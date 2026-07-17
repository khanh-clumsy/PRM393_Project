import { STATUS_OPTIONS } from '../constants'

type StatusMenuProps = {
  status: number
  disabled?: boolean
  onChange: (status: number) => void
}

/** Chọn trạng thái tiết học */
export default function StatusMenu({ status, disabled, onChange }: StatusMenuProps) {
  return (
    <div className="ui-field" style={{ marginBottom: 0 }}>
      <label htmlFor="lesson-status">Trạng thái</label>
      <select
        id="lesson-status"
        value={status}
        disabled={disabled}
        onChange={(e) => onChange(Number(e.target.value))}
      >
        {STATUS_OPTIONS.map((opt) => (
          <option key={opt.value} value={opt.value}>
            {opt.label}
          </option>
        ))}
      </select>
    </div>
  )
}
