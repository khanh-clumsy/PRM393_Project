/** Phòng ban / Khoa — khớp DepartmentDto API */
export type Department = {
  departmentId: number
  departmentName: string
  description: string | null
}

export type CreateDepartmentPayload = {
  departmentName: string
  description?: string | null
}

export type UpdateDepartmentPayload = {
  departmentName?: string
  description?: string | null
}
