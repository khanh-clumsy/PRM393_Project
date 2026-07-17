import {
  createContext,
  useCallback,
  useContext,
  useMemo,
  useState,
  type ReactNode,
} from 'react'
import { useNavigate } from 'react-router-dom'
import { loginApi } from '../../features/auth/api'
import type { UserDto } from '../../features/auth/types'
import { tokenStorage } from './tokenStorage'

const ADMIN_ROLE = 'Admin'
export const NON_ADMIN_ERROR = 'Tài khoản không có quyền Admin web.'

export type AuthContextValue = {
  user: UserDto | null
  isAuthenticated: boolean
  isAdmin: boolean
  isLoading: boolean
  login: (phoneNumber: string, password: string) => Promise<void>
  logout: () => void
}

const AuthContext = createContext<AuthContextValue | null>(null)

type AuthProviderProps = {
  children: ReactNode
}

/** Cung cấp session đăng nhập Admin cho toàn app */
export function AuthProvider({ children }: AuthProviderProps) {
  const navigate = useNavigate()
  const [user, setUser] = useState<UserDto | null>(() =>
    tokenStorage.getUser<UserDto>(),
  )
  const [isLoading, setIsLoading] = useState(false)

  const login = useCallback(
    async (phoneNumber: string, password: string) => {
      setIsLoading(true)
      try {
        const result = await loginApi(phoneNumber, password)

        // Chỉ cho phép vai trò Admin vào web quản trị
        if (result.user.roleName !== ADMIN_ROLE) {
          tokenStorage.clear()
          setUser(null)
          throw new Error(NON_ADMIN_ERROR)
        }

        tokenStorage.setAccessToken(result.accessToken)
        tokenStorage.setRefreshToken(result.refreshToken)
        tokenStorage.setUser(result.user)
        setUser(result.user)
        navigate('/admin', { replace: true })
      } finally {
        setIsLoading(false)
      }
    },
    [navigate],
  )

  const logout = useCallback(() => {
    tokenStorage.clear()
    setUser(null)
    navigate('/login', { replace: true })
  }, [navigate])

  const value = useMemo<AuthContextValue>(
    () => ({
      user,
      isAuthenticated: !!tokenStorage.getAccessToken() && user !== null,
      isAdmin: user?.roleName === ADMIN_ROLE,
      isLoading,
      login,
      logout,
    }),
    [user, isLoading, login, logout],
  )

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

/** Hook truy cập auth — bắt buộc bọc trong AuthProvider */
export function useAuth(): AuthContextValue {
  const ctx = useContext(AuthContext)
  if (!ctx) {
    throw new Error('useAuth phải được dùng bên trong AuthProvider')
  }
  return ctx
}
