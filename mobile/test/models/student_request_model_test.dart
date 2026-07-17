import 'package:flutter_test/flutter_test.dart';
import 'package:prm393_mobile/vn/edu/fpt/models/student_request_model.dart';

void main() {
  test('fromJson parses leave request', () {
    final m = StudentRequestModel.fromJson({
      'studentRequestId': 1,
      'studentId': 10,
      'studentName': 'Nguyen Van A',
      'requestedBy': 10,
      'requestedByName': 'Nguyen Van A',
      'leaveDate': '2026-07-15',
      'reason': 'Nghi om',
      'attachmentUrl': null,
      'status': 'Pending',
      'reviewedBy': null,
      'reviewedAt': null,
      'reviewNote': null,
      'createdAt': '2026-07-13T08:00:00Z',
    });

    expect(m.status, 'Pending');
    expect(m.statusLabelVi, 'Chờ duyệt');
    expect(m.studentName, 'Nguyen Van A');
  });
}
