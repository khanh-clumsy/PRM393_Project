import type { ReactNode } from 'react'

export type DataTableColumn<T> = {
  key: string
  header: string
  render?: (row: T, index: number) => ReactNode
  className?: string
}

type DataTableProps<T> = {
  columns: DataTableColumn<T>[]
  data: T[]
  rowKey: (row: T) => string | number
  emptyMessage?: string
}

/** Bảng dữ liệu generic — cột định nghĩa qua config */
export default function DataTable<T>({
  columns,
  data,
  rowKey,
  emptyMessage = 'Không có dữ liệu',
}: DataTableProps<T>) {
  if (data.length === 0) {
    return (
      <div className="data-table-wrap">
        <div className="state-panel" style={{ border: 'none', borderRadius: 0 }}>
          <p className="state-panel__message">{emptyMessage}</p>
        </div>
      </div>
    )
  }

  return (
    <div className="data-table-wrap">
      <table className="data-table">
        <thead>
          <tr>
            {columns.map((col) => (
              <th key={col.key} className={col.className}>
                {col.header}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {data.map((row, index) => (
            <tr key={rowKey(row)}>
              {columns.map((col) => (
                <td key={col.key} className={col.className}>
                  {col.render
                    ? col.render(row, index)
                    : String((row as Record<string, unknown>)[col.key] ?? '')}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
