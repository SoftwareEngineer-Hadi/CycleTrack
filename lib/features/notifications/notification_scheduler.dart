import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/models.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/providers.dart';

/// Keeps local notifications in sync whenever predictions, settings, or pill
/// reminders change.
final notificationSchedulerProvider = Provider<void>((ref) {
  ref.listen(predictionsProvider, (_, next) {
    _scheduleCycle(ref, next);
  });
  ref.listen(settingsProvider, (_, _) {
    _scheduleCycle(ref, ref.read(predictionsProvider));
  });
  ref.listen(_pillRemindersProvider, (_, next) {
    next.whenData(NotificationService.instance.schedulePillReminders);
  });

  final predictions = ref.read(predictionsProvider);
  if (predictions.isNotEmpty) {
    _scheduleCycle(ref, predictions);
  }
});

void _scheduleCycle(Ref ref, List predictions) {
  final settings = ref.read(settingsMapProvider);
  NotificationService.instance.scheduleCycleNotifications(
    predictions: List.from(predictions),
    periodEnabled: settings[SettingsKeys.notifyPeriod] != 'false',
    fertileEnabled: settings[SettingsKeys.notifyFertile] != 'false',
    ovulationEnabled: settings[SettingsKeys.notifyOvulation] != 'false',
    lateEnabled: settings[SettingsKeys.notifyLatePeriod] != 'false',
    pregnancyMode: settings[SettingsKeys.pregnancyMode] == 'true',
  );
}

final _pillRemindersProvider = StreamProvider<List<PillReminder>>(
  (ref) => ref.watch(databaseProvider).watchPillReminders(),
);

/// Call after onboarding or when the user enables notifications.
Future<void> requestNotificationPermissions() =>
    NotificationService.instance.requestPermissions();
