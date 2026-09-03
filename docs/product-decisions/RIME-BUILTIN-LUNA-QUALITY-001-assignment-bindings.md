# Product Decision: RIME-BUILTIN-LUNA-QUALITY-001 — Assignment Bindings

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "PD-RIME-BUILTIN-LUNA-QUALITY-001-ASSIGNMENT",
  "record_type": "decision",
  "title": "Bind F-02 implementation and review responsibilities",
  "status": "accepted",
  "updated_at": "2026-08-29T20:21:43+08:00",
  "revalidation_triggers": [
    "assignment_scope_changed",
    "executor_unavailable",
    "review_independence_unavailable",
    "environment_matrix_changed"
  ],
  "parent_refs": ["RIME-BUILTIN-LUNA-QUALITY-001"],
  "decision": {
    "authority_role": "Human Product Owner",
    "decision_source": "in-session 2026-08-29 Asia/Shanghai approval of the recommended responsibility configuration",
    "scope": "Bind the task-level Domain Owner, Executor, Environment Executor and independent reviewers",
    "outcome": "RIME Platform Maintainer owns the domain; the current Codex task executes the bounded work and local/simulator environment operations; Architecture and Quality retain independent review; the Human Product Owner operates the named physical device and owns Product Gate",
    "expires_at": null
  }
}
```

- **Decision ID:** `PD-RIME-BUILTIN-LUNA-QUALITY-001-ASSIGNMENT`
- **Lifecycle status:** `Accepted`
- **Date / timezone:** `2026-08-29 Asia/Shanghai`
- **Authority:** Human Product Owner acting as Product Lead

## Bindings

| Responsibility | Binding | Boundary |
|---|---|---|
| Domain Owner | RIME Platform Maintainer | Owns schema/resource compilation, OpenCC and generated artifact correctness |
| Executor | Current Codex task on `codex/f02-rime-builtin-quality-assignment`, operating under the RIME Platform Maintainer playbook | May perform only the Assignment scope; no PR #91, merge or Release action |
| Environment Executor | Current Codex task on the isolated F-02 worktree | Owns isolated repository fixtures, local builds and Simulator evidence only |
| Human Dependency | Human Product Owner | Performs named physical-device actions and makes the final Human Product Gate decision |
| Architecture Reviewer | Architecture & Knowledge Steward | Independently reviews dependency closure, App/Extension ownership, Source of Truth and ADR compatibility |
| Quality Reviewer | Quality, Performance & Release Maintainer | Independently reviews fixtures, candidate quality, offline deployment, performance and device evidence |
| Product Approver | Human Product Owner acting as Product Lead | Retains priority, scope, risk acceptance and Product Gate authority |

The implementation Executor cannot self-issue either independent review. A
separate review execution must produce the Architecture and Quality records
before the corresponding Gates can pass.

App & Data Operations Maintainer is a consulted secondary role for main-App
bundle membership and deployment orchestration. This consultation does not
split or transfer the RIME Platform Maintainer's primary domain ownership.

## Authorization Boundary

This decision authorizes Assignment completion and the bounded read-only work
needed to propose immutable upstream revisions, licenses and an exact resource
manifest. It does not yet authorize implementation code or asset changes.
