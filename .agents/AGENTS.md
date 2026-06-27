# AGENT.md — AI Agent Development Context & Rules

This document outlines the system architecture context, critical business logic rules, role constraints, and development guidelines for agentic codegen on the FSchool project.

---

## 💡 1. System Overview & Context

FSchool is an educational management portal designed to digitize academic communications between the school, teachers, students, and parents.
* **Backend:** ASP.NET Core 8 Web API.
* **Frontend:** Flutter Mobile Application.
* **Database:** SQL Server (using EF Core on the API side). The source of truth for the database schema is [001_init.sql](file:///c:/Code/PRM393_Project/api/sql/001_init.sql).

---

## 🔐 2. Strict Role-Based Access Control (RBAC) Rules

All API endpoints and business logic must enforce strict authorization checks based on user roles (`Roles` table):

### Quản trị viên (Admin - RoleId = 1)
* **Write/Modify Scope:** Full CRUD operations across all system configurations.
* **Academic setup:** Admin is the *only* role permitted to create classes, assign teachers to subjects/classes (`TeachingAssignments`), define semesters/academic years, and set up grading scales (`AcademicRanks`).
* **Announcements:** Admin manages global, school-wide news feed articles.

### Trưởng bộ môn (HeadOfDept - RoleId = 2)
* **Write/Modify Scope:** Full CRUD operations on Classes, TeachingAssignments, and Timetables for their department.
* **Quyền hạn:** Có thể xem danh sách giáo viên, thời khóa biểu, phân công giảng dạy, và báo cáo điểm số của các môn học thuộc tổ chuyên môn của mình. Trưởng bộ môn được quyền tạo lớp học, phân công giảng dạy và xếp thời khóa biểu.
* **Kiêm nhiệm:** Nếu Trưởng bộ môn trực tiếp giảng dạy lớp nào đó, họ có các quyền của Giáo viên đối với lớp đó.

### Giáo viên (Teacher - RoleId = 3)
* **Nghiệp vụ cơ bản:** Lấy thời khóa biểu dạy học, thực hiện điểm danh (`AttendanceRecords`), nhập điểm môn học (`Grades`), giao và chấm bài tập (`Assignments`, `Submissions`), duyệt đơn xin nghỉ học của học sinh.
* **Giáo viên chủ nhiệm (GVCN):** Có độc quyền đối với lớp chủ nhiệm (được liên kết qua `Classes.HomeroomTeacherId`):
  * Đọc bảng tổng hợp điểm số lớp học.
  - Đánh giá xếp loại Hạnh kiểm học kỳ/cả năm.
  - Chốt điểm tổng kết GPA học kỳ/cả năm và ánh xạ xếp loại học lực (`AcademicRanks`) lưu trực tiếp xuống `StudentSemesterSummaries` và `StudentYearlySummaries`.

### Học sinh (Student - RoleId = 4) & Phụ huynh (Parent - RoleId = 5)
* **Read Scope:** Tra cứu thời khóa biểu, điểm số thành phần, điểm danh chuyên cần, thông báo bảng tin, và học bạ điện tử (semester/yearly summaries).
* **Write Scope:** Học sinh nộp bài tập (`Submissions`). Học sinh hoặc Phụ huynh có thể tạo đơn xin nghỉ học (`StudentRequests`).

---

## ⚠️ 3. Database Schema Design Constants

Agents must adhere strictly to these physical database rules defined in [001_init.sql](file:///c:/Code/PRM393_Project/api/sql/001_init.sql):

### 3.1. Lịch sử lớp học (StudentClasses)
* Bảng `Users` không lưu trực tiếp `ClassId` của học sinh.
* Mối quan hệ học sinh - lớp học được lưu trong bảng trung gian `StudentClasses (StudentClassId, StudentId, ClassId)`. Do `ClassId` đã gắn liền với `AcademicYearId`, cấu trúc này cho phép tra cứu chính xác học sinh đã học lớp nào trong bất kỳ năm học nào mà không lo bị ghi đè thông tin khi lên lớp mới.

### 3.2. Cột lọc bộ môn (DepartmentId)
* Cột `Users.DepartmentId` (chỉ áp dụng cho Giáo viên) đóng vai trò làm tag/filter phục vụ tìm kiếm trên UI hoặc kết xuất báo cáo tổ chuyên môn.
* Hệ thống **không ràng buộc cứng** (no hard foreign constraint validation blocking teaching assignments) để giữ cho nghiệp vụ phân công dạy học chéo bộ môn ở Backend được đơn giản.

### 3.3. Tránh tính toán on-the-fly (Summaries Tables)
* Các bảng `StudentSemesterSummaries` và `StudentYearlySummaries` lưu trữ cứng kết quả GPA, Hạnh kiểm và Xếp loại (`RankId`).
* Dữ liệu này được chốt sổ bởi Giáo viên chủ nhiệm. Khi hiển thị Học bạ điện tử, API lấy trực tiếp từ các bảng summaries này thay vì tính toán động từ bảng `Grades` nhằm tối ưu hóa hiệu năng hệ thống.

### 3.4. Token Indexes & Unique Constraints
* Bảng `RefreshTokens` bắt buộc phải được đánh `INDEX` trên hai cột `Token` và `UserId`. Khi truy vấn hoặc thu hồi token, luôn lọc theo các trường đã đánh index.
* Bảng `Semesters` áp dụng ràng buộc `UNIQUE (AcademicYearId, SemesterName)` để loại bỏ dữ liệu rác (tránh trùng lặp học kỳ trong cùng năm học).

---

## 🚫 4. Out of Scope Features
* **Chat module** (1-1 chat, group chat) đã được loại bỏ hoàn toàn. Tuyệt đối không sinh code, không thiết lập WebSocket hay tạo các bảng/endpoint liên quan đến nhắn tin.

---
---

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

---
---

# GEMINI.md — Gemini & AI Developer Instruction Checklist

Use this checklist and prompt reference when invoking Gemini models or agent subagents for assistance on the FSchool workspace.

---

## 🤖 1. Model Profiles

* **Gemini 3.5 Flash (Medium):** Recommended for high-speed tasks, such as creating scaffolds, refactoring isolated files, executing file searches, writing boilerplate controllers, and minor UI updates.
* **Gemini 3.1 Pro (Low):** Recommended for complex debugging, architecture reviews, designing database synchronizations, and analyzing multi-file integrations.

---

## 📋 2. Pre-flight Coding Checklist

Before committing files or generating endpoints, you must verify against the following project rules:

### 1. Database Schema Sync
* Ensure all EF Core models in [Models/](file:///c:/Code/PRM393_Project/api/Models/) strictly match [001_init.sql](file:///c:/Code/PRM393_Project/api/sql/001_init.sql).
* Any database changes must be proposed first and recorded in [DATABASE_CHANGELOG.md](file:///c:/Code/PRM393_Project/docs/DATABASE_CHANGELOG.md) before executing migrations.

### 2. Authentication Flow
* Ensure all endpoints (except `/api/auth/login`, `/api/auth/forgot-password`, `/api/auth/refresh`) require JWT Bearer authorization (using the `[Authorize]` attribute on the C# controller or class level).

### 3. Flutter Naming Conventions
* Files in `mobile/lib/vn/edu/fpt/` directories must conform to standard Flutter clean patterns:
  * Controller files in `controllers/` directory: Must end in `_controller.dart`.
  * Model files in `models/` directory: Must end in `_model.dart`.
  * View files in `view/` directory: Must end in `_view.dart` or `_screen.dart`.

### 4. Documentation Compliance
* Check [SRS.md](file:///c:/Code/PRM393_Project/docs/SRS.md) and [API_DESIGN.md](file:///c:/Code/PRM393_Project/docs/API_DESIGN.md) before implementing any endpoint or UI screen. Ensure the behavior exactly aligns with the written specification.

---

## 🏗️ 3. Deep Architectural Guidance

### Backend Development Patterns (.NET 8 API)
* **Routing Scheme:** All controllers must use prefix routing: `[Route("api/[controller]")]`. Use lowercase plural names where possible (e.g. `api/students`, `api/admin/users`).
* **Input Scrutiny (DTOs):** Never accept DB Entity models directly as controller arguments. Implement lightweight Request DTOs and validate parameters using Data Annotations (e.g. `[Required]`, `[MaxLength]`, `[Range]`).
* **Response Separation:** Map DB entities to Response DTOs before return. This prevents circular serialization reference errors (e.g. User references Role references User).
* **Exception handling:** Do not write try-catch blocks in controllers for standard errors. Rely on global middleware exception handling or services returning operational results (e.g., `Result<T>` pattern).

### Frontend Development Patterns (Flutter Mobile)
* **Dio Client Usage:** Always import and use the centralized API client utilizing the `Dio` package. Do not instantiate direct `http` client requests.
* **Separation of Concerns (MVC/GetX):** 
  - **VIEWS MUST BE STATELESS:** Never write API calls, state management, or business logic directly inside View files (`*_view.dart` or `*_screen.dart`). Always use `StatelessWidget` or GetX's `GetView`.
  - **CONTROLLERS FOR LOGIC:** Put all state variables, network triggers (API requests), form submissions, and data parsing strictly inside Controller classes (`*_controller.dart`).
* **Component Styling:** Use Material 3 widgets with the FSchools theme. Use the main color `#FF6B00` (FSchool Orange) as primary seed color.

---

## 💬 4. Prompts to Bootstrap Subagents

Use the exact prompts below when spawning subagents for automated development tasks:

### Prompt for Scaffolding ASP.NET Core Controllers
> "Please scaffold the controller, service, and repository for `StudentSemesterSummaries`. Refer to `001_init.sql` for model properties, use DTOs for request payloads, and implement the validation logic for Homeroom Teachers. Ensure the files are placed in their correct layers under the `api/` folder and registered in `Program.cs`."

### Prompt for Scaffolding Flutter Screens
> "Build the 'Học bạ điện tử' view using Material 3. Fetch data from `/api/students/{studentId}/summaries/semester/{semesterId}` and `/api/students/{studentId}/summaries/yearly/{academicYearId}` using the Central Api Client. Organize the views to end in `_view.dart` or `_screen.dart` under the `mobile/lib/vn/edu/fpt/view/` directory."

---

## 🔍 5. Data Parsing & JSON Contracts

* **Frontend/Backend Synchronization:** Whenever writing Flutter code that extracts data from an API response, you MUST cross-reference the exact property names and data types emitted by the corresponding Backend DTO (`.cs` file). 
* Do not make assumptions about JSON structures. Always compare the backend's response payload (BE) with the frontend's mapping code (FE) to ensure perfect matching
