import { apiRequest } from '../../core/api/client'
import type {
  CreateTemplatePayload,
  CreateTimetablePayload,
  TimetableLesson,
  TimetableLookup,
  TimetableTemplate,
  UpdateTemplatePayload,
  UpdateTimetablePayload,
} from './types'

/** Lookup năm, học kỳ, lớp, ca học */
export function fetchTimetableLookup() {
  return apiRequest<TimetableLookup>('/api/lookup/teaching-assignments')
}

/** Lịch tuần theo lớp — date là bất kỳ ngày nào trong tuần */
export function fetchWeeklyByClass(classId: number, date: string) {
  return apiRequest<TimetableLesson[]>(
    `/api/timetable/weekly/by-class/${classId}?date=${encodeURIComponent(date)}`,
  )
}

/** Lịch mẫu theo lớp */
export function fetchTemplatesByClass(classId: number, semesterId: number) {
  return apiRequest<TimetableTemplate[]>(
    `/api/timetable/template/by-class/${classId}?semesterId=${semesterId}`,
  )
}

/** Tạo tiết học thực tế */
export function createTimetable(payload: CreateTimetablePayload) {
  return apiRequest<TimetableLesson>('/api/timetable', {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

/** Cập nhật tiết học — chỉ gửi field API hỗ trợ */
export function updateTimetable(id: number, payload: UpdateTimetablePayload) {
  return apiRequest<TimetableLesson>(`/api/timetable/${id}`, {
    method: 'PUT',
    body: JSON.stringify(payload),
  })
}

/** Xóa tiết học thực tế */
export function deleteTimetable(id: number) {
  return apiRequest<void>(`/api/timetable/${id}`, { method: 'DELETE' })
}

/** Tạo lịch mẫu */
export function createTemplate(payload: CreateTemplatePayload) {
  return apiRequest<TimetableTemplate>('/api/timetable/template', {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

/** Cập nhật lịch mẫu */
export function updateTemplate(id: number, payload: UpdateTemplatePayload) {
  return apiRequest<TimetableTemplate>(`/api/timetable/template/${id}`, {
    method: 'PUT',
    body: JSON.stringify(payload),
  })
}

/** Xóa lịch mẫu */
export function deleteTemplate(id: number) {
  return apiRequest<void>(`/api/timetable/template/${id}`, { method: 'DELETE' })
}

/** Sinh lịch thực tế từ lịch mẫu — xóa lịch cũ + attendance liên quan */
export function generateFromTemplate(semesterId: number, classId: number) {
  return apiRequest<{ count: number }>(
    `/api/timetable/generate-from-template/${semesterId}/${classId}`,
    { method: 'POST' },
  )
}

/** Chỉ dùng khi debug (DEV) — xóa lịch đã sinh */
export function clearGeneratedTimetables(semesterId: number, classId: number) {
  return apiRequest<{ count: number }>(
    `/api/timetable/clear-generated/${semesterId}/${classId}`,
    { method: 'POST' },
  )
}
