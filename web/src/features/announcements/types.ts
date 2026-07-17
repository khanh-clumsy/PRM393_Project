/** Mức ưu tiên thông báo */
export type AnnouncementPriority = 'normal' | 'high' | 'urgent'

/** Loại thông báo */
export type AnnouncementType = 'global' | 'class'

/** Thông báo — khớp AnnouncementDto API */
export type Announcement = {
  announcementId: number
  authorId: number
  title: string
  content: string
  announcementType: string
  priority: string
  createdAt: string
  targetClassIds: (number | null)[]
}

export type CreateAnnouncementPayload = {
  authorId: number
  title: string
  content: string
  announcementType: AnnouncementType
  priority: AnnouncementPriority
  targetClassIds: number[]
}

export type UpdateAnnouncementPayload = {
  title?: string
  content?: string
  priority?: AnnouncementPriority
}
