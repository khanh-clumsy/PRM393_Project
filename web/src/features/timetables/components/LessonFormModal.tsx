import { type FormEvent, useEffect, useMemo, useState } from 'react'
import Button from '../../../components/ui/Button'
import Modal from '../../../components/ui/Modal'
import type { TimetableSlot } from '../../slots/types'
import type { TeachingAssignment } from '../../teaching-assignments/types'
import { TIMETABLE_STATUS } from '../constants'
import StatusMenu from './StatusMenu'
import type { LessonFormContext } from '../types'

type LessonFormModalProps = {
  open: boolean
  context: LessonFormContext | null
  assignments: TeachingAssignment[]
  slots: TimetableSlot[]
  submitting: boolean
  onClose: () => void
  onSubmitWeeklyCreate: (payload: {
    teachingAssignmentId: number
    date: string
    slotId: number
    roomName: string
    status: number
    note: string
  }) => Promise<void>
  onSubmitWeeklyEdit: (payload: {
    id: number
    date: string
    slotId: number
    roomName: string
    status: number
    note: string
  }) => Promise<void>
  onSubmitTemplateCreate: (payload: {
    teachingAssignmentId: number
    dayOfWeek: number
    slotId: number
    roomName: string
  }) => Promise<void>
  onSubmitTemplateEdit: (payload: {
    id: number
    teachingAssignmentId: number
    dayOfWeek: number
    slotId: number
    roomName: string
  }) => Promise<void>
  onDeleteWeekly?: (id: number) => void
  onDeleteTemplate?: (id: number) => void
}

