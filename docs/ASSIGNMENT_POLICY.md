# Universe Keyboard Assignment Policy v1.0

> **Status:** Accepted
>
> **Policy version:** `1.0.0`
>
> **Governance owner:** 🏛️ Architecture & Knowledge Steward
>
> **Assignment authority:** 🧭 Product Lead

## Purpose

This Policy defines the repository-wide contract for assigning responsibility to a specific task. It makes assignment authority, execution responsibility, dependencies, review and handoff explicit without creating new permanent roles.

Permanent roles answer who owns a capability over time. Task Assignments answer who is authorized and responsible for one bounded work item. An Assignment does not transfer permanent ownership, Product authority, Architecture authority or Quality authority.

## Scope

Use this Policy for every formal task that changes repository or external state, requires implementation or evidence, depends on a device/environment/human action, crosses a review Gate, or requires a handoff.

A simple read-only question may proceed without a separate Assignment Record when its owner, scope, authority and output are already unambiguous. If any required responsibility is unknown, disputed or externally dependent, the task must use an Assignment Record and cannot enter `Ready` until it is complete.

This Policy does not:

- create a permanent role;
- choose an assignee;
- modify a Product Contract, ADR, Quality Gate or domain ownership boundary;
- authorize destructive, external or privileged actions beyond the task's explicit scope;
- turn Dashboard status into an Assignment Decision.

## Definitions

### Permanent Role

A stable ownership boundary defined by [`VIRTUAL_ENGINEERING_TEAM.md`](VIRTUAL_ENGINEERING_TEAM.md). It is not created or transferred by a task Assignment.

### Assignment Decision

An explicit Product Lead decision naming the task-level responsibility configuration. Recommendations, inferred ownership, availability, previous work or Dashboard text are not Assignment Decisions.

### Assignment Record

The task-specific instance of this Policy. It records the current Assignment Decision, required responsibilities, lifecycle state, dependencies, Stop Conditions and handoff.

### Domain Owner

The single primary long-term owner accountable for domain correctness, boundaries and domain evidence. Secondary domains may be consulted without becoming co-owners.

### Executor

The person or agent authorized to perform the task's in-scope work. The Executor may be the Domain Owner, but execution does not grant Product, Architecture or Quality authority.

### Environment Executor

A task-level function authorized to perform named device, build, deployment, account or environment operations. It is not a permanent role and has no authority outside those operations.

### Human Dependency

A named human-provided approval, device, credential, physical action, external access or judgment required for progress. A Human Dependency is not automatically the Domain Owner or Executor.

### Architecture Reviewer

The Architecture & Knowledge Steward, when the task requires boundary, dependency, Source-of-Truth or ADR review.

### Quality Reviewer

The reviewer independently responsible for the task's specified test, performance, device, Release or evidence conclusion.

### Product Approver

The Product Lead who owns Assignment decisions, Product Gate decisions, priority and acceptance authority.

### UNKNOWN

An explicit unresolved Assignment value. `UNKNOWN` is honest but incomplete and blocks the task from entering `Ready`.

### Not Applicable

A reviewed determination that a responsibility is unnecessary for this task. It requires a short reason and must not be used to hide an unresolved Assignment.

## Assignment Authority And Responsibility Boundary

### Product Lead

- makes, changes and revokes Assignment Decisions;
- approves Reassignment;
- decides whether a new task-level execution function is needed;
- retains Product Gate and acceptance authority.

### Program Manager / Engineering Coordinator

- checks Assignment Records for completeness, consistency, freshness and source links;
- reports `UNKNOWN`, conflict, staleness and unmet dependencies;
- keeps incomplete work out of `Ready` and escalates it to Product Lead;
- may recommend a next action but must not select, infer, replace or confirm an assignee.

### Architecture & Knowledge Steward

- owns this Policy and its Source-of-Truth boundary;
- checks whether a temporary Assignment conflicts with permanent ownership or an Accepted ADR;
- reviews architecture Stop Conditions;
- does not make Product Assignment Decisions.

### Domain Owner And Executor

- Domain Owner remains accountable for domain correctness and handoff quality;
- Executor performs only the authorized Scope and produces the required evidence;
- neither may expand Scope or fill an `UNKNOWN` responsibility without Product Lead decision.

### Environment Executor And Human Dependency

