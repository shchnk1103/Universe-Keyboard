# PF-003 — TYPO-CORRECTION-002 子项生命周期收尾

父任务 `TYPO-CORRECTION-002` 于 2026-10-11 Closed（PR #210）。其子 Assignment 大多仍显示 Active / Reviewed，原因是 Assignment Policy 规定“只要有残项没有处置，就不能 Close”，且没有 Cancelled / Superseded 状态。收尾按批进行：每个 Work Item 先由 Executor 回原文枚举全部残项并找出来源明确的处置，缺口项不关闭；再经 Architecture 与 Quality 两位独立 Reviewer 评审；最后由 Human 决定 push 与 merge。

## 已决定

- D1：子项按批收尾；D7：同步 / 收尾记录评审后直接 Close。（Human，2026-10-22）
- 允许的残项处置只有 `fix | accept | tech_debt:<ID>`；`tech_debt` 必须在 `docs/TECH_DEBT.md` 有同名条目。
- D-1B-AUTH、D-1C-AUTH：不修改任何 `docs/authorizations/` 文件；Closeout 逐项记录其现状并声明不可重放；TD-014 只作引用。
- A16 的原 query-density Product 残项：accept 为**受限未知**，不是性能 Pass，不新建 tech_debt；A18 的同一残项留给后续批次，沿用此决定。
- RimeRuntimeProvenance 缺口：Product Lead 明确 accept（批次 1）。
- 批次 1c 的三处映射 J1、J4、J5：Product Lead 明确 accept（2026-10-22），记录在批次 1c Assignment 的 “Remediation round 1”。

## 批次

| 批次 | 内容 | 状态 | 依据 |
|---|---|---|---|
| 1 | 关闭 7 项（A1、A23、A19、A20、A21、C1、C3） | Done | PR #223，`cd0b850` |
| 1b | 关闭 A16、A27 | Done | PR #224，`e828a99` |
| 1c | hardening 链四项：`…RUNTIME-INTEGRATION-DESIGN-001`、`…IMPLEMENTATION-001`、`…HARDENING-001`、`…HARDENING-BLOCKER-REMEDIATION-001`，并新增 F-04 tech_debt | Done | PR #225，`64385fe`；`LIFECYCLE-CLOSEOUT-BATCH-1C-001` |

## 待办

- 链批次剩余：`second-stage-recall-runtime-design-001`、`runtime-preflight-implementation-001`、`recall-remediation-publication-preflight-001` 的残项处置来源尚未核实（AR-01 到 AR-04 是否已落地；canonical group mapping P1；contextual 7/8 UNKNOWN）。
- A18：同一条 query-density 残项，按上面的决定处理。
- A28、A29：F-02 / QR-01 的处置来源没找到，保持不动。
- 同链下的 publication / preparation / final-SHA-quality-publication 子 Assignment：1c 未碰，另行处理。
- B 区：delivery-001 / 002 / 003 与 UI-1 的 Lifecycle 处置尚未决定（UI-1、`ACTIVE_WORK` 第 6 项当前均为 Active，UI-1 的同步记录明确无完成声称）；UI-2 因 TD-020 保持 Active。此前设想“只推进到 Completed、不 Close”，未经 Human 决定，也未执行。

## 仍为 UNKNOWN

批次 1 中 PR #210、#221、#222 的 Final Merge Gate / Merge 授权记录；物理设备 Apple Development 身份；已合并树（PR #144）是否逐字节包含当时冻结的快照。

任务文件（本地、不在仓库内）：`~/.kos-work/Universe-Keyboard/LIFECYCLE-CLOSEOUT-BATCH-{1,1B,1C}-001/`。
