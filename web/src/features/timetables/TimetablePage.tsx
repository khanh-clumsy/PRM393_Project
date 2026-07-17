import { useCallback, useEffect, useMemo, useState } from 'react'
import Button from '../../components/ui/Button'
import ConfirmDialog from '../../components/ui/ConfirmDialog'
import EmptyState from '../../components/ui/EmptyState'
import PageHeader from '../../components/ui/PageHeader'
import Spinner from '../../components/ui/Spinner'
import { useToast } from '../../components/ui/Toast'
import { fetchTeachingAssignments } from '../teaching-assignments/api'
import type { TeachingAssignment } from '../teaching-assignments/types'
import {
  clearGeneratedTimetables,
  createTemplate,
  createTimetable,
  deleteTemplate,
  deleteTimetable,
  fetchTemplatesByClass,
  fetchTimetableLookup,
  fetchWeeklyByClass,
  generateFromTemplate,
  updateTemplate,
  updateTimetable,
} from './api'
import LessonFormModal from './components/LessonFormModal'
import TemplateGrid from './components/TemplateGrid'
import WeekGrid from './components/WeekGrid'
import { formatDateISO, getMondayOfWeek } from './dateUtils'
import type { LessonFormContext, TimetableLesson, TimetableLookup, TimetableMode, TimetableTemplate } from './types'
import './timetable.css'

const FILTER_EMPTY = 'Vui lòng chọn Năm học, Học kỳ và Lớp học.'

