# Zero-Context Startup Layer

> **Version:** `2.0.0`
>
> **Status:** Accepted / Closed; operational track applied by KOS-MIG-001
>
> **Repository Change Type:** `Contract` (publication)
>
> **Publication Assignment:** [`KOS-BOOT-001`](../assignments/kos-boot-001.md)
>
> **Migration Assignment:** [`KOS-MIG-001`](../assignments/kos-mig-001.md)

## Purpose

The Zero-Context Startup Layer defines how a completely new AI session enters this repository with minimal prompt context and reconstructs current working authority from repository sources.

It completes Knowledge OS 2.0 startup behavior. It does not redesign Knowledge OS 2.0 or create a new governance model. Operational single-track navigation was applied by [`KOS-MIG-001`](../assignments/kos-mig-001.md); this document remains the startup Source of Truth and must not be replaced by conversation memory.

## Source-of-Truth Boundary

This document owns the startup procedure only:

- what to read first;
- how to discover current work;
- how to discover lifecycle, role and repository-truth authority;
- how to validate startup readiness;
- how prompts may be compressed once repository startup is reliable.

It does not own:

- Assignment field definitions or lifecycle rules, which remain in [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md);
- permanent role definitions, which remain in [`VIRTUAL_ENGINEERING_TEAM.md`](../VIRTUAL_ENGINEERING_TEAM.md);
- current program state, which remains a summary in [`ENGINEERING_DASHBOARD.md`](../ENGINEERING_DASHBOARD.md);
- Knowledge OS 2.0 principles, authority model, lifecycle model, task levels, repository change policy or migration model, which remain in [`knowledge-os-2.0-specification.md`](knowledge-os-2.0-specification.md);
- domain architecture, runtime behavior, Benchmark evidence, release evidence or migration execution.

Navigation documents may link to this document and summarize its existence, but must not maintain a competing startup procedure.

## Bootstrap Workflow

A new AI session starts with the smallest sufficient prompt:

```text
Read AGENTS.md.
Then read docs/KNOWLEDGE_INDEX.md.
Use docs/kos/zero-context-startup.md to discover current repository authority.
Follow the current user objective only after repository authority is known.
```

Then execute:

1. Read [`AGENTS.md`](../../AGENTS.md) for mandatory collaboration rules.
2. Read [`docs/KNOWLEDGE_INDEX.md`](../KNOWLEDGE_INDEX.md) for top-level navigation.
3. Read this startup layer when the session must recover repository authority with little or no historical prompt context.
4. Read [`docs/READING_MAPS.md`](../READING_MAPS.md) for the closest task route.
5. Read only the authority sources required by that route.
6. Before changing repository state, identify the Assignment, role owner, lifecycle state, Source of Truth and validation path.

Stop if the repository does not identify the required authority and the user objective would require guessing.

## Repository Entry Procedure

Use this procedure before acting on a non-trivial request:

1. **Identify the request class.** Determine whether the user asks for a read-only review, governance work, documentation change, implementation, evidence capture, release work or coordination.
2. **Find the route.** Use [`KNOWLEDGE_INDEX.md`](../KNOWLEDGE_INDEX.md), then [`READING_MAPS.md`](../READING_MAPS.md).
3. **Find the Work Item.** Search current Assignment records, Dashboard summaries and relevant task sources for the named task.
4. **Find the authority.** Resolve which document owns the decision or fact using [`DOCUMENTATION_GOVERNANCE.md`](../DOCUMENTATION_GOVERNANCE.md) and [`KNOWLEDGE_DEPENDENCIES.md`](../KNOWLEDGE_DEPENDENCIES.md).
5. **Find the role.** Resolve permanent ownership through [`VIRTUAL_ENGINEERING_TEAM.md`](../VIRTUAL_ENGINEERING_TEAM.md), then task-level responsibility through the applicable Assignment Record.
6. **Find the lifecycle state.** Use the Assignment Record for lifecycle authority; use [`ENGINEERING_DASHBOARD.md`](../ENGINEERING_DASHBOARD.md) only as a status summary that links back to owner sources.
7. **Check stop conditions.** Stop when required Assignment fields are `UNKNOWN`, required inputs are unavailable, repository sources conflict or the request exceeds authorized scope.
8. **Act only inside the resolved scope.** Change the owning source first, then update downstream navigation or status summaries only when their route changed.
9. **Validate the result.** Run validation appropriate to the change type and report skipped checks with reasons.

## Startup Reading Order

Default startup order:

1. [`AGENTS.md`](../../AGENTS.md)
2. [`docs/KNOWLEDGE_INDEX.md`](../KNOWLEDGE_INDEX.md)
3. [`docs/kos/zero-context-startup.md`](zero-context-startup.md)
4. [`docs/READING_MAPS.md`](../READING_MAPS.md)
5. Task-specific Assignment Record, when formal work is involved
6. Task-specific owner sources from the selected reading map
7. Applicable playbook under [`docs/playbooks/`](../playbooks/)
8. Validation and release/evidence sources only when the task route requires them

Do not start with broad repository search, historical plans, changelog archaeology or conversation memory unless the selected route requires history.

## Repository Discovery Rules

Use targeted discovery:

- Use [`KNOWLEDGE_INDEX.md`](../KNOWLEDGE_INDEX.md) for entry navigation.
- Use [`READING_MAPS.md`](../READING_MAPS.md) for task-specific required reading.
- Use [`DOCUMENTATION_GRAPH.md`](../DOCUMENTATION_GRAPH.md) when the route or Source-of-Truth relationship is unclear.
- Use [`DOCUMENTATION_GOVERNANCE.md`](../DOCUMENTATION_GOVERNANCE.md) to decide which document owns a fact.
- Use [`KNOWLEDGE_DEPENDENCIES.md`](../KNOWLEDGE_DEPENDENCIES.md) before editing documentation or navigation.
- Use `rg` or `find` to locate a named Work Item, Assignment, ADR, Registry ID or domain term after reading the navigation entrypoints.

