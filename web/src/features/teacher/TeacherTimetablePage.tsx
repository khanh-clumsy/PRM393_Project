import { useEffect, useMemo, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import Button from '../../components/ui/Button'
import EmptyState from '../../components/ui/EmptyState'
import PageHeader from '../../components/ui/PageHeader'
import Spinner from '../../components/ui/Spinner'
import { useAuth } from '../../core/auth/AuthContext'
import type { TimetableSlot } from '../slots/types'
import { WEEKDAY_COLUMNS } from '../timetables/constants'
import { formatDateISO, formatShortDate, getMondayOfWeek, getWeekDays } from '../timetables/dateUtils'
import { fetchTeacherSlots, fetchTeacherWeeklyTimetable } from './api'
import type { TimetableLesson } from './types'
import '../timetables/timetable.css'

function todayInput() {
  return new Date().toISOString().slice(0, 10)
}

function normalizeDate(value: string) {
  return value.slice(0, 10)
}

function formatVietnameseDate(value: string) {
  const [year, month, day] = value.split('-')
  if (!year || !month || !day) return value
  return `${day}/${month}/${year}`
}

function parseVietnameseDate(value: string) {
  const match = value.trim().match(/^(\d{1,2})\/(\d{1,2})\/(\d{4})$/)
  if (!match) return null

  const [, dayValue, monthValue, yearValue] = match
  const day = Number(dayValue)
  const month = Number(monthValue)
  const year = Number(yearValue)
  const parsed = new Date(year, month - 1, day)

  if (
    parsed.getFullYear() !== year ||
    parsed.getMonth() !== month - 1 ||
    parsed.getDate() !== day
  ) {
    return null
  }

  return `${yearValue}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`
}

export default function TeacherTimetablePage() {
  const navigate = useNavigate()
  const { user } = useAuth()
  const teacherId = user?.id
  const [date, setDate] = useState(todayInput)
  const [dateInput, setDateInput] = useState(formatVietnameseDate(todayInput()))
  const [lessons, setLessons] = useState<TimetableLesson[]>([])
  const [slots, setSlots] = useState<TimetableSlot[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const weekStart = useMemo(() => getMondayOfWeek(new Date(date)), [date])
  const weekDays = useMemo(() => getWeekDays(weekStart), [weekStart])
  const sortedSlots = useMemo(
    () => [...slots].sort((a, b) => a.startTime.localeCompare(b.startTime)),
    [slots],
  )

  useEffect(() => {
    if (!teacherId) return
    const id = teacherId

    let ignore = false
    async function load() {
      setLoading(true)
      setError(null)
      try {
        const [slotData, lessonData] = await Promise.all([
          fetchTeacherSlots(),
          fetchTeacherWeeklyTimetable(id, date),
        ])
        if (ignore) return
        setSlots(slotData)
        setLessons(lessonData)
      } catch (err) {
        if (!ignore) setError(err instanceof Error ? err.message : 'Không thể tải thời khóa biểu.')
      } finally {
        if (!ignore) setLoading(false)
      }
    }

    void load()
    return () => {
      ignore = true
    }
  }, [date, teacherId])

  function shiftWeek(delta: number) {
    const next = new Date(weekStart)
    next.setDate(next.getDate() + delta * 7)
    const nextDate = formatDateISO(next)
    setDate(nextDate)
    setDateInput(formatVietnameseDate(nextDate))
  }

  function chooseDate(nextDate: string) {
    setDate(nextDate)
    setDateInput(formatVietnameseDate(nextDate))
  }

  function findLesson(day: Date, slot: TimetableSlot) {
    const dayValue = formatDateISO(day)
    return lessons.find(
      (lesson) => normalizeDate(lesson.date) === dayValue && lesson.slotName === slot.slotName,
    )
  }

  function openAttendance(lesson: TimetableLesson) {
    navigate(
      `/teacher/attendance?date=${encodeURIComponent(normalizeDate(lesson.date))}&timetableId=${lesson.timetableId}`,
    )
  }

  return (
    <>
      <PageHeader
        title="Thời khóa biểu"
        subtitle="Bấm vào tiết dạy để mở điểm danh."
      />

      <div className="ui-filters">
        <div className="ui-field">
          <label htmlFor="teacher-week-date">Tuần chứa ngày</label>
          <input
            id="teacher-week-date"
            value={dateInput}
            onChange={(event) => {
              const nextInput = event.target.value
              setDateInput(nextInput)

              const nextDate = parseVietnameseDate(nextInput)
              if (nextDate) setDate(nextDate)
            }}
            placeholder="17/07/2026"
            inputMode="numeric"
          />
        </div>
      </div>

      <div className="timetable-week-nav">
        <Button size="sm" variant="secondary" onClick={() => shiftWeek(-1)} disabled={loading}>
          ← Tuần trước
        </Button>
        <span className="timetable-week-nav__label">
          {formatShortDate(weekDays[0])} – {formatShortDate(weekDays[6])}
        </span>
        <Button size="sm" variant="secondary" onClick={() => shiftWeek(1)} disabled={loading}>
          Tuần sau →
        </Button>
        <Button size="sm" variant="ghost" onClick={() => chooseDate(todayInput())} disabled={loading}>
          Tuần này
        </Button>
      </div>

      {loading ? (
        <div className="state-panel">
          <Spinner />
          <p className="state-panel__message">Đang tải thời khóa biểu...</p>
        </div>
      ) : error ? (
        <div className="state-panel state-panel--error">
          <p className="state-panel__title">Không thể tải dữ liệu</p>
          <p className="state-panel__message">{error}</p>
        </div>
      ) : sortedSlots.length === 0 ? (
        <EmptyState title="Chưa có ca học" message="Chưa có dữ liệu ca học để hiển thị thời khóa biểu." />
      ) : (
        <div className="timetable-grid-wrap">
          <table className="timetable-grid">
            <thead>
              <tr>
                <th className="timetable-grid__slot-col">Ca</th>
                {weekDays.map((day, index) => (
                  <th key={formatDateISO(day)}>
                    <div>{WEEKDAY_COLUMNS[index]?.short ?? ''}</div>
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
                    return (
                      <td key={`${slot.slotId}-${formatDateISO(day)}`}>
                        {lesson ? (
                          <button
                            type="button"
                            className="timetable-cell timetable-cell--filled"
                            onClick={() => openAttendance(lesson)}
                          >
                            <div className="timetable-lesson">
                              <div className="timetable-lesson__subject">{lesson.subjectName}</div>
                              <div className="timetable-lesson__teacher">{lesson.className}</div>
                              {lesson.roomName && (
                                <div className="timetable-lesson__room">{lesson.roomName}</div>
                              )}
                              <div className="timetable-lesson__status">
                                {lesson.isAttendanceTaken ? 'Đã điểm danh' : 'Chưa điểm danh'}
                              </div>
                            </div>
                          </button>
                        ) : (
                          <div className="timetable-cell timetable-cell--empty">
                            <span className="timetable-cell__add">Trống</span>
                          </div>
                        )}
                      </td>
                    )
                  })}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </>
  )
}
