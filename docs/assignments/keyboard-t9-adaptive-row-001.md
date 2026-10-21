# Assignment: KEYBOARD-T9-ADAPTIVE-ROW-001

Policy version: 1.0.0
record_id: KEYBOARD-T9-ADAPTIVE-ROW-001

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Active |
| Current phase | QA-001 FORMALLY CLOSED by Human; UI-2 feature remains Active, publication gated |
| Non-claims | QA-001-only closure; Quality remains CONDITIONAL PASS as relayed; no whole-feature/task close, PR update, Merge or Release |
| Next | Stop; await separate Human authorization before PR217 update or any publication; retain worktree and Human files |
| Residuals | R-QA001-GOV-01 / Q-01 / Q-02 / Q-03 retained: accept, non-blocking for QA-001 only; [register](../evidence/keyboard-t9-adaptive-row-001/formal-closure-20261021/residuals.md) |
| QA-001 defect status | CLOSED; [Human formal decision](../evidence/keyboard-t9-adaptive-row-001/formal-closure-20261021/human-decision.md) |
| QA-001 Quality Closure | SUPPORTED; Human-relayed independent Quality Sufficiency CONDITIONAL PASS, not an original Reviewer Artifact |

以下 dated 阶段均为历史记录；其中 device pending / OPEN / CLOSURE BLOCKED / HUMAN DECISION REQUIRED 及 unsigned proposal 由文末本次明确 Human 正式决定更新。历史负证据、流程偏差和原件缺失不回写；仅 QA-001 关闭，整个 UI-2 Assignment 保持 Active。

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

QA-001诊断结果：[报告](../evidence/keyboard-t9-adaptive-row-001/qa001-diagnosis.md)。同步边界8序列首键正确、108项定向测试通过，但未复现native空白、根因未知、未改产品源码。Human FAIL保持OPEN；Implementation BLOCK / Validation CONDITIONAL PASS / INSUFFICIENT EVIDENCE。等待Human/Claude决定设备诊断安排，禁止发布。

## Device trace preparation

[Current AUTH](../authorizations/AUTH-KEYBOARD-T9-ADAPTIVE-ROW-001-DEVICE-TRACE.md) permits only DEBUG memory diagnostics, local validation/commits and shortest Human instructions. QA-001 OPEN/MAJOR; no root-cause fix or real-device PASS claim.

Device trace prepared：[操作单](../evidence/keyboard-t9-adaptive-row-001/device-trace-runbook.md)、[本地证据](../evidence/keyboard-t9-adaptive-row-001/device-trace-verification.md)。仅DEBUG内存诊断，QA-001仍OPEN/MAJOR，无根因修复/真机PASS。Human工程文件原样保留、不提交。等待Human采集。

## Human device acceptance and closure preparation — 2026-10-21

Human current-chat authorization permits Assignment/Evidence updates, exact-head Keyboard/Extension/UI-2 regression and local docs commits only. Writer remains codex-t9-adaptive-row; no reassignment or fabricated handoff/checkpoint. Tested product HEAD f610763df0cc12e89d0a8cd8c3b90197ced2d88b; product sources unchanged during this slice.

[Human receipt](../evidence/keyboard-t9-adaptive-row-001/acceptance-20261021/human-acceptance.md): DSON13Pro7/7 PASS (punctuation/kaomoji first path, subsequent/fast input, delete/Sticky/reset, wake/layout/rotation, masks/touch/reading). Human also relays Claude Architecture PASS, Quality CONDITIONAL PASS, Finding A CLOSED. These are Human-supplied acceptance/review records, not Codex device execution or a new independent review.

[Fresh regression and closure report](../evidence/keyboard-t9-adaptive-row-001/acceptance-20261021/closure-report.md): Keyboard49 + Extension41 + Controller21 =111 PASS/0FAIL/0SKIP, exit0, Debug test build success. Product/device validation is satisfied for the stated scope; no new code blocker. Prior HumanFAIL/raw traces remain historical evidence, not overwritten.

[Reviewer Lane Packet audit](../evidence/keyboard-t9-adaptive-row-001/acceptance-20261021/review-packet-audit.md) discloses absent local proof of historical lane ID/round/pre-dispatch freeze/digest/budget/preflight; lane first-assignment/possible grandfathering not established. No backdated packet or approval created. Human Product Lead/Coordinator owns applicability/disposition and remainingQuality conditional clarification. QA-001 formal closure recommendation: CLOSURE BLOCKED by this governance disposition, not by a device or local test failure. Lifecycle remains Active (closure preparation); no task close, publication or release authority inferred.

Human project.pbxproj and existing Scheme remain dirty/unmodified/not staged. No production/test/Signing edits, other worktree changes, push/PR217 update/merge/release or cleanup. Task BRIEF/log CP-012 kept historical under this slice's Assignment/Evidence-only allowlist; current authority is this Assignment plus latest Human instruction. Next: Human disposition and separately authorized PR preparation with exact-base/head/clean-checkout/CI gates.

## Governance policy check — 2026-10-21

