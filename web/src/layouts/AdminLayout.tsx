import { Outlet } from 'react-router-dom'
import { useAuth } from '../core/auth/AuthContext'

/** Layout admin tạm — Task 5 sẽ thay bằng sidebar đầy đủ */
export default function AdminLayout() {
  const { user, logout } = useAuth()

  return (
    <div className="admin-layout">
      <header className="admin-layout__header">
        <span className="admin-layout__title">Quản trị — {user?.fullName}</span>
        <button type="button" className="admin-layout__logout" onClick={logout}>
          Đăng xuất
        </button>
      </header>
      <main className="admin-layout__main">
        <Outlet />
      </main>
    </div>
  )
}
