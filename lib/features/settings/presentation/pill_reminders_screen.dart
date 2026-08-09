import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/providers.dart';

class PillRemindersScreen extends ConsumerWidget {
  const PillRemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final remindersAsync =
        ref.watch(_pillRemindersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pill reminders')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrEdit(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add reminder'),
      ),
      body: remindersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (reminders) {
          if (reminders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No pill reminders yet.\nTap Add reminder to schedule a daily notification.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
            itemCount: reminders.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final r = reminders[i];
              final time =
                  TimeOfDay(hour: r.hour, minute: r.minute).format(context);
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.medication_outlined),
                  title: Text(r.name),
                  subtitle: Text(time),
                  trailing: Switch(
                    value: r.enabled,
                    onChanged: (v) async {
                      await ref
                          .read(databaseProvider)
                          .updatePillReminder(r.copyWith(enabled: v));
                      await _resync(ref);
                    },
                  ),
                  onTap: () => _addOrEdit(context, ref, existing: r),
                  onLongPress: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete reminder?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel')),
                          FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete')),
                        ],
                      ),
                    );
                    if (ok == true) {
                      await ref
                          .read(databaseProvider)
                          .deletePillReminder(r.id);
                      await _resync(ref);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _addOrEdit(BuildContext context, WidgetRef ref,
      {PillReminder? existing}) async {
    final nameController =
        TextEditingController(text: existing?.name ?? 'Birth control');
    var time = TimeOfDay(
      hour: existing?.hour ?? 9,
      minute: existing?.minute ?? 0,
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(existing == null ? 'Add reminder' : 'Edit reminder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Time'),
                trailing: Text(time.format(ctx)),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: ctx,
                    initialTime: time,
                  );
                  if (picked != null) setState(() => time = picked);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Save')),
          ],
        ),
      ),
    );

    if (saved != true) return;
    final db = ref.read(databaseProvider);
    final name = nameController.text.trim().isEmpty
        ? 'Pill'
        : nameController.text.trim();
    if (existing == null) {
      await db.addPillReminder(PillRemindersCompanion.insert(
        name: name,
        hour: time.hour,
        minute: time.minute,
      ));
    } else {
      await db.updatePillReminder(existing.copyWith(
        name: name,
        hour: time.hour,
        minute: time.minute,
      ));
    }
    await NotificationService.instance.requestPermissions();
    await _resync(ref);
  }

  Future<void> _resync(WidgetRef ref) async {
    final pills = await ref.read(databaseProvider).getPillReminders();
    await NotificationService.instance.schedulePillReminders(pills);
  }
}

final _pillRemindersProvider = StreamProvider<List<PillReminder>>(
  (ref) => ref.watch(databaseProvider).watchPillReminders(),
);
