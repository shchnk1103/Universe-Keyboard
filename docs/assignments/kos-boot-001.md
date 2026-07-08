# Assignment: KOS-BOOT-001 — Publish Zero-Context Startup Layer

**Policy version:** `1.0.0`

**Decision source:** Product Lead — KOS-BOOT-001 Mission Charter and Governance Bootstrap Addendum

**Decision date:** `2026-07-08 Asia/Shanghai`

**Lifecycle status:** `Accepted / Closed`

**Assignment Authority:** 🧭 Product Lead

---

## Objective

Publish and validate the Zero-Context Startup Layer required to complete Knowledge OS 2.0.

The finished layer must let a new AI session enter the repository with minimal prompt context, recover the current repository truth from canonical sources and avoid relying on historical conversation as authority.

This Assignment completes the governance bootstrap required by the KOS-BOOT-001 Mission Charter. It does not reopen KOS-GOV-001 and does not redesign Knowledge OS 2.0.

---

## Authority

- **Assignment Authority:** 🧭 Product Lead
- **Product Approver:** 🧭 Product Lead
- **Permanent Domain Ownership:** 🏛️ Architecture & Knowledge Steward
- **Assignment Revalidation Authority:** 🧭 Product Lead

Authority precedence for this work is:

1. This published Assignment.
2. Repository canonical documents.
3. Repository governance.
4. KOS-BOOT-001 Mission Charter and Governance Bootstrap Addendum.
5. Conversation.

If these conflict, follow the repository authority or stop for Product revalidation.

---

## Assignment

- **Domain Owner:** 🏛️ Architecture & Knowledge Steward
- **Executor:** 🏛️ Architecture & Knowledge Steward
- **Environment Executor:** `Not Applicable — Zero-Context Startup publication does not require device, build, deployment, account or external environment operations`
- **Human Dependency:** `Not Applicable — repository governance activities are autonomous under the Mission Addendum and require no external credential, destructive action or human-only product decision`
- **Architecture Reviewer:** 🏛️ Architecture & Knowledge Steward
- **Quality Reviewer:** `Not Required — this task has no runtime, release, performance or benchmark evidence gate; required validation is documentation governance, navigation and scope validation`
- **Product Approver:** 🧭 Product Lead
- **Handoff Target:** 📋 Program Manager / Engineering Coordinator for closure synchronization after Product Review

---

## Scope

KOS-BOOT-001 authorizes only publication, validation and closure synchronization for the Zero-Context Startup Layer.

Allowed scope:

1. Publish a Zero-Context Startup specification under `docs/kos/`.
2. Define the repository entry procedure for a new AI session.
3. Define the startup reading order.
4. Define repository discovery rules.
5. Define current Work Item discovery.
6. Define current lifecycle discovery.
7. Define current role discovery.
8. Define repository truth discovery.
9. Define startup validation.
10. Define prompt compression guidance.
11. Add minimal navigation links required for discoverability.
12. Add minimal governance references required to identify the startup layer as canonical.
13. Validate internal consistency and link reachability.
14. Validate that no Repository Migration began.
15. Validate that no implementation work occurred.
16. Synchronize closure status in the Engineering Dashboard.

---

## Non-goals

KOS-BOOT-001 does not authorize:

- reopening or modifying KOS-GOV-001;
- redesigning Knowledge OS 2.0;
- changing accepted governance principles;
- changing the Authority Model;
- changing the Lifecycle Model;
- changing the Repository Change Policy;
- changing Task Levels;
- changing Work Order templates;
- changing Execution Contracts;
- changing Review Contracts;
- Repository Migration;
- creating KOS-MIG-001;
- Knowledge OS 2.1 or 3.0;
- production code changes;
- test code changes;
- build system changes;
- Universe Keyboard product or runtime modifications;
- Runtime, RIME, Benchmark, Registry, ADR, Template, Procedure, Task 7 or Assignment Policy changes outside this Assignment.

---

## Product Constraints

- Treat KOS-GOV-001 as `Accepted / Closed`.
- Do not re-open, revise or reinterpret KOS-GOV-001.
- Treat Knowledge OS 2.0 principles, authority, lifecycle, state/phase, task level, repository change and migration models as frozen.
- The Zero-Context Startup Layer must discover existing repository truth; it must not create a second source of truth.
- Navigation updates must link to the owning startup specification and avoid duplicating substantive rules.
- Prompt compression guidance must make conversation supplemental, not authoritative.
- Validation reports gaps; it must not invent new governance rules.

---

## Required Inputs

The following inputs were required before KOS-BOOT-001 could enter `Ready`:

1. Mission Charter and Governance Bootstrap Addendum.
2. `AGENTS.md`.
3. `docs/KNOWLEDGE_INDEX.md`.
4. `docs/READING_MAPS.md`.
5. `docs/KNOWLEDGE_OS.md`.
6. `docs/kos/knowledge-os-2.0-specification.md`.
7. `docs/kos/migration-readiness.md`.
8. `docs/ASSIGNMENT_POLICY.md`.
9. `docs/VIRTUAL_ENGINEERING_TEAM.md`.
10. `docs/DOCUMENTATION_GOVERNANCE.md`.
11. `docs/KNOWLEDGE_DEPENDENCIES.md`.
12. `docs/DOCUMENTATION_GRAPH.md`.
13. `docs/ENGINEERING_DASHBOARD.md`.
14. Current worktree status confirming unrelated changes can remain isolated.

