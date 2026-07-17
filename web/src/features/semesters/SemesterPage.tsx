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
  createSemester,
  deleteSemester,
  fetchSemestersByYear,
  updateSemester,
} from './api'
import type { Semester } from './types'

type FormState = {
  semesterName: string
  startDate: string
  endDate: string
}

const emptyForm: FormState = { semesterName: '', startDate: '', endDate: '' }

/** Quản lý học kỳ — CRUD, lọc theo năm học */
export default function SemesterPage() {
  const { showToast } = useToast()
  const [years, setYears] = useState<AcademicYear[]>([])
  const [yearFilter, setYearFilter] = useState<number | ''>('')
  const [items, setItems] = useState<Semester[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [submitting, setSubmitting] = useState(false)

  const [modalOpen, setModalOpen] = useState(false)
  const [editing, setEditing] = useState<Semester | null>(null)
  const [form, setForm] = useState<FormState>(emptyForm)

  const [deleteTarget, setDeleteTarget] = useState<Semester | null>(null)

  const yearNameById = useMemo(
    () => new Map(years.map((y) => [y.academicYearId, y.yearName])),
    [years],
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

  const loadSemesters = useCallback(async (academicYearId: number) => {
    setLoading(true)
    setError(null)
    try {
      const data = await fetchSemestersByYear(academicYearId)
      setItems(data)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Không tải được danh sách học kỳ.')
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    void (async () => {
      setLoading(true)
      setError(null)
      try {
        await loadYears()
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Không tải được danh sách năm học.')
        setLoading(false)
      }
    })()
  }, [loadYears])

  useEffect(() => {
    if (yearFilter === '') {
      setItems([])
      setLoading(false)
      return
    }
    void loadSemesters(yearFilter)
  }, [yearFilter, loadSemesters])

  function openCreate() {
    if (yearFilter === '') {
      showToast('Vui lòng chọn năm học trước khi thêm học kỳ.', 'error')
      return
    }
    setEditing(null)
    setForm(emptyForm)
    setModalOpen(true)
  }

  function openEdit(row: Semester) {
    setEditing(row)
    setForm({
      semesterName: row.semesterName,
      startDate: row.startDate,
      endDate: row.endDate,
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
    const semesterName = form.semesterName.trim()
    if (!semesterName) {
      showToast('Vui lòng nhập tên học kỳ.', 'error')
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
        await updateSemester(editing.semesterId, {
          semesterName,
          startDate: form.startDate,
          endDate: form.endDate,
        })
        showToast('Đã cập nhật học kỳ.', 'success')
      } else {
        if (yearFilter === '') {
          showToast('Vui lòng chọn năm học.', 'error')
          return
        }
        await createSemester({
          academicYearId: yearFilter,
          semesterName,
          startDate: form.startDate,
          endDate: form.endDate,
        })
        showToast('Đã thêm học kỳ mới.', 'success')
      }
      closeModal()
      if (yearFilter !== '') await loadSemesters(yearFilter)
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
      await deleteSemester(deleteTarget.semesterId)
      showToast('Đã xóa học kỳ.', 'success')
      setDeleteTarget(null)
      await loadSemesters(yearFilter)
    } catch (err) {
      showToast(err instanceof Error ? err.message : 'Xóa thất bại.', 'error')
    } finally {
      setSubmitting(false)
    }
  }

  const columns: DataTableColumn<Semester>[] = [
    { key: 'semesterId', header: 'ID' },
    { key: 'semesterName', header: 'Học kỳ' },
    {
      key: 'academicYearId',
      header: 'Năm học',
      render: (row) => yearNameById.get(row.academicYearId) ?? row.academicYearId,
    },
    { key: 'startDate', header: 'Bắt đầu' },
    { key: 'endDate', header: 'Kết thúc' },
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
        title="Học kỳ"
        subtitle="Quản lý học kỳ theo từng năm học"
        actions={
          <Button onClick={openCreate} disabled={loading || submitting || yearFilter === ''}>
            Thêm học kỳ
          </Button>
        }
      />

      <div className="ui-field" style={{ maxWidth: 320, marginBottom: 24 }}>
        <label htmlFor="semester-year-filter">Lọc theo năm học</label>
        <select
          id="semester-year-filter"
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
          <Button onClick={() => (yearFilter !== '' ? void loadSemesters(yearFilter) : void loadYears())}>
            Thử lại
          </Button>
        </div>
      )}

      {!loading && !error && years.length === 0 && (
        <EmptyState
          title="Chưa có năm học"
          message="Hãy tạo năm học trước khi quản lý học kỳ."
        />
      )}

      {!loading && !error && years.length > 0 && items.length === 0 && (
        <EmptyState
          title="Chưa có học kỳ"
          message={
            filterYearName
              ? `Năm ${filterYearName} chưa có học kỳ. Nhấn «Thêm học kỳ» để tạo.`
              : 'Nhấn «Thêm học kỳ» để tạo bản ghi đầu tiên.'
          }
          action={<Button onClick={openCreate}>Thêm học kỳ</Button>}
        />
      )}

      {!loading && !error && items.length > 0 && (
        <DataTable columns={columns} data={items} rowKey={(row) => row.semesterId} />
      )}

      <Modal
        open={modalOpen}
        title={editing ? 'Sửa học kỳ' : 'Thêm học kỳ'}
        onClose={closeModal}
        footer={
          <>
            <Button variant="secondary" onClick={closeModal} disabled={submitting}>
              Hủy
            </Button>
            <Button type="submit" form="semester-form" loading={submitting}>
              {editing ? 'Lưu' : 'Thêm'}
            </Button>
          </>
        }
      >
        <form id="semester-form" onSubmit={handleSubmit}>
          <div className="ui-field">
            <label htmlFor="semester-year">Năm học</label>
            <input
              id="semester-year"
              value={
                editing
                  ? (yearNameById.get(editing.academicYearId) ?? String(editing.academicYearId))
                  : (filterYearName ?? '')
              }
              disabled
            />
          </div>
          <div className="ui-field">
            <label htmlFor="semester-name">Tên học kỳ *</label>
            <input
              id="semester-name"
              value={form.semesterName}
              onChange={(e) => setForm((f) => ({ ...f, semesterName: e.target.value }))}
              disabled={submitting}
              placeholder="VD: HK1"
            />
          </div>
          <div className="ui-field">
            <label htmlFor="semester-start">Ngày bắt đầu *</label>
            <input
              id="semester-start"
              type="date"
              value={form.startDate}
              onChange={(e) => setForm((f) => ({ ...f, startDate: e.target.value }))}
              disabled={submitting}
            />
          </div>
          <div className="ui-field">
            <label htmlFor="semester-end">Ngày kết thúc *</label>
            <input
              id="semester-end"
              type="date"
              value={form.endDate}
              onChange={(e) => setForm((f) => ({ ...f, endDate: e.target.value }))}
              disabled={submitting}
            />
          </div>
        </form>
      </Modal>

      <ConfirmDialog
        open={deleteTarget !== null}
        title="Xóa học kỳ"
        message={
          deleteTarget ? `Bạn có chắc muốn xóa «${deleteTarget.semesterName}»?` : ''
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
