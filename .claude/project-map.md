# Project Map

Structural overview. For domain knowledge, follow links to docs/.

---

## Repository Root

```
PRM393_Project/
├── mobile/            Flutter mobile app (Android/iOS)
├── api/               ASP.NET Core 8 Web API (C#)
├── web/               React Admin web (Vite + TypeScript)
├── docs/              Single source of truth documentation
└── .claude/           Claude Code orchestration layer (this directory)
```

Active documentation: `docs/` only.

---

## System: FSchool — Education Management & Communication App

Single system with role-based access for: Admin, HeadOfDept, Teacher, Student, Parent.

**Domain modules:**
- Authentication & User Management
- Academic Management (Years, Semesters, Classes, Subjects)
- Teaching Assignments & Timetables
- Attendance Records
- Grades & Assessment
- Assignments (Homework)
- Announcements / News Feed
- Academic Summaries (Học bạ điện tử)

---

## Backend Structure (`api/`)

ASP.NET Core 8 Web API. Clean Architecture pattern.

```
api/
├── Controllers/           HTTP controllers (route → service)
├── Services/              Business logic layer
├── Repositories/          Data access layer (EF Core)
├── Models/                EF Core entity models (database tables)
├── DTOs/                  Request/response data transfer objects
├── Common/                Shared utilities, helpers, middleware
├── Migrations/            EF Core Code-First migrations
├── sql/                   Raw SQL scripts / seed data
├── Properties/            Launch settings
├── Program.cs             App entrypoint & DI configuration
├── appsettings.json       Base configuration
└── appsettings.Development.json  Local dev configuration
```

### Backend Layer Flow

```
HTTP Request → Controller → Service → Repository → Database (SQL Server)
```

**Conventions:**
- Controllers call Services only — never Repositories directly.
- Services contain business logic and call Repositories.
- Repositories use EF Core `DbContext` for data access.
- DTOs are defined per controller action (request/response separation).
- Models map 1:1 to database tables.

---

## Mobile Structure (`mobile/`)

Flutter app targeting Android and iOS.

```
mobile/
├── lib/                   Dart source code
│   ├── main.dart          App entrypoint
│   ├── core/              Core infrastructure (auth, http, routing, config)
│   ├── features/          Feature modules per domain
│   └── shared/            Shared widgets and utilities
├── assets/                Images, fonts, config files
├── android/               Android platform project
├── ios/                   iOS platform project
├── test/                  Unit and widget tests
└── pubspec.yaml           Dart dependencies
```

### Mobile Feature Structure

```
features/<feature>/
├── data/                  Repository implementations, API clients, models
├── domain/                Entities, use cases, repository interfaces
└── presentation/          Screens (pages), widgets, state (BLoC/Provider/Riverpod)
```

Refer to `docs/FLUTTER_ARCHITECTURE_GUIDE.md` for full Flutter conventions.

---

## Admin Web Structure (`web/`)

React + Vite admin portal for Admin role only. Calls API at `http://localhost:5088`; dev server at `http://localhost:5173`.

```
web/
├── src/
│   ├── app/               Router, App shell
│   ├── core/              Auth, API client, config
│   ├── features/          Admin modules (departments, classes, users, …)
│   ├── layouts/           Admin layout & navigation
│   └── components/        Shared UI components
├── package.json
└── README.md              Local run instructions
```

Plan & scope: `docs/superpowers/plans/2026-07-17-admin-web-react.md`

---

## Documentation (`docs/`)

```
docs/
├── SRS.md                     Software Requirements Specification (Vietnamese)
├── API_DESIGN.md              API endpoint design and contracts
├── DATABASE_CHANGELOG.md      Database schema changelog
├── FLUTTER_ARCHITECTURE_GUIDE.md  Flutter architecture and conventions
└── PRM393.docx                Original project specification document
```

---

## Key Investigation Starting Points

| Task | Start here |
|------|-----------|
| Understand system requirements | `docs/SRS.md` |
| Understand API design | `docs/API_DESIGN.md` |
| Understand database schema | `docs/DATABASE_CHANGELOG.md` |
| Understand Flutter conventions | `docs/FLUTTER_ARCHITECTURE_GUIDE.md` |
| Find an API controller | `api/Controllers/` |
| Find a service | `api/Services/` |
| Find a repository | `api/Repositories/` |
| Find a database model | `api/Models/` |
| Find a DTO | `api/DTOs/` |
| Find a migration | `api/Migrations/` |
| Find a Flutter screen | `mobile/lib/features/<feature>/presentation/` |
| Find Flutter data layer | `mobile/lib/features/<feature>/data/` |
| Find Admin web feature | `web/src/features/<feature>/` |
| Run Admin web locally | `web/README.md` |
