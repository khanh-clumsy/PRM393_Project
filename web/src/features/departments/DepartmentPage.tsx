import { type FormEvent, useCallback, useEffect, useState } from 'react'
import Button from '../../components/ui/Button'
import ConfirmDialog from '../../components/ui/ConfirmDialog'
import DataTable, { type DataTableColumn } from '../../components/ui/DataTable'
import EmptyState from '../../components/ui/EmptyState'
import Modal from '../../components/ui/Modal'
import PageHeader from '../../components/ui/PageHeader'
import Spinner from '../../components/ui/Spinner'
import { useToast } from '../../components/ui/Toast'
import {
  createDepartment,
  deleteDepartment,
  fetchDepartments,
  updateDepartment,
} from './api'
import type { Department } from './types'

type FormState = {
  departmentName: string
  description: string
}

const emptyForm: FormState = { departmentName: '', description: '' }

/** Quản lý phòng ban / khoa — CRUD đầy đủ */
export default function DepartmentPage() {
  const { showToast } = useToast()
  const [items, setItems] = useState<Department[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [submitting, setSubmitting] = useState(false)

  const [modalOpen, setModalOpen] = useState(false)
  const [editing, setEditing] = useState<Department | null>(null)
  const [form, setForm] = useState<FormState>(emptyForm)

  const [deleteTarget, setDeleteTarget] = useState<Department | null>(null)

  const load = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const data = await fetchDepartments()
      setItems(data)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Không tải được danh sách phòng ban.')
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

  function openEdit(row: Department) {
    setEditing(row)
    setForm({
      departmentName: row.departmentName,
      description: row.description ?? '',
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
    const name = form.departmentName.trim()
    if (!name) {
      showToast('Vui lòng nhập tên phòng ban.', 'error')
      return
    }

    setSubmitting(true)
    try {
      if (editing) {
        await updateDepartment(editing.departmentId, {
          departmentName: name,
          description: form.description.trim() || null,
        })
        showToast('Đã cập nhật phòng ban.', 'success')
      } else {
        await createDepartment({
          departmentName: name,
          description: form.description.trim() || null,
        })
        showToast('Đã thêm phòng ban mới.', 'success')
      }
      closeModal()
      await load()
    } catch (err) {
      showToast(
        err instanceof Error ? err.message : 'Thao tác thất bại.',
        'error',
      )
    } finally {
      setSubmitting(false)
    }
  }

  async function handleDeleteConfirm() {
    if (!deleteTarget) return
    setSubmitting(true)
    try {
      await deleteDepartment(deleteTarget.departmentId)
      showToast('Đã xóa phòng ban.', 'success')
      setDeleteTarget(null)
      await load()
    } catch (err) {
      showToast(err instanceof Error ? err.message : 'Xóa thất bại.', 'error')
    } finally {
      setSubmitting(false)
    }
  }

  const columns: DataTableColumn<Department>[] = [
    { key: 'departmentId', header: 'ID' },
    { key: 'departmentName', header: 'Tên phòng ban' },
    {
      key: 'description',
      header: 'Mô tả',
      render: (row) => row.description ?? '—',
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
        title="Phòng ban / Khoa"
        subtitle="Quản lý danh sách phòng ban trong trường"
        actions={
          <Button onClick={openCreate} disabled={loading || submitting}>
            Thêm phòng ban
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
          title="Chưa có phòng ban"
          message="Nhấn «Thêm phòng ban» để tạo bản ghi đầu tiên."
          action={<Button onClick={openCreate}>Thêm phòng ban</Button>}
        />
      )}

      {!loading && !error && items.length > 0 && (
        <DataTable
          columns={columns}
          data={items}
          rowKey={(row) => row.departmentId}
        />
      )}

      <Modal
        open={modalOpen}
        title={editing ? 'Sửa phòng ban' : 'Thêm phòng ban'}
        onClose={closeModal}
        footer={
          <>
            <Button variant="secondary" onClick={closeModal} disabled={submitting}>
              Hủy
            </Button>
            <Button type="submit" form="dept-form" loading={submitting}>
              {editing ? 'Lưu' : 'Thêm'}
            </Button>
          </>
        }
      >
        <form id="dept-form" onSubmit={handleSubmit}>
          <div className="ui-field">
            <label htmlFor="dept-name">Tên phòng ban *</label>
            <input
              id="dept-name"
              value={form.departmentName}
              onChange={(e) => setForm((f) => ({ ...f, departmentName: e.target.value }))}
              disabled={submitting}
              placeholder="VD: Khoa Toán"
            />
          </div>
          <div className="ui-field">
            <label htmlFor="dept-desc">Mô tả</label>
            <textarea
              id="dept-desc"
              rows={3}
              value={form.description}
              onChange={(e) => setForm((f) => ({ ...f, description: e.target.value }))}
              disabled={submitting}
              placeholder="Mô tả ngắn (tuỳ chọn)"
            />
          </div>
        </form>
      </Modal>

      <ConfirmDialog
        open={deleteTarget !== null}
        title="Xóa phòng ban"
        message={
          deleteTarget
            ? `Bạn có chắc muốn xóa «${deleteTarget.departmentName}»?`
            : ''
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
