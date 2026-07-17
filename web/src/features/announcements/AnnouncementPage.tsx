import { type FormEvent, useCallback, useEffect, useMemo, useState } from 'react'
import Button from '../../components/ui/Button'
import ConfirmDialog from '../../components/ui/ConfirmDialog'
import DataTable, { type DataTableColumn } from '../../components/ui/DataTable'
import EmptyState from '../../components/ui/EmptyState'
import Modal from '../../components/ui/Modal'
import PageHeader from '../../components/ui/PageHeader'
import Spinner from '../../components/ui/Spinner'
import { useToast } from '../../components/ui/Toast'
import { useAuth } from '../../core/auth/AuthContext'
import { fetchClasses } from '../classes/api'
import type { SchoolClass } from '../classes/types'
import {
  createAnnouncement,
  deleteAnnouncement,
  fetchAnnouncements,
  updateAnnouncement,
} from './api'
import type {
  Announcement,
  AnnouncementPriority,
  AnnouncementType,
} from './types'

type FormState = {
  title: string
  content: string
  announcementType: AnnouncementType
  priority: AnnouncementPriority
  targetClassIds: number[]
}

const emptyForm: FormState = {
  title: '',
  content: '',
  announcementType: 'global',
  priority: 'normal',
  targetClassIds: [],
}

const PRIORITY_OPTIONS: { value: AnnouncementPriority; label: string }[] = [
  { value: 'normal', label: 'Bình thường' },
  { value: 'high', label: 'Cao' },
  { value: 'urgent', label: 'Khẩn cấp' },
]

const TYPE_OPTIONS: { value: AnnouncementType; label: string }[] = [
  { value: 'global', label: 'Thông báo chung' },
  { value: 'class', label: 'Thông báo lớp' },
]

/** Nhãn và màu badge ưu tiên (tiếng Việt) */
function getPriorityMeta(priority: string): { label: string; color: string; bg: string } {
  switch (priority.toLowerCase()) {
    case 'urgent':
      return { label: 'Khẩn cấp', color: '#b91c1c', bg: '#fee2e2' }
    case 'high':
      return { label: 'Cao', color: '#c2410c', bg: '#ffedd5' }
    default:
      return { label: 'Bình thường', color: '#15803d', bg: '#dcfce7' }
  }
}

function getTypeLabel(type: string): string {
  return type.toLowerCase() === 'class' ? 'Thông báo lớp' : 'Thông báo chung'
}

/** Định dạng ngày giờ hiển thị */
function formatDateTime(iso: string): string {
  const d = new Date(iso)
  if (Number.isNaN(d.getTime())) return iso
  const pad = (n: number) => String(n).padStart(2, '0')
  return `${pad(d.getDate())}/${pad(d.getMonth() + 1)}/${d.getFullYear()} ${pad(d.getHours())}:${pad(d.getMinutes())}`
}

