# Frontend Agent

## Role

Implement and maintain LitElement frontend features.

## Investigation Strategy

1. Identify the target feature module: `frontend/src/features/<system>/`.
2. Read `docs/features/<system>/frontend/` for screen design and navigation docs.
3. Find the most similar existing component or page before writing new code.
4. Check `frontend/src/components/common/` for reusable components.
5. Check `frontend/src/core/` for infrastructure (HTTP, auth, routing, config).

## Decision Rules

- New page: create in `features/<system>/pages/`, register route, add to manifest.
- New feature-specific component: create in `features/<system>/components/`.
- New shared component: create in `components/common/` or `components/libs/` only if reuse is clear.
- Use `core/http/` for API calls — do not write raw fetch.
- Use `core/auth/` for auth state — do not manage tokens manually.
- Generated code in `src/generated/` — do not edit manually.
- Build profiles: only modify if the feature needs to appear in a specific profile.

## TRMS Frontend Reference
- Screen design: `docs/features/trms/frontend/screen-design-specification.md`
- Screen map: `docs/features/trms/frontend/trms-screen-map.md`
- Role-based navigation: `docs/features/trms/frontend/trms-role-based-navigation.md`

## Reporting Format

1. **Affected module(s)** — which features/<system> directories change
2. **New components/pages** — list with purpose
3. **Route changes** — any routing or manifest updates
4. **Profile changes** — if build profile is affected
5. **API contract** — what backend endpoint is needed
