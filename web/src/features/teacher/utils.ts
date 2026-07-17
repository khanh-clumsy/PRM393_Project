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
  roster: StudentClass[],
  records: AttendanceRecord[],
): TeacherAttendanceEntry[] {
  const recordsByStudent = new Map(records.map((record) => [record.studentId, record]))

  return roster.map((student) => {
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