- Environment Executor performs only named environment operations and reports actual state;
- Human Dependency supplies only the named action or resource;
- unavailability blocks the dependent Entry Criterion and must not be converted into fabricated evidence.

### Quality Reviewer

- independently evaluates the specified evidence or Gate;
- does not become the implementation owner by reviewing it;
- must stop when required evidence or independence is missing.

## Required Assignment Fields

Every formal Assignment Record must contain:

| Field | Required contract |
|---|---|
| Task ID / Title | Unique work-item identity. |
| Assignment Authority | `Product Lead`; no substitute authority is permitted. |
| Decision Source / Date | Repository, issue or approved handoff reference plus date and timezone. |
| Scope | Authorized work and affected systems. |
| Non-goals | Explicitly prohibited expansion. |
| Domain Owner | One primary owner, or `UNKNOWN`. |
| Executor | Named task executor, or `UNKNOWN`. |
| Environment Executor | Named executor, justified `Not Applicable`, or `UNKNOWN`. |
| Human Dependency | Named dependency and required action, justified `Not Applicable`, or `UNKNOWN`. |
| Architecture Reviewer | Named reviewer, justified `Not Applicable`, or `UNKNOWN`. |
| Quality Reviewer | Named reviewer, justified `Not Applicable`, or `UNKNOWN`. |
| Product Approver | Product Lead identity or authoritative Product thread. |
| Required Inputs | Documents, decisions, commits, devices, environments, access and predecessor tasks. |
| Entry Criteria | Conditions required before `Ready` or `Active`. |
| Exit Criteria | Deliverables and evidence required before completion. |
| Stop Conditions | Conditions requiring stop, block or escalation. |
| Handoff Target | Named next owner/reviewer and expected handoff content. |
| Lifecycle Status | One state from the lifecycle below. |
| Revalidation Trigger | Scope, owner, environment, dependency or time condition that invalidates the Assignment. |

## Unified Assignment Contract Template

```md
# Assignment: <Task ID — Title>

Policy version: 1.0.0
Lifecycle status: Assignment Pending

## Authority

- Assignment Authority: Product Lead
- Decision Source / Date:
- Product Approver:

## Boundary

- Scope:
- Non-goals:
- Required Inputs:

## Assignment

- Domain Owner: UNKNOWN
- Executor: UNKNOWN
- Environment Executor: UNKNOWN
- Human Dependency: UNKNOWN
- Architecture Reviewer: UNKNOWN
- Quality Reviewer: UNKNOWN

## Gates

- Entry Criteria:
- Exit Criteria:
- Stop Conditions:

## Handoff

- Handoff Target: UNKNOWN
- Required Handoff Content:
- Revalidation Trigger:
```

Template values must be replaced by an explicit Assignment, justified `Not Applicable`, or retained as `UNKNOWN`. Removing a field does not make the Assignment complete.

## Assignment Lifecycle

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

Lifecycle rules:

- `Assignment Pending`: Product Lead has not completed the Assignment Decision or required fields remain `UNKNOWN`.
- `Assigned`: Product Lead has named the task responsibilities.
- `Acknowledged`: required assignees have confirmed the Scope, dependencies and ability to proceed. Acknowledgment does not create Assignment authority.
- `Ready`: Assignment is complete and all Entry Criteria are satisfied.
- `Active`: authorized work has started.
- `Completed`: Executor has delivered the required outputs; this is not Quality or Product acceptance.
- `Reviewed`: required Architecture/Quality/Product reviews have produced their own conclusions.
- `Closed`: the owning Gate has closed the task and handoff is complete.
- `Blocked`: a Stop Condition, unmet dependency or invalid Assignment prevents progress.
- `Reassigned`: Product Lead has issued a new Assignment Decision and the previous record remains in history.

## UNKNOWN Assignment Rules

- `UNKNOWN` is a valid disclosure state but never a complete Assignment.
- Any required field containing `UNKNOWN` blocks `Ready` and `Active`.
- Program Manager records the missing field, decision owner and required next action, then escalates to Product Lead.
- Program Manager, Architecture, Domain Owner, Executor and Quality Reviewer must not infer or auto-fill the missing assignee.
- Prior work, likely expertise, current availability, branch ownership or previous task ownership are not substitutes for an Assignment Decision.
- `UNKNOWN` must not be rewritten as `Not Applicable` without a reviewed reason.
- Work already in progress when a required Assignment becomes `UNKNOWN` moves to `Blocked` at the next safe boundary.

