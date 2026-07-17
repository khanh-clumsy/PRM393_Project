import { useEffect, useMemo, useState } from 'react'
import PageHeader from '../../components/ui/PageHeader'
import Spinner from '../../components/ui/Spinner'
import { useAuth } from '../../core/auth/AuthContext'
import { fetchTeacherClasses, fetchTeacherWeeklyTimetable } from './api'
import type { TeacherClass, TimetableLesson } from './types'

function toDateInputValue(date: Date) {
  return date.toISOString().slice(0, 10)
}

export default function TeacherDashboardPage() {
  const { user } = useAuth()
  const teacherId = user?.id
  const [classes, setClasses] = useState<TeacherClass[]>([])
  const [todayLessons, setTodayLessons] = useState<TimetableLesson[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (!teacherId) return
    const id = teacherId

    let ignore = false
    async function load() {
      setLoading(true)
      setError(null)
      try {
        const today = toDateInputValue(new Date())
        const [classList, weekLessons] = await Promise.all([
          fetchTeacherClasses(id),
          fetchTeacherWeeklyTimetable(id, today),
        ])
        if (ignore) return
        setClasses(classList)
        setTodayLessons(weekLessons.filter((lesson) => lesson.date.slice(0, 10) === today))
      } catch (err) {
        if (!ignore) setError(err instanceof Error ? err.message : 'Không thể tải dữ liệu.')
      } finally {
        if (!ignore) setLoading(false)
      }
    }

    void load()
    return () => {
      ignore = true
    }
  }, [teacherId])

  const stats = useMemo(
    () => [
      { label: 'Lớp giảng dạy', value: classes.filter((cls) => cls.role !== 'homeroom').length },
      { label: 'Lớp chủ nhiệm', value: classes.filter((cls) => cls.role !== 'teaching').length },
      { label: 'Tiết dạy hôm nay', value: todayLessons.length },
      { label: 'Tiết đã điểm danh', value: todayLessons.filter((lesson) => lesson.isAttendanceTaken).length },
    ],
    [classes, todayLessons],
  )

  return (
    <>
      <PageHeader
        title="Tổng quan giáo viên"
        subtitle="Lịch dạy, lớp phụ trách và các việc cần xử lý trong ngày."
      />

      {loading ? (
        <div className="state-panel">
          <Spinner />
          <p className="state-panel__message">Đang tải tổng quan...</p>
        </div>
      ) : error ? (
        <div className="state-panel state-panel--error">
          <p className="state-panel__title">Có lỗi xảy ra</p>
          <p className="state-panel__message">{error}</p>
        </div>
      ) : (
        <>
          <div className="stat-grid teacher-stat-grid">
            {stats.map((item) => (
              <div className="stat-card" key={item.label}>
                <p className="stat-card__label">{item.label}</p>
                <p className="stat-card__value">{item.value}</p>
              </div>
            ))}
          </div>

          <section className="teacher-section">
            <h2>Tiết dạy hôm nay</h2>
            {todayLessons.length === 0 ? (
              <p className="teacher-muted">Không có tiết dạy trong hôm nay.</p>
            ) : (
              <div className="teacher-list">
                {todayLessons.map((lesson) => (
                  <div className="teacher-list__item" key={lesson.timetableId}>
                    <div>
                      <strong>{lesson.className}</strong>
                      <p>{lesson.subjectName}</p>
                    </div>
                    <span>
                      {lesson.slotName} · {lesson.startTime}-{lesson.endTime}
                    </span>
                  </div>
                ))}
              </div>
            )}
          </section>
        </>
      )}
    </>
  )
}
