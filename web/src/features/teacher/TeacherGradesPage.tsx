import { useEffect, useMemo, useState } from 'react'
import Button from '../../components/ui/Button'
import DataTable, { type DataTableColumn } from '../../components/ui/DataTable'
import PageHeader from '../../components/ui/PageHeader'
import Spinner from '../../components/ui/Spinner'
import { useAuth } from '../../core/auth/AuthContext'
import {
  fetchAssessmentTypes,
  fetchClassGradesByType,
  fetchTeacherAcademicYears,
  fetchTeacherAssignments,
  fetchTeacherSemesters,
  saveGradesByType,
} from './api'
import type { AcademicYear } from '../academic-years/types'
import type { Semester } from '../semesters/types'
import type { AssessmentType, GradeDraft, TeachingAssignment } from './types'
import { hasGradeErrors, parseGradeInput } from './utils'

export default function TeacherGradesPage() {
  const { user } = useAuth()
  const teacherId = user?.id
  const [academicYears, setAcademicYears] = useState<AcademicYear[]>([])
  const [semesters, setSemesters] = useState<Semester[]>([])
  const [assignments, setAssignments] = useState<TeachingAssignment[]>([])
  const [assessmentTypes, setAssessmentTypes] = useState<AssessmentType[]>([])
  const [yearId, setYearId] = useState<number | ''>('')
  const [semesterId, setSemesterId] = useState<number | ''>('')
  const [classId, setClassId] = useState<number | ''>('')
  const [assignmentId, setAssignmentId] = useState<number | ''>('')
  const [assessmentTypeId, setAssessmentTypeId] = useState<number | ''>('')
  const [rows, setRows] = useState<GradeDraft[]>([])
  const [loading, setLoading] = useState(true)
  const [loadingRows, setLoadingRows] = useState(false)
  const [saving, setSaving] = useState(false)
  const [message, setMessage] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (!teacherId) return
    const id = teacherId

    let ignore = false
    async function loadLookups() {
      setLoading(true)
      setError(null)
      try {
        const [assignmentData, typeData, yearData, semesterData] = await Promise.all([
          fetchTeacherAssignments(id),
          fetchAssessmentTypes(),
          fetchTeacherAcademicYears(),
          fetchTeacherSemesters(),
        ])
        if (ignore) return
        setAcademicYears(yearData)
        setSemesters(semesterData)
        setAssignments(assignmentData)
        setAssessmentTypes(typeData)
        const defaultYear =
          yearData.find((year) => year.isActive)?.academicYearId ?? yearData[0]?.academicYearId ?? ''
        setYearId(defaultYear)
        setAssessmentTypeId(typeData[0]?.assessmentTypeId ?? '')
      } catch (err) {
        if (!ignore) setError(err instanceof Error ? err.message : 'Không thể tải dữ liệu nhập điểm.')
      } finally {
        if (!ignore) setLoading(false)
      }
    }

    void loadLookups()
    return () => {
      ignore = true
    }
  }, [teacherId])

  const semestersInYear = useMemo(() => {
    if (yearId === '') return []
    return semesters.filter((semester) => semester.academicYearId === yearId)
  }, [semesters, yearId])

  const assignmentsInSemester = useMemo(() => {
    if (semesterId === '') return []
    return assignments.filter((assignment) => assignment.semesterId === semesterId)
  }, [assignments, semesterId])

  const classOptions = useMemo(() => {
    const byClass = new Map<number, string>()
    for (const assignment of assignmentsInSemester) {
      byClass.set(assignment.classId, assignment.className ?? `Lớp #${assignment.classId}`)
    }
    return [...byClass.entries()]
      .map(([id, name]) => ({ id, name }))
      .sort((a, b) => a.name.localeCompare(b.name, 'vi'))
  }, [assignmentsInSemester])

  const assignmentsInClass = useMemo(() => {
    if (classId === '') return []
    return assignmentsInSemester.filter((assignment) => assignment.classId === classId)
  }, [assignmentsInSemester, classId])

  useEffect(() => {
    const nextSemester = semestersInYear[0]?.semesterId ?? ''
    setSemesterId((current) =>
      current !== '' && semestersInYear.some((semester) => semester.semesterId === current)
        ? current
        : nextSemester,
    )
  }, [semestersInYear])

  useEffect(() => {
    const nextClass = classOptions[0]?.id ?? ''
    setClassId((current) =>
      current !== '' && classOptions.some((option) => option.id === current)
        ? current
        : nextClass,
    )
  }, [classOptions])

  useEffect(() => {
    const nextAssignment = assignmentsInClass[0]?.teachingAssignmentId ?? ''
    setAssignmentId((current) =>
      current !== '' &&
      assignmentsInClass.some((assignment) => assignment.teachingAssignmentId === current)
        ? current
        : nextAssignment,
    )
  }, [assignmentsInClass])

  useEffect(() => {
    if (!assignmentId || !assessmentTypeId) {
      setRows([])
      return
    }

    let ignore = false
    async function loadRows() {
      setLoadingRows(true)
      setMessage(null)
      setError(null)
      try {
        const data = await fetchClassGradesByType(Number(assignmentId), Number(assessmentTypeId))
        if (!ignore) {
          setRows(
            data.map((row) => ({
              ...row,
              scoreInput: row.score === null ? '' : String(row.score),
              error: null,
            })),
          )
        }
      } catch (err) {
        if (!ignore) setError(err instanceof Error ? err.message : 'Không thể tải bảng điểm.')
      } finally {
        if (!ignore) setLoadingRows(false)
      }
    }

    void loadRows()
    return () => {
      ignore = true
    }
  }, [assignmentId, assessmentTypeId])

  function updateScore(studentId: number, value: string) {
    const parsed = parseGradeInput(value)
    setRows((current) =>
      current.map((row) =>
        row.studentId === studentId ? { ...row, scoreInput: value, error: parsed.error } : row,
      ),
    )
  }

  function updateComment(studentId: number, comment: string) {
    setRows((current) =>
      current.map((row) => (row.studentId === studentId ? { ...row, comment } : row)),
    )
  }

  async function save() {
    if (!assignmentId || !assessmentTypeId || hasGradeErrors(rows)) return

    setSaving(true)
    setError(null)
    setMessage(null)
    try {
      await saveGradesByType({
        teachingAssignmentId: Number(assignmentId),
        assessmentTypeId: Number(assessmentTypeId),
        students: rows.map((row) => ({
          studentId: row.studentId,
          score: parseGradeInput(row.scoreInput).score,
          comment: row.comment?.trim() || null,
        })),
      })
      setMessage('Đã lưu bảng điểm.')
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Không thể lưu bảng điểm.')
    } finally {
      setSaving(false)
    }
  }

  const selectedAssignment = useMemo(
    () => assignments.find((item) => item.teachingAssignmentId === assignmentId),
    [assignmentId, assignments],
  )

  const columns: DataTableColumn<GradeDraft>[] = [
    { key: 'order', header: 'STT', render: (_row, index) => index + 1 },
    { key: 'username', header: 'Mã HS', render: (row) => row.username || '-' },
    { key: 'studentName', header: 'Họ tên' },
    {
      key: 'score',
      header: 'Điểm',
      render: (row) => (
        <div>
          <input
            className={`teacher-input-inline${row.error ? ' teacher-input-inline--error' : ''}`}
            value={row.scoreInput}
            onChange={(event) => updateScore(row.studentId, event.target.value)}
            placeholder="0..10"
            inputMode="decimal"
          />
          {row.error && <p className="teacher-field-error">{row.error}</p>}
        </div>
      ),
    },
    {
      key: 'comment',
      header: 'Nhận xét',
      render: (row) => (
        <input
          className="teacher-input-inline"
          value={row.comment ?? ''}
          onChange={(event) => updateComment(row.studentId, event.target.value)}
          placeholder="Nhận xét"
        />
      ),
    },
  ]

  return (
    <>
      <PageHeader
        title="Nhập điểm"
        subtitle="Nhập điểm cho các lớp và môn được phân công."
        actions={
          <Button
            loading={saving}
            disabled={!assignmentId || !assessmentTypeId || rows.length === 0 || hasGradeErrors(rows)}
            onClick={save}
          >
            Lưu điểm
          </Button>
        }
      />

      {loading ? (
        <div className="state-panel">
          <Spinner />
          <p className="state-panel__message">Đang tải dữ liệu nhập điểm...</p>
        </div>
      ) : (
        <>
          <div className="ui-filters">
            <div className="ui-field">
              <label htmlFor="grade-year">Năm học</label>
              <select
                id="grade-year"
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
              <label htmlFor="grade-semester">Học kỳ</label>
              <select
                id="grade-semester"
                value={semesterId}
                onChange={(event) => setSemesterId(Number(event.target.value) || '')}
                disabled={yearId === ''}
              >
                <option value="">Chọn học kỳ</option>
                {semestersInYear.map((semester) => (
                  <option key={semester.semesterId} value={semester.semesterId}>
                    {semester.semesterName}
                  </option>
                ))}
              </select>
            </div>
            <div className="ui-field">
              <label htmlFor="grade-class">Lớp học</label>
              <select
                id="grade-class"
                value={classId}
                onChange={(event) => setClassId(Number(event.target.value) || '')}
                disabled={semesterId === ''}
              >
                <option value="">Chọn lớp</option>
                {classOptions.map((option) => (
                  <option key={option.id} value={option.id}>
                    {option.name}
                  </option>
                ))}
              </select>
            </div>
            <div className="ui-field">
              <label htmlFor="grade-assignment">Môn học</label>
              <select
                id="grade-assignment"
                value={assignmentId}
                onChange={(event) => setAssignmentId(Number(event.target.value) || '')}
                disabled={classId === ''}
              >
                <option value="">Chọn môn học</option>
                {assignmentsInClass.map((assignment) => (
                  <option key={assignment.teachingAssignmentId} value={assignment.teachingAssignmentId}>
                    {assignment.subjectName ?? `Môn #${assignment.subjectId}`}
                  </option>
                ))}
              </select>
            </div>
            <div className="ui-field">
              <label htmlFor="grade-type">Cột điểm</label>
              <select
                id="grade-type"
                value={assessmentTypeId}
                onChange={(event) => setAssessmentTypeId(Number(event.target.value) || '')}
              >
                <option value="">Chọn loại điểm</option>
                {assessmentTypes.map((type) => (
                  <option key={type.assessmentTypeId} value={type.assessmentTypeId}>
                    {type.typeName} ({type.weight})
                  </option>
                ))}
              </select>
            </div>
          </div>

          {selectedAssignment && (
            <p className="teacher-muted">
              Đang nhập điểm cho {selectedAssignment.className} · {selectedAssignment.subjectName}
            </p>
          )}
          {message && <p className="teacher-success">{message}</p>}
          {error && <p className="teacher-alert">{error}</p>}

          {loadingRows ? (
            <div className="state-panel">
              <Spinner />
              <p className="state-panel__message">Đang tải bảng điểm...</p>
            </div>
          ) : (
            <DataTable
              columns={columns}
              data={rows}
              rowKey={(row) => row.studentId}
              emptyMessage="Chưa có dữ liệu học sinh hoặc chưa chọn phân công."
            />
          )}
        </>
      )}
    </>
  )
}
