import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';
import '../../core/providers.dart';

/// Whether the app is currently locked behind PIN/biometrics.
final appLockProvider = StateProvider<bool>((ref) => false);

String hashPin(String pin) => sha256.convert(utf8.encode('cycletrack:$pin')).toString();

/// Locks the app on startup if a PIN has been configured.
Future<void> initAppLock(ProviderContainer container) async {
  final db = container.read(databaseProvider);
  final pinHash = await db.getSetting(SettingsKeys.pinHash);
  if (pinHash != null && pinHash.isNotEmpty) {
    container.read(appLockProvider.notifier).state = true;
  }
}
