import RequireRole from './RequireRole'

/** Chặn truy cập nếu không phải quản trị viên. */
export default function RequireAdmin() {
  return <RequireRole allow={['Admin']} />
}
