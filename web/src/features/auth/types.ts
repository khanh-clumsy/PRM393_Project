/** DTO người dùng — khớp JSON camelCase từ API UserDto */
export type UserDto = {
  id: number
  username: string
  fullName: string
  email: string | null
  phoneNumber: string | null
  roleId: number
  roleName: string
  departmentId: number | null
  dateOfBirth: string | null
  gender: string | null
  address: string | null
  avatarUrl: string | null
  isActive: boolean
  createdAt: string
}

/** Phản hồi đăng nhập / refresh token */
export type AuthTokenDto = {
  accessToken: string
  refreshToken: string
  user: UserDto
}

/** Map vai trò cố định — giống mobile */
export const ROLE_OPTIONS = [
  { id: 1, name: 'Admin', label: 'Quản trị viên' },
  { id: 2, name: 'HeadOfDept', label: 'Trưởng bộ môn' },
  { id: 3, name: 'Teacher', label: 'Giáo viên' },
  { id: 4, name: 'Student', label: 'Học sinh' },
  { id: 5, name: 'Parent', label: 'Phụ huynh' },
] as const

export type RoleName = (typeof ROLE_OPTIONS)[number]['name']
