/** Năm học — khớp AcademicYearDto API */
export type AcademicYear = {
  academicYearId: number
  yearName: string
  startDate: string
  endDate: string
  isActive: boolean
}

export type CreateAcademicYearPayload = {
  yearName: string
  startDate: string
  endDate: string
  isActive?: boolean
}

export type UpdateAcademicYearPayload = {
  yearName?: string
  startDate?: string
  endDate?: string
  isActive?: boolean
}
