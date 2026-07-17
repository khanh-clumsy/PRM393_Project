import { Navigate, Route, Routes } from 'react-router-dom'
import RequireAdmin from '../core/auth/RequireAdmin'
import DashboardPage from '../features/dashboard/DashboardPage'
import LoginPage from '../features/auth/LoginPage'
import AdminLayout from '../layouts/AdminLayout'

/** Định nghĩa route công khai và khu vực Admin */
export default function AppRouter() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route element={<RequireAdmin />}>
        <Route path="/admin" element={<AdminLayout />}>
          <Route index element={<DashboardPage />} />
          {/* Các module CRUD đăng ký dần ở task sau */}
        </Route>
      </Route>
      <Route path="*" element={<Navigate to="/admin" replace />} />
    </Routes>
  )
}
