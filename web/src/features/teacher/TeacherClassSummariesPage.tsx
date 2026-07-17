import { useCallback, useEffect, useMemo, useState } from 'react'
import DataTable, { type DataTableColumn } from '../../components/ui/DataTable'
import PageHeader from '../../components/ui/PageHeader'
import Spinner from '../../components/ui/Spinner'
import { useAuth } from '../../core/auth/AuthContext'
import {
  fetchClassSemesterSummary,
  fetchClassYearlySummary,
  fetchTeacherAcademicYears,
  fetchTeacherHomeroomClasses,
  fetchTeacherSemesters,
} from './api'
import type { ClassSemesterSummaryRow, ClassYearlySummaryRow, SchoolClass } from './types'
import type { AcademicYear } from '../academic-years/types'
import type { Semester } from '../semesters/types'

type SummaryTab = 'semester' | 'yearly'

function getAcademicYearSortKey(year: AcademicYear) {
  const parsed = Date.parse(year.startDate)
  if (!Number.isNaN(parsed)) return parsed

  const match = year.yearName.match(/^(\d{4})/)
  return match ? Number(match[1]) : year.academicYearId
}

function sortAcademicYears(years: AcademicYear[]) {
  return [...years].sort((a, b) => getAcademicYearSortKey(a) - getAcademicYearSortKey(b))
}

function getPreferredAcademicYearId(years: AcademicYear[]) {
  if (years.length === 0) return ''
  const sorted = sortAcademicYears(years)
  const active = sorted.filter((year) => year.isActive)
  return (active.at(-1) ?? sorted.at(-1))?.academicYearId ?? ''
}

