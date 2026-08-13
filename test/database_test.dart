import 'package:cycletrack/core/db/database.dart';
import 'package:cycletrack/core/models.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('upsertLog updates the same calendar day without duplicate rows', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final day = DateTime(2026, 8, 12);
    await db.upsertLog(DayLogsCompanion.insert(
      date: day,
      flow: Value(FlowLevel.medium.index),
    ));
    await db.upsertLog(DayLogsCompanion.insert(
      date: day,
      flow: Value(FlowLevel.heavy.index),
      notes: const Value('updated'),
    ));

    final log = await db.getLog(day);
    expect(log?.flow, FlowLevel.heavy.index);
    expect(log?.notes, 'updated');
    expect((await db.getAllLogs()).length, 1);
  });
}
