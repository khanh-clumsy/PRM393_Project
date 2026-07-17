import type { AcademicYear } from '../academic-years/types'
import type { Semester } from '../semesters/types'
import type {
  AttendanceRecord,
  AttendanceStatusCode,
  GradeDraft,
  SchoolClass,
  StudentClass,
  TeacherAttendanceEntry,
  TeacherClass,
  TeachingAssignment,
} from './types'

export function getAcademicYearSortKey(year: AcademicYear) {
  const parsed = Date.parse(year.startDate)
  if (!Number.isNaN(parsed)) return parsed

  const match = year.yearName.match(/^(\d{4})/)
  return match ? Number(match[1]) : year.academicYearId
}

export function sortAcademicYears(years: AcademicYear[]) {
  return [...years].sort((a, b) => getAcademicYearSortKey(a) - getAcademicYearSortKey(b))
}

export function getPreferredAcademicYearId(years: AcademicYear[]) {
  if (years.length === 0) return ''
  const sorted = sortAcademicYears(years)
  const active = sorted.filter((year) => year.isActive)
  return (active.at(-1) ?? sorted.at(-1))?.academicYearId ?? ''
}

export function getSemestersForYear(semesters: Semester[], academicYearId: number | '') {
  if (academicYearId === '') return []
  return semesters
    .filter((semester) => semester.academicYearId === academicYearId)
    .sort((a, b) => b.semesterId - a.semesterId)
}

export function dedupeAssignments(assignments: TeachingAssignment[]) {
  const byClassSubject = new Map<string, TeachingAssignment>()

  for (const assignment of assignments) {
    const key = `${assignment.classId}_${assignment.subjectId}`
    const existing = byClassSubject.get(key)
    if (!existing || assignment.semesterId > existing.semesterId) {
      byClassSubject.set(key, assignment)
    }
  }

  return [...byClassSubject.values()].sort((a, b) => {
    const classCompare = (a.className ?? '').localeCompare(b.className ?? '', 'vi')
    if (classCompare !== 0) return classCompare
    return (a.subjectName ?? '').localeCompare(b.subjectName ?? '', 'vi')
  })
}

export function getAssignmentsForSemester(assignments: TeachingAssignment[], semesterId: number | '') {
  if (semesterId === '') return []
  return dedupeAssignments(assignments.filter((assignment) => assignment.semesterId === semesterId))
}

export function mergeTeacherClasses(
  taughtAssignments: TeachingAssignment[],
  homeroomClasses: SchoolClass[],
): TeacherClass[] {
  const byClass = new Map<number, TeacherClass>()

  for (const assignment of taughtAssignments) {
    const existing = byClass.get(assignment.classId)
    if (existing) {
      existing.assignments.push(assignment)
      continue
    }

    byClass.set(assignment.classId, {
      classId: assignment.classId,
      className: assignment.className ?? `Lớp #${assignment.classId}`,
      academicYearId: 0,
      homeroomTeacherId: null,
      role: 'teaching',
      assignments: [assignment],
    })
  }

  for (const cls of homeroomClasses) {
    const existing = byClass.get(cls.classId)
    if (existing) {
      byClass.set(cls.classId, {
        ...existing,
        ...cls,
        role: 'both',
        assignments: existing.assignments,
      })
      continue
    }

    byClass.set(cls.classId, {
      ...cls,
      role: 'homeroom',
      assignments: [],
    })
  }

  return [...byClass.values()].sort((a, b) =>
    a.className.localeCompare(b.className, 'vi'),
  )
}

export function getRoleLabel(role: TeacherClass['role']) {
  if (role === 'both') return 'Giảng dạy + GVCN'
  if (role === 'homeroom') return 'GVCN'
  return 'Giảng dạy'
}

export function normalizeAttendanceStatus(status: string | null | undefined): AttendanceStatusCode {
  const value = (status ?? '').toUpperCase()
  if (value === 'A' || value === 'ABSENT') return 'A'
  if (value === 'L' || value === 'LATE') return 'L'
  if (value === 'E' || value === 'EXCUSED') return 'E'
  return 'P'
}

export function getAttendanceStatusLabel(status: string) {
  switch (normalizeAttendanceStatus(status)) {
    case 'A':
      return 'Vắng'
    case 'L':
      return 'Muộn'
    case 'E':
      return 'Có phép'
    case 'P':
    default:
      return 'Có mặt'
  }
}

export function buildAttendanceEntries(
  students: StudentClass[],
  records: AttendanceRecord[],
): TeacherAttendanceEntry[] {
  const recordsByStudent = new Map(records.map((record) => [record.studentId, record]))

  return students.map((student) => {
    const record = recordsByStudent.get(student.studentId)
    return {
      ...student,
      attendanceId: record?.attendanceId ?? null,
      status: normalizeAttendanceStatus(record?.status),
      note: record?.note ?? '',
    }
  })
}

export function parseGradeInput(value: string): { score: number | null; error: string | null } {
  const trimmed = value.trim()
  if (!trimmed) return { score: null, error: null }

  const score = Number(trimmed)
  if (!Number.isFinite(score)) {
    return { score: null, error: 'Điểm phải là số.' }
  }

  if (score < 0 || score > 10) {
    return { score: null, error: 'Điểm phải trong khoảng 0..10 hoặc để trống.' }
  }

  return { score, error: null }
}

export function hasGradeErrors(rows: GradeDraft[]) {
  return rows.some((row) => row.error !== null)
}
