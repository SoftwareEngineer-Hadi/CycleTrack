import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/db/database.dart';
import '../../../core/models.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import 'day_log_sheet.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.cycleColors;
    final logs = ref.watch(dayLogsMapProvider);
    final predictions = ref.watch(predictionsProvider);
    final pregnancyMode = ref.watch(pregnancyModeProvider);

    // Build fast lookup sets for predicted markers.
    final predictedPeriod = <DateTime>{};
    final fertileDays = <DateTime>{};
    final ovulationDays = <DateTime>{};
    if (!pregnancyMode) {
      for (final p in predictions) {
        for (var d = p.periodStart;
            !d.isAfter(p.periodEnd);
            d = d.add(const Duration(days: 1))) {
          predictedPeriod.add(_day(d));
        }
        for (var d = p.fertileStart;
            !d.isAfter(p.fertileEnd);
            d = d.add(const Duration(days: 1))) {
          fertileDays.add(_day(d));
        }
        ovulationDays.add(_day(p.ovulation));
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: SafeArea(
        child: Column(
          children: [
            TableCalendar<DayLog>(
              firstDay: DateTime.now().subtract(const Duration(days: 730)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: theme.textTheme.titleLarge!,
                leftChevronIcon:
                    Icon(Icons.chevron_left, color: colors.textSecondary),
                rightChevronIcon:
                    Icon(Icons.chevron_right, color: colors.textSecondary),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: theme.textTheme.labelSmall!,
                weekendStyle: theme.textTheme.labelSmall!,
              ),
              onPageChanged: (day) => _focusedDay = day,
              selectedDayPredicate: (_) => false,
              onDaySelected: (selected, focused) {
                _focusedDay = focused;
                showDayLogSheet(context, selected);
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) => _DayCell(
                  day: day,
                  log: logs[_day(day)],
                  predictedPeriod: predictedPeriod.contains(_day(day)),
                  fertile: fertileDays.contains(_day(day)),
                  ovulation: ovulationDays.contains(_day(day)),
                  isToday: false,
                  outside: false,
                ),
                todayBuilder: (context, day, focusedDay) => _DayCell(
                  day: day,
                  log: logs[_day(day)],
                  predictedPeriod: predictedPeriod.contains(_day(day)),
                  fertile: fertileDays.contains(_day(day)),
                  ovulation: ovulationDays.contains(_day(day)),
                  isToday: true,
                  outside: false,
                ),
                outsideBuilder: (context, day, focusedDay) => _DayCell(
                  day: day,
                  log: null,
                  predictedPeriod: false,
                  fertile: false,
                  ovulation: false,
                  isToday: false,
                  outside: true,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: _Legend(pregnancyMode: pregnancyMode),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.log,
    required this.predictedPeriod,
    required this.fertile,
    required this.ovulation,
    required this.isToday,
    required this.outside,
  });

  final DateTime day;
  final DayLog? log;
  final bool predictedPeriod;
  final bool fertile;
  final bool ovulation;
  final bool isToday;
  final bool outside;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.cycleColors;

    Color? fill;
    Color textColor = theme.colorScheme.onSurface;
    BoxBorder? border;

    final flow = log?.flow;
    if (flow != null) {
      // Flow level shades the marker.
      final t = switch (FlowLevel.values[flow]) {
        FlowLevel.spotting => 0.35,
        FlowLevel.light => 0.6,
        FlowLevel.medium => 0.8,
        FlowLevel.heavy => 1.0,
      };
      fill = Color.lerp(colors.soft, theme.colorScheme.primary, t);
      textColor = t > 0.5 ? Colors.white : theme.colorScheme.onSurface;
    } else if (ovulation) {
      fill = colors.ovulation;
      textColor = Colors.white;
    } else if (fertile) {
      fill = colors.fertile.withValues(alpha: 0.18);
    } else if (predictedPeriod) {
      border = Border.all(color: theme.colorScheme.primary, width: 1.5);
    }

    if (isToday) {
      border = Border.all(color: theme.colorScheme.primary, width: 2);
    }
    if (outside) {
      textColor = colors.textSecondary.withValues(alpha: 0.5);
    }

    final hasDetails = log != null &&
        (log!.symptoms.isNotEmpty ||
            log!.moods.isNotEmpty ||
            log!.bbtCelsius != null ||
            log!.weightKg != null ||
            log!.intercourse);

    return Center(
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: fill,
          border: border,
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: theme.textTheme.bodyMedium!.copyWith(
                color: textColor,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (hasDetails)
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: flow != null ? Colors.white70 : colors.lavender,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.pregnancyMode});

  final bool pregnancyMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.cycleColors;

    Widget item(Widget marker, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            marker,
            const SizedBox(width: 8),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        );

    Widget circle(Color color, {bool outlineOnly = false}) => Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: outlineOnly ? null : color,
            border: outlineOnly ? Border.all(color: color, width: 1.5) : null,
            shape: BoxShape.circle,
          ),
        );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Legend', style: theme.textTheme.titleMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 20,
              runSpacing: 10,
              children: [
                item(circle(theme.colorScheme.primary), 'Period (darker = heavier)'),
                if (!pregnancyMode) ...[
                  item(circle(theme.colorScheme.primary, outlineOnly: true),
                      'Predicted period'),
                  item(circle(colors.fertile.withValues(alpha: 0.4)),
                      'Fertile window'),
                  item(circle(colors.ovulation), 'Ovulation'),
                ],
                item(circle(colors.lavender), 'Symptoms logged'),
              ],
            ),
            if (pregnancyMode) ...[
              const SizedBox(height: 10),
              Text(
                'Pregnancy mode is on — period predictions are paused.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
