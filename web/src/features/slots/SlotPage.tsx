import { type FormEvent, useCallback, useEffect, useState } from 'react'
import Button from '../../components/ui/Button'
import ConfirmDialog from '../../components/ui/ConfirmDialog'
import DataTable, { type DataTableColumn } from '../../components/ui/DataTable'
import EmptyState from '../../components/ui/EmptyState'
import Modal from '../../components/ui/Modal'
import PageHeader from '../../components/ui/PageHeader'
import Spinner from '../../components/ui/Spinner'
import { useToast } from '../../components/ui/Toast'
import { createSlot, deleteSlot, fetchSlots, updateSlot } from './api'
import type { TimetableSlot } from './types'

type FormState = {
  slotName: string
  startTime: string
  endTime: string
}

const emptyForm: FormState = { slotName: '', startTime: '', endTime: '' }

/** Chuyển HH:mm:ss sang HH:mm cho input type=time */
function toTimeInputValue(value: string): string {
  return value.slice(0, 5)
}

/** Chuyển HH:mm từ input sang HH:mm:ss cho API */
function toApiTime(value: string): string {
  const trimmed = value.trim()
  if (/^\d{2}:\d{2}:\d{2}$/.test(trimmed)) return trimmed
  if (/^\d{2}:\d{2}$/.test(trimmed)) return `${trimmed}:00`
  return trimmed
}

/** So sánh thời gian dạng chuỗi */
function timeToSeconds(value: string): number {
  const [h, m, s] = toApiTime(value).split(':').map(Number)
  return h * 3600 + m * 60 + (s ?? 0)
}

/** Hiển thị thời gian ngắn gọn */
function formatTimeDisplay(value: string): string {
  return toTimeInputValue(value)
}

/** Quản lý ca học (tiết) — CRUD đầy đủ */
export default function SlotPage() {
  const { showToast } = useToast()
  const [items, setItems] = useState<TimetableSlot[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [submitting, setSubmitting] = useState(false)

  const [modalOpen, setModalOpen] = useState(false)
  const [editing, setEditing] = useState<TimetableSlot | null>(null)
  const [form, setForm] = useState<FormState>(emptyForm)

  const [deleteTarget, setDeleteTarget] = useState<TimetableSlot | null>(null)

  const load = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const data = await fetchSlots()
      setItems(data)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Không tải được danh sách ca học.')
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

  function openEdit(row: TimetableSlot) {
    setEditing(row)
    setForm({
      slotName: row.slotName,
      startTime: toTimeInputValue(row.startTime),
      endTime: toTimeInputValue(row.endTime),
    })
    setModalOpen(true)
  }

  function closeModal() {
    setModalOpen(false)
    setEditing(null)
    setForm(emptyForm)
  }

  async function handleSubmit(e: FormEvent) {
    e.preventDefault()
    const name = form.slotName.trim()
    if (!name) {
      showToast('Vui lòng nhập tên ca học.', 'error')
      return
    }
    if (!form.startTime || !form.endTime) {
      showToast('Vui lòng chọn giờ bắt đầu và kết thúc.', 'error')
      return
    }
    const start = toApiTime(form.startTime)
    const end = toApiTime(form.endTime)
    if (timeToSeconds(start) >= timeToSeconds(end)) {
      showToast('Giờ bắt đầu phải nhỏ hơn giờ kết thúc.', 'error')
      return
    }

    setSubmitting(true)
    try {
      if (editing) {
        await updateSlot(editing.slotId, {
          slotName: name,
          startTime: start,
          endTime: end,
        })
        showToast('Đã cập nhật ca học.', 'success')
      } else {
        await createSlot({
          slotName: name,
          startTime: start,
          endTime: end,
        })
        showToast('Đã thêm ca học mới.', 'success')
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
      await deleteSlot(deleteTarget.slotId)
      showToast('Đã xóa ca học.', 'success')
      setDeleteTarget(null)
      await load()
    } catch (err) {
      showToast(err instanceof Error ? err.message : 'Xóa thất bại.', 'error')
    } finally {
      setSubmitting(false)
    }
  }

  const columns: DataTableColumn<TimetableSlot>[] = [
    { key: 'slotId', header: 'ID' },
    { key: 'slotName', header: 'Tên ca' },
    {
      key: 'startTime',
      header: 'Bắt đầu',
      render: (row) => formatTimeDisplay(row.startTime),
    },
    {
      key: 'endTime',
      header: 'Kết thúc',
      render: (row) => formatTimeDisplay(row.endTime),
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
        title="Ca học (Slot)"
        subtitle="Quản lý khung giờ tiết học trong ngày"
        actions={
          <Button onClick={openCreate} disabled={loading || submitting}>
            Thêm ca học
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
          title="Chưa có ca học"
          message="Nhấn «Thêm ca học» để tạo bản ghi đầu tiên."
          action={<Button onClick={openCreate}>Thêm ca học</Button>}
        />
      )}

      {!loading && !error && items.length > 0 && (
        <DataTable columns={columns} data={items} rowKey={(row) => row.slotId} />
      )}

      <Modal
        open={modalOpen}
        title={editing ? 'Sửa ca học' : 'Thêm ca học'}
        onClose={closeModal}
        footer={
          <>
            <Button variant="secondary" onClick={closeModal} disabled={submitting}>
              Hủy
            </Button>
            <Button type="submit" form="slot-form" loading={submitting}>
              {editing ? 'Lưu' : 'Thêm'}
            </Button>
          </>
        }
      >
        <form id="slot-form" onSubmit={handleSubmit}>
          <div className="ui-field">
            <label htmlFor="slot-name">Tên ca học *</label>
            <input
              id="slot-name"
              value={form.slotName}
              onChange={(e) => setForm((f) => ({ ...f, slotName: e.target.value }))}
              disabled={submitting}
              placeholder="VD: Tiết 1"
            />
          </div>
          <div className="ui-field">
            <label htmlFor="slot-start">Giờ bắt đầu *</label>
            <input
              id="slot-start"
              type="time"
              value={form.startTime}
              onChange={(e) => setForm((f) => ({ ...f, startTime: e.target.value }))}
              disabled={submitting}
            />
          </div>
          <div className="ui-field">
            <label htmlFor="slot-end">Giờ kết thúc *</label>
            <input
              id="slot-end"
              type="time"
              value={form.endTime}
              onChange={(e) => setForm((f) => ({ ...f, endTime: e.target.value }))}
              disabled={submitting}
            />
          </div>
        </form>
      </Modal>

      <ConfirmDialog
        open={deleteTarget !== null}
        title="Xóa ca học"
        message={deleteTarget ? `Bạn có chắc muốn xóa «${deleteTarget.slotName}»?` : ''}
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
