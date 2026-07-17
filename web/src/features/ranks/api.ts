import { apiRequest } from '../../core/api/client'
import type { AcademicRank, CreateRankPayload, UpdateRankPayload } from './types'

/** Danh sách tất cả xếp loại */
export function fetchRanks() {
  return apiRequest<AcademicRank[]>('/api/academicrank')
}

/** Tạo xếp loại mới */
export function createRank(payload: CreateRankPayload) {
  return apiRequest<AcademicRank>('/api/academicrank', {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

/** Cập nhật xếp loại theo id */
export function updateRank(id: number, payload: UpdateRankPayload) {
  return apiRequest<AcademicRank>(`/api/academicrank/${id}`, {
    method: 'PUT',
    body: JSON.stringify(payload),
  })
}

/** Xóa xếp loại theo id */
export function deleteRank(id: number) {
  return apiRequest<void>(`/api/academicrank/${id}`, {
    method: 'DELETE',
  })
}
