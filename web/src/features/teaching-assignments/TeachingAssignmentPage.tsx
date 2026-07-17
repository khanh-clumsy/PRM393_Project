import { type FormEvent, useCallback, useEffect, useMemo, useState } from 'react'
import Button from '../../components/ui/Button'
import ConfirmDialog from '../../components/ui/ConfirmDialog'
import DataTable, { type DataTableColumn } from '../../components/ui/DataTable'
import EmptyState from '../../components/ui/EmptyState'
import Modal from '../../components/ui/Modal'
import PageHeader from '../../components/ui/PageHeader'
import Spinner from '../../components/ui/Spinner'
import { useToast } from '../../components/ui/Toast'
import {
  createTeachingAssignment,
  deleteTeachingAssignment,
  fetchTeachingAssignmentLookup,
  fetchTeachingAssignments,
  updateTeachingAssignment,
} from './api'
import type { TeachingAssignment, TeachingAssignmentLookup } from './types'

type FormMode = 'create' | 'edit'

const FILTER_EMPTY_MESSAGE = 'Vui lòng chọn Năm học, Học kỳ và Lớp học.'

/** Quản lý phân công giảng dạy — lọc năm → học kỳ → lớp */
export default function TeachingAssignmentPage() {
  const { showToast } = useToast()
  const [lookup, setLookup] = useState<TeachingAssignmentLookup | null>(null)
  const [allItems, setAllItems] = useState<TeachingAssignment[]>([])

  const [yearFilter, setYearFilter] = useState<number | ''>('')
  const [semesterFilter, setSemesterFilter] = useState<number | ''>('')
  const [classFilter, setClassFilter] = useState<number | ''>('')

  const [loadingInit, setLoadingInit] = useState(true)
  const [loadingList, setLoadingList] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [submitting, setSubmitting] = useState(false)

  const [modalOpen, setModalOpen] = useState(false)
  const [formMode, setFormMode] = useState<FormMode>('create')
  const [editing, setEditing] = useState<TeachingAssignment | null>(null)
  const [teacherId, setTeacherId] = useState<number | ''>('')
  const [subjectId, setSubjectId] = useState<number | ''>('')
  const [deleteTarget, setDeleteTarget] = useState<TeachingAssignment | null>(null)

  const filtersReady =
    yearFilter !== '' && semesterFilter !== '' && classFilter !== ''

  const semestersInYear = useMemo(() => {
    if (!lookup || yearFilter === '') return []
    return lookup.semesters.filter((s) => s.academicYearId === yearFilter)
  }, [lookup, yearFilter])

  const classesInYear = useMemo(() => {
    if (!lookup || yearFilter === '') return []
    return lookup.classes.filter((c) => c.academicYearId === yearFilter)
  }, [lookup, yearFilter])

  const activeSubjects = useMemo(
    () => lookup?.subjects.filter((s) => s.isActive) ?? [],
    [lookup],
  )

  const teacherNameById = useMemo(
    () => new Map(lookup?.teachers.map((t) => [t.id, t.fullName]) ?? []),
    [lookup],
  )

  const subjectNameById = useMemo(
    () => new Map(activeSubjects.map((s) => [s.subjectId, s.subjectName])),
    [activeSubjects],
  )

  const semesterNameById = useMemo(
    () => new Map(semestersInYear.map((s) => [s.semesterId, s.semesterName])),
    [semestersInYear],
  )

  const classNameById = useMemo(
    () => new Map(classesInYear.map((c) => [c.classId, c.className])),
    [classesInYear],
  )

  const items = useMemo(() => {
    if (!filtersReady) return []
    return allItems.filter(
      (ta) => ta.semesterId === semesterFilter && ta.classId === classFilter,
    )
  }, [allItems, filtersReady, semesterFilter, classFilter])

  const assignedSubjectIds = useMemo(
    () => new Set(items.map((ta) => ta.subjectId)),
    [items],
  )

  const availableSubjects = useMemo(() => {
    if (formMode === 'edit' && editing) {
      return activeSubjects.filter(
        (s) => s.subjectId === editing.subjectId || !assignedSubjectIds.has(s.subjectId),
      )
    }
    return activeSubjects.filter((s) => !assignedSubjectIds.has(s.subjectId))
  }, [activeSubjects, assignedSubjectIds, formMode, editing])

  const loadAssignments = useCallback(async () => {
    setLoadingList(true)
    setError(null)
    try {
      const data = await fetchTeachingAssignments()
      setAllItems(data)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Không tải được danh sách phân công.')
    } finally {
      setLoadingList(false)
    }
  }, [])

  useEffect(() => {
    void (async () => {
      setLoadingInit(true)
      setError(null)
      try {
        const lookupData = await fetchTeachingAssignmentLookup()
        setLookup(lookupData)
        if (lookupData.academicYears.length > 0) {
          const active = lookupData.academicYears.find((y) => y.isActive)
          const defaultYear =
            active?.academicYearId ?? lookupData.academicYears[0].academicYearId
          setYearFilter(defaultYear)

          const semesters = lookupData.semesters.filter(
            (s) => s.academicYearId === defaultYear,
          )
          const classes = lookupData.classes.filter(
            (c) => c.academicYearId === defaultYear,
          )
          if (semesters.length > 0) setSemesterFilter(semesters[0].semesterId)
          if (classes.length > 0) setClassFilter(classes[0].classId)
        }
        await loadAssignments()
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Không tải được dữ liệu ban đầu.')
      } finally {
        setLoadingInit(false)
      }
    })()
  }, [loadAssignments])

  function handleYearChange(yearId: number | '') {
    setYearFilter(yearId)
    setSemesterFilter('')
    setClassFilter('')
    if (yearId === '' || !lookup) return

    const semesters = lookup.semesters.filter((s) => s.academicYearId === yearId)
    const classes = lookup.classes.filter((c) => c.academicYearId === yearId)
    if (semesters.length > 0) setSemesterFilter(semesters[0].semesterId)
    if (classes.length > 0) setClassFilter(classes[0].classId)
  }

  function openCreate() {
    if (!filtersReady) {
      showToast(FILTER_EMPTY_MESSAGE, 'error')
      return
    }
    setFormMode('create')
    setEditing(null)
    setTeacherId('')
    setSubjectId('')
    setModalOpen(true)
  }

  function openEdit(row: TeachingAssignment) {
    setFormMode('edit')
    setEditing(row)
    setTeacherId(row.teacherId)
    setSubjectId(row.subjectId)
    setModalOpen(true)
  }

  function closeModal() {
    setModalOpen(false)
    setEditing(null)
    setTeacherId('')
    setSubjectId('')
  }

  async function handleSubmit(e: FormEvent) {
    e.preventDefault()
    if (!filtersReady || teacherId === '' || subjectId === '') {
      showToast('Vui lòng chọn giáo viên và môn học.', 'error')
      return
    }

    const payload = {
      teacherId,
      classId: classFilter as number,
      subjectId,
      semesterId: semesterFilter as number,
    }

    setSubmitting(true)
    try {
      if (formMode === 'edit' && editing) {
        await updateTeachingAssignment(editing.teachingAssignmentId, payload)
        showToast('Đã cập nhật phân công.', 'success')
      } else {
        await createTeachingAssignment(payload)
        showToast('Đã tạo phân công.', 'success')
      }
      closeModal()
      await loadAssignments()
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
      await deleteTeachingAssignment(deleteTarget.teachingAssignmentId)
      showToast('Đã xóa phân công.', 'success')
      setDeleteTarget(null)
      await loadAssignments()
    } catch (err) {
      showToast(err instanceof Error ? err.message : 'Xóa thất bại.', 'error')
    } finally {
      setSubmitting(false)
    }
  }

  const columns: DataTableColumn<TeachingAssignment>[] = [
    { key: 'teachingAssignmentId', header: 'ID' },
    {
      key: 'subjectName',
      header: 'Môn học',
      render: (row) => row.subjectName ?? subjectNameById.get(row.subjectId) ?? `#${row.subjectId}`,
    },
    {
      key: 'teacherId',
      header: 'Giáo viên',
      render: (row) => teacherNameById.get(row.teacherId) ?? `#${row.teacherId}`,
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

  const filterClassName = classFilter !== '' ? classNameById.get(classFilter) : undefined
  const filterSemesterName =
    semesterFilter !== '' ? semesterNameById.get(semesterFilter) : undefined

  return (
    <>
      <PageHeader
        title="Phân công giảng dạy"
        subtitle="Gán giáo viên dạy môn theo lớp và học kỳ"
        actions={
          <Button onClick={openCreate} disabled={loadingInit || submitting || !filtersReady}>
            Thêm phân công
          </Button>
        }
      />

      <div style={{ display: 'grid', gap: 16, maxWidth: 640, marginBottom: 24 }}>
        <div className="ui-field">
          <label htmlFor="ta-year-filter">Năm học</label>
          <select
            id="ta-year-filter"
            value={yearFilter}
            onChange={(e) => {
              const v = e.target.value
              handleYearChange(v === '' ? '' : Number(v))
            }}
            disabled={loadingInit || submitting || !lookup || lookup.academicYears.length === 0}
          >
            {!lookup || lookup.academicYears.length === 0 ? (
              <option value="">Chưa có năm học</option>
            ) : (
              lookup.academicYears.map((y) => (
                <option key={y.academicYearId} value={y.academicYearId}>
                  {y.yearName}
                  {y.isActive ? ' (đang dùng)' : ''}
                </option>
              ))
            )}
          </select>
        </div>

        <div className="ui-field">
          <label htmlFor="ta-semester-filter">Học kỳ</label>
          <select
            id="ta-semester-filter"
            value={semesterFilter}
            onChange={(e) => {
              const v = e.target.value
              setSemesterFilter(v === '' ? '' : Number(v))
            }}
            disabled={loadingInit || submitting || yearFilter === '' || semestersInYear.length === 0}
          >
            {yearFilter === '' ? (
              <option value="">Chọn năm học trước</option>
            ) : semestersInYear.length === 0 ? (
              <option value="">Chưa có học kỳ trong năm này</option>
            ) : (
              semestersInYear.map((s) => (
                <option key={s.semesterId} value={s.semesterId}>
                  {s.semesterName}
                </option>
              ))
            )}
          </select>
        </div>

        <div className="ui-field">
          <label htmlFor="ta-class-filter">Lớp học</label>
          <select
            id="ta-class-filter"
            value={classFilter}
            onChange={(e) => {
              const v = e.target.value
              setClassFilter(v === '' ? '' : Number(v))
            }}
            disabled={loadingInit || submitting || yearFilter === '' || classesInYear.length === 0}
          >
            {yearFilter === '' ? (
              <option value="">Chọn năm học trước</option>
            ) : classesInYear.length === 0 ? (
              <option value="">Chưa có lớp trong năm này</option>
            ) : (
              classesInYear.map((c) => (
                <option key={c.classId} value={c.classId}>
                  {c.className}
                </option>
              ))
            )}
          </select>
        </div>
      </div>

      {loadingInit && (
        <div className="state-panel">
          <Spinner size="lg" />
          <p className="state-panel__message">Đang tải dữ liệu…</p>
        </div>
      )}

      {!loadingInit && error && (
        <div className="state-panel state-panel--error">
          <p className="state-panel__title">Lỗi tải dữ liệu</p>
          <p className="state-panel__message">{error}</p>
          <Button onClick={() => void loadAssignments()}>Thử lại</Button>
        </div>
      )}

      {!loadingInit && !error && !filtersReady && (
        <EmptyState title="Chọn bộ lọc" message={FILTER_EMPTY_MESSAGE} />
      )}

      {!loadingInit && !error && filtersReady && loadingList && (
        <div className="state-panel">
          <Spinner size="lg" />
          <p className="state-panel__message">Đang tải phân công…</p>
        </div>
      )}

      {!loadingInit && !error && filtersReady && !loadingList && items.length === 0 && (
        <EmptyState
          title="Chưa có phân công"
          message={
            filterClassName && filterSemesterName
              ? `${filterClassName} — ${filterSemesterName} chưa có phân công. Nhấn «Thêm phân công».`
              : 'Nhấn «Thêm phân công» để bắt đầu.'
          }
          action={<Button onClick={openCreate}>Thêm phân công</Button>}
        />
      )}

      {!loadingInit && !error && filtersReady && !loadingList && items.length > 0 && (
        <DataTable columns={columns} data={items} rowKey={(row) => row.teachingAssignmentId} />
      )}

      <Modal
        open={modalOpen}
        title={formMode === 'edit' ? 'Sửa phân công' : 'Thêm phân công'}
        onClose={closeModal}
        footer={
          <>
            <Button variant="secondary" onClick={closeModal} disabled={submitting}>
              Hủy
            </Button>
            <Button type="submit" form="teaching-assignment-form" loading={submitting}>
              {formMode === 'edit' ? 'Lưu' : 'Thêm'}
            </Button>
          </>
        }
      >
        <form id="teaching-assignment-form" onSubmit={handleSubmit}>
          <div className="ui-field">
            <label htmlFor="ta-semester-display">Học kỳ</label>
            <input id="ta-semester-display" value={filterSemesterName ?? ''} disabled />
          </div>
          <div className="ui-field">
            <label htmlFor="ta-class-display">Lớp</label>
            <input id="ta-class-display" value={filterClassName ?? ''} disabled />
          </div>
          <div className="ui-field">
            <label htmlFor="ta-subject">Môn học *</label>
            <select
              id="ta-subject"
              value={subjectId}
              onChange={(e) => {
                const v = e.target.value
                setSubjectId(v === '' ? '' : Number(v))
              }}
              disabled={submitting}
            >
              <option value="">— Chọn môn học —</option>
              {availableSubjects.map((s) => (
                <option key={s.subjectId} value={s.subjectId}>
                  {s.subjectName} ({s.subjectCode})
                </option>
              ))}
            </select>
            {availableSubjects.length === 0 && (
              <p style={{ fontSize: 13, color: 'var(--color-text-muted)', margin: 0 }}>
                Không còn môn học khả dụng cho lớp và học kỳ này.
              </p>
            )}
          </div>
          <div className="ui-field">
            <label htmlFor="ta-teacher">Giáo viên *</label>
            <select
              id="ta-teacher"
              value={teacherId}
              onChange={(e) => {
                const v = e.target.value
                setTeacherId(v === '' ? '' : Number(v))
              }}
              disabled={submitting}
            >
              <option value="">— Chọn giáo viên —</option>
              {(lookup?.teachers ?? []).map((t) => (
                <option key={t.id} value={t.id}>
                  {t.fullName} ({t.username})
                </option>
              ))}
            </select>
          </div>
        </form>
      </Modal>

      <ConfirmDialog
        open={deleteTarget !== null}
        title="Xóa phân công"
        message={
          deleteTarget
            ? `Bạn có chắc muốn xóa phân công «${deleteTarget.subjectName ?? deleteTarget.subjectId}»?`
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
