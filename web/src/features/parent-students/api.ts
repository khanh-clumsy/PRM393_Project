import { apiRequest } from '../../core/api/client'
import type { UserDto } from '../auth/types'
import type {
  CreateParentStudentPayload,
  ParentStudent,
  UpdateParentStudentPayload,
  UserOption,
} from './types'

/** Liên kết theo phụ huynh — chỉ gọi khi đã chọn phụ huynh */
export function fetchParentStudentsByParent(parentId: number) {
  return apiRequest<ParentStudent[]>(`/api/parentstudent/by-parent/${parentId}`)
}

/** Danh sách phụ huynh (roleId = 5) */
export async function fetchParents(): Promise<UserOption[]> {
  const users = await apiRequest<UserDto[]>('/api/user/by-role/5')
  return users.map((u) => ({ id: u.id, fullName: u.fullName, username: u.username }))
}

/** Danh sách học sinh (roleId = 4) */
export async function fetchStudents(): Promise<UserOption[]> {
  const users = await apiRequest<UserDto[]>('/api/user/by-role/4')
  return users.map((u) => ({ id: u.id, fullName: u.fullName, username: u.username }))
}

/** Tạo liên kết mới */
export function createParentStudent(payload: CreateParentStudentPayload) {
  return apiRequest<ParentStudent>('/api/parentstudent', {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

/** Cập nhật quan hệ */
export function updateParentStudent(id: number, payload: UpdateParentStudentPayload) {
  return apiRequest<ParentStudent>(`/api/parentstudent/${id}`, {
    method: 'PUT',
    body: JSON.stringify(payload),
  })
}

/** Xóa liên kết */
export function deleteParentStudent(id: number) {
  return apiRequest<void>(`/api/parentstudent/${id}`, {
    method: 'DELETE',
  })
}
