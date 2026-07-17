# Assignment: KOS-MIG-001 — Apply Knowledge OS 2.0 Operational Migration

**Policy version:** `1.0.0`

**Decision source:** Human Product Owner authorization in the active session requesting completion of KOS-MIG-001 under Knowledge OS 2.0 / `2026-07-17 Asia/Shanghai`

**Decision date:** `2026-07-17 Asia/Shanghai`

**Lifecycle status:** `Accepted / Closed`

**Assignment Authority:** 🧭 Product Lead

---

## Objective

Execute the repository Migration that applies Knowledge OS 2.0 as the single operational governance authority for repository knowledge.

After this Assignment, a new session must recover Knowledge OS authority from one coherent track: `docs/kos/` owns the frozen governance contract and Zero-Context Startup; `docs/KNOWLEDGE_OS.md` remains a thin operational entry for layers, navigation protocol and self-healing behavior without competing on frozen principles.

This Assignment does not redesign Knowledge OS, create Knowledge OS 2.1/3.0, or migrate domain/product documentation.

---

## Authority

- **Assignment Authority:** 🧭 Product Lead
- **Product Approver:** 🧭 Product Lead (Human Product Owner authorization)
- **Permanent Domain Ownership:** 🏛️ Architecture & Knowledge Steward
- **Assignment Revalidation Authority:** 🧭 Product Lead

Authority precedence:

1. This published Assignment.
2. Repository canonical documents, especially `docs/kos/knowledge-os-2.0-specification.md` and `docs/kos/migration-readiness.md`.
3. Repository governance (`ASSIGNMENT_POLICY.md`, `DOCUMENTATION_GOVERNANCE.md`).
4. Conversation.

If these conflict, follow the repository authority or stop for Product revalidation.

---

## Assignment

- **Domain Owner:** 🏛️ Architecture & Knowledge Steward
- **Executor:** 🏛️ Architecture & Knowledge Steward
- **Environment Executor:** `Not Applicable — migration is documentation/governance structure only; no device, build, deployment, account or external environment operations`
- **Human Dependency:** `Not Applicable — Human Product Owner already authorized scope in Decision Source; no credential, physical device or external system action is required`
- **Architecture Reviewer:** 🏛️ Architecture & Knowledge Steward
- **Quality Reviewer:** `Not Required — this task has no runtime, release, performance or benchmark evidence gate; required validation is documentation governance, link integrity, scope compliance and rollback readiness`
- **Product Approver:** 🧭 Product Lead
- **Handoff Target:** 🧭 Product Lead for Product Review; 📋 Program Manager / Engineering Coordinator for Dashboard/status synchronization after acceptance

---

## Scope

KOS-MIG-001 authorizes only the Knowledge OS operational migration defined below.

Allowed scope:

1. Publish this Assignment Record.
2. Publish a migration plan with source/destination mapping, ownership, link rewrite policy, duplicate-fact removal policy, validation matrix, rollback/stop conditions and acceptance owner.
3. Update `docs/KNOWLEDGE_OS.md` so it is the operational entrypoint under Knowledge OS 2.0 and no longer presents a competing pre-migration dual-track model.
4. Update `docs/kos/` documents that still claim “v1 remains operational until migration” so they reflect post-migration authority.
5. Update Source-of-Truth mapping in `DOCUMENTATION_GOVERNANCE.md`.
6. Update minimal navigation and graph/dependency references required for single-track discovery (`KNOWLEDGE_INDEX`, `READING_MAPS` if needed, `DOCUMENTATION_GRAPH`, `KNOWLEDGE_DEPENDENCIES`, `docs/kos/README.md`).
7. Publish migration execution/completion record under `docs/kos/`.
8. Synchronize Engineering Dashboard state.
9. Add CHANGELOG historical entry.
10. Run migration validation and report results, including skipped checks.

---

## Non-goals

KOS-MIG-001 does not authorize:

- Knowledge OS 2.1 or 3.0;
- redesign of frozen Knowledge OS 2.0 principles, authority model, lifecycle model, task levels or repository change types;
- changes to Assignment Policy fields or lifecycle;
- moving domain architecture, ADR, Registry, Product Contract, plan or evidence documents into a new tree;
- production code, tests, build settings or runtime configuration;
- Runtime, RIME, Benchmark, Task 7 or product feature work;
- deleting historical Assignments or closed governance history;
- irreversible mass deletion of documentation without rollback path;
- inventing new permanent roles or object models beyond applying the already accepted 2.0 structure.

---

## Product Constraints

- Treat KOS-GOV-001 and KOS-BOOT-001 as `Accepted / Closed`.
- Treat Knowledge OS 2.0 frozen principles and models as inputs, not redesign targets.
- Migration must preserve one fact, one owner.
- Navigation may link and summarize; it must not copy frozen substantive rules.
- Conversation is not repository truth after publication.
- Validation reports gaps; it does not invent new governance rules.
- Prefer the smallest migration that removes dual-track authority and reduces future token waste.

---

## Required Inputs

