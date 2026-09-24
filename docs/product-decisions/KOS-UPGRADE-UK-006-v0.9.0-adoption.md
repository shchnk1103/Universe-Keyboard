# Product Decision: KOS-UPGRADE-UK-006 — 前瞻采用 KOS Agent Kit v0.9.0

## Current Status

| Field | Value |
|---|---|
| Status | Accepted |
| Decision | Adopt KOS Kit v0.9.0 in advisory mode, with the bounded prospective scope below |
| Effective date | 2026-09-25 Asia/Shanghai |
| Non-claims | No required-mode change, historical migration, Active-Assignment backfill, global orchestration-plan requirement, commit, push, PR, merge, tag or Release authorization |

---

Human Product Owner, current session, 2026-09-25 Asia/Shanghai: “决定前瞻性采用”。

## Decision

Universe Keyboard adopts KOS Agent Kit v0.9.0 at commit
c98b2813240e22b2ac7fec44b2445321b03f73e0 in **advisory** mode. The upstream
annotated tag object is 4a386cdc07cc52a3da4d7cf77b429b874169becb. The
independent Quality Round 3 receipt verified the exact latest Release response:
v0.9.0, published 2026-09-24T15:42:53Z.

This is a selective, prospective adoption of the following operational rules:

1. **M-02 trigger identity and non-recursive closeout.** Every M-02 trigger
   occurring on or after the effective date has a stable identity comprising
   the Work Item, exact event and authority record; a merge trigger also names
   the merged tip PR and commit. One closeout transaction records the final
   state for that trigger and cannot recursively trigger itself. A later,
   independently occurring event is a new trigger. This rule applies to
   future triggers, including on work that remains Active; it does not reopen
   or rewrite historical closeouts.

2. **Reviewer scope, budget and stop clauses for newly assigned independent
   review lanes.** Every independent reviewer lane first assigned on or after
   the effective date receives a frozen packet with its Work Item, stable lane
   ID, positive review round, exact baseline and packet digest, decision
   question/claims, allowed inputs and exclusions, read/write/tool/access/data
   boundaries, required outputs, positive and complete-coverage criteria,
   budget/checkpoints/exhaustion behavior, and stop conditions plus the named
   authority allowed to expand scope or budget. This applies to a newly
   assigned lane even when its parent Work Item began earlier. Already
   assigned lanes retain their frozen Assignment and packet; this decision
   does not migrate them. A reviewer or Coordinator cannot approve its own
   expansion. An uncovered claim or exhausted budget is Partial / incomplete,
   never Pass.

This does **not** adopt the full optional agent-orchestration package. Provider
routing, model-capability policy, replacement/lane-lifecycle rules and a
global ORCHESTRATION_PLAN are not adopted or required. The ordinary delegation
guidance remains in AI_WORKFLOW.md; the new lane contract is recorded in
ASSIGNMENT_POLICY.md.

## Existing contract and governance boundaries

- The project pin in .kos/project.json and docs/kos/UPGRADE_STATUS.md is
  updated to the released v0.9.0 commit.
- Record-envelope mode remains **advisory** and supported schema remains 1.0.
  No required-mode cutover is authorized.
- KOS 2.0 core, validator, Product/Architecture/Quality authority and Gate
  boundaries do not change.
- UK-005's adopted kos.release-evidence v1.0 contract, exact source bytes,
  Profile, implementation and prior review conclusions remain unchanged.
  The v0.9.0 release contains byte-identical contract, schema and evaluator
  files; it is not a second adoption or a new UK-005 review. The UK-005
  Profile's Project pin field is retained as the v0.8.0 adoption-time snapshot;
  the current project pin remains sourced from [UPGRADE_STATUS](../kos/UPGRADE_STATUS.md).
- Existing Active Assignments and already assigned reviewer lanes are not
  migrated or backfilled.
- v0.9.0 does not address Simulator/CoreDevice discovery or Device Hub and
  Accessibility health classification. Those remain separate project work.

## Review basis

- [KOS-UPGRADE-UK-006 review Assignment](../assignments/kos-upgrade-uk-006-v0.9.0.md)
- [Round 2 applicability assessment](../kos/upgrade-records/KOS-UPGRADE-UK-006-v0.9.0-round-2.md)
- [Frozen Round 2 source map](../evidence/kos-upgrade-uk-006-v0.9.0-round-2-source-freeze-2026-09-25.md)
- [Architecture Round 2 receipt](../reviews/KOS-UPGRADE-UK-006-v0.9.0-architecture-r2-review.md): Pass
- [Quality Round 3 receipt](../reviews/KOS-UPGRADE-UK-006-v0.9.0-quality-r3-review.md): Pass

These reviews support the Product disposition; neither review itself made the
adoption decision.

## Non-goals and separate authority

This decision does not change app/runtime code, CI, devices, simulators,
CoreDevice, Device Hub, Accessibility Inspector, XCTest or XCUITest behavior.
It does not authorize commit, push, PR creation, merge, tag, external
publication or Release. Any publication action requires its own explicit
authorization under the repository rules.

Reopen this decision if the selected v0.9.0 clauses, their effective boundary,
KOS 2.0/schema/validator, UK-005's exact contract/Profile, or the requested
migration/required/publication scope changes.
