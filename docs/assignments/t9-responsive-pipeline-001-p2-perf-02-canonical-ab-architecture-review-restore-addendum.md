# Architecture Review Addendum：P2-PERF-02 canonical A/B restore update

| 字段 | 结论 |
|---|---|
| 复审角色 | 🏛️ Architecture & Knowledge Steward（独立、只读） |
| 日期 | 2026-08-03（Asia/Shanghai） |
| 上一份复审 | [`Canonical A/B Architecture review`](t9-responsive-pipeline-001-p2-perf-02-canonical-ab-architecture-review.md) |
| 更新对象 | [`Canonical A/B evidence`](../evidence/t9-responsive-pipeline-p2-perf-02-canonical-ab-2026-08-03.md)、[`summary JSON`](../evidence/t9-responsive-pipeline-p2-perf-02-canonical-ab-summary-2026-08-03.json) |
| Pair ID | `P2P02-CANONICAL-AB-20260803-001` |
| 原 verdict | **Pass with conditions（bounded canonical A/B runtime evidence）** |
| 本次更新 | **ARCH-P2-CANONICAL-AB-P2-04：bounded evidence closed** |
| 治理边界 | 不接受 ADR 0025，不宣布 Product Gate、Release 或默认开启 |

## 1. Restore 新证据

更新后的 Assignment、evidence 与 summary 均记录：

- 同一 source snapshot 构建的普通 `Release` 包；没有注入任何 `T9_*` compilation condition；
- Restore App SHA-256：`fde6743792f4441f58130ff689b255a547d21eb9b1e3b1d9b238a20f835654f1`；
- Restore Keyboard.appex SHA-256：`612b4e0792ce4245ddb074c59148ec1a20c8ad10a1cee465fab3034db4c67845`；
- device install database sequence：`3768`；
- Human 一键 smoke：按键生效、键盘保持可见、键盘未退出；
- 未清除 source、user settings、App Group logs、Reminders data 或设备状态。

这组材料足以证明诊断 A/B 包已被替换为同源普通 gate-off 包，并完成了授权范围内的最小
可见恢复冒烟。

## 2. Finding disposition

### ARCH-P2-CANONICAL-AB-P2-04：Closed（bounded evidence layer）

原复审中“普通 restore pending、没有 restore identity/smoke”这一证据缺口已经闭合。它的
关闭范围仅是：普通包身份可追溯、安装成功、Human 一键键盘 smoke 通过。

这不等于长句性能恢复、进程终止/重载、schema/readiness、jetsam/memory 或完整 keyboard
lifecycle 已通过；单键 `smoke` 也不改写 A/B 的 Human score、engine lag 或任何 SLO。

原 Architecture review 的总体 verdict 不变。原始计数为 `P0/P1/P2/P3 = 0/0/4/2`；本
addendum 关闭一个 P2 后，当前仍开放的证据边界为 `0/0/3/2`（计数仅表示本次复审残余，
不是 Product/Quality Gate）。

## 3. 仍然开放的边界

- **P2 A/B envelope：** Full Access、opaque host ID 与 dirty untracked-content provenance
  仍未完整观察；A=2/4 → B=0.5/4 仍只是单 pair 方向性比较。
- **P2 geometry：** per-arm digest 含 run token 的设计保持正确，但 tokenless normalized
  geometry bytes/digest 尚未归档，跨臂 shape match 仍是摘要级 bounded observation。
- **P2 presentation：** B `PUBLISH 39/39` 仍然闭合 owner completion；`VISIBLE/PAINT` 的
  latest-only coalescing 允许缺少 rev 16、33 的 PAINT，但明确 coalesced receipt/reason 仍未
  形成，不能把允许的 coalesce 写成已证明的具体合并原因。
- **P3 human/replay：** 单次固定 A→B 顺序的主观评分没有重复样本或统计区间；raw attachment
  仍为受控临时文件，仓库只保留 content-free summary/hash，不形成永久 raw archive。

## 4. 文档一致性提示

复审时曾发现 evidence 顶部的历史 `Status` 行与后续 restore 小节不一致；文档 owner 随后已将
该行同步为“ordinary-package restore and one-key smoke complete”。因此当前 evidence、Assignment
execution result、summary 与本 addendum 的 restore 状态一致；剩余的 manifest/restoreRef 缺口
仍按上文列为 bounded evidence residual，不能用它重新打开已关闭的运行时 finding。

## 5. 最终结论与停止点

Restore update 只关闭 ARCH-P2-CANONICAL-AB-P2-04；原 Architecture verdict 仍为
**Pass with conditions（bounded canonical A/B runtime evidence）**。本 addendum 不把 restore
smoke 升级为 Release、Product Gate、ADR 0025 Accept、off-main 生产完成或用户性能 SLO。

本角色未修改生产逻辑、默认 gate、设备、原始附件、A/B 数值、Assignment 或 ADR；复核到此
停止。后续如补齐 Full Access、normalized geometry digest、PAINT receipt 或新的重复样本，
应按新的证据更新交由独立 Architecture/Quality 复审。
