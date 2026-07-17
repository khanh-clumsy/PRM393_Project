type SpinnerProps = {
  size?: 'md' | 'lg'
}

/** Vòng quay loading */
export default function Spinner({ size = 'md' }: SpinnerProps) {
  return (
    <span
      className={`ui-spinner${size === 'lg' ? ' ui-spinner--lg' : ''}`}
      role="status"
      aria-label="Đang tải"
    />
  )
}