---

## Entry Criteria

KOS-BOOT-001 could enter `Ready` only when:

- this Assignment Record was published;
- all required Assignment fields were explicit or justified `Not Applicable`;
- no `UNKNOWN` Assignment field remained;
- KOS-GOV-001 closure was accepted as current repository truth;
- publication could be limited to repository-backed governance documentation;
- no implementation, migration, product/runtime or benchmark changes were required;
- unrelated working-tree changes could be avoided.

---

## Deliverables

Executor must deliver:

1. This KOS-BOOT-001 Assignment Record.
2. Zero-Context Startup specification.
3. Bootstrap workflow.
4. Repository entry procedure.
5. Startup reading order.
6. Repository discovery rules.
7. Current Work Item discovery.
8. Current lifecycle discovery.
9. Current role discovery.
10. Repository truth discovery.
11. Startup validation procedure.
12. Prompt compression strategy.
13. Minimal navigation links required for discoverability.
14. Minimal governance references identifying the startup layer as canonical.
15. Engineering Dashboard closure synchronization.
16. Validation results.
17. Scope compliance summary.

---

## Success Criteria

KOS-BOOT-001 is successful only when:

- the Zero-Context Startup Layer is published in the repository;
- a new AI session can enter from `AGENTS.md` and `docs/KNOWLEDGE_INDEX.md` without historical conversation context;
- current Work Item, lifecycle, role and repository truth discovery are possible from repository sources;
- reading order is unambiguous;
- repository navigation is internally consistent;
- prompt context can shrink to repository entry instructions plus the current user objective;
- no accepted governance principle changed;
- no Repository Migration began;
- no implementation work occurred.

---

## Exit Criteria

KOS-BOOT-001 may be marked `Completed` only when:

- all deliverables are present;
- the startup specification is discoverable from Knowledge OS navigation;
- internal links resolve;
- the publication remains inside the frozen Knowledge OS 2.0 model;
- the Repository Change Type remains `Contract` plus downstream `State` synchronization;
- no production code, runtime, tests, build settings or product behavior were modified;
- Repository Migration has not begun;
- validation results and skipped validations are reported;
- Product Review can accept the published startup layer.

`Completed` does not authorize Repository Migration, Knowledge OS 2.1 or the next independent Work Item.

---

## Stop Conditions

Stop and return to Product Lead if completion requires:

- redesigning Knowledge OS;
- introducing new governance concepts;
- changing accepted Assignments outside this Assignment;
- changing accepted governance principles;
- changing the Authority Model, Lifecycle Model, Repository Change Policy or Task Levels;
- Repository Migration;
- implementation work;
- Runtime, Benchmark, Registry, ADR, Template, Procedure, Assignment Policy or Task 7 changes;
- external credentials;
- external network approval;
- destructive repository operations;
- irreversible data deletion;
- human product decisions that cannot be derived from the repository.

---

## Repository Change Policy

- **Repository Change Type:** `Contract`
- **Closure synchronization type:** `State`

Allowed file classes:

- KOS-BOOT-001 Assignment Record;
- Knowledge OS 2.0 startup specification documents;
- minimal navigation documents;
- minimal governance/reference documents required for Source-of-Truth discovery;
- Engineering Dashboard status synchronization;
- changelog history entry after completion.

Disallowed file classes:

- production code;
- test code;
- runtime configuration;
- build settings;
- repository migration output;
- benchmark evidence;
- device/environment evidence.

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

Closure means this Mission ended after publishing, validation and repository integration. It does not authorize the next independent Work Item.

---

## Revalidation Trigger

Product Revalidation is required if any of the following change:

- Domain Owner, Executor, reviewer or handoff target;
- Scope or Non-goals;
- Repository Change Type;
- frozen Knowledge OS 2.0 governance inputs;
- need for implementation or Repository Migration;
- need for ADR, Registry, Template, Procedure, Assignment Policy or Product Contract changes beyond this Assignment;
- inability to isolate changes from unrelated working-tree modifications.

---

## Required Handoff Content

Executor must hand off:

- Assignment ID and Policy version;
- final lifecycle state;
- modified file list;
- startup specification path;
- navigation and governance references added;
- validation commands and results;
- scope compliance report;
- Stop Condition status;
- skipped validations and reasons;
- confirmation that no implementation began;
- confirmation that no Repository Migration began;
- residual risks;
- closure recommendation.

---

## Product Review And Closure

Product Review result:

> **Accepted**

Closure result:

> **KOS-BOOT-001: Accepted / Closed**

The Zero-Context Startup Layer is accepted as the final missing Knowledge OS 2.0 startup capability. Stop after closure synchronization. Do not begin Repository Migration, Knowledge OS 2.1 or any next independent Work Item automatically.
