class AcademicYearModel {
  final int academicYearId;
  final String yearName;
  final String startDate; // Backend returns DateOnly as string (YYYY-MM-DD)
  final String endDate;
  final bool isActive;

  AcademicYearModel({
    required this.academicYearId,
    required this.yearName,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  /// Thứ tự thời gian: 2024-2025 → 2025-2026 → 2026-2027
  int get chronologicalSortKey {
    final parsed = DateTime.tryParse(startDate);
    if (parsed != null) {
      return parsed.year * 10000 + parsed.month * 100 + parsed.day;
    }
    final match = RegExp(r'^(\d{4})').firstMatch(yearName);
    if (match != null) {
      return int.parse(match.group(1)!) * 10000;
    }
    return academicYearId;
  }

  static int sortKeyFromJson(Map<String, dynamic> json) {
    final startDate = json['startDate']?.toString();
    if (startDate != null && startDate.isNotEmpty) {
      final parsed = DateTime.tryParse(startDate);
      if (parsed != null) {
        return parsed.year * 10000 + parsed.month * 100 + parsed.day;
      }
    }
    final yearName = json['yearName']?.toString() ?? '';
    final match = RegExp(r'^(\d{4})').firstMatch(yearName);
    if (match != null) {
      return int.parse(match.group(1)!) * 10000;
    }
    return json['academicYearId'] as int? ?? 0;
  }

  static List<AcademicYearModel> sortedChronologically(
    Iterable<AcademicYearModel> years,
  ) {
    final list = years.toList();
    list.sort((a, b) => a.chronologicalSortKey.compareTo(b.chronologicalSortKey));
    return list;
  }

  static void sortMaps(List<dynamic> years) {
    years.sort(
      (a, b) => sortKeyFromJson(a as Map<String, dynamic>)
          .compareTo(sortKeyFromJson(b as Map<String, dynamic>)),
    );
  }

  /// Ưu tiên năm đang active; không có thì lấy năm mới nhất.
  static int? preferredDefaultId(List<AcademicYearModel> years) {
    if (years.isEmpty) return null;
    final sorted = sortedChronologically(years);
    final active = sorted.where((y) => y.isActive).toList();
    if (active.isNotEmpty) {
      return active.last.academicYearId;
    }
    return sorted.last.academicYearId;
  }

  static int? preferredDefaultIdFromMaps(List<dynamic> years) {
    if (years.isEmpty) return null;
    sortMaps(years);
    final active = years.where((y) => (y as Map)['isActive'] == true).toList();
    if (active.isNotEmpty) {
      return active.last['academicYearId'] as int?;
    }
    return (years.last as Map)['academicYearId'] as int?;
  }

  factory AcademicYearModel.fromJson(Map<String, dynamic> json) {
    return AcademicYearModel(
      academicYearId: json['academicYearId'] as int,
      yearName: json['yearName'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      isActive: json['isActive'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'academicYearId': academicYearId,
      'yearName': yearName,
      'startDate': startDate,
      'endDate': endDate,
      'isActive': isActive,
    };
  }
}
