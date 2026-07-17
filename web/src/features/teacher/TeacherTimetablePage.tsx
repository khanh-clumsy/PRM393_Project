import { useEffect, useMemo, useState } from 'react'
import DataTable, { type DataTableColumn } from '../../components/ui/DataTable'
import PageHeader from '../../components/ui/PageHeader'
import Spinner from '../../components/ui/Spinner'
import { useAuth } from '../../core/auth/AuthContext'
import { fetchTeacherWeeklyTimetable } from './api'
import type { TimetableLesson } from './types'

function todayInput() {
  return new Date().toISOString().slice(0, 10)
}

export default function TeacherTimetablePage() {
  const { user } = useAuth()
  const teacherId = user?.id
  const [date, setDate] = useState(todayInput)
  const [lessons, setLessons] = useState<TimetableLesson[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (!teacherId) return
    const id = teacherId

    let ignore = false
    async function load() {
      setLoading(true)
      setError(null)
      try {
        const data = await fetchTeacherWeeklyTimetable(id, date)
        if (!ignore) setLessons(data)
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

  const columns = useMemo<DataTableColumn<TimetableLesson>[]>(
    () => [
      { key: 'date', header: 'Ngày', render: (row) => row.date.slice(0, 10) },
      { key: 'slotName', header: 'Tiết' },
      { key: 'time', header: 'Giờ', render: (row) => `${row.startTime}-${row.endTime}` },
      { key: 'className', header: 'Lớp' },
      { key: 'subjectName', header: 'Môn học' },
      { key: 'roomName', header: 'Phòng', render: (row) => row.roomName ?? '-' },
      {
        key: 'attendance',
        header: 'Điểm danh',
        render: (row) => (row.isAttendanceTaken ? 'Đã điểm danh' : 'Chưa điểm danh'),
      },
    ],
    [],
  )

  return (
    <>
      <PageHeader
        title="Thời khóa biểu"
        subtitle="Lịch dạy theo tuần của giáo viên, chỉ đọc."
      />

      <div className="ui-filters">
        <div className="ui-field">
          <label htmlFor="teacher-week-date">Tuần chứa ngày</label>
          <input
            id="teacher-week-date"
            type="date"
            value={date}
            onChange={(event) => setDate(event.target.value)}
          />
        </div>
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
      ) : (
        <DataTable
          columns={columns}
          data={lessons}
          rowKey={(row) => row.timetableId}
          emptyMessage="Không có tiết dạy trong tuần này."
        />
      )}
    </>
  )
}
