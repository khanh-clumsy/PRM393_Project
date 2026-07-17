/** Mục điều hướng sidebar admin — khớp mobile AdminHomeView */
export type AdminNavItem = {
  to: string
  label: string
  end?: boolean
}

export const ADMIN_NAV: AdminNavItem[] = [
  { to: '/admin', label: 'Thống kê', end: true },
  { to: '/admin/users', label: 'Tài khoản' },
  { to: '/admin/departments', label: 'Phòng ban / Khoa' },
  { to: '/admin/academic-years', label: 'Năm học' },
  { to: '/admin/semesters', label: 'Học kỳ' },
  { to: '/admin/subjects', label: 'Môn học' },
  { to: '/admin/classes', label: 'Lớp học' },
  { to: '/admin/ranks', label: 'Xếp loại' },
  { to: '/admin/slots', label: 'Ca học (Slot)' },
  { to: '/admin/teaching-assignments', label: 'Phân công GV' },
  { to: '/admin/timetables', label: 'Thời khóa biểu' },
  { to: '/admin/student-classes', label: 'Phân lớp HS' },
  { to: '/admin/parent-student', label: 'Phụ huynh - HS' },
  { to: '/admin/announcements', label: 'Bảng tin' },
  { to: '/admin/account', label: 'Tài khoản của tôi' },
]
