import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models.dart';
import '../../../core/providers.dart';
import '../../../core/sync/supabase_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../sync/sync_service.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _busy = false;
  String? _message;

  SyncService get _sync => SyncService(ref.read(databaseProvider));

  Future<void> _run(Future<void> Function() action, String okMsg) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await action();
      setState(() => _message = okMsg);
    } catch (e) {
      setState(() => _message = e.toString().replaceFirst('Bad state: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.cycleColors;
    final settings = ref.watch(settingsMapProvider);
    final last = settings[SettingsKeys.lastBackupAt];
    final signedIn = _sync.currentUser != null;

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
                    'Optional Google sign-in backs up an AES-256-GCM encrypted '
                    'blob. CycleTrack never uploads plaintext cycle data.',
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
                  color: signedIn
                      ? colors.fertile
                      : colors.textSecondary,
                ),
                title: Text(signedIn
                    ? (_sync.currentUser?.email ?? 'Signed in')
                    : 'Not signed in'),
                subtitle: Text(signedIn
                    ? 'Ready to backup and restore'
                    : 'Sign in with Google to sync'),
              ),
            ),
            const SizedBox(height: 12),
            if (!signedIn)
              FilledButton.icon(
                onPressed: _busy
                    ? null
                    : () => _run(
                          () async {
                            await _sync.signInWithGoogle();
                          },
                          'Sign-in started — complete in browser',
                        ),
                icon: const Icon(Icons.login),
                label: const Text('Continue with Google'),
              )
            else ...[
              FilledButton.icon(
                onPressed: _busy
                    ? null
                    : () => _run(_sync.backup, 'Backup saved'),
                icon: const Icon(Icons.cloud_upload_outlined),
                label: const Text('Backup now'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _busy
                    ? null
                    : () => _run(_sync.restore, 'Backup restored'),
                icon: const Icon(Icons.cloud_download_outlined),
                label: const Text('Restore from cloud'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _busy
                    ? null
                    : () => _run(_sync.signOut, 'Signed out'),
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
            Text(
              _message!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}
