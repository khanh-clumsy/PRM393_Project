import { apiRequest } from '../../core/api/client'
import type { CreateSubjectPayload, Subject, UpdateSubjectPayload } from './types'

/** Danh sách tất cả môn học */
export function fetchSubjects() {
  return apiRequest<Subject[]>('/api/subject')
}

/** Tạo môn học mới */
export function createSubject(payload: CreateSubjectPayload) {
  return apiRequest<Subject>('/api/subject', {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

/** Cập nhật môn học theo id */
export function updateSubject(id: number, payload: UpdateSubjectPayload) {
  return apiRequest<Subject>(`/api/subject/${id}`, {
    method: 'PUT',
    body: JSON.stringify(payload),
  })
}

/** Xóa môn học theo id */
export function deleteSubject(id: number) {
  return apiRequest<void>(`/api/subject/${id}`, {
    method: 'DELETE',
  })
}
