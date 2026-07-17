import { useEffect, useState, type FormEvent } from 'react'
import Button from '../../components/ui/Button'
import DataTable, { type DataTableColumn } from '../../components/ui/DataTable'
import PageHeader from '../../components/ui/PageHeader'
import Spinner from '../../components/ui/Spinner'
import { useAuth } from '../../core/auth/AuthContext'
import { createTeacherAnnouncement, fetchTeacherAnnouncements, fetchTeacherClasses } from './api'
import type { Announcement, TeacherClass } from './types'

export default function TeacherAnnouncementsPage() {
  const { user } = useAuth()
  const teacherId = user?.id
  const [classes, setClasses] = useState<TeacherClass[]>([])
  const [announcements, setAnnouncements] = useState<Announcement[]>([])
  const [targetClassId, setTargetClassId] = useState<number | ''>('')
  const [title, setTitle] = useState('')
  const [content, setContent] = useState('')
  const [priority, setPriority] = useState('Normal')
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
        const [classData, feed] = await Promise.all([
          fetchTeacherClasses(id),
          fetchTeacherAnnouncements(),
        ])
        if (ignore) return
        setClasses(classData)
        setAnnouncements(feed)
        setTargetClassId(classData[0]?.classId ?? '')
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

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    if (!teacherId || !targetClassId || !title.trim() || !content.trim()) return

    setSaving(true)
    setError(null)
    setMessage(null)
    try {
      await createTeacherAnnouncement({
        authorId: teacherId,
        title: title.trim(),
        content: content.trim(),
        announcementType: 'Class',
        priority,
        targetClassIds: [Number(targetClassId)],
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
    { key: 'title', header: 'Tiêu đề' },
    { key: 'priority', header: 'Mức độ' },
    { key: 'announcementType', header: 'Loại' },
    { key: 'createdAt', header: 'Ngày đăng', render: (row) => row.createdAt.slice(0, 10) },
  ]

  return (
    <>
      <PageHeader
        title="Bảng tin lớp"
        subtitle="Giáo viên chỉ đăng thông báo loại Class cho lớp đang dạy hoặc chủ nhiệm."
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
                <label htmlFor="announcement-class">Lớp nhận</label>
                <select
                  id="announcement-class"
                  value={targetClassId}
                  onChange={(event) => setTargetClassId(Number(event.target.value) || '')}
                >
                  <option value="">Chọn lớp</option>
                  {classes.map((cls) => (
                    <option key={cls.classId} value={cls.classId}>
                      {cls.className}
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
                  <option value="Normal">Bình thường</option>
                  <option value="High">Quan trọng</option>
                  <option value="Urgent">Khẩn</option>
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
            <Button loading={saving} disabled={!targetClassId || !title.trim() || !content.trim()} type="submit">
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
