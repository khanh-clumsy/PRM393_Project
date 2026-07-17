import { useCallback, useEffect, useState } from 'react'
import Button from '../../components/ui/Button'
import PageHeader from '../../components/ui/PageHeader'
import Spinner from '../../components/ui/Spinner'
import { fetchDashboardStats } from './api'

type Stats = {
  userCount: number
  classCount: number
  subjectCount: number
}

/** Bảng điều khiển — thống kê nhanh tài khoản, lớp, môn học */
export default function DashboardPage() {
  const [stats, setStats] = useState<Stats | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const load = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const data = await fetchDashboardStats()
      setStats(data)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Không tải được thống kê.')
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    void load()
  }, [load])

  return (
    <>
      <PageHeader
        title="Thống kê"
        subtitle="Tổng quan dữ liệu hệ thống"
      />

      {loading && (
        <div className="state-panel">
          <Spinner size="lg" />
          <p className="state-panel__message">Đang tải thống kê…</p>
        </div>
      )}

      {!loading && error && (
        <div className="state-panel state-panel--error">
          <p className="state-panel__title">Lỗi tải dữ liệu</p>
          <p className="state-panel__message">{error}</p>
          <Button onClick={() => void load()}>Thử lại</Button>
        </div>
      )}

      {!loading && !error && stats && (
        <div className="stat-grid">
          <div className="stat-card">
            <p className="stat-card__label">Tài khoản</p>
            <p className="stat-card__value">{stats.userCount}</p>
          </div>
          <div className="stat-card">
            <p className="stat-card__label">Lớp học</p>
            <p className="stat-card__value">{stats.classCount}</p>
          </div>
          <div className="stat-card">
            <p className="stat-card__label">Môn học</p>
            <p className="stat-card__value">{stats.subjectCount}</p>
          </div>
        </div>
      )}
    </>
  )
}
