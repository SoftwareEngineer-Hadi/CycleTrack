import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/providers.dart';

/// Keeps local notifications in sync whenever predictions or settings change.
final notificationSchedulerProvider = Provider<void>((ref) {
  ref.listen(predictionsProvider, (_, next) {
    _schedule(ref, next);
  });
  ref.listen(settingsProvider, (_, _) {
    _schedule(ref, ref.read(predictionsProvider));
  });
  // Initial schedule once data is available.
  final predictions = ref.read(predictionsProvider);
  if (predictions.isNotEmpty) {
    _schedule(ref, predictions);
  }
});

void _schedule(Ref ref, List predictions) {
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
