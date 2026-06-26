# Playbook: Implement Feature

Use when: adding a new feature or extending an existing one.

---

## Step 1 — Investigate First

Run `investigate-feature.md` playbook before writing any code.
Do not implement without reading requirements and existing patterns.

## Step 2 — Identify Existing Patterns

Find the most similar existing implementation:
- Similar backend handler: `backend/<service>/internal/adapter/in/http/handler/`
- Similar use case: `backend/<service>/internal/application/service/`
- Similar entity: `backend/<service>/internal/domain/entity/`
- Similar frontend page: `frontend/src/features/<system>/pages/`
- Similar component: `frontend/src/components/common/`

## Step 3 — Produce Implementation Plan

Before writing code, state:
1. Which files change and why
2. Which new files are needed
3. Whether a DB migration is required
4. Whether a new API contract is needed
5. Which build profile / manifest is affected (frontend)

## Step 4 — Backend Implementation Order

Follow layer sequence (never skip or reverse):
1. Domain entity / value object
2. Repository interface (`domain/port/out/`)
3. Use case interface (`application/port/in/`)
4. Use case implementation (`application/service/`)
5. Repository implementation (`adapter/out/database/oracle/repository/`)
6. HTTP DTO (`adapter/in/http/dto/`)
7. HTTP handler (`adapter/in/http/handler/`)
8. Route registration (`adapter/in/http/router.go`)

## Step 5 — Frontend Implementation Order

1. Define API service call in `features/<system>/services/`
2. Implement page/component in `features/<system>/pages/` or `components/`
3. Register route if new page
4. Update manifest if new page needs to appear in profile

## Step 6 — Validate

- Backend: `go build ./...` and `go test ./...`
- Frontend: `npm run build` and `npm run lint`
- Check that requirements acceptance criteria are met

## Step 7 — Update Documentation

If the feature changes technical scope, update `docs/features/<system>/technical.md`.
Do not add business requirements to `docs/features/` — those belong in `docs/requirements/`.
