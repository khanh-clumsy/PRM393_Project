class YearlyTranscriptModel {
  final int studentId;
  final int academicYearId;
  final double? yearlyCumulativeGpa;
  final String? yearlyConduct;
  final List<SemesterTranscriptModel> semesters;

  YearlyTranscriptModel({
    required this.studentId,
    required this.academicYearId,
    this.yearlyCumulativeGpa,
    this.yearlyConduct,
    required this.semesters,
  });

  factory YearlyTranscriptModel.fromJson(Map<String, dynamic> json) {
    var semestersList = json['semesters'] as List? ?? [];
    return YearlyTranscriptModel(
      studentId: json['studentId'] ?? 0,
      academicYearId: json['academicYearId'] ?? 0,
      yearlyCumulativeGpa: json['yearlyCumulativeGpa'] != null ? (json['yearlyCumulativeGpa'] as num).toDouble() : null,
      yearlyConduct: json['yearlyConduct'],
      semesters: semestersList.map((e) => SemesterTranscriptModel.fromJson(e)).toList(),
    );
  }
}

class SemesterTranscriptModel {
  final int semesterId;
  final String semesterName;
  final double? gpa;
  final String? conduct;
  final String? rankName;
  final List<SemesterSubjectTranscriptModel> subjects;

  SemesterTranscriptModel({
    required this.semesterId,
    required this.semesterName,
    this.gpa,
    this.conduct,
    this.rankName,
    required this.subjects,
  });

  factory SemesterTranscriptModel.fromJson(Map<String, dynamic> json) {
    var subjectsList = json['subjects'] as List? ?? [];
    return SemesterTranscriptModel(
      semesterId: json['semesterId'] ?? 0,
      semesterName: json['semesterName'] ?? '',
      gpa: json['gpa'] != null ? (json['gpa'] as num).toDouble() : null,
      conduct: json['conduct'],
      rankName: json['rankName'],
      subjects: subjectsList.map((e) => SemesterSubjectTranscriptModel.fromJson(e)).toList(),
    );
  }
}

class SemesterSubjectTranscriptModel {
  final int subjectId;
  final String subjectName;
  final String subjectCode;
  final double? overallScore;
  final double? yearlyAverageScore;
  final bool? isPassed;
  final List<AssessmentGradeModel> grades;

  SemesterSubjectTranscriptModel({
    required this.subjectId,
    required this.subjectName,
    required this.subjectCode,
    this.overallScore,
    this.yearlyAverageScore,
    this.isPassed,
    required this.grades,
  });

  factory SemesterSubjectTranscriptModel.fromJson(Map<String, dynamic> json) {
    var gradesList = json['grades'] as List? ?? [];
    return SemesterSubjectTranscriptModel(
      subjectId: json['subjectId'] ?? 0,
      subjectName: json['subjectName'] ?? '',
      subjectCode: json['subjectCode'] ?? '',
      overallScore: json['overallScore'] != null ? (json['overallScore'] as num).toDouble() : null,
      yearlyAverageScore: json['yearlyAverageScore'] != null ? (json['yearlyAverageScore'] as num).toDouble() : null,
      isPassed: json['isPassed'],
      grades: gradesList.map((e) => AssessmentGradeModel.fromJson(e)).toList(),
    );
  }
}
class AssessmentGradeModel {
  final int assessmentId;
  final String assessmentName;
  final String typeName;
  final double weight;
  final double maxScore;
  final double? score;
  final String? comment;
  final DateTime? enteredAt;

  AssessmentGradeModel({
    required this.assessmentId,
    required this.assessmentName,
    required this.typeName,
    required this.weight,
    required this.maxScore,
    this.score,
    this.comment,
    this.enteredAt,
  });

  factory AssessmentGradeModel.fromJson(Map<String, dynamic> json) {
    return AssessmentGradeModel(
      assessmentId: json['assessmentId'] ?? 0,
      assessmentName: json['assessmentName'] ?? '',
      typeName: json['typeName'] ?? '',
      weight: (json['weight'] ?? 0).toDouble(),
      maxScore: (json['maxScore'] ?? 10).toDouble(),
      score: json['score'] != null ? (json['score'] as num).toDouble() : null,
      comment: json['comment'],
      enteredAt: json['enteredAt'] != null ? DateTime.tryParse(json['enteredAt']) : null,
    );
  }
}

class StudentGradeEntryModel {
  final int studentId;
  final String studentName;
  double? score;
  String? comment;

  StudentGradeEntryModel({
    required this.studentId,
    required this.studentName,
    this.score,
    this.comment,
  });

  factory StudentGradeEntryModel.fromJson(Map<String, dynamic> json) {
    return StudentGradeEntryModel(
      studentId: json['studentId'] ?? 0,
      studentName: json['studentName'] ?? '',
      score: json['score'] != null ? (json['score'] as num).toDouble() : null,
      comment: json['comment'],
    );
  }
}

class BulkGradeModel {
  final int assessmentId;
  final int studentId;
  final double? score;
  final String? comment;
  final int enteredBy;

  BulkGradeModel({
    required this.assessmentId,
    required this.studentId,
    this.score,
    this.comment,
    required this.enteredBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'assessmentId': assessmentId,
      'studentId': studentId,
      'score': score,
      'comment': comment,
      'enteredBy': enteredBy,
    };
  }
}

class StudentGradeByTypeModel {
  final int studentId;
  final String studentName;
  final String username;
  final String? avatarUrl;
  double? score;
  String? comment;

  StudentGradeByTypeModel({
    required this.studentId,
    required this.studentName,
    required this.username,
    this.avatarUrl,
    this.score,
    this.comment,
  });

  factory StudentGradeByTypeModel.fromJson(Map<String, dynamic> json) {
    return StudentGradeByTypeModel(
      studentId: json['studentId'],
      studentName: json['studentName'],
      username: json['username'],
      avatarUrl: json['avatarUrl'],
      score: json['score'] != null ? (json['score'] as num).toDouble() : null,
      comment: json['comment'],
    );
  }
}

class BulkGradeByTypeModel {
  final int teachingAssignmentId;
  final int assessmentTypeId;
  final List<StudentScoreModel> students;

  BulkGradeByTypeModel({
    required this.teachingAssignmentId,
    required this.assessmentTypeId,
    required this.students,
  });

  Map<String, dynamic> toJson() {
    return {
      'teachingAssignmentId': teachingAssignmentId,
      'assessmentTypeId': assessmentTypeId,
      'students': students.map((s) => s.toJson()).toList(),
    };
  }
}

class StudentScoreModel {
  final int studentId;
  final double? score;
  final String? comment;

  StudentScoreModel({
    required this.studentId,
    this.score,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'score': score,
      'comment': comment,
    };
  }
}
