import type { ReactNode } from 'react'

type EmptyStateProps = {
  title: string
  message?: string
  action?: ReactNode
}

/** Trạng thái danh sách rỗng */
export default function EmptyState({ title, message, action }: EmptyStateProps) {
  return (
    <div className="state-panel">
      <p className="state-panel__title">{title}</p>
      {message && <p className="state-panel__message">{message}</p>}
      {action}
    </div>
  )
}
