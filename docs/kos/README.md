# Knowledge OS 2.0

> **Version:** `2.0.0`
>
> **Status:** Canonical specification, Zero-Context Startup and operational migration accepted
>
> **Source of Truth:** this directory for frozen governance and startup; [`../KNOWLEDGE_OS.md`](../KNOWLEDGE_OS.md) for operational entry
>
> **Assignments:** [`KOS-GOV-001`](../assignments/kos-gov-001.md), [`KOS-BOOT-001`](../assignments/kos-boot-001.md), [`KOS-MIG-001`](../assignments/kos-mig-001.md)

This directory is the canonical repository-backed specification for Knowledge OS 2.0.

Knowledge OS 2.0 is a governance specification. It defines how repository knowledge is organized, assigned, changed, reviewed and migrated. It is not product runtime behavior, implementation code, Benchmark evidence or domain architecture.

## Canonical Documents

- [`Knowledge OS 2.0 Specification`](knowledge-os-2.0-specification.md) — frozen principles, authority model, lifecycle model, state and phase model, task level specification, repository change policy, migration specification and repository structure specification.
- [`Zero-Context Startup Layer`](zero-context-startup.md) — startup workflow, reading order, discovery rules, repository-truth discovery, validation and prompt compression guidance for new AI sessions.
- [`Migration Readiness Assessment`](migration-readiness.md) — historical readiness assessment from KOS-GOV-001 publication (not current migration status).
- [`Migration completion record`](migration-001-record.md) — KOS-MIG-001 execution evidence, validation, scope compliance and rollback.

## Post-Migration Authority

After [`KOS-MIG-001`](../assignments/kos-mig-001.md):

| Concern | Owner |
|---|---|
| Frozen Knowledge OS 2.0 contract | `knowledge-os-2.0-specification.md` |
| Zero-Context Startup | `zero-context-startup.md` |
| Operational layers / navigation protocol / self-healing | [`../KNOWLEDGE_OS.md`](../KNOWLEDGE_OS.md) |
| Migration execution evidence | `migration-001-record.md` |

Navigation is single-track. Do not treat pre-migration “v1 remains operational” language as current guidance.

## Authority Boundary

If this directory conflicts with an applicable open Assignment, return to Product Lead for revalidation. Do not resolve the conflict by redesigning Knowledge OS.

Closed publication Assignments remain historical authority for their own deliverables; they do not authorize new redesign, Knowledge OS 2.1 or domain migration.

## Non-goals

This directory does not authorize by mere existence:

- further repository migration beyond accepted records;
- implementation work;
- production code changes;
- test changes;
- Runtime, RIME, Benchmark, Registry or ADR product changes;
- Knowledge OS 2.1 or 3.0;
- new roles, lifecycle concepts, object models or governance principles without a new Product Assignment.
