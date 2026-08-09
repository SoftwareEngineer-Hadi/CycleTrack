import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/cycle/domain/cycle_engine.dart';
import 'db/database.dart';
import 'models.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final settingsProvider = StreamProvider<Map<String, String>>(
  (ref) => ref.watch(databaseProvider).watchAllSettings(),
);

/// Convenience synchronous view of settings (empty map while loading).
final settingsMapProvider = Provider<Map<String, String>>(
  (ref) => ref.watch(settingsProvider).value ?? const {},
);

final dayLogsProvider = StreamProvider<List<DayLog>>(
  (ref) => ref.watch(databaseProvider).watchAllLogs(),
);

final dayLogsMapProvider = Provider<Map<DateTime, DayLog>>((ref) {
  final logs = ref.watch(dayLogsProvider).value ?? const [];
  return {for (final l in logs) DateTime(l.date.year, l.date.month, l.date.day): l};
});

/// Periods derived from logged flow days.
final periodsProvider = Provider<List<PeriodRecord>>((ref) {
  final logs = ref.watch(dayLogsProvider).value ?? const [];
  return CycleEngine.derivePeriods(
    logs.where((l) => l.flow != null).map((l) => l.date),
  );
});

final cycleEngineProvider = Provider<CycleEngine>((ref) {
  final settings = ref.watch(settingsMapProvider);
  return CycleEngine(
    cycleLengthOverride:
        int.tryParse(settings[SettingsKeys.cycleLengthOverride] ?? ''),
    periodLengthOverride:
        int.tryParse(settings[SettingsKeys.periodLengthOverride] ?? ''),
    lutealLength:
        int.tryParse(settings[SettingsKeys.lutealLength] ?? '') ?? 14,
  );
});

final cycleStatsProvider = Provider<CycleStats>((ref) {
  final engine = ref.watch(cycleEngineProvider);
  return engine.stats(ref.watch(periodsProvider));
});

final predictionsProvider = Provider<List<CyclePrediction>>((ref) {
  final engine = ref.watch(cycleEngineProvider);
  return engine.predict(ref.watch(periodsProvider));
});

final pregnancyModeProvider = Provider<bool>((ref) =>
    ref.watch(settingsMapProvider)[SettingsKeys.pregnancyMode] == 'true');

final pregnancyInfoProvider = Provider<PregnancyInfo?>((ref) {
  if (!ref.watch(pregnancyModeProvider)) return null;
  final lmpString =
      ref.watch(settingsMapProvider)[SettingsKeys.pregnancyLmp];
  final lmp = DateTime.tryParse(lmpString ?? '');
  if (lmp == null) return null;
  return CycleEngine.pregnancyInfo(lmp, DateTime.now());
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  switch (ref.watch(settingsMapProvider)[SettingsKeys.themeMode]) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
});

final onboardingDoneProvider = Provider<bool?>((ref) {
  final settings = ref.watch(settingsProvider);
  if (settings.isLoading) return null;
  return (settings.value ?? const {})[SettingsKeys.onboardingDone] == 'true';
});
