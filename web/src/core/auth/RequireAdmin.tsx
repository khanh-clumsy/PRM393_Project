import RequireRole from './RequireRole'

/** Route guard: yêu cầu đăng nhập và vai trò Admin */
export default function RequireAdmin() {
  return <RequireRole allow={['Admin']} />
}
