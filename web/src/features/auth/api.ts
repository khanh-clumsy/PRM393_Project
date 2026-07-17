import { apiRequest } from '../../core/api/client'
import type { AuthTokenDto } from './types'

/** Gọi API đăng nhập bằng số điện thoại và mật khẩu */
export function loginApi(phoneNumber: string, password: string) {
  return apiRequest<AuthTokenDto>('/api/auth/login', {
    method: 'POST',
    body: JSON.stringify({ phoneNumber, password }),
  })
}
