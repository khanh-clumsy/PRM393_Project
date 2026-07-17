import { apiRequest } from '../../core/api/client'
import type { UserDto } from '../auth/types'
import type {
  CreateClassPayload,
  SchoolClass,
  TeacherOption,
  UpdateClassPayload,
} from './types'

/** Danh sách tất cả lớp */
export function fetchClasses() {
  return apiRequest<SchoolClass[]>('/api/class')
}

/** Lớp theo năm học */
export function fetchClassesByYear(academicYearId: number) {
  return apiRequest<SchoolClass[]>(`/api/class/by-year/${academicYearId}`)
}

/** Danh sách giáo viên (roleId = 3) cho dropdown GVCN */
export async function fetchTeachers(): Promise<TeacherOption[]> {
  const users = await apiRequest<UserDto[]>('/api/user/by-role/3')
  return users.map((u) => ({ id: u.id, fullName: u.fullName }))
}

/** Tạo lớp mới */
export function createClass(payload: CreateClassPayload) {
  return apiRequest<SchoolClass>('/api/class', {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

/** Cập nhật lớp theo id */
export function updateClass(id: number, payload: UpdateClassPayload) {
  return apiRequest<SchoolClass>(`/api/class/${id}`, {
    method: 'PUT',
    body: JSON.stringify(payload),
  })
}

/** Xóa lớp theo id */
export function deleteClass(id: number) {
  return apiRequest<void>(`/api/class/${id}`, {
    method: 'DELETE',
  })
}
