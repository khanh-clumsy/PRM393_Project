# Database Runbook

SQL Server. EF Core Code-First migrations. Schema owned by `api/` project.

---

## Schema Ownership

All database schema is defined through EF Core entity models in `api/Models/`.
Migrations are auto-generated and live in `api/Migrations/`.
Do not write manual DDL unless adding raw SQL for seed data in `api/sql/`.

---

## Key Locations

| Purpose | Path |
|---------|------|
| EF Core entities (schema definition) | `api/Models/` |
| EF Core migrations | `api/Migrations/` |
| Raw SQL scripts / seed data | `api/sql/` |
| DbContext configuration | `api/Program.cs` or `api/Common/` |
| Connection string | `api/appsettings.Development.json` |

---

## Migration Workflow

```powershell
# 1. Modify entity in api/Models/
# 2. Create migration (working dir: api/)
dotnet ef migrations add <DescriptiveName>

# 3. Review the generated migration file in api/Migrations/
# 4. Apply to database
dotnet ef database update

# 5. If migration is wrong, remove it before applying:
dotnet ef migrations remove
```

---

## Schema Reference

See `docs/DATABASE_CHANGELOG.md` for the full schema changelog and table definitions.

Key tables (from SRS):
- `Users` — all users across roles
- `Departments` — subject groups (Tổ chuyên môn)
- `Classes` — school classes
- `Subjects` — academic subjects
- `AcademicYears`, `Semesters`
- `StudentClasses` — student-class enrollment history
- `TeachingAssignments` — teacher-class-subject-semester mapping
- `Timetables` — weekly schedule slots
- `AttendanceRecords` — per-lesson attendance (P/A/L)
- `AssessmentTypes`, `Grades` — grade columns and scores
- `Assignments`, `Submissions` — homework
- `StudentSemesterSummaries`, `StudentYearlySummaries` — academic results
- `AcademicRanks` — grading rubrics

---

## Conventions

- Use EF Core Fluent API (in `OnModelCreating`) for complex relationships and constraints.
- Avoid data annotations on models where Fluent API is sufficient.
- All new tables need a migration — never modify the database directly.
- Seed data goes in `api/sql/` as `.sql` files, not in migrations.
- Check `docs/DATABASE_CHANGELOG.md` before adding new tables to avoid duplication.
