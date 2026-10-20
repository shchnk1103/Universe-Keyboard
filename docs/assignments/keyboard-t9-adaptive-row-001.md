# Assignment: KEYBOARD-T9-ADAPTIVE-ROW-001

Policy version: 1.0.0
record_id: KEYBOARD-T9-ADAPTIVE-ROW-001

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Active |
| Current phase | Bounded UIKit implementation and L1/L2 validation |
| Non-claims | No independent review, real Extension validation, Product Gate, product push, PR, Merge or TestFlight |
| Next | Local review candidate to Human; intended independent Claude review |
| Residuals | Real host geometry and interaction remain Human Gate |

## Authority and responsibility

Assignment Authority / Product Approver: Human Product Lead, current chat, 2026-10-20 Asia/Shanghai, “UI-2 Adaptive T9 Pinyin Row — Bounded Implementation Authorization”. [AUTH](../authorizations/AUTH-KEYBOARD-T9-ADAPTIVE-ROW-001.md).
Domain Owner: Keyboard UI. Executor / initial Writer: current Codex lane `codex-t9-adaptive-row`. Environment Executor: same Codex, independent build/test directories and task-owned Simulator only. Human Dependency: Human Product Lead for real host acceptance and later publication. Architecture / Quality Reviewer: subsequent independent Claude review, not an implementation dependency or assigned active lane. Handoff Target: Human Product Lead; review candidate intended for Claude. Permanent ownership unchanged.

## Task Workspace

Explicit opt-in to Kit `ops/task-workspace.md` at `9ca6dc015bf01084150538aac65cedc25b2a33a5`, sha256 `91d3da26728c210de3b605f28f65e0377f9ee90b2f0eaf65c8e12b7f8cb5f76a`, under UK-007; F-01/L-01 not adopted. Human named this lane initial Writer. No predecessor, no pending P, no fabricated HANDOFF/ACCEPT. Initial CHECKPOINT establishes W.
Carrier / product branch: `codex/keyboard-t9-adaptive-row-001`; worktree `t9-adaptive-row-001`. Only initial docs-only records may sync. Every product descendant stays local.

## Scope and protected boundaries

Baseline: freshly fetched origin/main `096183ca118cc40ffc16854d1a5336a42cfcbd89`. No UI-1 commits. Main candidate container48pt = visual34 + gesture14; do not change candidates/actions/blur/cells.
Implement Chinese nine-key letters Path row true0/34pt from existing composition snapshot/state. Preserve temporary-empty composition, Recovery/Disabled safety, selection and expanded panels. Reuse750 root mechanism; no allowsSelfSizing or second height system. Allowed: small UIKit controller/view edits, focused tests and necessary test-target wiring, directly affected docs and evidence.
Forbidden: Core/session/authority/origin/native select/owner/epoch/revision/R174 semantics; RIME deploy/reset to change height; UI-1 PR216/worktree, shared/main/historical workspaces; product push/PR/merge/TestFlight/cleanup.

## Stage plan

1. Initialize Assignment/AUTH then BRIEF+append-only log CHECKPOINT; verify docs-only allowlist and sync carrier before product writes.
2. Implement local UIKit presentation only; inspect available signals, use conservative visibility where state is uncertain. Do not create a second input state machine.
3. L1 state/geometry/Recovery/expanded checks using production Controller; L2 KeyboardTests, KeyboardExtensionTests, real Controller integration, Debug build-for-testing and strict format. No full Core/App/Bridge or L3. Real activated Extension may remain pending; no prolonged GUI attempts.
4. Local product commit, verification evidence and final checkpoint; stop for Human. No HANDOFF unless separately authorized.

Entry: current Human authorization, exact baseline, independent worktree, adopted contract verified, initial W established before code edits.
Exit: auditable local implementation candidate and exact L1/L2 outcomes, or bounded blocker. Real Extension absence does not block local candidate completion.
Stop: Core semantics needed, weakened Recovery/authority, unexplained required-constraint conflict, unsafe750 reuse, key compression, large root refactor, definite input-loss/wrong-selection risk, UI-1 impact, Writer conflict or invalid authority.
Revalidation: baseline/scope/owner/contract changes, AUTH revocation, new Writer. Material changes return to Human.

Current Codex acknowledges this bounded assignment. No independent reviewer or Product acceptance conclusion is asserted.
