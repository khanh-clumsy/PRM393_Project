/// Danh mục quan hệ phụ huynh – học sinh (lưu DB + hiển thị).
class ParentRelationshipType {
  final String value;
  final String label;
  final String description;

  const ParentRelationshipType({
    required this.value,
    required this.label,
    required this.description,
  });
}

class ParentRelationshipHelper {
  ParentRelationshipHelper._();

  static const List<ParentRelationshipType> options = [
    ParentRelationshipType(
      value: 'Bố',
      label: 'Bố',
      description: 'Cha đẻ của học sinh',
    ),
    ParentRelationshipType(
      value: 'Mẹ',
      label: 'Mẹ',
      description: 'Mẹ đẻ của học sinh',
    ),
    ParentRelationshipType(
      value: 'Ông',
      label: 'Ông',
      description: 'Ông nội hoặc ông ngoại của học sinh',
    ),
    ParentRelationshipType(
      value: 'Bà',
      label: 'Bà',
      description: 'Bà nội hoặc bà ngoại của học sinh',
    ),
    ParentRelationshipType(
      value: 'Anh/Chị',
      label: 'Anh/Chị',
      description: 'Anh hoặc chị ruột của học sinh',
    ),
    ParentRelationshipType(
      value: 'Người giám hộ',
      label: 'Người giám hộ',
      description: 'Người được ủy quyền chăm sóc và theo dõi học tập',
    ),
    ParentRelationshipType(
      value: 'Khác',
      label: 'Khác',
      description: 'Quan hệ khác với học sinh',
    ),
  ];

  static ParentRelationshipType? findByValue(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final trimmed = raw.trim();
    for (final option in options) {
      if (option.value == trimmed) return option;
    }
    final mapped = _legacyAliases[trimmed.toLowerCase()];
    if (mapped != null) {
      return options.firstWhere((o) => o.value == mapped);
    }
    return null;
  }

  static const Map<String, String> _legacyAliases = {
    'cha': 'Bố',
    'bố': 'Bố',
    'bo': 'Bố',
    'me': 'Mẹ',
    'mẹ': 'Mẹ',
    'phụ huynh': 'Người giám hộ',
    'phu huynh': 'Người giám hộ',
  };

  /// Nhãn ngắn hiển thị trên danh sách.
  static String displayLabel(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 'Chưa xác định';
    return findByValue(raw)?.label ?? raw.trim();
  }

  /// Mô tả đầy đủ cho modal / chi tiết.
  static String displayDescription(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return 'Chưa có thông tin quan hệ với học sinh';
    }
    final match = findByValue(raw);
    if (match != null) return match.description;
    return 'Quan hệ: ${raw.trim()}';
  }

  /// Dòng phụ hiển thị dạng "Bố · Cha đẻ của học sinh".
  static String displaySubtitle(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 'Chưa xác định quan hệ';
    final match = findByValue(raw);
    if (match != null) return '${match.label} · ${match.description}';
    return raw.trim();
  }

  /// Giá trị chọn sẵn trong dropdown khi sửa (chuẩn hóa dữ liệu cũ).
  static String initialDropdownValue(String? raw) {
    return findByValue(raw)?.value ?? options.first.value;
  }
}
