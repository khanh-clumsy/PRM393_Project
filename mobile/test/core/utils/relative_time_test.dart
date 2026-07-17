import 'package:flutter_test/flutter_test.dart';
import 'package:prm393_mobile/vn/edu/fpt/core/utils/relative_time.dart';

void main() {
  group('parseApiDateTime', () {
    test('naive ISO (no Z) is treated as UTC then converted to local', () {
      // API stores UtcNow; SQL/EF often serialize without Z → Dart would treat as local.
      final local = parseApiDateTime('2026-07-15T07:45:00');
      expect(local, DateTime.utc(2026, 7, 15, 7, 45).toLocal());
    });

    test('ISO with Z converts to local', () {
      final local = parseApiDateTime('2026-07-15T07:45:00Z');
      expect(local, DateTime.utc(2026, 7, 15, 7, 45).toLocal());
    });

    test('ISO with offset is respected', () {
      final local = parseApiDateTime('2026-07-15T14:45:00+07:00');
      expect(local.toUtc(), DateTime.utc(2026, 7, 15, 7, 45));
    });
  });

  group('formatRelativeTimeVi', () {
    test('just-created naive UTC shows Vừa xong', () {
      final nowUtc = DateTime.now().toUtc();
      final iso = DateTime.utc(
        nowUtc.year,
        nowUtc.month,
        nowUtc.day,
        nowUtc.hour,
        nowUtc.minute,
        nowUtc.second,
      ).toIso8601String().replaceAll('Z', '');
      expect(formatRelativeTimeVi(iso), 'Vừa xong');
    });
  });
}
