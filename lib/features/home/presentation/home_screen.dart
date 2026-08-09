import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../calendar/presentation/day_log_sheet.dart';
import '../../cycle/domain/cycle_engine.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pregnancy = ref.watch(pregnancyInfoProvider);
    return Scaffold(
      body: SafeArea(
        child: pregnancy != null
            ? _PregnancyView(info: pregnancy)
            : const _CycleView(),
      ),
    );
  }
}

class _CycleView extends ConsumerWidget {
  const _CycleView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.cycleColors;
    final engine = ref.watch(cycleEngineProvider);
    final periods = ref.watch(periodsProvider);
    final stats = ref.watch(cycleStatsProvider);
    final predictions = ref.watch(predictionsProvider);

    final today = DateTime.now();
    final cycleDay = engine.cycleDay(today, periods);
    final phase = engine.phaseOn(today, periods);
    final daysToNext = engine.daysUntilNextPeriod(today, periods);

    final next = predictions.isNotEmpty ? predictions.first : null;

    final (phaseColor, headline, subline) = switch (phase) {
      CyclePhase.menstrual => (
          theme.colorScheme.primary,
          'Period',
          'Take it easy today'
        ),
      CyclePhase.ovulation => (
          colors.ovulation,
          'Ovulation',
          'High chance of pregnancy'
        ),
      CyclePhase.fertile => (
          colors.fertile,
          'Fertile window',
          'High chance of pregnancy'
        ),
      CyclePhase.luteal => (
          colors.lavender,
          'Luteal phase',
          daysToNext != null && daysToNext >= 0
              ? 'Period in $daysToNext days'
              : 'Log your period if it started'
        ),
      CyclePhase.follicular => (
          theme.colorScheme.primary,
          'Follicular phase',
          daysToNext != null && daysToNext >= 0
              ? 'Period in $daysToNext days'
              : 'Log your period to start predictions'
        ),
    };

    final progress = cycleDay != null
        ? (cycleDay / stats.averageCycleLength).clamp(0.0, 1.0)
        : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  DateFormat('EEEE, MMMM d').format(today),
                  style: theme.textTheme.bodyMedium!
                      .copyWith(color: colors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  cycleDay != null ? 'Cycle Day $cycleDay' : 'CycleTrack',
                  style: theme.textTheme.headlineMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 260,
              height: 260,
              child: CustomPaint(
                painter: _RingPainter(
                  progress: progress,
                  trackColor: colors.soft,
                  arcColor: phaseColor,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(headline,
                          style: theme.textTheme.titleMedium!
                              .copyWith(color: phaseColor)),
                      Text(
                        cycleDay != null ? 'Day $cycleDay' : '—',
                        style: theme.textTheme.displayLarge,
                      ),
                      Text(
                        subline,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall,
                      ),
                      if (stats.isIrregular) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Irregular cycles — lower confidence',
                          style: theme.textTheme.labelSmall!
                              .copyWith(color: theme.colorScheme.error),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => showDayLogSheet(context, DateTime.now()),
            icon: const Icon(Icons.add),
            label: const Text('Log today'),
          ),
          const SizedBox(height: 16),
          if (next != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Coming up', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 12),
                    _UpcomingRow(
                      color: colors.fertile,
                      label: 'Fertile window',
                      value:
                          '${DateFormat.MMMd().format(next.fertileStart)} – ${DateFormat.MMMd().format(next.fertileEnd)}',
                    ),
                    const SizedBox(height: 10),
                    _UpcomingRow(
                      color: colors.ovulation,
                      label: 'Ovulation day',
                      value: DateFormat('EEE, MMM d').format(next.ovulation),
                    ),
                    const SizedBox(height: 10),
                    _UpcomingRow(
                      color: theme.colorScheme.primary,
                      label: 'Next period',
                      value: DateFormat('EEE, MMM d').format(next.periodStart),
                    ),
                  ],
                ),
              ),
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Log your period to unlock predictions for your fertile window, ovulation and next period.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  const _UpcomingRow(
      {required this.color, required this.label, required this.value});

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
        Text(
          value,
          style: theme.textTheme.bodyMedium!
              .copyWith(color: context.cycleColors.textSecondary),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.arcColor,
  });

  final double progress;
  final Color trackColor;
  final Color arcColor;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 18.0;
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor;
    canvas.drawCircle(center, radius, track);

    if (progress > 0) {
      final arc = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = arcColor;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        arc,
      );

      // End dot
      final angle = -math.pi / 2 + 2 * math.pi * progress;
      final dotCenter = center +
          Offset(radius * math.cos(angle), radius * math.sin(angle));
      canvas.drawCircle(
          dotCenter, strokeWidth / 2 + 3, Paint()..color = arcColor);
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.arcColor != arcColor ||
      oldDelegate.trackColor != trackColor;
}

class _PregnancyView extends ConsumerWidget {
  const _PregnancyView({required this.info});

  final PregnancyInfo info;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.cycleColors;
    final progress = (info.week / 40).clamp(0.0, 1.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  DateFormat('EEEE, MMMM d').format(DateTime.now()),
                  style: theme.textTheme.bodyMedium!
                      .copyWith(color: colors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text('Pregnancy', style: theme.textTheme.headlineMedium),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 260,
              height: 260,
              child: CustomPaint(
                painter: _RingPainter(
                  progress: progress,
                  trackColor: colors.soft,
                  arcColor: colors.lavender,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Trimester ${info.trimester}',
                          style: theme.textTheme.titleMedium!
                              .copyWith(color: colors.lavender)),
                      Text('Week ${info.week}',
                          style: theme.textTheme.displayLarge),
                      Text(
                        'Day ${info.dayOfWeek} of this week',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('This week', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(info.milestone, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _UpcomingRow(
                color: colors.lavender,
                label: 'Estimated due date',
                value: DateFormat('EEE, MMM d, y').format(info.dueDate),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
