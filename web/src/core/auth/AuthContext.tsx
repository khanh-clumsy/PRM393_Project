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
import { ADMIN_ROLE, TEACHER_ROLE, isAllowedWebRole, roleHomePath } from './roles'
import { tokenStorage } from './tokenStorage'

export const WEB_ACCESS_ERROR = 'Tài khoản không có quyền truy cập web.'

export type AuthContextValue = {
  user: UserDto | null
  isAuthenticated: boolean
  isAdmin: boolean
  isTeacher: boolean
  isLoading: boolean
  login: (phoneNumber: string, password: string) => Promise<void>
  logout: () => void
}

const AuthContext = createContext<AuthContextValue | null>(null)

type AuthProviderProps = {
  children: ReactNode
}

/** Cung cấp phiên đăng nhập web cho quản trị viên và giáo viên. */
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

        // Chỉ cho phép quản trị viên và giáo viên dùng web.
        if (!isAllowedWebRole(result.user.roleName)) {
          tokenStorage.clear()
          setUser(null)
          throw new Error(WEB_ACCESS_ERROR)
        }

        tokenStorage.setAccessToken(result.accessToken)
        tokenStorage.setRefreshToken(result.refreshToken)
        tokenStorage.setUser(result.user)
        setUser(result.user)
        navigate(roleHomePath(result.user.roleName), { replace: true })
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
      isTeacher: user?.roleName === TEACHER_ROLE,
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
