import type { SchoolClass } from '../classes/types'
import type { StudentClass } from '../student-classes/types'
import type { TeachingAssignment } from '../teaching-assignments/types'
import type { TimetableLesson } from '../timetables/types'

export type TeacherClassRole = 'teaching' | 'homeroom' | 'both'

export type TeacherClass = SchoolClass & {
  role: TeacherClassRole
  assignments: TeachingAssignment[]
}

export type AttendanceStatusCode = 'P' | 'A' | 'L' | 'E'

export type AttendanceRecord = {
  attendanceId: number
  timetableId: number
  studentId: number
  status: string
  note: string | null
  recordedBy: number
  recordedAt: string
}

export type TeacherAttendanceEntry = StudentClass & {
  attendanceId: number | null
  status: AttendanceStatusCode
  note: string
}

export type AssessmentType = {
  assessmentTypeId: number
  typeName: string
  weight: number
}

export type StudentGradeByType = {
  studentId: number
  studentName: string
  username: string
  avatarUrl: string | null
  score: number | null
  comment: string | null
}

export type GradeDraft = StudentGradeByType & {
  scoreInput: string
  error: string | null
}

export type Announcement = {
  announcementId: number
  authorId: number
  title: string
  content: string
  announcementType: string
  priority: string
  createdAt: string
  targetClassIds?: Array<number | null>
}

export type CreateAnnouncementPayload = {
  authorId: number
  title: string
  content: string
  announcementType: 'class' | 'Class'
  priority: string
  targetClassIds: number[]
}

export type StudentRequest = {
  studentRequestId: number
  studentId: number
  studentName: string | null
  requestedBy: number
  requestedByName: string | null
  leaveDate: string
  reason: string
  attachmentUrl: string | null
  status: string
  reviewedBy: number | null
  reviewedAt: string | null
  reviewNote: string | null
  createdAt: string
}

export type ReviewStudentRequestPayload = {
  status: 'Approved' | 'Rejected'
  reviewedBy: number
  reviewNote: string | null
}

export type ClassSemesterSummaryRow = {
  studentId: number
  studentName: string
  studentCode: string | null
  summaryId: number | null
  gpa: number | null
  conduct: string | null
  rankId: number | null
  rankName: string | null
  isFinalized: boolean
}

export type ClassYearlySummaryRow = {
  studentId: number
  studentName: string
  studentCode: string | null
  yearlySummaryId: number | null
  yearlyGpa: number | null
  yearlyConduct: string | null
  rankId: number | null
  rankName: string | null
  isFinalized: boolean
}

export type { SchoolClass, StudentClass, TeachingAssignment, TimetableLesson }