/** Quản lý TKB — lịch thực tế và lịch mẫu */
export default function TimetablePage() {
  const { showToast } = useToast()

  const [lookup, setLookup] = useState<TimetableLookup | null>(null)
  const [allAssignments, setAllAssignments] = useState<TeachingAssignment[]>([])

  const [yearFilter, setYearFilter] = useState<number | ''>('')
  const [semesterFilter, setSemesterFilter] = useState<number | ''>('')
  const [classFilter, setClassFilter] = useState<number | ''>('')
  const [mode, setMode] = useState<TimetableMode>('weekly')

  const [weekAnchor, setWeekAnchor] = useState(() => getMondayOfWeek(new Date()))
  const [weeklyLessons, setWeeklyLessons] = useState<TimetableLesson[]>([])
  const [templates, setTemplates] = useState<TimetableTemplate[]>([])

  const [loadingInit, setLoadingInit] = useState(true)
  const [loadingGrid, setLoadingGrid] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [submitting, setSubmitting] = useState(false)

  const [formContext, setFormContext] = useState<LessonFormContext | null>(null)
  const [generateConfirm, setGenerateConfirm] = useState(false)
  const [clearStep, setClearStep] = useState<0 | 1 | 2>(0)

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

  const filteredAssignments = useMemo(() => {
    if (!filtersReady) return []
    return allAssignments.filter(
      (a) => a.classId === classFilter && a.semesterId === semesterFilter,
    )
  }, [allAssignments, filtersReady, classFilter, semesterFilter])

  const slots = lookup?.slots ?? []
  const weekStart = getMondayOfWeek(weekAnchor)
  const weekEnd = useMemo(() => {
    const d = new Date(weekStart)
    d.setDate(d.getDate() + 6)
    return d
  }, [weekStart])

  const weekLabel = `${formatDateISO(weekStart).split('-').reverse().join('/')} – ${formatDateISO(weekEnd).split('-').reverse().join('/')}`

  const loadWeekly = useCallback(async () => {
    if (!filtersReady) return
    const classId = classFilter as number
    setLoadingGrid(true)
    setError(null)
    try {
      const data = await fetchWeeklyByClass(classId, formatDateISO(weekAnchor))
      setWeeklyLessons(data)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Không tải được lịch tuần.')
    } finally {
      setLoadingGrid(false)
    }
  }, [filtersReady, classFilter, weekAnchor])

  const loadTemplates = useCallback(async () => {
    if (!filtersReady) return
    const classId = classFilter as number
    const semesterId = semesterFilter as number
    setLoadingGrid(true)
    setError(null)
    try {
      const data = await fetchTemplatesByClass(classId, semesterId)
      setTemplates(data)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Không tải được lịch mẫu.')
    } finally {
      setLoadingGrid(false)
    }
  }, [filtersReady, classFilter, semesterFilter])

  useEffect(() => {
    void (async () => {
      setLoadingInit(true)
      setError(null)
      try {
        const [lookupData, assignments] = await Promise.all([
          fetchTimetableLookup(),
          fetchTeachingAssignments(),
        ])
        setLookup(lookupData)
        setAllAssignments(assignments)

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
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Không tải được dữ liệu ban đầu.')
      } finally {
        setLoadingInit(false)
      }
    })()
  }, [])

  useEffect(() => {
    if (!filtersReady) return
    if (mode === 'weekly') {
      void loadWeekly()
    } else {
      void loadTemplates()
    }
  }, [filtersReady, mode, loadWeekly, loadTemplates])

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

  function shiftWeek(delta: number) {
    setWeekAnchor((prev) => {
      const d = new Date(prev)
      d.setDate(d.getDate() + delta * 7)
      return d
    })
  }

  function handleWeeklyCell(date: string, slotId: number, lesson?: TimetableLesson) {
    if (lesson) {
      setFormContext({ kind: 'weekly-edit', lesson })
    } else {
      setFormContext({ kind: 'weekly-create', date, slotId })
    }
  }

  function handleTemplateCell(dayOfWeek: number, slotId: number, template?: TimetableTemplate) {
    if (template) {
      setFormContext({ kind: 'template-edit', template })
    } else {
      setFormContext({ kind: 'template-create', dayOfWeek, slotId })
    }
  }

  async function handleWeeklyCreate(payload: {
    teachingAssignmentId: number
    date: string
    slotId: number
    roomName: string
    status: number
    note: string
  }) {
    setSubmitting(true)
    try {
      await createTimetable({
        teachingAssignmentId: payload.teachingAssignmentId,
        date: payload.date,
        slotId: payload.slotId,
        roomName: payload.roomName || null,
        status: payload.status,
        note: payload.note || null,
      })
      showToast('Đã thêm tiết học.', 'success')
      setFormContext(null)
      await loadWeekly()
    } catch (err) {
      showToast(err instanceof Error ? err.message : 'Không thể thêm tiết học.', 'error')
    } finally {
      setSubmitting(false)
    }
  }

  async function handleWeeklyEdit(payload: {
    id: number
    date: string
    slotId: number
    roomName: string
    status: number
    note: string
  }) {
    setSubmitting(true)
    try {
      await updateTimetable(payload.id, {
        date: payload.date,
        slotId: payload.slotId,
        roomName: payload.roomName || null,
        status: payload.status,
        note: payload.note || null,
      })
      showToast('Đã cập nhật tiết học.', 'success')
      setFormContext(null)
      await loadWeekly()
    } catch (err) {
      showToast(err instanceof Error ? err.message : 'Không thể cập nhật tiết học.', 'error')
    } finally {
      setSubmitting(false)
    }
  }

  async function handleTemplateCreate(payload: {
    teachingAssignmentId: number
    dayOfWeek: number
    slotId: number
    roomName: string
  }) {
    setSubmitting(true)
    try {
      await createTemplate({
        teachingAssignmentId: payload.teachingAssignmentId,
        dayOfWeek: payload.dayOfWeek,
        slotId: payload.slotId,
        roomName: payload.roomName || null,
      })
      showToast('Đã thêm lịch mẫu.', 'success')
      setFormContext(null)
      await loadTemplates()
    } catch (err) {
      showToast(err instanceof Error ? err.message : 'Không thể thêm lịch mẫu.', 'error')
    } finally {
      setSubmitting(false)
    }
  }

  async function handleTemplateEdit(payload: {
    id: number
    teachingAssignmentId: number
    dayOfWeek: number
    slotId: number
    roomName: string
  }) {
    setSubmitting(true)
    try {
      await updateTemplate(payload.id, {
        teachingAssignmentId: payload.teachingAssignmentId,
        dayOfWeek: payload.dayOfWeek,
        slotId: payload.slotId,
        roomName: payload.roomName || null,
      })
      showToast('Đã cập nhật lịch mẫu.', 'success')
      setFormContext(null)
      await loadTemplates()
    } catch (err) {
      showToast(err instanceof Error ? err.message : 'Không thể cập nhật lịch mẫu.', 'error')
    } finally {
      setSubmitting(false)
    }
  }

  async function handleDeleteWeekly(id: number) {
    setSubmitting(true)
    try {
      await deleteTimetable(id)
      showToast('Đã xóa tiết học.', 'success')
      setFormContext(null)
      await loadWeekly()
    } catch (err) {
      showToast(err instanceof Error ? err.message : 'Không thể xóa tiết học.', 'error')
    } finally {
      setSubmitting(false)
    }
  }

  async function handleDeleteTemplate(id: number) {
    setSubmitting(true)
    try {
      await deleteTemplate(id)
      showToast('Đã xóa lịch mẫu.', 'success')
      setFormContext(null)
      await loadTemplates()
    } catch (err) {
      showToast(err instanceof Error ? err.message : 'Không thể xóa lịch mẫu.', 'error')
    } finally {
      setSubmitting(false)
    }
  }

  async function handleGenerateConfirm() {
    if (!filtersReady) return
    setSubmitting(true)
    try {
      const result = await generateFromTemplate(semesterFilter as number, classFilter as number)
      showToast(`Đã sinh ${result.count ?? 0} tiết học từ lịch mẫu.`, 'success')
      setGenerateConfirm(false)
      setMode('weekly')
      await loadWeekly()
    } catch (err) {
      showToast(err instanceof Error ? err.message : 'Sinh lịch thất bại.', 'error')
    } finally {
      setSubmitting(false)
    }
  }

  async function handleClearConfirm() {
    if (!filtersReady || clearStep !== 2) return
    setSubmitting(true)
    try {
      const result = await clearGeneratedTimetables(
        semesterFilter as number,
        classFilter as number,
      )
      showToast(`Đã xóa ${result.count ?? 0} tiết đã sinh.`, 'info')
      setClearStep(0)
      await loadWeekly()
    } catch (err) {
      showToast(err instanceof Error ? err.message : 'Xóa lịch thất bại.', 'error')
    } finally {
      setSubmitting(false)
    }
  }

  const className =
    classFilter !== '' ? classesInYear.find((c) => c.classId === classFilter)?.className : ''
  const semesterName =
    semesterFilter !== ''
      ? semestersInYear.find((s) => s.semesterId === semesterFilter)?.semesterName
      : ''

  return (
    <>
      <PageHeader
        title="Thời khóa biểu"
        subtitle="Quản lý lịch mẫu và lịch thực tế theo lớp"
      />

      <div className="timetable-filters">
        <div className="ui-field">
          <label htmlFor="tt-year">Năm học</label>
          <select
            id="tt-year"
            value={yearFilter}
            onChange={(e) => {
              const v = e.target.value
              handleYearChange(v === '' ? '' : Number(v))
            }}
            disabled={loadingInit || submitting || !lookup?.academicYears.length}
          >
            {!lookup?.academicYears.length ? (
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
          <label htmlFor="tt-semester">Học kỳ</label>
          <select
            id="tt-semester"
            value={semesterFilter}
            onChange={(e) => {
              const v = e.target.value
              setSemesterFilter(v === '' ? '' : Number(v))
            }}
            disabled={loadingInit || submitting || yearFilter === '' || !semestersInYear.length}
          >
            {yearFilter === '' ? (
              <option value="">Chọn năm học trước</option>
            ) : !semestersInYear.length ? (
              <option value="">Chưa có học kỳ</option>
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
          <label htmlFor="tt-class">Lớp học</label>
          <select
            id="tt-class"
            value={classFilter}
            onChange={(e) => {
              const v = e.target.value
              setClassFilter(v === '' ? '' : Number(v))
            }}
            disabled={loadingInit || submitting || yearFilter === '' || !classesInYear.length}
          >
            {yearFilter === '' ? (
              <option value="">Chọn năm học trước</option>
            ) : !classesInYear.length ? (
              <option value="">Chưa có lớp</option>
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

      <div className="timetable-mode-tabs" role="tablist">
        <button
          type="button"
          role="tab"
          className={mode === 'weekly' ? 'is-active' : ''}
          onClick={() => setMode('weekly')}
        >
          Lịch thực tế
        </button>
        <button
          type="button"
          role="tab"
          className={mode === 'template' ? 'is-active' : ''}
          onClick={() => setMode('template')}
        >
          Lịch mẫu
        </button>
      </div>

      {loadingInit && (
        <div className="state-panel">
          <Spinner size="lg" />
          <p className="state-panel__message">Đang tải dữ liệu…</p>
        </div>
      )}

      {!loadingInit && !filtersReady && (
        <EmptyState title="Chọn bộ lọc" message={FILTER_EMPTY} />
      )}

      {!loadingInit && filtersReady && mode === 'weekly' && (
        <>
          <div className="timetable-week-nav">
            <Button size="sm" variant="secondary" onClick={() => shiftWeek(-1)} disabled={loadingGrid}>
              ← Tuần trước
            </Button>
            <span className="timetable-week-nav__label">{weekLabel}</span>
            <Button size="sm" variant="secondary" onClick={() => shiftWeek(1)} disabled={loadingGrid}>
              Tuần sau →
            </Button>
            <Button
              size="sm"
              variant="ghost"
              onClick={() => setWeekAnchor(getMondayOfWeek(new Date()))}
              disabled={loadingGrid}
            >
              Tuần này
            </Button>
          </div>

          {loadingGrid && (
            <div className="state-panel">
              <Spinner size="lg" />
              <p className="state-panel__message">Đang tải lịch tuần…</p>
            </div>
          )}

          {!loadingGrid && error && (
            <div className="state-panel state-panel--error">
              <p className="state-panel__title">Lỗi</p>
              <p className="state-panel__message">{error}</p>
              <Button onClick={() => void loadWeekly()}>Thử lại</Button>
            </div>
          )}

          {!loadingGrid && !error && slots.length === 0 && (
            <EmptyState
              title="Chưa có ca học"
              message="Cấu hình ca học tại menu «Ca học» trước khi xếp TKB."
            />
          )}

          {!loadingGrid && !error && slots.length > 0 && (
            <WeekGrid
              weekStart={weekStart}
              slots={slots}
              lessons={weeklyLessons}
              onCellClick={handleWeeklyCell}
            />
          )}
        </>
      )}

      {!loadingInit && filtersReady && mode === 'template' && (
        <>
          <div className="timetable-toolbar">
            <p className="timetable-hint" style={{ margin: 0 }}>
              {className && semesterName
                ? `Lịch mẫu — ${className}, ${semesterName}. Nhấn ô trống để thêm tiết.`
                : 'Lịch mẫu theo tuần lặp lại.'}
            </p>
            <Button
              variant="primary"
              onClick={() => setGenerateConfirm(true)}
              disabled={loadingGrid || submitting || templates.length === 0}
            >
              Sinh lịch học kỳ
            </Button>
          </div>

          {filteredAssignments.length === 0 && (
            <p className="timetable-hint timetable-hint--warn">
              Chưa có phân công giảng dạy cho lớp và học kỳ này — thêm tại «Phân công giảng dạy».
            </p>
          )}

          {loadingGrid && (
            <div className="state-panel">
              <Spinner size="lg" />
              <p className="state-panel__message">Đang tải lịch mẫu…</p>
            </div>
          )}

          {!loadingGrid && error && (
            <div className="state-panel state-panel--error">
              <p className="state-panel__title">Lỗi</p>
              <p className="state-panel__message">{error}</p>
              <Button onClick={() => void loadTemplates()}>Thử lại</Button>
            </div>
          )}

          {!loadingGrid && !error && slots.length > 0 && (
            <TemplateGrid
              slots={slots}
              templates={templates}
              onCellClick={handleTemplateCell}
            />
          )}
        </>
      )}

      {import.meta.env.DEV && filtersReady && (
        <div className="timetable-dev-actions">
          <p className="timetable-dev-actions__label">Chỉ hiển thị khi DEV — debug</p>
          <Button
            size="sm"
            variant="danger"
            onClick={() => setClearStep(1)}
            disabled={submitting}
          >
            Xóa lịch đã sinh (DEV)
          </Button>
        </div>
      )}

      <LessonFormModal
        open={formContext !== null}
        context={formContext}
        assignments={filteredAssignments}
        slots={slots}
        submitting={submitting}
        onClose={() => {
          if (!submitting) setFormContext(null)
        }}
        onSubmitWeeklyCreate={handleWeeklyCreate}
        onSubmitWeeklyEdit={handleWeeklyEdit}
        onSubmitTemplateCreate={handleTemplateCreate}
        onSubmitTemplateEdit={handleTemplateEdit}
        onDeleteWeekly={(id) => void handleDeleteWeekly(id)}
        onDeleteTemplate={(id) => void handleDeleteTemplate(id)}
      />

      <ConfirmDialog
        open={generateConfirm}
        title="Sinh lịch từ lịch mẫu"
        message={`Thao tác này sẽ XÓA toàn bộ lịch học thực tế hiện có của lớp «${className ?? ''}» trong học kỳ «${semesterName ?? ''}» và sinh lại từ lịch mẫu. Dữ liệu điểm danh liên quan cũng sẽ bị xóa. Bạn có chắc chắn muốn tiếp tục?`}
        confirmLabel="Sinh lịch"
        variant="danger"
        loading={submitting}
        onConfirm={() => void handleGenerateConfirm()}
        onCancel={() => {
          if (!submitting) setGenerateConfirm(false)
        }}
      />

      <ConfirmDialog
        open={clearStep === 1}
        title="Xóa lịch đã sinh (DEV)"
        message="Bạn có chắc muốn xóa toàn bộ lịch đã sinh cho lớp và học kỳ đang chọn?"
        confirmLabel="Tiếp tục"
        variant="danger"
        loading={submitting}
        onConfirm={() => setClearStep(2)}
        onCancel={() => {
          if (!submitting) setClearStep(0)
        }}
      />

      <ConfirmDialog
        open={clearStep === 2}
        title="Xác nhận lần 2 (DEV)"
        message="Hành động không thể hoàn tác. Bạn thực sự muốn xóa toàn bộ lịch đã sinh?"
        confirmLabel="Xóa ngay"
        variant="danger"
        loading={submitting}
        onConfirm={() => void handleClearConfirm()}
        onCancel={() => {
          if (!submitting) setClearStep(0)
        }}
      />
    </>
  )
}
