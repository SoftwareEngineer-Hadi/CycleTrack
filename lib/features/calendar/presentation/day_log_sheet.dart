import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/db/database.dart';
import '../../../core/models.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';

Future<void> showDayLogSheet(BuildContext context, DateTime day) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => DayLogSheet(day: DateTime(day.year, day.month, day.day)),
  );
}

class DayLogSheet extends ConsumerStatefulWidget {
  const DayLogSheet({super.key, required this.day});

  final DateTime day;

  @override
  ConsumerState<DayLogSheet> createState() => _DayLogSheetState();
}

class _DayLogSheetState extends ConsumerState<DayLogSheet> {
  bool _loaded = false;

  FlowLevel? _flow;
  bool _intercourse = false;
  bool? _protected;
  Libido? _libido;
  final Set<String> _symptoms = {};
  final Set<String> _moods = {};
  CervicalMucus? _mucus;
  bool _pillTaken = false;
  final _weightController = TextEditingController();
  final _bbtController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final log = await ref.read(databaseProvider).getLog(widget.day);
    if (log != null) {
      _flow = log.flow != null ? FlowLevel.values[log.flow!] : null;
      _intercourse = log.intercourse;
      _protected = log.protectedSex;
      _libido = log.libido != null ? Libido.values[log.libido!] : null;
      _symptoms.addAll(log.symptoms.split(',').where((s) => s.isNotEmpty));
      _moods.addAll(log.moods.split(',').where((s) => s.isNotEmpty));
      _mucus = log.cervicalMucus != null
          ? CervicalMucus.values[log.cervicalMucus!]
          : null;
      _pillTaken = log.pillTaken;
      if (log.weightKg != null) {
        _weightController.text = log.weightKg!.toStringAsFixed(1);
      }
      if (log.bbtCelsius != null) {
        _bbtController.text = log.bbtCelsius!.toStringAsFixed(2);
      }
      _notesController.text = log.notes ?? '';
    }
    if (mounted) setState(() => _loaded = true);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _bbtController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final db = ref.read(databaseProvider);
    await db.upsertLog(DayLogsCompanion.insert(
      date: widget.day,
      flow: Value(_flow?.index),
      intercourse: Value(_intercourse),
      protectedSex: Value(_intercourse ? _protected : null),
      libido: Value(_libido?.index),
      symptoms: Value(_symptoms.join(',')),
      moods: Value(_moods.join(',')),
      weightKg: Value(double.tryParse(
          _weightController.text.replaceAll(',', '.'))),
      bbtCelsius: Value(double.tryParse(
          _bbtController.text.replaceAll(',', '.'))),
      cervicalMucus: Value(_mucus?.index),
      pillTaken: Value(_pillTaken),
      notes: Value(
          _notesController.text.isEmpty ? null : _notesController.text),
    ));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.cycleColors;
    final engine = ref.watch(cycleEngineProvider);
    final periods = ref.watch(periodsProvider);
    final cycleDay = engine.cycleDay(widget.day, periods);
    final phase = engine.phaseOn(widget.day, periods);

    if (!_loaded) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              DateFormat('EEEE, MMMM d').format(widget.day),
              style: theme.textTheme.titleLarge,
            ),
            if (cycleDay != null)
              Text(
                'Cycle Day $cycleDay \u00b7 ${phase.label}',
                style: theme.textTheme.bodySmall,
              ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                children: [
                  _SectionLabel('Menstrual flow'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final f in FlowLevel.values)
                        FilterChip(
                          label: Text(f.label),
                          selected: _flow == f,
                          onSelected: (sel) =>
                              setState(() => _flow = sel ? f : null),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionLabel('Symptoms'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final s in Symptoms.all)
                        FilterChip(
                          label: Text(s),
                          selected: _symptoms.contains(s),
                          onSelected: (sel) => setState(() =>
                              sel ? _symptoms.add(s) : _symptoms.remove(s)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionLabel('Mood'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final m in Moods.all)
                        FilterChip(
                          label: Text(m),
                          selected: _moods.contains(m),
                          onSelected: (sel) => setState(
                              () => sel ? _moods.add(m) : _moods.remove(m)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionLabel('Intimacy'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Intercourse'),
                        selected: _intercourse,
                        onSelected: (sel) => setState(() {
                          _intercourse = sel;
                          if (!sel) _protected = null;
                        }),
                      ),
                      if (_intercourse) ...[
                        FilterChip(
                          label: const Text('Protected'),
                          selected: _protected == true,
                          onSelected: (sel) =>
                              setState(() => _protected = sel ? true : null),
                        ),
                        FilterChip(
                          label: const Text('Unprotected'),
                          selected: _protected == false,
                          onSelected: (sel) =>
                              setState(() => _protected = sel ? false : null),
                        ),
                      ],
                      for (final l in Libido.values)
                        FilterChip(
                          label: Text(l.label),
                          selected: _libido == l,
                          onSelected: (sel) =>
                              setState(() => _libido = sel ? l : null),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionLabel('Biometrics'),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _weightController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Weight',
                            suffixText: 'kg',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _bbtController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'BBT',
                            suffixText: '\u00b0C',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final m in CervicalMucus.values)
                        FilterChip(
                          label: Text(m.label),
                          selected: _mucus == m,
                          onSelected: (sel) =>
                              setState(() => _mucus = sel ? m : null),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionLabel('Pill'),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Pill taken today',
                        style: theme.textTheme.bodyMedium),
                    value: _pillTaken,
                    onChanged: (v) => setState(() => _pillTaken = v),
                  ),
                  const SizedBox(height: 8),
                  _SectionLabel('Notes'),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Anything else about today\u2026',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _save,
                    child: const Text('Save log'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
