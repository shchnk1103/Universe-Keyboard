# Reading Maps

## How To Use

Read `AGENTS.md` and `KNOWLEDGE_INDEX.md` first. Select one map below and stop when its required sources answer the task. Historical plans and changelog entries are optional evidence, never the starting authority.

Every implementation task also requires the documentation review checklist in `DOCUMENTATION_GOVERNANCE.md` and the relevant pre-push review.

When work is delegated, use the matching file under [`playbooks/`](playbooks/). Reading maps define knowledge inputs; playbooks define allowed work, evidence, stop conditions and handoff.

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

## Modify Schema Download, Install Or Rollback

Ownership: Primary [`Main App UI`](playbooks/main-app-ui.md) for download/install/deploy orchestration; secondary [`RimeBridge`](playbooks/rime-bridge.md) for deployment/runtime boundaries and [`Test / Release`](playbooks/test-release.md) for interruption evidence; escalate transaction-model, rollback or cross-target decisions to [`Coordinator`](playbooks/coordinator.md).

1. ADR 0001, ADR 0003 and ADR 0006.
2. `RIME_SCHEME_MANAGEMENT.md`.
3. `architecture/shared-container-and-rime-lifecycle.md`.
4. `TECH_DEBT.md` TD-001.
5. `DEBUGGING.md` and `RELEASE_CHECKLIST.md`.

Required review: current non-atomic behavior, staging/rollback claims, download verification, interruption recovery and no Extension deployment.

## Modify KeyboardCore

1. `PROJECT_CONTEXT.md` KeyboardCore boundary.
2. The domain architecture source for the affected action/state.
3. `.claude/skills/keyboard-test-writer/SKILL.md` and `REFERENCE.md`.
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
2. ADR 0004 for session/thread changes.
3. Relevant architecture/domain source.
4. `TECH_DEBT.md` TD-003.
5. Performance and lifecycle gates in `RELEASE_CHECKLIST.md`.

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
4. [`playbooks/test-release.md`](playbooks/test-release.md).

Required review: installed simulator discovery, no hardcoded counts/device names, affected targets and current evidence policy.

## Change Documentation Or Add A Plan

Ownership: Primary [`Documentation Maintainer`](playbooks/documentation-maintainer.md); secondary [`Context Scout`](playbooks/context-scout.md) for read-only source verification and the affected domain playbook for factual confirmation; escalate missing product/architecture decisions or competing owners to [`Coordinator`](playbooks/coordinator.md).

1. `DOCUMENTATION_GOVERNANCE.md`.
2. `KNOWLEDGE_DEPENDENCIES.md`.
3. `DECISION_TREES.md` documentation tree.
4. `DOCUMENTATION_HEALTH.md` if a metric/status changes.

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
