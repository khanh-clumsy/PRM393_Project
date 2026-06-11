# PRM393 Project

Monorepo with a Flutter mobile app (`mobile/`) and a .NET 8 Web API (`api/`).

---

## Prerequisites

| Tool | Version |
|------|---------|
| Flutter | ≥ 3.x |
| Dart | ≥ 3.x |
| .NET SDK | 8.0 |
| SQL Server LocalDB | bundled with VS 2022 |

---

## Mobile (Flutter)

```bash
cd mobile
flutter pub get
flutter run
```

### Structure

```
mobile/lib/
├── main.dart                    # App entry + GoRouter setup
└── vn/edu/fpt/
    ├── controller/              # Business logic controllers
    ├── model/                   # Data models
    └── view/                    # UI screens / widgets
```

### Key packages

| Package | Purpose |
|---------|---------|
| `dio` | HTTP client |
| `go_router` | Declarative routing |

---

## API (.NET 8)

```bash
cd api

# Apply EF migrations (first run)
dotnet ef migrations add InitialCreate
dotnet ef database update

# Run
dotnet run
```

Swagger UI is available at `https://localhost:<port>/swagger` when running in Development.

### Structure

```
api/
├── Controllers/        # HTTP layer — UserController
├── Services/
│   ├── Interfaces/     # IUserService
│   └── UserService.cs  # Business logic
├── Repositories/
│   ├── Interfaces/     # IUserRepository
│   └── UserRepository.cs
├── Models/             # EF entities (User)
├── DTOs/               # Request / response shapes
├── Common/             # AppDbContext, JwtHelper
└── Program.cs          # DI wiring, middleware
```

### Authentication

JWT Bearer. Obtain a token via `POST /api/user/login`, then include it as:

```
Authorization: Bearer <token>
```

### Configuration

Edit `appsettings.Development.json` to set:
- `ConnectionStrings:DefaultConnection` — SQL Server LocalDB connection string
- `Jwt:Key` — signing secret (≥ 32 characters, change before deploying)
- `Jwt:Issuer` / `Jwt:Audience`

---

## Build verification

```bash
# From repo root
cd api && dotnet build
cd ../mobile && flutter pub get
```
