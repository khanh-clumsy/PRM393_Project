/** Ca học (tiết) — khớp TimetableSlotDto API */
export type TimetableSlot = {
  slotId: number
  slotName: string
  startTime: string
  endTime: string
}

export type CreateSlotPayload = {
  slotName: string
  startTime: string
  endTime: string
}

export type UpdateSlotPayload = {
  slotName?: string
  startTime?: string
  endTime?: string
}
