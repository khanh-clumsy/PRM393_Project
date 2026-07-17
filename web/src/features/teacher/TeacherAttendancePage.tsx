import { useEffect, useMemo, useState } from 'react'
import { useSearchParams } from 'react-router-dom'
import Button from '../../components/ui/Button'
import DataTable, { type DataTableColumn } from '../../components/ui/DataTable'
import PageHeader from '../../components/ui/PageHeader'
import Spinner from '../../components/ui/Spinner'
import { useAuth } from '../../core/auth/AuthContext'
import {
  createAttendanceBulk,
  fetchAttendanceByTimetable,
  fetchClassStudents,
  fetchTeacherWeeklyTimetable,
  updateAttendanceBulk,
} from './api'
import type { AttendanceStatusCode, TeacherAttendanceEntry, TimetableLesson } from './types'
import { buildAttendanceEntries, getAttendanceStatusLabel } from './utils'

const STATUS_OPTIONS: Array<{ value: AttendanceStatusCode; label: string }> = [
  { value: 'P', label: 'Có mặt' },
  { value: 'A', label: 'Vắng' },
  { value: 'L', label: 'Muộn' },
]

function todayInput() {
  return new Date().toISOString().slice(0, 10)
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

function normalizeUiStatus(status: AttendanceStatusCode): AttendanceStatusCode {
  return status === 'E' ? 'A' : status
}

export default function TeacherAttendancePage() {
  const [searchParams, setSearchParams] = useSearchParams()
  const { user } = useAuth()
  const teacherId = user?.id
  const timetableIdParam = searchParams.get('timetableId') ?? ''
  const initialDate = searchParams.get('date') ?? todayInput()
  const initialTimetableId = Number(timetableIdParam)
  const [date, setDate] = useState(initialDate)
  const [dateInput, setDateInput] = useState(formatVietnameseDate(initialDate))
  const [lessons, setLessons] = useState<TimetableLesson[]>([])
  const [selectedTimetableId, setSelectedTimetableId] = useState<number | ''>(
    Number.isFinite(initialTimetableId) && initialTimetableId > 0 ? initialTimetableId : '',
  )
  const [entries, setEntries] = useState<TeacherAttendanceEntry[]>([])
  const [loadingLessons, setLoadingLessons] = useState(false)
  const [loadingStudents, setLoadingStudents] = useState(false)
  const [saving, setSaving] = useState(false)
  const [message, setMessage] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)

  const selectedLesson = useMemo(
    () => lessons.find((lesson) => lesson.timetableId === selectedTimetableId),
    [lessons, selectedTimetableId],
  )

  useEffect(() => {
    if (!teacherId) return
    const id = teacherId

    let ignore = false
    async function loadLessons() {
      setLoadingLessons(true)
      setError(null)
      setMessage(null)
      try {
        const data = await fetchTeacherWeeklyTimetable(id, date)
        const sameDay = data.filter((lesson) => lesson.date.slice(0, 10) === date)
        if (ignore) return
        setLessons(sameDay)
        const requestedTimetableId = Number(timetableIdParam)
        const requestedLesson = sameDay.find((lesson) => lesson.timetableId === requestedTimetableId)
        setSelectedTimetableId(requestedLesson?.timetableId ?? sameDay[0]?.timetableId ?? '')
      } catch (err) {
        if (!ignore) setError(err instanceof Error ? err.message : 'Không thể tải tiết dạy.')
      } finally {
        if (!ignore) setLoadingLessons(false)
      }
    }

    void loadLessons()
    return () => {
      ignore = true
    }
  }, [date, teacherId, timetableIdParam])

  useEffect(() => {
    if (!selectedLesson) {
      setEntries([])
      return
    }
    const lesson = selectedLesson

    let ignore = false
    async function loadStudents() {
      setLoadingStudents(true)
      setError(null)
      try {
        const [students, attendance] = await Promise.all([
          fetchClassStudents(lesson.classId),
          fetchAttendanceByTimetable(lesson.timetableId),
        ])
        if (!ignore) {
          setEntries(
            buildAttendanceEntries(students, attendance).map((entry) => ({
              ...entry,
              status: normalizeUiStatus(entry.status),
            })),
          )
        }
      } catch (err) {
        if (!ignore) setError(err instanceof Error ? err.message : 'Không thể tải danh sách điểm danh.')
      } finally {
        if (!ignore) setLoadingStudents(false)
      }
    }

    void loadStudents()
    return () => {
      ignore = true
    }
  }, [selectedLesson])

  function updateEntry(studentId: number, patch: Partial<TeacherAttendanceEntry>) {
    setEntries((current) =>
      current.map((entry) => (entry.studentId === studentId ? { ...entry, ...patch } : entry)),
    )
  }

  function markAll(status: AttendanceStatusCode) {
    setEntries((current) => current.map((entry) => ({ ...entry, status })))
  }

  async function save() {
    if (!selectedLesson || !teacherId) return

    setSaving(true)
    setError(null)
    setMessage(null)
    try {
      const toCreate = entries.filter((entry) => entry.attendanceId === null)
      const toUpdate = entries.filter((entry) => entry.attendanceId !== null)

      if (toCreate.length > 0) {
        await createAttendanceBulk(
          toCreate.map((entry) => ({
            timetableId: selectedLesson.timetableId,
            studentId: entry.studentId,
            status: entry.status,
            note: entry.note.trim() || null,
            recordedBy: teacherId,
          })),
        )
      }

      if (toUpdate.length > 0) {
        await updateAttendanceBulk(
          toUpdate.map((entry) => ({
            attendanceId: entry.attendanceId ?? 0,
            status: entry.status,
            note: entry.note.trim() || null,
          })),
        )
      }

      const attendance = await fetchAttendanceByTimetable(selectedLesson.timetableId)
      const students = await fetchClassStudents(selectedLesson.classId)
      setEntries(
        buildAttendanceEntries(students, attendance).map((entry) => ({
          ...entry,
          status: normalizeUiStatus(entry.status),
        })),
      )
      setMessage('Đã lưu điểm danh.')
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Không thể lưu điểm danh.')
    } finally {
      setSaving(false)
    }
  }

  const columns: DataTableColumn<TeacherAttendanceEntry>[] = [
    { key: 'order', header: 'STT', render: (_row, index) => index + 1 },
    { key: 'studentCode', header: 'Mã HS', render: (row) => row.studentCode ?? '-' },
    { key: 'studentName', header: 'Họ tên', render: (row) => row.studentName ?? `HS #${row.studentId}` },
    {
      key: 'status',
      header: 'Trạng thái',
      render: (row) => (
          <div className="teacher-radio-group" role="radiogroup" aria-label={`Trạng thái ${row.studentName ?? row.studentId}`}>
            {STATUS_OPTIONS.map((option) => (
              <label className="teacher-radio" key={option.value}>
                <input
                  type="radio"
                  name={`attendance-status-${row.studentId}`}
                  value={option.value}
                  checked={row.status === option.value}
                  onChange={() => updateEntry(row.studentId, { status: option.value })}
                />
                <span>{option.label}</span>
              </label>
            ))}
          </div>
      ),
    },
    {
      key: 'note',
      header: 'Ghi chú',
      render: (row) => (
        <input
          className="teacher-input-inline"
          value={row.note}
          onChange={(event) => updateEntry(row.studentId, { note: event.target.value })}
          placeholder="Ghi chú"
        />
      ),
    },
  ]

  const summary = STATUS_OPTIONS.map((option) => ({
    ...option,
    count: entries.filter((entry) => entry.status === option.value).length,
  }))

  return (
    <>
      <PageHeader
        title="Điểm danh"
        subtitle="Cập nhật chuyên cần theo tiết dạy."
        actions={
          <Button
            loading={saving}
            disabled={!selectedLesson || entries.length === 0}
            onClick={save}
          >
            Lưu điểm danh
          </Button>
        }
      />

      <div className="ui-filters">
        <div className="ui-field">
          <label htmlFor="attendance-date">Ngày</label>
          <input
            id="attendance-date"
            value={dateInput}
            onChange={(event) => {
              const nextInput = event.target.value
              setDateInput(nextInput)

              const nextDate = parseVietnameseDate(nextInput)
              if (!nextDate) return

              setDate(nextDate)
              setSearchParams({ date: nextDate })
            }}
            placeholder="17/07/2026"
            inputMode="numeric"
          />
        </div>
        <div className="ui-field">
          <label htmlFor="attendance-slot">Tiết dạy</label>
          <select
            id="attendance-slot"
            value={selectedTimetableId}
            onChange={(event) => {
              const next = Number(event.target.value) || ''
              setSelectedTimetableId(next)
              setSearchParams(
                next ? { date, timetableId: String(next) } : { date },
              )
            }}
          >
            <option value="">Chọn tiết</option>
            {lessons.map((lesson) => (
              <option key={lesson.timetableId} value={lesson.timetableId}>
                {lesson.slotName} · {lesson.className} · {lesson.subjectName}
              </option>
            ))}
          </select>
        </div>
      </div>

      {message && <p className="teacher-success">{message}</p>}
      {error && <p className="teacher-alert">{error}</p>}

      <div className="teacher-toolbar">
        {summary.map((item) => (
          <span className="teacher-pill" key={item.value}>
            {item.label}: {item.count}
          </span>
        ))}
        <Button size="sm" variant="secondary" disabled={entries.length === 0} onClick={() => markAll('P')}>
          Tất cả có mặt
        </Button>
      </div>

      {loadingLessons || loadingStudents ? (
        <div className="state-panel">
          <Spinner />
          <p className="state-panel__message">Đang tải điểm danh...</p>
        </div>
      ) : (
        <DataTable
          columns={columns}
          data={entries}
          rowKey={(row) => row.studentId}
          emptyMessage={
            selectedLesson
              ? 'Lớp chưa có học sinh.'
              : `Không có tiết dạy để điểm danh (${getAttendanceStatusLabel('P')}).`
          }
        />
      )}
    </>
  )
}
