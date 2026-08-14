# Product Decision: RELEASE-2026-0801 — 目标日期改期

**Decision ID:** `PD-RELEASE-2026-0801-TARGET-REDATE`
**Lifecycle status:** `Recorded`
**Date / timezone:** `2026-08-14 Asia/Shanghai`
**Assignment:** [`RELEASE-2026-0801`](../assignments/release-2026-08-01.md)
**Evidence ledger:** [`release-2026-08-01-acceptance.md`](../evidence/release-2026-08-01-acceptance.md)

## Authority

- **Product Approver / Decision maker:** Human Product Owner / Product Lead
- **Decision Source:** Human Product Owner 在 Active Work 收敛复核中明示「改期，改到 8 月 26 号」
- **Assignment Authority:** Product Lead under [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md)

本 Decision 只改 **目标可用日期**。它不冻结新的 release commit、不授权 TestFlight / App Store 上传、不跳过子项 Gate、不改变 `RELEASE-2026-0801-02` 的功能/支持范围。

## Bound Product Decisions

1. Work Item ID 仍为 `RELEASE-2026-0801`（历史标识不改名）。
2. 现行目标日期为 **`2026-08-26 Asia/Shanghai`**。
3. 原目标 `2026-08-01 Asia/Shanghai` 保留为历史值；过期本身已触发 Assignment 的 Revalidation Trigger，本 Decision 完成该次再验证中的日期部分。
4. 子项生命周期、Entry Criteria、Architecture No-Go 与未命名 Executor 不因改期而自动满足。

## Explicit non-authorization

- App Store 提交、审核或手动发布
- 跳过 01 / 04 / 05 / 06 / 07 / 08 / 09 的未满足门
- 把 Typing Intelligence 或 contextual typo correction 纳入首发宣称
- 关闭本伞 Assignment

## Related Documents

- [`assignments/release-2026-08-01.md`](../assignments/release-2026-08-01.md)
- [`evidence/release-2026-08-01-acceptance.md`](../evidence/release-2026-08-01-acceptance.md)
- [`ACTIVE_WORK.md`](../ACTIVE_WORK.md)
