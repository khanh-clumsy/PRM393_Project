import { apiRequest } from '../../core/api/client'

/** Lấy số lượng tài khoản, lớp, môn học cho dashboard */
export async function fetchDashboardStats() {
  const [users, classes, subjects] = await Promise.all([
    apiRequest<unknown[]>('/api/user'),
    apiRequest<unknown[]>('/api/class'),
    apiRequest<unknown[]>('/api/subject'),
  ])

  return {
    userCount: users.length,
    classCount: classes.length,
    subjectCount: subjects.length,
  }
}
