import '../storage/local_storage.dart';

/// Phạm vi quản lý: admin (toàn trường) hoặc head (theo tổ).
enum ScopeMode { admin, head }

class RoleContext {
  static Future<String?> get role async => LocalStorage.getRole();

  static Future<bool> get isHeadOfDept async =>
      (await role)?.toLowerCase() == 'headofdept';

  static Future<bool> get isAdmin async =>
      (await role)?.toLowerCase() == 'admin';

  static Future<int?> get departmentId async {
    final id = await LocalStorage.getDepartmentId();
    return id != null ? int.tryParse(id) : null;
  }

  static Future<ScopeMode> resolveScopeMode([ScopeMode? override]) async {
    if (override != null) return override;
    return (await isHeadOfDept) ? ScopeMode.head : ScopeMode.admin;
  }
}
