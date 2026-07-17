export type TeacherNavItem = {
  to: string
  label: string
  end?: boolean
}

export const TEACHER_NAV: TeacherNavItem[] = [
  { to: '/teacher', label: 'Tổng quan', end: true },
  { to: '/teacher/classes', label: 'Lớp của tôi' },
  { to: '/teacher/timetable', label: 'Thời khóa biểu' },
  { to: '/teacher/attendance', label: 'Điểm danh' },
  { to: '/teacher/grades', label: 'Nhập điểm' },
  { to: '/teacher/announcements', label: 'Bảng tin' },
  { to: '/teacher/leave-requests', label: 'Đơn xin nghỉ' },
  { to: '/teacher/class-summaries', label: 'Tổng kết lớp' },
  { to: '/teacher/account', label: 'Tài khoản' },
]
