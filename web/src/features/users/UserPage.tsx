import { type FormEvent, useCallback, useEffect, useMemo, useState } from 'react'
import Button from '../../components/ui/Button'
import ConfirmDialog from '../../components/ui/ConfirmDialog'
import DataTable, { type DataTableColumn } from '../../components/ui/DataTable'
import EmptyState from '../../components/ui/EmptyState'
import Modal from '../../components/ui/Modal'
import PageHeader from '../../components/ui/PageHeader'
import Spinner from '../../components/ui/Spinner'
import { useToast } from '../../components/ui/Toast'
import { ROLE_OPTIONS } from '../auth/types'
import type { UserDto } from '../auth/types'
import { fetchDepartments } from '../departments/api'
import type { Department } from '../departments/types'
import { createUser, deleteUser, fetchUsers, updateUser } from './api'

type FormState = {
  username: string
  password: string
  fullName: string
  email: string
  phoneNumber: string
  departmentId: string
}

const emptyForm: FormState = {
  username: '',
  password: '',
  fullName: '',
  email: '',
  phoneNumber: '',
  departmentId: '',
}

/** Vai trò bắt buộc chọn phòng ban */
function roleNeedsDepartment(roleId: number): boolean {
  return roleId === 2 || roleId === 3
}

/** Map roleId sang nhãn tiếng Việt khi roleName rỗng */
function roleLabel(user: UserDto): string {
  if (user.roleName) return user.roleName
  const found = ROLE_OPTIONS.find((r) => r.id === user.roleId)
  return found?.label ?? `Vai trò #${user.roleId}`
}

