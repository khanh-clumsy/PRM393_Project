import { Navigate, Route, Routes } from 'react-router-dom'
import RequireAdmin from '../core/auth/RequireAdmin'
import AccountPage from '../features/account/AccountPage'
import LoginPage from '../features/auth/LoginPage'
import DashboardPage from '../features/dashboard/DashboardPage'
import DepartmentPage from '../features/departments/DepartmentPage'
import PlaceholderPage from '../features/shared/PlaceholderPage'
import AdminLayout from '../layouts/AdminLayout'

/** Định nghĩa route công khai và khu vực Admin */
export default function AppRouter() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route element={<RequireAdmin />}>
        <Route path="/admin" element={<AdminLayout />}>
          <Route index element={<DashboardPage />} />
          <Route path="users" element={<PlaceholderPage />} />
          <Route path="departments" element={<DepartmentPage />} />
          <Route path="academic-years" element={<PlaceholderPage />} />
          <Route path="semesters" element={<PlaceholderPage />} />
          <Route path="subjects" element={<PlaceholderPage />} />
          <Route path="classes" element={<PlaceholderPage />} />
          <Route path="ranks" element={<PlaceholderPage />} />
          <Route path="slots" element={<PlaceholderPage />} />
          <Route path="teaching-assignments" element={<PlaceholderPage />} />
          <Route path="timetables" element={<PlaceholderPage />} />
          <Route path="student-classes" element={<PlaceholderPage />} />
          <Route path="parent-student" element={<PlaceholderPage />} />
          <Route path="announcements" element={<PlaceholderPage />} />
          <Route path="account" element={<AccountPage />} />
        </Route>
      </Route>
      <Route path="*" element={<Navigate to="/admin" replace />} />
    </Routes>
  )
}
