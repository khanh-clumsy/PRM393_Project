import { apiRequest } from '../../core/api/client'
import type {
  CreateDepartmentPayload,
  Department,
  UpdateDepartmentPayload,
} from './types'

/** Danh sách tất cả phòng ban */
export function fetchDepartments() {
  return apiRequest<Department[]>('/api/department')
}

/** Tạo phòng ban mới */
export function createDepartment(payload: CreateDepartmentPayload) {
  return apiRequest<Department>('/api/department', {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

/** Cập nhật phòng ban theo id */
export function updateDepartment(id: number, payload: UpdateDepartmentPayload) {
  return apiRequest<Department>(`/api/department/${id}`, {
    method: 'PUT',
    body: JSON.stringify(payload),
  })
}

/** Xóa phòng ban theo id */
export function deleteDepartment(id: number) {
  return apiRequest<void>(`/api/department/${id}`, {
    method: 'DELETE',
  })
}
