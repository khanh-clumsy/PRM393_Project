import { type FormEvent, useCallback, useEffect, useMemo, useRef, useState } from 'react'
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
import { fetchClassesByYear } from '../classes/api'
import type { SchoolClass } from '../classes/types'
import {
  createStudentClass,
  deleteStudentClass,
  fetchStudentClassesByClass,
  fetchStudents,
} from './api'
import type { StudentClass, StudentOption } from './types'

/** Quản lý phân lớp học sinh — lọc năm → lớp, cache HS đã phân theo năm */
export default function StudentClassPage() {
  const { showToast } = useToast()
  const [years, setYears] = useState<AcademicYear[]>([])
  const [yearFilter, setYearFilter] = useState<number | ''>('')
  const [classesInYear, setClassesInYear] = useState<SchoolClass[]>([])
  const [classFilter, setClassFilter] = useState<number | ''>('')
  const [students, setStudents] = useState<StudentOption[]>([])
  const [items, setItems] = useState<StudentClass[]>([])
  const [yearAssignedIds, setYearAssignedIds] = useState<Set<number>>(new Set())

  const [loadingInit, setLoadingInit] = useState(true)
  const [loadingList, setLoadingList] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [submitting, setSubmitting] = useState(false)

  const [modalOpen, setModalOpen] = useState(false)
  const [selectedStudentId, setSelectedStudentId] = useState<number | ''>('')
  const [deleteTarget, setDeleteTarget] = useState<StudentClass | null>(null)

  // Cache HS đã phân lớp theo năm — tránh gọi lại khi đổi lớp trong cùng năm
  const yearCacheRef = useRef<Map<number, Set<number>>>(new Map())

  const yearNameById = useMemo(
    () => new Map(years.map((y) => [y.academicYearId, y.yearName])),
    [years],
  )

  const classNameById = useMemo(
    () => new Map(classesInYear.map((c) => [c.classId, c.className])),
    [classesInYear],
  )

  const invalidateYearCache = useCallback((yearId: number) => {
    yearCacheRef.current.delete(yearId)
  }, [])

  /** Tải cache HS đã phân trong tất cả lớp của năm (một lần / năm) */
  const loadYearAssignedCache = useCallback(
    async (yearId: number, classes: SchoolClass[]) => {
      const cached = yearCacheRef.current.get(yearId)
      if (cached) {
        setYearAssignedIds(new Set(cached))
        return
      }

      const ids = new Set<number>()
      for (const cls of classes) {
        const list = await fetchStudentClassesByClass(cls.classId)
        for (const sc of list) ids.add(sc.studentId)
      }
      yearCacheRef.current.set(yearId, ids)
      setYearAssignedIds(new Set(ids))
    },
    [],
  )

  const loadClassesForYear = useCallback(
    async (yearId: number) => {
      setLoadingList(true)
      setError(null)
      try {
        const data = await fetchClassesByYear(yearId)
        setClassesInYear(data)
        if (data.length === 0) {
          setClassFilter('')
          setItems([])
          setYearAssignedIds(new Set())
          return
        }
        const firstClassId = data[0].classId
        setClassFilter(firstClassId)
        await loadYearAssignedCache(yearId, data)
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Không tải được dữ liệu lớp học.')
      } finally {
        setLoadingList(false)
      }
    },
    [loadYearAssignedCache],
  )

  const loadStudentClasses = useCallback(async (classId: number) => {
    setLoadingList(true)
    setError(null)
    try {
      const data = await fetchStudentClassesByClass(classId)
      setItems(data)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Không tải được danh sách học sinh.')
    } finally {
      setLoadingList(false)
    }
  }, [])

  useEffect(() => {
    void (async () => {
      setLoadingInit(true)
      setError(null)
      try {
        const [yearData, studentData] = await Promise.all([
          fetchAcademicYears(),
          fetchStudents(),
        ])
        setYears(yearData)
        setStudents(studentData)
        if (yearData.length > 0) {
          const active = yearData.find((y) => y.isActive)
          const defaultYear = active?.academicYearId ?? yearData[0].academicYearId
          setYearFilter(defaultYear)
        }
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Không tải được dữ liệu ban đầu.')
      } finally {
        setLoadingInit(false)
      }
    })()
  }, [])

  useEffect(() => {
    if (yearFilter === '') return
    void loadClassesForYear(yearFilter)
  }, [yearFilter, loadClassesForYear])

  useEffect(() => {
    if (classFilter === '' || yearFilter === '') return
    void loadStudentClasses(classFilter)
  }, [classFilter, yearFilter, loadStudentClasses])

  const availableStudents = useMemo(() => {
    const inCurrentClass = new Set(items.map((sc) => sc.studentId))
    return students.filter(
      (s) => !inCurrentClass.has(s.id) && !yearAssignedIds.has(s.id),
    )
  }, [students, items, yearAssignedIds])

  function openCreate() {
    if (classFilter === '') {
      showToast('Vui lòng chọn lớp học trước.', 'error')
      return
    }
    setSelectedStudentId('')
    setModalOpen(true)
  }

  function closeModal() {
    setModalOpen(false)
    setSelectedStudentId('')
  }

  async function handleSubmit(e: FormEvent) {
    e.preventDefault()
    if (classFilter === '' || selectedStudentId === '') {
      showToast('Vui lòng chọn học sinh.', 'error')
      return
    }

    setSubmitting(true)
    try {
      await createStudentClass({ studentId: selectedStudentId, classId: classFilter })
      showToast('Đã thêm học sinh vào lớp.', 'success')
      closeModal()
      if (yearFilter !== '') invalidateYearCache(yearFilter)
      await loadStudentClasses(classFilter)
      if (yearFilter !== '' && classesInYear.length > 0) {
        await loadYearAssignedCache(yearFilter, classesInYear)
      }
    } catch (err) {
      showToast(err instanceof Error ? err.message : 'Thêm học sinh thất bại.', 'error')
    } finally {
      setSubmitting(false)
    }
  }

  async function handleDeleteConfirm() {
    if (!deleteTarget || classFilter === '') return
    setSubmitting(true)
    try {
      await deleteStudentClass(deleteTarget.studentClassId)
      showToast('Đã xóa học sinh khỏi lớp.', 'success')
      setDeleteTarget(null)
      if (yearFilter !== '') invalidateYearCache(yearFilter)
      await loadStudentClasses(classFilter)
      if (yearFilter !== '' && classesInYear.length > 0) {
        await loadYearAssignedCache(yearFilter, classesInYear)
      }
    } catch (err) {
      showToast(err instanceof Error ? err.message : 'Xóa thất bại.', 'error')
    } finally {
      setSubmitting(false)
    }
  }

  const columns: DataTableColumn<StudentClass>[] = [
    { key: 'studentClassId', header: 'ID' },
    {
      key: 'studentName',
      header: 'Học sinh',
      render: (row) => row.studentName ?? `#${row.studentId}`,
    },
    {
      key: 'studentCode',
      header: 'Mã HS',
      render: (row) => row.studentCode ?? '—',
    },
    {
      key: 'actions',
      header: 'Thao tác',
      render: (row) => (
        <div className="data-table__actions">
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

  const loading = loadingInit || loadingList
  const filterYearName = yearFilter !== '' ? yearNameById.get(yearFilter) : undefined
  const filterClassName = classFilter !== '' ? classNameById.get(classFilter) : undefined

  return (
    <>
      <PageHeader
        title="Phân lớp học sinh"
        subtitle="Gán học sinh vào lớp theo năm học"
        actions={
          <Button
            onClick={openCreate}
            disabled={loading || submitting || classFilter === ''}
          >
            Thêm học sinh
          </Button>
        }
      />

      <div className="ui-filters">
        <div className="ui-field">
          <label htmlFor="sc-year-filter">Năm học</label>
          <select
            id="sc-year-filter"
            value={yearFilter}
            onChange={(e) => {
              const v = e.target.value
              setYearFilter(v === '' ? '' : Number(v))
              setClassFilter('')
              setItems([])
            }}
            disabled={loadingInit || submitting || years.length === 0}
          >
            {years.length === 0 ? (
              <option value="">Chưa có năm học</option>
            ) : (
              years.map((y) => (
                <option key={y.academicYearId} value={y.academicYearId}>
                  {y.yearName}
                </option>
              ))
            )}
          </select>
        </div>

        <div className="ui-field">
          <label htmlFor="sc-class-filter">Lớp học</label>
          <select
            id="sc-class-filter"
            value={classFilter}
            onChange={(e) => {
              const v = e.target.value
              setClassFilter(v === '' ? '' : Number(v))
            }}
            disabled={loading || submitting || classesInYear.length === 0}
          >
            {classesInYear.length === 0 ? (
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
          <Button
            onClick={() => {
              if (yearFilter !== '') void loadClassesForYear(yearFilter)
              else window.location.reload()
            }}
          >
            Thử lại
          </Button>
        </div>
      )}

      {!loadingInit && !error && years.length === 0 && (
        <EmptyState
          title="Chưa có năm học"
          message="Hãy tạo năm học và lớp trước khi phân lớp học sinh."
        />
      )}

      {!loadingInit && !error && years.length > 0 && classesInYear.length === 0 && (
        <EmptyState
          title="Chưa có lớp học"
          message={
            filterYearName
              ? `Năm ${filterYearName} chưa có lớp. Hãy tạo lớp trước.`
              : 'Hãy tạo lớp học trước khi phân học sinh.'
          }
        />
      )}

      {!loadingInit && !error && classFilter !== '' && loadingList && (
        <div className="state-panel">
          <Spinner size="lg" />
          <p className="state-panel__message">Đang tải danh sách học sinh…</p>
        </div>
      )}

      {!loadingInit && !error && classFilter !== '' && !loadingList && items.length === 0 && (
        <EmptyState
          title="Chưa có học sinh"
          message={
            filterClassName
              ? `Lớp ${filterClassName} chưa có học sinh. Nhấn «Thêm học sinh».`
              : 'Nhấn «Thêm học sinh» để phân lớp.'
          }
          action={<Button onClick={openCreate}>Thêm học sinh</Button>}
        />
      )}

      {!loadingInit && !error && !loadingList && items.length > 0 && (
        <DataTable columns={columns} data={items} rowKey={(row) => row.studentClassId} />
      )}

      <Modal
        open={modalOpen}
        title="Thêm học sinh vào lớp"
        onClose={closeModal}
        footer={
          <>
            <Button variant="secondary" onClick={closeModal} disabled={submitting}>
              Hủy
            </Button>
            <Button type="submit" form="student-class-form" loading={submitting}>
              Thêm
            </Button>
          </>
        }
      >
        <form id="student-class-form" onSubmit={handleSubmit}>
          <div className="ui-field">
            <label htmlFor="sc-class-display">Lớp</label>
            <input id="sc-class-display" value={filterClassName ?? ''} disabled />
          </div>
          <div className="ui-field">
            <label htmlFor="sc-student">Học sinh *</label>
            <select
              id="sc-student"
              value={selectedStudentId}
              onChange={(e) => {
                const v = e.target.value
                setSelectedStudentId(v === '' ? '' : Number(v))
              }}
              disabled={submitting}
            >
              <option value="">— Chọn học sinh —</option>
              {availableStudents.map((s) => (
                <option key={s.id} value={s.id}>
                  {s.fullName} ({s.username})
                </option>
              ))}
            </select>
          </div>
        </form>
      </Modal>

      <ConfirmDialog
        open={deleteTarget !== null}
        title="Xóa khỏi lớp"
        message={
          deleteTarget
            ? `Bạn có chắc muốn xóa «${deleteTarget.studentName ?? deleteTarget.studentId}» khỏi lớp?`
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
