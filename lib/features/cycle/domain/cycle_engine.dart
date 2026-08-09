import 'dart:math' as math;

import '../../../core/models.dart';

/// A single menstrual period derived from logged flow days.
class PeriodRecord {
  const PeriodRecord({required this.start, required this.length});

  final DateTime start;

  /// Number of consecutive flow days.
  final int length;

  DateTime get end => start.add(Duration(days: length - 1));
}

/// One predicted future cycle.
class CyclePrediction {
  const CyclePrediction({
    required this.periodStart,
    required this.periodEnd,
    required this.ovulation,
    required this.fertileStart,
    required this.fertileEnd,
  });

  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime ovulation;
  final DateTime fertileStart;
  final DateTime fertileEnd;
}

/// Aggregated history statistics used by predictions and the analytics UI.
class CycleStats {
  const CycleStats({
    required this.averageCycleLength,
    required this.averagePeriodLength,
    required this.cycleLengths,
    required this.standardDeviation,
  });

  final int averageCycleLength;
  final int averagePeriodLength;

  /// Historical cycle lengths, oldest first (may be empty).
  final List<int> cycleLengths;
  final double standardDeviation;

  /// Cycles varying by more than ~4 days are commonly considered irregular.
  bool get isIrregular => standardDeviation > 4;
}

/// Pregnancy progress derived from the last menstrual period date.
class PregnancyInfo {
  const PregnancyInfo({
    required this.lmp,
    required this.week,
    required this.dayOfWeek,
    required this.trimester,
    required this.dueDate,
    required this.milestone,
  });

  final DateTime lmp;

  /// Completed gestational weeks (0-based counting, "week 18" style).
  final int week;

  /// Day within the current week, 1..7.
  final int dayOfWeek;
  final int trimester;
  final DateTime dueDate;
  final String milestone;
}

/// Pure-Dart prediction engine. No Flutter or database dependencies, so it is
/// fully unit-testable.
class CycleEngine {
  CycleEngine({
    this.defaultCycleLength = 28,
    this.defaultPeriodLength = 5,
    this.lutealLength = 14,
    this.cycleLengthOverride,
    this.periodLengthOverride,
    this.historyWindow = 6,
  });

  final int defaultCycleLength;
  final int defaultPeriodLength;

  /// Days between ovulation and the next period start.
  final int lutealLength;

  /// User-pinned values for irregular cycles; take precedence over averages.
  final int? cycleLengthOverride;
  final int? periodLengthOverride;

  /// How many most-recent cycles feed the averages.
  final int historyWindow;

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Groups logged flow days (any [FlowLevel]) into consecutive periods.
  /// [flowDays] does not need to be sorted.
  static List<PeriodRecord> derivePeriods(Iterable<DateTime> flowDays) {
    final days = flowDays.map(_day).toSet().toList()..sort();
    if (days.isEmpty) return [];

    final periods = <PeriodRecord>[];
    var start = days.first;
    var length = 1;
    for (var i = 1; i < days.length; i++) {
      final gap = days[i].difference(days[i - 1]).inDays;
      // Allow a 1-day logging gap within the same period.
      if (gap <= 2) {
        length = days[i].difference(start).inDays + 1;
      } else {
        periods.add(PeriodRecord(start: start, length: length));
        start = days[i];
        length = 1;
      }
    }
    periods.add(PeriodRecord(start: start, length: length));
    return periods;
  }

  /// Computes averages over the last [historyWindow] cycles.
  CycleStats stats(List<PeriodRecord> periods) {
    final cycleLengths = <int>[];
    for (var i = 1; i < periods.length; i++) {
      final len = periods[i].start.difference(periods[i - 1].start).inDays;
      // Ignore nonsense gaps (missed months of logging).
      if (len >= 15 && len <= 60) cycleLengths.add(len);
    }
    final recent = cycleLengths.length > historyWindow
        ? cycleLengths.sublist(cycleLengths.length - historyWindow)
        : cycleLengths;

    final avgCycle = recent.isEmpty
        ? defaultCycleLength
        : (recent.reduce((a, b) => a + b) / recent.length).round();

    final periodLengths = periods
        .map((p) => p.length)
        .where((l) => l >= 1 && l <= 10)
        .toList();
    final recentPeriods = periodLengths.length > historyWindow
        ? periodLengths.sublist(periodLengths.length - historyWindow)
        : periodLengths;
    final avgPeriod = recentPeriods.isEmpty
        ? defaultPeriodLength
        : (recentPeriods.reduce((a, b) => a + b) / recentPeriods.length)
            .round();

    double std = 0;
    if (recent.length >= 2) {
      final mean = recent.reduce((a, b) => a + b) / recent.length;
      final variance =
          recent.map((l) => (l - mean) * (l - mean)).reduce((a, b) => a + b) /
              recent.length;
      std = math.sqrt(variance);
    }

    return CycleStats(
      averageCycleLength: avgCycle,
      averagePeriodLength: avgPeriod,
      cycleLengths: recent,
      standardDeviation: std,
    );
  }

  int _effectiveCycleLength(CycleStats stats) =>
      cycleLengthOverride ?? stats.averageCycleLength;

