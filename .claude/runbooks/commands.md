# Commands

---

## Backend (working dir: `api/`)

### Development
```powershell
dotnet run                          # Start development server
dotnet watch run                    # Start with hot reload
```

### Build
```powershell
dotnet build                        # Build project
dotnet publish -c Release           # Publish release build
```

### Test
```powershell
dotnet test                         # Run all tests
dotnet test --verbosity normal      # Verbose output
```

### Database Migrations (EF Core)
```powershell
dotnet ef migrations add <Name>     # Create new migration
dotnet ef database update           # Apply pending migrations
dotnet ef migrations list           # List all migrations
dotnet ef migrations remove         # Remove last migration (if not applied)
dotnet ef database drop             # Drop database (destructive!)
```

### Packages
```powershell
dotnet restore                      # Restore NuGet packages
dotnet add package <Name>           # Add a NuGet package
```

---

## Mobile (working dir: `mobile/`)

### Development
```bash
flutter run                         # Run on connected device/emulator
flutter run -d android              # Run on Android
flutter run -d ios                  # Run on iOS
flutter run --debug                 # Debug mode (default)
flutter run --release               # Release mode
```

### Build
```bash
flutter build apk                   # Build Android APK
flutter build appbundle             # Build Android App Bundle
flutter build ios                   # Build iOS (requires macOS)
```

### Test
```bash
flutter test                        # Run all tests
flutter test test/<file>_test.dart  # Run specific test file
```

### Lint / Analyze
```bash
flutter analyze                     # Dart static analysis
dart fix --apply                    # Auto-fix lint issues
```

### Packages
```bash
flutter pub get                     # Install dependencies
flutter pub upgrade                 # Upgrade dependencies
flutter pub add <package>           # Add a package
```

### Code Generation
```bash
dart run build_runner build         # Run code generation (json_serializable, etc.)
dart run build_runner watch         # Watch mode for code generation
dart run build_runner build --delete-conflicting-outputs  # Clean build
```

---

## Admin Web (working dir: `web/`)

### Development
```bash
npm install                         # Install dependencies (first time)
npm run dev                         # Vite dev server → http://localhost:5173
```

Requires API running at `http://localhost:5088` (`cd api && dotnet run`).

### Build
```bash
npm run build                       # tsc + vite production build
npm run preview                     # Preview production build locally
```

### Lint
```bash
npm run lint                        # oxlint
```
