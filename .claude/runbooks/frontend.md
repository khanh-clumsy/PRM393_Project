# Frontend Runbook (Flutter Mobile)

Flutter app targeting Android and iOS. Dart language.

---

## Key Locations

| Purpose | Path |
|---------|------|
| App entry point | `mobile/lib/main.dart` |
| Core infrastructure | `mobile/lib/core/` |
| Feature modules | `mobile/lib/features/` |
| Shared widgets | `mobile/lib/shared/` |
| Assets (images, fonts) | `mobile/assets/` |
| Dependencies | `mobile/pubspec.yaml` |
| Unit/widget tests | `mobile/test/` |

---

## Feature Module Structure

Each domain feature lives under `mobile/lib/features/<feature>/`:

```
features/<feature>/
├── data/
│   ├── models/            JSON-serializable models (API response mapping)
│   ├── repositories/      Concrete repository implementations
│   └── datasources/       API clients / local storage
├── domain/
│   ├── entities/          Pure domain entities
│   ├── repositories/      Abstract repository interfaces
│   └── usecases/          Use case classes (optional, depends on complexity)
└── presentation/
    ├── screens/           Full-page screen widgets
    ├── widgets/           Feature-specific reusable widgets
    └── bloc/ (or provider/ or notifier/)  State management
```

Refer to `docs/FLUTTER_ARCHITECTURE_GUIDE.md` for full conventions.

---

## Architecture Conventions

- State management: check `docs/FLUTTER_ARCHITECTURE_GUIDE.md` for the chosen approach (BLoC, Riverpod, or Provider).
- HTTP: use the shared API client in `mobile/lib/core/` — do not create ad-hoc `http` calls in screens.
- Auth tokens: managed in core layer, injected into API client automatically.
- Navigation: check `mobile/lib/core/` for router setup (GoRouter or Navigator 2.0).
- No business logic in widgets — delegate to state management layer.

---

## Adding a New Screen

1. Create screen widget under `features/<feature>/presentation/screens/`
2. Register route in the router configuration (`mobile/lib/core/router/` or similar)
3. Create state management class under `presentation/bloc/` (or provider/notifier)
4. Implement data layer: model → datasource → repository
5. Wire dependency injection (check how existing features register their dependencies)
