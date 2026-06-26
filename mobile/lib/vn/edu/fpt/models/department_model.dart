class DepartmentModel {
  final int departmentId;
  final String departmentName;
  final String? description;

  DepartmentModel({
    required this.departmentId,
    required this.departmentName,
    this.description,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      departmentId: json['departmentId'] as int,
      departmentName: json['departmentName'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'departmentId': departmentId,
      'departmentName': departmentName,
      'description': description,
    };
  }
}
