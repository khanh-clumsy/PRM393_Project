class AuthModel {
  final String accessToken;
  final String refreshToken;
  final int userId;
  final String username;
  final String fullName;
  final int roleId;
  final String roleName;
  final int? departmentId;

  AuthModel({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.username,
    required this.fullName,
    required this.roleId,
    required this.roleName,
    this.departmentId,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? <String, dynamic>{};
    return AuthModel(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      userId: user['id'] ?? user['userId'] ?? 0,
      username: user['username'] ?? '',
      fullName: user['fullName'] ?? '',
      roleId: user['roleId'] ?? 0,
      roleName: user['roleName'] ?? '',
      departmentId: user['departmentId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'userId': userId,
      'username': username,
      'fullName': fullName,
      'roleId': roleId,
      'roleName': roleName,
      'departmentId': departmentId,
    };
  }
}