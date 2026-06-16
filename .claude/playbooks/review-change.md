# Playbook: Review Change

Use when: reviewing a PR, validating an implementation before merge.

---

## Step 1 — Understand Intent

What is this change supposed to do?
- Read the PR description or task description.
- Locate the requirement: `docs/requirements/<system>/` or `docs/features/<system>/`.

## Step 2 — Check Architecture Compliance

**Backend:**
- Are layer boundaries respected? (domain ← application ← adapter)
- Are domain entities exposed directly via HTTP? (they should not be)
- Is business logic in adapters? (it should not be)
- Are new dependencies injected via interfaces? (not hardcoded)

**Frontend:**
- Is new code in the correct feature module?
- Are shared components placed in `components/` (not buried in a feature)?
- Is routing registered correctly?
- Is the manifest updated if needed?

## Step 3 — Check Against Requirements

- Does the implementation match the documented process flow?
- Does it handle the edge cases in the data dictionary?
- Does it respect the permissions model?

TRMS permissions: `docs/requirements/trms/PERMISSIONS_TRMS.md`
TRMS process flow: `docs/requirements/trms/PROCESS_FLOW_TRMS.md`

## Step 4 — Check for Duplication

- Is there an existing utility or component that does the same thing?
- Is documentation being duplicated instead of referenced?

## Step 5 — Check Conventions

- Backend: follows Go naming conventions, no unused imports, no naked returns
- Frontend: LitElement patterns, TypeScript strict, no direct DOM manipulation outside components
- No hardcoded URLs — use config/url profiles
- No secrets or environment-specific values committed

## Output

1. **Summary** — what the change does
2. **Architecture** — pass / issues found
3. **Requirements alignment** — pass / gaps
4. **Duplication** — none / items to consolidate
5. **Conventions** — pass / violations
6. **Verdict** — approve / request changes
