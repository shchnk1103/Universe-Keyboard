# Product Decision: KEYBOARD-LAYOUT-9KEY-001 Authorization

**Decision ID:** `PD-KEYBOARD-LAYOUT-9KEY-001`
**Lifecycle status:** Recorded
**Date / timezone:** `2026-07-16 Asia/Shanghai`
**Assignment:** [`docs/assignments/keyboard-layout-9key-001.md`](../assignments/keyboard-layout-9key-001.md)
**Product plan (scope only, not authority):** [`docs/plans/keyboard-layout-9key-implementation-plan.md`](../plans/keyboard-layout-9key-implementation-plan.md)

## Authority

- **Product Approver / Decision maker:** Human Product Owner (repository Product authority for this work item)
- **Assignment Authority exercised under:** Product Lead mechanics per `docs/ASSIGNMENT_POLICY.md`, only under this Product Decision
- **Named Executor:** Grok
- **Named Architecture/Quality Reviewer for gate review:** Codex
- **Domain Owner (task Assignment):** RIME Platform Maintainer

This file is the stable, repository-verifiable Product Decision Source for KEYBOARD-LAYOUT-9KEY-001. Conversation history is not authority; this record is.

## Authorization wording (Human Product Owner)

On `2026-07-16 Asia/Shanghai`, the Human Product Owner authorized the following work package in the active product task thread:

1. Create a new feature branch.
2. Execute `docs/plans/keyboard-layout-9key-implementation-plan.md` strictly.
3. First complete Assignment and ADR work, then complete the T9 compatibility Spike.
4. Do not skip plan stop conditions.
5. After the Spike package, hand all plan Section 13 required evidence to Codex for review.

Subsequently on the same date, the Human Product Owner relayed Codex Architecture/Quality review conclusions and required Grok to amend Assignment, ADR and Spike archival before product implementation steps 3–10.

## Bound decisions

1. **Executor / reviewer:** Grok executes; Codex performs Architecture and Quality gate review for this Assignment.
2. **Spike technical direction:** after a successful Spike on pinned librime `1.16.1` with `t9_processor` removed, no librime vendor upgrade is required for V1 unless a later stop condition appears.
3. **Architecture contract:** ADR 0018, once accepted by Architecture review, is the binding contract for later implementation.
4. **Lifecycle gate:** Assignment may be prepared to `Ready` under this Decision. Moving to `Active` for product implementation steps 3–10 requires:
   - no blocking Assignment/evidence P1 findings;
   - ADR 0018 architecture acceptance (completed by Codex re-review);
   - transferable Spike evidence archive accepted;
   - explicit readiness to enter `Active` under Assignment Entry Criteria.
5. **Non-goals remain as in the plan and Assignment** (no English nine-key, no live hot-switch, no Extension deployment, no raw-digit host commit, etc.).

## Stable references

| Reference | Path or identity |
|---|---|
| Decision ID | `PD-KEYBOARD-LAYOUT-9KEY-001` |
| This record | `docs/product-decisions/KEYBOARD-LAYOUT-9KEY-001-authorization.md` |
| Assignment | `docs/assignments/keyboard-layout-9key-001.md` |
| ADR | `docs/architecture/decisions/0018-keyboard-layout-nine-key-and-t9-runtime.md` |
| First Codex review (immutable) | `docs/evidence/keyboard-layout-9key-001-codex-review.md` |
| Codex amendment re-review | `docs/evidence/keyboard-layout-9key-001-codex-rereview.md` |
| Current handoff | `docs/evidence/keyboard-layout-9key-001-codex-handoff.md` |

## Change policy

Amendments to this Product Decision require a new dated Product Decision revision or superseding Decision ID. Executors must not rewrite historical Product authorization text to match later implementation convenience.
