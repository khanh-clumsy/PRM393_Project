# Rules

Operative rules for all Claude Code agents in this repository.

---

## Core

1. **docs/ is the single source of truth.** Never duplicate business requirements, architecture decisions, or domain knowledge. Reference docs/ instead.

2. **Investigate before implementing.** Read existing code and relevant docs before writing anything. Use `.claude/context-map.md` to find documentation.

3. **Reuse existing patterns.** Find a similar implementation in the codebase before introducing new structure. Check `backend/go-backend-template/` for service patterns.

4. **Prefer minimal and incremental changes.** Smallest correct diff. No speculative features. No premature abstractions.

5. **No duplicate modules.** Before creating a new file, verify it does not already exist.

6. **No duplicate documentation.** Do not write content into `.claude/` that belongs in `docs/`.

---

## Investigation Protocol

Before any implementation:

1. Consult `.claude/context-map.md` to locate relevant docs.
2. Read relevant docs in `docs/features/<system>/` and `docs/requirements/<system>/`.
3. Locate existing code in `frontend/src/features/<system>/` and `backend/<service>/`.
4. Identify existing patterns (handlers, DTOs, services, entities).
5. Produce findings before recommendations.
6. Produce recommendations before modifying code.

---

## Documentation Rules

- Active technical docs → `docs/features/<system>/`
- Active requirements / customer files → `docs/requirements/<system>/`
- Deprecated / backup files → `archive/quarantine/`
- Do not write to `documents/` (legacy, inactive)
- Do not write to `frontend/docs/trms/` (inactive)

---

## Architecture Rules

- Frontend: LitElement + TypeScript. No new frameworks without explicit approval, only use existing components, ask if new component needed.
- Backend: Go, Hexagonal/Clean Architecture. Follow layer boundaries.
- Database: Oracle. Schema changes require migration scripts.
- Gateway: Kong. Config lives in `deploy/tenants/<tenant>/<env>/`.
- Do not introduce new external dependencies without discussion.

---

## Layer Discipline (Backend)

```
domain/         ← no imports from outer layers
application/    ← imports domain only
adapter/        ← imports application and domain; never domain's internal details
```

Domain entities and port interfaces define contracts.
Adapters implement ports; they do not define business logic.

---

## Reporting Format

Findings first. Then recommendations. Then code changes.
State assumptions explicitly if requirements are ambiguous.
