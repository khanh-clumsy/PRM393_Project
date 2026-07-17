/** Trạng thái tiết học — khớp API byte status */
export const TIMETABLE_STATUS = {
  NORMAL: 1,
  RESCHEDULED: 2,
  CANCELLED: 3,
  MAKEUP: 4,
} as const

export const STATUS_OPTIONS = [
  { value: TIMETABLE_STATUS.NORMAL, label: 'Bình thường' },
  { value: TIMETABLE_STATUS.RESCHEDULED, label: 'Đổi lịch' },
  { value: TIMETABLE_STATUS.CANCELLED, label: 'Nghỉ học' },
  { value: TIMETABLE_STATUS.MAKEUP, label: 'Dạy bù' },
] as const

/** Thứ 2 = 2 … Chủ nhật = 8 (chuẩn .NET DayOfWeek) */
export const WEEKDAY_COLUMNS = [
  { dayOfWeek: 2, label: 'Thứ 2', short: 'T2' },
  { dayOfWeek: 3, label: 'Thứ 3', short: 'T3' },
  { dayOfWeek: 4, label: 'Thứ 4', short: 'T4' },
  { dayOfWeek: 5, label: 'Thứ 5', short: 'T5' },
  { dayOfWeek: 6, label: 'Thứ 6', short: 'T6' },
  { dayOfWeek: 7, label: 'Thứ 7', short: 'T7' },
  { dayOfWeek: 8, label: 'Chủ nhật', short: 'CN' },
] as const

export function getStatusLabel(status: number): string {
  return STATUS_OPTIONS.find((s) => s.value === status)?.label ?? `Trạng thái ${status}`
}

export function getStatusClass(status: number): string {
  switch (status) {
    case TIMETABLE_STATUS.RESCHEDULED:
      return 'timetable-lesson--rescheduled'
    case TIMETABLE_STATUS.CANCELLED:
      return 'timetable-lesson--cancelled'
    case TIMETABLE_STATUS.MAKEUP:
      return 'timetable-lesson--makeup'
    default:
      return 'timetable-lesson--normal'
  }
}
