import { useEffect, useMemo, useState } from 'react'
import Button from '../../components/ui/Button'
import DataTable, { type DataTableColumn } from '../../components/ui/DataTable'
import PageHeader from '../../components/ui/PageHeader'
import Spinner from '../../components/ui/Spinner'
import { useAuth } from '../../core/auth/AuthContext'
import {
  createAttendanceBulk,
  fetchAttendanceByTimetable,
  fetchClassRoster,
  fetchTeacherWeeklyTimetable,
  updateAttendanceBulk,
} from './api'
import type { AttendanceStatusCode, TeacherAttendanceEntry, TimetableLesson } from './types'
import { buildAttendanceEntries, getAttendanceStatusLabel } from './utils'

const STATUS_OPTIONS: Array<{ value: AttendanceStatusCode; label: string }> = [
  { value: 'P', label: 'Có mặt' },
  { value: 'A', label: 'Vắng' },
  { value: 'L', label: 'Muộn' },
  { value: 'E', label: 'Có phép' },
]

function todayInput() {
  return new Date().toISOString().slice(0, 10)
}

export default function TeacherAttendancePage() {
  const { user } = useAuth()
  const teacherId = user?.id
  const [date, setDate] = useState(todayInput)
  const [lessons, setLessons] = useState<TimetableLesson[]>([])
  const [selectedTimetableId, setSelectedTimetableId] = useState<number | ''>('')
  const [entries, setEntries] = useState<TeacherAttendanceEntry[]>([])
  const [loadingLessons, setLoadingLessons] = useState(false)
  const [loadingRoster, setLoadingRoster] = useState(false)
  const [saving, setSaving] = useState(false)
  const [message, setMessage] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)

  const selectedLesson = useMemo(
    () => lessons.find((lesson) => lesson.timetableId === selectedTimetableId),
    [lessons, selectedTimetableId],
  )
  const isToday = date === todayInput()

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
        setSelectedTimetableId(sameDay[0]?.timetableId ?? '')
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
  }, [date, teacherId])

  useEffect(() => {
    if (!selectedLesson) {
      setEntries([])
      return
    }
    const lesson = selectedLesson

    let ignore = false
    async function loadRoster() {
      setLoadingRoster(true)
      setError(null)
      try {
        const [roster, attendance] = await Promise.all([
          fetchClassRoster(lesson.classId),
          fetchAttendanceByTimetable(lesson.timetableId),
        ])
        if (!ignore) setEntries(buildAttendanceEntries(roster, attendance))
      } catch (err) {
        if (!ignore) setError(err instanceof Error ? err.message : 'Không thể tải roster điểm danh.')
      } finally {
        if (!ignore) setLoadingRoster(false)
      }
    }

    void loadRoster()
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
    if (!selectedLesson || !teacherId || !isToday) return

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
      const roster = await fetchClassRoster(selectedLesson.classId)
      setEntries(buildAttendanceEntries(roster, attendance))
      setMessage('Đã lưu điểm danh.')
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Không thể lưu điểm danh.')
    } finally {
      setSaving(false)
    }
  }

  const columns: DataTableColumn<TeacherAttendanceEntry>[] = [
    { key: 'studentCode', header: 'Mã HS', render: (row) => row.studentCode ?? '-' },
    { key: 'studentName', header: 'Họ tên', render: (row) => row.studentName ?? `HS #${row.studentId}` },
    {
      key: 'status',
      header: 'Trạng thái',
      render: (row) => (
        <select
          className="ui-select teacher-select-inline"
          value={row.status}
          onChange={(event) =>
            updateEntry(row.studentId, { status: event.target.value as AttendanceStatusCode })
          }
          disabled={!isToday}
          aria-label={`Trạng thái ${row.studentName ?? row.studentId}`}
        >
          {STATUS_OPTIONS.map((option) => (
            <option key={option.value} value={option.value}>
              {option.label}
            </option>
          ))}
        </select>
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
          disabled={!isToday}
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
        subtitle="Chọn ngày và tiết dạy của giáo viên để cập nhật chuyên cần."
        actions={
          <Button
            loading={saving}
            disabled={!selectedLesson || entries.length === 0 || !isToday}
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
            type="date"
            value={date}
            onChange={(event) => setDate(event.target.value)}
          />
        </div>
        <div className="ui-field">
          <label htmlFor="attendance-slot">Tiết dạy</label>
          <select
            id="attendance-slot"
            value={selectedTimetableId}
            onChange={(event) => setSelectedTimetableId(Number(event.target.value) || '')}
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

      {!isToday && (
        <p className="teacher-alert">Theo mobile, giáo viên chỉ được lưu điểm danh trong ngày hôm nay.</p>
      )}
      {message && <p className="teacher-success">{message}</p>}
      {error && <p className="teacher-alert">{error}</p>}

      <div className="teacher-toolbar">
        {summary.map((item) => (
          <span className="teacher-pill" key={item.value}>
            {item.label}: {item.count}
          </span>
        ))}
        <Button size="sm" variant="secondary" disabled={!isToday || entries.length === 0} onClick={() => markAll('P')}>
          Tất cả có mặt
        </Button>
      </div>

      {loadingLessons || loadingRoster ? (
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