/** Quản lý bảng tin — CRUD Admin (giống mobile) */
export default function AnnouncementPage() {
  const { user } = useAuth()
  const { showToast } = useToast()

  const [items, setItems] = useState<Announcement[]>([])
  const [classes, setClasses] = useState<SchoolClass[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [submitting, setSubmitting] = useState(false)

  const [modalOpen, setModalOpen] = useState(false)
  const [editing, setEditing] = useState<Announcement | null>(null)
  const [form, setForm] = useState<FormState>(emptyForm)
  const [deleteTarget, setDeleteTarget] = useState<Announcement | null>(null)

  const classNameById = useMemo(
    () => new Map(classes.map((c) => [c.classId, c.className])),
    [classes],
  )

  const load = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const [announcements, classList] = await Promise.all([
        fetchAnnouncements(),
        fetchClasses(),
      ])
      setItems(announcements)
      setClasses(classList)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Không tải được danh sách bảng tin.')
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    void load()
  }, [load])

  function openCreate() {
    setEditing(null)
    setForm(emptyForm)
    setModalOpen(true)
  }

  function openEdit(row: Announcement) {
    setEditing(row)
    setForm({
      title: row.title,
      content: row.content,
      announcementType: row.announcementType.toLowerCase() as AnnouncementType,
      priority: row.priority.toLowerCase() as AnnouncementPriority,
      targetClassIds: [],
    })
    setModalOpen(true)
  }

  function closeModal() {
    setModalOpen(false)
    setEditing(null)
    setForm(emptyForm)
  }

  function toggleClassId(classId: number, checked: boolean) {
    setForm((f) => ({
      ...f,
      targetClassIds: checked
        ? [...f.targetClassIds, classId]
        : f.targetClassIds.filter((id) => id !== classId),
    }))
  }

  async function handleSubmit(e: FormEvent) {
    e.preventDefault()
    const title = form.title.trim()
    const content = form.content.trim()

    if (!title || !content) {
      showToast('Vui lòng nhập đủ tiêu đề và nội dung.', 'error')
      return
    }

    if (!editing && form.announcementType === 'class' && form.targetClassIds.length === 0) {
      showToast('Vui lòng chọn ít nhất 1 lớp.', 'error')
      return
    }

    if (!editing && !user) {
      showToast('Không xác định được người đăng.', 'error')
      return
    }

    setSubmitting(true)
    try {
      if (editing) {
        await updateAnnouncement(editing.announcementId, {
          title,
          content,
          priority: form.priority,
        })
        showToast('Đã cập nhật bảng tin.', 'success')
      } else {
        await createAnnouncement({
          authorId: user!.id,
          title,
          content,
          announcementType: form.announcementType,
          priority: form.priority,
          targetClassIds: form.announcementType === 'global' ? [] : form.targetClassIds,
        })
        showToast('Đã đăng bảng tin mới.', 'success')
      }
      closeModal()
      await load()
    } catch (err) {
      showToast(err instanceof Error ? err.message : 'Thao tác thất bại.', 'error')
    } finally {
      setSubmitting(false)
    }
  }

  async function handleDeleteConfirm() {
    if (!deleteTarget) return
    setSubmitting(true)
    try {
      await deleteAnnouncement(deleteTarget.announcementId)
      showToast('Đã xóa bảng tin.', 'success')
      setDeleteTarget(null)
      await load()
    } catch (err) {
      showToast(err instanceof Error ? err.message : 'Xóa thất bại.', 'error')
    } finally {
      setSubmitting(false)
    }
  }

  function renderTargetClasses(row: Announcement) {
    if (row.announcementType.toLowerCase() === 'global') return '—'
    const names = row.targetClassIds
      .filter((id): id is number => id != null)
      .map((id) => classNameById.get(id) ?? `#${id}`)
    return names.length > 0 ? names.join(', ') : '—'
  }

  const columns: DataTableColumn<Announcement>[] = [
    { key: 'announcementId', header: 'ID' },
    {
      key: 'priority',
      header: 'Ưu tiên',
      render: (row) => {
        const meta = getPriorityMeta(row.priority)
        return (
          <span
            style={{
              display: 'inline-block',
              padding: '2px 8px',
              borderRadius: 8,
              fontSize: 12,
              fontWeight: 600,
              color: meta.color,
              backgroundColor: meta.bg,
            }}
          >
            {meta.label}
          </span>
        )
      },
    },
    {
      key: 'announcementType',
      header: 'Loại',
      render: (row) => getTypeLabel(row.announcementType),
    },
    { key: 'title', header: 'Tiêu đề' },
    {
      key: 'content',
      header: 'Nội dung',
      render: (row) =>
        row.content.length > 80 ? `${row.content.slice(0, 80)}…` : row.content,
    },
    {
      key: 'targetClassIds',
      header: 'Lớp nhận',
      render: (row) => renderTargetClasses(row),
    },
    {
      key: 'createdAt',
      header: 'Ngày đăng',
      render: (row) => formatDateTime(row.createdAt),
    },
    {
      key: 'actions',
      header: 'Thao tác',
      render: (row) => (
        <div className="data-table__actions">
          <Button size="sm" variant="secondary" onClick={() => openEdit(row)} disabled={submitting}>
            Sửa
          </Button>
          <Button
            size="sm"
            variant="danger"
            onClick={() => setDeleteTarget(row)}
            disabled={submitting}
          >
            Xóa
          </Button>
        </div>
      ),
    },
  ]

  return (
    <>
      <PageHeader
        title="Bảng tin"
        subtitle="Quản lý thông báo toàn trường và theo lớp"
        actions={
          <Button onClick={openCreate} disabled={loading || submitting}>
            Tạo bảng tin
          </Button>
        }
      />

      {loading && (
        <div className="state-panel">
          <Spinner size="lg" />
          <p className="state-panel__message">Đang tải danh sách…</p>
        </div>
      )}

      {!loading && error && (
        <div className="state-panel state-panel--error">
          <p className="state-panel__title">Lỗi tải dữ liệu</p>
          <p className="state-panel__message">{error}</p>
          <Button onClick={() => void load()}>Thử lại</Button>
        </div>
      )}

      {!loading && !error && items.length === 0 && (
        <EmptyState
          title="Chưa có thông báo"
          message="Nhấn «Tạo bảng tin» để đăng thông báo đầu tiên."
          action={<Button onClick={openCreate}>Tạo bảng tin</Button>}
        />
      )}

      {!loading && !error && items.length > 0 && (
        <DataTable columns={columns} data={items} rowKey={(row) => row.announcementId} />
      )}

      <Modal
        open={modalOpen}
        title={editing ? 'Sửa bảng tin' : 'Tạo bảng tin'}
        onClose={closeModal}
        footer={
          <>
            <Button variant="secondary" onClick={closeModal} disabled={submitting}>
              Hủy
            </Button>
            <Button type="submit" form="announcement-form" loading={submitting}>
              {editing ? 'Lưu' : 'Đăng'}
            </Button>
          </>
        }
      >
        <form id="announcement-form" onSubmit={handleSubmit}>
          <div className="ui-field">
            <label htmlFor="ann-title">Tiêu đề *</label>
            <input
              id="ann-title"
              value={form.title}
              onChange={(e) => setForm((f) => ({ ...f, title: e.target.value }))}
              disabled={submitting}
            />
          </div>
          <div className="ui-field">
            <label htmlFor="ann-content">Nội dung *</label>
            <textarea
              id="ann-content"
              rows={4}
              value={form.content}
              onChange={(e) => setForm((f) => ({ ...f, content: e.target.value }))}
              disabled={submitting}
            />
          </div>

          {!editing && (
            <>
              <div className="ui-field">
                <label htmlFor="ann-type">Loại thông báo *</label>
                <select
                  id="ann-type"
                  value={form.announcementType}
                  onChange={(e) => {
                    const announcementType = e.target.value as AnnouncementType
                    setForm((f) => ({
                      ...f,
                      announcementType,
                      targetClassIds: announcementType === 'global' ? [] : f.targetClassIds,
                    }))
                  }}
                  disabled={submitting}
                >
                  {TYPE_OPTIONS.map((opt) => (
                    <option key={opt.value} value={opt.value}>
                      {opt.label}
                    </option>
                  ))}
                </select>
              </div>

              {form.announcementType === 'class' && (
                <div className="ui-field">
                  <label>Chọn lớp nhận thông báo *</label>
                  <div
                    style={{
                      maxHeight: 160,
                      overflowY: 'auto',
                      border: '1px solid var(--color-border-strong)',
                      borderRadius: 'var(--radius-md)',
                      padding: '4px 0',
                    }}
                  >
                    {classes.length === 0 ? (
                      <p style={{ padding: '8px 12px', margin: 0, color: 'var(--color-text-muted)' }}>
                        Chưa có lớp học.
                      </p>
                    ) : (
                      classes.map((cls) => (
                        <label
                          key={cls.classId}
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: 8,
                            padding: '6px 12px',
                            cursor: submitting ? 'not-allowed' : 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={form.targetClassIds.includes(cls.classId)}
                            onChange={(e) => toggleClassId(cls.classId, e.target.checked)}
                            disabled={submitting}
                          />
                          {cls.className}
                        </label>
                      ))
                    )}
                  </div>
                </div>
              )}
            </>
          )}

          <div className="ui-field">
            <label htmlFor="ann-priority">Mức ưu tiên *</label>
            <select
              id="ann-priority"
              value={form.priority}
              onChange={(e) =>
                setForm((f) => ({ ...f, priority: e.target.value as AnnouncementPriority }))
              }
              disabled={submitting}
            >
              {PRIORITY_OPTIONS.map((opt) => (
                <option key={opt.value} value={opt.value}>
                  {opt.label}
                </option>
              ))}
            </select>
          </div>
        </form>
      </Modal>

      <ConfirmDialog
        open={deleteTarget !== null}
        title="Xóa bảng tin"
        message={
          deleteTarget ? `Bạn có chắc muốn xóa «${deleteTarget.title}»?` : ''
        }
        confirmLabel="Xóa"
        variant="danger"
        loading={submitting}
        onConfirm={() => void handleDeleteConfirm()}
        onCancel={() => {
          if (!submitting) setDeleteTarget(null)
        }}
      />
    </>
  )
}
