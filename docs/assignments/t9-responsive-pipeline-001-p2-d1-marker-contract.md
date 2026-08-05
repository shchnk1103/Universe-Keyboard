# Assignment: T9-RESPONSIVE-PIPELINE-001 / P2-D1 Marker Contract

Policy version: 1.0.0  
Lifecycle status: **Completed with bounded residuals — independent Architecture and Quality reviews complete**  
Date: 2026-08-02 Asia/Shanghai

## Authority

- Assignment Authority: Product Lead
- Decision Source / Date: Human Product Owner authorization in the active Codex task,
  “P2-D1：明确 PUBLISH/VISIBLE 含义，并补专项回归测试”，2026-08-02 Asia/Shanghai
- Product Approver: Human Product Owner / Product Lead
- Parent Assignment: [`P2-PERF-02 Release-like`](t9-responsive-pipeline-001-p2-perf-02-release-like.md)
- Architecture Boundary: [`ADR 0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md)
  remains **Proposed**

## Boundary

### Scope

1. Freeze content-free diagnostic marker semantics:
   - `ACCEPT` means MainActor accepted/enqueued a revision;
   - `PUBLISH` means the serial owner completed and delivered that revision;
   - `VISIBLE` means the MainActor applied a visible composition snapshot;
   - `PAINT` is supplementary UI-presentation timing and may be coalesced.
2. Make the evidence validator arm-aware: sync A does not require responsive
   `ACCEPT/PUBLISH` markers; thread-affine B still requires one epoch-bound
   owner-completion `PUBLISH` for every accepted revision.
3. Make the privacy validator allow only numeric `candidates=<count>` summaries,
   while continuing to reject candidate text and malformed values.
4. Add focused regression fixtures and update the evidence contract plus a
   Proposed ADR 0025 amendment. Keep all gates and production defaults unchanged.

### Non-goals

- No change to default responsive gates, user settings, RIME/Lua, candidate ranking,
  provisional composition behavior or input-event policy.
- No production wiring of real `RimeEngineImpl` beyond the existing explicit
  diagnostic/preflight path.
- No device installation, manual input, App Group cleanup, Release/Product Gate,
  ADR acceptance or shipping decision.
- No `@unchecked Sendable`, unsafe isolation or synchronous persistence in the key path.

## Decision Record

The current evidence ambiguity is resolved as follows:

```text
ACCEPT  ── owner completes ──>  PUBLISH  ── optional UI apply ──>  VISIBLE
                                      └── timing/coalescing ──>  PAINT
```

`PUBLISH` is therefore not a promise that every accepted revision was painted.
Under latest-only UI coalescing, intermediate revisions may have no individual
`VISIBLE` or `PAINT`; they must still have an owner-completion `PUBLISH` unless
the revision was invalidated by an epoch barrier.

## Assignment

- Domain Owner: 🧪 Quality, Performance & Release Maintainer
- Executor: Current Codex task
- Environment Executor: Not Applicable — this child task performs no device or deployment operation
- Human Dependency: Not Applicable — the Product Lead decision is supplied in this Assignment
- Architecture Reviewer: Independent Architecture & Knowledge Steward
- Quality Reviewer: Independent Quality, Performance & Release Maintainer

## Required Inputs

- [`P2-H-06 device evidence`](../evidence/t9-responsive-pipeline-p2-perf-02-device-2026-08-02.md)
- [`P2-H-06 Architecture review`](t9-responsive-pipeline-001-p2-perf-02-device-architecture-review.md)
- [`P2-H-06 Quality review`](t9-responsive-pipeline-001-p2-perf-02-device-quality-review.md)
- [`P2-PERF-02 Evidence Contract`](t9-responsive-pipeline-001-p2-perf-02-evidence-contract.md)
- [`ADR 0025 Proposed`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md)

## Entry Criteria

- Product Lead has authorized P2-D1.
- Existing ambient worktree changes are preserved and not treated as this child task's diff.
- The implementation remains limited to KeyboardCore diagnostics/validator/tests and
  the named contract documents.

## Exit Criteria

1. Source and validator use the four marker meanings above without duplicate
   owner/UI `PUBLISH` semantics.
2. Focused tests cover sync-positive, thread-affine missing-publish negative,
   owner-completion/paint separation, coalescing, and privacy count/text cases.
3. `swift test --package-path Packages/KeyboardCore` focused and full results are
   recorded, or the exact environment blocker is recorded.
4. Independent Architecture and Quality reviewers receive the changed-file allowlist,
  test output and Proposed ADR/contract updates; both reviews return Pass with conditions.
5. The parent Assignment remains diagnostic-only and historical B evidence remains `Partial`
   until a separately authorized real-device rerun.

## Stop Conditions

- Any change would alter production defaults, input behavior, RIME ownership, Lua,
  user settings or ADR status.
- A test requires real user text, coordinate automation, device cleanup or a new
  true-librime run.
- The two marker meanings cannot be represented without unsafe Swift 6 isolation.
- Existing ambient changes would need to be overwritten or staged broadly.

## Handoff

- Handoff Target: Independent Architecture reviewer, then independent Quality reviewer
- Required Handoff Content: decision summary, changed-file allowlist, validator fixtures,
  focused/full test output, skipped environment checks and residual runtime limits
- Revalidation Trigger: marker schema change, owner delivery/coalescing implementation,
  validator privacy policy, gate/build flags, device/OS/toolchain or ADR status change

## Verification snapshot (2026-08-02 Asia/Shanghai)

### Passed

- `swift test --package-path Packages/KeyboardCore --filter T9ResponsiveEvidenceValidatorTests`：
  **28 tests，0 failures**。
- `swift test --package-path Packages/KeyboardCore --filter ResponsiveRimeFeltMetricsTests`：
  **5 tests，0 failures**。
- `swift test --package-path Packages/KeyboardCore`：**894 tests，0 failures**。
  仅有既存 `T9PinyinPathTests.swift` 的 optional interpolation warning；没有新增失败。
- 新增 metrics 回归验证 session epoch 变化后 revision 计数重用仍可产生一次合法
  `PUBLISH`，避免旧 epoch 的去重集合误伤新 session。
- Swift 6 全源 type-check 在普通条件与
  `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT` 条件均通过；Type-check 使用临时
  `Bundle.module` resource stub，仅绕过直接调用 `swiftc` 时 SwiftPM 不生成资源访问器的差异。
- `git diff --check` 通过。

### 未执行与原因

- XcodeBuildMCP iOS Simulator XCTest 未执行：当前缓存的 simulator UDID
  `D3C353BE-3AA6-499B-8F87-349073D65BE4` 不存在，目的地解析失败；没有自动创建或擦除模拟器。
- 真机、真实 librime、Extension jetsam、App Group 持久化/恢复和 Release/Product Gate 未执行；
  均不在 P2-D1 授权范围。

### Changed-file allowlist

- `Packages/KeyboardCore/Sources/KeyboardCore/T9ResponsiveEvidenceValidator.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/ResponsiveRimeFeltMetrics.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController.swift`（仅 owner-completion/
  presentation marker 接线）
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/T9ResponsiveEvidenceValidatorTests.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/ResponsiveRimeFeltMetricsTests.swift`
- 本 Assignment、P2-PERF-02 Evidence Contract、ADR 0025 Proposed amendment

## Final disposition

- Independent Architecture：**Pass with conditions**；独立 Quality：**Pass with conditions**。
- P2-D1 的 marker 语义、validator、隐私规则、owner/UI 分离和 epoch/revision 回归已完成。
- 保留的 bounded residual：真实运行时所有 reset/recover/late-result 入口的生命周期矩阵、
  真实 librime/Extension/Simulator/真机/Release/jetsam/App Group persistence 证据均未执行。
- 后续已建立独立的 [`P3-D1 Runtime Lifecycle Evidence Matrix`](t9-responsive-pipeline-001-p3-d1-runtime-lifecycle-matrix.md)，
  其设计/预检阶段不改变生产逻辑；各真实运行层仍须按矩阵逐层取证。
- 本记录不把上述通过结果升级为 ADR 0025 Accepted、Production Gate、Release 或默认开启；
  后续若要关闭 runtime residual，需另建并授权专门子件。
