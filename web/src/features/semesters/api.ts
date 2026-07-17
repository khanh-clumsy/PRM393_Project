import { apiRequest } from '../../core/api/client'
import type { CreateSemesterPayload, Semester, UpdateSemesterPayload } from './types'

/** Danh sách tất cả học kỳ */
export function fetchSemesters() {
  return apiRequest<Semester[]>('/api/semester')
}

/** Học kỳ theo năm học */
export function fetchSemestersByYear(academicYearId: number) {
  return apiRequest<Semester[]>(`/api/semester/by-year/${academicYearId}`)
}

/** Tạo học kỳ mới */
export function createSemester(payload: CreateSemesterPayload) {
  return apiRequest<Semester>('/api/semester', {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

/** Cập nhật học kỳ theo id */
export function updateSemester(id: number, payload: UpdateSemesterPayload) {
  return apiRequest<Semester>(`/api/semester/${id}`, {
    method: 'PUT',
    body: JSON.stringify(payload),
  })
}

/** Xóa học kỳ theo id */
export function deleteSemester(id: number) {
  return apiRequest<void>(`/api/semester/${id}`, {
    method: 'DELETE',
  })
}
