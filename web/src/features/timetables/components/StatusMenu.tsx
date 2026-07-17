import { STATUS_OPTIONS, getStatusClass, getStatusLabel } from '../constants'

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
        className={`timetable-status-select ${getStatusClass(status)}`}
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
      <span className={`timetable-status-badge ${getStatusClass(status)}`}>
        {getStatusLabel(status)}
      </span>
    </div>
  )
}

export { getStatusClass, getStatusLabel }
