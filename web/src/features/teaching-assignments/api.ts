import { apiRequest } from '../../core/api/client'
import type {
  TeachingAssignment,
  TeachingAssignmentLookup,
  TeachingAssignmentPayload,
} from './types'

/** Lookup năm, học kỳ, lớp, môn, giáo viên */
export function fetchTeachingAssignmentLookup() {
  return apiRequest<TeachingAssignmentLookup>('/api/lookup/teaching-assignments')
}

/** Toàn bộ phân công — lọc client theo semesterId + classId */
export function fetchTeachingAssignments() {
  return apiRequest<TeachingAssignment[]>('/api/teachingassignment')
}

/** Tạo phân công mới */
export function createTeachingAssignment(payload: TeachingAssignmentPayload) {
  return apiRequest<TeachingAssignment>('/api/teachingassignment', {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

/** Cập nhật phân công theo id */
export function updateTeachingAssignment(id: number, payload: TeachingAssignmentPayload) {
  return apiRequest<TeachingAssignment>(`/api/teachingassignment/${id}`, {
    method: 'PUT',
    body: JSON.stringify(payload),
  })
}

/** Xóa phân công theo id */
export function deleteTeachingAssignment(id: number) {
  return apiRequest<void>(`/api/teachingassignment/${id}`, {
    method: 'DELETE',
  })
}
