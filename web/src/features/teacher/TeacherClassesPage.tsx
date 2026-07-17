import { useEffect, useMemo, useState } from 'react'
import Button from '../../components/ui/Button'
import DataTable, { type DataTableColumn } from '../../components/ui/DataTable'
import PageHeader from '../../components/ui/PageHeader'
import Spinner from '../../components/ui/Spinner'
import { useAuth } from '../../core/auth/AuthContext'
import {
  fetchClassStudents,
  fetchTeacherAcademicYears,
  fetchTeacherAssignments,
  fetchTeacherHomeroomClasses,
  fetchTeacherSemesters,
} from './api'
import type { AcademicYear } from '../academic-years/types'
import type { Semester } from '../semesters/types'
import type { SchoolClass, StudentClass, TeacherClass, TeachingAssignment } from './types'
import {
  getAssignmentsForSemester,
  getPreferredAcademicYearId,
  getRoleLabel,
  getSemestersForYear,
  mergeTeacherClasses,
  sortAcademicYears,
} from './utils'

export default function TeacherClassesPage() {
  const { user } = useAuth()
  const teacherId = user?.id
  const [academicYears, setAcademicYears] = useState<AcademicYear[]>([])
  const [semesters, setSemesters] = useState<Semester[]>([])
  const [assignments, setAssignments] = useState<TeachingAssignment[]>([])
  const [homeroomClasses, setHomeroomClasses] = useState<SchoolClass[]>([])
  const [yearId, setYearId] = useState<number | ''>('')
  const [semesterId, setSemesterId] = useState<number | ''>('')
  const [classes, setClasses] = useState<TeacherClass[]>([])
  const [selectedClassId, setSelectedClassId] = useState<number | ''>('')
  const [students, setStudents] = useState<StudentClass[]>([])
  const [loading, setLoading] = useState(true)
  const [studentsLoading, setStudentsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (!teacherId) return
    const id = teacherId

    let ignore = false
    async function load() {
      setLoading(true)
      setError(null)
      try {
        const [assignmentData, homeroomData, yearData, semesterData] = await Promise.all([
          fetchTeacherAssignments(id),
          fetchTeacherHomeroomClasses(id),
          fetchTeacherAcademicYears(),
          fetchTeacherSemesters(),
        ])
        if (ignore) return

        const sortedYears = sortAcademicYears(yearData)
        const defaultYear = getPreferredAcademicYearId(sortedYears)
        const defaultSemester = getSemestersForYear(semesterData, defaultYear)[0]?.semesterId ?? ''

        setAssignments(assignmentData)
        setHomeroomClasses(homeroomData)
        setAcademicYears(sortedYears)
        setSemesters(semesterData)
        setYearId(defaultYear)
        setSemesterId(defaultSemester)
      } catch (err) {
        if (!ignore) setError(err instanceof Error ? err.message : 'Không thể tải lớp.')
      } finally {
        if (!ignore) setLoading(false)
      }
    }

    void load()
    return () => {
      ignore = true
    }
  }, [teacherId])

  const filteredSemesters = useMemo(
    () => getSemestersForYear(semesters, yearId),
    [semesters, yearId],
  )

  const filteredAssignments = useMemo(
    () => getAssignmentsForSemester(assignments, semesterId),
    [assignments, semesterId],
  )

  const filteredHomeroomClasses = useMemo(
    () =>
      yearId === ''
        ? []
        : homeroomClasses.filter((cls) => cls.academicYearId === yearId),
    [homeroomClasses, yearId],
  )

  useEffect(() => {
    const nextSemester = filteredSemesters[0]?.semesterId ?? ''
    setSemesterId((current) =>
      current !== '' && filteredSemesters.some((semester) => semester.semesterId === current)
        ? current
        : nextSemester,
    )
  }, [filteredSemesters])

  useEffect(() => {
    const nextClasses = mergeTeacherClasses(filteredAssignments, filteredHomeroomClasses)
    setClasses(nextClasses)
    setSelectedClassId((current) =>
      current !== '' && nextClasses.some((cls) => cls.classId === current)
        ? current
        : nextClasses[0]?.classId ?? '',
    )
  }, [filteredAssignments, filteredHomeroomClasses])

  useEffect(() => {
    if (!selectedClassId) {
      setStudents([])
      return
    }

    let ignore = false
    async function loadStudents() {
      setStudentsLoading(true)
      try {
        const data = await fetchClassStudents(Number(selectedClassId))
        if (!ignore) setStudents(data)
      } catch {
        if (!ignore) setStudents([])
      } finally {
        if (!ignore) setStudentsLoading(false)
      }
    }

    void loadStudents()
    return () => {
      ignore = true
    }
  }, [selectedClassId])

  const selectedClass = useMemo(
    () => classes.find((cls) => cls.classId === selectedClassId),
    [classes, selectedClassId],
  )

  const classColumns: DataTableColumn<TeacherClass>[] = [
    { key: 'order', header: 'STT', render: (_row, index) => index + 1 },
    { key: 'className', header: 'Lớp' },
    {
      key: 'role',
      header: 'Vai trò',
      render: (row) => <span className={`teacher-badge teacher-badge--${row.role}`}>{getRoleLabel(row.role)}</span>,
    },
    {
      key: 'subjects',
      header: 'Môn giảng dạy',
      render: (row) =>
        row.assignments.length > 0
          ? row.assignments.map((item) => item.subjectName ?? `Môn #${item.subjectId}`).join(', ')
          : 'Không có phân công',
    },
    {
      key: 'actions',
      header: '',
      render: (row) => (
        <Button
          size="sm"
          variant={row.classId === selectedClassId ? 'primary' : 'secondary'}
          onClick={() => setSelectedClassId(row.classId)}
        >
          Xem danh sách
        </Button>
      ),
    },
  ]

  const studentColumns: DataTableColumn<StudentClass>[] = [
    { key: 'order', header: 'STT', render: (_row, index) => index + 1 },
    { key: 'studentCode', header: 'Mã học sinh', render: (row) => row.studentCode ?? '-' },
    { key: 'studentName', header: 'Họ tên', render: (row) => row.studentName ?? `HS #${row.studentId}` },
  ]

  return (
    <>
      <PageHeader
        title="Lớp của tôi"
        subtitle="Lớp giảng dạy và lớp chủ nhiệm."
      />

      {loading ? (
        <div className="state-panel">
          <Spinner />
          <p className="state-panel__message">Đang tải lớp...</p>
        </div>
      ) : error ? (
        <div className="state-panel state-panel--error">
          <p className="state-panel__title">Không thể tải dữ liệu</p>
          <p className="state-panel__message">{error}</p>
        </div>
      ) : (
        <>
          <div className="ui-filters">
            <div className="ui-field">
              <label htmlFor="class-year">Năm học</label>
              <select
                id="class-year"
                value={yearId}
                onChange={(event) => setYearId(Number(event.target.value) || '')}
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
              <label htmlFor="class-semester">Học kỳ</label>
              <select
                id="class-semester"
                value={semesterId}
                onChange={(event) => setSemesterId(Number(event.target.value) || '')}
                disabled={yearId === ''}
              >
                <option value="">Chọn học kỳ</option>
                {filteredSemesters.map((semester) => (
                  <option key={semester.semesterId} value={semester.semesterId}>
                    {semester.semesterName}
                  </option>
                ))}
              </select>
            </div>
          </div>

          <div className="teacher-split">
            <section>
            <DataTable
              columns={classColumns}
              data={classes}
              rowKey={(row) => row.classId}
              emptyMessage="Chưa có lớp giảng dạy hoặc chủ nhiệm."
            />
            </section>

            <section className="teacher-section teacher-section--flush">
            <h2>Danh sách học sinh {selectedClass ? `· ${selectedClass.className}` : ''}</h2>
            {studentsLoading ? (
              <div className="state-panel">
                <Spinner />
                <p className="state-panel__message">Đang tải danh sách học sinh...</p>
              </div>
            ) : (
              <DataTable
                columns={studentColumns}
                data={students}
                rowKey={(row) => row.studentClassId}
                emptyMessage="Chưa có học sinh trong lớp."
              />
            )}
            </section>
          </div>
        </>
      )}
    </>
  )
}
