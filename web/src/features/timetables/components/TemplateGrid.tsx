import type { TimetableSlot } from '../../slots/types'
import { WEEKDAY_COLUMNS, getStatusClass } from '../constants'
import type { TimetableTemplate } from '../types'

type TemplateGridProps = {
  slots: TimetableSlot[]
  templates: TimetableTemplate[]
  onCellClick: (dayOfWeek: number, slotId: number, template?: TimetableTemplate) => void
}

/** Lưới lịch mẫu — hàng = ca, cột = thứ */
export default function TemplateGrid({ slots, templates, onCellClick }: TemplateGridProps) {
  const sortedSlots = [...slots].sort((a, b) => a.startTime.localeCompare(b.startTime))

  function findTemplate(dayOfWeek: number, slotId: number): TimetableTemplate | undefined {
    return templates.find((t) => t.dayOfWeek === dayOfWeek && t.slotId === slotId)
  }

  return (
    <div className="timetable-grid-wrap">
      <table className="timetable-grid">
        <thead>
          <tr>
            <th className="timetable-grid__slot-col">Ca</th>
            {WEEKDAY_COLUMNS.map((col) => (
              <th key={col.dayOfWeek}>{col.short}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {sortedSlots.map((slot) => (
            <tr key={slot.slotId}>
              <td className="timetable-grid__slot-col">
                <div className="timetable-grid__slot-name">{slot.slotName}</div>
                <div className="timetable-grid__slot-time">
                  {slot.startTime.slice(0, 5)}–{slot.endTime.slice(0, 5)}
                </div>
              </td>
              {WEEKDAY_COLUMNS.map((col) => {
                const tpl = findTemplate(col.dayOfWeek, slot.slotId)
                return (
                  <td key={col.dayOfWeek}>
                    <button
                      type="button"
                      className={`timetable-cell ${tpl ? 'timetable-cell--filled' : 'timetable-cell--empty'}`}
                      onClick={() => onCellClick(col.dayOfWeek, slot.slotId, tpl)}
                    >
                      {tpl ? (
                        <div className={`timetable-lesson ${getStatusClass(1)}`}>
                          <div className="timetable-lesson__subject">{tpl.subjectName}</div>
                          <div className="timetable-lesson__teacher">{tpl.teacherName}</div>
                          {tpl.roomName && (
                            <div className="timetable-lesson__room">{tpl.roomName}</div>
                          )}
                        </div>
                      ) : (
                        <span className="timetable-cell__add">+ Thêm</span>
                      )}
                    </button>
                  </td>
                )
              })}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
