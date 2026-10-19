# Assignment: INPUT-RELIABILITY-DELIVERY-003 — T9 & Partial Commit Recovery

Policy version: 1.0.0
record_id: INPUT-RELIABILITY-DELIVERY-003

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Active |
| Current phase | Local candidate ready for independent review |
| Material non-claims | No independent Review, merge readiness, Product Gate or Release claimed. R174 remains off in normal builds. No product push, PR, merge or TestFlight authorization. |
| Next handoff / decision | Local candidate to Human for Claude independent Architecture / Quality Review |
| Residuals | [Verification and evidence gaps](../evidence/input-reliability-delivery-003/verification.md); no Closeout in this phase. |

## Authority

Assignment Authority / Product Approver: Human Product Lead, current Codex chat, 2026-10-19 Asia/Shanghai, “Human Authorization — Batch 3 Implementation”.
Authorization: [AUTH](../authorizations/AUTH-INPUT-RELIABILITY-DELIVERY-003.md).

## Task Workspace

Explicit opt-in: `ops/task-workspace.md`, Kit commit `9ca6dc015bf01084150538aac65cedc25b2a33a5`, sha256 `91d3da26728c210de3b605f28f65e0377f9ee90b2f0eaf65c8e12b7f8cb5f76a`, under UK-007. No F-01/L-01 adoption or historical task migration.
Human named the current Codex session initial Writer, lane `codex-batch3`. No predecessor Writer or pending HANDOFF exists. First CHECKPOINT establishes W; no HANDOFF or ACCEPT is fabricated.
Carrier: `codex/input-reliability-delivery-003`. Keep its continuity history separate from any future squash-merged product history; no cleanup authorized.

## Responsibility

- Domain Owner: Keyboard input runtime (Core state and Extension recovery integration), performed by the named Codex executor within this bounded task; permanent ownership unchanged.
- Executor / initial Writer: current Codex session, lane `codex-batch3`.
- Environment Executor: current Codex session on this Mac, scoped builds/tests and an isolated simulator; no shared device reset or cleanup.
- Human Dependency: Human Product Lead for later product publication, Product acceptance and any scope change.
- Architecture Reviewer: Claude, subsequent independent read-only review; not a current implementation dependency.
- Quality Reviewer: Claude, subsequent independent read-only review; no implementation participation.
- Product Approver / Handoff Target: Human Product Lead; review candidate intended for Claude.

## Scope and inputs

Baseline: actual fetched `origin/main` `d08175b915aee40998398d7fdc03f2fd7cf0833f`, containing Batch 1 `bb430f914deaf7b19a61183f744b5dcf2fdb8eae` and Batch 2 `d08175b915aee40998398d7fdc03f2fd7cf0833f`.
Extraction source, strictly read-only: `/Users/doubleshy0n/.codex/worktrees/input-reliability-main-20261012/Universe Keyboard`, HEAD `eedbee993f8d89cd283c1487356f27f66c5e044a` plus its uncommitted files. Handoff: external backup `input-reliability-b-001-step1-20261019T083952Z/GROK-DELIVERY-HANDOFF.md`.
Scope: T9 short-delete history/retype/state consistency; failed Partial Commit checkpoint protection; R174 implementation/tests with normal-build default off; Core and Extension recovery rejection, candidate/paging/Path invalidation and notices; directly related Return/space/symbol/emoji finalization/cancellation. Extract shared files by hunk, preserve all merged identity/authority protections.
Non-goals: reimplement Batch 1/2; R345/R349 investigation; Build 94; C/D phases; deployment lifecycle changes; R174 user/persistent/TestFlight switch; changes to source/other/main worktrees or backups; large test framework; product publication or Closeout.

## Stage plan / gates

1. Initialize Assignment/AUTH, then initial BRIEF + CHECKPOINT and docs-only carrier sync. Verify W/P/H/S and current authority before product writes.
2. Extract only Batch 3 hunks and directly related tests into the new worktree; record paths/source hashes and adaptations. Keep Batch 2 native-origin rejection intact.
3. Bounded integration fixes and validation: strict Swift format; full KeyboardCore; RimeBridge relevant/full; App + Keyboard; Debug build-for-testing; Release build; directed UIKit behavior. Distinguish pass/skip/not-run/blocker, R174 normal off/test opt-in, and fixture/native/Extension evidence.
4. Local product commit after format/checks. Final local CHECKPOINT and evidence; stop for Human/Claude. Do not push any descendant containing product changes.

Entry: Human authorization and roles above, exact fetched baseline, independent clean worktree, accessible read-only source, exact adopted contract verified. Initial Writer must be established before stage 2.
Exit: auditable local candidate commits, exact checks and UI coverage/gaps recorded; or accurately marked WIP/blocker without merge claim.
Stop: weakening Batch 2; source worktree writes; normal R174 enablement; production deploy changes; unbounded hard dependency; unexplained wrong-host write, duplicate commit, wrong selection or data loss; nonunique/invalid Writer; inability to finish a critical validation.
Revalidation: baseline/contract/scope/owner changes, second Writer, AUTH revocation; stop and return to Human for substantive boundary changes.

## Acknowledgment

Current Codex session acknowledges scope, read-only extraction source, access and stop boundaries. Implementation is authorized; independent Claude review and Product publication remain separate stages.
