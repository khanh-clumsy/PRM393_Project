/// Tài khoản seed từ `api/Migrations/20260612042441_SeedData.cs`.
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
  DevLoginAccount(
    label: 'Admin',
    phoneNumber: '0903476776',
    password: devLoginPassword,
    roleHint: 'Quản trị viên',
  ),
  DevLoginAccount(
    label: 'Trưởng BM',
    phoneNumber: '0123456789',
    password: devLoginPassword,
    roleHint: 'HeadOfDept · Tổ Văn',
  ),
  DevLoginAccount(
    label: 'Giáo viên',
    phoneNumber: '01234567890',
    password: devLoginPassword,
    roleHint: 'GVCN 10A1 · teacher01',
  ),
  DevLoginAccount(
    label: 'Học sinh',
    phoneNumber: '0364828685',
    password: devLoginPassword,
    roleHint: 'Lớp 10A1 · student01',
  ),
  DevLoginAccount(
    label: 'Phụ huynh',
    phoneNumber: '0786414311',
    password: devLoginPassword,
    roleHint: 'PH của student01',
  ),
];
