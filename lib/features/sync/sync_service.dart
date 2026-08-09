import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/db/database.dart';
import '../../core/models.dart';
import '../../core/sync/supabase_config.dart';
import '../../core/sync/auth_callback.dart';

/// Thrown when cloud backup/restore fails with a user-facing message.
class SyncException implements Exception {
  SyncException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Client-side AES-GCM encrypted backup to Supabase.
///
/// Payload is encrypted with a random data key. The key is wrapped with a
/// user-derived secret so restore works on a new device after Google sign-in.
class SyncService {
  SyncService(this._db);

  final AppDatabase _db;
  static const _backupKeyStorage = 'cycletrack_backup_key';
  static const _table = 'encrypted_backups';
  static const _wrapInfo = 'cycletrack-backup-key-v1';
  static const _wrapSalt = 'cycletrack-backup-salt';
  static const _minAutoBackupInterval = Duration(hours: 12);

  final _storage = const FlutterSecureStorage();
  final _cipher = AesGcm.with256bits();

  bool get isConfigured => supabaseConfigured;

  SupabaseClient? get _client =>
      supabaseConfigured ? Supabase.instance.client : null;

  User? get currentUser => _client?.auth.currentUser;

  /// Opens the Google OAuth flow. Completes in browser; session arrives via deep link.
  Future<void> signInWithGoogle() async {
    final client = _client;
    if (client == null) {
      throw SyncException('Supabase is not configured for this build');
    }
    try {
      final ok = await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: supabaseAuthRedirectUrl,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      if (!ok) {
        throw SyncException('Google sign-in was cancelled');
      }
    } on AuthException catch (e) {
      throw SyncException(e.message);
    } on SyncException {
      rethrow;
    } catch (e) {
      throw SyncException('Could not start Google sign-in: $e');
    }
  }

  Future<void> signOut() async {
    await _client?.auth.signOut();
  }

  Future<SecretKey> _dataKey({bool createIfMissing = true}) async {
    var raw = await _storage.read(key: _backupKeyStorage);
    if (raw == null) {
      if (!createIfMissing) {
        throw SyncException('No local encryption key — restore from cloud first');
      }
      final bytes = List<int>.generate(32, (_) => Random.secure().nextInt(256));
      raw = base64UrlEncode(bytes);
      await _storage.write(key: _backupKeyStorage, value: raw);
    }
    return SecretKey(base64Url.decode(raw));
  }

  Future<void> _persistDataKey(SecretKey key) async {
    final bytes = await key.extractBytes();
    await _storage.write(
      key: _backupKeyStorage,
      value: base64UrlEncode(bytes),
    );
  }

  Future<SecretKey> _wrapKey(String userId) async {
    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
    return hkdf.deriveKey(
      secretKey: SecretKey(utf8.encode(userId)),
      info: utf8.encode(_wrapInfo),
      nonce: utf8.encode(_wrapSalt),
    );
  }

  Future<String> _wrapDataKey(SecretKey dataKey, String userId) async {
    final wrapSecret = await _wrapKey(userId);
    final raw = await dataKey.extractBytes();
    final box = await _cipher.encrypt(raw, secretKey: wrapSecret);
    final combined = BytesBuilder()
      ..add(box.nonce)
      ..add(box.cipherText)
      ..add(box.mac.bytes);
    return base64Encode(combined.toBytes());
  }

  Future<SecretKey> _unwrapDataKey(String wrapped, String userId) async {
    final wrapSecret = await _wrapKey(userId);
    final bytes = base64Decode(wrapped);
    final nonce = bytes.sublist(0, 12);
    final mac = Mac(bytes.sublist(bytes.length - 16));
    final cipherText = bytes.sublist(12, bytes.length - 16);
    final clear = await _cipher.decrypt(
      SecretBox(cipherText, nonce: nonce, mac: mac),
      secretKey: wrapSecret,
    );
    return SecretKey(clear);
  }

