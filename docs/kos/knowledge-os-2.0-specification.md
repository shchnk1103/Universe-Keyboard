# Knowledge OS 2.0 Canonical Specification

> **Version:** `2.0.0`
>
> **Status:** Canonical specification published for KOS-GOV-001 Product Review
>
> **Repository Change Type:** `Contract`
>
> **Assignment:** [`KOS-GOV-001`](../assignments/kos-gov-001.md)

## Purpose

Knowledge OS 2.0 is the repository governance specification for durable knowledge. It defines the authority, lifecycle, task level, repository change and migration boundaries used to keep knowledge discoverable, reviewable and maintainable after conversation history disappears.

This specification records the frozen Knowledge OS 2.0 architecture. It does not redesign Knowledge OS, reinterpret Product intent or execute repository migration.

## Source-of-Truth Boundary

This document is the canonical Knowledge OS 2.0 specification. Navigation documents may link to it and summarize its existence, but they must not maintain a competing copy of its substantive rules.

Current Knowledge OS v1 entrypoints remain operational navigation until a separately assigned migration updates them. Publication of this specification does not migrate the repository.

## Frozen Principles

Knowledge OS 2.0 is governed by these frozen principles:

1. Repository knowledge must have a single owning Source of Truth.
2. Navigation documents link to owning sources; they do not duplicate substantive rules.
3. Product, Architecture, Quality, Program Management and Execution authority are separate.
4. Task-level Assignment does not create or transfer permanent roles.
5. Lifecycle state and current phase are separate concepts.
6. Repository changes must declare their change type before execution.
7. Migration must be explicitly assigned and must not occur as a side effect of specification publication.
8. Historical conversation is not repository truth.
9. Unknown authority, missing required inputs or conflicting frozen inputs stop progress.
10. Validation reports gaps; it does not invent new governance rules.

## Authority Model

Knowledge OS 2.0 preserves the existing authority separation:

| Authority | Owns | Must not do |
|---|---|---|
| Product Lead | Product decisions, Assignment authority, Product approval, revalidation | Perform Architecture, Quality or implementation decisions by implication |
| Architecture & Knowledge Steward | Architecture boundaries, Source of Truth, documentation architecture, ADR and Knowledge OS governance | Reinterpret Product intent or perform Quality acceptance |
| Quality, Performance & Release Maintainer | Evidence, validation, performance, release and quality gates | Redesign architecture or assign work |
| Program Manager / Engineering Coordinator | Status synchronization, completeness checks, handoff coordination | Assign owners, approve Product scope or create decisions |
| Domain Owner | Domain correctness and domain handoff quality | Expand scope or bypass Product/Architecture/Quality gates |
| Executor | In-scope work authorized by Assignment | Create authority, redesign frozen inputs or start unassigned work |

Authority precedence for KOS-GOV-001 publication is:

1. Published Assignment.
2. Repository canonical documents.
3. Work Order.
4. Conversation.

If these conflict, follow the Published Assignment or stop for Product revalidation.

## Lifecycle Model

Knowledge OS 2.0 uses the Assignment lifecycle from [`Assignment Policy v1.0.0`](../ASSIGNMENT_POLICY.md):

```text
Assignment Required
  -> Assignment Pending
       -> Assigned
            -> Acknowledged
                 -> Ready
                      -> Active
                           -> Completed
                                -> Reviewed
                                     -> Closed
```

Exceptional transitions:

```text
Assignment Pending / Assigned / Ready / Active
  -> Blocked
       -> Reassigned
            -> Acknowledged
                 -> Ready / Active
```

KOS-GOV-001 uses its published Assignment lifecycle context:

- current state at publication start: `Assigned`;
- allowed execution path: `Assigned -> Acknowledged -> Ready -> Active -> Completed`;
- final acceptance and closure remain Product Lead decisions.

This specification does not introduce a new lifecycle.

## State And Phase Model

Knowledge OS 2.0 separates state from phase:

| Concept | Meaning | Owner |
|---|---|---|
| Lifecycle State | Assignment progress and gate status, such as `Assigned`, `Ready`, `Active`, `Completed`, `Reviewed` or `Closed` | Product Assignment / owning gate |
| Current Phase | The type of work currently authorized, such as Architecture Review, Specification Publication, Quality Review or Product Review | Current Assignment and role boundary |

Rules:

- State does not grant work authority by itself.
- Phase does not override Assignment scope.
- Dashboard phase summaries do not supersede Assignment records.
- A phase requiring a role not assigned in the canonical Assignment requires Product revalidation.

## Task Level Specification

Knowledge OS 2.0 recognizes task levels as governance classification, not as permanent role creation.

| Level | Meaning | Expected governance |
|---|---|---|
| Level S — System Governance | Repository-wide governance or knowledge-system contract | Published Assignment, Architecture review, Product approval and explicit repository change policy |
| Formal assigned task | Bounded work item with owner, executor, required inputs, gates and handoff | Assignment Policy applies |
| Read-only review | Architectural, Product, Quality or coordination review with no repository modification | May proceed under explicit Work Order when authority and scope are clear |
| Implementation / evidence task | Runtime, tooling, evidence, release or test work | Requires appropriate Domain, Architecture, Quality and Product boundaries |

