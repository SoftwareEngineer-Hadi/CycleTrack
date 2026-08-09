import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/models.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/providers.dart';
import '../../lock/app_lock.dart';
import '../../sync/sync_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsMapProvider);
    final pregnancyMode = settings[SettingsKeys.pregnancyMode] == 'true';
    final pinSet = (settings[SettingsKeys.pinHash] ?? '').isNotEmpty;
    final biometric =
        settings[SettingsKeys.biometricEnabled] == 'true';
    final themeMode = settings[SettingsKeys.themeMode] ?? 'system';

    Future<void> setBool(String key, bool value) async {
      await ref.read(databaseProvider).setSetting(key, value.toString());
      await _rescheduleNotifications(ref);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _SectionHeader('Privacy'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('App lock'),
                  subtitle: Text(pinSet ? 'PIN enabled' : 'Off'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _configurePin(context, ref, pinSet),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.fingerprint),
                  title: const Text('Biometric unlock'),
                  value: biometric && pinSet,
                  onChanged: !pinSet
                      ? null
                      : (v) => setBool(SettingsKeys.biometricEnabled, v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionHeader('Cycle'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.child_friendly_outlined),
                  title: const Text('Pregnancy mode'),
                  subtitle: const Text(
                      'Pauses period predictions and shows pregnancy week'),
                  value: pregnancyMode,
                  onChanged: (v) async {
                    final db = ref.read(databaseProvider);
                    if (v) {
                      final lmp = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now()
                            .subtract(const Duration(days: 60)),
                        firstDate: DateTime.now()
                            .subtract(const Duration(days: 300)),
                        lastDate: DateTime.now(),
                        helpText: 'First day of last period',
                      );
                      if (lmp == null) return;
                      await db.setSetting(SettingsKeys.pregnancyMode, 'true');
                      await db.setSetting(
                          SettingsKeys.pregnancyLmp, lmp.toIso8601String());
                    } else {
                      await db.setSetting(SettingsKeys.pregnancyMode, 'false');
                      await db.setSetting(SettingsKeys.pregnancyLmp, null);
                    }
                    if (!context.mounted) return;
                    await _rescheduleNotifications(ref);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.timeline),
                  title: const Text('Cycle length override'),
                  subtitle: Text(
                      '${settings[SettingsKeys.cycleLengthOverride] ?? '28'} days'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _editIntSetting(
                    context,
                    ref,
                    SettingsKeys.cycleLengthOverride,
                    title: 'Cycle length',
                    min: 15,
                    max: 60,
                    current: int.tryParse(
                            settings[SettingsKeys.cycleLengthOverride] ??
                                '') ??
                        28,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.water_drop_outlined),
                  title: const Text('Period length override'),
                  subtitle: Text(
                      '${settings[SettingsKeys.periodLengthOverride] ?? '5'} days'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _editIntSetting(
                    context,
                    ref,
                    SettingsKeys.periodLengthOverride,
                    title: 'Period length',
                    min: 1,
                    max: 10,
                    current: int.tryParse(
                            settings[SettingsKeys.periodLengthOverride] ??
                                '') ??
                        5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionHeader('Notifications'),
          Card(
            child: Column(
              children: [
                for (final entry in [
                  (
                    SettingsKeys.notifyPeriod,
                    'Period reminders',
                    Icons.event_outlined
                  ),
                  (
                    SettingsKeys.notifyFertile,
                    'Fertile window',
                    Icons.eco_outlined
                  ),
                  (
                    SettingsKeys.notifyOvulation,
                    'Ovulation day',
                    Icons.star_outline
                  ),
                  (
                    SettingsKeys.notifyLatePeriod,
                    'Late period alert',
                    Icons.schedule
                  ),
                ])
                  SwitchListTile(
                    secondary: Icon(entry.$3),
                    title: Text(entry.$2),
                    value: settings[entry.$1] != 'false',
                    onChanged: (v) => setBool(entry.$1, v),
                  ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.medication_outlined),
                  title: const Text('Pill reminders'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/pills'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionHeader('Data'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cloud_outlined),
                  title: const Text('Backup & restore'),
                  subtitle: Text(
                    settings[SettingsKeys.lastBackupAt] != null
                        ? 'Last backup ${DateFormat.yMMMd().add_jm().format(DateTime.parse(settings[SettingsKeys.lastBackupAt]!))}'
                        : 'Optional encrypted cloud sync',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/backup'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.file_download_outlined),
                  title: const Text('Export CSV'),
                  subtitle: const Text('Share logs for doctor visits'),
                  onTap: () => _exportCsv(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.delete_forever_outlined,
                      color: theme.colorScheme.error),
                  title: Text('Delete everything',
                      style: TextStyle(color: theme.colorScheme.error)),
                  subtitle: const Text(
                      'Wipe local data and cloud backup'),
                  onTap: () => _deleteEverything(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionHeader('Appearance'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'system', label: Text('System')),
                  ButtonSegment(value: 'light', label: Text('Light')),
                  ButtonSegment(value: 'dark', label: Text('Dark')),
                ],
                selected: {themeMode},
                onSelectionChanged: (selection) {
                  ref
                      .read(databaseProvider)
                      .setSetting(SettingsKeys.themeMode, selection.first);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About & privacy'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/about'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _configurePin(
      BuildContext context, WidgetRef ref, bool pinSet) async {
    final db = ref.read(databaseProvider);
    if (pinSet) {
      final remove = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Remove app lock?'),
          content: const Text('Anyone with your phone can open CycleTrack.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Remove')),
          ],
        ),
      );
      if (remove == true) {
        await db.setSetting(SettingsKeys.pinHash, null);
        await db.setSetting(SettingsKeys.biometricEnabled, 'false');
        ref.read(appLockProvider.notifier).state = false;
      }
      return;
    }

    final pin = await _promptPin(context, title: 'Create a 4–6 digit PIN');
    if (pin == null || !context.mounted) return;
    final confirm =
        await _promptPin(context, title: 'Confirm PIN');
    if (confirm == null || !context.mounted) return;
    if (pin != confirm) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PINs did not match')),
        );
      }
      return;
    }
    await db.setSetting(SettingsKeys.pinHash, hashPin(pin));
  }

  Future<String?> _promptPin(BuildContext context,
      {required String title}) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 6,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'PIN'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final v = controller.text.trim();
              if (v.length >= 4 && v.length <= 6) Navigator.pop(ctx, v);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _editIntSetting(
    BuildContext context,
    WidgetRef ref,
    String key, {
    required String title,
    required int min,
    required int max,
    required int current,
  }) async {
    var value = current;
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(title),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: value > min ? () => setState(() => value--) : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text('$value days',
                  style: Theme.of(ctx).textTheme.titleLarge),
              IconButton(
                onPressed: value < max ? () => setState(() => value++) : null,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, value),
                child: const Text('Save')),
          ],
        ),
      ),
    );
    if (result != null) {
      await ref.read(databaseProvider).setSetting(key, result.toString());
      await _rescheduleNotifications(ref);
    }
  }

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    final logs = await ref.read(databaseProvider).getAllLogs();
    final buf = StringBuffer(
        'date,flow,intercourse,protected,libido,symptoms,moods,weight_kg,bbt_c,mucus,pill,notes\n');
    for (final l in logs) {
      buf.writeln([
        DateFormat('yyyy-MM-dd').format(l.date),
        l.flow ?? '',
        l.intercourse,
        l.protectedSex ?? '',
        l.libido ?? '',
        '"${l.symptoms}"',
        '"${l.moods}"',
        l.weightKg ?? '',
        l.bbtCelsius ?? '',
        l.cervicalMucus ?? '',
        l.pillTaken,
        '"${(l.notes ?? '').replaceAll('"', '""')}"',
      ].join(','));
    }
    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/cycletrack_export_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv');
    await file.writeAsString(buf.toString());
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: 'CycleTrack export'),
    );
  }

  Future<void> _deleteEverything(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete everything?'),
        content: const Text(
          'This permanently wipes your local database, app lock, '
          'notifications, and any encrypted cloud backup. This cannot be undone.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    await NotificationService.instance.cancelAll();
    try {
      await SyncService(ref.read(databaseProvider)).deleteCloudBackup();
    } on SyncException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
      return;
    }
    await ref.read(databaseProvider).wipeAllData();
    ref.read(appLockProvider.notifier).state = false;
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All data deleted')),
      );
    }
  }
}

Future<void> _rescheduleNotifications(WidgetRef ref) async {
  final settings = ref.read(settingsMapProvider);
  final predictions = ref.read(predictionsProvider);
  await NotificationService.instance.scheduleCycleNotifications(
    predictions: predictions,
    periodEnabled: settings[SettingsKeys.notifyPeriod] != 'false',
    fertileEnabled: settings[SettingsKeys.notifyFertile] != 'false',
    ovulationEnabled: settings[SettingsKeys.notifyOvulation] != 'false',
    lateEnabled: settings[SettingsKeys.notifyLatePeriod] != 'false',
    pregnancyMode: settings[SettingsKeys.pregnancyMode] == 'true',
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
