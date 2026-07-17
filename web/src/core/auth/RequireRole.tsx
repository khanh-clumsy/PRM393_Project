import { Navigate, Outlet } from 'react-router-dom'
import { useAuth } from './AuthContext'
import type { AppRole } from './roles'

type RequireRoleProps = {
  allow: AppRole[]
}

function ForbiddenPage() {
  const { logout, user } = useAuth()

  return (
    <div className="forbidden-page">
      <h1>403 — Không có quyền truy cập</h1>
      <p>
        Tài khoản <strong>{user?.fullName ?? user?.username}</strong> không có quyền
        truy cập khu vực này.
      </p>
      <button type="button" className="forbidden-page__btn" onClick={logout}>
        Đăng xuất
      </button>
    </div>
  )
}

/** Chặn truy cập sai khu vực theo vai trò đăng nhập. */
export default function RequireRole({ allow }: RequireRoleProps) {
  const { isAuthenticated, user } = useAuth()

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />
  }

  if (!user || !allow.includes(user.roleName as AppRole)) {
    return <ForbiddenPage />
  }

  return <Outlet />
}
