import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/db/database.dart';
import '../../../core/models.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  TrackingGoal _goal = TrackingGoal.trackCycle;
  DateTime? _lastPeriodStart;
  int _cycleLength = 28;
  int _periodLength = 5;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final db = ref.read(databaseProvider);
    await db.setSetting(SettingsKeys.goal, _goal.name);
    await db.setSetting(
        SettingsKeys.cycleLengthOverride, _cycleLength.toString());
    await db.setSetting(
        SettingsKeys.periodLengthOverride, _periodLength.toString());
    for (final key in [
      SettingsKeys.notifyPeriod,
      SettingsKeys.notifyFertile,
      SettingsKeys.notifyOvulation,
      SettingsKeys.notifyLatePeriod,
    ]) {
      await db.setSetting(key, 'true');
    }

    final lastStart = _lastPeriodStart;
    if (lastStart != null) {
      if (_goal == TrackingGoal.pregnancy) {
        await db.setSetting(SettingsKeys.pregnancyMode, 'true');
        await db.setSetting(
            SettingsKeys.pregnancyLmp, lastStart.toIso8601String());
      } else {
        // Seed the engine with the last period as logged flow days.
        for (var i = 0; i < _periodLength; i++) {
          final day = lastStart.add(Duration(days: i));
          await db.upsertLog(DayLogsCompanion.insert(
            date: DateTime(day.year, day.month, day.day),
            flow: Value(FlowLevel.medium.index),
          ));
        }
      }
    }
    await db.setSetting(SettingsKeys.onboardingDone, 'true');
  }

  void _next() {
    if (_page < 2) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _GoalStep(
                    goal: _goal,
                    onChanged: (g) => setState(() => _goal = g),
                  ),
                  _LastPeriodStep(
                    selected: _lastPeriodStart,
                    isPregnancy: _goal == TrackingGoal.pregnancy,
                    onChanged: (d) => setState(() => _lastPeriodStart = d),
                  ),
                  _LengthsStep(
                    cycleLength: _cycleLength,
                    periodLength: _periodLength,
                    onCycleChanged: (v) => setState(() => _cycleLength = v),
                    onPeriodChanged: (v) => setState(() => _periodLength = v),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _page ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _page
                              ? theme.colorScheme.primary
                              : context.cycleColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed:
                        _page == 1 && _lastPeriodStart == null ? null : _next,
                    child: Text(_page == 2 ? 'Get started' : 'Continue'),
                  ),
                  if (_page == 1) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        setState(() => _lastPeriodStart = null);
                        _pageController.nextPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut);
                      },
                      child: const Text('I don\u2019t remember'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalStep extends StatelessWidget {
  const _GoalStep({required this.goal, required this.onChanged});

  final TrackingGoal goal;
  final ValueChanged<TrackingGoal> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text('Welcome to CycleTrack',
              style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Private, offline-first cycle tracking.\nNo account needed \u2014 your data stays on this device.',
            style: theme.textTheme.bodyMedium!
                .copyWith(color: context.cycleColors.textSecondary),
          ),
          const SizedBox(height: 32),
          Text('What brings you here?', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          for (final g in TrackingGoal.values) ...[
            _GoalCard(
              goal: g,
              selected: g == goal,
              onTap: () => onChanged(g),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard(
      {required this.goal, required this.selected, required this.onTap});

  final TrackingGoal goal;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.cycleColors;
    final icon = switch (goal) {
      TrackingGoal.trackCycle => Icons.water_drop_outlined,
      TrackingGoal.conceive => Icons.favorite_outline,
      TrackingGoal.pregnancy => Icons.child_friendly_outlined,
    };
    return Material(
      color: selected ? colors.soft : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? theme.colorScheme.primary : colors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon,
                  color: selected
                      ? theme.colorScheme.primary
                      : colors.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(goal.label, style: theme.textTheme.titleMedium),
              ),
              if (selected)
                Icon(Icons.check_circle,
                    color: theme.colorScheme.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _LastPeriodStep extends StatelessWidget {
  const _LastPeriodStep({
    required this.selected,
    required this.isPregnancy,
    required this.onChanged,
  });

  final DateTime? selected;
  final bool isPregnancy;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            isPregnancy
                ? 'First day of your last period?'
                : 'When did your last period start?',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            isPregnancy
                ? 'We use this to estimate your due date and pregnancy week.'
                : 'This is the anchor for all predictions. You can change it anytime.',
            style: theme.textTheme.bodyMedium!
                .copyWith(color: context.cycleColors.textSecondary),
          ),
          const SizedBox(height: 16),
          if (selected != null)
            Center(
              child: Chip(
                label: Text(DateFormat.yMMMMd().format(selected!)),
              ),
            ),
          Expanded(
            child: CalendarDatePicker(
              initialDate: selected ?? now,
              firstDate: now.subtract(const Duration(days: 300)),
              lastDate: now,
              onDateChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _LengthsStep extends StatelessWidget {
  const _LengthsStep({
    required this.cycleLength,
    required this.periodLength,
    required this.onCycleChanged,
    required this.onPeriodChanged,
  });

  final int cycleLength;
  final int periodLength;
  final ValueChanged<int> onCycleChanged;
  final ValueChanged<int> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text('Your usual cycle', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Rough numbers are fine \u2014 predictions adapt as you log real cycles.',
            style: theme.textTheme.bodyMedium!
                .copyWith(color: context.cycleColors.textSecondary),
          ),
          const SizedBox(height: 32),
          _Stepper(
            label: 'Cycle length',
            unit: 'days',
            value: cycleLength,
            min: 15,
            max: 60,
            onChanged: onCycleChanged,
          ),
          const SizedBox(height: 20),
          _Stepper(
            label: 'Period length',
            unit: 'days',
            value: periodLength,
            min: 1,
            max: 10,
            onChanged: onPeriodChanged,
          ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.unit,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final String unit;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(child: Text(label, style: theme.textTheme.titleMedium)),
            IconButton(
              onPressed: value > min ? () => onChanged(value - 1) : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            SizedBox(
              width: 72,
              child: Text(
                '$value $unit',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
            ),
            IconButton(
              onPressed: value < max ? () => onChanged(value + 1) : null,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ),
    );
  }
}