## Assignment Completeness Rules

An Assignment is complete only when:

- all required fields are present;
- each responsibility is explicitly assigned or justified `Not Applicable`;
- the Product Decision source is verifiable;
- exactly one primary Domain Owner exists;
- Executor authority covers the requested actions;
- Human and environment dependencies have owners and release conditions;
- required reviewer independence is preserved;
- Entry, Exit and Stop Conditions are executable;
- Handoff Target is named;
- no value conflicts with permanent ownership, Accepted ADRs or another current Assignment Record;
- the Assignment has not expired under its Revalidation Trigger.

Completeness is a procedural fact, not a Product Assignment Decision. Program Manager may report `Complete` or `Incomplete`; only Product Lead can decide the Assignment itself.

## Reassignment And Handoff Rules

- Only Product Lead authorizes Reassignment.
- Reassignment records the previous assignee, reason, effective date, decision source and remaining work.
- The previous record is retained; history must not be rewritten.
- Work pauses at a safe boundary until the new assignee acknowledges Scope and dependencies.
- Handoff includes current status, completed outputs, unresolved risks, evidence locations, environment state, Stop Conditions and the next required decision.
- Reassignment does not transfer permanent ownership.
- A temporary execution function that recurs frequently remains task-level until Product Lead separately reviews the organization model.

## Stop Conditions

Stop and mark the task `Blocked` when:

- Assignment Authority or Decision Source is missing;
- a required field is `UNKNOWN`;
- multiple records assign the same responsibility inconsistently;
- assignee acknowledgment, access, device, environment or Human Dependency is unavailable;
- required reviewer independence is absent;
- requested action exceeds Scope or authority;
- Assignment conflicts with permanent ownership, Product Contract or an Accepted ADR;
- destructive, external or privileged action lacks explicit authorization;
- scope, dependency, environment or Gate changes invalidate the Assignment;
- Program Manager is asked to choose or replace an assignee.

Assignment gaps return to Product Lead. Architecture conflicts return to Architecture & Knowledge Steward. Evidence or independence gaps return to Quality. No role may resolve another role's authority gap merely to advance status.

## Examples

### Device Evidence Task

- Domain Owner: RIME Platform Maintainer
- Executor: assigned evidence executor
- Environment Executor: named physical-device operator
- Human Dependency: named person providing an unlocked device and required access
- Architecture Reviewer: `Not Applicable — no architecture boundary changes`
- Quality Reviewer: Quality, Performance & Release Maintainer
- Product Approver: Product Lead

If the device operator remains `UNKNOWN`, the task stays `Assignment Pending` and cannot become `Ready`.

### Documentation-only Governance Publication

- Domain Owner: Architecture & Knowledge Steward
- Executor: Architecture & Knowledge Steward
- Environment Executor: `Not Applicable — repository documentation only`
- Human Dependency: Product Gate decision
- Architecture Reviewer: Architecture & Knowledge Steward
- Quality Reviewer: `Not Applicable — link and governance validation are publication checks`
- Product Approver: Product Lead

### Future Task-level Execution Function

A task may define a new function such as `Localization Executor` or `Security Evidence Executor` when its Scope, authority, output, Stop Conditions and Handoff are explicit. This is an Assignment field extension, not a new permanent role. Product Lead must approve its use in that task.

## Version And Change Policy

- Patch: non-semantic clarification, link or example correction.
- Minor: additive field, lifecycle state or task-level function that preserves authority boundaries.
- Major: incompatible lifecycle or authority change.

Changes that grant Assignment authority to another role, alter permanent ownership, or turn a task-level function into a permanent role require a new Product governance review before publication. This Policy remains the single Source of Truth; downstream documents link to it instead of copying its rules.

## Related Documents

- [`Virtual Engineering Team`](VIRTUAL_ENGINEERING_TEAM.md)
- [`Knowledge Index`](KNOWLEDGE_INDEX.md)
- [`Reading Maps`](READING_MAPS.md)
- [`Documentation Governance`](DOCUMENTATION_GOVERNANCE.md)
- [`Documentation Graph`](DOCUMENTATION_GRAPH.md)
- [`Knowledge Dependencies`](KNOWLEDGE_DEPENDENCIES.md)
- [`AI Workflow`](AI_WORKFLOW.md)
