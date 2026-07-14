import 'package:flutter_test/flutter_test.dart';
import 'package:prm393_mobile/vn/edu/fpt/models/notification_log_model.dart';

void main() {
  test('fromJson parses notification log', () {
    final model = NotificationLogModel.fromJson({
      'notificationId': 7,
      'userId': 12,
      'announcementId': 3,
      'title': 'Thong bao moi',
      'body': 'Noi dung',
      'isRead': false,
      'readAt': null,
      'createdAt': '2026-07-13T10:00:00Z',
    });

    expect(model.notificationId, 7);
    expect(model.isRead, false);
    expect(model.title, 'Thong bao moi');
  });
}
