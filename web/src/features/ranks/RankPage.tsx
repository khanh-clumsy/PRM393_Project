import { type FormEvent, useCallback, useEffect, useState } from 'react'
import Button from '../../components/ui/Button'
import ConfirmDialog from '../../components/ui/ConfirmDialog'
import DataTable, { type DataTableColumn } from '../../components/ui/DataTable'
import EmptyState from '../../components/ui/EmptyState'
import Modal from '../../components/ui/Modal'
import PageHeader from '../../components/ui/PageHeader'
import Spinner from '../../components/ui/Spinner'
import { useToast } from '../../components/ui/Toast'
import { createRank, deleteRank, fetchRanks, updateRank } from './api'
import type { AcademicRank } from './types'

type FormState = {
  rankName: string
  minScore: string
  maxScore: string
}

const emptyForm: FormState = { rankName: '', minScore: '', maxScore: '' }

/** Quản lý xếp loại học lực — CRUD đầy đủ */
export default function RankPage() {
  const { showToast } = useToast()
  const [items, setItems] = useState<AcademicRank[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [submitting, setSubmitting] = useState(false)

  const [modalOpen, setModalOpen] = useState(false)
  const [editing, setEditing] = useState<AcademicRank | null>(null)
  const [form, setForm] = useState<FormState>(emptyForm)

  const [deleteTarget, setDeleteTarget] = useState<AcademicRank | null>(null)

  const load = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const data = await fetchRanks()
      setItems(data)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Không tải được danh sách xếp loại.')
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    void load()
  }, [load])

  function openCreate() {
    setEditing(null)
    setForm(emptyForm)
    setModalOpen(true)
  }

  function openEdit(row: AcademicRank) {
    setEditing(row)
    setForm({
      rankName: row.rankName,
      minScore: String(row.minScore),
      maxScore: String(row.maxScore),
    })
    setModalOpen(true)
  }

  function closeModal() {
    setModalOpen(false)
    setEditing(null)
    setForm(emptyForm)
  }

  function parseScores(): { min: number; max: number } | null {
    const min = Number(form.minScore)
    const max = Number(form.maxScore)
    if (Number.isNaN(min) || Number.isNaN(max)) {
      showToast('Điểm tối thiểu và tối đa phải là số hợp lệ.', 'error')
      return null
    }
    if (min < 0 || max < 0) {
      showToast('Điểm tối thiểu và tối đa phải ≥ 0.', 'error')
      return null
    }
    if (min > max) {
      showToast('Điểm tối thiểu phải ≤ điểm tối đa.', 'error')
      return null
    }
    return { min, max }
  }

  async function handleSubmit(e: FormEvent) {
    e.preventDefault()
    const name = form.rankName.trim()
    if (!name) {
      showToast('Vui lòng nhập tên xếp loại.', 'error')
      return
    }
    const scores = parseScores()
    if (!scores) return

    setSubmitting(true)
    try {
      if (editing) {
        await updateRank(editing.rankId, {
          rankName: name,
          minScore: scores.min,
          maxScore: scores.max,
        })
        showToast('Đã cập nhật xếp loại.', 'success')
      } else {
        await createRank({
          rankName: name,
          minScore: scores.min,
          maxScore: scores.max,
        })
        showToast('Đã thêm xếp loại mới.', 'success')
      }
      closeModal()
      await load()
    } catch (err) {
      showToast(err instanceof Error ? err.message : 'Thao tác thất bại.', 'error')
    } finally {
      setSubmitting(false)
    }
  }

  async function handleDeleteConfirm() {
    if (!deleteTarget) return
    setSubmitting(true)
    try {
      await deleteRank(deleteTarget.rankId)
      showToast('Đã xóa xếp loại.', 'success')
      setDeleteTarget(null)
      await load()
    } catch (err) {
      showToast(err instanceof Error ? err.message : 'Xóa thất bại.', 'error')
    } finally {
      setSubmitting(false)
    }
  }

  const columns: DataTableColumn<AcademicRank>[] = [
    { key: 'rankId', header: 'ID' },
    { key: 'rankName', header: 'Tên xếp loại' },
    {
      key: 'minScore',
      header: 'Điểm tối thiểu',
      render: (row) => row.minScore.toFixed(1),
    },
    {
      key: 'maxScore',
      header: 'Điểm tối đa',
      render: (row) => row.maxScore.toFixed(1),
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

  return (
    <>
      <PageHeader
        title="Xếp loại học lực"
        subtitle="Quản lý thang điểm xếp loại học tập"
        actions={
          <Button onClick={openCreate} disabled={loading || submitting}>
            Thêm xếp loại
          </Button>
        }
      />

      {loading && (
        <div className="state-panel">
          <Spinner size="lg" />
          <p className="state-panel__message">Đang tải danh sách…</p>
        </div>
      )}

      {!loading && error && (
        <div className="state-panel state-panel--error">
          <p className="state-panel__title">Lỗi tải dữ liệu</p>
          <p className="state-panel__message">{error}</p>
          <Button onClick={() => void load()}>Thử lại</Button>
        </div>
      )}

      {!loading && !error && items.length === 0 && (
        <EmptyState
          title="Chưa có xếp loại"
          message="Nhấn «Thêm xếp loại» để tạo bản ghi đầu tiên."
          action={<Button onClick={openCreate}>Thêm xếp loại</Button>}
        />
      )}

      {!loading && !error && items.length > 0 && (
        <DataTable columns={columns} data={items} rowKey={(row) => row.rankId} />
      )}

      <Modal
        open={modalOpen}
        title={editing ? 'Sửa xếp loại' : 'Thêm xếp loại'}
        onClose={closeModal}
        footer={
          <>
            <Button variant="secondary" onClick={closeModal} disabled={submitting}>
              Hủy
            </Button>
            <Button type="submit" form="rank-form" loading={submitting}>
              {editing ? 'Lưu' : 'Thêm'}
            </Button>
          </>
        }
      >
        <form id="rank-form" onSubmit={handleSubmit}>
          <div className="ui-field">
            <label htmlFor="rank-name">Tên xếp loại *</label>
            <input
              id="rank-name"
              value={form.rankName}
              onChange={(e) => setForm((f) => ({ ...f, rankName: e.target.value }))}
              disabled={submitting}
              placeholder="VD: Giỏi"
            />
          </div>
          <div className="ui-field">
            <label htmlFor="rank-min">Điểm tối thiểu *</label>
            <input
              id="rank-min"
              type="number"
              min={0}
              step={0.1}
              value={form.minScore}
              onChange={(e) => setForm((f) => ({ ...f, minScore: e.target.value }))}
              disabled={submitting}
              placeholder="VD: 8.0"
            />
          </div>
          <div className="ui-field">
            <label htmlFor="rank-max">Điểm tối đa *</label>
            <input
              id="rank-max"
              type="number"
              min={0}
              step={0.1}
              value={form.maxScore}
              onChange={(e) => setForm((f) => ({ ...f, maxScore: e.target.value }))}
              disabled={submitting}
              placeholder="VD: 10.0"
            />
          </div>
        </form>
      </Modal>

      <ConfirmDialog
        open={deleteTarget !== null}
        title="Xóa xếp loại"
        message={
          deleteTarget ? `Bạn có chắc muốn xóa «${deleteTarget.rankName}»?` : ''
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
