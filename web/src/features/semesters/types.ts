/** Học kỳ — khớp SemesterDto API */
export type Semester = {
  semesterId: number
  academicYearId: number
  semesterName: string
  startDate: string
  endDate: string
}

export type CreateSemesterPayload = {
  academicYearId: number
  semesterName: string
  startDate: string
  endDate: string
}

/** Cập nhật học kỳ — không đổi academicYearId */
export type UpdateSemesterPayload = {
  semesterName?: string
  startDate?: string
  endDate?: string
}
