# CLAUDE.md — FSchool Development Architecture & Code Guidelines

This document provides a deep, comprehensive guide to the FSchool monorepo. It details project commands, architecture layout, coding style conventions, database synchronization constraints, and security standards.

---

## 🛠️ 1. Build & Execution Commands

### Backend (.NET 8 Web API)
All backend commands must be run from the `api/` directory:
* **Restore dependencies:** `dotnet restore`
* **Build project:** `dotnet build`
* **Run in Development:** `dotnet run` (runs on `https://localhost:<port>`)
* **Watch mode (auto-reload):** `dotnet watch run`
* **Entity Framework Core Migrations:**
  * Generate a migration: `dotnet ef migrations add <MigrationName> --project PRM393API.csproj --startup-project PRM393API.csproj`
  * Apply migrations to database: `dotnet ef database update`
  * Remove last migration: `dotnet ef migrations remove`
  * Drop Database: `dotnet ef database drop`

### Frontend (Flutter Mobile App)
All mobile commands must be run from the `mobile/` directory:
* **Restore dependencies:** `flutter pub get`
* **Run application:** `flutter run` (ensure an emulator or physical device is active)
* **Check layout & issues:** `flutter analyze`
* **Run tests:** `flutter test`
* **Build release APK:** `flutter build apk --release`
* **Clean cache:** `flutter clean`

---

## 🏗️ 2. Comprehensive Directory Structure

The project is structured as a monorepo containing the .NET 8 Web API (`api/`) and the Flutter mobile client (`mobile/`).

### Backend Architecture Layout (`api/`)
The backend strictly adheres to a **Controller-Service-Repository** layered architecture.

```
api/
├── Controllers/         # HTTP Layer: Exposes REST API endpoints. Validates input DTOs.
├── Services/            # Business Logic Layer
│   ├── Interfaces/      # Service Interfaces (e.g., IUserService.cs)
│   └── UserService.cs   # Implementations: handles authorization checks, logic, and data flow.
├── Repositories/        # Data Access Layer
│   ├── Interfaces/      # Repository Interfaces (e.g., IUserRepository.cs)
│   └── UserRepository.cs# Implementations: performs direct DB queries using Entity Framework Core.
├── Models/              # Database Entity Layer: Entities mapping 1-1 with 001_init.sql.
├── DTOs/                # Data Transfer Objects: Separates API payload structures from DB models.
├── Common/              # Infrastructure: AppDbContext.cs, JWT helpers, middlewares.
└── Program.cs           # Bootstrapper: Registers DI, auth schemes, DbContext, and middlewares.
```

### Frontend Architecture Layout (`mobile/`)
The frontend is built using standard Flutter MVC/clean architectural components located under `mobile/lib/vn/edu/fpt/`.

```
mobile/lib/
├── main.dart            # Flutter entry point. Sets up the MaterialApp, Theme, and root routing.
└── vn/edu/fpt/
    ├── controllers/     # Controller files (State Management, API integrations using Dio).
    │                    # MUST name files as: *_controller.dart
    ├── models/          # Model files (JSON serialization/deserialization classes).
    │                    # MUST name files as: *_model.dart
    └── view/            # Screen UI files, subviews, and reusable widgets.
                         # MUST name files as: *_view.dart or *_screen.dart
```

---

## 🎯 3. Architectural Design Flow

Any request to the API undergoes the following flow:

```
[Client App] ──(Request DTO)──> [Controller] ──(DTo / Primitives)──> [Service]
                                                                        │
                                                                        ▼ (Business Logic)
[Client App] <──(Response DTO)─ [Controller] <──(Domain Entity/Data)── [Repository]
                                                                        │
                                                                        ▼ (Queries EF Core)
                                                                  [SQL Database]
```

1. **HTTP Routing & Input Validation:** Controllers intercept requests, validate authentication headers, and perform initial request body validations using C# `DataAnnotations` in DTOs.
2. **Business & Security Logic:** Services process business logic (e.g. GPA calculations, Rank mapping, date checks) and perform permission verification based on the user role.
3. **Data Access Isolation:** Repositories invoke `AppDbContext` to query or persist data to the SQL Server database. No business or HTTP logic should leak into this layer.

---

## 🎨 4. Coding Conventions & Best Practices

### C# / .NET Coding Conventions
* **Language Standard:** C# 12 features on .NET 8.
* **Naming Standards:**
  * **PascalCase:** Classes, Structs, Enums, Interfaces, Public Properties, and Methods (e.g., `UserRepository`, `GetActiveUsers()`).
  * **camelCase:** Method arguments and local variables (e.g., `studentId`, `tempScore`).
  * **_camelCase:** Private and protected fields (e.g., `_dbContext`, `_jwtHelper`).
  * **I-Prefix:** Interfaces must start with `I` (e.g., `IUserRepository`).
* **Asynchronous Execution:** Every repository query, file access, or network transaction must use `async` / `await` and return a `Task` or `Task<T>`.
* **Dependency Injection:** Inject repositories into services, and services into controllers using Constructor Injection. Never instantiate dependencies using `new` manually.
* **Database Alignment:** Every C# model in [Models/](file:///c:/Code/PRM393_Project/api/Models/) must strictly map to tables and data types declared in [001_init.sql](file:///c:/Code/PRM393_Project/api/sql/001_init.sql). Any change must be logged in [DATABASE_CHANGELOG.md](file:///c:/Code/PRM393_Project/docs/DATABASE_CHANGELOG.md).

### Dart / Flutter Coding Conventions
* **Naming Standards:**
  * **PascalCase:** Class names, Widget names, and Type definitions (e.g., `AcademicSummaryView`).
  * **camelCase:** Function names, method names, variable names, and class members (e.g., `fetchGrades()`, `isLoading`).
  * **lower_snake_case:** File names (e.g., `academic_summary_view.dart`, `student_model.dart`).
* **File Naming Rules:**
  * Controller files under `controllers/` must end in `_controller.dart`.
  * Model files under `models/` must end in `_model.dart`.
  * View/Screen files under `view/` must end in `_view.dart` or `_screen.dart`.
* **Network & Deserialization:**
  * Use a centralized HTTP client utilizing `Dio` for backend communication.
  * Embed standard interceptors to attach `Authorization: Bearer <Token>` dynamically to outgoing requests.
  * Models must implement a `fromJson()` factory constructor and a `toJson()` map converter.

---

## 🔒 5. Security & Authentication Rules

* **JWT Bearer Authentication:** Every backend API route is secured by default. The `[Authorize]` attribute (or global authorization filters) must be applied to all controllers.
* **Whitelisted Public Endpoints:** Only these three endpoints are allowed to bypass authentication:
  1. `POST /api/auth/login` - User sign-in.
  2. `POST /api/auth/forgot-password` - Trigger password reset.
  3. `POST /api/auth/refresh` - Refresh expired access tokens.
* **Password Hashing:** Passwords must be hashed using a secure cryptographic algorithm (e.g. BCrypt) combined with a unique salt prior to database write. Plain text passwords are strictly forbidden.
* **Token Expiration:** Access tokens must have a short lifespan (e.g., 15 minutes), and refresh tokens must be securely stored in the database with `ExpiresAt` and `IsRevoked` flags.