  int _effectivePeriodLength(CycleStats stats) =>
      periodLengthOverride ?? stats.averagePeriodLength;

  /// Predicts the next [count] cycles following the last logged period.
  /// Returns an empty list when there is no logged period at all.
  List<CyclePrediction> predict(List<PeriodRecord> periods, {int count = 12}) {
    if (periods.isEmpty) return [];
    final s = stats(periods);
    final cycleLength = _effectiveCycleLength(s);
    final periodLength = _effectivePeriodLength(s);

    final predictions = <CyclePrediction>[];
    var start = periods.last.start;
    for (var i = 1; i <= count; i++) {
      final nextStart = start.add(Duration(days: cycleLength));
      final ovulation = nextStart.subtract(Duration(days: lutealLength));
      predictions.add(CyclePrediction(
        periodStart: nextStart,
        periodEnd: nextStart.add(Duration(days: periodLength - 1)),
        ovulation: ovulation,
        fertileStart: ovulation.subtract(const Duration(days: 5)),
        fertileEnd: ovulation.add(const Duration(days: 1)),
      ));
      start = nextStart;
    }
    return predictions;
  }

  /// The cycle phase for [date], given logged periods.
  CyclePhase phaseOn(DateTime date, List<PeriodRecord> periods) {
    final day = _day(date);
    final s = stats(periods);
    final periodLength = _effectivePeriodLength(s);

    for (final p in periods) {
      if (!day.isBefore(p.start) && !day.isAfter(p.end)) {
        return CyclePhase.menstrual;
      }
    }
    if (periods.isEmpty) return CyclePhase.follicular;

    // Locate the cycle containing `day`: the last known/predicted period
    // start not after `day`.
    final all = [
      ...periods.map((p) => p.start),
      ...predict(periods, count: 13).map((p) => p.periodStart),
    ]..sort();
    DateTime cycleStart = all.first;
    DateTime? nextStart;
    for (final startDate in all) {
      if (!startDate.isAfter(day)) {
        cycleStart = startDate;
      } else {
        nextStart = startDate;
        break;
      }
    }
    nextStart ??=
        cycleStart.add(Duration(days: _effectiveCycleLength(s)));

    if (day.difference(cycleStart).inDays < periodLength) {
      return CyclePhase.menstrual;
    }
    final ovulation = nextStart.subtract(Duration(days: lutealLength));
    final diff = day.difference(ovulation).inDays;
    if (diff == 0) return CyclePhase.ovulation;
    if (diff >= -5 && diff <= 1) return CyclePhase.fertile;
    if (diff > 1) return CyclePhase.luteal;
    return CyclePhase.follicular;
  }

  /// 1-based day number within the current cycle.
  int? cycleDay(DateTime date, List<PeriodRecord> periods) {
    if (periods.isEmpty) return null;
    final day = _day(date);
    DateTime? cycleStart;
    for (final p in periods) {
      if (!p.start.isAfter(day)) cycleStart = p.start;
    }
    if (cycleStart == null) return null;
    return day.difference(cycleStart).inDays + 1;
  }

  /// Days until the next predicted period (negative = late by N days).
  int? daysUntilNextPeriod(DateTime date, List<PeriodRecord> periods) {
    final predictions = predict(periods, count: 1);
    if (predictions.isEmpty) return null;
    return predictions.first.periodStart.difference(_day(date)).inDays;
  }

  // ----- Pregnancy mode -----

  static PregnancyInfo pregnancyInfo(DateTime lmp, DateTime today) {
    final days = _day(today).difference(_day(lmp)).inDays.clamp(0, 320);
    final week = days ~/ 7;
    final trimester = week < 13
        ? 1
        : week < 27
            ? 2
            : 3;
    return PregnancyInfo(
      lmp: _day(lmp),
      week: week,
      dayOfWeek: days % 7 + 1,
      trimester: trimester,
      dueDate: _day(lmp).add(const Duration(days: 280)),
      milestone: milestoneForWeek(week),
    );
  }

  static String milestoneForWeek(int week) {
    const milestones = <int, String>{
      4: 'Your baby is the size of a poppy seed. The neural tube is forming.',
      6: 'A tiny heart has started beating — about the size of a lentil.',
      8: 'All major organs have begun to form. Baby is raspberry-sized.',
      10: 'Baby is now officially a fetus and can bend little limbs.',
      12: 'Fingernails and toenails are forming. Size of a plum.',
      14: 'Baby can squint and frown. Second trimester begins!',
      16: 'Baby can hear muffled sounds from the outside world.',
      18: 'You might feel the first flutters of movement soon.',
      20: 'Halfway there! Baby is about the size of a banana.',
      24: 'Lungs are developing branches and surfactant production begins.',
      28: 'Third trimester! Baby can open and close those little eyes.',
      32: 'Baby is practicing breathing movements. About 1.7 kg now.',
      36: 'Baby is head-down (usually) and gaining ~30 g per day.',
      40: 'Full term — your baby could arrive any day now!',
    };
    var best = milestones[4]!;
    for (final entry in milestones.entries) {
      if (week >= entry.key) best = entry.value;
    }
    return best;
  }
}