Search results are discovery evidence, not authority by themselves. The owning document still controls the decision or fact.

## Current Work Item Discovery

To discover current work:

1. Search [`docs/assignments/`](../assignments/) for a matching Assignment Record.
2. Read the Assignment Record before treating work as authorized.
3. Read [`ENGINEERING_DASHBOARD.md`](../ENGINEERING_DASHBOARD.md) for coordination status, blockers and handoffs.
4. Follow Dashboard links back to owner sources before accepting any status as authoritative.
5. If the Work Item does not exist and the user objective authorizes governance bootstrap, create and complete the Assignment lifecycle first.
6. If no Assignment exists and the objective does not authorize governance bootstrap, stop before formal work and return the missing Assignment as a blocker.

Dashboard text never creates a Product Assignment Decision. It only summarizes owner-confirmed state.

## Current Lifecycle Discovery

Lifecycle authority comes from the task Assignment Record and [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md).

Use this rule:

```text
Assignment Record lifecycle state
  -> Assignment Policy lifecycle definition
       -> Dashboard summary only after owner-confirmed synchronization
```

If the Assignment Record and Dashboard disagree, treat the conflict as a synchronization defect. Do not resolve it by inventing a lifecycle state.

## Current Role Discovery

Role discovery has two layers:

1. Permanent ownership: [`VIRTUAL_ENGINEERING_TEAM.md`](../VIRTUAL_ENGINEERING_TEAM.md).
2. Task-level responsibility: the applicable Assignment Record under [`docs/assignments/`](../assignments/).

Permanent roles do not automatically assign a task. Assignment Records do not create or transfer permanent ownership.

If a required task field is `UNKNOWN`, the task cannot enter `Ready` or `Active`.

## Repository Truth Discovery

Repository truth follows this order:

1. Published Assignment.
2. Repository canonical documents.
3. Repository governance.
4. User-provided Mission Charter or Work Order.
5. Conversation.

When sources conflict:

1. identify the owning source in [`DOCUMENTATION_GOVERNANCE.md`](../DOCUMENTATION_GOVERNANCE.md);
2. check whether a more specific Assignment supersedes general navigation;
3. preserve `UNKNOWN`, `Blocked` or conflict state when authority is missing;
4. stop for the owning role instead of filling gaps from memory.

Conversation explains intent. Repository sources decide current authority.

## Startup Validation Procedure

Before declaring startup complete for a new session, verify:

- `AGENTS.md` was read.
- `docs/KNOWLEDGE_INDEX.md` was read.
- This startup layer was read when zero-context entry was required.
- The closest reading map was selected.
- The current Work Item was identified or its absence was handled through Assignment governance.
- Lifecycle state came from an Assignment Record or was explicitly reported missing.
- Permanent role and task-level responsibility were separated.
- Repository truth came from the owning document, not conversation memory.
- Stop Conditions were checked.
- Validation appropriate to the change type was run or skipped with a reason.

For this repository, minimum documentation validation for a Zero-Context Startup change is:

```bash
git diff --check
find docs -type f -name '*.md' -print | sort
rg -n 'KOS-BOOT-001|Zero-Context Startup|zero-context-startup' docs AGENTS.md README.md CHANGELOG.md CONTEXT_INDEX.md
```

Additional link checks may be used when available.

## Prompt Compression Strategy

Future prompts should shrink to:

1. the current user objective;
2. any external artifact paths that are not already in the repository;
3. explicit human constraints that are not represented in repository documents.

Do not paste long historical summaries when the repository contains the answer. Instead, instruct the new session to read:

```text
AGENTS.md
docs/KNOWLEDGE_INDEX.md
docs/kos/zero-context-startup.md
```

Then let the repository route the session.

Prompt compression is valid only when repository navigation is current. If startup validation fails, fix the repository route rather than expanding the prompt permanently.

## Scope Compliance

KOS-BOOT-001 publication of this startup layer did not:

- reopen KOS-GOV-001;
- change the Knowledge OS 2.0 authority model;
- change the Assignment lifecycle;
- change task levels;
- change the Repository Change Policy;
- execute Repository Migration (later completed under KOS-MIG-001);
- change Runtime, RIME, Benchmark, Registry, ADR, Template, Procedure, Task 7, production code, tests or build settings.

Later operational single-track application is recorded in [`migration-001-record.md`](migration-001-record.md).

## Related Documents

- [`KOS-BOOT-001 Assignment`](../assignments/kos-boot-001.md)
- [`KOS-MIG-001 Assignment`](../assignments/kos-mig-001.md)
- [`Knowledge OS 2.0 Specification`](knowledge-os-2.0-specification.md)
- [`Migration Readiness Assessment`](migration-readiness.md)
- [`Migration completion record`](migration-001-record.md)
- [`Knowledge OS operational entry`](../KNOWLEDGE_OS.md)
- [`Knowledge Index`](../KNOWLEDGE_INDEX.md)
- [`Reading Maps`](../READING_MAPS.md)
- [`Documentation Governance`](../DOCUMENTATION_GOVERNANCE.md)
- [`Documentation Graph`](../DOCUMENTATION_GRAPH.md)
- [`Knowledge Dependencies`](../KNOWLEDGE_DEPENDENCIES.md)
- [`Assignment Policy`](../ASSIGNMENT_POLICY.md)
- [`Virtual Engineering Team`](../VIRTUAL_ENGINEERING_TEAM.md)
- [`Engineering Dashboard`](../ENGINEERING_DASHBOARD.md)
