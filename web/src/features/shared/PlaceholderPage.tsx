import PageHeader from '../../components/ui/PageHeader'

/** Trang placeholder cho module chưa triển khai */
export default function PlaceholderPage() {
  return (
    <>
      <PageHeader title="Đang phát triển" subtitle="Module sẽ được bổ sung ở task tiếp theo" />
      <div className="placeholder-page">
        <h2>Đang phát triển</h2>
        <p>Chức năng này sẽ sớm có mặt trên web quản trị.</p>
      </div>
    </>
  )
}
