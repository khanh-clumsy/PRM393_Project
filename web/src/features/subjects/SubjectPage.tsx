import { type FormEvent, useCallback, useEffect, useState } from 'react'
import Button from '../../components/ui/Button'
import ConfirmDialog from '../../components/ui/ConfirmDialog'
import DataTable, { type DataTableColumn } from '../../components/ui/DataTable'
import EmptyState from '../../components/ui/EmptyState'
import Modal from '../../components/ui/Modal'
import PageHeader from '../../components/ui/PageHeader'
import Spinner from '../../components/ui/Spinner'
import { useToast } from '../../components/ui/Toast'
import { createSubject, deleteSubject, fetchSubjects, updateSubject } from './api'
import type { Subject } from './types'

type FormState = {
  subjectCode: string
  subjectName: string
  isActive: boolean
}

const emptyForm: FormState = { subjectCode: '', subjectName: '', isActive: true }

/** Quản lý môn học — CRUD đầy đủ */
export default function SubjectPage() {
  const { showToast } = useToast()
  const [items, setItems] = useState<Subject[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [submitting, setSubmitting] = useState(false)

  const [modalOpen, setModalOpen] = useState(false)
  const [editing, setEditing] = useState<Subject | null>(null)
  const [form, setForm] = useState<FormState>(emptyForm)

  const [deleteTarget, setDeleteTarget] = useState<Subject | null>(null)

  const load = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const data = await fetchSubjects()
      setItems(data)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Không tải được danh sách môn học.')
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

  function openEdit(row: Subject) {
    setEditing(row)
    setForm({
      subjectCode: row.subjectCode,
      subjectName: row.subjectName,
      isActive: row.isActive,
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
    const code = form.subjectCode.trim()
    const name = form.subjectName.trim()
    if (!code) {
      showToast('Vui lòng nhập mã môn học.', 'error')
      return
    }
    if (!name) {
      showToast('Vui lòng nhập tên môn học.', 'error')
      return
    }

    setSubmitting(true)
    try {
      if (editing) {
        await updateSubject(editing.subjectId, {
          subjectCode: code,
          subjectName: name,
          isActive: form.isActive,
        })
        showToast('Đã cập nhật môn học.', 'success')
      } else {
        await createSubject({
          subjectCode: code,
          subjectName: name,
          isActive: form.isActive,
        })
        showToast('Đã thêm môn học mới.', 'success')
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
      await deleteSubject(deleteTarget.subjectId)
      showToast('Đã xóa môn học.', 'success')
      setDeleteTarget(null)
      await load()
    } catch (err) {
      showToast(err instanceof Error ? err.message : 'Xóa thất bại.', 'error')
    } finally {
      setSubmitting(false)
    }
  }

  const columns: DataTableColumn<Subject>[] = [
    { key: 'subjectId', header: 'ID' },
    { key: 'subjectCode', header: 'Mã môn' },
    { key: 'subjectName', header: 'Tên môn học' },
    {
      key: 'isActive',
      header: 'Trạng thái',
      render: (row) => (row.isActive ? 'Đang dùng' : 'Ngưng'),
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
        title="Môn học"
        subtitle="Quản lý danh sách môn học trong trường"
        actions={
          <Button onClick={openCreate} disabled={loading || submitting}>
            Thêm môn học
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
          title="Chưa có môn học"
          message="Nhấn «Thêm môn học» để tạo bản ghi đầu tiên."
          action={<Button onClick={openCreate}>Thêm môn học</Button>}
        />
      )}

      {!loading && !error && items.length > 0 && (
        <DataTable columns={columns} data={items} rowKey={(row) => row.subjectId} />
      )}

      <Modal
        open={modalOpen}
        title={editing ? 'Sửa môn học' : 'Thêm môn học'}
        onClose={closeModal}
        footer={
          <>
            <Button variant="secondary" onClick={closeModal} disabled={submitting}>
              Hủy
            </Button>
            <Button type="submit" form="subject-form" loading={submitting}>
              {editing ? 'Lưu' : 'Thêm'}
            </Button>
          </>
        }
      >
        <form id="subject-form" onSubmit={handleSubmit}>
          <div className="ui-field">
            <label htmlFor="subject-code">Mã môn học *</label>
            <input
              id="subject-code"
              value={form.subjectCode}
              onChange={(e) => setForm((f) => ({ ...f, subjectCode: e.target.value }))}
              disabled={submitting}
              placeholder="VD: TOAN"
            />
          </div>
          <div className="ui-field">
            <label htmlFor="subject-name">Tên môn học *</label>
            <input
              id="subject-name"
              value={form.subjectName}
              onChange={(e) => setForm((f) => ({ ...f, subjectName: e.target.value }))}
              disabled={submitting}
              placeholder="VD: Toán"
            />
          </div>
          <div className="ui-field">
            <label className="ui-field__checkbox">
              <input
                type="checkbox"
                checked={form.isActive}
                onChange={(e) => setForm((f) => ({ ...f, isActive: e.target.checked }))}
                disabled={submitting}
              />
              Đang sử dụng
            </label>
          </div>
        </form>
      </Modal>

      <ConfirmDialog
        open={deleteTarget !== null}
        title="Xóa môn học"
        message={
          deleteTarget ? `Bạn có chắc muốn xóa «${deleteTarget.subjectName}»?` : ''
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
