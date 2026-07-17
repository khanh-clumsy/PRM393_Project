import 'package:intl/intl.dart';

/// Parses API timestamps to local time.
///
/// Backend stores UTC (`DateTime.UtcNow`). SQL Server / EF often round-trip
/// `DateTime` as Unspecified, so JSON may omit `Z`. Dart then treats the
/// value as local and shifts clocks by the timezone offset (UTC+7 → −7h).
DateTime parseApiDateTime(String isoDate) {
  final parsed = DateTime.parse(isoDate);
  if (_hasExplicitTimezone(isoDate)) {
    return parsed.toLocal();
  }
  return DateTime.utc(
    parsed.year,
    parsed.month,
    parsed.day,
    parsed.hour,
    parsed.minute,
    parsed.second,
    parsed.millisecond,
    parsed.microsecond,
  ).toLocal();
}

bool _hasExplicitTimezone(String isoDate) {
  if (isoDate.endsWith('Z') || isoDate.endsWith('z')) return true;
  // e.g. 2026-07-15T14:45:00+07:00 or ...-05:00
  return RegExp(r'[+-]\d{2}:\d{2}$').hasMatch(isoDate);
}

String formatRelativeTimeVi(String isoDate) {
  final dt = parseApiDateTime(isoDate);
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'Vừa xong';
  if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
  if (diff.inHours < 24) return '${diff.inHours} giờ trước';
  if (diff.inDays == 1) return 'Hôm qua, ${DateFormat('HH:mm').format(dt)}';
  if (diff.inDays < 7) return '${diff.inDays} ngày trước';
  return DateFormat('dd/MM/yyyy').format(dt);
}
