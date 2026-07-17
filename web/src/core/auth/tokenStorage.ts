const KEY_ACCESS = 'fs_access_token'
const KEY_REFRESH = 'fs_refresh_token'
const KEY_USER = 'fs_user_json'

export const tokenStorage = {
  getAccessToken(): string | null {
    return localStorage.getItem(KEY_ACCESS)
  },

  setAccessToken(token: string): void {
    localStorage.setItem(KEY_ACCESS, token)
  },

  getRefreshToken(): string | null {
    return localStorage.getItem(KEY_REFRESH)
  },

  setRefreshToken(token: string): void {
    localStorage.setItem(KEY_REFRESH, token)
  },

  getUser<T = unknown>(): T | null {
    const raw = localStorage.getItem(KEY_USER)
    if (!raw) return null
    try {
      return JSON.parse(raw) as T
    } catch {
      return null
    }
  },

  setUser(user: unknown): void {
    localStorage.setItem(KEY_USER, JSON.stringify(user))
  },

  clear(): void {
    localStorage.removeItem(KEY_ACCESS)
    localStorage.removeItem(KEY_REFRESH)
    localStorage.removeItem(KEY_USER)
  },
}
