# Context Map

Routing table: investigation topic → documentation location.
Do not duplicate content from docs/. Follow references.

---

## Business Domains

### FSchool — Education Management System

Single system covering all roles: Admin, HeadOfDept, Teacher, Student, Parent.

- System requirements (Vietnamese): `docs/SRS.md`
- API endpoint design: `docs/API_DESIGN.md`
- Database schema changelog: `docs/DATABASE_CHANGELOG.md`
- Flutter architecture guide: `docs/FLUTTER_ARCHITECTURE_GUIDE.md`
- Original spec (Word doc): `docs/PRM393.docx`

---

## Technical Topics

### Authentication & Authorization
- JWT Bearer Token + Refresh Token flow: `docs/SRS.md` §3.1
- RBAC roles (Admin, HeadOfDept, Teacher, Student, Parent): `docs/SRS.md` §2
- API auth endpoints: `docs/API_DESIGN.md`
- Backend implementation: `api/Controllers/AuthController.cs` (if exists)

### Database Schema
- Schema changelog: `docs/DATABASE_CHANGELOG.md`
- EF Core entity models: `api/Models/`
- Migrations: `api/Migrations/`
- Raw SQL: `api/sql/`

### API Design
- Full endpoint list: `docs/API_DESIGN.md`
- Controllers: `api/Controllers/`
- DTOs: `api/DTOs/`

### Flutter Mobile
- Architecture guide: `docs/FLUTTER_ARCHITECTURE_GUIDE.md`
- Feature modules: `mobile/lib/features/`
- Core infrastructure: `mobile/lib/core/`
- Assets: `mobile/assets/`
- Dependencies: `mobile/pubspec.yaml`

### Backend (ASP.NET Core)
- Entry point & DI: `api/Program.cs`
- Configuration: `api/appsettings.Development.json`
- Services: `api/Services/`
- Repositories: `api/Repositories/`
- Models: `api/Models/`
- Common utilities: `api/Common/`

---

## Common Investigation Tasks

| Task | Start here |
|------|-----------|
| Understand user roles & permissions | `docs/SRS.md` §2 |
| Understand a functional requirement | `docs/SRS.md` §3 |
| Find API endpoints for a feature | `docs/API_DESIGN.md` |
| Understand database tables | `docs/DATABASE_CHANGELOG.md` |
| Find EF Core entity | `api/Models/` |
| Find business logic for a feature | `api/Services/` |
| Find data access for a feature | `api/Repositories/` |
| Find Flutter screen for a feature | `mobile/lib/features/<feature>/presentation/` |
| Understand Flutter architecture | `docs/FLUTTER_ARCHITECTURE_GUIDE.md` |
| Find app configuration | `api/appsettings.Development.json` |
| Find DI / middleware setup | `api/Program.cs` |
