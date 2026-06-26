class UserModel {
  final int userId;
  final String username;
  final String fullName;
  final String? dateOfBirth;
  final String? gender;
  final String? address;
  final String? email;
  final String? phoneNumber;
  final String? avatarUrl;
  final int roleId;
  final String roleName;
  final int? departmentId;

  UserModel({
    required this.userId,
    required this.username,
    required this.fullName,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.email,
    this.phoneNumber,
    this.avatarUrl,
    required this.roleId,
    required this.roleName,
    this.departmentId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['id'] ?? json['userId'] ?? 0,
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      dateOfBirth: json['dateOfBirth'],
      gender: json['gender'],
      address: json['address'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      avatarUrl: json['avatarUrl'],
      roleId: json['roleId'] ?? 0,
      roleName: json['roleName'] ?? '',
      departmentId: json['departmentId'],
    );
  }

  bool get isStudent => roleName.toLowerCase() == 'student';
  bool get isTeacher => roleName.toLowerCase() == 'teacher';
  bool get isAdmin => roleName.toLowerCase() == 'admin';
  bool get isHeadOfDept => roleName.toLowerCase() == 'headofdept';
  bool get isParent => roleName.toLowerCase() == 'parent';
}