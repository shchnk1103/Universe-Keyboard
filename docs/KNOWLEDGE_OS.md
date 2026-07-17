# Universe Keyboard Knowledge OS

> **Operational entry under Knowledge OS 2.0**
>
> **Migration:** [`KOS-MIG-001`](assignments/kos-mig-001.md) — applied
>
> **Frozen governance SoT:** [`docs/kos/`](kos/)

## Purpose

The Knowledge OS is the operating model for repository knowledge. It tells contributors how to find an answer, identify its authority, change it safely and detect drift. It is not a project README, architecture description or implementation guide.

This file is the **operational entrypoint** after Knowledge OS 2.0 migration. It owns knowledge layers, navigation protocol, evolution transitions and self-healing behavior. It does **not** own frozen governance principles, authority model, lifecycle model, task levels, repository change types or migration rules.

## Authority Boundary

| Concern | Source of Truth |
|---|---|
| Frozen Knowledge OS 2.0 principles, authority, lifecycle, state/phase, task levels, repository change policy, migration rules | [`docs/kos/knowledge-os-2.0-specification.md`](kos/knowledge-os-2.0-specification.md) |
| Zero-Context Startup for new AI sessions | [`docs/kos/zero-context-startup.md`](kos/zero-context-startup.md) |
| KOS-MIG-001 migration execution evidence and rollback | [`docs/kos/migration-001-record.md`](kos/migration-001-record.md) |
| Task Assignment contract | [`ASSIGNMENT_POLICY.md`](ASSIGNMENT_POLICY.md) |
| Documentation SoT table and doc lifecycle | [`DOCUMENTATION_GOVERNANCE.md`](DOCUMENTATION_GOVERNANCE.md) |
| Operational layers, navigation protocol, evolution, self-healing | **This file** |

Start at [`KNOWLEDGE_INDEX.md`](KNOWLEDGE_INDEX.md). For zero-context AI entry, use [`kos/zero-context-startup.md`](kos/zero-context-startup.md). Select a task in [`READING_MAPS.md`](READING_MAPS.md), then read only the sources required for that task.

## Knowledge Layers

| Layer | Responsibility | Entry |
|---|---|---|
| Entry | Fast orientation and navigation | `README.md`, `docs/KNOWLEDGE_INDEX.md` |
| Current system | What exists and where responsibilities live | `docs/PROJECT_CONTEXT.md`, architecture documents |
| Decisions | Why durable contracts exist | `docs/architecture/decisions/` |
| Operations | How to diagnose, measure and release | `docs/DEBUGGING.md`, `docs/PERFORMANCE_BASELINE.md`, `docs/RELEASE_CHECKLIST.md` |
| Risk | What remains unsafe or incomplete | `docs/TECH_DEBT.md` |
| History | What changed and why architecture evolved | `CHANGELOG.md`, `docs/ARCHITECTURE_TIMELINE.md`, archived plans |
| Collaboration | How agents and contributors work | `AGENTS.md`, `docs/AI_WORKFLOW.md`, `docs/playbooks/` |
| Governance | How knowledge is maintained | `docs/kos/`, this file, `docs/DOCUMENTATION_GOVERNANCE.md`, `docs/DOCUMENTATION_HEALTH.md` |

## Navigation Protocol

1. Read `AGENTS.md` for non-negotiable collaboration rules.
2. Open `docs/KNOWLEDGE_INDEX.md`; do not begin with a repository-wide scan.
3. When recovering repository authority with little or no chat history, read `docs/kos/zero-context-startup.md`.
4. Choose the closest task in `docs/READING_MAPS.md`.
5. Read the listed current architecture documents before historical material.
6. Read applicable ADRs before proposing a change to a durable contract.
7. Use `docs/DEBUGGING.md` for evidence collection, not intuition.
8. Use `docs/KNOWLEDGE_DEPENDENCIES.md` before editing documentation.
9. Apply `docs/DOCUMENTATION_GOVERNANCE.md` and pre-push review before handoff.

If no reading map matches, use the glossary to identify the owning subsystem, then follow the documentation graph. A missing route is a Knowledge OS defect and should be added without copying domain content.

## One Fact, One Owner

Knowledge is linked, not mirrored. The owning document contains the full fact; upstream navigation documents name and link it. ADRs own rationale, architecture documents own current mechanics, operational documents own procedures, and the changelog owns dated events.

When two sources disagree:

1. verify current source behavior and project configuration;
2. identify the designated Source of Truth in `DOCUMENTATION_GOVERNANCE.md`;
3. correct that source;
4. replace stale copies with links or non-authoritative summaries;
5. record the correction if it changes previously published understanding.

## Knowledge Evolution

Knowledge should evolve through explicit transitions:

- proposed direction -> active plan;
- durable choice -> accepted ADR;
- implemented behavior -> current architecture or domain source;
- diagnostic discovery -> debugging procedure or invariant;
- unresolved risk -> technical debt;
- completed work -> changelog and archived plan;
- superseded choice -> new ADR linked from the old one;
- governance contract change -> Assignment-authorized publication under `docs/kos/` rules.

No transition is complete while the old document still appears authoritative.

## Self-Healing Mechanisms

The repository repairs drift through:

- reading maps that expose missing routes;
- dependency rules that identify review impact;
- pre-push governance gates;
- measurable health checks in `DOCUMENTATION_HEALTH.md`;
- monthly or milestone Knowledge Audits;
- archived plans and superseded ADR links;
- explicit technical-debt triggers;
- Assignment lifecycle and stop conditions when authority is missing.

Self-healing means drift becomes observable and assigned. It does not mean generating more prose automatically.

## What The Knowledge OS Must Not Become

- A second README or PROJECT_CONTEXT.
- A second copy of the frozen Knowledge OS 2.0 specification.
- A summary of every implementation detail.
- A replacement for reading source code during implementation.
- A store for chat transcripts or unverified recollection.
- A dashboard with manually maintained numbers that immediately drift.
- An excuse to duplicate the same rule across indexes, playbooks and checklists.
- A requirement to document trivial local code behavior that is already clear and tested.

## Definition Of Healthy

A healthy repository lets a new contributor answer, without historical chat:

- Where is the authoritative answer?
- Why does this contract exist?
- What else must be reviewed if it changes?
- How is failure diagnosed and release safety verified?
- Which risks are intentionally unresolved?
- Which historical documents are no longer guidance?

The system is unhealthy whenever answering requires guessing which document is current.

## Related Documents

- [`docs/kos/`](kos/) — Knowledge OS 2.0 canonical specification and startup layer
- [`KNOWLEDGE_INDEX.md`](KNOWLEDGE_INDEX.md) — navigation only
- [`READING_MAPS.md`](READING_MAPS.md) — task routes
- [`DOCUMENTATION_GOVERNANCE.md`](DOCUMENTATION_GOVERNANCE.md) — SoT table and doc rules
- [`ASSIGNMENT_POLICY.md`](ASSIGNMENT_POLICY.md) — task Assignment contract