  Future<String> _encrypt(Map<String, dynamic> payload, SecretKey secret) async {
    final clear = utf8.encode(jsonEncode(payload));
    final box = await _cipher.encrypt(clear, secretKey: secret);
    final combined = BytesBuilder()
      ..add(box.nonce)
      ..add(box.cipherText)
      ..add(box.mac.bytes);
    return base64Encode(combined.toBytes());
  }

  Future<Map<String, dynamic>> _decrypt(String blob, SecretKey secret) async {
    final bytes = base64Decode(blob);
    final nonce = bytes.sublist(0, 12);
    final mac = Mac(bytes.sublist(bytes.length - 16));
    final cipherText = bytes.sublist(12, bytes.length - 16);
    final clear = await _cipher.decrypt(
      SecretBox(cipherText, nonce: nonce, mac: mac),
      secretKey: secret,
    );
    return jsonDecode(utf8.decode(clear)) as Map<String, dynamic>;
  }

  Future<void> backup() async {
    final client = _client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) {
      throw SyncException('Sign in to back up');
    }

    try {
      final dataKey = await _dataKey();
      final payload = await _db.exportAsJson();
      final ciphertext = await _encrypt(payload, dataKey);
      final wrappedKey = await _wrapDataKey(dataKey, user.id);

      await client.from(_table).upsert({
        'user_id': user.id,
        'ciphertext': ciphertext,
        'wrapped_key': wrappedKey,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
      await _db.setSetting(
        SettingsKeys.lastBackupAt,
        DateTime.now().toIso8601String(),
      );
    } on PostgrestException catch (e) {
      throw SyncException('Backup failed: ${e.message}');
    } on SocketException {
      throw SyncException('No internet connection — try again when online');
    } on SyncException {
      rethrow;
    } catch (e) {
      throw SyncException('Backup failed: $e');
    }
  }

  /// Backs up when signed in, auto-backup is on, and enough time has passed.
  Future<bool> backupIfDue({bool force = false}) async {
    if (!isConfigured || currentUser == null) return false;

    final auto =
        await _db.getSetting(SettingsKeys.autoBackupEnabled);
    if (!force && auto != 'true') return false;

    if (!force) {
      final lastRaw = await _db.getSetting(SettingsKeys.lastBackupAt);
      if (lastRaw != null) {
        final last = DateTime.tryParse(lastRaw);
        if (last != null &&
            DateTime.now().difference(last) < _minAutoBackupInterval) {
          return false;
        }
      }
    }

    await backup();
    return true;
  }

  Future<void> restore() async {
    final client = _client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) {
      throw SyncException('Sign in to restore');
    }

    try {
      final row = await client
          .from(_table)
          .select('ciphertext, wrapped_key')
          .eq('user_id', user.id)
          .maybeSingle();
      if (row == null) {
        throw SyncException('No backup found for this account');
      }

      final wrapped = row['wrapped_key'] as String?;
      late final SecretKey dataKey;
      if (wrapped != null && wrapped.isNotEmpty) {
        dataKey = await _unwrapDataKey(wrapped, user.id);
        await _persistDataKey(dataKey);
      } else {
        dataKey = await _dataKey(createIfMissing: false);
      }

      final data = await _decrypt(row['ciphertext'] as String, dataKey);
      await _db.importFromJson(data);
    } on PostgrestException catch (e) {
      throw SyncException('Restore failed: ${e.message}');
    } on SocketException {
      throw SyncException('No internet connection — try again when online');
    } on SecretBoxAuthenticationError {
      throw SyncException(
        'Could not decrypt backup — sign in with the same Google account',
      );
    } on SyncException {
      rethrow;
    } catch (e) {
      throw SyncException('Restore failed: $e');
    }
  }

  Future<void> deleteCloudBackup() async {
    final client = _client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) return;
    try {
      await client.from(_table).delete().eq('user_id', user.id);
    } on PostgrestException catch (e) {
      throw SyncException('Could not delete cloud backup: ${e.message}');
    }
  }
}
