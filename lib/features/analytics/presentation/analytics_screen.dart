import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../cycle/domain/cycle_engine.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs =
      TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.cycleColors;
    final stats = ref.watch(cycleStatsProvider);
    final periods = ref.watch(periodsProvider);
    final logs = ref.watch(dayLogsProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colors.soft,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: TabBar(
                  controller: _tabs,
                  indicator: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: colors.textSecondary,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'BBT'),
                    Tab(text: 'Weight'),
                    Tab(text: 'Cycles'),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      value: '${stats.averageCycleLength}',
                      label: 'Avg cycle days',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      value: '${stats.averagePeriodLength}',
                      label: 'Avg period days',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      value: stats.standardDeviation == 0
                          ? '—'
                          : '±${stats.standardDeviation.toStringAsFixed(0)}',
                      label: 'Cycle variation',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _BbtChart(logs: logs, predictions: ref.watch(predictionsProvider)),
                  _WeightChart(logs: logs),
                  _CycleHistoryChart(periods: periods, stats: stats),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text(value, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _BbtChart extends StatelessWidget {
  const _BbtChart({required this.logs, required this.predictions});

  final List logs;
  final List<CyclePrediction> predictions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.cycleColors;
    final points = logs
        .where((l) => l.bbtCelsius != null)
        .map((l) => MapEntry(l.date as DateTime, l.bbtCelsius as double))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // Last 30 days of readings, or all if fewer.
    final recent = points.length > 30
        ? points.sublist(points.length - 30)
        : points;

    if (recent.isEmpty) {
      return const _EmptyChart(
        message: 'Log basal body temperature in your daily log to see trends.',
      );
    }

    final minY =
        recent.map((e) => e.value).reduce((a, b) => a < b ? a : b) - 0.2;
    final maxY =
        recent.map((e) => e.value).reduce((a, b) => a > b ? a : b) + 0.2;
    final spots = [
      for (var i = 0; i < recent.length; i++)
        FlSpot(i.toDouble(), recent[i].value),
    ];

    // Highlight ovulation shift if we have a recent prediction near the data.
    final ovulationIndex = () {
      if (predictions.isEmpty) return -1;
      final ov = predictions.first.ovulation;
      for (var i = 0; i < recent.length; i++) {
        if (recent[i].key.year == ov.year &&
            recent[i].key.month == ov.month &&
            recent[i].key.day == ov.day) {
          return i;
        }
      }
      return -1;
    }();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Basal body temperature',
                  style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                ovulationIndex >= 0
                    ? 'Temperature shift near ovulation day'
                    : 'Looking for a sustained rise after ovulation',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: LineChart(
                  LineChartData(
                    minY: minY,
                    maxY: maxY,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: colors.border,
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (v, _) => Text(
                            v.toStringAsFixed(1),
                            style: theme.textTheme.labelSmall,
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: (recent.length / 4).clamp(1, 10).toDouble(),
                          getTitlesWidget: (v, _) {
                            final i = v.round();
                            if (i < 0 || i >= recent.length) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              DateFormat.Md().format(recent[i].key),
                              style: theme.textTheme.labelSmall,
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: colors.bbt,
                        barWidth: 2.5,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, bar, index) =>
                              FlDotCirclePainter(
                            radius: 3.5,
                            color: colors.bbt,
                            strokeWidth: 0,
                          ),
                        ),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                    extraLinesData: ExtraLinesData(
                      verticalLines: ovulationIndex >= 0
                          ? [
                              VerticalLine(
                                x: ovulationIndex.toDouble(),
                                color: colors.ovulation.withValues(alpha: 0.5),
                                strokeWidth: 2,
                                dashArray: [4, 4],
                              ),
                            ]
                          : const [],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeightChart extends StatelessWidget {
  const _WeightChart({required this.logs});

  final List logs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.cycleColors;
    final points = logs
        .where((l) => l.weightKg != null)
        .map((l) => MapEntry(l.date as DateTime, l.weightKg as double))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final recent =
        points.length > 60 ? points.sublist(points.length - 60) : points;

    if (recent.isEmpty) {
      return const _EmptyChart(
        message: 'Log your weight in the daily log to track fluctuations.',
      );
    }

    final minY =
        recent.map((e) => e.value).reduce((a, b) => a < b ? a : b) - 1;
    final maxY =
        recent.map((e) => e.value).reduce((a, b) => a > b ? a : b) + 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Weight', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              Expanded(
                child: LineChart(
                  LineChartData(
                    minY: minY,
                    maxY: maxY,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) =>
                          FlLine(color: colors.border, strokeWidth: 1),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (v, _) => Text(
                            v.toStringAsFixed(0),
                            style: theme.textTheme.labelSmall,
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: (recent.length / 4).clamp(1, 15).toDouble(),
                          getTitlesWidget: (v, _) {
                            final i = v.round();
                            if (i < 0 || i >= recent.length) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              DateFormat.Md().format(recent[i].key),
                              style: theme.textTheme.labelSmall,
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          for (var i = 0; i < recent.length; i++)
                            FlSpot(i.toDouble(), recent[i].value),
                        ],
                        isCurved: true,
                        color: theme.colorScheme.primary,
                        barWidth: 2.5,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: theme.colorScheme.primary
                              .withValues(alpha: 0.12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CycleHistoryChart extends StatelessWidget {
  const _CycleHistoryChart({required this.periods, required this.stats});

  final List<PeriodRecord> periods;
  final CycleStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.cycleColors;
    final lengths = stats.cycleLengths;

    if (lengths.isEmpty) {
      return const _EmptyChart(
        message:
            'Log at least two periods to compare cycle lengths over months.',
      );
    }

    // Pair cycle lengths with the period that ended them (index i uses period i+1 start month).
    final labels = <String>[];
    for (var i = 1; i < periods.length && labels.length < lengths.length; i++) {
      final len = periods[i].start.difference(periods[i - 1].start).inDays;
      if (len >= 15 && len <= 60) {
        labels.add(DateFormat.MMM().format(periods[i].start));
      }
    }
    while (labels.length < lengths.length) {
      labels.insert(0, '—');
    }
    final shown = lengths.length > 6
        ? lengths.sublist(lengths.length - 6)
        : lengths;
    final shownLabels = labels.length > 6
        ? labels.sublist(labels.length - 6)
        : labels;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cycle history', style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                stats.isIrregular
                    ? 'Higher variation detected — predictions may be less precise'
                    : 'Your cycles are fairly consistent',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BarChart(
                  BarChartData(
                    maxY: (shown.reduce((a, b) => a > b ? a : b) + 5)
                        .toDouble(),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) =>
                          FlLine(color: colors.border, strokeWidth: 1),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (v, _) => Text(
                            v.toInt().toString(),
                            style: theme.textTheme.labelSmall,
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            final i = v.toInt();
                            if (i < 0 || i >= shownLabels.length) {
                              return const SizedBox.shrink();
                            }
                            return Text(shownLabels[i],
                                style: theme.textTheme.labelSmall);
                          },
                        ),
                      ),
                    ),
                    barGroups: [
                      for (var i = 0; i < shown.length; i++)
                        BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: shown[i].toDouble(),
                              width: 22,
                              borderRadius: BorderRadius.circular(7),
                              color: i == shown.length - 1
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.primary
                                      .withValues(alpha: 0.55),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ),
    );
  }
}
