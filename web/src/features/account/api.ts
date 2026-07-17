import { apiRequest } from '../../core/api/client'
import type { UserDto } from '../auth/types'

/** Lấy chi tiết tài khoản đang đăng nhập */
export function fetchUserById(id: number) {
  return apiRequest<UserDto>(`/api/user/${id}`)
}
