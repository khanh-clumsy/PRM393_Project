# Deployment Runbook

Local development and build/deploy for PRM393 FSchool.

---

## Backend Deployment (ASP.NET Core)

### Local Development
```powershell
# Working dir: api/
dotnet run                          # Start on http://localhost:<port>
dotnet watch run                    # Hot reload
```

### Configuration
- Dev config: `api/appsettings.Development.json`
- Base config: `api/appsettings.json`
- Launch settings (ports): `api/Properties/launchSettings.json`

### Publish
```powershell
dotnet publish -c Release -o ./publish
```

---

## Mobile Deployment (Flutter)

### Android
```bash
# Working dir: mobile/
flutter build apk --release                     # APK for direct install
flutter build appbundle --release               # AAB for Play Store
```

### iOS (requires macOS)
```bash
flutter build ios --release
```

### Environment / Config

Flutter app base URL and environment config: check `mobile/lib/core/` or
any `.env`-equivalent files under `mobile/assets/`.

---

## Database

Before deploying backend to a new environment:
```powershell
# Apply all pending EF Core migrations
dotnet ef database update
```

Connection string must be set in `appsettings.json` or environment variable
`ConnectionStrings__DefaultConnection`.

---

## GitHub Actions CI

CI workflow configuration: `.github/workflows/`
Check existing workflows for build and test automation steps.
