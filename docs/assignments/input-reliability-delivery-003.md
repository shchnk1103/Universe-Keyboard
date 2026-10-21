# Assignment: INPUT-RELIABILITY-DELIVERY-003 — T9 & Partial Commit Recovery

Policy version: 1.0.0
record_id: INPUT-RELIABILITY-DELIVERY-003

## Current Status

> **Superseded for current status:** see [PR #215 post-merge State Sync](#pr-215-post-merge-state-sync--2026-10-21) below and [`ACTIVE-WORK-STALE-FACTS-SYNC-001`](active-work-stale-facts-sync-001.md) (2026-10-21).
> PR [#215](https://github.com/shchnk1103/Universe-Keyboard/pull/215) is **merged** (`096183ca118cc40ffc16854d1a5336a42cfcbd89`). Text in this document such as "Product PR preparation and hosted CI verification", "stop for Human Merge decision" and "No ... Merge" is historical narrative as of its own date, not current truth. This note does not change the Lifecycle value.

| Field | Value |
|---|---|
| Lifecycle | Active |
| Current phase | Product PR preparation and hosted CI verification |
| Material non-claims | Human reports Claude Architecture Pass / Quality Partial / Ready for PR Preparation Yes. No Quality Pass, Merge, TestFlight or Closeout authority. R174 remains off. |
| Next handoff / decision | Push reviewed candidate, open PR to main, check actual CI, then stop for Human Merge decision |
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
Extraction source, strictly read-only: the original read-only Codex worktree identified by Human, HEAD `eedbee993f8d89cd283c1487356f27f66c5e044a` plus its uncommitted files. Handoff: external backup `input-reliability-b-001-step1-20261019T083952Z/GROK-DELIVERY-HANDOFF.md`.
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

## Product PR authorization — 2026-10-19 Asia/Shanghai

Human explicitly authorized final Git/KOS checks, normal push of the reviewed product and necessary task records, a product PR to main, actual GitHub CI observation and a report. [Publication AUTH](../authorizations/AUTH-INPUT-RELIABILITY-DELIVERY-003-PRODUCT-PR.md) supersedes the earlier local-only boundary for this slice; no new feature, production behavior, Merge, TestFlight or Closeout is authorized. [Independent review receipt](../evidence/input-reliability-delivery-003/independent-review-received.md) records Human's relay, not a newly performed review. Existing assignees and Writer remain unchanged.

The earlier implementation plan and local-only statements above describe the completed stage. This stage's exit is a published PR with actual check results and an explicit stop. Source/test hashes must remain those of product `286d3e91c0cc0e94d1d439c10d799948abcb9a1f`. Only necessary publication records and public-path sanitization may be added. Real RIME T9 recovery integration and the activated Extension's complete system interaction must be addressed before TestFlight; neither is waived by opening a PR.

## PR #215 post-merge State Sync — 2026-10-21

Late M-02 sync: written after the event, not at the time of the merge.

- **Trigger:** PR [#215](https://github.com/shchnk1103/Universe-Keyboard/pull/215) `fix(keyboard): improve T9 and partial commit recovery`; merge commit `096183ca118cc40ffc16854d1a5336a42cfcbd89`; head `2477472396d827ade9f08d88714c426da3f6d5c9` (branch `codex/input-reliability-delivery-003`); merged `2026-10-19T23:30:33Z` (`2026-10-20 07:30:33 Asia/Shanghai`) by `shchnk1103` (read-only `gh pr view 215`). The PR body states baseline `d08175b` (the PR #214 merge) and links `docs/evidence/input-reliability-delivery-003/`.
- **Current:** Batch 3 is on `main` through PR #215. This Assignment's own publication authorization excluded Merge; a Merge authorization record was not found in the repository: UNKNOWN. The merge action was performed by `shchnk1103`.
- **Residuals unchanged, none closed:** see [verification](../evidence/input-reliability-delivery-003/verification.md). Real RIME T9 recovery integration evidence and the activated Extension's complete system interaction had to be disposed of before TestFlight; whether that has happened is UNKNOWN (no record found). The PR body also states that 30 skipped tests are not passes, live-native R174 is unverified, and R174 stays off by default.
- **Review wording:** Claude Architecture Pass / Quality Partial remain Human-relayed results (see the [receipt](../evidence/input-reliability-delivery-003/independent-review-received.md)); Quality Partial is not raised to Pass here.
- **Final Merge Gate / Authority record for the merge:** UNKNOWN (none found in the repository).
- **Lifecycle:** this file still reads `Active`; not changed here, needs a separate Human decision.
- **Non-claims:** not Release; no TestFlight, no Closeout; no residual weakened or closed.
