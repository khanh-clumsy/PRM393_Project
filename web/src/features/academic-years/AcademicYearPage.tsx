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
  createAcademicYear,
  deleteAcademicYear,
  fetchAcademicYears,
  updateAcademicYear,
} from './api'
import type { AcademicYear } from './types'

type FormState = {
  yearName: string
  startDate: string
  endDate: string
  isActive: boolean
}

const emptyForm: FormState = {
  yearName: '',
  startDate: '',
  endDate: '',
  isActive: true,
}

const YEAR_NAME_PATTERN = /^\d{4}-\d{4}$/

/** Quản lý năm học — CRUD đầy đủ (API tự sinh HK1/HK2 khi tạo) */
export default function AcademicYearPage() {
  const { showToast } = useToast()
  const [items, setItems] = useState<AcademicYear[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [submitting, setSubmitting] = useState(false)

  const [modalOpen, setModalOpen] = useState(false)
  const [editing, setEditing] = useState<AcademicYear | null>(null)
  const [form, setForm] = useState<FormState>(emptyForm)

  const [deleteTarget, setDeleteTarget] = useState<AcademicYear | null>(null)

  const load = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const data = await fetchAcademicYears()
      setItems(data)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Không tải được danh sách năm học.')
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

  function openEdit(row: AcademicYear) {
    setEditing(row)
    setForm({
      yearName: row.yearName,
      startDate: row.startDate,
      endDate: row.endDate,
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
    const yearName = form.yearName.trim()
    if (!yearName) {
      showToast('Vui lòng nhập tên năm học.', 'error')
      return
    }
    if (!YEAR_NAME_PATTERN.test(yearName)) {
      showToast('Tên năm học phải theo dạng YYYY-YYYY (VD: 2026-2027).', 'error')
      return
    }
    if (!form.startDate || !form.endDate) {
      showToast('Vui lòng chọn ngày bắt đầu và kết thúc.', 'error')
      return
    }
    if (form.startDate > form.endDate) {
      showToast('Ngày bắt đầu phải ≤ ngày kết thúc.', 'error')
      return
    }

    setSubmitting(true)
    try {
      if (editing) {
        await updateAcademicYear(editing.academicYearId, {
          yearName,
          startDate: form.startDate,
          endDate: form.endDate,
          isActive: form.isActive,
        })
        showToast('Đã cập nhật năm học.', 'success')
      } else {
        await createAcademicYear({
          yearName,
          startDate: form.startDate,
          endDate: form.endDate,
          isActive: form.isActive,
        })
        showToast('Đã thêm năm học mới (HK1/HK2 được tạo tự động).', 'success')
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
      await deleteAcademicYear(deleteTarget.academicYearId)
      showToast('Đã xóa năm học.', 'success')
      setDeleteTarget(null)
      await load()
    } catch (err) {
      showToast(err instanceof Error ? err.message : 'Xóa thất bại.', 'error')
    } finally {
      setSubmitting(false)
    }
  }

  const columns: DataTableColumn<AcademicYear>[] = [
    { key: 'academicYearId', header: 'ID' },
    { key: 'yearName', header: 'Năm học' },
    { key: 'startDate', header: 'Bắt đầu' },
    { key: 'endDate', header: 'Kết thúc' },
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
        title="Năm học"
        subtitle="Quản lý niên khóa và khung thời gian năm học"
        actions={
          <Button onClick={openCreate} disabled={loading || submitting}>
            Thêm năm học
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
          title="Chưa có năm học"
          message="Nhấn «Thêm năm học» để tạo bản ghi đầu tiên."
          action={<Button onClick={openCreate}>Thêm năm học</Button>}
        />
      )}

      {!loading && !error && items.length > 0 && (
        <DataTable columns={columns} data={items} rowKey={(row) => row.academicYearId} />
      )}

      <Modal
        open={modalOpen}
        title={editing ? 'Sửa năm học' : 'Thêm năm học'}
        onClose={closeModal}
        footer={
          <>
            <Button variant="secondary" onClick={closeModal} disabled={submitting}>
              Hủy
            </Button>
            <Button type="submit" form="year-form" loading={submitting}>
              {editing ? 'Lưu' : 'Thêm'}
            </Button>
          </>
        }
      >
        <form id="year-form" onSubmit={handleSubmit}>
          <div className="ui-field">
            <label htmlFor="year-name">Tên năm học *</label>
            <input
              id="year-name"
              value={form.yearName}
              onChange={(e) => setForm((f) => ({ ...f, yearName: e.target.value }))}
              disabled={submitting}
              placeholder="VD: 2026-2027"
            />
          </div>
          <div className="ui-field">
            <label htmlFor="year-start">Ngày bắt đầu *</label>
            <input
              id="year-start"
              type="date"
              value={form.startDate}
              onChange={(e) => setForm((f) => ({ ...f, startDate: e.target.value }))}
              disabled={submitting}
            />
          </div>
          <div className="ui-field">
            <label htmlFor="year-end">Ngày kết thúc *</label>
            <input
              id="year-end"
              type="date"
              value={form.endDate}
              onChange={(e) => setForm((f) => ({ ...f, endDate: e.target.value }))}
              disabled={submitting}
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
        title="Xóa năm học"
        message={
          deleteTarget ? `Bạn có chắc muốn xóa «${deleteTarget.yearName}»?` : ''
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
