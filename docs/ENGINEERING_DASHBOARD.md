# Engineering Dashboard

> **Status:** Active program snapshot
>
> **Updated:** 2026-07-20 Asia/Shanghai
>
> **Coordinator:** 📋 Program Manager / Engineering Coordinator

本文汇总当前项目状态、依赖、Handoff、Blocker 和建议下一步。它不是 Product Contract、架构、Registry、实现或 Quality Evidence 的 Source of Truth，也不独立授予 `Accepted`、`Ready`、`Closed` 或 `Authorized` 状态。

## RELEASE-2026-0801 — 2026 年 8 月 1 日 App Store 发布

- **Lifecycle:** `Active — release coordination and Assignment bootstrap`
- **Authority:** [`Release umbrella Assignment`](assignments/release-2026-08-01.md)
- **Evidence source:** [`Release evidence and acceptance record`](evidence/release-2026-08-01-acceptance.md)
- **Current state:** Scope freeze (`RELEASE-2026-0801-02`) is Executor-completed and awaits independent Architecture/Quality review. The current Codex task is assigned to tasks 01, 05–09 in their KOS-compatible domain roles; their Entry Criteria remain pending. Task 03 remains on its separately authorized Grok path. Device Hub currently exposes a connected iPhone 13 Pro and iPad Pro (11-inch, 3rd generation), operated by the Human Product Owner. Task 04 remains `Assignment Pending` because its independent Quality Executor is not yet named.
- **Frozen Product scope:** iPhone + iPad, iOS 26.0+, Chinese nine-key, precise pinyin, post-commit continuation and kaomoji content. Typing Intelligence and contextual typo correction are excluded from launch claims. The iOS 26.0 project-target change, iPad support and kaomoji content remain unimplemented/unverified release blockers; see the [scope record](assignments/release-2026-08-01-02-scope-freeze.md).
- **Current blockers:** independent Architecture/Quality review of scope and iOS 26.0 target boundary; stable-toolchain archive readiness; iPad physical-device evidence; Product Lead catalog source/licensing/content decision; Full Access/onboarding closure; independent final physical-device/performance evidence; public URLs/contact/account access for App Store materials.
- **Authority boundary:** this status does not authorize upload, App Store submission, skipped-gate acceptance or manual release.
- **Next Product action:** name an independent Quality Executor and physical-device operators for task 04; provide the kaomoji catalog decision, public URLs/contact answers, account/signing access and physical devices when the dependent tasks reach their environment gates.

## KEYBOARD-LAYOUT-9KEY-PINYIN-002 — 确定性选项与选拼音循环

- **Lifecycle:** `Active — Amendment B local implementation; review/Product Gate pending`
- **Authority:** [`PD-KEYBOARD-LAYOUT-9KEY-PINYIN-002`](product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-002-authorization.md) + [`Assignment`](assignments/keyboard-layout-9key-pinyin-002.md)
- **Current phase:** Amendment B progressive-syllable path bar implemented locally; independent review and physical-device Product Gate next (covers A+B)
- **Completed gates:** [ADR 0021](architecture/decisions/0021-t9-deterministic-single-key-choices-and-cycle-selection.md) Accepted (+ Amendments A/B); pinned librime `1.16.1` Spike PASS for `m/n/o` (`9/9/4` candidates, no committed text); Core focused path tests pass after Amendment B
- **Delivered locally:** canonical single-key choices (`6 → m/n/o`), retained selection snapshot, direct/cycle shared transaction, first/next/wrap **选拼音**, selected accessibility state
- **Latest acceptance fix:** visible inverse-color selected-path highlight and exact `m/n/o` marked-text display implemented; focused/full Core tests, main scheme Simulator tests, and Debug/Release strict builds were refreshed and passed
- **Amendment A delivered locally:** `64 → mi/ni/m/n/o`; retained `n` focus across later `GHI`; selected-item tap confirms/advances to live-authorized `g/h`; active T9 space title `选定` but action remains first-candidate commit. Pinned librime hard gate passed with `authorizedSuffixes=g|h` and fallback-only `i` rejected.
- **Amendment B delivered locally (2026-07-20):** ban multi-syllable whole compact labels; first-syllable + first-key letters only; **direct path tap** confirms/advances immediately (选拼音 only cycles tentative selection); syllable-level next choices with letter-group fallback; path bar single-line UI defense. Focused `T9PinyinPathTests` `39/39` PASS.
- **Pending:** clean-commit Spike evidence, independent Architecture/Quality reviews, and physical-device Product Gate; see [review handoff](assignments/keyboard-layout-9key-pinyin-002-review-handoff.md) and [human handoff](assignments/keyboard-layout-9key-pinyin-002-product-gate-human-handoff.md)
- **Human dependency:** physical-device comparison against the supplied native-keyboard behavior before Product Gate
- **Predecessor:** `KEYBOARD-LAYOUT-9KEY-PINYIN-001` remains `Accepted / Closed`; this Work Item does not rewrite its history

