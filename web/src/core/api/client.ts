import { API_BASE_URL } from '../config/env'
import { tokenStorage } from '../auth/tokenStorage'
import { getApiErrorMessage } from './errors'

const PUBLIC_PATHS = [
  '/api/auth/login',
  '/api/auth/refresh',
  '/api/auth/forgot-password',
] as const

/** Lỗi API có status HTTP và body gốc từ server */
export class ApiError extends Error {
  readonly status: number
  readonly body: unknown

  constructor(message: string, status: number, body?: unknown) {
    super(message)
    this.name = 'ApiError'
    this.status = status
    this.body = body
  }
}

function isPublicPath(path: string): boolean {
  return PUBLIC_PATHS.some((p) => path.includes(p))
}

async function parseResponseBody(response: Response): Promise<unknown> {
  if (response.status === 204 || response.status === 205) {
    return undefined
  }

  const text = await response.text()
  if (!text.trim()) return undefined

  const contentType = response.headers.get('content-type')
  if (contentType?.includes('application/json')) {
    try {
      return JSON.parse(text) as unknown
    } catch {
      return text
    }
  }

  return text
}

let refreshPromise: Promise<boolean> | null = null

/** Gọi refresh token và lưu cặp token mới (giống mobile) */
async function tryRefreshToken(): Promise<boolean> {
  const refreshToken = tokenStorage.getRefreshToken()
  if (!refreshToken) return false

  try {
    const res = await fetch(`${API_BASE_URL}/api/auth/refresh`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ refreshToken }),
    })

    if (!res.ok) return false

    const body = (await parseResponseBody(res)) as Record<string, unknown> | undefined
    if (
      !body ||
      typeof body.accessToken !== 'string' ||
      typeof body.refreshToken !== 'string'
    ) {
      return false
    }

    tokenStorage.setAccessToken(body.accessToken)
    tokenStorage.setRefreshToken(body.refreshToken)
    return true
  } catch {
    return false
  }
}

async function handleRefresh(): Promise<boolean> {
  if (!refreshPromise) {
    refreshPromise = tryRefreshToken().finally(() => {
      refreshPromise = null
    })
  }
  return refreshPromise
}

async function doFetch(path: string, options: RequestInit = {}): Promise<Response> {
  const headers = new Headers(options.headers)
  if (!headers.has('Content-Type')) {
    headers.set('Content-Type', 'application/json')
  }

  // Public path không gắn Bearer
  if (!isPublicPath(path)) {
    const accessToken = tokenStorage.getAccessToken()
    if (accessToken) {
      headers.set('Authorization', `Bearer ${accessToken}`)
    }
  }

  return fetch(`${API_BASE_URL}${path}`, {
    ...options,
    headers,
  })
}

async function handleResponse<T>(response: Response, fallback: string): Promise<T> {
  const body = await parseResponseBody(response)

  if (response.status === 204) {
    return undefined as T
  }

  if (!response.ok) {
    throw new ApiError(getApiErrorMessage(body, fallback), response.status, body)
  }

  return body as T
}

export async function apiRequest<T>(
  path: string,
  options: RequestInit = {},
  isRetry = false,
): Promise<T> {
  const response = await doFetch(path, options)

  // 401 trên protected route → thử refresh một lần rồi retry
  if (response.status === 401 && !isPublicPath(path) && !isRetry) {
    const refreshed = await handleRefresh()
    if (refreshed) {
      return apiRequest<T>(path, options, true)
    }

    tokenStorage.clear()
    window.location.assign('/login')
    throw new ApiError('Phiên đăng nhập đã hết hạn.', 401)
  }

  return handleResponse<T>(response, `Yêu cầu thất bại (${response.status})`)
}
