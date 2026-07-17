import { apiRequest } from '../../core/api/client'
import type {
  Announcement,
  CreateAnnouncementPayload,
  UpdateAnnouncementPayload,
} from './types'

/** Danh sách tất cả thông báo (Admin CRUD) */
export function fetchAnnouncements() {
  return apiRequest<Announcement[]>('/api/announcement')
}

/** Tạo thông báo mới */
export function createAnnouncement(payload: CreateAnnouncementPayload) {
  return apiRequest<Announcement>('/api/announcement', {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

/** Cập nhật tiêu đề / nội dung / ưu tiên */
export function updateAnnouncement(id: number, payload: UpdateAnnouncementPayload) {
  return apiRequest<Announcement>(`/api/announcement/${id}`, {
    method: 'PUT',
    body: JSON.stringify(payload),
  })
}

/** Xóa mềm thông báo */
export function deleteAnnouncement(id: number) {
  return apiRequest<void>(`/api/announcement/${id}`, {
    method: 'DELETE',
  })
}
