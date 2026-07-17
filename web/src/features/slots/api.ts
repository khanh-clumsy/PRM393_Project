import { apiRequest } from '../../core/api/client'
import type { CreateSlotPayload, TimetableSlot, UpdateSlotPayload } from './types'

/** Danh sách tất cả ca học */
export function fetchSlots() {
  return apiRequest<TimetableSlot[]>('/api/timetableslot')
}

/** Tạo ca học mới */
export function createSlot(payload: CreateSlotPayload) {
  return apiRequest<TimetableSlot>('/api/timetableslot', {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

/** Cập nhật ca học theo id */
export function updateSlot(id: number, payload: UpdateSlotPayload) {
  return apiRequest<TimetableSlot>(`/api/timetableslot/${id}`, {
    method: 'PUT',
    body: JSON.stringify(payload),
  })
}

/** Xóa ca học theo id */
export function deleteSlot(id: number) {
  return apiRequest<void>(`/api/timetableslot/${id}`, {
    method: 'DELETE',
  })
}
