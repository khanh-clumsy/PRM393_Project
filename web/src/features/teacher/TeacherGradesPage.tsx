import { useEffect, useMemo, useState } from 'react'
import Button from '../../components/ui/Button'
import DataTable, { type DataTableColumn } from '../../components/ui/DataTable'
import PageHeader from '../../components/ui/PageHeader'
import Spinner from '../../components/ui/Spinner'
import { useAuth } from '../../core/auth/AuthContext'
import {
  fetchAssessmentTypes,
  fetchClassGradesByType,
  fetchTeacherAssignments,
  saveGradesByType,
} from './api'
import type { AssessmentType, GradeDraft, TeachingAssignment } from './types'
import { hasGradeErrors, parseGradeInput } from './utils'

export default function TeacherGradesPage() {
  const { user } = useAuth()
  const teacherId = user?.id
  const [assignments, setAssignments] = useState<TeachingAssignment[]>([])
  const [assessmentTypes, setAssessmentTypes] = useState<AssessmentType[]>([])
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
        const [assignmentData, typeData] = await Promise.all([
          fetchTeacherAssignments(id),
          fetchAssessmentTypes(),
        ])
        if (ignore) return
        setAssignments(assignmentData)
        setAssessmentTypes(typeData)
        setAssignmentId(assignmentData[0]?.teachingAssignmentId ?? '')
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
        subtitle="Chỉ hiển thị phân công giảng dạy của giáo viên; GVCN không có assignment sẽ không có quyền nhập."
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
              <label htmlFor="grade-assignment">Lớp / môn</label>
              <select
                id="grade-assignment"
                value={assignmentId}
                onChange={(event) => setAssignmentId(Number(event.target.value) || '')}
              >
                <option value="">Chọn phân công</option>
                {assignments.map((assignment) => (
                  <option
                    key={assignment.teachingAssignmentId}
                    value={assignment.teachingAssignmentId}
                  >
                    {assignment.className ?? `Lớp #${assignment.classId}`} ·{' '}
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
