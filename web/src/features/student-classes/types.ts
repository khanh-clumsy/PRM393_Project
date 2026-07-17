/** Bản ghi phân lớp học sinh — khớp StudentClassResponseDto API */
export type StudentClass = {
  studentClassId: number
  studentId: number
  classId: number
  studentName: string | null
  studentCode: string | null
}

export type CreateStudentClassPayload = {
  studentId: number
  classId: number
}

/** Học sinh dùng cho dropdown (roleId = 4) */
export type StudentOption = {
  id: number
  fullName: string
  username: string
}
