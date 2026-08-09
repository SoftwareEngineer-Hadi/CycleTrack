import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/providers.dart';
import '../../core/sync/supabase_config.dart';
import '../../features/sync/sync_service.dart';

/// Runs encrypted cloud backup when the app moves to the background.
class AutoBackupLifecycle extends ConsumerStatefulWidget {
  const AutoBackupLifecycle({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AutoBackupLifecycle> createState() =>
      _AutoBackupLifecycleState();
}

class _AutoBackupLifecycleState extends ConsumerState<AutoBackupLifecycle>
    with WidgetsBindingObserver {
  bool _backingUp = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _maybeAutoBackup();
    }
  }

  Future<void> _maybeAutoBackup() async {
    if (!supabaseConfigured || _backingUp) return;
    final user = ref.read(authUserProvider).valueOrNull;
    if (user == null) return;

    final settings = ref.read(settingsMapProvider);
    if (settings[SettingsKeys.autoBackupEnabled] != 'true') return;

    _backingUp = true;
    try {
      await SyncService(ref.read(databaseProvider)).backupIfDue();
    } catch (_) {
      // Silent on background — user can retry manually from Backup screen.
    } finally {
      _backingUp = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Refreshes Riverpod state and notifications after a cloud restore.
Future<void> refreshAfterCloudRestore(WidgetRef ref) async {
  ref.invalidate(dayLogsProvider);
  ref.invalidate(settingsProvider);
  ref.invalidate(authUserProvider);

  final settings = ref.read(settingsMapProvider);
  final predictions = ref.read(predictionsProvider);
  NotificationService.instance.scheduleCycleNotifications(
    predictions: predictions,
    periodEnabled: settings[SettingsKeys.notifyPeriod] != 'false',
    fertileEnabled: settings[SettingsKeys.notifyFertile] != 'false',
    ovulationEnabled: settings[SettingsKeys.notifyOvulation] != 'false',
    lateEnabled: settings[SettingsKeys.notifyLatePeriod] != 'false',
    pregnancyMode: settings[SettingsKeys.pregnancyMode] == 'true',
  );

  final pills = await ref.read(databaseProvider).getPillReminders();
  await NotificationService.instance.schedulePillReminders(pills);
}
