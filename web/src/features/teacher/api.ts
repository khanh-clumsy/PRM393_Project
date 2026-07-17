import { apiRequest } from '../../core/api/client'
import type { AcademicYear } from '../academic-years/types'
import type { SchoolClass } from '../classes/types'
import type { Semester } from '../semesters/types'
import type { TimetableSlot } from '../slots/types'
import type { StudentClass } from '../student-classes/types'
import type { TeachingAssignment } from '../teaching-assignments/types'
import type { TimetableLesson } from '../timetables/types'
import type {
  Announcement,
  AssessmentType,
  AttendanceRecord,
  ClassSemesterSummaryRow,
  ClassYearlySummaryRow,
  CreateAnnouncementPayload,
  ReviewStudentRequestPayload,
  StudentGradeByType,
  StudentRequest,
  TeacherClass,
} from './types'
import { mergeTeacherClasses } from './utils'

export function fetchTeacherAcademicYears() {
  return apiRequest<AcademicYear[]>('/api/academicyear')
}

export function fetchTeacherSemesters() {
  return apiRequest<Semester[]>('/api/semester')
}

export function fetchTeacherSlots() {
  return apiRequest<TimetableSlot[]>('/api/timetableslot')
}

export async function fetchTeacherAssignments(teacherId: number) {
  return apiRequest<TeachingAssignment[]>(`/api/teachingassignment/by-teacher/${teacherId}`)
}

export async function fetchTeacherHomeroomClasses(teacherId: number) {
  return apiRequest<SchoolClass[]>(`/api/class/by-homeroom/${teacherId}`)
}

export async function fetchTeacherClasses(teacherId: number): Promise<TeacherClass[]> {
  const [assignments, homeroomClasses] = await Promise.all([
    fetchTeacherAssignments(teacherId),
    fetchTeacherHomeroomClasses(teacherId),
  ])

  return mergeTeacherClasses(assignments, homeroomClasses)
}

export function fetchClassStudents(classId: number) {
  return apiRequest<StudentClass[]>(`/api/studentclass/by-class/${classId}`)
}

export function fetchTeacherWeeklyTimetable(teacherId: number, date: string) {
  return apiRequest<TimetableLesson[]>(
    `/api/timetable/weekly/by-teacher/${teacherId}?date=${encodeURIComponent(date)}`,
  )
}

export function fetchAttendanceByTimetable(timetableId: number) {
  return apiRequest<AttendanceRecord[]>(`/api/attendance/by-timetable/${timetableId}`)
}

export function createAttendanceBulk(
  payload: Array<{
    timetableId: number
    studentId: number
    status: string
    note: string | null
    recordedBy: number
  }>,
) {
  return apiRequest<AttendanceRecord[]>('/api/attendance/bulk', {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

export function updateAttendanceBulk(
  payload: Array<{
    attendanceId: number
    status: string
    note: string | null
  }>,
) {
  return apiRequest<AttendanceRecord[]>('/api/attendance/bulk', {
    method: 'PUT',
    body: JSON.stringify(payload),
  })
}

export function fetchAssessmentTypes() {
  return apiRequest<AssessmentType[]>('/api/assessmenttype')
}

export function fetchClassGradesByType(teachingAssignmentId: number, assessmentTypeId: number) {
  return apiRequest<StudentGradeByType[]>(
    `/api/grade/class-grades-by-type?teachingAssignmentId=${teachingAssignmentId}&assessmentTypeId=${assessmentTypeId}`,
  )
}

export function saveGradesByType(payload: {
  teachingAssignmentId: number
  assessmentTypeId: number
  students: Array<{ studentId: number; score: number | null; comment: string | null }>
}) {
  return apiRequest<void>('/api/grade/bulk-by-type', {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

export function fetchTeacherAnnouncements() {
  return apiRequest<Announcement[]>('/api/announcement/my-feed')
}

export function createTeacherAnnouncement(payload: CreateAnnouncementPayload) {
  return apiRequest<Announcement>('/api/announcement', {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

export function fetchPendingLeaveRequests() {
  return apiRequest<StudentRequest[]>('/api/studentrequest/pending/for-teacher')
}

export function reviewLeaveRequest(
  requestId: number,
  payload: ReviewStudentRequestPayload,
) {
  return apiRequest<StudentRequest>(`/api/studentrequest/${requestId}/review`, {
    method: 'PUT',
    body: JSON.stringify(payload),
  })
}

export function fetchClassSemesterSummary(classId: number, semesterId: number) {
  return apiRequest<ClassSemesterSummaryRow[]>(
    `/api/class/${classId}/summaries/semester/${semesterId}`,
  )
}

export function fetchClassYearlySummary(classId: number, academicYearId: number) {
  return apiRequest<ClassYearlySummaryRow[]>(
    `/api/class/${classId}/summaries/yearly/${academicYearId}`,
  )
}
