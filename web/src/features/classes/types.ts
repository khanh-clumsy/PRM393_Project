/** Lớp học — khớp ClassDto API */
export type SchoolClass = {
  classId: number
  className: string
  academicYearId: number
  homeroomTeacherId: number | null
}

export type CreateClassPayload = {
  className: string
  academicYearId: number
  homeroomTeacherId?: number
}

export type UpdateClassPayload = {
  className?: string
  homeroomTeacherId?: number
}

/** Giáo viên dùng cho dropdown GVCN (roleId = 3) */
export type TeacherOption = {
  id: number
  fullName: string
}
