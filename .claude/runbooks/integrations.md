# Integrations Runbook

External systems and third-party integrations for PRM393 FSchool.

---

## Authentication

- JWT Bearer Token issued by the ASP.NET Core API (`api/`)
- Refresh Token stored securely on mobile (Flutter Secure Storage or similar)
- All API endpoints (except auth) require `Authorization: Bearer <token>` header
- JWT middleware configured in `api/Program.cs`

---

## File Storage / Avatars

- Avatar URL stored as string in `Users` table (`AvatarUrl` field)
- File upload endpoints: check `docs/API_DESIGN.md` for file-related endpoints
- Static files may be served from `api/wwwroot/`

---

## Push Notifications

Not yet identified as integrated. Check `docs/API_DESIGN.md` and `mobile/pubspec.yaml`
for any Firebase / APNs or similar push notification setup.

---

## Email / SMS

Password recovery via Email/Phone mentioned in SRS §3.1.
Check `api/Services/` for any email service implementation.

---

## Mobile ↔ API Communication

- Flutter app communicates with ASP.NET Core API via HTTP/HTTPS
- Base URL configured in Flutter app — check `mobile/lib/core/` for API client setup
- API contract documented in `docs/API_DESIGN.md`
