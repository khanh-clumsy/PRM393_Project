# CLAUDE.md

## Project Principles

This repository uses documentation-first development.

The `docs/` directory is the single source of truth for:

- Business requirements
- Domain knowledge
- System architecture
- Database design
- API specifications

Do not duplicate domain knowledge into `.claude/`.

---

## Working Rules

Before implementing any feature:

1. Investigate existing implementation.
2. Read relevant documentation from `docs/`.
3. Reuse existing project patterns whenever possible.
4. Prefer minimal and incremental changes.
5. Produce an implementation plan before large modifications.
6. Explain assumptions if requirements are unclear.

---

## Repository Navigation

Main areas:

- `mobile/` : Flutter mobile app (Android/iOS)
- `api/` : ASP.NET Core 8 Web API (C#)
- `docs/` : Source of truth documentation
- `.claude/` : Claude orchestration layer — navigation, agents, playbooks, runbooks

See `.claude/project-map.md` for system boundaries and code entrypoints.

---

## Context Discovery

Always consult in this order:

1. `.claude/context-map.md` — topic → documentation routing table
2. `.claude/project-map.md` — system boundaries and service locations
3. Relevant files under `docs/`
4. Existing implementation

Investigation is preferred over assumptions.

---

## .claude/ Structure

```
.claude/
├── context-map.md       Topic → docs routing table
├── project-map.md       Repo structure, system boundaries, code entrypoints
├── rules.md             Operative rules for all agents
├── skills/              Agent Skills workflows
├── runbooks/
│   ├── commands.md      Build, test, lint, migration commands
│   ├── frontend.md      Flutter mobile app conventions
│   ├── backend.md       ASP.NET Core API conventions
│   ├── database.md      Schema ownership and migration conventions
│   ├── deployment.md    Deployment locations and config
│   └── integrations.md  External integrations
├── agents/
│   ├── product-agent.md
│   ├── architect-agent.md
│   ├── backend-agent.md
│   ├── frontend-agent.md
│   └── qa-agent.md
└── playbooks/
    ├── investigate-feature.md
    ├── implement-feature.md
    ├── investigate-bug.md
    └── review-change.md
```

---

## Architecture Principles

- Mobile: Flutter (Dart) — Android/iOS
- Backend: ASP.NET Core 8 Web API (C#)
- Database: SQL Server (EF Core Code-First Migrations)
- Authentication: JWT Bearer Token + Refresh Token
- Architecture: Clean Architecture (Controllers → Services → Repositories)

Do not introduce new frameworks unless explicitly requested.

---

## Modification Policy

Before modifying code:

- Identify existing patterns.
- Locate similar implementations.
- Explain planned changes.
- Avoid duplicate modules and duplicate abstractions.

For architecture questions:

- Produce findings first.
- Produce recommendations second.
- Modify code last.

---

## Skill Usage

Agent Skills are available under:

.claude/skills/

When a matching skill exists, follow the skill workflow before implementation unless explicitly instructed otherwise.

Preferred mapping:

- New feature → spec-driven-development → planning-and-task-breakdown → incremental-implementation
- Bug / incident → debugging-and-error-recovery
- API design → api-and-interface-design
- Mobile/Flutter work → frontend-ui-engineering
- Testing → test-driven-development
- Code review → code-review-and-quality
- Refactoring → code-simplification
- Security review → security-and-hardening
- Performance investigation → performance-optimization
- Documentation / ADR → documentation-and-adrs
- Deployment / release → shipping-and-launch

If multiple skills apply, combine them in the natural development lifecycle:

SPEC → PLAN → BUILD → TEST → REVIEW → SHIP

Do not skip required investigation and planning steps for non-trivial changes.

When unsure which workflow applies, consult:

.claude/skills/using-agent-skills/SKILL.md

## Database Work

For database-related tasks:

1. Read `.claude/runbooks/database.md`
2. Read relevant database documentation under `docs/`
3. Follow existing EF Core migration patterns in `api/Migrations/`
4. Verify SQL Server compatibility before implementation
