/** Xếp loại học lực — khớp AcademicRankDto API */
export type AcademicRank = {
  rankId: number
  rankName: string
  minScore: number
  maxScore: number
}

export type CreateRankPayload = {
  rankName: string
  minScore: number
  maxScore: number
}

export type UpdateRankPayload = {
  rankName?: string
  minScore?: number
  maxScore?: number
}
