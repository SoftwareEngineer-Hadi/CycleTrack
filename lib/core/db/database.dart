import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class DayLogs extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Normalized to midnight (local). Unique per day.
  DateTimeColumn get date => dateTime().unique()();

  /// Index into [FlowLevel], null when no flow logged.
  IntColumn get flow => integer().nullable()();
  BoolColumn get intercourse => boolean().withDefault(const Constant(false))();

  /// Null when [intercourse] is false.
  BoolColumn get protectedSex => boolean().nullable()();

  /// Index into [Libido].
  IntColumn get libido => integer().nullable()();

  /// Comma-separated entries from [Symptoms.all].
  TextColumn get symptoms => text().withDefault(const Constant(''))();

  /// Comma-separated entries from [Moods.all].
  TextColumn get moods => text().withDefault(const Constant(''))();
  RealColumn get weightKg => real().nullable()();
  RealColumn get bbtCelsius => real().nullable()();

  /// Index into [CervicalMucus].
  IntColumn get cervicalMucus => integer().nullable()();
  BoolColumn get pillTaken => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
}

class KeyValues extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

class PillReminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get hour => integer()();
  IntColumn get minute => integer()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
}

@DriftDatabase(tables: [DayLogs, KeyValues, PillReminders])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openEncryptedConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  // ----- Day logs -----

  Stream<List<DayLog>> watchAllLogs() =>
      (select(dayLogs)..orderBy([(t) => OrderingTerm.asc(t.date)])).watch();

  Future<List<DayLog>> getAllLogs() =>
      (select(dayLogs)..orderBy([(t) => OrderingTerm.asc(t.date)])).get();

  Future<DayLog?> getLog(DateTime day) => (select(dayLogs)
        ..where((t) => t.date.equals(_normalize(day))))
      .getSingleOrNull();

  Future<void> upsertLog(DayLogsCompanion entry) async {
    final date = _normalize(entry.date.value);
    await transaction(() async {
      await (delete(dayLogs)..where((t) => t.date.equals(date))).go();
      await into(dayLogs).insert(entry.copyWith(date: Value(date)));
    });
  }

  Future<void> deleteLog(DateTime day) =>
      (delete(dayLogs)..where((t) => t.date.equals(_normalize(day)))).go();

  static DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  // ----- Settings -----

  Future<String?> getSetting(String key) async {
    final row = await (select(keyValues)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Stream<String?> watchSetting(String key) =>
      (select(keyValues)..where((t) => t.key.equals(key)))
          .watchSingleOrNull()
          .map((row) => row?.value);

  Stream<Map<String, String>> watchAllSettings() => select(keyValues)
      .watch()
      .map((rows) => {for (final r in rows) r.key: r.value});

  Future<void> setSetting(String key, String? value) async {
    if (value == null) {
      await (delete(keyValues)..where((t) => t.key.equals(key))).go();
    } else {
      await into(keyValues)
          .insertOnConflictUpdate(KeyValue(key: key, value: value));
    }
  }

  // ----- Pill reminders -----

  Stream<List<PillReminder>> watchPillReminders() =>
      (select(pillReminders)..orderBy([(t) => OrderingTerm.asc(t.hour)]))
          .watch();

  Future<List<PillReminder>> getPillReminders() => select(pillReminders).get();

  Future<int> addPillReminder(PillRemindersCompanion entry) =>
      into(pillReminders).insert(entry);

  Future<void> updatePillReminder(PillReminder reminder) =>
      update(pillReminders).replace(reminder);

  Future<void> deletePillReminder(int id) =>
      (delete(pillReminders)..where((t) => t.id.equals(id))).go();

  // ----- Bulk (backup / wipe) -----

  /// Serializes the full database to a JSON map for encrypted backup.
  Future<Map<String, dynamic>> exportAsJson() async {
    final logs = await getAllLogs();
    final settings = await select(keyValues).get();
    final pills = await getPillReminders();
    return {
      'version': schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'dayLogs': logs.map((l) => l.toJson()).toList(),
      'settings': settings.map((s) => s.toJson()).toList(),
      'pillReminders': pills.map((r) => r.toJson()).toList(),
    };
  }

  /// Replaces all local data with the contents of a backup payload.
  Future<void> importFromJson(Map<String, dynamic> data) async {
    await transaction(() async {
      await delete(dayLogs).go();
      await delete(keyValues).go();
      await delete(pillReminders).go();
      for (final row in (data['dayLogs'] as List? ?? [])) {
        await into(dayLogs)
            .insert(DayLog.fromJson(row as Map<String, dynamic>));
      }
      for (final row in (data['settings'] as List? ?? [])) {
        await into(keyValues)
            .insert(KeyValue.fromJson(row as Map<String, dynamic>));
      }
      for (final row in (data['pillReminders'] as List? ?? [])) {
        await into(pillReminders)
            .insert(PillReminder.fromJson(row as Map<String, dynamic>));
      }
    });
  }

  /// Deletes every row in every table.
  Future<void> wipeAllData() async {
    await transaction(() async {
      await delete(dayLogs).go();
      await delete(keyValues).go();
      await delete(pillReminders).go();
    });
  }
}

const _dbKeyStorageKey = 'cycletrack_db_key';

/// Opens a SQLCipher-encrypted database. The 256-bit key is generated on
/// first launch and kept in the platform keychain/keystore.
///
/// SQLCipher itself is enabled via the `hooks.user_defines.sqlite3.source`
/// entry in pubspec.yaml.
LazyDatabase _openEncryptedConnection() {
  return LazyDatabase(() async {
    const storage = FlutterSecureStorage();
    var key = await storage.read(key: _dbKeyStorageKey);
    if (key == null) {
      final rng = Random.secure();
      key = base64UrlEncode(List.generate(32, (_) => rng.nextInt(256)));
      await storage.write(key: _dbKeyStorageKey, value: key);
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'cycletrack.db'));
    final dbKey = key;
    return NativeDatabase.createInBackground(
      file,
      setup: (db) {
        // Must be the first statement on a SQLCipher connection.
        db.execute("PRAGMA key = '$dbKey';");
      },
    );
  });
}
