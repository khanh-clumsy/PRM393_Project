import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorage {
  static const _storage = FlutterSecureStorage();

  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyRole = 'user_role';
  static const _keyUserId = 'user_id';
  static const _keyDepartmentId = 'department_id';

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  static Future<void> saveRole(String role) async {
    await _storage.write(key: _keyRole, value: role);
  }

  static Future<String?> getRole() async {
    return await _storage.read(key: _keyRole);
  }

  static Future<void> saveUserId(String userId) async {
    await _storage.write(key: _keyUserId, value: userId);
  }

  static Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  static Future<void> saveDepartmentId(String? departmentId) async {
    if (departmentId == null || departmentId.isEmpty) {
      await _storage.delete(key: _keyDepartmentId);
    } else {
      await _storage.write(key: _keyDepartmentId, value: departmentId);
    }
  }

  static Future<String?> getDepartmentId() async {
    return await _storage.read(key: _keyDepartmentId);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
