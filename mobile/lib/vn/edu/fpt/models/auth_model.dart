class AuthModel {
  final String accessToken;
  final String refreshToken;
  final int userId;
  final String username;
  final String fullName;
  final int roleId;
  final String roleName;

  AuthModel({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.username,
    required this.fullName,
    required this.roleId,
    required this.roleName,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? <String, dynamic>{};
    return AuthModel(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      userId: user['id'] ?? 0,
      username: user['username'] ?? '',
      fullName: user['fullName'] ?? '',
      roleId: user['roleId'] ?? 0,
      roleName: user['roleName'] ?? '',
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
    };
  }
}