Human 本轮仅授权 Policy 核查、本 Assignment / Evidence 更新及本地文档提交，不含 Policy、源码、测试、工程、Scheme 或外部操作。入口 `10b277461f238815e08c1fb5d6d1bf4ccf93547d`；已验收产品 `f610763` 未变。Human 7/7、Executor 111/0/0，以及 Human 转述的 Claude Architecture PASS / Quality CONDITIONAL PASS / Finding A CLOSED 均已核对。证据哈希有效，本轮无需且未重新测试。

[Policy 核查](../evidence/keyboard-t9-adaptive-row-001/governance-check-20261021/policy-check.md)：适用的 Reviewer Packet 必须事前冻结；未找到专门的追溯 Packet 豁免或自动全部重审条款。M-03 允许明确 non-blocking 的 residual accept，但不能据此补造完整覆盖或历史合规。证据缺口归 Quality 判断，Product Lead 拥有 Assignment / Product 验收权；Coordinator 不拥有独立豁免或 Quality 签核权。本段澄清上轮“Human/Coordinator 处置”的泛称，不回写历史收据。

`R-QA001-GOV-01` 仍 Pending：历史 Packet / lane 首次指派证据本地不可核验，需明确 Quality 的完整覆盖及剩余条件、M-03 处置。[待确认决定](../evidence/keyboard-t9-adaptive-row-001/governance-check-20261021/proposed-decision.md) 中的 accept 尚未生效或签署；它只是本任务限定、不构成先例、不倒填的未来选项，不是已经执行的例外。若证据不足，可由 Human 另授权有真实事前 Packet 的有界 Quality 补充复核，不默认重跑全部测试。

当前结论 **HUMAN DECISION REQUIRED**；QA-001 正式关闭仍 BLOCKED，技术和设备验收仍 PASS。Task Lifecycle 保持 Active / closure preparation，未写 QA 或任务 Closed。两个 Human dirty 文件原样保留且不暂存；没有新 Writer、Policy 修改、追溯 Packet、审批补造、Push、PR、Merge、Release 或 Worktree 清理。完成后停止，等待 Human 及相应 Quality 处置。

## QA-001 formal defect closure — 2026-10-21

**QA-001 FORMALLY CLOSED — Closure Scope: QA-001 defect only.** Human 本次明确接受四项 non-blocking residual 并批准正式关闭，完整原文见[Human Decision](../evidence/keyboard-t9-adaptive-row-001/formal-closure-20261021/human-decision.md)。这是当前真实授权，不是追溯Packet或历史审批，不修改KOS Policy、不代替Quality签核。

技术证据：Human DSON13Pro7/7 PASS（Device-attested）；Keyboard49 + Extension41 + Integration21 =111/0/0，exit0（Executor-recorded）；Finding A CLOSED、Architecture PASS均为既有Human转述。本次Human另外转述独立Claude Quality Sufficiency CONDITIONAL PASS / QA-001 Quality Closure SUPPORTED / Historical Packet Residual NON-BLOCKING CANDIDATE；原件未归档，不伪装原始Artifact。源码从f271f68后未变，等同Human验收f610763；本轮只核验既有证据，不重跑测试。

| Residual ID | Owner | Disposition at QA-001 close | Evidence Pointer |
|---|---|---|---|
| R-QA001-GOV-01 | Human Product Owner | `accept` — NON-BLOCKING FOR QA-001 ONLY | [历史Packet流程偏差及新一轮未冻结记录](../evidence/keyboard-t9-adaptive-row-001/formal-closure-20261021/residuals.md#r-qa001-gov-01) |
| R-QA001-Q-01 | Human Product Owner (Residual Acceptance) | `accept` — NON-BLOCKING FOR QA-001 ONLY | [UIKit内部根因不确定性](../evidence/keyboard-t9-adaptive-row-001/formal-closure-20261021/residuals.md#r-qa001-q-01) |
| R-QA001-Q-02 | Human Product Owner (Residual Acceptance) | `accept` — NON-BLOCKING FOR QA-001 ONLY | [Human设备证据范围及原始trace/录像缺失](../evidence/keyboard-t9-adaptive-row-001/formal-closure-20261021/residuals.md#r-qa001-q-02) |
| R-QA001-Q-03 | Human Product Owner (Residual Acceptance) | `accept` — NON-BLOCKING FOR QA-001 ONLY | [Review原件及条件清单来源限制](../evidence/keyboard-t9-adaptive-row-001/formal-closure-20261021/residuals.md#r-qa001-q-03) |

四项均在close保留，不倒填历史、不声称历史Review流程合规，不构成未来省略Packet的先例。Owner仅接受Residual，不替代独立Architecture/Quality职责。原始FAIL、Blocked报告与unsigned提案继续作为历史证据。[关闭报告](../evidence/keyboard-t9-adaptive-row-001/formal-closure-20261021/closure.md)列明哈希、证据来源、监控/重开条件和发布边界。

本任务Lifecycle仍为Active（UI-2 feature），未关闭整个Assignment或Feature/Release Gate。PR217、Merge、Release状态不变；未来更新需单独Human授权及远端基线/提交链/精确HEAD CI核验。Human project.pbxproj/Scheme前后哈希一致，均未修改/暂存/提交。只更新本Assignment及Evidence，创建一个本地docs-only提交；不触碰其他Worktree、不清理。当前会话可由Human归档，但Worktree/分支/未发布提交/Human dirty现场必须保留。完成后停止。
