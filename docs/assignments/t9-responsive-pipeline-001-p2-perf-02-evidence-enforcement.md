# Assignment: T9-RESPONSIVE-PIPELINE-001 / P2-PERF-02 Evidence Enforcement

Policy version: 1.0.0
Lifecycle status: **Reviewed — Pass with conditions; follow-up required**
Date: 2026-08-01 Asia/Shanghai

## Authority

- Assignment Authority: Human Product Owner / Product Lead
- Decision Source / Date: explicit authorization in the active Codex task,
  2026-08-01 Asia/Shanghai
- Parent Assignment: [`P2-PERF-02`](t9-responsive-pipeline-001-p2-perf-02-release-like.md)
- Contract: [`P2-PERF-02 Evidence Contract`](t9-responsive-pipeline-001-p2-perf-02-evidence-contract.md)
- Related Architecture Boundary: [`ADR 0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md),
  remains `Proposed`

## Objective

将 P2-PERF-02 取证合同落实为可观察、可回归、可判定的诊断基础设施，关闭当前
B 证据中的导出、session、geometry 和自动判定缺口。实现必须保持输入事件保序，
不得把诊断工作变成按键热路径上的同步等待。

## Scope

1. Internal preflight evidence export must include `T9RESP` engine-category markers
   in the content-free subset; ordinary Release remains unchanged.
2. Thread-affine owner must publish a native, content-free RIME session snapshot
   through a `Sendable` value result. The MainActor must not access the owner-thread
   engine directly.
3. The device-preflight geometry context must survive the documented extension UI
   reload boundary, or fail closed with an explicit `unavailable` state rather than
   silently changing the run token/digest.
4. Add pure validator tests for the P2 evidence contract: token, 39 ordered rows,
   marker ordering, session/geometry state, legacy `T9ARM` checkpoint semantics,
   privacy, and `Complete`/`Partial`/`Blocked` classification.
5. Update the relevant diagnostics documentation with implementation status and
   test evidence; do not rewrite historical B evidence as complete.

## Non-goals and prohibitions

- No change to default responsive gates, user settings, RIME/Lua, candidate ranking,
  provisional composition semantics or input-event policy.
- No `@unchecked Sendable`, unsafe actor escape, synchronous MainActor-to-engine call,
  or production wiring of the real thread-affine bridge outside the existing explicit
  preflight gate.
- No input drop, merge, reorder, coordinate automation, Computer Use typing or new
  real-device A/B run in this implementation step.
- No ADR 0025 acceptance, Product Gate, R6, Release default-on or shipping claim.
- No destructive device/container/RIME/userdb operation.

## Required implementation constraints

- Runtime records remain content-free: no pinyin, candidate, marked text, host text or
  user dictionary data.
- The owner thread is the only place allowed to touch the non-Sendable RIME engine.
- Session snapshots must be captured on the owner thread and transported as value data.
- Existing S6-A `T9ARM actions=38` remains a historical checkpoint; P2 validation derives
  the 39-action count from `T9SEG` rows.
- Diagnostics export must use all categories so engine `PATH/READY` lines are not lost.

## Deliverables

- Source changes limited to the internal diagnostics/preflight and test surfaces.
- Pure validator and focused regression tests.
- Test commands, results and skipped device checks recorded in handoff evidence.
- Updated links/status in the parent Assignment and evidence contract if necessary.

## Acceptance criteria

1. `T9RESP PATH/READY` is present in the internal content-free evidence export and a
   regression test prevents it from being filtered out.
2. A thread-affine diagnostic run can expose a non-zero native session identity and
   `valid=true` without touching the engine from MainActor; the absence case remains
   explicit and testable.
3. Prepared and execution geometry either carry the same token/digest across the UI
   reload boundary or produce a clear `unavailable` classification; no `run=invalid`
   is silently interpreted as valid.
4. Validator tests reject missing/duplicate/reordered rows, mixed tokens, raw content,
   invalid session/geometry and wrong marker ordering, while accepting the declared
   39-row content-free fixture with a legacy `T9ARM` checkpoint.
5. Existing KeyboardCore tests and relevant app/diagnostic tests pass; no default gate
   or production input behavior is changed.
6. Handoff explicitly lists what remains unverified: real-librime long-run behavior,
   physical-device A/B rerun, jetsam/memory, iOS 26.0 Release RC and Product Gate.

## Stop conditions

- Fix would require changing product semantics or default gates.
- The only way to move a session snapshot is unsafe cross-isolation transfer.
- A test would need raw user content, coordinate typing or destructive reset.
- Existing unrelated dirty files would need to be overwritten or staged.

## Handoff

Target: independent Architecture reviewer, then independent Quality reviewer.
Required handoff: changed-file allowlist, test output, content-free sample/fixture,
known limitations, and explicit statement that no real-device run was performed by
this implementation step.

## Independent review reconciliation

- [Architecture review](t9-responsive-pipeline-001-p2-perf-02-evidence-enforcement-architecture-review.md)：
  **Bounded Pass with conditions**，P0/P1/P2/P3 = **0/0/6/1**。
- [Quality review](t9-responsive-pipeline-001-p2-perf-02-evidence-enforcement-quality-review.md)：
  **Pass with conditions（bounded implementation/evidence review）**，P0/P1/P2/P3 =
  **0/0/6/1**。

两份独立结论一致：owner-thread isolation、Sendable session snapshot、allow-list、geometry
retry 意图和 default-off 边界可接受；但本 Assignment 不能标记为 `Complete`，也不能把
历史 B 证据升级为完整运行证据。开放条件归并为：

1. PATH/READY 是否进入 mandatory preflight persistence channel；
2. PATH/READY 的 fixture、gate、owner-readiness 和 run identity schema；
3. geometry 唯一 digest、非法 digest 拒绝，以及 `unavailable → success` retry 终态；
4. validator 的 epoch、字段完整性和 fail-closed 分类；
5. owner readiness timeout 的显式状态；
6. 最终 artifact、真实 librime、iPhone 13 Pro、日志导出、jetsam/内存和 Release RC
   运行证据。

这些条件不改变本子 Assignment 的已交付代码；Product Lead 已明确授权新的
Evidence Hardening 子 Assignment，当前实现与后续复审均必须在该子 Assignment 的
边界内进行。本任务保持 `Reviewed` 而非 `Closed`。

## Verification snapshot

本子 Assignment 的实现范围已完成，但不改变 P2-PERF-02 历史 B 证据的判定：

- `T9ResponsiveEvidenceValidatorTests`：9 tests / 0 failures；覆盖 39 行完整样本、
  旧 `T9ARM actions=38` checkpoint、缺失/重复/乱序、PATH/READY、session、geometry、
  revision 顺序、隐私违规和缺失 run binding。
- `ThreadAffineRimeWireTests`：8 tests / 0 failures；包含 owner-thread native
  session snapshot 的 Sendable 值传输回归。
- `ThreadAffineRimeSpikeTests`：10 tests / 0 failures；包含 owner deinit、150ms+
  阻塞引擎下 MainActor 仍可 enqueue 的既有 Spike 证明。
- KeyboardCore 全量：871 tests / 0 failures。
- 独立 Quality 复审在当前 tip 上完成了 `Release` generic `platform=iOS` app +
  extension build（`CODE_SIGNING_ALLOWED=NO`，仅命令行注入诊断 flags）；产物字符串
  扫描确认含有 `T9ResponsiveEvidenceValidator`、`T9DEVICE_DISABLED`、
  `T9GEOM phase=execution`、`T9RESP marker=PATH/READY`。artifact fingerprint：
  app `12ebd0861f22816fc6edbfaaa9907bf986d01823c37b2e9bac85678b8ea5262b`，extension
  `5737b06c4a9f55f8a537f572150a22acb0f5d9931ea8c5c1801f716500569041`。这仍只是
  unsigned generic 编译证明，不是安装或真机运行证明。

### 本子 Assignment 的 changed-file allowlist

- `Packages/KeyboardCore/Sources/KeyboardCore/T9DevicePreflightEvidenceLineFilter.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/T9ResponsiveEvidenceValidator.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/T9ResponsiveEvidenceValidatorTests.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/ThreadAffineRimeSpike.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/ThreadAffineRimeSession.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/ThreadAffineRimeWireTests.swift`
- `Keyboard/Controllers/KeyboardViewController+DevicePreflight.swift`
- `Keyboard/Controllers/KeyboardViewController.swift`
- `Universe Keyboard/Views/Diagnostics/T9DevicePreflightEvidenceView.swift`
- 本子 Assignment、P2-PERF-02 evidence contract 和 parent Assignment 的链接/状态补充。
- 已完成 bounded 复审的 [Evidence Hardening 子 Assignment](t9-responsive-pipeline-001-p2-perf-02-evidence-hardening.md)。

### 未执行与停止边界

- 未进行新的 iPhone 13 Pro 真机输入、安装、诊断日志导出或 A/B Pair；此前 B 证据仍按
  `Partial` 保留，不能由本次编译/单元测试补值。
- 未证明真实 librime 长句行为、Extension jetsam/内存稳定性、iOS 26.0 Release RC、
  跨设备一致性或 Product Gate。
- 未打开任何默认 gate，未改输入语义、RIME/Lua、候选策略或事件保序合同。

Evidence Hardening 完成独立 Architecture / Quality 复审后，仍需 Product Lead 单独
决定是否进行真实设备重跑、生产接线、ADR 0025 Accept 或默认开启；本子 Assignment
本身不授予这些权限。