/** Form thêm/sửa tiết — lịch thực tế hoặc lịch mẫu */
export default function LessonFormModal({
  open,
  context,
  assignments,
  slots,
  submitting,
  onClose,
  onSubmitWeeklyCreate,
  onSubmitWeeklyEdit,
  onSubmitTemplateCreate,
  onSubmitTemplateEdit,
  onDeleteWeekly,
  onDeleteTemplate,
}: LessonFormModalProps) {
  const [teachingAssignmentId, setTeachingAssignmentId] = useState<number | ''>('')
  const [slotId, setSlotId] = useState<number | ''>('')
  const [date, setDate] = useState('')
  const [dayOfWeek, setDayOfWeek] = useState<number>(2)
  const [roomName, setRoomName] = useState('')
  const [status, setStatus] = useState<number>(TIMETABLE_STATUS.NORMAL)
  const [note, setNote] = useState('')

  const isWeekly = context?.kind === 'weekly-create' || context?.kind === 'weekly-edit'
  const isEdit = context?.kind === 'weekly-edit' || context?.kind === 'template-edit'
  const isTemplate = context?.kind === 'template-create' || context?.kind === 'template-edit'

  const sortedSlots = useMemo(
    () => [...slots].sort((a, b) => a.startTime.localeCompare(b.startTime)),
    [slots],
  )

  useEffect(() => {
    if (!context) return

    if (context.kind === 'weekly-create') {
      setTeachingAssignmentId('')
      setSlotId(context.slotId)
      setDate(context.date)
      setRoomName('')
      setStatus(TIMETABLE_STATUS.NORMAL)
      setNote('')
      return
    }

    if (context.kind === 'weekly-edit') {
      const lesson = context.lesson
      setTeachingAssignmentId(lesson.teachingAssignmentId)
      setSlotId(
        sortedSlots.find((s) => s.slotName === lesson.slotName)?.slotId ?? '',
      )
      setDate(lesson.date.split('T')[0] ?? lesson.date)
      setRoomName(lesson.roomName ?? '')
      setStatus(lesson.status)
      setNote(lesson.note ?? '')
      return
    }

    if (context.kind === 'template-create') {
      setTeachingAssignmentId('')
      setSlotId(context.slotId)
      setDayOfWeek(context.dayOfWeek)
      setRoomName('')
      return
    }

    if (context.kind === 'template-edit') {
      const tpl = context.template
      setTeachingAssignmentId(tpl.teachingAssignmentId)
      setSlotId(tpl.slotId)
      setDayOfWeek(tpl.dayOfWeek)
      setRoomName(tpl.roomName ?? '')
    }
  }, [context, sortedSlots])

  const title = useMemo(() => {
    if (!context) return ''
    if (context.kind === 'weekly-create') return 'Thêm tiết học'
    if (context.kind === 'weekly-edit') return 'Sửa tiết học'
    if (context.kind === 'template-create') return 'Thêm lịch mẫu'
    return 'Sửa lịch mẫu'
  }, [context])

  async function handleSubmit(e: FormEvent) {
    e.preventDefault()
    if (!context || slotId === '') return

    if (context.kind === 'weekly-create') {
      if (teachingAssignmentId === '') return
      await onSubmitWeeklyCreate({
        teachingAssignmentId,
        date,
        slotId,
        roomName: roomName.trim(),
        status,
        note: note.trim(),
      })
      return
    }

    if (context.kind === 'weekly-edit') {
      await onSubmitWeeklyEdit({
        id: context.lesson.timetableId,
        date,
        slotId,
        roomName: roomName.trim(),
        status,
        note: note.trim(),
      })
      return
    }

    if (context.kind === 'template-create') {
      if (teachingAssignmentId === '') return
      await onSubmitTemplateCreate({
        teachingAssignmentId,
        dayOfWeek,
        slotId,
        roomName: roomName.trim(),
      })
      return
    }

    if (context.kind === 'template-edit') {
      if (teachingAssignmentId === '') return
      await onSubmitTemplateEdit({
        id: context.template.templateId,
        teachingAssignmentId,
        dayOfWeek,
        slotId,
        roomName: roomName.trim(),
      })
    }
  }

  const canDelete =
    context?.kind === 'weekly-edit'
      ? onDeleteWeekly && !context.lesson.isAttendanceTaken
      : context?.kind === 'template-edit'
        ? !!onDeleteTemplate
        : false

  const deleteBlocked =
    context?.kind === 'weekly-edit' && context.lesson.isAttendanceTaken

  return (
    <Modal
      open={open}
      title={title}
      onClose={onClose}
      footer={
        <>
          {canDelete && context?.kind === 'weekly-edit' && (
            <Button
              variant="danger"
              onClick={() => onDeleteWeekly?.(context.lesson.timetableId)}
              disabled={submitting}
            >
              Xóa
            </Button>
          )}
          {canDelete && context?.kind === 'template-edit' && (
            <Button
              variant="danger"
              onClick={() => onDeleteTemplate?.(context.template.templateId)}
              disabled={submitting}
            >
              Xóa
            </Button>
          )}
          <Button variant="secondary" onClick={onClose} disabled={submitting}>
            Hủy
          </Button>
          <Button type="submit" form="lesson-form" loading={submitting}>
            {isEdit ? 'Lưu' : 'Thêm'}
          </Button>
        </>
      }
    >
      <form id="lesson-form" onSubmit={(e) => void handleSubmit(e)}>
        {!isEdit && (
          <div className="ui-field">
            <label htmlFor="lesson-assignment">Phân công giảng dạy *</label>
            <select
              id="lesson-assignment"
              value={teachingAssignmentId}
              onChange={(e) => {
                const v = e.target.value
                setTeachingAssignmentId(v === '' ? '' : Number(v))
              }}
              disabled={submitting}
            >
              <option value="">— Chọn môn / giáo viên —</option>
              {assignments.map((a) => (
                <option key={a.teachingAssignmentId} value={a.teachingAssignmentId}>
                  {a.subjectName ?? `Môn #${a.subjectId}`} — GV #{a.teacherId}
                </option>
              ))}
            </select>
          </div>
        )}

        {isEdit && teachingAssignmentId !== '' && (
          <div className="ui-field">
            <label>Phân công</label>
            <input
              value={
                assignments.find((a) => a.teachingAssignmentId === teachingAssignmentId)
                  ?.subjectName ?? `#${teachingAssignmentId}`
              }
              disabled
            />
          </div>
        )}

        {isWeekly && (
          <div className="ui-field">
            <label htmlFor="lesson-date">Ngày học</label>
            <input
              id="lesson-date"
              type="date"
              value={date}
              onChange={(e) => setDate(e.target.value)}
              disabled={submitting}
            />
          </div>
        )}

        {isTemplate && (
          <div className="ui-field">
            <label htmlFor="lesson-dow">Thứ trong tuần</label>
            <select
              id="lesson-dow"
              value={dayOfWeek}
              onChange={(e) => setDayOfWeek(Number(e.target.value))}
              disabled={submitting}
            >
              <option value={2}>Thứ 2</option>
              <option value={3}>Thứ 3</option>
              <option value={4}>Thứ 4</option>
              <option value={5}>Thứ 5</option>
              <option value={6}>Thứ 6</option>
              <option value={7}>Thứ 7</option>
              <option value={8}>Chủ nhật</option>
            </select>
          </div>
        )}

        <div className="ui-field">
          <label htmlFor="lesson-slot">Ca học *</label>
          <select
            id="lesson-slot"
            value={slotId}
            onChange={(e) => {
              const v = e.target.value
              setSlotId(v === '' ? '' : Number(v))
            }}
            disabled={submitting}
          >
            <option value="">— Chọn ca —</option>
            {sortedSlots.map((s) => (
              <option key={s.slotId} value={s.slotId}>
                {s.slotName} ({s.startTime.slice(0, 5)}–{s.endTime.slice(0, 5)})
              </option>
            ))}
          </select>
        </div>

        <div className="ui-field">
          <label htmlFor="lesson-room">Phòng học</label>
          <input
            id="lesson-room"
            value={roomName}
            onChange={(e) => setRoomName(e.target.value)}
            placeholder="VD: A101"
            disabled={submitting}
          />
        </div>

        {isWeekly && (
          <>
            <StatusMenu status={status} disabled={submitting} onChange={setStatus} />
            <div className="ui-field">
              <label htmlFor="lesson-note">Ghi chú</label>
              <textarea
                id="lesson-note"
                rows={3}
                value={note}
                onChange={(e) => setNote(e.target.value)}
                placeholder="Ghi chú đổi lịch, nghỉ học…"
                disabled={submitting}
              />
            </div>
          </>
        )}

        {deleteBlocked && (
          <p className="timetable-hint timetable-hint--warn">
            Tiết đã điểm danh — không thể xóa qua giao diện này.
          </p>
        )}
      </form>
    </Modal>
  )
}
