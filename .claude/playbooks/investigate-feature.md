# Playbook: Investigate Feature

Use when: understanding how a feature works, scoping a change, onboarding to a system.

---

## Step 1 — Identify the System

Determine which system the feature belongs to: PMS, TRMS, MEMS, CCTVAI, Admin, ASMS, DOMS, Workflow.
Use `.claude/context-map.md` to locate documentation.

## Step 2 — Read Requirements

- Business requirements: `docs/requirements/<system>/BRD_*.md` or `brd.md`
- Process flow: `docs/requirements/<system>/PROCESS_FLOW_*.md`
- Data dictionary: `docs/requirements/<system>/DATA_DICTIONARY_*.md`
- Permissions: `docs/requirements/<system>/PERMISSIONS_*.md`

## Step 3 — Read Technical Documentation

- Technical state: `docs/features/<system>/technical.md`
- Architecture: `docs/features/<system>/architecture/`
- Database design: `docs/features/<system>/database/`
- Frontend design: `docs/features/<system>/frontend/`

## Step 4 — Locate Frontend Code

- Module: `frontend/src/features/<system>/`
- Pages: `frontend/src/features/<system>/pages/`
- Services (API clients): `frontend/src/features/<system>/services/`
- Manifest: `frontend/src/configs/manifests/<profile>.json`

## Step 5 — Locate Backend Code

- Service: `backend/<service>/`
- Handlers: `backend/<service>/internal/adapter/in/http/handler/`
- Use cases: `backend/<service>/internal/application/service/`
- Domain entities: `backend/<service>/internal/domain/entity/`
- Repositories: `backend/<service>/internal/adapter/out/database/oracle/repository/`

## Step 6 — Identify Gaps

- What is documented but not implemented?
- What is implemented but not documented?
- What is ambiguous?

## Output

Produce a findings summary:
1. What the feature is supposed to do (requirements reference)
2. What exists in code
3. Gaps and open questions
