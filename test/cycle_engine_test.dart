import 'package:cycletrack/core/models.dart';
import 'package:cycletrack/features/cycle/domain/cycle_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CycleEngine.derivePeriods', () {
    test('groups consecutive flow days', () {
      final periods = CycleEngine.derivePeriods([
        DateTime(2026, 1, 1),
        DateTime(2026, 1, 2),
        DateTime(2026, 1, 3),
        DateTime(2026, 1, 4),
        DateTime(2026, 1, 5),
        DateTime(2026, 1, 29),
        DateTime(2026, 1, 30),
        DateTime(2026, 1, 31),
        DateTime(2026, 2, 1),
        DateTime(2026, 2, 2),
      ]);
      expect(periods.length, 2);
      expect(periods[0].start, DateTime(2026, 1, 1));
      expect(periods[0].length, 5);
      expect(periods[1].start, DateTime(2026, 1, 29));
      expect(periods[1].length, 5);
    });

    test('allows a single missed day inside a period', () {
      final periods = CycleEngine.derivePeriods([
        DateTime(2026, 3, 1),
        DateTime(2026, 3, 2),
        // gap on Mar 3
        DateTime(2026, 3, 4),
        DateTime(2026, 3, 5),
      ]);
      expect(periods.length, 1);
      expect(periods.first.length, 5);
    });
  });

  group('predictions', () {
    final engine = CycleEngine();
    final periods = [
      PeriodRecord(start: DateTime(2026, 1, 1), length: 5),
      PeriodRecord(start: DateTime(2026, 1, 29), length: 5), // 28-day cycle
    ];

    test('next period is average cycle length after last start', () {
      final preds = engine.predict(periods, count: 1);
      expect(preds, hasLength(1));
      expect(preds.first.periodStart, DateTime(2026, 2, 26));
      expect(preds.first.periodEnd, DateTime(2026, 3, 2));
    });

    test('ovulation is lutealLength days before next period', () {
      final preds = engine.predict(periods, count: 1);
      expect(preds.first.ovulation, DateTime(2026, 2, 12));
      expect(preds.first.fertileStart, DateTime(2026, 2, 7));
      expect(preds.first.fertileEnd, DateTime(2026, 2, 13));
    });

    test('override wins over historical average', () {
      final custom = CycleEngine(cycleLengthOverride: 30);
      final preds = custom.predict(periods, count: 1);
      expect(preds.first.periodStart, DateTime(2026, 2, 28));
    });
  });

  group('phase and cycle day', () {
    final engine = CycleEngine();
    final periods = [
      PeriodRecord(start: DateTime(2026, 8, 1), length: 5),
    ];

    test('menstrual phase during period', () {
      expect(
        engine.phaseOn(DateTime(2026, 8, 3), periods),
        CyclePhase.menstrual,
      );
      expect(engine.cycleDay(DateTime(2026, 8, 3), periods), 3);
    });

    test('ovulation day around cycle day 14 for 28-day cycle', () {
      // Next period predicted Aug 29 → ovulation Aug 15
      expect(
        engine.phaseOn(DateTime(2026, 8, 15), periods),
        CyclePhase.ovulation,
      );
    });
  });

  group('pregnancy', () {
    test('computes week and trimester from LMP', () {
      final info = CycleEngine.pregnancyInfo(
        DateTime(2026, 4, 1),
        DateTime(2026, 8, 9), // ~18 weeks later
      );
      expect(info.week, 18);
      expect(info.trimester, 2);
      expect(info.dueDate, DateTime(2026, 4, 1).add(const Duration(days: 280)));
      expect(info.milestone, isNotEmpty);
    });
  });

  group('stats irregularity', () {
    test('flags high variance', () {
      final engine = CycleEngine();
      final periods = [
        PeriodRecord(start: DateTime(2026, 1, 1), length: 5),
        PeriodRecord(start: DateTime(2026, 1, 22), length: 5), // 21
        PeriodRecord(start: DateTime(2026, 2, 26), length: 5), // 35
        PeriodRecord(start: DateTime(2026, 3, 20), length: 5), // 22
        PeriodRecord(start: DateTime(2026, 4, 24), length: 5), // 35
      ];
      final stats = engine.stats(periods);
      expect(stats.isIrregular, isTrue);
    });
  });
}
