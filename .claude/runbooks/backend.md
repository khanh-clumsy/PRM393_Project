# Backend Runbook

ASP.NET Core 8 Web API. Clean Architecture (Controller → Service → Repository).

---

## Project Location

| Component | Path |
|-----------|------|
| API project root | `api/` |
| Entry point | `api/Program.cs` |
| Base config | `api/appsettings.json` |
| Dev config | `api/appsettings.Development.json` |
| Project file | `api/PRM393API.csproj` |

---

## Internal Layer Structure

```
api/
├── Controllers/           HTTP controllers — route mapping, request validation, call service
├── Services/              Business logic — orchestrate domain rules, call repositories
├── Repositories/          Data access — EF Core queries against DbContext
├── Models/                EF Core entity models (map to database tables)
├── DTOs/                  Request/response data transfer objects (per endpoint)
├── Common/                Shared middleware, helpers, extension methods
├── Migrations/            EF Core Code-First migrations (auto-generated)
└── sql/                   Raw SQL scripts and seed data
```

**Import rule:** Controllers → Services → Repositories. Never skip layers.

---

## Conventions

- Each controller action calls exactly one service method.
- Services contain business logic and call one or more repositories.
- Repositories use EF Core `DbContext` directly — no raw ADO.NET unless necessary.
- DTOs are defined in `DTOs/` — domain Models are never serialized to HTTP responses directly.
- Authentication: JWT Bearer Token. Middleware configured in `Program.cs`.
- Dependency injection wired in `Program.cs`.

---

## Starting a New Feature

1. Define EF Core entity in `Models/`
2. Create migration: `dotnet ef migrations add <Name>`
3. Define repository interface (if using interface pattern) and implement in `Repositories/`
4. Implement service in `Services/`
5. Define request/response DTOs in `DTOs/`
6. Implement controller in `Controllers/`
7. Register new services/repos in `Program.cs` DI container

---

## Database

- ORM: Entity Framework Core (Code-First)
- Database: SQL Server
- Migrations: `api/Migrations/`
- Apply migrations: `dotnet ef database update`
- Connection string: `api/appsettings.Development.json` → `ConnectionStrings.DefaultConnection`
