class StudentRequestModel {
  final int studentRequestId;
  final int studentId;
  final String? studentName;
  final int requestedBy;
  final String? requestedByName;
  final String leaveDate;
  final String reason;
  final String? attachmentUrl;
  final String status;
  final int? reviewedBy;
  final String? reviewedAt;
  final String? reviewNote;
  final String createdAt;

  StudentRequestModel({
    required this.studentRequestId,
    required this.studentId,
    this.studentName,
    required this.requestedBy,
    this.requestedByName,
    required this.leaveDate,
    required this.reason,
    this.attachmentUrl,
    required this.status,
    this.reviewedBy,
    this.reviewedAt,
    this.reviewNote,
    required this.createdAt,
  });

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isRejected => status.toLowerCase() == 'rejected';

  String get statusLabelVi => switch (status.toLowerCase()) {
        'approved' => 'Đã duyệt',
        'rejected' => 'Từ chối',
        _ => 'Chờ duyệt',
      };

  factory StudentRequestModel.fromJson(Map<String, dynamic> json) {
    return StudentRequestModel(
      studentRequestId: json['studentRequestId'] as int,
      studentId: json['studentId'] as int,
      studentName: json['studentName'] as String?,
      requestedBy: json['requestedBy'] as int,
      requestedByName: json['requestedByName'] as String?,
      leaveDate: json['leaveDate'] as String,
      reason: json['reason'] as String,
      attachmentUrl: json['attachmentUrl'] as String?,
      status: json['status'] as String,
      reviewedBy: json['reviewedBy'] as int?,
      reviewedAt: json['reviewedAt'] as String?,
      reviewNote: json['reviewNote'] as String?,
      createdAt: json['createdAt'] as String,
    );
  }
}
