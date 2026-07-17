/** Chuyển Date sang chuỗi yyyy-MM-dd (local) */
export function formatDateISO(date: Date): string {
  const y = date.getFullYear()
  const m = String(date.getMonth() + 1).padStart(2, '0')
  const d = String(date.getDate()).padStart(2, '0')
  return `${y}-${m}-${d}`
}

/** Thứ Hai của tuần chứa ngày cho trước */
export function getMondayOfWeek(date: Date): Date {
  const copy = new Date(date.getFullYear(), date.getMonth(), date.getDate())
  const diff = copy.getDay() === 0 ? -6 : 1 - copy.getDay()
  copy.setDate(copy.getDate() + diff)
  return copy
}

/** 7 ngày từ Thứ 2 → Chủ nhật */
export function getWeekDays(monday: Date): Date[] {
  return Array.from({ length: 7 }, (_, i) => {
    const d = new Date(monday)
    d.setDate(monday.getDate() + i)
    return d
  })
}

/** dayOfWeek .NET: T2=2 … CN=8 */
export function dateToDayOfWeek(date: Date): number {
  return date.getDay() === 0 ? 8 : date.getDay() + 1
}

/** Hiển thị ngắn: 17/07 */
export function formatShortDate(date: Date): string {
  return `${String(date.getDate()).padStart(2, '0')}/${String(date.getMonth() + 1).padStart(2, '0')}`
}

/** Lấy phần ngày từ chuỗi API (có thể kèm T…) */
export function normalizeApiDate(value: string): string {
  return value.split('T')[0] ?? value
}
