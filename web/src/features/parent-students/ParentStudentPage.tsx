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
  createParentStudent,
  deleteParentStudent,
  fetchParentStudentsByParent,
  fetchParents,
  fetchStudents,
  updateParentStudent,
} from './api'
import type { ParentStudent, UserOption } from './types'
import {
  RELATIONSHIP_OPTIONS,
  initialRelationshipValue,
  relationshipSubtitle,
} from './types'

type FormMode = 'create' | 'edit'

/** Quản lý liên kết phụ huynh – học sinh — chỉ tải links khi chọn phụ huynh */
export default function ParentStudentPage() {
  const { showToast } = useToast()
  const [parents, setParents] = useState<UserOption[]>([])
  const [students, setStudents] = useState<UserOption[]>([])
  const [parentFilter, setParentFilter] = useState<number | ''>('')
  const [items, setItems] = useState<ParentStudent[]>([])

  const [loadingInit, setLoadingInit] = useState(true)
  const [loadingLinks, setLoadingLinks] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [submitting, setSubmitting] = useState(false)

  const [modalOpen, setModalOpen] = useState(false)
  const [formMode, setFormMode] = useState<FormMode>('create')
  const [editing, setEditing] = useState<ParentStudent | null>(null)
  const [selectedStudentId, setSelectedStudentId] = useState<number | ''>('')
  const [relationship, setRelationship] = useState(RELATIONSHIP_OPTIONS[0].value)
  const [deleteTarget, setDeleteTarget] = useState<ParentStudent | null>(null)

  const parentNameById = useMemo(
    () => new Map(parents.map((p) => [p.id, p.fullName])),
    [parents],
  )

  const loadLinks = useCallback(async (parentId: number) => {
    setLoadingLinks(true)
    setError(null)
    try {
      const data = await fetchParentStudentsByParent(parentId)
      setItems(data)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Không tải được danh sách liên kết.')
      setItems([])
    } finally {
      setLoadingLinks(false)
    }
  }, [])

  useEffect(() => {
    void (async () => {
      setLoadingInit(true)
      setError(null)
      try {
        const [parentData, studentData] = await Promise.all([
          fetchParents(),
          fetchStudents(),
        ])
        setParents(parentData)
        setStudents(studentData)
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Không tải được dữ liệu ban đầu.')
      } finally {
        setLoadingInit(false)
      }
    })()
  }, [])

  // Chỉ gọi API links khi đã chọn phụ huynh — không preload toàn hệ thống
  useEffect(() => {
    if (parentFilter === '') {
      setItems([])
      return
    }
    void loadLinks(parentFilter)
  }, [parentFilter, loadLinks])

  const linkedStudentIds = useMemo(
    () => new Set(items.map((ps) => ps.studentId)),
    [items],
  )

  const availableStudents = useMemo(() => {
    return students.filter((s) => !linkedStudentIds.has(s.id))
  }, [students, linkedStudentIds])

  function openCreate() {
    if (parentFilter === '') {
      showToast('Vui lòng chọn phụ huynh trước.', 'error')
      return
    }
    setFormMode('create')
    setEditing(null)
    setSelectedStudentId('')
    setRelationship(RELATIONSHIP_OPTIONS[0].value)
    setModalOpen(true)
  }

  function openEdit(row: ParentStudent) {
    setFormMode('edit')
    setEditing(row)
    setSelectedStudentId(row.studentId)
    setRelationship(initialRelationshipValue(row.relationship))
    setModalOpen(true)
  }

  function closeModal() {
    setModalOpen(false)
    setEditing(null)
    setSelectedStudentId('')
    setRelationship(RELATIONSHIP_OPTIONS[0].value)
  }

  async function handleSubmit(e: FormEvent) {
    e.preventDefault()
    if (parentFilter === '') return

    if (formMode === 'create') {
      if (selectedStudentId === '') {
        showToast('Vui lòng chọn học sinh.', 'error')
        return
      }
    }

    setSubmitting(true)
    try {
      if (formMode === 'edit' && editing) {
        await updateParentStudent(editing.parentStudentId, { relationship })
        showToast('Đã cập nhật quan hệ.', 'success')
      } else {
        await createParentStudent({
          parentId: parentFilter,
          studentId: selectedStudentId as number,
          relationship,
        })
        showToast('Đã thêm liên kết.', 'success')
      }
      closeModal()
      await loadLinks(parentFilter)
    } catch (err) {
      showToast(err instanceof Error ? err.message : 'Thao tác thất bại.', 'error')
    } finally {
      setSubmitting(false)
    }
  }

  async function handleDeleteConfirm() {
    if (!deleteTarget || parentFilter === '') return
    setSubmitting(true)
    try {
      await deleteParentStudent(deleteTarget.parentStudentId)
      showToast('Đã xóa liên kết.', 'success')
      setDeleteTarget(null)
      await loadLinks(parentFilter)
    } catch (err) {
      showToast(err instanceof Error ? err.message : 'Xóa thất bại.', 'error')
    } finally {
      setSubmitting(false)
    }
  }

  const columns: DataTableColumn<ParentStudent>[] = [
    { key: 'parentStudentId', header: 'ID' },
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
      key: 'relationship',
      header: 'Quan hệ',
      render: (row) => relationshipSubtitle(row.relationship),
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

  const selectedRelationshipOption = RELATIONSHIP_OPTIONS.find((o) => o.value === relationship)
  const filterParentName = parentFilter !== '' ? parentNameById.get(parentFilter) : undefined

  return (
    <>
      <PageHeader
        title="Phụ huynh – Học sinh"
        subtitle="Liên kết tài khoản phụ huynh với học sinh"
        actions={
          <Button
            onClick={openCreate}
            disabled={loadingInit || submitting || parentFilter === ''}
          >
            Thêm liên kết
          </Button>
        }
      />

      <div className="ui-field" style={{ maxWidth: 480, marginBottom: 24 }}>
        <label htmlFor="ps-parent-filter">Phụ huynh</label>
        <select
          id="ps-parent-filter"
          value={parentFilter}
          onChange={(e) => {
            const v = e.target.value
            setParentFilter(v === '' ? '' : Number(v))
          }}
          disabled={loadingInit || submitting || parents.length === 0}
        >
          <option value="">— Chọn phụ huynh —</option>
          {parents.map((p) => (
            <option key={p.id} value={p.id}>
              {p.fullName} ({p.username})
            </option>
          ))}
        </select>
      </div>

      {loadingInit && (
        <div className="state-panel">
          <Spinner size="lg" />
          <p className="state-panel__message">Đang tải dữ liệu…</p>
        </div>
      )}

      {!loadingInit && error && parentFilter === '' && (
        <div className="state-panel state-panel--error">
          <p className="state-panel__title">Lỗi tải dữ liệu</p>
          <p className="state-panel__message">{error}</p>
        </div>
      )}

      {!loadingInit && parents.length === 0 && (
        <EmptyState
          title="Chưa có phụ huynh"
          message="Hãy tạo tài khoản phụ huynh (role Parent) trước."
        />
      )}

      {!loadingInit && parents.length > 0 && parentFilter === '' && (
        <EmptyState
          title="Chọn phụ huynh"
          message="Chọn một phụ huynh ở trên để xem và quản lý liên kết học sinh."
        />
      )}

      {!loadingInit && parentFilter !== '' && loadingLinks && (
        <div className="state-panel">
          <Spinner size="lg" />
          <p className="state-panel__message">Đang tải liên kết…</p>
        </div>
      )}

      {!loadingInit && parentFilter !== '' && !loadingLinks && error && (
        <div className="state-panel state-panel--error">
          <p className="state-panel__title">Lỗi tải liên kết</p>
          <p className="state-panel__message">{error}</p>
          <Button onClick={() => void loadLinks(parentFilter)}>Thử lại</Button>
        </div>
      )}

      {!loadingInit && parentFilter !== '' && !loadingLinks && !error && items.length === 0 && (
        <EmptyState
          title="Chưa có liên kết"
          message={
            filterParentName
              ? `${filterParentName} chưa liên kết học sinh nào. Nhấn «Thêm liên kết».`
              : 'Nhấn «Thêm liên kết» để bắt đầu.'
          }
          action={<Button onClick={openCreate}>Thêm liên kết</Button>}
        />
      )}

      {!loadingInit && parentFilter !== '' && !loadingLinks && !error && items.length > 0 && (
        <DataTable columns={columns} data={items} rowKey={(row) => row.parentStudentId} />
      )}

      <Modal
        open={modalOpen}
        title={formMode === 'edit' ? 'Sửa quan hệ' : 'Thêm liên kết'}
        onClose={closeModal}
        footer={
          <>
            <Button variant="secondary" onClick={closeModal} disabled={submitting}>
              Hủy
            </Button>
            <Button type="submit" form="parent-student-form" loading={submitting}>
              {formMode === 'edit' ? 'Lưu' : 'Thêm'}
            </Button>
          </>
        }
      >
        <form id="parent-student-form" onSubmit={handleSubmit}>
          <div className="ui-field">
            <label htmlFor="ps-parent-display">Phụ huynh</label>
            <input id="ps-parent-display" value={filterParentName ?? ''} disabled />
          </div>

          {formMode === 'create' ? (
            <div className="ui-field">
              <label htmlFor="ps-student">Học sinh *</label>
              <select
                id="ps-student"
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
              {availableStudents.length === 0 && (
                <p style={{ fontSize: 13, color: 'var(--color-text-muted)', margin: 0 }}>
                  Không còn học sinh khả dụng cho phụ huynh này. Học sinh đã liên kết phụ huynh khác
                  sẽ bị API từ chối khi thêm.
                </p>
              )}
            </div>
          ) : (
            <div className="ui-field">
              <label htmlFor="ps-student-display">Học sinh</label>
              <input
                id="ps-student-display"
                value={editing?.studentName ?? (selectedStudentId !== '' ? `#${selectedStudentId}` : '')}
                disabled
              />
            </div>
          )}

          <div className="ui-field">
            <label htmlFor="ps-relationship">Quan hệ *</label>
            <select
              id="ps-relationship"
              value={relationship}
              onChange={(e) => setRelationship(e.target.value)}
              disabled={submitting}
            >
              {RELATIONSHIP_OPTIONS.map((o) => (
                <option key={o.value} value={o.value}>
                  {o.label}
                </option>
              ))}
            </select>
            {selectedRelationshipOption && (
              <p style={{ fontSize: 13, color: 'var(--color-text-muted)', margin: 0 }}>
                {selectedRelationshipOption.description}
              </p>
            )}
          </div>
        </form>
      </Modal>

      <ConfirmDialog
        open={deleteTarget !== null}
        title="Xóa liên kết"
        message={
          deleteTarget
            ? `Bạn có chắc muốn xóa liên kết với «${deleteTarget.studentName ?? deleteTarget.studentId}»?`
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