## KEYBOARD-LAYOUT-9KEY-PINYIN-001 — 九宫格精准选拼音

- **Confirmed status:** `Accepted / Closed` (`2026-07-19 Asia/Shanghai`)
- **Status owner/source:** Product Lead / Domain Owner Input Intelligence; [`Assignment`](assignments/keyboard-layout-9key-pinyin-001.md); [`PD-KEYBOARD-LAYOUT-9KEY-PINYIN-001`](product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-001-authorization.md)
- **Product plan (non-authority):** [`plans/keyboard-layout-9key-pinyin-selection-implementation-plan.md`](plans/keyboard-layout-9key-pinyin-selection-implementation-plan.md) (`Archived`)
- **Architecture source:** [ADR 0020](architecture/decisions/0020-t9-precise-pinyin-path-selection.md) (extends ADR 0018)
- **PR / merge:** [#20](https://github.com/shchnk1103/Universe-Keyboard/pull/20) **MERGED** → `main` (`fe9010f`); feature commits `77d38ad` + `e5e9bd3`
- **Gates:** Architecture Pass; automated Quality Pass; Product Gate PASS (Human device OK)
- **Delivered:** path bar + 选拼音 panel; KeyboardCore dual-revision provenance; mixed T9 no-raw host commit; Spike on librime 1.16.1 / `t9`
- **Open blockers:** None for this Assignment
- **Recommended next action:** None (closed). Optional path-panel UI automation would need a new Assignment
- **Stop conditions (historical):** mixed `replaceInput` infeasible; unstable comments; schema/vendor upgrade; Extension deploy; raw-input host commit

## KEYBOARD-LAYOUT-9KEY-UI-001 — Native-aligned Chinese nine-key chrome

- **Confirmed status:** `Accepted / Closed`
- **Status owner/source:** Product Lead; [`Assignment`](assignments/keyboard-layout-9key-ui-001.md)
- **Product / domain sources:** [`KEYBOARD_LAYOUT.md`](KEYBOARD_LAYOUT.md) (Nine-key Chrome), [`UI_STYLE_GUIDE.md`](UI_STYLE_GUIDE.md)
- **Architecture source:** [ADR 0018](architecture/decisions/0018-keyboard-layout-nine-key-and-t9-runtime.md) (unchanged T9 digit semantics)
- **Current phase:** Closed after human visual acceptance (`2026-07-17`); publication via feature branch / PR merge
- **Delivered chrome:** Left 4-column letter-group pad; right delete / 颜表情 `^_^` / double-height return glyph; bottom emoji + 选拼音 placeholder + wide 拼音 (1+1+2); type scale 22/16/15/14; digit payload via accessibility identity
- **Residual product work:** full 选拼音 delivered under [`KEYBOARD-LAYOUT-9KEY-PINYIN-001`](assignments/keyboard-layout-9key-pinyin-001.md) (`Accepted / Closed`); full 颜表情 candidate content still requires a **separate** future Assignment
- **Stop conditions (historical):** Raw-digit host commit, Extension deploy, live hot-switch redesign, English nine-key

## POST-COMMIT-CONTINUATION-001 — Ephemeral Post-Commit Continuation V1

- **Confirmed status:** `Closed`
- **Status owner/source:** Product Lead; [`Assignment`](assignments/post-commit-continuation-001.md)
- **Product source:** [`Post-Commit Continuation Product Contract`](POST_COMMIT_CONTINUATION.md)
- **Architecture source:** [ADR 0017](architecture/decisions/0017-ephemeral-post-commit-continuation.md)
- **Current phase:** Product Gate closed; PR #14 publication and safe branch cleanup authorized.
- **Current implementation:** Bounded bundled provider, transient KeyboardCore state, distinct candidate semantics, candidate-bar integration, default-on setting, strict resource validation, a 60-case/15-category synthetic Top-3 benchmark and a 250-context curated pack are present.
- **Current evidence:** The human owner accepted physical-device candidate behavior. A paired Release snapshot on iPhone 13 Pro/iOS 27.0 beta 3 covers enabled/disabled cold process, repeated final commit, candidate refresh, CPU, physical footprint and 250-ms hang rows without an unexplained feature regression. See the [physical-device acceptance record](evidence/post-commit-continuation-v1.3-physical-device-2026-07-16.md).
- **Closure evidence:** The [independent review record](evidence/post-commit-continuation-v1.3-independent-review-2026-07-16.md) records passing Quality and Architecture conclusions. The human Product Lead explicitly closed V1.3 on `2026-07-16`; publication remains complete only after PR #14 merges and the feature commit is reachable from `origin/main`.
- **Stop conditions:** Host-context access, committed-text persistence/logging/network use, unbounded lookup, RIME-session prediction or unexplained performance regression.

## TYPING-INTELLIGENCE-001 — Local Typing Intelligence Foundation

- **Confirmed status:** `Active`
- **Status owner/source:** Product Lead; [`Assignment`](assignments/typing-intelligence-001.md)
- **Product source:** [`Typing Intelligence Product Contract`](TYPING_INTELLIGENCE.md)
- **Architecture source:** [ADR 0011](architecture/decisions/0011-local-typing-intelligence-data-boundary.md)
- **Current phase:** Implementation; automated and physical-device validation pending
- **Domain Owner / Executor:** Input Intelligence Maintainer
- **Supporting owners:** Keyboard Experience, App & Data Operations, Architecture, Quality
- **Dependencies:** Pre-feature baseline and privacy API inventory are Gate 0 work; physical-device Full Access evidence is required before final acceptance.
- **NE1 boundary:** NATIVE-EXPERIENCE-001 remains independently frozen/traceable and is not modified by this Work Item.
- **Current implementation:** Commit/classification contract, bounded writer/store, Extension wiring, main-App dashboard, privacy page and target manifests are present; Quality has not yet validated them.
- **Next handoff:** Quality runs the automated matrix and reports compile/test/privacy/performance findings; App/Data and Input Intelligence address evidence-backed defects.
- **Stop conditions:** Raw/reconstructable input persistence, synchronous key-path storage, RIME/candidate/lifecycle redesign, network/SDK data sharing or NE1 contamination.

- Product 决策和 Gate 归 🧭 Product Lead。
- 架构、ADR 和 Source of Truth 归 🏛️ Architecture & Knowledge Steward。
- 领域实现和领域证据归各 Maintainer。
- 测试、性能、真机和 Release 证据判定归 🧪 Quality, Performance & Release Maintainer。
- 状态冲突时，以对应 owner 的当前仓库记录为准，并在 Dashboard 中标记待同步。

## TYPO-CORRECTION-002 — Contextual Multi-Error Pinyin Recovery

- **Confirmed status:** `Active`
- **Status owner/source:** Product Lead; [`Assignment`](assignments/typo-correction-002.md)
- **Product source:** [`Contextual Typo Correction Product Contract`](TYPO_CORRECTION.md)
- **Architecture source:** [ADR 0015](architecture/decisions/0015-contextual-multi-error-typo-correction.md) and [ADR 0016](architecture/decisions/0016-progressive-contextual-recall-preflight.md)
- **Current phase:** Core/bridge, bounded progressive-recall preflight and iOS UI baseline evidence captured; semantic scoring, contextual UI and designated-simulator acceptance pending
- **Domain Owner / Executor:** Input Intelligence Maintainer
- **Supporting owners:** RIME Platform, Keyboard Experience, Architecture and Quality
- **Device constraint:** environment-specific evidence may use only the designated Device Hub iOS 27 iPhone 17 Pro Max simulator.
- **Current evidence:** KeyboardCore focused/full tests, iOS Debug/Release Simulator builds, RimeBridge contract tests, iOS UI baseline, and the isolated 60/64/8 progressive-recall preflight passed locally; real rime_ice sidecar fixture is skipped when fixture directories are unavailable.
- **Open Gate:** the designated simulator is available, but the contextual-candidate, cancellation, real-RIME and paired-performance scenarios have not run. The progressive plan is not connected to production and supplies no semantic-ranking evidence. See the [validation record](evidence/typo-correction-002-device-hub-validation.md).
- **Stop conditions:** live-session mutation for hypothesis queries, unbounded hot-path search, raw sentence persistence, network/telemetry, or substituting a non-designated environment for the Device Hub simulator.

## System Governance

### Active Governance Work Items

| Work item | Lifecycle state | Current phase | Routing / coordination note |
|---|---|---|---|
| `KOS-GOV-001` | Accepted / Closed | Closed | Product Review accepted the completed Knowledge OS 2.0 publication. Closure synchronization records the concluded state only; this closure did not itself authorize migration. |
| `KOS-BOOT-001` | Accepted / Closed | Closed | Product Review accepted the Zero-Context Startup Layer publication. Closure synchronization records the concluded state only; this closure did not itself authorize migration or Knowledge OS 2.1. |
| `KOS-MIG-001` | Accepted / Closed | Closed | Product-authorized operational migration applied Knowledge OS 2.0 as the single governance track. See [Assignment](assignments/kos-mig-001.md) and [completion record](kos/migration-001-record.md). Knowledge OS 2.1, domain tree moves, implementation and Benchmark work remain unauthorized by this closure. |
| `DOC-HYGIENE-001` | Accepted / Closed | Closed | Documentation hygiene pass under Knowledge OS 2.0: plan lifecycle normalization, closed-Assignment header sync, ADR 0017/0019 collision fix, README reduction, health snapshot refresh. See [Assignment](assignments/doc-hygiene-001.md) and [audit](evidence/doc-hygiene-001-audit.md). Domain duplicate-fact cleanup and playbook dry-runs remain residual. |

### KOS-MIG-001 Coordination

- Work item: `KOS-MIG-001 — Apply Knowledge OS 2.0 Operational Migration`.
- Classification: `Level S — System Governance`.
- Repository Change Type: `Migration`; closure synchronization: `State`.
- Assignment source: [KOS-MIG-001 Assignment Record](assignments/kos-mig-001.md).
- Plan source: [Migration plan](plans/kos-mig-001-migration-plan.md).
- Completion source: [Migration completion record](kos/migration-001-record.md).
- Operational entry: [KNOWLEDGE_OS.md](KNOWLEDGE_OS.md).
- Frozen governance: [docs/kos/](kos/).
- Lifecycle state: `Accepted / Closed`.
- Current phase: `Closure Synchronization complete`.
- Domain Owner / Executor: 🏛️ Architecture & Knowledge Steward.
- Product Approver: 🧭 Product Lead (Human Product Owner authorization `2026-07-17`).
- Quality Reviewer: `Not Required` per the published Assignment.
- Product Review: `Accepted`.
- Routing: concluded; no further KOS-MIG-001 owner action is pending after closure synchronization.
- Not authorized by this synchronization: Knowledge OS 2.1/3.0, domain documentation tree moves, implementation, Benchmark work or Task 7.

### KOS-BOOT-001 Coordination

- Work item: `KOS-BOOT-001 — Publish Zero-Context Startup Layer`.
- Classification: `Level S — System Governance`.
- Repository Change Type for publication: `Contract`; closure synchronization: `State`.
- Assignment source: [KOS-BOOT-001 Assignment Record](assignments/kos-boot-001.md).
- Startup source: [Zero-Context Startup Layer](kos/zero-context-startup.md).
- Lifecycle state: `Accepted / Closed`.
- Current phase: `Closure Synchronization complete`.
- Domain Owner / Executor: 🏛️ Architecture & Knowledge Steward.
- Product Approver: 🧭 Product Lead.
- Quality Reviewer: `Not Required` per the published Assignment.
- Product Review: `Accepted`.
- Routing: concluded; no further KOS-BOOT-001 owner action is pending after closure synchronization.
- Historical note: this closure did not authorize migration; migration was later completed under KOS-MIG-001.

### KOS-GOV-001 Coordination

- Work item: `KOS-GOV-001 — Publish Knowledge OS 2.0 Canonical Specification`.
- Classification: `Level S — System Governance`.
- Repository Change Type for this synchronization: `State`.
- Assignment source: [KOS-GOV-001 Assignment Record](assignments/kos-gov-001.md).
- Lifecycle state: `Accepted / Closed`.
- Current phase: `Closure Synchronization complete`.
- Domain Owner / Executor: 🏛️ Architecture & Knowledge Steward.
- Product Approver: 🧭 Product Lead.
- Quality Reviewer: `Not Required` per the published Assignment.
- Product Review: `Accepted`.
- Routing: concluded; no further KOS-GOV-001 owner action is pending after closure synchronization.
- Historical note: this closure did not authorize migration; migration was later completed under KOS-MIG-001.

## Typo Benchmark v1.0

### Governance Baseline

| Field | Value |
|---|---|
| Assignment Policy | [`v1.0.0`](ASSIGNMENT_POLICY.md) / Accepted |
| Policy commit | `4188dccef2083e998185e242c6d5ab45af3ea9b4` |
| Governance tag | `governance-v1.0.0` |
| Governance synchronization | `main` pushed, range `3cb5a6c..4188dcc` |
| Environment Capture Procedure | [`v1.0.0`](ENVIRONMENT_CAPTURE_PROCEDURE.md) / Accepted |
| Procedure publication chain | Template `760aa4a722f397fbcbf21e3430189ab46ce33cbe`; baseline `8d55b9c1b817016b17b97bc80014e9b53dea28f8`; accepted `05784106df50c4accb94233cf22681f3901f542a` |

### Current Registry

| Field | Value |
|---|---|
| Version | `1.0.0` |
| Commit | `49b000bcbb3a90d04f00dd803981a24a25b70e28` |
| Source of Truth | [`TYPO_BENCHMARK_REGISTRY.md`](TYPO_BENCHMARK_REGISTRY.md) |
| Architecture decision | [ADR 0009](architecture/decisions/0009-typo-benchmark-registry-source-of-truth.md) |

### Task Status

| Task | Current status | Coordination note |
|---|---|---|
| `ORG-POLICY-001A` | Accepted / Closed | Assignment Policy v1.0.0 accepted at `4188dccef2083e998185e242c6d5ab45af3ea9b4`; governance tag `governance-v1.0.0`. |
| `ORG-PROCEDURE-001` | Accepted / Closed | Environment Capture Procedure v1.0.0 accepted at `05784106df50c4accb94233cf22681f3901f542a`. |
| `ENV-TOOLING-001` | Accepted / Closed | Product Review completed; capability is accepted and closed. `004C-R1` may remove the ENV-TOOLING-001 capability blocker, but still requires its own Entry Criteria evidence and lifecycle handling before start. |
| `TYPO-BENCHMARK-006B` | Accepted / Closed | Registry v1.0 Source-of-Truth publication completed at the commit above. |
| `TYPO-BENCHMARK-004B` | Accepted with Implementation Blockers / Closed | Product status is closed; implementation/environment blockers remain visible below. |
| `TYPO-BENCHMARK-004C-R1` | Assigned / Not Ready | Assignment Record is complete with no `UNKNOWN` fields, but remaining Entry Criteria block `Ready`; do not start. See the [Assignment Record](assignments/typo-benchmark-004c-r1.md). |
| `TYPO-BENCHMARK-004D` | Accepted / Closed | Test-only Structured Evidence Capability completed through its required Architecture, Quality and Product reviews. |
| Task 7 | Not Authorized | Registry publication and test-only capability do not authorize Task 7. |

`Closed` describes the owning task decision, not the removal of downstream implementation or evidence blockers. `Implemented` describes capability presence, not Product or Quality acceptance.

## Open Blockers

| Blocker | Impact / exit owner |
|---|---|
| Physical device offline | Human Dependency must provide the designated unlocked device and access; Environment Executor must confirm operational availability before capture. |
| Deployment not frozen | Runs are not comparable until deployment inputs and artifact state are frozen. |
| Actual runtime schema not verified | Real RIME conclusions remain blocked until the active runtime schema is captured and verified. |
| Clean state not established | Baseline and scenario comparisons cannot claim a controlled starting state. |
| Real RIME `nihoa-satisfied` / `nihoa-unsatisfied` not verified | Required provider-dependent behavior remains unverified in the real runtime. |
| Release baseline not prepared | Release-default comparison and isolation evidence are unavailable. |
| Performance baseline not executed | No current comparable performance baseline exists. |
| Evidence archive policy not established | Capture must not begin until the archive location and policy are identified. |

## Current Assignment Coordination

- Current task: `TYPO-BENCHMARK-004C-R1 Physical Device Deployment & Environment Capture`.
- Lifecycle: `Assigned / Not Ready`.
- Assignment source: [004C-R1 Assignment Record](assignments/typo-benchmark-004c-r1.md).
- Required capture procedure: [Environment Capture Procedure v1.0.0](ENVIRONMENT_CAPTURE_PROCEDURE.md); every future `004C-R1` capture must cite and follow this accepted version.
- ENV capability dependency: `ENV-TOOLING-001` is `Accepted / Closed`; the capability blocker may be removed for `004C-R1`.
- Assignment completeness: complete; no required field remains `UNKNOWN`.
- Remaining readiness work: satisfy every remaining `004C-R1` Entry Criterion with current evidence, including frozen build/deployment artifacts, active runtime schema, Full Access observation, canonical clean-state procedure and evidence archive policy, before any separate lifecycle progression.
- Task 7 remains `Not Authorized`.

This is an Assignment completeness report, not an Assignment Decision made by the Program Manager.

## ENV-TOOLING-001 Assignment Coordination

- Lifecycle: `Accepted / Closed`.
- Assignment source: [ENV-TOOLING-001 Assignment Record](assignments/env-tooling-001.md).
- Product Review: completed by Product Lead; this Dashboard records the lifecycle result and does not modify the Assignment Contract.
- Routing: ENV-TOOLING-001 no longer requires Executor, Architecture or Quality routing. Future use by `004C-R1` is routed through the `004C-R1` Assignment and its required Quality handoff.
- Predecessor relationship: ENV capability dependency is satisfied for coordination purposes; `004C-R1` still requires separate Entry Criteria evidence and lifecycle handling before using the capability in capture.
- Task 7 remains `Not Authorized`.

## Update Contract

Update this Dashboard only after the responsible owner confirms a state, dependency, blocker or handoff change. Every update must preserve:

- the task or blocker owner;
- the evidence or repository reference supporting the state;
- the distinction between implementation, verification, acceptance and authorization;
- unresolved Stop Conditions and the role required to clear them;
- the rule that Dashboard summaries never supersede Product, Architecture, Registry or Quality sources.
