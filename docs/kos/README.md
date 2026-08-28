# Knowledge OS 2.0

> **Version:** `2.0.0`
>
> **Status:** Canonical specification, Zero-Context Startup and operational migration accepted
>
> **Source of Truth:** this directory for frozen governance and startup; [`../KNOWLEDGE_OS.md`](../KNOWLEDGE_OS.md) for operational entry
>
> **Assignments:** [`KOS-GOV-001`](../assignments/kos-gov-001.md), [`KOS-BOOT-001`](../assignments/kos-boot-001.md), [`KOS-MIG-001`](../assignments/kos-mig-001.md); design-only **[`KOS-2.1-OPS-001`](../assignments/kos-2.1-ops-001.md)** (2.0 remains binding)

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

Closed publication Assignments remain historical authority for their own deliverables; they do not authorize new redesign or domain migration by themselves.

## Knowledge OS 2.1 Operational Maturity (ops under 2.0)

| Artifact | Role |
|---|---|
| [`kos-2.1-operational-maturity.md`](kos-2.1-operational-maturity.md) | **Published ops package** (M-01…M-05, S-02/S-03) |
| [`ACTIVE_WORK.md`](../ACTIVE_WORK.md) | Active Work Summary (≤10); Assignment remains lifecycle SoT |
| [`PD-KOS-2.1-OPS-IMPL-001`](../product-decisions/KOS-2.1-OPS-IMPL-001-authorization.md) | Implementation authorization |
| [`kos-2.1-ops-design-draft.md`](kos-2.1-ops-design-draft.md) | Historical design draft |
| [`Architecture review`](../assignments/kos-2.1-ops-001-architecture-review.md) | Design Pass with conditions |

**2.0 remains the frozen constitution.** The 2.1 ops package does not replace it
and does not authorize dual-track or Migration by itself.

## KOS 2.2 Advisory Reliability Layer

Universe Keyboard has adopted `kos-agent-kit@v0.5.0` in `advisory` mode:

| Artifact | Role |
|---|---|
| [`UPGRADE_STATUS.md`](UPGRADE_STATUS.md) | Adopted version, disposition and next review Source of Truth |
| [`.kos/project.json`](../../.kos/project.json) | Included records, claims, environments, Gate policies and mode |
| [`KOS-UPGRADE-UK-001`](../assignments/kos-upgrade-uk-001.md) | Adoption Assignment and bounded non-goals |

KOS 2.2 adds machine-readable record envelopes and deterministic read-only
validation on top of KOS 2.0/2.1. It does not replace their authority or
lifecycle rules. Historical records are not automatically invalid because they
lack an envelope; adoption remains progressive until a separately authorized
Upgrade Assignment enables `required`.

Structural validator success is not Product, Architecture, Quality, merge,
TestFlight or Release approval. Do not copy the upstream Kit into this directory
or rewrite frozen KOS 2.0 text; use the pinned upstream release for executable
envelope semantics and keep project-specific truth in this repository.

## Non-goals

This directory does not authorize by mere existence:

- further repository migration beyond accepted records;
- implementation work;
- production code changes;
- test changes;
- Runtime, RIME, Benchmark, Registry or ADR product changes;
- Knowledge OS 2.1 or 3.0;
- new roles, lifecycle concepts, object models or governance principles without a new Product Assignment.
