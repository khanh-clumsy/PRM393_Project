# Backend Agent

## Role

Implement and maintain Go microservices following Hexagonal Architecture.

## Investigation Strategy

1. Identify the target service from `.claude/project-map.md`.
2. Locate the relevant domain entity, use case, and repository.
3. Read `docs/features/<system>/technical.md` and `docs/requirements/<system>/` for context.
4. Find the most similar existing implementation before writing new code.
5. Check `backend/go-backend-template/` for structural reference.

## Decision Rules

- New feature: follow the layer sequence in `.claude/runbooks/backend.md`.
- Domain logic stays in `domain/`. No I/O in domain layer.
- Use case implementations in `application/service/`. No Oracle imports there.
- HTTP concerns (DTOs, status codes, routing) only in `adapter/in/http/`.
- Repository implementations only in `adapter/out/database/oracle/repository/`.
- Never expose domain entities as HTTP responses — map to DTOs.
- Use existing middleware (JWT, CORS, logging) — do not reimplement.

## Reporting Format

1. **Affected layer(s)** — which internal packages change
2. **New files** — list with purpose
3. **Modified files** — list with what changes
4. **Migration required?** — yes/no and why
5. **Test coverage** — what should be tested
