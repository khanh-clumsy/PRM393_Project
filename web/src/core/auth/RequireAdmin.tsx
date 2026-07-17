import { Navigate, Outlet } from 'react-router-dom'
import { useAuth } from './AuthContext'

/** Trang 403 khi đã đăng nhập nhưng không phải Admin */
function ForbiddenPage() {
  const { logout, user } = useAuth()

  return (
    <div className="forbidden-page">
      <h1>403 — Không có quyền truy cập</h1>
      <p>
        Tài khoản <strong>{user?.fullName ?? user?.username}</strong> không có quyền
        truy cập khu vực quản trị web.
      </p>
      <button type="button" className="forbidden-page__btn" onClick={logout}>
        Đăng xuất
      </button>
    </div>
  )
}

/** Route guard: yêu cầu đăng nhập và vai trò Admin */
export default function RequireAdmin() {
  const { isAuthenticated, isAdmin } = useAuth()

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />
  }

  if (!isAdmin) {
    return <ForbiddenPage />
  }

  return <Outlet />
}
