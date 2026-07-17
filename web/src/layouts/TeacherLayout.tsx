import { useState } from 'react'
import { NavLink, Outlet } from 'react-router-dom'
import ConfirmDialog from '../components/ui/ConfirmDialog'
import { useAuth } from '../core/auth/AuthContext'
import { TEACHER_NAV } from './teacherNav'
import '../features/teacher/teacher.css'

export default function TeacherLayout() {
  const { user, logout } = useAuth()
  const [logoutOpen, setLogoutOpen] = useState(false)

  function handleLogoutConfirm() {
    setLogoutOpen(false)
    logout()
  }

  return (
    <div className="admin-layout teacher-layout">
      <aside className="admin-sidebar teacher-sidebar">
        <div className="admin-sidebar__brand">
          FPT <span>Teacher</span>
        </div>
        <nav className="admin-sidebar__nav" aria-label="Menu giáo viên">
          {TEACHER_NAV.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.end}
              className={({ isActive }) =>
                `admin-sidebar__link${isActive ? ' admin-sidebar__link--active' : ''}`
              }
            >
              {item.label}
            </NavLink>
          ))}
        </nav>
        <div className="admin-sidebar__footer">
          <button
            type="button"
            className="admin-sidebar__logout"
            onClick={() => setLogoutOpen(true)}
          >
            Đăng xuất
          </button>
        </div>
      </aside>

      <div className="admin-main">
        <header className="admin-topbar">
          <span className="admin-topbar__user">
            Xin chào, <strong>{user?.fullName ?? 'Giáo viên'}</strong>
          </span>
        </header>
        <main className="admin-content teacher-content">
          <Outlet />
        </main>
      </div>

      <ConfirmDialog
        open={logoutOpen}
        title="Đăng xuất"
        message="Bạn có chắc muốn đăng xuất khỏi khu vực giáo viên?"
        confirmLabel="Đăng xuất"
        variant="danger"
        onConfirm={handleLogoutConfirm}
        onCancel={() => setLogoutOpen(false)}
      />
    </div>
  )
}
