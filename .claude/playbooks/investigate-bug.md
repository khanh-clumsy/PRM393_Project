# Playbook: Investigate Bug

Use when: a feature is not behaving as expected.

---

## Step 1 — Identify the System and Layer

Which system? Which layer is failing (frontend UI, API call, backend handler, use case, repository, database)?

## Step 2 — Read Requirements

What is the expected behavior according to requirements?
- `docs/requirements/<system>/` — process flow, BRD, SRS
- `docs/features/<system>/technical.md` — technical scope

Confirm: is this actually a bug, or undefined/undocumented behavior?

## Step 3 — Locate the Code Path

Trace from the surface symptom inward:

**Frontend bug:**
- Page: `frontend/src/features/<system>/pages/`
- Component: `frontend/src/features/<system>/components/`
- API call: `frontend/src/features/<system>/services/`
- HTTP client: `frontend/src/core/http/`

**Backend bug:**
- Handler: `backend/<service>/internal/adapter/in/http/handler/`
- Use case: `backend/<service>/internal/application/service/`
- Domain logic: `backend/<service>/internal/domain/`
- Repository / SQL: `backend/<service>/internal/adapter/out/database/oracle/repository/`

## Step 4 — Identify Root Cause

- Is the logic wrong in the domain layer?
- Is the SQL query wrong in the repository?
- Is the DTO mapping losing data?
- Is the frontend mishandling the API response?

State the root cause precisely before proposing a fix.

## Step 5 — Propose Fix

- Minimal diff — fix only what is broken.
- Do not refactor surrounding code unless it is causing the bug.
- If the bug is caused by missing requirements clarity, flag it before patching.

## Output

1. **Symptom** — observed behavior
2. **Expected behavior** — requirements reference
3. **Root cause** — exact location and reason
4. **Fix** — minimal change description
5. **Risk** — what else could be affected
