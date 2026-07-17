/** Liên kết phụ huynh – học sinh — khớp ParentStudentDto API */
export type ParentStudent = {
  parentStudentId: number
  parentId: number
  studentId: number
  relationship: string
  studentName: string | null
  parentName: string | null
  studentCode: string | null
  parentCode: string | null
}

export type CreateParentStudentPayload = {
  parentId: number
  studentId: number
  relationship: string
}

export type UpdateParentStudentPayload = {
  relationship: string
}

/** Người dùng dùng cho dropdown */
export type UserOption = {
  id: number
  fullName: string
  username: string
}

/** Danh mục quan hệ phụ huynh – học sinh */
export type RelationshipOption = {
  value: string
  label: string
  description: string
}

export const RELATIONSHIP_OPTIONS: RelationshipOption[] = [
  { value: 'Bố', label: 'Bố', description: 'Cha đẻ của học sinh' },
  { value: 'Mẹ', label: 'Mẹ', description: 'Mẹ đẻ của học sinh' },
  { value: 'Ông', label: 'Ông', description: 'Ông nội hoặc ông ngoại của học sinh' },
  { value: 'Bà', label: 'Bà', description: 'Bà nội hoặc bà ngoại của học sinh' },
  { value: 'Anh/Chị', label: 'Anh/Chị', description: 'Anh hoặc chị ruột của học sinh' },
  {
    value: 'Người giám hộ',
    label: 'Người giám hộ',
    description: 'Người được ủy quyền chăm sóc và theo dõi học tập',
  },
  { value: 'Khác', label: 'Khác', description: 'Quan hệ khác với học sinh' },
]

/** Chuẩn hóa giá trị quan hệ cũ cho dropdown */
export function initialRelationshipValue(raw: string | null | undefined): string {
  if (!raw?.trim()) return RELATIONSHIP_OPTIONS[0].value
  const match = RELATIONSHIP_OPTIONS.find((o) => o.value === raw.trim())
  return match?.value ?? RELATIONSHIP_OPTIONS[0].value
}

/** Nhãn hiển thị quan hệ trên bảng */
export function relationshipSubtitle(raw: string | null | undefined): string {
  if (!raw?.trim()) return 'Chưa xác định quan hệ'
  const match = RELATIONSHIP_OPTIONS.find((o) => o.value === raw.trim())
  if (match) return `${match.label} · ${match.description}`
  return raw.trim()
}
