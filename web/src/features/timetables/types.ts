import type { AcademicYear } from '../academic-years/types'
import type { UserDto } from '../auth/types'
import type { SchoolClass } from '../classes/types'
import type { Semester } from '../semesters/types'
import type { TimetableSlot } from '../slots/types'
import type { Subject } from '../subjects/types'
import type { TeachingAssignment } from '../teaching-assignments/types'

/** Tiết học thực tế — khớp TimetableSlotDetailDto API */
export type TimetableLesson = {
  timetableId: number
  teachingAssignmentId: number
  date: string
  slotName: string
  startTime: string
  endTime: string
  roomName: string | null
  subjectId: number
  subjectName: string
  teacherId: number
  teacherName: string
  classId: number
  className: string
  status: number
  note: string | null
  isAttendanceTaken: boolean
}

/** Lịch mẫu — khớp TimetableTemplateResponseDto API */
export type TimetableTemplate = {
  templateId: number
  teachingAssignmentId: number
  dayOfWeek: number
  slotId: number
  slotName: string
  startTime: string
  endTime: string
  roomName: string | null
  subjectId: number
  subjectName: string
  teacherId: number
  teacherName: string
  classId: number
  className: string
  semesterId: number
}

export type TimetableLookup = {
  academicYears: AcademicYear[]
  semesters: Semester[]
  classes: SchoolClass[]
  subjects: Subject[]
  teachers: UserDto[]
  slots: TimetableSlot[]
}

export type CreateTimetablePayload = {
  teachingAssignmentId: number
  date: string
  slotId: number
  roomName?: string | null
  status?: number
  note?: string | null
}

export type UpdateTimetablePayload = {
  date?: string
  slotId?: number
  roomName?: string | null
  status?: number
  note?: string | null
}

export type CreateTemplatePayload = {
  teachingAssignmentId: number
  dayOfWeek: number
  slotId: number
  roomName?: string | null
}

export type UpdateTemplatePayload = {
  teachingAssignmentId?: number
  dayOfWeek?: number
  slotId?: number
  roomName?: string | null
}

export type TimetableMode = 'weekly' | 'template'

export type LessonFormContext =
  | {
      kind: 'weekly-create'
      date: string
      slotId: number
    }
  | {
      kind: 'weekly-edit'
      lesson: TimetableLesson
    }
  | {
      kind: 'template-create'
      dayOfWeek: number
      slotId: number
    }
  | {
      kind: 'template-edit'
      template: TimetableTemplate
    }

export type { TeachingAssignment }
