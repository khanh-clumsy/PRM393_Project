import { type FormEvent, useState } from 'react'
import { Navigate } from 'react-router-dom'
import { ApiError } from '../../core/api/client'
import { useAuth } from '../../core/auth/AuthContext'
import { roleHomePath } from '../../core/auth/roles'
import './login.css'

/** Trang đăng nhập web cho quản trị viên và giáo viên. */
export default function LoginPage() {
  const { login, isLoading, isAuthenticated, user } = useAuth()
  const [phoneNumber, setPhoneNumber] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState<string | null>(null)

  // Đã đăng nhập thì chuyển về đúng khu vực theo vai trò.
  if (isAuthenticated && user) {
    return <Navigate to={roleHomePath(user.roleName)} replace />
  }

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setError(null)

    const phone = phoneNumber.trim()
    if (!phone || !password) {
      setError('Vui lòng nhập số điện thoại và mật khẩu.')
      return
    }

    try {
      await login(phone, password)
    } catch (err) {
      if (err instanceof ApiError) {
        setError(err.message)
      } else if (err instanceof Error) {
        setError(err.message)
      } else {
        setError('Đăng nhập thất bại. Vui lòng thử lại.')
      }
    }
  }

  return (
    <div className="login-page">
      <div className="login-page__card">
        <header className="login-page__header">
          <div className="login-page__logo" aria-hidden="true">
            FS
          </div>
          <h1>FSchool Web</h1>
          <p>Đăng nhập bằng tài khoản quản trị viên hoặc giáo viên</p>
        </header>

        <form className="login-page__form" onSubmit={handleSubmit} noValidate>
          {error && (
            <div className="login-page__error" role="alert">
              {error}
            </div>
          )}

          <label className="login-page__field">
            <span>Số điện thoại</span>
            <input
              type="tel"
              name="phoneNumber"
              autoComplete="username"
              placeholder="VD: 0901234567"
              value={phoneNumber}
              onChange={(e) => setPhoneNumber(e.target.value)}
              disabled={isLoading}
            />
          </label>

          <label className="login-page__field">
            <span>Mật khẩu</span>
            <input
              type="password"
              name="password"
              autoComplete="current-password"
              placeholder="Nhập mật khẩu"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              disabled={isLoading}
            />
          </label>

          <button type="submit" className="login-page__submit" disabled={isLoading}>
            {isLoading ? 'Đang đăng nhập…' : 'Đăng nhập'}
          </button>
        </form>
      </div>
    </div>
  )
}
