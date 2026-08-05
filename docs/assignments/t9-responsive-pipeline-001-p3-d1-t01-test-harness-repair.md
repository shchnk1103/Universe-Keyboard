# Assignment: T9-RESPONSIVE-PIPELINE-001 / P3-D1-T01 Test Harness Repair

Policy version: 1.0.0  
Lifecycle status: **Completed — bounded repair and independent reviews complete**  
Date: 2026-08-02 Asia/Shanghai

## Authority and boundary

- Assignment Authority: Product Lead
- Decision Source / Date: Human Product Owner authorization in the active Codex task,
  “授权你进行单独修复和后续的任务”，2026-08-02 Asia/Shanghai
- Parent Assignment: [`P3-D1 Runtime Lifecycle Evidence Matrix`](t9-responsive-pipeline-001-p3-d1-runtime-lifecycle-matrix.md)
- Governing production baseline: [`ADR 0004`](../architecture/decisions/0004-rime-runtime-session-model.md)
- Proposed diagnostic boundary: [`ADR 0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md)
  remains **Proposed** and default-off

This Assignment authorizes only the smallest test-harness repair needed to unblock the
P3-D1-T01 target preflight, plus a test-only scheduler-stability correction discovered by the
same verification. It does not authorize production RIME rewiring, lifecycle behavior changes,
default-gate changes, real-device testing, Release acceptance or Product Gate decisions.

## Findings

1. `KeyboardExtensionTests/CandidatePrefetchUIContractTests.swift` was a Swift 6 test class with
   class-level `@MainActor`. Under the target's `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`,
   that isolated `XCTestCase` initializers that XCTest declares nonisolated, producing compile
   errors for `init()`, `init(selector:)` and `init(invocation:)`.
2. Removing only the class annotation exposed a separate link boundary: an XCTest bundle cannot
   link a concrete `KeyboardViewController` symbol from `Keyboard.appex`. The probe therefore
   no longer references an appex type; the target dependency still builds `Keyboard.appex`, and
   the test verifies only that its own XCTest bundle loads.
3. The first full KeyboardCore rerun had one timing-sensitive failure in
   `testCoalesceBacklogStillPaintsL1`: a fixed 35 ms sleep was shorter than possible MainActor
   scheduling delay under the full suite. The assertion now waits asynchronously for at most
   two seconds and still fails if the required `·····` state never appears.

## Changes

- [`KeyboardExtensionTests/CandidatePrefetchUIContractTests.swift`](../../KeyboardExtensionTests/CandidatePrefetchUIContractTests.swift)
  - declare the XCTest class `nonisolated`;
  - keep the test as a bundle-load probe, without linking an appex symbol;
  - retain the `Keyboard` module import so the Extension target remains a compile dependency.
- [`ResponsiveProvisionalCompositionTests.swift`](../../Packages/KeyboardCore/Tests/KeyboardCoreTests/ResponsiveProvisionalCompositionTests.swift)
  - replace only the fixed test sleep with a bounded asynchronous polling wait;
  - this file already contained unrelated ambient worktree edits; those hunks were preserved and
    are not claimed by this Assignment;
  - no production source or runtime behavior changed.

## Verification

All commands use the discovered iOS 27.0 iPhone 17 Pro Max Simulator
(`06C5BC3E-7599-4761-A1A2-71DAEA991474`, no device creation/erase/substitution) unless stated
otherwise.

| Check | Result | Evidence |
|---|---:|---|
| Focused `KeyboardExtensionTests/CandidatePrefetchUIContractTests` | **1/0** | `/tmp/universe-keyboard-p3-d1-extension-derived/Logs/Test/Test-KeyboardExtensionTests-2026.08.02_17-17-14-+0800.xcresult` |
| Full `KeyboardExtensionTests` | **1/0** | `/tmp/universe-keyboard-p3-d1-extension-derived/Logs/Test/Test-KeyboardExtensionTests-2026.08.02_17-18-29-+0800.xcresult` |
| `RimeBridgeTests` | **54/0, 20 skipped** | `/tmp/universe-keyboard-p3-d1-rime-derived-r1/Logs/Test/Test-RimeBridgeTests-2026.08.02_17-19-29-+0800.xcresult` |
| Focused `testCoalesceBacklogStillPaintsL1` after stabilization | **1/0** | SwiftPM focused run, 2026-08-02 17:24:24 |
| Full `Packages/KeyboardCore` | **894/0** | SwiftPM full run, 2026-08-02 17:24:58–17:25:57 |
| `git diff --check` | **pass** | current worktree check |

The 20 RimeBridge skips remain environment-gated real-runtime cases (isolated RIME/T9
directories or explicit fixture variables). They are not promoted to real RIME or physical-device
proof.

## Evidence disposition

- P3-D1-T01 is now **`Partial (bounded)`**: the Keyboard appex target builds as a dependency and
  the test bundle executes one passing probe.
- T01 does **not** prove Extension lifecycle wiring, marked-text lifecycle, real
  `RimeEngineImpl`, PATH/READY, persistence, memory or jetsam.
- P3-D1-T02/T03 and R01–R06 remain `NotRun`; no Product Gate, Release default-on or ADR 0025
  acceptance is implied.

## Independent review disposition

- [`T01 Architecture review`](t9-responsive-pipeline-001-p3-d1-t01-architecture-review.md)：**Pass
  with conditions**，P0/P1/P2/P3 = `0/0/0/2`。复审确认三项变更均为 test-only 最小修复，T01
  仍只能是 `Partial (bounded)`；残余条件是保留 hunk/source fingerprint，并禁止把
  bundle-load probe 解读为 Extension lifecycle 证据。
- [`T01 Quality review`](t9-responsive-pipeline-001-p3-d1-t01-quality-review.md)：**Pass with
  conditions**，P0/P1/P2/P3 = `0/0/0/1`。复审确认 focused/full target、Core 和 bridge
  结果的分层含义，20 个 RimeBridge skip 仍未执行真实 RIME；T02/T03、真实 RIME、真机和
  Release 仍为 `NotRun`。
- 两份独立复审均未授权生产接线、ADR 0025 Accept、default-on、Product Gate 或 Release
  结论。T01 修复子 Assignment 至此关闭；父级 P3-D1 matrix 继续保持 `Active`。

## Provenance closure

为满足 Architecture 的归因条件，本交接保留以下 repair-only source fingerprints：

- `CandidatePrefetchUIContractTests.swift` 当前完整文件字节：
  `7bf9aab583fed3828fe9567c85c4b2955b3b982d8511474d15b605cc37fdce02`。
- `testCoalesceBacklogStillPaintsL1` bounded-wait 核心代码行（UTF-8、Unix 换行、去除缩进）：
  `13fc80078e0e0b83870f0cd576215367cdc785911ce3b1011f8f255c62da0706`。

第二项只覆盖本 Assignment 声明的 bounded-wait hunk，不覆盖同一测试文件中的 ambient
改动；`Universe Keyboard.xcodeproj/project.pbxproj` 的 dirty diff 也不归因于本修复。若
后续需要提交或继续审计，应以冻结提交加上述 fingerprint/hunk allowlist 重新绑定来源。

## Handoff and next owner

Independent Architecture and Quality review is complete with the dispositions above. The next
separately scoped task, if Product Lead authorizes it, is a target-level lifecycle harness
(T02/T03) that uses a controlled Fake/Spike owner and explicit diagnostic flags. Real RIME and
physical-device phases remain separate assignments with new Run IDs and evidence contracts.

## Changed-file allowlist

- `KeyboardExtensionTests/CandidatePrefetchUIContractTests.swift`
- the bounded-wait hunk in `Packages/KeyboardCore/Tests/KeyboardCoreTests/ResponsiveProvisionalCompositionTests.swift`
- `docs/assignments/t9-responsive-pipeline-001-p3-d1-runtime-lifecycle-matrix.md`
- this Assignment file

Other pre-existing worktree changes in the test file and elsewhere remain ambient and were not
staged, reverted or attributed to this repair.

No production source, Xcode project, ADR status, default gate or device evidence artifact was
changed.
