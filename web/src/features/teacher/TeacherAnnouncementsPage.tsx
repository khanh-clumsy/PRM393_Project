import { useEffect, useMemo, useState, type FormEvent } from 'react'
import Button from '../../components/ui/Button'
import DataTable, { type DataTableColumn } from '../../components/ui/DataTable'
import PageHeader from '../../components/ui/PageHeader'
import Spinner from '../../components/ui/Spinner'
import { useAuth } from '../../core/auth/AuthContext'
import {
  createTeacherAnnouncement,
  fetchTeacherAcademicYears,
  fetchTeacherAnnouncements,
  fetchTeacherAssignments,
  fetchTeacherSemesters,
} from './api'
import type { AcademicYear } from '../academic-years/types'
import type { Semester } from '../semesters/types'
import type { Announcement, TeachingAssignment } from './types'
import {
  getAssignmentsForSemester,
  getPreferredAcademicYearId,
  getSemestersForYear,
  sortAcademicYears,
} from './utils'

export default function TeacherAnnouncementsPage() {
  const { user } = useAuth()
  const teacherId = user?.id
  const [academicYears, setAcademicYears] = useState<AcademicYear[]>([])
  const [semesters, setSemesters] = useState<Semester[]>([])
  const [assignments, setAssignments] = useState<TeachingAssignment[]>([])
  const [announcements, setAnnouncements] = useState<Announcement[]>([])
  const [yearId, setYearId] = useState<number | ''>('')
  const [semesterId, setSemesterId] = useState<number | ''>('')
  const [assignmentId, setAssignmentId] = useState<number | ''>('')
  const [title, setTitle] = useState('')
  const [content, setContent] = useState('')
  const [priority, setPriority] = useState('normal')
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [message, setMessage] = useState<string | null>(null)

  useEffect(() => {
    if (!teacherId) return
    const id = teacherId

    let ignore = false
    async function load() {
      setLoading(true)
      setError(null)
      try {
        const [assignmentData, feed, yearData, semesterData] = await Promise.all([
          fetchTeacherAssignments(id),
          fetchTeacherAnnouncements(),
          fetchTeacherAcademicYears(),
          fetchTeacherSemesters(),
        ])
        if (ignore) return

        const sortedYears = sortAcademicYears(yearData)
        const defaultYear = getPreferredAcademicYearId(sortedYears)
        const defaultSemester = getSemestersForYear(semesterData, defaultYear)[0]?.semesterId ?? ''

        setAssignments(assignmentData)
        setAnnouncements(feed)
        setAcademicYears(sortedYears)
        setSemesters(semesterData)
        setYearId(defaultYear)
        setSemesterId(defaultSemester)
      } catch (err) {
        if (!ignore) setError(err instanceof Error ? err.message : 'Không thể tải bảng tin.')
      } finally {
        if (!ignore) setLoading(false)
      }
    }

    void load()
    return () => {
      ignore = true
    }
  }, [teacherId])

  const filteredSemesters = useMemo(
    () => getSemestersForYear(semesters, yearId),
    [semesters, yearId],
  )
  const filteredAssignments = useMemo(
    () => getAssignmentsForSemester(assignments, semesterId),
    [assignments, semesterId],
  )
  const selectedAssignment = useMemo(
    () => assignments.find((assignment) => assignment.teachingAssignmentId === assignmentId),
    [assignmentId, assignments],
  )

  useEffect(() => {
    const nextSemester = filteredSemesters[0]?.semesterId ?? ''
    setSemesterId((current) =>
      current !== '' && filteredSemesters.some((semester) => semester.semesterId === current)
        ? current
        : nextSemester,
    )
  }, [filteredSemesters])

  useEffect(() => {
    const nextAssignment = filteredAssignments[0]?.teachingAssignmentId ?? ''
    setAssignmentId((current) =>
      current !== '' && filteredAssignments.some((assignment) => assignment.teachingAssignmentId === current)
        ? current
        : nextAssignment,
    )
  }, [filteredAssignments])

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    if (!teacherId || !selectedAssignment || !title.trim() || !content.trim()) return

    setSaving(true)
    setError(null)
    setMessage(null)
    try {
      await createTeacherAnnouncement({
        authorId: teacherId,
        title: title.trim(),
        content: content.trim(),
        announcementType: 'class',
        priority,
        targetClassIds: [selectedAssignment.classId],
      })
      const feed = await fetchTeacherAnnouncements()
      setAnnouncements(feed)
      setTitle('')
      setContent('')
      setMessage('Đã đăng thông báo lớp.')
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Không thể đăng thông báo.')
    } finally {
      setSaving(false)
    }
  }

  const columns: DataTableColumn<Announcement>[] = [
    { key: 'order', header: 'STT', render: (_row, index) => index + 1 },
    { key: 'title', header: 'Tiêu đề' },
    { key: 'priority', header: 'Mức độ' },
    { key: 'announcementType', header: 'Loại' },
    { key: 'createdAt', header: 'Ngày đăng', render: (row) => row.createdAt.slice(0, 10) },
  ]

  return (
    <>
      <PageHeader
        title="Bảng tin lớp"
        subtitle="Gửi và theo dõi thông báo của lớp."
      />

      {loading ? (
        <div className="state-panel">
          <Spinner />
          <p className="state-panel__message">Đang tải bảng tin...</p>
        </div>
      ) : (
        <>
          <form className="teacher-form-panel" onSubmit={submit}>
            <div className="ui-filters teacher-form-grid">
              <div className="ui-field">
                <label htmlFor="announcement-year">Năm học</label>
                <select
                  id="announcement-year"
                  value={yearId}
                  onChange={(event) => setYearId(Number(event.target.value) || '')}
                >
                  <option value="">Chọn năm học</option>
                  {academicYears.map((year) => (
                    <option key={year.academicYearId} value={year.academicYearId}>
                      {year.yearName}
                    </option>
                  ))}
                </select>
              </div>
              <div className="ui-field">
                <label htmlFor="announcement-semester">Học kỳ</label>
                <select
                  id="announcement-semester"
                  value={semesterId}
                  onChange={(event) => setSemesterId(Number(event.target.value) || '')}
                  disabled={yearId === ''}
                >
                  <option value="">Chọn học kỳ</option>
                  {filteredSemesters.map((semester) => (
                    <option key={semester.semesterId} value={semester.semesterId}>
                      {semester.semesterName}
                    </option>
                  ))}
                </select>
              </div>
              <div className="ui-field">
                <label htmlFor="announcement-assignment">Lớp</label>
                <select
                  id="announcement-assignment"
                  value={assignmentId}
                  onChange={(event) => setAssignmentId(Number(event.target.value) || '')}
                  disabled={semesterId === ''}
                >
                  <option value="">Chọn lớp</option>
                  {filteredAssignments.map((assignment) => (
                    <option key={assignment.teachingAssignmentId} value={assignment.teachingAssignmentId}>
                      {assignment.className ?? `Lớp #${assignment.classId}`} - {assignment.subjectName ?? 'Môn học'}
                    </option>
                  ))}
                </select>
              </div>
              <div className="ui-field">
                <label htmlFor="announcement-priority">Mức độ</label>
                <select
                  id="announcement-priority"
                  value={priority}
                  onChange={(event) => setPriority(event.target.value)}
                >
                  <option value="normal">Bình thường</option>
                  <option value="urgent">Khẩn cấp</option>
                </select>
              </div>
            </div>
            <div className="ui-field">
              <label htmlFor="announcement-title">Tiêu đề</label>
              <input id="announcement-title" value={title} onChange={(event) => setTitle(event.target.value)} />
            </div>
            <div className="ui-field">
              <label htmlFor="announcement-content">Nội dung</label>
              <textarea
                id="announcement-content"
                value={content}
                onChange={(event) => setContent(event.target.value)}
                rows={4}
              />
            </div>
            <Button loading={saving} disabled={!selectedAssignment || !title.trim() || !content.trim()} type="submit">
              Đăng thông báo
            </Button>
          </form>

          {message && <p className="teacher-success">{message}</p>}
          {error && <p className="teacher-alert">{error}</p>}

          <section className="teacher-section">
            <h2>Thông báo gần đây</h2>
            <DataTable
              columns={columns}
              data={announcements}
              rowKey={(row) => row.announcementId}
              emptyMessage="Chưa có thông báo."
            />
          </section>
        </>
      )}
    </>
  )
}
