/** Môn học — khớp SubjectDto API */
export type Subject = {
  subjectId: number
  subjectCode: string
  subjectName: string
  isActive: boolean
}

export type CreateSubjectPayload = {
  subjectCode: string
  subjectName: string
  isActive?: boolean
}

export type UpdateSubjectPayload = {
  subjectCode?: string
  subjectName?: string
  isActive?: boolean
}
