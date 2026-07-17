import { apiRequest } from '../../core/api/client'
import type {
  AcademicYear,
  CreateAcademicYearPayload,
  UpdateAcademicYearPayload,
} from './types'

/** Danh sách tất cả năm học */
export function fetchAcademicYears() {
  return apiRequest<AcademicYear[]>('/api/academicyear')
}

/** Tạo năm học mới (API tự sinh HK1/HK2) */
export function createAcademicYear(payload: CreateAcademicYearPayload) {
  return apiRequest<AcademicYear>('/api/academicyear', {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

/** Cập nhật năm học theo id */
export function updateAcademicYear(id: number, payload: UpdateAcademicYearPayload) {
  return apiRequest<AcademicYear>(`/api/academicyear/${id}`, {
    method: 'PUT',
    body: JSON.stringify(payload),
  })
}

/** Xóa năm học theo id */
export function deleteAcademicYear(id: number) {
  return apiRequest<void>(`/api/academicyear/${id}`, {
    method: 'DELETE',
  })
}
