import { Navigate, Route, Routes } from 'react-router-dom'
import RequireAdmin from '../core/auth/RequireAdmin'
import AccountPage from '../features/account/AccountPage'
import AcademicYearPage from '../features/academic-years/AcademicYearPage'
import LoginPage from '../features/auth/LoginPage'
import ClassPage from '../features/classes/ClassPage'
import DashboardPage from '../features/dashboard/DashboardPage'
import DepartmentPage from '../features/departments/DepartmentPage'
import RankPage from '../features/ranks/RankPage'
import PlaceholderPage from '../features/shared/PlaceholderPage'
import SlotPage from '../features/slots/SlotPage'
import SemesterPage from '../features/semesters/SemesterPage'
import SubjectPage from '../features/subjects/SubjectPage'
import AdminLayout from '../layouts/AdminLayout'

/** Định nghĩa route công khai và khu vực Admin */
export default function AppRouter() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route element={<RequireAdmin />}>
        <Route path="/admin" element={<AdminLayout />}>
          <Route index element={<DashboardPage />} />
          <Route path="users" element={<PlaceholderPage />} />
          <Route path="departments" element={<DepartmentPage />} />
          <Route path="academic-years" element={<AcademicYearPage />} />
          <Route path="semesters" element={<SemesterPage />} />
          <Route path="subjects" element={<SubjectPage />} />
          <Route path="classes" element={<ClassPage />} />
          <Route path="ranks" element={<RankPage />} />
          <Route path="slots" element={<SlotPage />} />
          <Route path="teaching-assignments" element={<PlaceholderPage />} />
          <Route path="timetables" element={<PlaceholderPage />} />
          <Route path="student-classes" element={<PlaceholderPage />} />
          <Route path="parent-student" element={<PlaceholderPage />} />
          <Route path="announcements" element={<PlaceholderPage />} />
          <Route path="account" element={<AccountPage />} />
        </Route>
      </Route>
      <Route path="*" element={<Navigate to="/admin" replace />} />
    </Routes>
  )
}