export default function TeacherClassSummariesPage() {
  const { user } = useAuth()
  const teacherId = user?.id
  const [classes, setClasses] = useState<SchoolClass[]>([])
  const [classId, setClassId] = useState<number | ''>('')
  const [tab, setTab] = useState<SummaryTab>('semester')
  const [academicYears, setAcademicYears] = useState<AcademicYear[]>([])
  const [semesters, setSemesters] = useState<Semester[]>([])
  const [semesterId, setSemesterId] = useState<number | ''>('')
  const [academicYearId, setAcademicYearId] = useState<number | ''>('')
  const [semesterRows, setSemesterRows] = useState<ClassSemesterSummaryRow[]>([])
  const [yearlyRows, setYearlyRows] = useState<ClassYearlySummaryRow[]>([])
  const [loadingFilters, setLoadingFilters] = useState(true)
  const [loadingRows, setLoadingRows] = useState(false)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (!teacherId) return
    const id = teacherId

    let ignore = false
    async function loadFilters() {
      setLoadingFilters(true)
      setError(null)
      try {
        const [classData, yearData, semesterData] = await Promise.all([
          fetchTeacherHomeroomClasses(id),
          fetchTeacherAcademicYears(),
          fetchTeacherSemesters(),
        ])
        if (ignore) return

        const sortedYears = sortAcademicYears(yearData)
        const preferredYearId = getPreferredAcademicYearId(sortedYears)
        const semestersInYear = semesterData
          .filter((semester) => semester.academicYearId === preferredYearId)
          .sort((a, b) => a.semesterId - b.semesterId)

        setClasses(classData)
        setAcademicYears(sortedYears)
        setSemesters(semesterData)
        setAcademicYearId(preferredYearId)
        setSemesterId(semestersInYear[0]?.semesterId ?? '')
        setClassId(classData[0]?.classId ?? '')
      } catch (err) {
        if (!ignore) setError(err instanceof Error ? err.message : 'Không thể tải dữ liệu tổng kết lớp.')
      } finally {
        if (!ignore) setLoadingFilters(false)
      }
    }

    void loadFilters()
    return () => {
      ignore = true
    }
  }, [teacherId])

  const yearSemesters = useMemo(
    () =>
      semesters
        .filter((semester) => semester.academicYearId === academicYearId)
        .sort((a, b) => a.semesterId - b.semesterId),
    [academicYearId, semesters],
  )

  const loadSummary = useCallback(async () => {
    if (!classId) return

    setLoadingRows(true)
    setError(null)
    try {
      if (tab === 'semester') {
        if (!semesterId) {
          setSemesterRows([])
          setError('Chưa chọn học kỳ.')
          return
        }
        setSemesterRows(await fetchClassSemesterSummary(Number(classId), Number(semesterId)))
      } else {
        if (!academicYearId) {
          setYearlyRows([])
          setError('Chưa chọn năm học.')
          return
        }
        setYearlyRows(await fetchClassYearlySummary(Number(classId), Number(academicYearId)))
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Không thể tải tổng kết.')
    } finally {
      setLoadingRows(false)
    }
  }, [academicYearId, classId, semesterId, tab])

  useEffect(() => {
    const nextSemesterId = yearSemesters[0]?.semesterId ?? ''
    setSemesterId((current) => {
      if (current && yearSemesters.some((semester) => semester.semesterId === current)) return current
      return nextSemesterId
    })
  }, [yearSemesters])

  useEffect(() => {
    if (loadingFilters || !classId) return
    if (tab === 'semester' && !semesterId) {
      setSemesterRows([])
      return
    }
    if (tab === 'semester' && !yearSemesters.some((semester) => semester.semesterId === semesterId)) {
      setSemesterRows([])
      return
    }
    if (tab === 'yearly' && !academicYearId) {
      setYearlyRows([])
      return
    }
    void loadSummary()
  }, [academicYearId, classId, loadingFilters, loadSummary, semesterId, tab, yearSemesters])

  const semesterColumns: DataTableColumn<ClassSemesterSummaryRow>[] = [
    { key: 'order', header: 'STT', render: (_row, index) => index + 1 },
    { key: 'studentCode', header: 'Mã HS', render: (row) => row.studentCode ?? '-' },
    { key: 'studentName', header: 'Họ tên' },
    { key: 'gpa', header: 'GPA', render: (row) => row.gpa ?? '-' },
    { key: 'conduct', header: 'Hạnh kiểm', render: (row) => row.conduct ?? '-' },
    { key: 'rankName', header: 'Xếp loại', render: (row) => row.rankName ?? '-' },
    { key: 'isFinalized', header: 'Trạng thái', render: (row) => (row.isFinalized ? 'Đã chốt' : 'Chưa chốt') },
  ]

  const yearlyColumns: DataTableColumn<ClassYearlySummaryRow>[] = [
    { key: 'order', header: 'STT', render: (_row, index) => index + 1 },
    { key: 'studentCode', header: 'Mã HS', render: (row) => row.studentCode ?? '-' },
    { key: 'studentName', header: 'Họ tên' },
    { key: 'yearlyGpa', header: 'GPA năm', render: (row) => row.yearlyGpa ?? '-' },
    { key: 'yearlyConduct', header: 'Hạnh kiểm năm', render: (row) => row.yearlyConduct ?? '-' },
    { key: 'rankName', header: 'Xếp loại', render: (row) => row.rankName ?? '-' },
    { key: 'isFinalized', header: 'Trạng thái', render: (row) => (row.isFinalized ? 'Đã chốt' : 'Chưa chốt') },
  ]

  return (
    <>
      <PageHeader
        title="Tổng kết lớp"
        subtitle="Theo dõi kết quả học tập của lớp chủ nhiệm."
      />

      {loadingFilters ? (
        <div className="state-panel">
          <Spinner />
          <p className="state-panel__message">Đang tải dữ liệu tổng kết...</p>
        </div>
      ) : (
        <>
          <div className="ui-filters">
            <div className="ui-field">
              <label htmlFor="summary-year">Năm học</label>
              <select
                id="summary-year"
                value={academicYearId}
                onChange={(event) => setAcademicYearId(Number(event.target.value) || '')}
              >
                <option value="">Chọn năm học</option>
                {academicYears.map((year) => (
                  <option key={year.academicYearId} value={year.academicYearId}>
                    {year.yearName}
                  </option>
                ))}
              </select>
            </div>
            <div className="ui-field">
              <label htmlFor="summary-class">Lớp chủ nhiệm</label>
              <select
                id="summary-class"
                value={classId}
                onChange={(event) => setClassId(Number(event.target.value) || '')}
              >
                <option value="">Chọn lớp</option>
                {classes.map((cls) => (
                  <option key={cls.classId} value={cls.classId}>
                    {cls.className}
                  </option>
                ))}
              </select>
            </div>
            {tab === 'semester' && (
              <div className="ui-field">
                <label htmlFor="summary-semester">Học kỳ</label>
                <select
                  id="summary-semester"
                  value={semesterId}
                  onChange={(event) => setSemesterId(Number(event.target.value) || '')}
                >
                  <option value="">Chọn học kỳ</option>
                  {yearSemesters.map((semester) => (
                    <option key={semester.semesterId} value={semester.semesterId}>
                      {semester.semesterName}
                    </option>
                  ))}
                </select>
              </div>
            )}
          </div>

          <div className="teacher-tabs" role="tablist" aria-label="Loại tổng kết">
            <button
              type="button"
              className={tab === 'semester' ? 'teacher-tabs__item teacher-tabs__item--active' : 'teacher-tabs__item'}
              onClick={() => setTab('semester')}
            >
              Học kỳ
            </button>
            <button
              type="button"
              className={tab === 'yearly' ? 'teacher-tabs__item teacher-tabs__item--active' : 'teacher-tabs__item'}
              onClick={() => setTab('yearly')}
            >
              Cả năm
            </button>
          </div>

          {error && <p className="teacher-alert">{error}</p>}

          {loadingRows ? (
            <div className="state-panel">
              <Spinner />
              <p className="state-panel__message">Đang tải tổng kết...</p>
            </div>
          ) : tab === 'semester' ? (
            <DataTable
              columns={semesterColumns}
              data={semesterRows}
              rowKey={(row) => row.studentId}
              emptyMessage="Chưa có dữ liệu tổng kết học kỳ."
            />
          ) : (
            <DataTable
              columns={yearlyColumns}
              data={yearlyRows}
              rowKey={(row) => row.studentId}
              emptyMessage="Chưa có dữ liệu tổng kết năm."
            />
          )}
        </>
      )}
    </>
  )
}
