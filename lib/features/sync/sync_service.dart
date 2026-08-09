import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/db/database.dart';
import '../../core/models.dart';
import '../../core/sync/supabase_config.dart';

/// Client-side AES-GCM encrypted backup to Supabase.
///
/// The server only stores an opaque ciphertext blob. The encryption key never
/// leaves the device (stored in [FlutterSecureStorage]).
class SyncService {
  SyncService(this._db);

  final AppDatabase _db;
  static const _backupKeyStorage = 'cycletrack_backup_key';
  static const _table = 'encrypted_backups';

  final _storage = const FlutterSecureStorage();
  final _cipher = AesGcm.with256bits();

  bool get isConfigured => supabaseConfigured;

  SupabaseClient? get _client =>
      supabaseConfigured ? Supabase.instance.client : null;

  User? get currentUser => _client?.auth.currentUser;

  /// Opens the Google OAuth flow. Completes via deep link when configured.
  Future<void> signInWithGoogle() async {
    final client = _client;
    if (client == null) {
      throw StateError('Supabase is not configured');
    }
    final ok = await client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.cycletrack://login-callback/',
    );
    if (!ok) throw StateError('Google sign-in was cancelled');
  }

  Future<void> signOut() async {
    await _client?.auth.signOut();
  }

  Future<SecretKey> _backupKey() async {
    var raw = await _storage.read(key: _backupKeyStorage);
    if (raw == null) {
      final bytes = List<int>.generate(32, (_) => Random.secure().nextInt(256));
      raw = base64UrlEncode(bytes);
      await _storage.write(key: _backupKeyStorage, value: raw);
    }
    return SecretKey(base64Url.decode(raw));
  }

  Future<String> _encrypt(Map<String, dynamic> payload) async {
    final clear = utf8.encode(jsonEncode(payload));
    final secret = await _backupKey();
    final box = await _cipher.encrypt(clear, secretKey: secret);
    // nonce || ciphertext || mac
    final combined = BytesBuilder()
      ..add(box.nonce)
      ..add(box.cipherText)
      ..add(box.mac.bytes);
    return base64Encode(combined.toBytes());
  }

  Future<Map<String, dynamic>> _decrypt(String blob) async {
    final bytes = base64Decode(blob);
    // AES-GCM nonce is 12 bytes; mac is 16 bytes.
    final nonce = bytes.sublist(0, 12);
    final mac = Mac(bytes.sublist(bytes.length - 16));
    final cipherText = bytes.sublist(12, bytes.length - 16);
    final secret = await _backupKey();
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
      throw StateError('Sign in to back up');
    }
    final payload = await _db.exportAsJson();
    final ciphertext = await _encrypt(payload);
    await client.from(_table).upsert({
      'user_id': user.id,
      'ciphertext': ciphertext,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
    await _db.setSetting(
        SettingsKeys.lastBackupAt, DateTime.now().toIso8601String());
  }

  Future<void> restore() async {
    final client = _client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) {
      throw StateError('Sign in to restore');
    }
    final row = await client
        .from(_table)
        .select('ciphertext')
        .eq('user_id', user.id)
        .maybeSingle();
    if (row == null) throw StateError('No backup found for this account');
    final data = await _decrypt(row['ciphertext'] as String);
    await _db.importFromJson(data);
  }

  Future<void> deleteCloudBackup() async {
    final client = _client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) return;
    await client.from(_table).delete().eq('user_id', user.id);
  }
}
