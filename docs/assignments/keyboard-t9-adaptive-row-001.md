# Assignment: KEYBOARD-T9-ADAPTIVE-ROW-001

Policy version: 1.0.0
record_id: KEYBOARD-T9-ADAPTIVE-ROW-001

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Active |
| Current phase | QA-001 local diagnosis and minimal remediation |
| Non-claims | Human-relayed Claude Conditional review; no real Extension/Product Gate, Ready, Merge, TestFlight or Close |
| Next | Human/Claude independent review of local integration candidate; no publication |
| Residuals | [Current Sticky verification](../evidence/keyboard-t9-adaptive-row-001/sticky-verification.md); real host geometry and interaction remain Human Gate |

Historical pre-integration Sticky correction evidence: L1 5/0/0, L2 Keyboard49/0/0 + Extension35/0/0, Debug build-for-testing and strict format8 passed. Real host evidence is pending; no Gate/Close. Writer remains codex-t9-adaptive-row, P=none.

## Authority and responsibility

Assignment Authority / Product Approver: Human Product Lead, current chat, 2026-10-20 Asia/Shanghai, “UI-2 Adaptive T9 Pinyin Row — Bounded Implementation Authorization”. [AUTH](../authorizations/AUTH-KEYBOARD-T9-ADAPTIVE-ROW-001.md).
Domain Owner: Keyboard UI. Executor / initial Writer: current Codex lane `codex-t9-adaptive-row`. Environment Executor: same Codex, independent build/test directories and task-owned Simulator only. Human Dependency: Human Product Lead for real host acceptance and later publication. Architecture / Quality Reviewer: subsequent independent Claude review, not an implementation dependency or assigned active lane. Handoff Target: Human Product Lead; review candidate intended for Claude. Permanent ownership unchanged.

## Task Workspace

Explicit opt-in to Kit `ops/task-workspace.md` at `9ca6dc015bf01084150538aac65cedc25b2a33a5`, sha256 `91d3da26728c210de3b605f28f65e0377f9ee90b2f0eaf65c8e12b7f8cb5f76a`, under UK-007; F-01/L-01 not adopted. Human named this lane initial Writer. No predecessor, no pending P, no fabricated HANDOFF/ACCEPT. Initial CHECKPOINT establishes W.
Carrier / product branch: `codex/keyboard-t9-adaptive-row-001`; worktree `t9-adaptive-row-001`. Only initial docs-only records may sync. Every product descendant stays local.

## Scope and protected boundaries

Historical initial scope (superseded only by the controlled integration authorization below): freshly fetched origin/main `096183ca118cc40ffc16854d1a5336a42cfcbd89`. No UI-1 commits. Main candidate container48pt = visual34 + gesture14; do not change candidates/actions/blur/cells.
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

## Current policy correction — 2026-10-20

Human explicitly supersedes per-composition collapse with per-presentation Sticky Expansion. Existing initial Writer codex-t9-adaptive-row remains W, P=none. Prior local candidate5cc4a74/checkpoint2b59617 retained. Plan: inspect existing lifecycle; add minimal UI latch with conservative reset; update real Controller L1; run affected L2/Debug build-for-testing/strict format; local commit/checkpoint then stop. Existing scope protections and stop conditions remain. Completed disappearance + existing hidden gate + detached view is a conservative boundary candidate; host lifecycle coverage is not proven by in-process fixtures. Ordinary appear/reload/document/page/layout events alone never reset. No new task/Writer/remote publication.

## Draft PR publication authorization — 2026-10-20

Human authorizes normal product push, one Draft PR to main and existing CI observation. [Publication AUTH](../authorizations/AUTH-KEYBOARD-T9-ADAPTIVE-ROW-001-DRAFT-PR.md) supersedes prior local-only frontier for this slice only; no further product edits or automatic CI fixes. [Human review relay](../evidence/keyboard-t9-adaptive-row-001/review-received.md): Sticky Pass, Lifecycle/Architecture/Quality Conditional, no reported code blocker. Runtime Gate remains pending. Baseline/source hash/Writer checks passed; no rebase/UI-1 integration/Close. Carrier and all history retained. Stop after results.

Publication completed: [Draft217 and exact-head CI receipt](../evidence/keyboard-t9-adaptive-row-001/draft-publication.md). All9 jobs successful; Runtime Gate remains pending. Final CI receipt/checkpoint intentionally local-only; published head6f6fc12 retained. Stop for Human, no further external action.

## Controlled local integration — 2026-10-20

Human authorizes [bounded local integration](../authorizations/AUTH-KEYBOARD-T9-ADAPTIVE-ROW-001-INTEGRATION.md) of exact main78b795f. Same Writer, task, worktree and existing two local docs retained. CI attempt2/Xcode Cloud pass; suspected historical diagnostic-test flake preserved and excluded from fixes. Resolve only I-1–I-5 and test I-6/I-7; minimal product fix only on reproduced layout-integration cause. Target contract candidate46/Path0→34Sticky/root254→288. No pushes/PR updates/main actions. Retired UI-1 worktree/Human project edits are not inputs.

本地集成完成：[集成证据](../evidence/keyboard-t9-adaptive-row-001/integration-verification.md)。Controller17、Keyboard49、Extension41均通过，Debug build-for-testing及格式通过；真实Extension未验证。等待独立复核，禁止外部发布。

## QA-001 Human device finding

[Current bounded AUTH](../authorizations/AUTH-KEYBOARD-T9-ADAPTIVE-ROW-001-QA001.md). Human011d3fa two rounds8 PASS/1 FAIL; first input following punctuation/kaomoji expansion leaves blank Path until next key, which includes both inputs. Root cause unconfirmed at entry; no input-loss/Core claim. Same Writer/P=none; local only, then independent re-review and Human retest.
