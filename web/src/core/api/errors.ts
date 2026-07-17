export function getApiErrorMessage(body: unknown, fallback: string): string {
  if (!body) return fallback
  if (typeof body === 'string' && body.trim()) return body
  if (typeof body !== 'object') return fallback
  const obj = body as Record<string, unknown>
  if (typeof obj.message === 'string' && obj.message.trim()) return obj.message
  if (typeof obj.detail === 'string' && obj.detail.trim()) return obj.detail
  if (obj.errors && typeof obj.errors === 'object') {
    const parts: string[] = []
    for (const [key, val] of Object.entries(obj.errors as Record<string, unknown>)) {
      if (Array.isArray(val)) parts.push(`${key}: ${val.join(', ')}`)
      else if (typeof val === 'string') parts.push(`${key}: ${val}`)
    }
    if (parts.length) return parts.join('; ')
  }
  if (typeof obj.title === 'string' && obj.title.trim()) return obj.title
  return fallback
}
