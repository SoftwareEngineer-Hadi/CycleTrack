import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models.dart';
import '../../../core/providers.dart';
import '../../../core/sync/supabase_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../sync/auto_backup.dart';
import '../../sync/sync_service.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _busy = false;
  String? _message;
  bool? _messageIsError;

  SyncService get _sync => SyncService(ref.read(databaseProvider));

  Future<void> _setAutoBackup(bool value) async {
    await ref.read(databaseProvider).setSetting(
          SettingsKeys.autoBackupEnabled,
          value.toString(),
        );
  }

  Future<void> _run(
    Future<void> Function() action,
    String okMsg, {
    bool refreshAfterRestore = false,
  }) async {
    setState(() {
      _busy = true;
      _message = null;
      _messageIsError = null;
    });
    try {
      await action();
      if (refreshAfterRestore) {
        await refreshAfterCloudRestore(ref);
      }
      if (mounted) {
        setState(() {
          _message = okMsg;
          _messageIsError = false;
        });
      }
    } on SyncException catch (e) {
      if (mounted) {
        setState(() {
          _message = e.message;
          _messageIsError = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _message = e.toString().replaceFirst('Bad state: ', '');
          _messageIsError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmRestore() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore from cloud?'),
        content: const Text(
          'This replaces all local cycle data, settings, and pill reminders '
          'with your cloud backup. Make a manual backup first if this device '
          'has newer data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await _run(
      _sync.restore,
      'Backup restored — your data is up to date',
      refreshAfterRestore: true,
    );
  }

  Future<void> _backupNow() async {
    await _run(_sync.backup, 'Backup saved to cloud');
    // Enable auto-backup after the first successful manual backup.
    final auto =
        ref.read(settingsMapProvider)[SettingsKeys.autoBackupEnabled];
    if (auto != 'true') {
      await _setAutoBackup(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.cycleColors;
    final settings = ref.watch(settingsMapProvider);
    final last = settings[SettingsKeys.lastBackupAt];
    final autoBackup = settings[SettingsKeys.autoBackupEnabled] == 'true';
    final user = ref.watch(authUserProvider).valueOrNull;
    final signedIn = user != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Backup & restore')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Encrypted cloud sync',
                      style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Google sign-in backs up an AES-256-GCM encrypted blob. '
                    'Your cycle data is encrypted on this device before upload. '
                    'Restore works on a new phone with the same Google account.',
                    style: theme.textTheme.bodyMedium!
                        .copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (!supabaseConfigured)
            Card(
              child: ListTile(
                leading: Icon(Icons.warning_amber_rounded,
                    color: theme.colorScheme.error),
                title: const Text('Supabase not configured'),
                subtitle: const Text(
                  'Run with --dart-define=SUPABASE_URL=... and '
                  'SUPABASE_ANON_KEY=... to enable sync.',
                ),
              ),
            )
          else ...[
            Card(
              child: ListTile(
                leading: Icon(
                  signedIn ? Icons.check_circle : Icons.account_circle_outlined,
                  color: signedIn ? colors.fertile : colors.textSecondary,
                ),
                title: Text(
                  signedIn ? (user.email ?? 'Signed in') : 'Not signed in',
                ),
                subtitle: Text(
                  signedIn
                      ? 'Ready to backup and restore on any device'
                      : 'Sign in with Google to sync',
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (!signedIn)
              FilledButton.icon(
                onPressed: _busy
                    ? null
                    : () => _run(
                          _sync.signInWithGoogle,
                          'Sign-in started — complete in your browser',
                        ),
                icon: const Icon(Icons.login),
                label: const Text('Continue with Google'),
              )
            else ...[
              FilledButton.icon(
                onPressed: _busy ? null : _backupNow,
                icon: const Icon(Icons.cloud_upload_outlined),
                label: const Text('Backup now'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _busy ? null : _confirmRestore,
                icon: const Icon(Icons.cloud_download_outlined),
                label: const Text('Restore from cloud'),
              ),
              const SizedBox(height: 10),
              Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.sync_outlined),
                  title: const Text('Auto-backup'),
                  subtitle: const Text(
                    'Encrypt and upload when you leave the app (every 12+ hours)',
                  ),
                  value: autoBackup,
                  onChanged: _busy ? null : (v) => _setAutoBackup(v),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: _busy ? null : () => _run(_sync.signOut, 'Signed out'),
                child: const Text('Sign out'),
              ),
            ],
            if (last != null) ...[
              const SizedBox(height: 16),
              Text(
                'Last backup: ${DateFormat.yMMMd().add_jm().format(DateTime.parse(last))}',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ],
          if (_busy) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
          ],
          if (_message != null) ...[
            const SizedBox(height: 16),
            Card(
              color: _messageIsError == true
                  ? theme.colorScheme.errorContainer
                  : colors.soft,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(
                      _messageIsError == true
                          ? Icons.error_outline
                          : Icons.check_circle_outline,
                      color: _messageIsError == true
                          ? theme.colorScheme.error
                          : colors.fertile,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _message!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
