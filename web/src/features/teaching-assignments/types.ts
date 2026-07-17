import type { AcademicYear } from '../academic-years/types'
import type { UserDto } from '../auth/types'
import type { SchoolClass } from '../classes/types'
import type { Semester } from '../semesters/types'
import type { Subject } from '../subjects/types'

/** Phân công giảng dạy — khớp TeachingAssignmentDto API */
export type TeachingAssignment = {
  teachingAssignmentId: number
  teacherId: number
  classId: number
  subjectId: number
  semesterId: number
  className: string | null
  subjectName: string | null
}

export type TeachingAssignmentPayload = {
  teacherId: number
  classId: number
  subjectId: number
  semesterId: number
}

/** Lookup từ GET /api/lookup/teaching-assignments */
export type TeachingAssignmentLookup = {
  academicYears: AcademicYear[]
  semesters: Semester[]
  classes: SchoolClass[]
  subjects: Subject[]
  teachers: UserDto[]
}

/** Giáo viên dùng cho dropdown */
export type TeacherOption = {
  id: number
  fullName: string
}
