/** Payload tạo tài khoản — khớp CreateUserDto API */
export type CreateUserPayload = {
  username: string
  password: string
  fullName: string
  roleId: number
  email?: string | null
  phoneNumber?: string | null
  departmentId?: number | null
  dateOfBirth?: string | null
  gender?: string | null
  address?: string | null
}

/** Payload cập nhật — không đổi username/password */
export type UpdateUserPayload = {
  fullName?: string
  email?: string | null
  phoneNumber?: string | null
  address?: string | null
  gender?: string | null
  avatarUrl?: string | null
  isActive?: boolean
  roleId?: number
  departmentId?: number | null
}
