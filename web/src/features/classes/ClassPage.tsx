import { type FormEvent, useCallback, useEffect, useMemo, useState } from 'react'
import Button from '../../components/ui/Button'
import ConfirmDialog from '../../components/ui/ConfirmDialog'
import DataTable, { type DataTableColumn } from '../../components/ui/DataTable'
import EmptyState from '../../components/ui/EmptyState'
import Modal from '../../components/ui/Modal'
import PageHeader from '../../components/ui/PageHeader'
import Spinner from '../../components/ui/Spinner'
import { useToast } from '../../components/ui/Toast'
import { fetchAcademicYears } from '../academic-years/api'
import type { AcademicYear } from '../academic-years/types'
import {
  createClass,
  deleteClass,
  fetchClassesByYear,
  fetchTeachers,
  updateClass,
} from './api'
import type { SchoolClass } from './types'

type FormState = {
  className: string
  homeroomTeacherId: string
}

const emptyForm: FormState = { className: '', homeroomTeacherId: '' }

/** Quản lý lớp học — CRUD, lọc theo năm học, gán GVCN */
export default function ClassPage() {
  const { showToast } = useToast()
  const [years, setYears] = useState<AcademicYear[]>([])
  const [yearFilter, setYearFilter] = useState<number | ''>('')
  const [teachers, setTeachers] = useState<{ id: number; fullName: string }[]>([])
  const [items, setItems] = useState<SchoolClass[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [submitting, setSubmitting] = useState(false)

  const [modalOpen, setModalOpen] = useState(false)
  const [editing, setEditing] = useState<SchoolClass | null>(null)
  const [form, setForm] = useState<FormState>(emptyForm)

  const [deleteTarget, setDeleteTarget] = useState<SchoolClass | null>(null)

  const yearNameById = useMemo(
    () => new Map(years.map((y) => [y.academicYearId, y.yearName])),
    [years],
  )

  const teacherNameById = useMemo(
    () => new Map(teachers.map((t) => [t.id, t.fullName])),
    [teachers],
  )

  const loadYears = useCallback(async () => {
    const data = await fetchAcademicYears()
    setYears(data)
    if (data.length === 0) {
      setYearFilter('')
      return
    }
    setYearFilter((prev) => {
      if (prev !== '' && data.some((y) => y.academicYearId === prev)) return prev
      const active = data.find((y) => y.isActive)
      return active?.academicYearId ?? data[0].academicYearId
    })
  }, [])

  const loadTeachers = useCallback(async () => {
    const data = await fetchTeachers()
    setTeachers(data)
  }, [])

  const loadClasses = useCallback(async (academicYearId: number) => {
    setLoading(true)
    setError(null)
    try {
      const data = await fetchClassesByYear(academicYearId)
      setItems(data)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Không tải được danh sách lớp học.')
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    void (async () => {
      setLoading(true)
      setError(null)
      try {
        await Promise.all([loadYears(), loadTeachers()])
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Không tải được dữ liệu.')
        setLoading(false)
      }
    })()
  }, [loadYears, loadTeachers])

  useEffect(() => {
    if (yearFilter === '') {
      setItems([])
      setLoading(false)
      return
    }
    void loadClasses(yearFilter)
  }, [yearFilter, loadClasses])

  function openCreate() {
    if (yearFilter === '') {
      showToast('Vui lòng chọn năm học trước khi thêm lớp.', 'error')
      return
    }
    setEditing(null)
    setForm(emptyForm)
    setModalOpen(true)
  }

  function openEdit(row: SchoolClass) {
    setEditing(row)
    setForm({
      className: row.className,
      homeroomTeacherId:
        row.homeroomTeacherId !== null ? String(row.homeroomTeacherId) : '',
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
    const className = form.className.trim()
    if (!className) {
      showToast('Vui lòng nhập tên lớp.', 'error')
      return
    }

    setSubmitting(true)
    try {
      if (editing) {
        const payload: { className?: string; homeroomTeacherId?: number } = {}
        if (className !== editing.className) payload.className = className
        if (form.homeroomTeacherId !== '') {
          const teacherId = Number(form.homeroomTeacherId)
          if (teacherId !== editing.homeroomTeacherId) {
            payload.homeroomTeacherId = teacherId
          }
        }
        await updateClass(editing.classId, payload)
        showToast('Đã cập nhật lớp học.', 'success')
      } else {
        if (yearFilter === '') {
          showToast('Vui lòng chọn năm học.', 'error')
          return
        }
        const payload: { className: string; academicYearId: number; homeroomTeacherId?: number } =
          {
            className,
            academicYearId: yearFilter,
          }
        if (form.homeroomTeacherId !== '') {
          payload.homeroomTeacherId = Number(form.homeroomTeacherId)
        }
        await createClass(payload)
        showToast('Đã thêm lớp học mới.', 'success')
      }
      closeModal()
      if (yearFilter !== '') await loadClasses(yearFilter)
    } catch (err) {
      showToast(err instanceof Error ? err.message : 'Thao tác thất bại.', 'error')
    } finally {
      setSubmitting(false)
    }
  }

  async function handleDeleteConfirm() {
    if (!deleteTarget || yearFilter === '') return
    setSubmitting(true)
    try {
      await deleteClass(deleteTarget.classId)
      showToast('Đã xóa lớp học.', 'success')
      setDeleteTarget(null)
      await loadClasses(yearFilter)
    } catch (err) {
      showToast(err instanceof Error ? err.message : 'Xóa thất bại.', 'error')
    } finally {
      setSubmitting(false)
    }
  }

  const columns: DataTableColumn<SchoolClass>[] = [
    { key: 'classId', header: 'ID' },
    { key: 'className', header: 'Tên lớp' },
    {
      key: 'academicYearId',
      header: 'Năm học',
      render: (row) => yearNameById.get(row.academicYearId) ?? row.academicYearId,
    },
    {
      key: 'homeroomTeacherId',
      header: 'GVCN',
      render: (row) =>
        row.homeroomTeacherId !== null
          ? (teacherNameById.get(row.homeroomTeacherId) ?? `#${row.homeroomTeacherId}`)
          : '—',
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

  const filterYearName =
    yearFilter !== '' ? yearNameById.get(yearFilter) : undefined

  return (
    <>
      <PageHeader
        title="Lớp học"
        subtitle="Quản lý lớp theo năm học và gán giáo viên chủ nhiệm"
        actions={
          <Button onClick={openCreate} disabled={loading || submitting || yearFilter === ''}>
            Thêm lớp
          </Button>
        }
      />

      <div className="ui-field" style={{ maxWidth: 320, marginBottom: 24 }}>
        <label htmlFor="class-year-filter">Lọc theo năm học</label>
        <select
          id="class-year-filter"
          value={yearFilter}
          onChange={(e) => {
            const v = e.target.value
            setYearFilter(v === '' ? '' : Number(v))
          }}
          disabled={loading || submitting || years.length === 0}
        >
          {years.length === 0 ? (
            <option value="">Chưa có năm học</option>
          ) : (
            years.map((y) => (
              <option key={y.academicYearId} value={y.academicYearId}>
                {y.yearName}
                {y.isActive ? ' (đang dùng)' : ''}
              </option>
            ))
          )}
        </select>
      </div>

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
          <Button onClick={() => (yearFilter !== '' ? void loadClasses(yearFilter) : void loadYears())}>
            Thử lại
          </Button>
        </div>
      )}

      {!loading && !error && years.length === 0 && (
        <EmptyState
          title="Chưa có năm học"
          message="Hãy tạo năm học trước khi quản lý lớp học."
        />
      )}

      {!loading && !error && years.length > 0 && items.length === 0 && (
        <EmptyState
          title="Chưa có lớp học"
          message={
            filterYearName
              ? `Năm ${filterYearName} chưa có lớp. Nhấn «Thêm lớp» để tạo.`
              : 'Nhấn «Thêm lớp» để tạo bản ghi đầu tiên.'
          }
          action={<Button onClick={openCreate}>Thêm lớp</Button>}
        />
      )}

      {!loading && !error && items.length > 0 && (
        <DataTable columns={columns} data={items} rowKey={(row) => row.classId} />
      )}

      <Modal
        open={modalOpen}
        title={editing ? 'Sửa lớp học' : 'Thêm lớp học'}
        onClose={closeModal}
        footer={
          <>
            <Button variant="secondary" onClick={closeModal} disabled={submitting}>
              Hủy
            </Button>
            <Button type="submit" form="class-form" loading={submitting}>
              {editing ? 'Lưu' : 'Thêm'}
            </Button>
          </>
        }
      >
        <form id="class-form" onSubmit={handleSubmit}>
          <div className="ui-field">
            <label htmlFor="class-year">Năm học</label>
            <input
              id="class-year"
              value={
                editing
                  ? (yearNameById.get(editing.academicYearId) ?? String(editing.academicYearId))
                  : (filterYearName ?? '')
              }
              disabled
            />
          </div>
          <div className="ui-field">
            <label htmlFor="class-name">Tên lớp *</label>
            <input
              id="class-name"
              value={form.className}
              onChange={(e) => setForm((f) => ({ ...f, className: e.target.value }))}
              disabled={submitting}
              placeholder="VD: 10A1"
            />
          </div>
          <div className="ui-field">
            <label htmlFor="class-gvcn">Giáo viên chủ nhiệm</label>
            <select
              id="class-gvcn"
              value={form.homeroomTeacherId}
              onChange={(e) => setForm((f) => ({ ...f, homeroomTeacherId: e.target.value }))}
              disabled={submitting}
            >
              {(!editing || editing.homeroomTeacherId === null) && (
                <option value="">— {editing ? 'Chưa có GVCN' : 'Không chọn'} —</option>
              )}
              {teachers.map((t) => (
                <option key={t.id} value={t.id}>
                  {t.fullName}
                </option>
              ))}
            </select>
            {editing && (
              <p style={{ fontSize: 13, color: 'var(--color-text-muted)', margin: 0 }}>
                Để giữ GVCN hiện tại, không đổi lựa chọn. API không hỗ trợ xóa GVCN qua null.
              </p>
            )}
          </div>
        </form>
      </Modal>

      <ConfirmDialog
        open={deleteTarget !== null}
        title="Xóa lớp học"
        message={
          deleteTarget ? `Bạn có chắc muốn xóa lớp «${deleteTarget.className}»?` : ''
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
