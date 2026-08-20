# Product Decision: RELEASE-2026-0801 — 最低系统改为 iOS 18.0

> **Phase 2 supersession:** `2026-08-19 Asia/Shanghai` — [`PD-RELEASE-2026-0801-10-PHASE2-NARROW`](RELEASE-2026-0801-10-phase2-narrow.md) 收窄并 Human 接受 Phase 2。下文「Phase 2 未授权 / 不得宣称已验证」不再是当前状态。


**Decision ID:** `PD-RELEASE-2026-0801-MINIMUM-OS-IOS18`
**Lifecycle status:** `Recorded`
**Date / timezone:** `2026-08-18 Asia/Shanghai`
**Assignment:** [`RELEASE-2026-0801-10`](../assignments/release-2026-08-01-10-ios-18-target.md)
**Parent:** [`RELEASE-2026-0801`](../assignments/release-2026-08-01.md)
**Supersedes:** [`RELEASE-2026-0801-02`](../assignments/release-2026-08-01-02-scope-freeze.md) 的 Minimum OS 行；以及 [`RELEASE-2026-0801-09`](../assignments/release-2026-08-01-09-ios-26-target.md) 的 iOS 26.0 实施目标

## Authority

- **Product Approver / Decision maker:** Human Product Owner / Product Lead
- **Decision Source:** Human Product Owner 在 Active Codex 任务中明示：为覆盖更多用户，V1.0 最低系统从 iOS 26.0 改为 iOS 18.0；先过编译，键盘 iOS 18 样式后补
- **Assignment Authority:** Product Lead under [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md)

本 Decision 只改 **V1.0 最低系统**。它不授权 iOS 18 外观已可用、不授权 TestFlight / App Store 上传、不跳过子项 Gate、不改变 RIME / Extension 所有权。

## Bound Product Decisions

1. V1.0 最低系统现为 **iOS 18.0 and later**。
2. 历史冻结值 `iOS 26.0 and later` 保留为审计记录，不再约束实施目标。
3. 实施分两期，且必须分开验收：
   - **Phase 1（本 Decision 立即授权）：** 全部 App / Extension / 测试 target 与本地 Package platforms 对齐到 iOS 18.0；只修编译器证明的 unavailable API。
   - **Phase 2（已被收窄并 Human 接受）：** 见 [`PD-RELEASE-2026-0801-10-PHASE2-NARROW`](RELEASE-2026-0801-10-phase2-narrow.md)。不再要求整套表面重写。
4. `RELEASE-2026-0801-09` 的 26.0-only 实施目标被取代；不得再把 26.0 runtime 缺失当作本最低系统工作的 Entry blocker。
5. 本地可用的 Xcode（含 beta）可用于 Phase 1 编译证据。该证据 **不是** 稳定工具链、Archive 或发布证明。
6. App Store 文案可以陈述最低系统为 iOS 18.0，并可以引用 Human 已接受的收窄 Phase 2。不得把本次观察写成独立 Quality、完整设备矩阵或已上架。

## Explicit non-authorization

- iOS 18 键盘样式、圆角容器或 Liquid Glass fallback 的产品完成
- 把 beta Xcode 编译结果当作 Release / Archive 证据
- 跳过 `RELEASE-2026-0801-01` / `04` / `05` 或最终 Product Gate
- App Store 提交、审核或手动发布
- 改变 RIME 部署所有权、Extension 热路径或 Full Access 合同

## Related Documents

- [`assignments/release-2026-08-01-10-ios-18-target.md`](../assignments/release-2026-08-01-10-ios-18-target.md)
- [`assignments/release-2026-08-01-02-scope-freeze.md`](../assignments/release-2026-08-01-02-scope-freeze.md)
- [`assignments/release-2026-08-01-09-ios-26-target.md`](../assignments/release-2026-08-01-09-ios-26-target.md)
- [`evidence/release-2026-0801-10-ios-18-target-architecture-review.md`](../evidence/release-2026-0801-10-ios-18-target-architecture-review.md)
- [`evidence/release-2026-08-01-acceptance.md`](../evidence/release-2026-08-01-acceptance.md)
