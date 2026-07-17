import type { TimetableSlot } from '../../slots/types'
import { WEEKDAY_COLUMNS, getStatusClass, getStatusLabel } from '../constants'
import { formatShortDate, getWeekDays, normalizeApiDate } from '../dateUtils'
import type { TimetableLesson } from '../types'

type WeekGridProps = {
  weekStart: Date
  slots: TimetableSlot[]
  lessons: TimetableLesson[]
  onCellClick: (date: string, slotId: number, lesson?: TimetableLesson) => void
}

/** Lưới lịch thực tế theo tuần — hàng = ca, cột = ngày */
export default function WeekGrid({ weekStart, slots, lessons, onCellClick }: WeekGridProps) {
  const weekDays = getWeekDays(weekStart)
  const sortedSlots = [...slots].sort((a, b) => a.startTime.localeCompare(b.startTime))

  function findLesson(date: Date, slot: TimetableSlot): TimetableLesson | undefined {
    const dateStr = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`
    return lessons.find(
      (l) => normalizeApiDate(l.date) === dateStr && l.slotName === slot.slotName,
    )
  }

  return (
    <div className="timetable-grid-wrap">
      <table className="timetable-grid">
        <thead>
          <tr>
            <th className="timetable-grid__slot-col">Ca</th>
            {weekDays.map((day, idx) => (
              <th key={idx}>
                <div>{WEEKDAY_COLUMNS[idx]?.short ?? ''}</div>
                <div className="timetable-grid__date">{formatShortDate(day)}</div>
              </th>
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
              {weekDays.map((day) => {
                const lesson = findLesson(day, slot)
                const dateStr = `${day.getFullYear()}-${String(day.getMonth() + 1).padStart(2, '0')}-${String(day.getDate()).padStart(2, '0')}`
                return (
                  <td key={dateStr}>
                    <button
                      type="button"
                      className={`timetable-cell ${lesson ? 'timetable-cell--filled' : 'timetable-cell--empty'}`}
                      onClick={() => onCellClick(dateStr, slot.slotId, lesson)}
                    >
                      {lesson ? (
                        <div className={`timetable-lesson ${getStatusClass(lesson.status)}`}>
                          <div className="timetable-lesson__subject">{lesson.subjectName}</div>
                          <div className="timetable-lesson__teacher">{lesson.teacherName}</div>
                          {lesson.roomName && (
                            <div className="timetable-lesson__room">{lesson.roomName}</div>
                          )}
                          <div className="timetable-lesson__status">
                            {getStatusLabel(lesson.status)}
                          </div>
                          {lesson.isAttendanceTaken && (
                            <div className="timetable-lesson__badge">Đã điểm danh</div>
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
