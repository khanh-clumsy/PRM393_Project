import { apiRequest } from '../../core/api/client'
import type { UserDto } from '../auth/types'
import type { CreateStudentClassPayload, StudentClass, StudentOption } from './types'

/** Học sinh trong lớp */
export function fetchStudentClassesByClass(classId: number) {
  return apiRequest<StudentClass[]>(`/api/studentclass/by-class/${classId}`)
}

/** Danh sách học sinh (roleId = 4) */
export async function fetchStudents(): Promise<StudentOption[]> {
  const users = await apiRequest<UserDto[]>('/api/user/by-role/4')
  return users.map((u) => ({ id: u.id, fullName: u.fullName, username: u.username }))
}

/** Thêm học sinh vào lớp */
export function createStudentClass(payload: CreateStudentClassPayload) {
  return apiRequest<StudentClass>('/api/studentclass', {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

/** Xóa phân lớp theo id */
export function deleteStudentClass(id: number) {
  return apiRequest<void>(`/api/studentclass/${id}`, {
    method: 'DELETE',
  })
}
