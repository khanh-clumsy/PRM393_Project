import 'package:intl/intl.dart';

String formatRelativeTimeVi(String isoDate) {
  final dt = DateTime.parse(isoDate).toLocal();
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'Vua xong';
  if (diff.inMinutes < 60) return '${diff.inMinutes} phut truoc';
  if (diff.inHours < 24) return '${diff.inHours} gio truoc';
  if (diff.inDays == 1) return 'Hom qua, ${DateFormat('HH:mm').format(dt)}';
  if (diff.inDays < 7) return '${diff.inDays} ngay truoc';
  return DateFormat('dd/MM/yyyy').format(dt);
}
