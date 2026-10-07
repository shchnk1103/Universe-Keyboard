# Reading Maps

2026-10-06 当前：三件 keyboard-wake Assignment **Closed**。[Close](product-decisions/KEYBOARD-WAKE-BOUNDED-CLOSE-001-product-decision-2026-10-06.md) · [记录](evidence/keyboard-wake-bounded-close-001-2026-10-06.md)。隔离 worktree KEEP。无 TestFlight / Release。

2026-10-06 当前：PR [#198](https://github.com/shchnk1103/Universe-Keyboard/pull/198) 已 squash-merge `4b102a9f33e1535da6be23280e912a84d2766c3c`。[M-02](evidence/keyboard-wake-bounded-publication-001-post-merge-state-sync-2026-10-06.md)。无 TestFlight / Release。

2026-10-06 当前：[Git 发布草稿 PR #198](https://github.com/shchnk1103/Universe-Keyboard/pull/198)隔离分支已 push；Human 观察 CI；无 merge。

2026-10-06 当前：[Git 发布 COMMIT](authorizations/AUTH-KEYBOARD-WAKE-BOUNDED-PUBLICATION-001-COMMIT.md)隔离分支 scoped commit `247c6aad3619d8e2f807a864ef3dbe0e9a60e185`。PUSH-PR 未消费；无 merge。

2026-10-06 当前：[paired-rollout有界完成](evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-bounded-completion-2026-10-06.md)Human批准选项A，Completed为诊断producer与父交接交付；R-JSONL/R-V6/R-COV/R-AUDIT/R-SKIP非阻塞未验证，独立Partial保留。键盘唤醒三件任务均有界Completed。

2026-10-06 当前：[paired-rollout Exit对照准备稿](evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-jsonl-parent-exit-map-2026-10-06.md)父JSONL映射已由父历史Exit图+PEXIT-R1完成；子诊断交接已交付。全局v6 emission/已审查v6 Maps未满足，E1不并入。Assignment仍Active，有界收尾待Product。

2026-10-03 当前：[M2停止Incomplete](evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m2-baseline-stop-validation-2026-10-03.md)：基线多次按键未更新，freeze卡前出口hit1，触发未知；0read，11calls账本、cleanup与视觉Exit齐。未执行目标AppSwitcher配对，不判owner为空；下一建议只读核提前出口绑定，未授权新实例/重试。


2026-10-03 当前：[M1限定核验完成](evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m1-validation-2026-10-03.md)：Human补确认26键/空候选/观测/未点击未输入，机器新3626身份与保护齐。M2单轮取证待明确授权及fresh Entry，尚无LLDB或输入，父子Active。


2026-10-03 当前：[M1只读核验](evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m1-validation-2026-10-03.md)：新PID3626与原设备／安装43d85d身份一致，源1279及M0备份956文件通过；人工布局/空候选/未arm补确认待回。M2未授权，loaded identity与调试器步骤另核。


2026-10-03 当前：[已授权T旧快照清理](evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m0-old-backup-cleanup-validation-2026-10-03.md)完成：精确4目录原分配499.83MiB已移除，凭据／测试／审查证据保留；I0/I1/M0约382.83MiB仍在。M0完成，M1/M2未授权，无设备操作。


2026-10-03 当前：[M0保护交付](evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m0-validation-2026-10-03.md)完成：精确旧扩展一次SIGTERM退出，当前43d85d完整备份127.63MiB通过，恢复方案Prepared；4组T旧快照约499.83MiB可申请精确删除，尚未删除。M1/M2未授权，父子Active、根因开放。


2026-10-03 当前：[M阶段准备包](plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m-prepared-2026-10-03.md)已准备：同一新实例内两次合成输入，中间只AppSwitcher直接回Maps；Entry/备份恢复/取证判读及停止条件已冻结。M0保护与后续M1/M2执行未授权，现场条件UNKNOWN，不Ready。U1R1窄接受及阶段残项处置保留，父子Active。


2026-10-03 当前：[U1R1 Product阶段处置](evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u1r1-delivery-correction-validation-2026-10-03.md)：Human仅当前阶段接受计时／预算合规未知及usage模型字段限制为非阻塞、未验证残项；独立Partial原记录与运行链窄接受保持，停止重复补审。父子Active，Maps／根因开放，无新增设备操作授权。


2026-10-03 当前：[U1R1作者补正接收](evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u1r1-delivery-correction-validation-2026-10-03.md)：D001–D004已补正，原窄运行意见不变；2/2调用耗尽，补正整轮计时/180秒合规未知，usage模型字段未重复，正式交付仍Partial，停止追加。无模拟器操作，Product阶段处置待决定。


## How To Use

Read `AGENTS.md` and `KNOWLEDGE_INDEX.md` first. Select one map below and stop when its required sources answer the task. Historical plans and changelog entries are optional evidence, never the starting authority.

Every implementation task also requires the documentation review checklist in `DOCUMENTATION_GOVERNANCE.md` and the relevant pre-push review.

When work is delegated, use the matching file under [`playbooks/`](playbooks/). Reading maps define knowledge inputs; playbooks define allowed work, evidence, stop conditions and handoff.

Long-lived thread ownership is defined in [`VIRTUAL_ENGINEERING_TEAM.md`](VIRTUAL_ENGINEERING_TEAM.md). Read it when creating a permanent thread, resolving ownership, coordinating multiple maintainers or handing work between long-lived threads. Short-term ✍️ Typo Maintainer threads may continue during the transition, but their benchmark, candidate-ranking, learning and regression evidence must hand off to the 🧠 Input Intelligence Maintainer.

## Enter With Zero Context

Ownership: Architecture & Knowledge Steward owns startup routing; Product Lead owns any new Product Assignment required before formal work; Program Manager may synchronize status only after owner-confirmed sources exist.

1. `AGENTS.md` — mandatory collaboration rules.
2. `KNOWLEDGE_INDEX.md` — top-level navigation.
3. `kos/zero-context-startup.md` — startup reading order, repository discovery, Work Item discovery, lifecycle discovery, role discovery, repository truth and prompt compression.
4. `KNOWLEDGE_OS.md` — only when operational layers, navigation protocol or self-healing behavior are required (not for frozen governance tables).
5. The task-specific reading map selected after startup.

Required review: repository truth comes from Assignment and canonical documents, not conversation; current Work Item and lifecycle are discovered before action; missing Assignment or UNKNOWN fields stop formal work unless the user objective authorizes governance bootstrap. After KOS-MIG-001, frozen Knowledge OS rules live under docs/kos/; do not treat pre-migration dual-track language as current. KOS 2.2 remains advisory at the v0.9.0 pin; see [UPGRADE_STATUS](kos/UPGRADE_STATUS.md), [PD-KOS-UPGRADE-UK-006](product-decisions/KOS-UPGRADE-UK-006-v0.9.0-adoption.md) and [the v0.9.0 reviewer-lane contract](ASSIGNMENT_POLICY.md#independent-reviewer-lane-packet-kos-kit-v090-selective-adoption). Do not treat validator output as a Gate pass.

## Create, Review Or Change A Task Assignment

Ownership: Product Lead makes Assignment and Reassignment decisions; Program Manager checks completeness only; Architecture & Knowledge Steward owns Policy governance.

1. `ASSIGNMENT_POLICY.md` — required fields, lifecycle, `UNKNOWN`, completeness, Reassignment and handoff.
2. `VIRTUAL_ENGINEERING_TEAM.md` — permanent ownership boundaries; do not convert an Assignment into a new role.
3. The task's Product decision, domain source and required review sources.

Required review: explicit Product Decision source; one Domain Owner; Executor, Environment Executor, Human Dependency and reviewers assigned or justified `Not Applicable`; executable Entry/Exit/Stop Conditions; named Handoff Target; no `UNKNOWN` before `Ready`. Program Manager reports gaps and escalates but never chooses the assignee.

## Review Or Update Program Status

Ownership: Primary 📋 Program Manager / Engineering Coordinator for status aggregation only. Product Lead owns product decisions and Gates; Architecture & Knowledge Steward owns architecture and Source of Truth; domain Maintainers own implementation/evidence; Test / Release owns Quality conclusions.

1. `ENGINEERING_DASHBOARD.md` — current status, dependencies, handoffs, blockers and recommended next actions.
2. `VIRTUAL_ENGINEERING_TEAM.md` — role boundaries and escalation rules.
3. The task's current Product, Architecture, domain and Quality sources cited by the Dashboard.

Required review: every status has an owner and source; implementation is not presented as acceptance; recommendations are not presented as decisions; Stop Conditions remain visible; Dashboard changes do not alter Product Contracts, ADRs, Registry entries or Quality Gates.

## Capture Environment Evidence

Ownership: The task Assignment names the Domain Owner and Environment Executor; Architecture & Knowledge Steward owns the reusable procedure, and Test / Release owns the Quality conclusion.

1. `ASSIGNMENT_POLICY.md` and the task-specific Assignment Record.
2. `ENVIRONMENT_CAPTURE_PROCEDURE.md` — preparation, sequencing, tool-observation, handoff and correction procedure.
3. The applicable accepted evidence template — required fields, provenance, unavailable form, Run ID, naming, blocking and archive contract.
4. Applicable ADRs, including ADR 0010 when execution facts or debug-only trace provenance are involved.

Required review: no `UNKNOWN` Assignment field; frozen inputs and archive location; current-run provenance; tool failures not treated as absence; actual SHA-256 values and complete manifest; immutable handoff; no Product, Runtime or Quality conclusion inferred by the Executor.

For a mismatch between host Terminal discovery and Codex/Xcode UI operations, read [KOS-DEVICE-DISCOVERY-DIAGNOSTICS-001](assignments/kos-device-discovery-diagnostics-001.md) and the accepted diagnostic section in `ENVIRONMENT_CAPTURE_PROCEDURE.md`.

For `ENV-TOOLING-001` capability implementation or Quality verification, also read `ENVIRONMENT_DIGEST_TOOLING.md`. It is the authority for digest roots, include/exclude rules, user-configuration separation, canonical manifest bytes, privacy and non-shipping boundaries. Fixture results validate tooling only and cannot replace a new Environment Capture.

## Publish Or Maintain A GitHub Pull Request

Ownership: the current Assignment and Authorization bound the publish action; Architecture & Knowledge Steward owns the reusable authentication diagnosis procedure. Merge and Release remain separate Human authorities.

1. `AGENTS.md` — GitHub publishing, branch cleanup and local CI gates.
2. [`kos/codex-github-cli-auth-troubleshooting.md`](kos/codex-github-cli-auth-troubleshooting.md) — sandbox/host authentication and network classification.
3. `AI_WORKFLOW.md` — PR topology and post-merge state synchronization.
4. The current Assignment, Authorization and changed-file-specific CI requirements.

Required review: confirm the exact current authorization and branch/PR state; never expose secret material; do one sandbox/host comparison before asking for reauthentication; do not reuse a historical proxy address; do not infer merge or Release authority from successful authentication.

## Modify Candidate Bar

Ownership: Primary [`Keyboard UI`](playbooks/keyboard-ui.md); secondary [`KeyboardCore`](playbooks/keyboard-core.md) when selection/state semantics change and [`Debug Investigator`](playbooks/debug-investigator.md) when the boundary is unproven; escalate ownership conflicts or durable product changes to [`Coordinator`](playbooks/coordinator.md).

1. `PROJECT_CONTEXT.md` — current UI/input ownership.
2. `UI_STYLE_GUIDE.md` — candidate presentation rules.
3. `architecture/input-pipeline-and-marked-text.md` — if selection or composition changes.
4. ADR 0002 and ADR 0004 — if lifecycle/session semantics are involved.
5. `DEBUGGING.md` — stale/frozen candidate evidence.

Required review: candidate selection references, paging snapshots, marked-text finalization, physical-device UI checks, `KeyboardTests`/relevant KeyboardCore coverage. Review `RELEASE_CHECKLIST.md` if user-visible interaction changes.

## Modify RIME Runtime Or Bridge

1. `PROJECT_CONTEXT.md`.
2. `architecture/shared-container-and-rime-lifecycle.md`.
3. ADR 0001, 0003, 0004 and 0008.
4. `architecture/swift6-migration.md`.
5. `DEBUGGING.md`; then `RELEASE_CHECKLIST.md`.

Add `architecture/rime-artifacts.md` for binary/vendor changes. Review session threading, Extension deployment prohibition, fallback semantics, performance measurement and `RimeBridgeTests`.

## Modify Lua

Ownership: Primary [`RimeBridge`](playbooks/rime-bridge.md) after the failing boundary is known; secondary [`Debug Investigator`](playbooks/debug-investigator.md) for smoke/runtime diagnosis and [`Test / Release`](playbooks/test-release.md) for acceptance evidence; escalate cross-target strategy or unresolved product behavior to [`Coordinator`](playbooks/coordinator.md).

1. RIME runtime map above.
2. `RIME_SCHEME_MANAGEMENT.md` advanced-input boundary.
3. Archived `plans/rime-ice-lua-full-capability-plan.md` only for historical constraints.
4. ADR 0001, 0004 and 0007.
5. Lua sections in `DEBUGGING.md`, `PERFORMANCE_BASELINE.md` and `RELEASE_CHECKLIST.md`.

Required review: module registration, referenced script completeness, deploy/runtime parity, real fixture smoke evidence, Full Access state and ordinary-input regression.

## Modify OpenCC

Ownership: Primary [`RimeBridge`](playbooks/rime-bridge.md); secondary [`Main App UI`](playbooks/main-app-ui.md) for settings/deployment orchestration, [`Debug Investigator`](playbooks/debug-investigator.md) for diagnosis and [`Test / Release`](playbooks/test-release.md) for acceptance; escalate a new integration strategy or cross-target ownership change to [`Coordinator`](playbooks/coordinator.md).

1. `architecture/opencc-integration.md` — current integration Source of Truth.
2. `architecture/shared-container-and-rime-lifecycle.md` for asset ownership.
3. ADR 0001 and 0003.
4. OpenCC sections in `DEBUGGING.md`, `PERFORMANCE_BASELINE.md` and `RELEASE_CHECKLIST.md`.
5. RIME artifact document if binary/data artifacts change.

Required review: custom YAML, deployed assets, active schema filter, conversion correctness and performance evidence. A new integration strategy requires an ADR.

## Change Keyboard Lifecycle

Ownership: Primary [`Keyboard UI`](playbooks/keyboard-ui.md) for Extension lifecycle wiring after the contract is defined; secondary [`KeyboardCore`](playbooks/keyboard-core.md), [`RimeBridge`](playbooks/rime-bridge.md) and [`Debug Investigator`](playbooks/debug-investigator.md) according to the proven boundary; escalate any composition product-contract change or multi-owner scope to [`Coordinator`](playbooks/coordinator.md).

1. ADR 0002 and ADR 0004.
2. `architecture/shared-container-and-rime-lifecycle.md`.
3. `architecture/input-pipeline-and-marked-text.md`.
4. `PROJECT_CONTEXT.md`.
5. lifecycle flows in `DEBUGGING.md` and physical-device gates in `RELEASE_CHECKLIST.md`.

Required review: new/superseding ADR, first appearance, disappearance, return, process death, marked text, candidate caches, active-session recovery and real-device evidence.

## Modify Marked Text, Commit, Delete, Space Or Return

Current delete-key V1 gestures: [`DELETE-KEY-SCRUB-001`](assignments/delete-key-scrub-001.md) (**Closed**；产品树 `origin/main` `cee4f91`；Close 与 Gate 在 PR #204 squash `4c2760d`） · [`PD`](product-decisions/DELETE-KEY-SCRUB-001-product-contract.md) · [`Gate`](product-decisions/DELETE-KEY-SCRUB-001-product-gate.md) · [`Close`](evidence/delete-key-scrub-001-close-2026-10-07.md). Settings page: [`DELETE-KEY-SETTINGS-001`](assignments/delete-key-settings-001.md) (**Reviewed**；Product Gate 002 Pass；本地内容 commit `2603b00`；未 push) · [`PD`](product-decisions/DELETE-KEY-SETTINGS-001-product-contract.md) · [`Product Gate`](reviews/delete-key-settings-001-product-gate.md) · [`Product Gate 002`](reviews/delete-key-settings-001-product-gate-002.md). Primary playbook [`Keyboard UI`](playbooks/keyboard-ui.md); the settings page also uses [`Main App UI`](playbooks/main-app-ui.md).

1. `architecture/input-pipeline-and-marked-text.md`.
2. `architecture/partial-commit.md` when checkpoint behavior is involved.
3. ADR 0002 and ADR 0004.
4. `DEBUGGING.md` marked-text and action flows.
5. `RELEASE_CHECKLIST.md` device acceptance.

Required review: raw input versus display preedit, exactly-once commit, underline clearing, composition-first Delete, Return raw commit and regression tests.

## Modify Shared Container Or User Dictionary

Ownership: Primary [`Main App UI`](playbooks/main-app-ui.md) for backup/restore orchestration; secondary [`RimeBridge`](playbooks/rime-bridge.md) for runtime/user-data coordination and [`Test / Release`](playbooks/test-release.md) for safety evidence; escalate destructive behavior, unresolved session coordination or user-data policy to [`Coordinator`](playbooks/coordinator.md) and the human owner.

1. ADR 0003 and ADR 0005.
2. `architecture/shared-container-and-rime-lifecycle.md`.
3. `RIME_USER_DICTIONARY.md`.
4. `TECH_DEBT.md` TD-002 and TD-007.
5. `DEBUGGING.md` and `RELEASE_CHECKLIST.md`.

Required review: reader/writer ownership, active-session coordination, backup-before-restore, failure recovery, Full Access/privacy and migration compatibility.

## Modify Portable RIME Sync

Ownership: Primary [`Main App UI`](playbooks/main-app-ui.md) for sync orchestration, provider credentials and settings UX; secondary [`RimeBridge`](playbooks/rime-bridge.md) only when librime user-data APIs are involved and [`Test / Release`](playbooks/test-release.md) for security, interruption and compatibility evidence.

1. `RIME_SYNC.md` and the current `RIME-SYNC-001` Assignment. Add `APP_NOTIFICATIONS.md` and `APP-NOTIFICATIONS-001` when notification or Toast behavior changes.
2. ADR 0012, then ADR 0003, 0005 and 0007. Add ADR 0019 for notification ownership, permission or foreground-presentation changes.
3. `architecture/shared-container-and-rime-lifecycle.md`.
4. `PRIVACY_POLICY.md`, `DEBUGGING.md`, `RELEASE_CHECKLIST.md` and `TECH_DEBT.md`.
5. `UI_STYLE_GUIDE.md` for the main-App surface.

Required review: transport-independent package format, authenticated encryption, credential/key separation, conditional writes, non-destructive conflict handling, provider deletion, unknown-field preservation, main-App-only execution, no keyboard hot-path work and representative cross-platform fixtures. CloudKit additionally requires verified membership, container, entitlement and physical-device evidence.

## Modify Schema Download, Install Or Rollback

Ownership: Primary [`Main App UI`](playbooks/main-app-ui.md) for download/install/deploy orchestration; secondary [`RimeBridge`](playbooks/rime-bridge.md) for deployment/runtime boundaries and [`Test / Release`](playbooks/test-release.md) for interruption evidence; escalate transaction-model, rollback or cross-target decisions to [`Coordinator`](playbooks/coordinator.md).

1. ADR 0001, ADR 0003 and ADR 0006. Add ADR 0032 for verified source recovery and ADR 0033 when built-in official bytes are involved.
2. `RIME_SCHEME_MANAGEMENT.md`.
3. `architecture/shared-container-and-rime-lifecycle.md`.
4. `TECH_DEBT.md` TD-001. Add TD-011 when Lua/shared-prefix coexistence is in scope.
5. `DEBUGGING.md` and `RELEASE_CHECKLIST.md`.
6. For post-download `resource_preparation` failure or shared-file ownership: [`SCHEME-DELIVERY-SOURCE-STATE-001`](assignments/scheme-delivery-source-state-001.md) (**engineering Assignment Closed**), [`coexistence plan`](plans/scheme-resource-ownership-and-coexistence-plan.md) and [ADR 0034](architecture/decisions/0034-multi-scheme-resource-ownership.md) (**Accepted — Conditional**). The plan remains supporting history; the ADR is the architecture source.

Required review: current non-atomic behavior, staging/rollback claims, download verification, interruption recovery and no Extension deployment. Do not treat the conditional ADR dispositions or an unproven `default.yaml` overwrite as a general device root cause.

## Modify Keyboard Layout Or Chinese Nine-Key

Ownership: Primary [`RimeBridge`](playbooks/rime-bridge.md) for T9 schema compatibility, effective-scheme selection and deploy/session boundaries; secondary [`KeyboardCore`](playbooks/keyboard-core.md) for layout/readiness settings and T9 input semantics, [`Keyboard UI`](playbooks/keyboard-ui.md) for Extension nine-key chrome, [`Main App UI`](playbooks/main-app-ui.md) for settings/install/verify orchestration and [`Test / Release`](playbooks/test-release.md) for evidence; escalate librime binary changes or deployment-boundary changes to [`Coordinator`](playbooks/coordinator.md).

1. `KEYBOARD_LAYOUT.md` (runtime + nine-key chrome), ADR 0018, closed Assignments `KEYBOARD-LAYOUT-9KEY-001` and `KEYBOARD-LAYOUT-9KEY-UI-001`, closed `KEYBOARD-LAYOUT-9KEY-PINYIN-001`, and closed `KEYBOARD-LAYOUT-9KEY-PINYIN-004` / ADR 0023 when changing Path catalog, atomic presentation, or T9 Partial×Path residual-B cursor. For the nine-key `，。？！` pending/cycle contract, also read [`KEYBOARD-LAYOUT-9KEY-PUNCT-001`](assignments/keyboard-layout-9key-punct-001.md) and [`PD-KEYBOARD-LAYOUT-9KEY-PUNCT-001`](product-decisions/KEYBOARD-LAYOUT-9KEY-PUNCT-001-authorization.md); that work is `Closed`（PR [#75](https://github.com/shchnk1103/Universe-Keyboard/pull/75) merged）with ADR 0029 `Accepted`.
2. ADR 0018, then ADR 0001, 0003, 0004 and 0006. For Path/Partial residual-B: ADR 0023 + [`PD-…-GATE5-RESIDUAL-B-PATH-LEDGER-PEEL`](product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-residual-b-path-ledger-peel.md) + [`architecture/partial-commit.md`](architecture/partial-commit.md) §T9 Path residual-B.
3. `architecture/shared-container-and-rime-lifecycle.md` and `architecture/input-pipeline-and-marked-text.md`.
4. `RIME_SCHEME_MANAGEMENT.md`, `UI_STYLE_GUIDE.md`, `DEBUGGING.md` and `RELEASE_CHECKLIST.md`.
5. `architecture/rime-artifacts.md` only if the pinned librime artifact itself must change.

Required review: T9 Spike evidence against the pinned librime, base scheme vs effective scheme separation, main-App-only readiness writes, failure fallback to 26-key, no raw-digit host commits, no Extension deployment, nine-key chrome contract in `KEYBOARD_LAYOUT.md` / `UI_STYLE_GUIDE.md` when changing Extension appearance, and physical-device nine-key acceptance when productizing.

## Modify KeyboardCore

1. `PROJECT_CONTEXT.md` KeyboardCore boundary.
2. The domain architecture source for the affected action/state.
3. `.claude/skills/keyboard-test-writer/SKILL.md`; load its references only for the affected test target.
4. Applicable ADRs.

Required review: state ownership, `KeyboardAction -> KeyboardEffect`, MainActor constraints, focused unit tests and documentation impact.

Playbook: [`playbooks/keyboard-core.md`](playbooks/keyboard-core.md).

## Fix A Crash Or Hard Bug

Ownership: Primary [`Debug Investigator`](playbooks/debug-investigator.md) until the failing boundary is proven; secondary the resulting Keyboard UI, KeyboardCore, RimeBridge or Main App owner plus [`Test / Release`](playbooks/test-release.md) for crash/jetsam evidence; escalate missing devices, archives, risk acceptance or ambiguous ownership to [`Coordinator`](playbooks/coordinator.md) and the human owner.

1. `DEBUGGING.md` first; collect evidence.
2. Relevant task map after locating the boundary.
3. Applicable ADRs before changing a contract.
4. `PERFORMANCE_BASELINE.md` for stalls, memory or jetsam.
5. `CHANGELOG.md` only to research similar completed incidents.

Required review: reproducible input/lifecycle, exact build/device, crash/jetsam classification, root cause, durable invariant and updated diagnostic flow when reusable.

Playbook: [`playbooks/debug-investigator.md`](playbooks/debug-investigator.md), followed by the owning domain playbook after the boundary is proven.

## Improve Performance

1. `PERFORMANCE_BASELINE.md`.
2. `kos/universe-keyboard-human-operated-evidence-profile.md` when evidence requires a Human Device Operator.
3. ADR 0004 for session/thread changes.
4. Relevant architecture/domain source.
5. `TECH_DEBT.md` TD-003.
6. Performance and lifecycle gates in `RELEASE_CHECKLIST.md`.

Required review: comparable measurements, no invented thresholds, hot-path storage/logging, memory growth and whether architecture changes require an ADR.

For Typo Correction Benchmark v1.0 evidence, also read `TYPO_BENCHMARK_REGISTRY.md`. Use Canonical `TC-PERF::{CaseID}::{ScenarioClass}` references and do not treat behavior coverage as performance evidence.

## Change Typo Correction Benchmark Registry Or Evidence References

Ownership: Primary Architecture & Knowledge Steward using [`documentation-maintainer.md`](playbooks/documentation-maintainer.md); Product Lead approves product intent, Input Intelligence reviews Contract/Case facts, and Test / Release reviews evidence references.

1. `TYPO_BENCHMARK_REGISTRY.md` — Canonical IDs, relationships, aliases and version.
2. ADR 0009 — Source-of-Truth and dependency decision.
3. `TYPO_BENCHMARK.md` — behavior explanation only.
4. `PERFORMANCE_BASELINE.md` — measurement procedure only.
5. `architecture/partial-commit.md` when Integration Cases reference Partial Commit.
6. `DOCUMENTATION_GOVERNANCE.md` and `KNOWLEDGE_DEPENDENCIES.md`.

Required review: immutable Canonical IDs, exactly one Primary Contract per Case, valid secondary references, `TC-PERF::*` targets, Alias/Superseded lifecycle, no duplicated authority, Markdown links and `git diff --check`. Registry publication does not mark evidence passed or authorize Task 7.

## Change UI

1. `PROJECT_CONTEXT.md`.
2. `UI_STYLE_GUIDE.md`.
3. Candidate/input map if keyboard interaction semantics change.
4. `RELEASE_CHECKLIST.md` accessibility/device checks.

Required review: existing components, light/dark, VoiceOver, Dynamic Type, frozen geometry and no accidental product-contract change.

## Release A Version

Ownership: Primary [`Test / Release`](playbooks/test-release.md); secondary all affected domain playbooks and [`Documentation Maintainer`](playbooks/documentation-maintainer.md); release approval, skipped gates and risk acceptance escalate to [`Coordinator`](playbooks/coordinator.md) and the human product/release owner.

1. `RELEASE_CHECKLIST.md`.
2. `TECH_DEBT.md` for release-triggered debt.
3. `PERFORMANCE_BASELINE.md`.
4. Applicable acceptance/domain documents.
5. `DOCUMENTATION_HEALTH.md` and governance checklist.

Required review: current evidence matrix, artifacts, physical device, RIME/Lua/OpenCC, privacy, skipped gates, changelog and no stale plan claims.

Playbook: [`playbooks/test-release.md`](playbooks/test-release.md).

## Change Tests Or Build Workflow

1. `PROJECT_CONTEXT.md` build entry.
2. `RELEASE_CHECKLIST.md` canonical commands.
3. `architecture/swift6-migration.md` for concurrency/build contract.
4. [`CI_CHANGE_CLASSIFICATION.md`](CI_CHANGE_CLASSIFICATION.md) for remote tiering and stable final-gate semantics.
5. [`playbooks/test-release.md`](playbooks/test-release.md).

Required review: installed simulator discovery, no hardcoded counts/device names, affected targets and current evidence policy.

## Change Documentation Or Add A Plan

Ownership: Primary [`Documentation Maintainer`](playbooks/documentation-maintainer.md); secondary [`Context Scout`](playbooks/context-scout.md) for read-only source verification and the affected domain playbook for factual confirmation; escalate missing product/architecture decisions or competing owners to [`Coordinator`](playbooks/coordinator.md).

1. `DOCUMENTATION_GOVERNANCE.md`.
2. `KNOWLEDGE_DEPENDENCIES.md`.
3. `DECISION_TREES.md` documentation tree.
4. `docs/kos/` when work concerns Knowledge OS 2.0 specification or migration readiness.
5. `DOCUMENTATION_HEALTH.md` if a metric/status changes.

Required review: one owner, links instead of copies, lifecycle/status metadata, archive condition, ADR need and navigation route.

Playbook: [`playbooks/documentation-maintainer.md`](playbooks/documentation-maintainer.md).

## Add A Long-Term Product Behavior Or Privacy-Sensitive Feature

Ownership: Primary [`Coordinator`](playbooks/coordinator.md); secondary the affected KeyboardCore, Keyboard UI, Main App UI, RimeBridge, Test / Release and Documentation Maintainer playbooks; product intent, privacy, retention, cross-target ownership and irreversible data decisions escalate to the human owner before implementation.

1. `DECISION_TREES.md` new-feature and lifecycle/user-data classification.
2. `DOCUMENTATION_GOVERNANCE.md` ADR and privacy-sensitive change triggers.
3. `PROJECT_CONTEXT.md` for current module and target boundaries.
4. Applicable ADRs, especially ADR 0003 and ADR 0007 for shared data or privacy.
5. Relevant architecture/domain source, then `PERFORMANCE_BASELINE.md`, `DEBUGGING.md`, `RELEASE_CHECKLIST.md` and `TECH_DEBT.md` according to impact.

Required review: product definition, data owner, collection point, retention/deletion, Full Access behavior, hot-path cost, privacy boundary, migration/recovery, ADR, tests and physical-device acceptance. Stop before implementation when any of these contracts remains unspecified.

For `TYPING-INTELLIGENCE-001`, also read `TYPING_INTELLIGENCE.md`, its Assignment, ADR 0011 and the Active implementation plan before entering a domain work package.
