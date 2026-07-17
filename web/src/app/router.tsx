import { Navigate, Route, Routes } from 'react-router-dom'
import RequireAdmin from '../core/auth/RequireAdmin'
import RequireRole from '../core/auth/RequireRole'
import AccountPage from '../features/account/AccountPage'
import AcademicYearPage from '../features/academic-years/AcademicYearPage'
import LoginPage from '../features/auth/LoginPage'
import ClassPage from '../features/classes/ClassPage'
import DashboardPage from '../features/dashboard/DashboardPage'
import DepartmentPage from '../features/departments/DepartmentPage'
import RankPage from '../features/ranks/RankPage'
import AnnouncementPage from '../features/announcements/AnnouncementPage'
import SlotPage from '../features/slots/SlotPage'
import TimetablePage from '../features/timetables/TimetablePage'
import SemesterPage from '../features/semesters/SemesterPage'
import SubjectPage from '../features/subjects/SubjectPage'
import ParentStudentPage from '../features/parent-students/ParentStudentPage'
import StudentClassPage from '../features/student-classes/StudentClassPage'
import TeachingAssignmentPage from '../features/teaching-assignments/TeachingAssignmentPage'
import {
  TeacherAnnouncementsPage,
  TeacherAttendancePage,
  TeacherClassesPage,
  TeacherClassSummariesPage,
  TeacherDashboardPage,
  TeacherGradesPage,
  TeacherLeaveRequestsPage,
  TeacherTimetablePage,
} from '../features/teacher'
import UserPage from '../features/users/UserPage'
import AdminLayout from '../layouts/AdminLayout'
import TeacherLayout from '../layouts/TeacherLayout'

/** Định nghĩa route công khai, khu vực Admin và Teacher portal. */
export default function AppRouter() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route element={<RequireAdmin />}>
        <Route path="/admin" element={<AdminLayout />}>
          <Route index element={<DashboardPage />} />
          <Route path="users" element={<UserPage />} />
          <Route path="departments" element={<DepartmentPage />} />
          <Route path="academic-years" element={<AcademicYearPage />} />
          <Route path="semesters" element={<SemesterPage />} />
          <Route path="subjects" element={<SubjectPage />} />
          <Route path="classes" element={<ClassPage />} />
          <Route path="ranks" element={<RankPage />} />
          <Route path="slots" element={<SlotPage />} />
          <Route path="teaching-assignments" element={<TeachingAssignmentPage />} />
          <Route path="timetables" element={<TimetablePage />} />
          <Route path="student-classes" element={<StudentClassPage />} />
          <Route path="parent-student" element={<ParentStudentPage />} />
          <Route path="announcements" element={<AnnouncementPage />} />
          <Route path="account" element={<AccountPage />} />
        </Route>
      </Route>
      <Route element={<RequireRole allow={['Teacher']} />}>
        <Route path="/teacher" element={<TeacherLayout />}>
          <Route index element={<TeacherDashboardPage />} />
          <Route path="classes" element={<TeacherClassesPage />} />
          <Route path="timetable" element={<TeacherTimetablePage />} />
          <Route path="attendance" element={<TeacherAttendancePage />} />
          <Route path="grades" element={<TeacherGradesPage />} />
          <Route path="announcements" element={<TeacherAnnouncementsPage />} />
          <Route path="leave-requests" element={<TeacherLeaveRequestsPage />} />
          <Route path="class-summaries" element={<TeacherClassSummariesPage />} />
          <Route path="account" element={<AccountPage />} />
        </Route>
      </Route>
      <Route path="*" element={<Navigate to="/login" replace />} />
    </Routes>
  )
}
