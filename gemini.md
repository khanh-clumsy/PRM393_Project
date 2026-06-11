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
* **Separation of Concerns:** Keep Views stateless and decouple UI logic from data fetching. Put all state variables, network triggers, and form submissions inside the respective controller class.
* **Component Styling:** Use Material 3 widgets with the FSchools theme. Use the main color `#FF6B00` (FSchool Orange) as primary seed color.

---

## 💬 4. Prompts to Bootstrap Subagents

Use the exact prompts below when spawning subagents for automated development tasks:

### Prompt for Scaffolding ASP.NET Core Controllers
> "Please scaffold the controller, service, and repository for `StudentSemesterSummaries`. Refer to `001_init.sql` for model properties, use DTOs for request payloads, and implement the validation logic for Homeroom Teachers. Ensure the files are placed in their correct layers under the `api/` folder and registered in `Program.cs`."

### Prompt for Scaffolding Flutter Screens
> "Build the 'Học bạ điện tử' view using Material 3. Fetch data from `/api/students/{studentId}/summaries/semester/{semesterId}` and `/api/students/{studentId}/summaries/yearly/{academicYearId}` using the Central Api Client. Organize the views to end in `_view.dart` or `_screen.dart` under the `mobile/lib/vn/edu/fpt/view/` directory."
