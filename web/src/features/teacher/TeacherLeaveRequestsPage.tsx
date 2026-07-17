import { useEffect, useState } from 'react'
import Button from '../../components/ui/Button'
import DataTable, { type DataTableColumn } from '../../components/ui/DataTable'
import PageHeader from '../../components/ui/PageHeader'
import Spinner from '../../components/ui/Spinner'
import { useAuth } from '../../core/auth/AuthContext'
import { fetchPendingLeaveRequests, reviewLeaveRequest } from './api'
import type { StudentRequest } from './types'

function getStatusLabel(status: string) {
  const value = status.toLowerCase()
  if (value === 'approved') return 'Đã duyệt'
  if (value === 'rejected') return 'Từ chối'
  return 'Chờ duyệt'
}

export default function TeacherLeaveRequestsPage() {
  const { user } = useAuth()
  const reviewerId = user?.id
  const [requests, setRequests] = useState<StudentRequest[]>([])
  const [reviewNote, setReviewNote] = useState('')
  const [loading, setLoading] = useState(true)
  const [reviewingId, setReviewingId] = useState<number | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [message, setMessage] = useState<string | null>(null)

  async function load() {
    setLoading(true)
    setError(null)
    try {
      setRequests(await fetchPendingLeaveRequests())
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Không thể tải đơn xin nghỉ.')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    void load()
  }, [])

  async function review(requestId: number, status: 'Approved' | 'Rejected') {
    if (!reviewerId) return

    setReviewingId(requestId)
    setError(null)
    setMessage(null)
    try {
      await reviewLeaveRequest(requestId, {
        status,
        reviewedBy: reviewerId,
        reviewNote: reviewNote.trim() || null,
      })
      setMessage(status === 'Approved' ? 'Đã duyệt đơn xin nghỉ.' : 'Đã từ chối đơn xin nghỉ.')
      setReviewNote('')
      await load()
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Không thể xử lý đơn.')
    } finally {
      setReviewingId(null)
    }
  }

  const columns: DataTableColumn<StudentRequest>[] = [
    { key: 'studentName', header: 'Học sinh', render: (row) => row.studentName ?? `HS #${row.studentId}` },
    { key: 'requestedByName', header: 'Người gửi', render: (row) => row.requestedByName ?? `User #${row.requestedBy}` },
    { key: 'leaveDate', header: 'Ngày nghỉ', render: (row) => row.leaveDate.slice(0, 10) },
    { key: 'reason', header: 'Lý do' },
    { key: 'status', header: 'Trạng thái', render: (row) => getStatusLabel(row.status) },
    {
      key: 'actions',
      header: '',
      render: (row) => (
        <div className="data-table__actions">
          <Button
            size="sm"
            loading={reviewingId === row.studentRequestId}
            onClick={() => void review(row.studentRequestId, 'Approved')}
          >
            Duyệt
          </Button>
          <Button
            size="sm"
            variant="danger"
            loading={reviewingId === row.studentRequestId}
            onClick={() => void review(row.studentRequestId, 'Rejected')}
          >
            Từ chối
          </Button>
        </div>
      ),
    },
  ]

  return (
    <>
      <PageHeader
        title="Đơn xin nghỉ"
        subtitle="Xem các đơn chờ duyệt thuộc lớp giáo viên phụ trách và phản hồi."
      />

      <div className="teacher-form-panel teacher-form-panel--compact">
        <div className="ui-field">
          <label htmlFor="review-note">Ghi chú phản hồi</label>
          <input
            id="review-note"
            value={reviewNote}
            onChange={(event) => setReviewNote(event.target.value)}
            placeholder="Tuỳ chọn"
          />
        </div>
      </div>

      {message && <p className="teacher-success">{message}</p>}
      {error && <p className="teacher-alert">{error}</p>}

      {loading ? (
        <div className="state-panel">
          <Spinner />
          <p className="state-panel__message">Đang tải đơn xin nghỉ...</p>
        </div>
      ) : (
        <DataTable
          columns={columns}
          data={requests}
          rowKey={(row) => row.studentRequestId}
          emptyMessage="Không có đơn chờ duyệt."
        />
      )}
    </>
  )
}
