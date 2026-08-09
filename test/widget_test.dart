import 'package:cycletrack/features/cycle/domain/cycle_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('engine smoke', () {
    final periods = CycleEngine.derivePeriods([
      DateTime(2026, 1, 1),
      DateTime(2026, 1, 2),
      DateTime(2026, 1, 3),
    ]);
    expect(periods, isNotEmpty);
  });
}