/** Quản lý tài khoản — CRUD, tab theo vai trò, khóa/mở */
export default function UserPage() {
  const { showToast } = useToast()
  const [activeRoleId, setActiveRoleId] = useState<number>(ROLE_OPTIONS[0].id)
  const [allUsers, setAllUsers] = useState<UserDto[]>([])
  const [departments, setDepartments] = useState<Department[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [submitting, setSubmitting] = useState(false)

  const [modalOpen, setModalOpen] = useState(false)
  const [editing, setEditing] = useState<UserDto | null>(null)
  const [form, setForm] = useState<FormState>(emptyForm)

  const [deleteTarget, setDeleteTarget] = useState<UserDto | null>(null)
  const [lockTarget, setLockTarget] = useState<UserDto | null>(null)

  const deptNameById = useMemo(
    () => new Map(departments.map((d) => [d.departmentId, d.departmentName])),
    [departments],
  )

  const filteredUsers = useMemo(
    () => allUsers.filter((u) => u.roleId === activeRoleId),
    [allUsers, activeRoleId],
  )

  const activeRoleLabel =
    ROLE_OPTIONS.find((r) => r.id === activeRoleId)?.label ?? `Vai trò #${activeRoleId}`

  const load = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const [users, depts] = await Promise.all([fetchUsers(), fetchDepartments()])
      setAllUsers(users)
      setDepartments(depts)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Không tải được danh sách tài khoản.')
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

  function openEdit(row: UserDto) {
    setEditing(row)
    setForm({
      username: row.username,
      password: '',
      fullName: row.fullName,
      email: row.email ?? '',
      phoneNumber: row.phoneNumber ?? '',
      departmentId: row.departmentId !== null ? String(row.departmentId) : '',
    })
    setModalOpen(true)
  }

  function closeModal() {
    setModalOpen(false)
    setEditing(null)
    setForm(emptyForm)
  }

  function resolveDepartmentId(roleId: number): number | null | undefined {
    if (!roleNeedsDepartment(roleId)) return null
    if (form.departmentId === '') return undefined
    return Number(form.departmentId)
  }

  async function handleSubmit(e: FormEvent) {
    e.preventDefault()
    const fullName = form.fullName.trim()
    if (!fullName) {
      showToast('Vui lòng nhập họ tên.', 'error')
      return
    }

    const roleId = editing?.roleId ?? activeRoleId
    const departmentId = resolveDepartmentId(roleId)
    if (roleNeedsDepartment(roleId) && departmentId === undefined) {
      showToast('Vui lòng chọn phòng ban cho vai trò này.', 'error')
      return
    }

    setSubmitting(true)
    try {
      if (editing) {
        await updateUser(editing.id, {
          fullName,
          email: form.email.trim() || null,
          phoneNumber: form.phoneNumber.trim() || null,
          roleId,
          departmentId: departmentId ?? null,
        })
        showToast('Đã cập nhật tài khoản.', 'success')
      } else {
        const username = form.username.trim()
        const password = form.password
        if (!username) {
          showToast('Vui lòng nhập tên đăng nhập.', 'error')
          return
        }
        if (!password) {
          showToast('Vui lòng nhập mật khẩu.', 'error')
          return
        }
        await createUser({
          username,
          password,
          fullName,
          roleId,
          email: form.email.trim() || null,
          phoneNumber: form.phoneNumber.trim() || null,
          departmentId: departmentId ?? null,
        })
        showToast('Đã thêm tài khoản mới.', 'success')
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
      await deleteUser(deleteTarget.id)
      showToast('Đã xóa tài khoản.', 'success')
      setDeleteTarget(null)
      await load()
    } catch (err) {
      showToast(err instanceof Error ? err.message : 'Xóa thất bại.', 'error')
    } finally {
      setSubmitting(false)
    }
  }

  async function handleLockConfirm() {
    if (!lockTarget) return
    setSubmitting(true)
    try {
      await updateUser(lockTarget.id, { isActive: !lockTarget.isActive })
      showToast(
        lockTarget.isActive ? 'Đã khóa tài khoản.' : 'Đã mở khóa tài khoản.',
        'success',
      )
      setLockTarget(null)
      await load()
    } catch (err) {
      showToast(err instanceof Error ? err.message : 'Thao tác thất bại.', 'error')
    } finally {
      setSubmitting(false)
    }
  }

  const columns: DataTableColumn<UserDto>[] = [
    { key: 'id', header: 'ID' },
    { key: 'username', header: 'Tên đăng nhập' },
    { key: 'fullName', header: 'Họ tên' },
    {
      key: 'roleName',
      header: 'Vai trò',
      render: (row) => roleLabel(row),
    },
    {
      key: 'departmentId',
      header: 'Phòng ban',
      render: (row) =>
        row.departmentId !== null
          ? (deptNameById.get(row.departmentId) ?? `#${row.departmentId}`)
          : '—',
    },
    {
      key: 'email',
      header: 'Email',
      render: (row) => row.email ?? '—',
    },
    {
      key: 'isActive',
      header: 'Trạng thái',
      render: (row) => (row.isActive ? 'Hoạt động' : 'Đã khóa'),
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
            variant="secondary"
            onClick={() => setLockTarget(row)}
            disabled={submitting}
          >
            {row.isActive ? 'Khóa' : 'Mở khóa'}
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

  const showDepartmentField = roleNeedsDepartment(editing?.roleId ?? activeRoleId)

  return (
    <>
      <PageHeader
        title="Tài khoản người dùng"
        subtitle="Quản lý tài khoản theo vai trò trong hệ thống"
        actions={
          <Button onClick={openCreate} disabled={loading || submitting}>
            Thêm tài khoản
          </Button>
        }
      />

      <div
        role="tablist"
        aria-label="Lọc theo vai trò"
        style={{ display: 'flex', flexWrap: 'wrap', gap: 8, marginBottom: 24 }}
      >
        {ROLE_OPTIONS.map((role) => {
          const count = allUsers.filter((u) => u.roleId === role.id).length
          const active = activeRoleId === role.id
          return (
            <Button
              key={role.id}
              size="sm"
              variant={active ? 'primary' : 'secondary'}
              onClick={() => setActiveRoleId(role.id)}
              disabled={loading || submitting}
              aria-selected={active}
            >
              {role.label} ({count})
            </Button>
          )
        })}
      </div>

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

      {!loading && !error && filteredUsers.length === 0 && (
        <EmptyState
          title={`Chưa có ${activeRoleLabel.toLowerCase()}`}
          message={`Nhấn «Thêm tài khoản» để tạo tài khoản ${activeRoleLabel.toLowerCase()} đầu tiên.`}
          action={<Button onClick={openCreate}>Thêm tài khoản</Button>}
        />
      )}

      {!loading && !error && filteredUsers.length > 0 && (
        <DataTable columns={columns} data={filteredUsers} rowKey={(row) => row.id} />
      )}

      <Modal
        open={modalOpen}
        title={editing ? 'Sửa tài khoản' : 'Thêm tài khoản'}
        onClose={closeModal}
        footer={
          <>
            <Button variant="secondary" onClick={closeModal} disabled={submitting}>
              Hủy
            </Button>
            <Button type="submit" form="user-form" loading={submitting}>
              {editing ? 'Lưu' : 'Thêm'}
            </Button>
          </>
        }
      >
        <form id="user-form" onSubmit={handleSubmit}>
          {!editing && (
            <>
              <div className="ui-field">
                <label htmlFor="user-username">Tên đăng nhập *</label>
                <input
                  id="user-username"
                  value={form.username}
                  onChange={(e) => setForm((f) => ({ ...f, username: e.target.value }))}
                  disabled={submitting}
                  autoComplete="off"
                  placeholder="VD: teacher01"
                />
              </div>
              <div className="ui-field">
                <label htmlFor="user-password">Mật khẩu *</label>
                <input
                  id="user-password"
                  type="password"
                  value={form.password}
                  onChange={(e) => setForm((f) => ({ ...f, password: e.target.value }))}
                  disabled={submitting}
                  autoComplete="new-password"
                />
              </div>
            </>
          )}

          {editing && (
            <div className="ui-field">
              <label htmlFor="user-username-readonly">Tên đăng nhập</label>
              <input id="user-username-readonly" value={form.username} disabled />
            </div>
          )}

          <div className="ui-field">
            <label htmlFor="user-fullname">Họ tên *</label>
            <input
              id="user-fullname"
              value={form.fullName}
              onChange={(e) => setForm((f) => ({ ...f, fullName: e.target.value }))}
              disabled={submitting}
              placeholder="Họ và tên đầy đủ"
            />
          </div>

          <div className="ui-field">
            <label htmlFor="user-role">Vai trò</label>
            <input
              id="user-role"
              value={editing ? roleLabel(editing) : activeRoleLabel}
              disabled
            />
          </div>

          {showDepartmentField && (
            <div className="ui-field">
              <label htmlFor="user-dept">Phòng ban *</label>
              <select
                id="user-dept"
                value={form.departmentId}
                onChange={(e) => setForm((f) => ({ ...f, departmentId: e.target.value }))}
                disabled={submitting || departments.length === 0}
              >
                <option value="">— Chọn phòng ban —</option>
                {departments.map((d) => (
                  <option key={d.departmentId} value={d.departmentId}>
                    {d.departmentName}
                  </option>
                ))}
              </select>
            </div>
          )}

          <div className="ui-field">
            <label htmlFor="user-email">Email</label>
            <input
              id="user-email"
              type="email"
              value={form.email}
              onChange={(e) => setForm((f) => ({ ...f, email: e.target.value }))}
              disabled={submitting}
              placeholder="Tuỳ chọn"
            />
          </div>

          <div className="ui-field">
            <label htmlFor="user-phone">Số điện thoại</label>
            <input
              id="user-phone"
              value={form.phoneNumber}
              onChange={(e) => setForm((f) => ({ ...f, phoneNumber: e.target.value }))}
              disabled={submitting}
              placeholder="Tuỳ chọn"
            />
          </div>
        </form>
      </Modal>

      <ConfirmDialog
        open={deleteTarget !== null}
        title="Xóa tài khoản"
        message={
          deleteTarget
            ? `Bạn có chắc muốn xóa tài khoản «${deleteTarget.fullName}» (${deleteTarget.username})?`
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

      <ConfirmDialog
        open={lockTarget !== null}
        title={lockTarget?.isActive ? 'Khóa tài khoản' : 'Mở khóa tài khoản'}
        message={
          lockTarget
            ? lockTarget.isActive
              ? `Khóa tài khoản «${lockTarget.fullName}»? Người dùng sẽ không đăng nhập được.`
              : `Mở khóa tài khoản «${lockTarget.fullName}»?`
            : ''
        }
        confirmLabel={lockTarget?.isActive ? 'Khóa' : 'Mở khóa'}
        variant={lockTarget?.isActive ? 'danger' : 'primary'}
        loading={submitting}
        onConfirm={() => void handleLockConfirm()}
        onCancel={() => {
          if (!submitting) setLockTarget(null)
        }}
      />
    </>
  )
}
