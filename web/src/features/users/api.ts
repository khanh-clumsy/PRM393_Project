import { apiRequest } from '../../core/api/client'
import type { UserDto } from '../auth/types'
import type { CreateUserPayload, UpdateUserPayload } from './types'

/** Danh sách tất cả người dùng */
export function fetchUsers() {
  return apiRequest<UserDto[]>('/api/user')
}

/** Tạo tài khoản mới */
export function createUser(payload: CreateUserPayload) {
  return apiRequest<UserDto>('/api/user', {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

/** Cập nhật tài khoản theo id */
export function updateUser(id: number, payload: UpdateUserPayload) {
  return apiRequest<UserDto>(`/api/user/${id}`, {
    method: 'PUT',
    body: JSON.stringify(payload),
  })
}

/** Xóa tài khoản theo id */
export function deleteUser(id: number) {
  return apiRequest<void>(`/api/user/${id}`, {
    method: 'DELETE',
  })
}
