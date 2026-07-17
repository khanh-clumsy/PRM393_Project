import { type ReactNode, useEffect } from 'react'

type ModalProps = {
  open: boolean
  title: string
  onClose: () => void
  children: ReactNode
  footer?: ReactNode
}

/** Hộp thoại modal cơ bản — đóng bằng nút X hoặc overlay */
export default function Modal({
  open,
  title,
  onClose,
  children,
  footer,
}: ModalProps) {
  // Khóa scroll nền khi modal mở
  useEffect(() => {
    if (!open) return
    const prev = document.body.style.overflow
    document.body.style.overflow = 'hidden'
    return () => {
      document.body.style.overflow = prev
    }
  }, [open])

  if (!open) return null

  return (
    <div
      className="ui-modal-overlay"
      role="presentation"
      onClick={(e) => {
        if (e.target === e.currentTarget) onClose()
      }}
    >
      <div className="ui-modal" role="dialog" aria-modal="true" aria-labelledby="modal-title">
        <div className="ui-modal__header">
          <h2 id="modal-title" className="ui-modal__title">
            {title}
          </h2>
          <button
            type="button"
            className="ui-modal__close"
            onClick={onClose}
            aria-label="Đóng"
          >
            ×
          </button>
        </div>
        <div className="ui-modal__body">{children}</div>
        {footer && <div className="ui-modal__footer">{footer}</div>}
      </div>
    </div>
  )
}
