import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.cycleColors;
    final pregnancy = ref.watch(pregnancyInfoProvider);
    final engine = ref.watch(cycleEngineProvider);
    final periods = ref.watch(periodsProvider);
    final stats = ref.watch(cycleStatsProvider);
    final logs = ref.watch(dayLogsProvider).value ?? const [];
    final today = DateTime.now();
    final phase = engine.phaseOn(today, periods);
    final cycleDay = engine.cycleDay(today, periods);

    if (pregnancy != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Insights')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _PhaseHero(
              title: 'Week ${pregnancy.week}',
              subtitle: 'Trimester ${pregnancy.trimester}',
              tip: pregnancy.milestone,
              color: colors.lavender,
            ),
            const SizedBox(height: 16),
            ..._pregnancyTips(pregnancy.trimester).map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TipCard(title: t.$1, body: t.$2, icon: t.$3),
              ),
            ),
          ],
        ),
      );
    }

    final tip = _phaseTip(phase);
    final symptomSummary = _symptomFrequency(logs);

    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _PhaseHero(
            title: phase.label,
            subtitle: cycleDay != null
                ? 'Cycle day $cycleDay · avg ${stats.averageCycleLength} days'
                : 'Log a period to personalize insights',
            tip: tip.$2,
            color: tip.$1,
          ),
          if (stats.isIrregular) ...[
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: Icon(Icons.info_outline,
                    color: theme.colorScheme.error),
                title: const Text('Irregular cycles detected'),
                subtitle: Text(
                  'Variation ±${stats.standardDeviation.toStringAsFixed(1)} days. '
                  'You can pin custom cycle length in Settings.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text('Tips for this phase', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          for (final t in tip.$3)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TipCard(title: t.$1, body: t.$2, icon: t.$3),
            ),
          if (symptomSummary.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Your frequent symptoms', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    for (final entry in symptomSummary.take(5))
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text(entry.key,
                                    style: theme.textTheme.bodyMedium)),
                            Text(
                              '${entry.value}×',
                              style: theme.textTheme.bodyMedium!.copyWith(
                                  color: colors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Returns (accent, tip headline, tip cards).
  (Color, String, List<(String, String, IconData)>) _phaseTip(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return (
          AppColors.brandPrimary,
          'Rest, warmth, and gentle movement help most during your period.',
          [
            (
              'Comfort first',
              'A heating pad and magnesium-rich foods can ease cramps.',
              Icons.favorite_outline
            ),
            (
              'Hydrate',
              'Extra water and herbal tea reduce bloating.',
              Icons.water_drop_outlined
            ),
            (
              'Light movement',
              'A short walk or stretch can improve mood and flow.',
              Icons.directions_walk
            ),
          ],
        );
      case CyclePhase.follicular:
        return (
          AppColors.brandPrimary,
          'Energy often rises after your period — a good window for new routines.',
          [
            (
              'Build habits',
              'Strength training and creative work often feel easier now.',
              Icons.bolt_outlined
            ),
            (
              'Fuel well',
              'Protein and iron-rich meals support recovery from your period.',
              Icons.restaurant_outlined
            ),
          ],
        );
      case CyclePhase.fertile:
      case CyclePhase.ovulation:
        return (
          AppColors.fertile,
          'Fertility is peaking. Log intimacy and cervical mucus for clearer patterns.',
          [
            (
              'Peak fertility',
              'Sperm can survive up to 5 days — fertile days matter before ovulation too.',
              Icons.favorite_outline
            ),
            (
              'Track signs',
              'Egg-white mucus and a BBT rise help confirm ovulation.',
              Icons.thermostat_outlined
            ),
          ],
        );
      case CyclePhase.luteal:
        return (
          AppColors.lavender,
          'Progesterone rises — prioritize sleep, steady meals, and stress care.',
          [
            (
              'Steady energy',
              'Complex carbs and regular meals can ease PMS dips.',
              Icons.restaurant_outlined
            ),
            (
              'Sleep',
              'Wind-down routines help when sleep gets lighter pre-period.',
              Icons.bedtime_outlined
            ),
            (
              'Mood check-in',
              'Log moods now so patterns become clearer over cycles.',
              Icons.mood_outlined
            ),
          ],
        );
    }
  }

  List<(String, String, IconData)> _pregnancyTips(int trimester) {
    return switch (trimester) {
      1 => [
          (
            'Prenatal care',
            'Start prenatal vitamins with folic acid if you haven\'t already.',
            Icons.medical_services_outlined
          ),
          (
            'Rest',
            'Fatigue is common — short naps and earlier bedtimes help.',
            Icons.bedtime_outlined
          ),
        ],
      2 => [
          (
            'Movement',
            'Most people feel more energetic — gentle exercise is often encouraged.',
            Icons.directions_walk
          ),
          (
            'Nutrition',
            'Calcium and protein needs rise as baby grows.',
            Icons.restaurant_outlined
          ),
        ],
      _ => [
          (
            'Prepare',
            'Pack a hospital bag and discuss birth preferences with your care team.',
            Icons.luggage_outlined
          ),
          (
            'Rest & monitor',
            'Track baby movements and rest when you can.',
            Icons.child_friendly_outlined
          ),
        ],
    };
  }

  List<MapEntry<String, int>> _symptomFrequency(List logs) {
    final counts = <String, int>{};
    for (final log in logs) {
      final symptoms = (log.symptoms as String)
          .split(',')
          .where((s) => s.isNotEmpty);
      for (final s in symptoms) {
        counts[s] = (counts[s] ?? 0) + 1;
      }
    }
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }
}

class _PhaseHero extends StatelessWidget {
  const _PhaseHero({
    required this.title,
    required this.subtitle,
    required this.tip,
    required this.color,
  });

  final String title;
  final String subtitle;
  final String tip;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: theme.textTheme.headlineMedium!.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(subtitle, style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          Text(tip, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard(
      {required this.title, required this.body, required this.icon});

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title, style: theme.textTheme.titleMedium),
        subtitle: Text(body, style: theme.textTheme.bodySmall),
      ),
    );
  }
}
