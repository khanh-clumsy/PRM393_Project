/// Tài khoản demo 3 role — SĐT phải khớp seed:
/// `api/sql/002_wipe_and_reseed_demo_3_roles.sql`
/// Mật khẩu chung (chỉ môi trường dev): 12345678
class DevLoginAccount {
  final String label;
  final String phoneNumber;
  final String password;
  final String roleHint;

  const DevLoginAccount({
    required this.label,
    required this.phoneNumber,
    required this.password,
    required this.roleHint,
  });
}

const devLoginPassword = '12345678';

const kDevLoginAccounts = <DevLoginAccount>[
  // Demo mobile: chỉ 3 role cần dùng. Admin / Trưởng BM tạm skip trên UI.
  DevLoginAccount(
    label: 'Giáo viên',
    phoneNumber: '01234567890',
    password: devLoginPassword,
    roleHint: 'GVCN 10A1 · teacher01',
  ),
  DevLoginAccount(
    label: 'Phụ huynh',
    phoneNumber: '0786414311',
    password: devLoginPassword,
    roleHint: 'PH của student01',
  ),
  DevLoginAccount(
    label: 'Học sinh',
    phoneNumber: '0364828685',
    password: devLoginPassword,
    roleHint: 'Lớp 10A1 · student01',
  ),
];
