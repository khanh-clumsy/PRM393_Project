import { useEffect, useMemo, useState } from 'react'
import Button from '../../components/ui/Button'
import DataTable, { type DataTableColumn } from '../../components/ui/DataTable'
import PageHeader from '../../components/ui/PageHeader'
import Spinner from '../../components/ui/Spinner'
import { useAuth } from '../../core/auth/AuthContext'
import { fetchClassRoster, fetchTeacherClasses } from './api'
import type { StudentClass, TeacherClass } from './types'
import { getRoleLabel } from './utils'

export default function TeacherClassesPage() {
  const { user } = useAuth()
  const teacherId = user?.id
  const [classes, setClasses] = useState<TeacherClass[]>([])
  const [selectedClassId, setSelectedClassId] = useState<number | ''>('')
  const [roster, setRoster] = useState<StudentClass[]>([])
  const [loading, setLoading] = useState(true)
  const [rosterLoading, setRosterLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (!teacherId) return
    const id = teacherId

    let ignore = false
    async function load() {
      setLoading(true)
      setError(null)
      try {
        const data = await fetchTeacherClasses(id)
        if (ignore) return
        setClasses(data)
        setSelectedClassId(data[0]?.classId ?? '')
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

  useEffect(() => {
    if (!selectedClassId) {
      setRoster([])
      return
    }

    let ignore = false
    async function loadRoster() {
      setRosterLoading(true)
      try {
        const data = await fetchClassRoster(Number(selectedClassId))
        if (!ignore) setRoster(data)
      } catch {
        if (!ignore) setRoster([])
      } finally {
        if (!ignore) setRosterLoading(false)
      }
    }

    void loadRoster()
    return () => {
      ignore = true
    }
  }, [selectedClassId])

  const selectedClass = useMemo(
    () => classes.find((cls) => cls.classId === selectedClassId),
    [classes, selectedClassId],
  )

  const classColumns: DataTableColumn<TeacherClass>[] = [
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
          Xem roster
        </Button>
      ),
    },
  ]

  const rosterColumns: DataTableColumn<StudentClass>[] = [
    { key: 'studentCode', header: 'Mã học sinh', render: (row) => row.studentCode ?? '-' },
    { key: 'studentName', header: 'Họ tên', render: (row) => row.studentName ?? `HS #${row.studentId}` },
  ]

  return (
    <>
      <PageHeader
        title="Lớp của tôi"
        subtitle="Hợp lớp giảng dạy và lớp chủ nhiệm; lớp GVCN luôn xem được roster."
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
            <h2>Roster {selectedClass ? `· ${selectedClass.className}` : ''}</h2>
            {rosterLoading ? (
              <div className="state-panel">
                <Spinner />
                <p className="state-panel__message">Đang tải roster...</p>
              </div>
            ) : (
              <DataTable
                columns={rosterColumns}
                data={roster}
                rowKey={(row) => row.studentClassId}
                emptyMessage="Chưa có học sinh trong lớp."
              />
            )}
          </section>
        </div>
      )}
    </>
  )
}