KOS-GOV-001 is `Level S — System Governance`.

## Repository Change Policy

Every Knowledge OS 2.0 task must declare its Repository Change Type before execution.

| Change Type | Meaning | Examples |
|---|---|---|
| `Contract` | Repository governance, architecture or product contract publication/update | Knowledge OS specification, Assignment records, registry source-of-truth documents |
| `State` | Status, routing or dashboard synchronization without changing the underlying contract | Dashboard status update after owner-confirmed decision |
| `Documentation` | Non-contract documentation clarification or navigation update | Reading map link correction, typo fix |
| `Implementation` | Product, runtime, test, build or tooling code change | Runtime feature, test update, build script change |
| `Evidence` | Evidence capture or validation artifact | Environment run record, benchmark evidence |
| `Migration` | Repository structure or content migration applying an accepted migration plan | Moving documents into a new canonical structure |

KOS-GOV-001 is limited to `Contract`.

Allowed file classes for KOS-GOV-001:

- Knowledge OS 2.0 canonical specification documents;
- minimal navigation documents;
- minimal governance/reference documents required for Source-of-Truth discovery.

Disallowed file classes:

- production code;
- test code;
- runtime configuration;
- build settings;
- migration output files created by executing migration;
- benchmark evidence;
- device/environment evidence.

## Migration Specification

Specification publication and repository migration are separate.

Knowledge OS 2.0 migration rules:

1. Publishing the specification does not move, rename, archive or delete existing documents except for minimal navigation/reference links required for discoverability.
2. Migration requires a separate Assignment and Product authorization.
3. Migration must define source documents, destination structure, ownership, validation, rollback or stop conditions before execution.
4. Migration must preserve Source-of-Truth ownership and must not create duplicate authoritative facts.
5. Migration readiness assessment may identify blockers, but must not resolve them by moving files.
6. Any migration that requires new roles, lifecycle states, object models or governance concepts must return to Product Lead before execution.

## Repository Structure Specification

Knowledge OS 2.0 canonical specification lives under:

```text
docs/kos/
  README.md
  knowledge-os-2.0-specification.md
  zero-context-startup.md
  migration-readiness.md
```

The current repository navigation remains:

```text
AGENTS.md
  -> docs/KNOWLEDGE_INDEX.md
       -> docs/READING_MAPS.md
       -> docs/KNOWLEDGE_OS.md
       -> docs/kos/
```

Structure rules:

- `docs/kos/` owns Knowledge OS 2.0 specification text and the Zero-Context Startup Layer.
- `docs/KNOWLEDGE_OS.md` remains the operational entrypoint until separately migrated.
- `docs/KNOWLEDGE_INDEX.md`, `docs/READING_MAPS.md`, `docs/DOCUMENTATION_GRAPH.md` and `docs/KNOWLEDGE_DEPENDENCIES.md` may link to `docs/kos/` for discoverability.
- Existing domain, architecture, ADR, Registry, Template, Procedure, Assignment and Dashboard documents keep their current ownership unless a separate Assignment changes them.
- No repository migration is implied by this directory existing.

## Validation Contract

A Knowledge OS 2.0 specification publication is valid only when:

- the canonical specification is discoverable from repository navigation;
- internal links resolve;
- no implementation, runtime, test, build or migration output changes are included;
- no new roles, lifecycle concepts, object models or governance principles are introduced;
- the repository change remains `Contract`;
- migration readiness is assessed without executing migration;
- handoff returns to Product Lead for review.

## Stop Conditions

Stop and return to Product Lead if any future Knowledge OS 2.0 work requires:

- architecture redesign;
- Product reinterpretation;
- new roles;
- new lifecycle concepts;
- new object models;
- new governance principles;
- Repository Migration;
- implementation work;
- Runtime, Registry, ADR, Template, Procedure or Assignment Policy changes not authorized by the current Assignment.

## Related Documents

- [`KOS-GOV-001 Assignment`](../assignments/kos-gov-001.md)
- [`KOS-BOOT-001 Assignment`](../assignments/kos-boot-001.md)
- [`Zero-Context Startup Layer`](zero-context-startup.md)
- [`Knowledge OS`](../KNOWLEDGE_OS.md)
- [`Knowledge Index`](../KNOWLEDGE_INDEX.md)
- [`Reading Maps`](../READING_MAPS.md)
- [`Documentation Governance`](../DOCUMENTATION_GOVERNANCE.md)
- [`Documentation Graph`](../DOCUMENTATION_GRAPH.md)
- [`Knowledge Dependencies`](../KNOWLEDGE_DEPENDENCIES.md)
- [`Assignment Policy`](../ASSIGNMENT_POLICY.md)
- [`Engineering Dashboard`](../ENGINEERING_DASHBOARD.md)
