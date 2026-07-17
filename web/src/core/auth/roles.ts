export type AppRole = 'Admin' | 'Teacher'

export const ADMIN_ROLE: AppRole = 'Admin'
export const TEACHER_ROLE: AppRole = 'Teacher'

export function roleHomePath(roleName: string): string {
  if (roleName === ADMIN_ROLE) return '/admin'
  if (roleName === TEACHER_ROLE) return '/teacher'
  return '/login'
}

export function isAllowedWebRole(roleName: string): roleName is AppRole {
  return roleName === ADMIN_ROLE || roleName === TEACHER_ROLE
}
