import { useEffect, useState } from 'react'
import DataTable, { type DataTableColumn } from '../../components/ui/DataTable'
import PageHeader from '../../components/ui/PageHeader'
import Spinner from '../../components/ui/Spinner'
import { useAuth } from '../../core/auth/AuthContext'
import {
  fetchClassSemesterSummary,
  fetchClassYearlySummary,
  fetchTeacherHomeroomClasses,
} from './api'
import type { ClassSemesterSummaryRow, ClassYearlySummaryRow, SchoolClass } from './types'

type SummaryTab = 'semester' | 'yearly'

export default function TeacherClassSummariesPage() {
  const { user } = useAuth()
  const teacherId = user?.id
  const [classes, setClasses] = useState<SchoolClass[]>([])
  const [classId, setClassId] = useState<number | ''>('')
  const [tab, setTab] = useState<SummaryTab>('semester')
  const [semesterId, setSemesterId] = useState('')
  const [academicYearId, setAcademicYearId] = useState('')
  const [semesterRows, setSemesterRows] = useState<ClassSemesterSummaryRow[]>([])
  const [yearlyRows, setYearlyRows] = useState<ClassYearlySummaryRow[]>([])
  const [loadingClasses, setLoadingClasses] = useState(true)
  const [loadingRows, setLoadingRows] = useState(false)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (!teacherId) return
    const id = teacherId

    let ignore = false
    async function loadClasses() {
      setLoadingClasses(true)
      setError(null)
      try {
        const data = await fetchTeacherHomeroomClasses(id)
        if (ignore) return
        setClasses(data)
        setClassId(data[0]?.classId ?? '')
        setAcademicYearId(data[0]?.academicYearId ? String(data[0].academicYearId) : '')
      } catch (err) {
        if (!ignore) setError(err instanceof Error ? err.message : 'Không thể tải lớp chủ nhiệm.')
      } finally {
        if (!ignore) setLoadingClasses(false)
      }
    }

    void loadClasses()
    return () => {
      ignore = true
    }
  }, [teacherId])

  useEffect(() => {
    if (!classId) return
    const selected = classes.find((cls) => cls.classId === classId)
    if (selected?.academicYearId) setAcademicYearId(String(selected.academicYearId))
  }, [classId, classes])

  async function loadSummary() {
    if (!classId) return

    setLoadingRows(true)
    setError(null)
    try {
      if (tab === 'semester') {
        if (!semesterId.trim()) {
          setSemesterRows([])
          setError('Nhập semesterId để xem tổng kết học kỳ.')
          return
        }
        setSemesterRows(await fetchClassSemesterSummary(Number(classId), Number(semesterId)))
      } else {
        if (!academicYearId.trim()) {
          setYearlyRows([])
          setError('Nhập academicYearId để xem tổng kết năm.')
          return
        }
        setYearlyRows(await fetchClassYearlySummary(Number(classId), Number(academicYearId)))
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Không thể tải tổng kết.')
    } finally {
      setLoadingRows(false)
    }
  }

  const semesterColumns: DataTableColumn<ClassSemesterSummaryRow>[] = [
    { key: 'studentCode', header: 'Mã HS', render: (row) => row.studentCode ?? '-' },
    { key: 'studentName', header: 'Họ tên' },
    { key: 'gpa', header: 'GPA', render: (row) => row.gpa ?? '-' },
    { key: 'conduct', header: 'Hạnh kiểm', render: (row) => row.conduct ?? '-' },
    { key: 'rankName', header: 'Xếp loại', render: (row) => row.rankName ?? '-' },
    { key: 'isFinalized', header: 'Trạng thái', render: (row) => (row.isFinalized ? 'Đã chốt' : 'Chưa chốt') },
  ]

  const yearlyColumns: DataTableColumn<ClassYearlySummaryRow>[] = [
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
        subtitle="Chỉ đọc dữ liệu tổng kết cho lớp giáo viên chủ nhiệm."
      />

      {loadingClasses ? (
        <div className="state-panel">
          <Spinner />
          <p className="state-panel__message">Đang tải lớp chủ nhiệm...</p>
        </div>
      ) : (
        <>
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

          <div className="ui-filters">
            <div className="ui-field">
              <label htmlFor="summary-class">Lớp GVCN</label>
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
            {tab === 'semester' ? (
              <div className="ui-field">
                <label htmlFor="summary-semester">Semester ID</label>
                <input
                  id="summary-semester"
                  value={semesterId}
                  onChange={(event) => setSemesterId(event.target.value)}
                  inputMode="numeric"
                />
              </div>
            ) : (
              <div className="ui-field">
                <label htmlFor="summary-year">AcademicYear ID</label>
                <input
                  id="summary-year"
                  value={academicYearId}
                  onChange={(event) => setAcademicYearId(event.target.value)}
                  inputMode="numeric"
                />
              </div>
            )}
            <div className="ui-field teacher-filter-action">
              <label>&nbsp;</label>
              <button className="ui-btn ui-btn--primary" type="button" onClick={() => void loadSummary()}>
                Xem tổng kết
              </button>
            </div>
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