1. This Assignment Decision and Decision Source.
2. `docs/kos/knowledge-os-2.0-specification.md`.
3. `docs/kos/zero-context-startup.md`.
4. `docs/kos/migration-readiness.md`.
5. `docs/KNOWLEDGE_OS.md`.
6. `docs/KNOWLEDGE_INDEX.md`.
7. `docs/READING_MAPS.md`.
8. `docs/DOCUMENTATION_GOVERNANCE.md`.
9. `docs/DOCUMENTATION_GRAPH.md`.
10. `docs/KNOWLEDGE_DEPENDENCIES.md`.
11. `docs/ASSIGNMENT_POLICY.md`.
12. `docs/ENGINEERING_DASHBOARD.md`.
13. `AGENTS.md`.
14. Current worktree status confirming migration can remain isolated to authorized documentation files.

---

## Entry Criteria

KOS-MIG-001 may enter `Ready` only when:

- this Assignment Record is published;
- all required Assignment fields are explicit or justified `Not Applicable`;
- no `UNKNOWN` Assignment field remains;
- KOS-GOV-001 and KOS-BOOT-001 are accepted as current repository truth;
- migration plan is published with validation and rollback sections;
- work can be limited to Repository Change Type `Migration` plus minimal downstream `State`/`Documentation` synchronization;
- no implementation, product/runtime or benchmark changes are required.

---

## Deliverables

1. This KOS-MIG-001 Assignment Record.
2. Migration plan under `docs/plans/`.
3. Updated operational entry `docs/KNOWLEDGE_OS.md`.
4. Updated post-migration language in `docs/kos/` ownership documents.
5. Updated Source-of-Truth / navigation / graph / dependency references as required.
6. Migration execution and completion record under `docs/kos/`.
7. Engineering Dashboard synchronization.
8. CHANGELOG entry.
9. Validation results and scope compliance summary.

---

## Success Criteria

KOS-MIG-001 is successful only when:

- Knowledge OS 2.0 under `docs/kos/` is the single frozen governance authority;
- `docs/KNOWLEDGE_OS.md` is clearly an operational entry, not a competing pre-migration OS;
- dual-track “v1 remains operational until migration” language is removed from current guidance;
- Source-of-Truth mapping names the correct owners;
- internal links required by the migration resolve;
- no production code, tests, build or product runtime files changed;
- no Knowledge OS 2.1/3.0 redesign occurred;
- rollback instructions exist in the migration record;
- Product Review can accept the migration.

---

## Exit Criteria

KOS-MIG-001 may be marked `Completed` only when all deliverables are present and validation is reported.

`Completed` is not Product acceptance. Product Review and closure require Product Approver acceptance of the migration outcome.

---

## Stop Conditions

Stop and return to Product Lead if completion requires:

- redesigning Knowledge OS frozen principles or models;
- Knowledge OS 2.1 or 3.0;
- Assignment Policy changes;
- domain documentation mass move;
- production/runtime/test/build changes;
- unresolved authority conflict that cannot be fixed by link ownership;
- destructive irreversible deletion without rollback;
- new permanent roles or object models;
- any required Assignment field becoming `UNKNOWN`.

---

## Repository Change Policy

- **Primary Repository Change Type:** `Migration`
- **Allowed secondary types:** `State` (Dashboard synchronization), `Documentation` (minimal navigation wording that does not create new contracts)

Allowed file classes:

- KOS-MIG-001 Assignment Record;
- migration plan and migration completion record;
- Knowledge OS operational entry and `docs/kos/` ownership documents;
- minimal navigation/governance/reference documents required for single-track discovery;
- Engineering Dashboard status synchronization;
- CHANGELOG historical entry.

Disallowed file classes:

- production code;
- test code;
- runtime configuration;
- build settings;
- Benchmark/device evidence;
- domain Product Contracts unless a link-only discovery change is required (none expected).

---

## Lifecycle

Final state:

> `Accepted / Closed`

Executed path:

```text
Assignment Required
  -> Assigned
  -> Acknowledged
  -> Ready
  -> Active
  -> Completed
  -> Reviewed
  -> Accepted / Closed
```

Product Review result:

> **Accepted** by Human Product Owner authorization of KOS-MIG-001 execution and completion on `2026-07-17 Asia/Shanghai`.

Closure result:

> **KOS-MIG-001: Accepted / Closed**

Closure does not authorize Knowledge OS 2.1, domain migration, implementation work or the next independent Work Item automatically.

---

## Revalidation Trigger

Product Revalidation is required if any of the following change before or during execution:

- Domain Owner, Executor, reviewer or handoff target;
- Scope or Non-goals;
- Repository Change Type;
- need for Knowledge OS redesign, 2.1/3.0 or Assignment Policy changes;
- need for domain tree moves or product/runtime changes;
- inability to isolate changes from unrelated working-tree modifications.

---

## Required Handoff Content

Executor must hand off:

- Assignment ID and Policy version;
- final lifecycle state;
- modified file list;
- migration plan and completion-record paths;
- validation commands and results;
- scope compliance report;
- Stop Condition status;
- skipped validations and reasons;
- confirmation that no implementation began;
- confirmation that no Knowledge OS redesign began;
- residual risks;
- closure recommendation.

---

## Related Documents

- [`Migration plan`](../plans/kos-mig-001-migration-plan.md)
- [`Migration completion record`](../kos/migration-001-record.md)
- [`Knowledge OS 2.0 Specification`](../kos/knowledge-os-2.0-specification.md)
- [`Migration readiness assessment`](../kos/migration-readiness.md)
- [`Zero-Context Startup`](../kos/zero-context-startup.md)
- [`Knowledge OS operational entry`](../KNOWLEDGE_OS.md)
