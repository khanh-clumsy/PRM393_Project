import { useCallback, useEffect, useState } from 'react'
import { ROLE_OPTIONS } from '../auth/types'
import type { UserDto } from '../auth/types'
import { useAuth } from '../../core/auth/AuthContext'
import Button from '../../components/ui/Button'
import ConfirmDialog from '../../components/ui/ConfirmDialog'
import PageHeader from '../../components/ui/PageHeader'
import Spinner from '../../components/ui/Spinner'
import { fetchUserById } from './api'

/** Map roleId sang nhãn tiếng Việt */
function roleLabel(user: UserDto): string {
  if (user.roleName) return user.roleName
  const found = ROLE_OPTIONS.find((r) => r.id === user.roleId)
  return found?.label ?? `Vai trò #${user.roleId}`
}

/** Trang tài khoản của tôi — xem profile và đăng xuất */
export default function AccountPage() {
  const { user: authUser, logout } = useAuth()
  const [profile, setProfile] = useState<UserDto | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [logoutOpen, setLogoutOpen] = useState(false)

  const load = useCallback(async () => {
    if (!authUser?.id) return
    setLoading(true)
    setError(null)
    try {
      const data = await fetchUserById(authUser.id)
      setProfile(data)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Không tải được thông tin tài khoản.')
    } finally {
      setLoading(false)
    }
  }, [authUser?.id])

  useEffect(() => {
    void load()
  }, [load])

  function handleLogoutConfirm() {
    setLogoutOpen(false)
    logout()
  }

  return (
    <>
      <PageHeader title="Tài khoản của tôi" subtitle="Thông tin đăng nhập hiện tại" />

      {loading && (
        <div className="state-panel">
          <Spinner size="lg" />
          <p className="state-panel__message">Đang tải thông tin…</p>
        </div>
      )}

      {!loading && error && (
        <div className="state-panel state-panel--error">
          <p className="state-panel__title">Lỗi tải dữ liệu</p>
          <p className="state-panel__message">{error}</p>
          <Button onClick={() => void load()}>Thử lại</Button>
        </div>
      )}

      {!loading && !error && profile && (
        <div className="profile-card">
          <div className="profile-row">
            <span className="profile-row__label">Họ tên</span>
            <span className="profile-row__value">{profile.fullName}</span>
          </div>
          <div className="profile-row">
            <span className="profile-row__label">Tên đăng nhập</span>
            <span className="profile-row__value">{profile.username}</span>
          </div>
          <div className="profile-row">
            <span className="profile-row__label">Vai trò</span>
            <span className="profile-row__value">{roleLabel(profile)}</span>
          </div>
          <div className="profile-row">
            <span className="profile-row__label">Email</span>
            <span className="profile-row__value">{profile.email ?? '—'}</span>
          </div>
          <div className="profile-row">
            <span className="profile-row__label">Số điện thoại</span>
            <span className="profile-row__value">{profile.phoneNumber ?? '—'}</span>
          </div>
          <div className="profile-row">
            <span className="profile-row__label">Trạng thái</span>
            <span className="profile-row__value">
              {profile.isActive ? 'Đang hoạt động' : 'Đã khóa'}
            </span>
          </div>

          <div className="profile-actions">
            <Button variant="danger" onClick={() => setLogoutOpen(true)}>
              Đăng xuất
            </Button>
          </div>
        </div>
      )}

      <ConfirmDialog
        open={logoutOpen}
        title="Đăng xuất"
        message="Bạn có chắc muốn đăng xuất khỏi hệ thống quản trị?"
        confirmLabel="Đăng xuất"
        variant="danger"
        onConfirm={handleLogoutConfirm}
        onCancel={() => setLogoutOpen(false)}
      />
    </>
  )
}
