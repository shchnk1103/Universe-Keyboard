# Assignment: T9-RESPONSIVE-PIPELINE-001 / P3-D1 Runtime Lifecycle Evidence Matrix

Policy version: 1.0.0  
Lifecycle status: **Active — T01 target probe repaired; T02/T03 harness implemented; T02/T03 Product Hold after host block**  
Date: 2026-08-03 Asia/Shanghai

## Authority

- Assignment Authority: Product Lead
- Decision Source / Date: Human Product Owner authorization in the active Codex task,
  “授权你进行下一步”，2026-08-02 Asia/Shanghai
- Product Approver: Human Product Owner / Product Lead
- Parent Assignment: [`P2-D1 Marker Contract`](t9-responsive-pipeline-001-p2-d1-marker-contract.md)
- Evidence Contract: [`P2-PERF-02 Evidence Contract`](t9-responsive-pipeline-001-p2-perf-02-evidence-contract.md)
- Architecture Boundary: [`ADR 0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md)
  remains **Proposed**; production remains governed by [`ADR 0004`](../architecture/decisions/0004-rime-runtime-session-model.md)

## Objective

Close the next evidence layer after P2-D1: determine whether the documented epoch,
reset/recover, late-result, owner-timeout and process-lifecycle contracts hold at the
Extension/real-RIME boundary. The matrix must keep four evidence layers separate:

1. deterministic KeyboardCore/Fake proof;
2. target-level Extension wiring proof;
3. real `RimeEngineImpl`/librime runtime proof;
4. physical-device lifecycle, persistence, memory and jetsam observation.

Passing a lower layer never upgrades a higher layer. A missing device or unavailable
tool is recorded as `Unavailable`/`Blocked`, never as a successful runtime result.

## Scope

- Freeze a replayable, content-free lifecycle matrix for the explicit diagnostic B path and
  the ordinary sync A path.
- Validate reset/recover/visibility epoch boundaries, stale-result rejection, owner timeout
  fallback and latest-only presentation semantics in existing deterministic tests before any
  target/device action.
- Define target-level and real-runtime evidence requirements for `PATH/READY`, session
  identity, `ACCEPT/PUBLISH/VISIBLE/PAINT`, fallback, reload and App Group writer state.
- If the physical phase becomes Ready, use the established Human-input method: empty Reminders
  title, software keyboard, Universe Chinese nine-key, synthetic
  `jintiandetianqizhenbucuowomenchuquwanba`, no coordinate typing, no Path/candidate selection,
  and content-free App Diagnostics export.
- Preserve immutable run identity, source/build/device provenance, unavailable/contradicted
  states and a reviewer handoff package.

## Non-goals

- No production behavior change, real `RimeEngineImpl` production rewire, Lua/schema change,
  candidate-policy change or input-event drop/merge/reorder.
- No default responsive gate, user setting, Release default-on, ADR 0025 acceptance, Product
  Gate, R6 or shipping decision.
- No coordinate-driven XCTest, Computer Use typing, guessed screen coordinates or automation of
  the third-party keyboard's physical UI.
- No uninstall, App Group wipe, RIME/userdb reset, destructive cleanup or host-data deletion.
- No invented latency/memory SLO; P3-D1 records observations and distributions only.
- No claim that a `PUBLISH` marker proves UI paint, or that `T9DEVICE gate=off` proves the
  responsive B gate is off.

## Assignment

- Domain Owner: 🧪 Quality, Performance & Release Maintainer
- Executor: Current Codex task for documentation, deterministic verification and evidence
  orchestration within this scope
- Environment Executor: Current Codex task for non-destructive build/tool discovery and any
  explicitly authorized install/log operation; unavailable tool access is a blocker
- Human Dependency: Human Product Owner provides the connected/unlocked/trusted iPhone 13 Pro,
  opens an empty Reminders title and performs the declared manual fixture only when the physical
  phase is declared Ready
- Architecture Reviewer: Independent Architecture & Knowledge Steward
- Quality Reviewer: Independent Quality, Performance & Release Maintainer

## Required Inputs

- [`P2-D1 Assignment`](t9-responsive-pipeline-001-p2-d1-marker-contract.md)
- [`P2-D1 Architecture review`](t9-responsive-pipeline-001-p2-d1-architecture-review.md)
- [`P2-D1 Quality review`](t9-responsive-pipeline-001-p2-d1-quality-review.md)
- [`P2-PERF-02 Evidence Contract`](t9-responsive-pipeline-001-p2-perf-02-evidence-contract.md)
- [`ADR 0025 Proposed`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md)
- [`ADR 0004`](../architecture/decisions/0004-rime-runtime-session-model.md)
- [`ADR 0002`](../architecture/decisions/0002-visibility-change-abandons-composition.md)（visibility abandon 合同）
- [`Shared Container And RIME Lifecycle`](../architecture/shared-container-and-rime-lifecycle.md)
- [`Performance Baseline`](../PERFORMANCE_BASELINE.md)
- [`Environment Capture Procedure`](../ENVIRONMENT_CAPTURE_PROCEDURE.md)
- [`Test And Release Playbook`](../playbooks/test-release.md)
- [`RimeBridge Playbook`](../playbooks/rime-bridge.md)
- [`Debug Investigator Playbook`](../playbooks/debug-investigator.md)

## Evidence Layers and Matrix

| ID | Layer / boundary | Stimulus | Required invariant | Required evidence | Current state |
|---|---|---|---|---|---|
| P3-D1-C01 | Core / sync A | Gate-off `processKey` burst | A does not require responsive markers; order and no-drop remain intact | Focused XCTest + full KeyboardCore | **Passed (bounded)** — `ResponsiveRimePipelineTests` 23/0 |
| P3-D1-C02 | Core / visibility barrier | Accept pending work, then `bumpSessionEpoch` | Old pending/late work cannot apply or publish; new epoch accepts fresh revision space | Epoch, pending, stale counters; no content | **Passed (bounded)** — epoch bump/old-result tests passed |
| P3-D1-C03 | Core / enqueued reset | `processKey → resetSession → processKey` | Reset executes serially, bumps epoch, trailing old-epoch work is discarded | Engine call order, epoch, discarded count | **Passed (bounded)** — reset ordering test passed |
| P3-D1-C04 | Core / enqueued recover | `processKey → recoverSession` | Recovery bumps epoch and prevents old result publication | Recovery count, epoch, stale-result count | **Partial (bounded)** — recover epoch test passed; same-recover late-result negative case not yet isolated |
| P3-D1-C05 | Core / late snapshot | Deliver old snapshot after epoch bump | Old epoch is rejected; same revision may be reused only by new epoch | `tryApplyExternalSnapshot`, tracker late-completion nil | **Passed (bounded)** — old snapshot and tracker late-result tests passed |
| P3-D1-C06 | Core / latest-only | Burst multiple accepted revisions | Engine still processes every event; UI may coalesce; each valid B accepted revision has owner PUBLISH | Applied/published watermarks, coalesced count, marker validator | **Passed (bounded)** — latest-only/catch-up tests passed |
| P3-D1-C07 | Core / owner readiness | Controlled owner delay/timeout | `NOT_READY`/fallback is explicit; gate does not remain falsely active; A sync fallback is usable | Fake delay, readiness marker, fallback reason, no unsafe isolation | **Partial (bounded)** — Spike 10/0 + Wire 9/0; target PATH/READY/fallback wiring not proved |
| P3-D1-T01 | Extension target | Build/load Extension test target and exercise lifecycle harness | Keyboard target can load; lifecycle boundary invokes the same reset/recover/epoch cleanup | Xcode test result, target/build identity, no device claim | **Partial (bounded)** — appex target built; `KeyboardExtensionTests` probe 1/0; lifecycle harness not covered |
| P3-D1-T02 | Extension target | Explicit B flag with controlled Fake/Spike owner | MainActor accepts while owner is delayed; results are ordered and epoch-checked; gate-off remains behavior-equivalent | Target logs + test report + compile flags | **Blocked (host accessibility)** — actual-target harness-on/gate-off compiles passed; the run `P3D1-T02-T03-SIM-20260803-001` skipped before activation because no fully accessible system keyboard boundary was exposed; no target owner marker sequence observed |
| P3-D1-T03 | Extension target | Visibility abandon / return and keyboard reload | Composition is abandoned per ADR 0002; old session/result does not leak into new session | Lifecycle logs, epoch/session IDs, marked-text outcome | **Blocked (host accessibility)** — lifecycle epoch barrier and stale-snapshot regression are proven in Core, but host-driven return skipped before target activation; no target lifecycle marker sequence observed |
| P3-D1-R01 | Real RIME | Explicit diagnostic B with prepared `rime_ice`/T9 runtime | `PATH/READY`, owner-thread session identity, real publish order and fallback are observed | Run-bound content-free logs, artifact hashes, schema/readiness and session fields | **NotRun** — requires real iOS target/runtime |
| P3-D1-R02 | Real RIME | Reset/recover during or immediately after pending work | Real old-epoch result is discarded; new session can continue without duplicate host text | Content-free immutable export (or privacy-scanned controlled attachment), epoch/revision timeline, host integrity report | **NotRun** — requires real iOS target/runtime |
| P3-D1-R03 | Physical device | Human synthetic 39-key fixture in Reminders | No lost/duplicate input, candidate disappearance or keyboard exit; B/A path facts remain distinct | App Diagnostics export, Human report, run/build/device provenance | **Partial — gate-off baseline captured** — [`P3-D1-R03 device evidence`](../evidence/t9-responsive-pipeline-p3-d1-r03-device-2026-08-03.md); 39/39 T9SEG, stable session/geometry, Human reported no integrity failure but noticeable stalls; [`Architecture review`](t9-responsive-pipeline-001-p3-d1-r03-device-architecture-review.md) and [`Quality review`](t9-responsive-pipeline-001-p3-d1-r03-device-quality-review.md) completed with conditions; [`Evidence Hardening follow-up`](../evidence/t9-responsive-pipeline-p3-d1-r03-evidence-hardening-followup-2026-08-03.md) closes validator re-openability and post-restore smoke; [`Q2/Q3 provenance addendum`](t9-responsive-pipeline-001-p3-d1-r03-q2-q3-evidence-hardening.md) records build/restore and observed marker fixture identity while canonical human-fixture mapping remains unproven; B comparison remains out of scope |
| P3-D1-R04 | Physical lifecycle | Hide/show, keyboard reload, process termination and return | New process/session starts clean; unfinished composition is not restored; no stale marked text | Device log, session/epoch markers, manual observation | **NotRun** — requires device; no destructive reset |
| P3-D1-R05 | Persistence/suspend | End/suspend Extension after marker activity | Mandatory diagnostic records have the documented async writer outcome; no claim of durability without artifact | App Group export, writer state, suspend/termination classification | **NotRun** — requires device and approved capture path |
| P3-D1-R06 | Memory/jetsam | Sustained synthetic input and controlled lifecycle pressure | Termination is classified as normal/crash/jetsam; memory trend is recorded without a budget claim | Organizer/device logs, exact build/dSYM, memory trace | **NotRun** — separate evidence row; not a Product Gate |

## Run and Privacy Contract

Every target/real run must bind all records to one immutable Run ID and include, where
available: source/dirty-worktree fingerprint, exact build configuration and injected flags,
App/Extension hashes, device/OS, schema/readiness, Full Access observation, fixture ID, session
and epoch fields, and artifact hashes. A restarted build/device/schema or changed clean state is
a new Run ID.

Diagnostics may contain only content-free fields: action/event counts, revisions, epochs,
timings, pending/coalesced counts, gate/path/readiness/session booleans, hashes and bounded
reasons. Raw pinyin, candidate text, host text, user dictionary data and credentials are
prohibited. Human reports may describe integrity outcomes but must not paste typed content.

For manual physical input, `execution geometry` is **Not Applicable** to the typing method when
no coordinate driver is used; it must not be represented as a successful geometry proof. Tool
failures (including simulator/device/App Group enumeration failures) are recorded as unavailable
observations with command, exit status and retry condition.

## Entry Criteria

- This Assignment contains no `UNKNOWN` required responsibility and remains within the P2-D1/
  ADR 0004/0025 boundaries.
- Current final P2-D1 docs and marker schema are available; default gate remains off.
- Deterministic phase: `Packages/KeyboardCore` can run its focused/full tests; no target/device
  is required for the first phase.
- Target phase: a concrete installed Simulator/device destination and Xcode target scheme are
  discoverable; stale UDIDs are not accepted.
- Physical phase: Human confirms iPhone 13 Pro is connected/unlocked/trusted, ordinary gate-off
  restore is available, Reminders is ready, software keyboard mode is selected and App Diagnostics
  export is accessible.
- Real-runtime phase: prepared RIME directories/schema and explicit diagnostic build flags are
  recorded without changing project defaults.

## Exit Criteria

1. Matrix rows are classified `Passed`, `Partial`, `Blocked` or `NotRun` with evidence-layer
   provenance; no lower-layer result is promoted to a higher layer.
2. Deterministic lifecycle rows have focused regression output and full KeyboardCore result.
3. Any target/real/device run has an immutable Run ID, build/device/schema/access provenance,
   content-free export hash and explicit teardown/restore status.
4. Reset/recover/late-result, owner timeout/fallback, reload and persistence outcomes are stated
   separately; missing PATH/READY/session/geometry fields stay missing.
5. Independent Architecture and Quality reviews complete with residuals and a named next owner.
6. No ADR 0025 acceptance, Product Gate, Release default-on or user-facing performance budget is
   claimed by this Assignment.

## Stop Conditions

- A required Assignment field, evidence template or authority source becomes `UNKNOWN` or
  contradictory.
- A test or capture requires raw user content, candidate text, destructive reset, coordinate
  typing, unsafe isolation or default-gate changes.
- Xcode/CoreSimulator/device services are unavailable; record the environment blocker rather
  than creating or erasing a replacement device.
- Real runtime requires wiring production `RimeEngineImpl` across an unreviewed isolation boundary,
  changing ADR 0004, or using `@unchecked Sendable`.
- App Group/tool output is empty or inaccessible; do not infer absence of the container or runtime.
- A failure would require a product choice about timeout budgets, default gate, dropped input,
  host text semantics or Release acceptance.

## Handoff

- Handoff Target: Independent Architecture reviewer, then independent Quality reviewer; final
  residual decision returns to Product Lead.
- Required Handoff Content: matrix classification, changed-file allowlist, exact commands,
  focused/full results, Run IDs and hashes, skipped/blocked observations, privacy scan and
  teardown/restore proof.
- Revalidation Trigger: marker schema, owner/recovery implementation, build flags, target/device/
  OS, RIME artifact/schema, Full Access, persistence writer, ADR 0025 status or Product Gate
  decision changes.

## Current Preflight Record (2026-08-02 Asia/Shanghai)

- P2-D1 final code/docs are present; Architecture and Quality both returned **Pass with
  conditions** on the final tip.
- `swift test --package-path Packages/KeyboardCore --filter ResponsiveRimePipelineTests`：
  **23/0**。
- `swift test --package-path Packages/KeyboardCore --filter ThreadAffineRimeSpikeTests`：
  **10/0**。
- `swift test --package-path Packages/KeyboardCore --filter ThreadAffineRimeWireTests`：
  **10/0**（包含 owner restart 后旧 epoch snapshot 被拒绝的回归）。
- `swift test --package-path Packages/KeyboardCore --filter ResponsiveProvisionalCompositionTests`：
  **6/0**。
- `swift test --package-path Packages/KeyboardCore --filter P3D1LifecycleEvidenceValidatorTests`：**6/0**。
- `swift test --package-path Packages/KeyboardCore`：**901/0**。
  P2-D1 focused validator **28/0** 与 felt metrics **5/0** 仍为同一 final tip 的已记录基线。
- Ordinary and `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT` Swift 6 whole-source type-check both last
  returned exit 0.
- `xcrun simctl list devices available` was unavailable because CoreSimulatorService connection
  failed in the restricted invocation; an authorized read-only retry discovered iOS 27.0
  iPhone 17 Pro Max `06C5BC3E-7599-4761-A1A2-71DAEA991474` in `Shutdown` state. No simulator
  was created, erased or substituted.
- `xcrun xctrace list devices` was unavailable in the restricted environment because Instruments
  could not create its cache directory; this is a tool limitation, not evidence that no device
  exists.
- `xcodebuild -list -project "Universe Keyboard.xcodeproj"` succeeded in the authorized read-only
  retry and confirmed the `KeyboardExtensionTests` target/scheme and `RimeBridgeTests` scheme.
- `KeyboardExtensionTests` on the discovered iOS 27.0 Simulator was **Blocked at compile**
  (exit 65): the ambient `CandidatePrefetchUIContractTests` `@MainActor XCTestCase` has
  Swift 6 initializer-isolation errors. Result bundle:
  `/tmp/universe-keyboard-p3-d1-derived/Logs/Test/Test-KeyboardExtensionTests-2026.08.02_17-02-20-+0800.xcresult`.
  No test body ran; this was not treated as a runtime failure and the test source was not changed.
- Follow-up repair is recorded in [`P3-D1-T01 Test Harness Repair`](t9-responsive-pipeline-001-p3-d1-t01-test-harness-repair.md)。
  The test class is explicitly `nonisolated`, the method remains a bundle-only probe, and no
  `KeyboardViewController` appex symbol is linked from XCTest. A focused run and the full
  `KeyboardExtensionTests` target both passed **1/0**; latest result bundle:
  `/tmp/universe-keyboard-p3-d1-extension-derived/Logs/Test/Test-KeyboardExtensionTests-2026.08.02_17-18-29-+0800.xcresult`。
  This moves T01 from `Blocked` to **`Partial (bounded)`**: target build and test-bundle probe are
  proven, but Extension lifecycle wiring is still not exercised.
- `RimeBridgeTests` on the same Simulator **succeeded 54/0 with 20 skipped** (exit 0); the
  skipped cases require isolated RIME/T9 runtime directories or real-engine variables. This is
  bridge/test-target evidence only, not real Extension `RimeEngineImpl` or physical-device proof.
  Result bundle: `/tmp/universe-keyboard-p3-d1-rime-derived-r1/Logs/Test/Test-RimeBridgeTests-2026.08.02_17-19-29-+0800.xcresult`.
- The first full KeyboardCore rerun exposed one MainActor scheduler-sensitive assertion in
  `testCoalesceBacklogStillPaintsL1`; the test now uses a two-second bounded async wait and the
  subsequent full suite passed **894/0**. This is a test-only timing stabilization, not a product
  delay or performance budget.
- Therefore target row T01 is **`Partial (bounded)`**, RimeBridge bridge coverage is `Partial`,
  target-level lifecycle T02/T03 are **`Blocked (host accessibility)`**, and real-librime/
  physical-device/persistence/jetsam rows remain `NotRun`. The independent T01 Quality review is recorded in
  [`P3-D1-T01 Quality review`](t9-responsive-pipeline-001-p3-d1-t01-quality-review.md)，Architecture
  复审记录在 [`P3-D1-T01 Architecture review`](t9-responsive-pipeline-001-p3-d1-t01-architecture-review.md)。
- T02/T03 的实现与执行边界已单独建档于 [`P3-D1-T02/T03 Lifecycle Harness`](t9-responsive-pipeline-001-p3-d1-t02-t03-lifecycle-harness.md)。
  实际 `Keyboard` Extension 的 harness-on/gate-off 编译均通过；宿主 Messages 没有暴露可点击的
  系统键盘切换器，故两条 host-driven UI invocation 按契约记录为 `Blocked / Skipped`，不能升级为
  lifecycle Pass，也不能把宿主边界误判为产品失败。
- T02/T03 修复后重新绑定到 Run ID `P3D1-T02-T03-SIM-20260803-001`：marker 使用运行器注入或
  进程生成的 opaque token，target seam 增加 content-free accessibility handshake，UI test
  对 harness 缺失、owner 未 ready、PUBLISH/clear 缺失 fail-closed。宿主仍在 activation
  boundary 前 Skip，因此这些断言尚未产生 target runtime Pass。
- 2026-08-03 Product Lead 选择 Option 1 Product Hold：T02/T03 保持
  `Blocked (host accessibility)`，不追加代码、测试或设备运行；后续重新打开必须新建明确
  Product Assignment，不得从当前 hold 自动推导出 target/Release/Product Gate 权限。

## Independent Review Disposition and Documentation Closure

- [`P3-D1 Architecture review`](t9-responsive-pipeline-001-p3-d1-architecture-review.md)：**Pass
  with conditions（pre-repair snapshot）**。该复审当时将 T01 记录为入口 Blocked；修复后该
  观察由当前 matrix 的 `Partial (bounded)` 取代。C04/C07 仍为 `Partial`，T02/T03 当前为
  `Blocked (host accessibility)`、R01–R06 仍为 `NotRun`；没有接受 ADR 0025 或授权生产接线。T01 修复是否需要 Architecture re-review
  由后续 owner 决定。
- [`P3-D1 Quality review`](t9-responsive-pipeline-001-p3-d1-quality-review.md)：**Pass with
  conditions（deterministic Core preflight；pre-repair snapshot）**；整张矩阵为 `Partial`。
  该复审已确认 focused/full KeyboardCore、隐私/Run ID/Unavailable/Blocked 合同及人工输入
  边界，但其 T01 环境状态是修复前快照。
- [`P3-D1-T01 Quality review`](t9-responsive-pipeline-001-p3-d1-t01-quality-review.md)：**Pass
  with conditions（bounded harness repair）**；确认 `KeyboardExtensionTests` 1/0、
  `RimeBridgeTests` 54/0 + 20 skipped、KeyboardCore 894/0 以及 bounded timing 修复；T01
  仍为 `Partial (bounded)`，不升级 T02/T03 或真实 RIME/设备证据。
- [`P3-D1-T01 Architecture review`](t9-responsive-pipeline-001-p3-d1-t01-architecture-review.md)：
  **Pass with conditions（bounded harness repair）**，P0/P1/P2/P3 = `0/0/0/2`；确认
  `nonisolated`、bundle-only probe 和 bounded polling 均未越界，并要求保留 hunk/source
  fingerprint、禁止把 bundle probe 升级为 lifecycle 证据。
- Architecture 复审指出的矩阵文档条件已收敛：Required Inputs 补列 ADR 0002，矩阵
  `Current state` 使用 `Passed`/`Partial`/`Blocked`/`NotRun` 枚举，R02 证据改为
  content-free immutable export（或 privacy-scanned controlled attachment），T01 repair
  Assignment 另列 repair-only fingerprints。C04/C07 的证据条件仍未补齐，因此**父级
  P3-D1 Assignment 继续保持 `Active`**，不宣称 P3-D1 runtime 完成。
- T02/T03 子件 [`P3-D1-T02/T03 Lifecycle Harness`](t9-responsive-pipeline-001-p3-d1-t02-t03-lifecycle-harness.md)
  已选择“宿主驱动 Simulator + target-only seam”边界并完成实现；明确
  `KeyboardExtensionTests` 不得通过直接链接 appex symbol 冒充生命周期证明。当前 T02/T03
  是 `Blocked (host accessibility)`，已请求独立 Architecture / Quality 对修复后的 marker、
  handshake、epoch barrier 和 provenance 重新复审，不升级真实 RIME、设备、持久化、jetsam
  或 Product Gate 结论。

## Changed-file Allowlist for This Design/Preflight and T01 Repair Phase

- Design/preflight phase: this Assignment file only (plus links added to the completed P2-D1
  contract/evidence documents).
- T01 repair phase: [`CandidatePrefetchUIContractTests.swift`](../../KeyboardExtensionTests/CandidatePrefetchUIContractTests.swift)
  and only the bounded-wait hunk in
  [`ResponsiveProvisionalCompositionTests.swift`](../../Packages/KeyboardCore/Tests/KeyboardCoreTests/ResponsiveProvisionalCompositionTests.swift)，
  as enumerated by the repair Assignment. Other pre-existing hunks in that test file remain
  ambient and are not attributed to this phase.
- T02/T03 implementation phase: the existing `Keyboard` lifecycle sources and presentation seam,
  `Packages/KeyboardCore` coordinator + focused regression, the existing
  `UniverseKeyboardUITests` host-driven test file, and the child Assignment execution record;
  the seam is compile-flag-only and no Release/project default was changed.
- No production source, Xcode project, ADR status, default gate or device evidence artifact is
  changed by either phase.

This Assignment is a matrix and evidence contract. It does not itself prove any runtime row.
