# PF-010 — 下一次 TestFlight 的门禁清单

本文是指针与讨论背景，**不是状态权威**。它不是 Release 授权、Product Decision 或 Assignment。“是否仍适用”一列只记录仓库没有给出下一次范围时的缺口，不把历史条款改写成已经适用于下一次发布。

目录状态：`Blocked`。Human 打算在 UI-4 完成之后发布；无日期，无候选构建。这是意向，不是授权。

## 门禁

| 项 | 出处 | 仓库里怎么写 | 是否仍适用 |
|---|---|---|---|
| 先定这次 TestFlight 的范围 | [发布清单](../RELEASE_CHECKLIST.md) 第 66–68 行 | 未决合同必须按确切 TestFlight 范围分类；“接受风险”只允许范围很窄的内部构建，且须 Human 批准 | 下一次的范围尚未决定，所以本列不能填成“适用”或“不适用” |
| TD-003 Extension 性能基线 | 同文件第 72 行 | 更广的外部 TestFlight 默认 Blocker | 取决于上一项的范围，本次不填 |
| TD-004 完全访问降级矩阵 | 同文件第 73 行 | 声称可自诊断或覆盖完全访问开/关的外部测试，默认 Blocker | 同上。与 UI-4“完全访问开/关均可调节”的方向相关，关系未在本任务裁定 |
| TD-005 崩溃 / jetsam / 符号化手册 | 同文件第 74 行 | 更广的外部 TestFlight 在保留确切 archive/dSYM 并走过采集流程之前，默认 Blocker | 同上 |
| TD-002 活动 Extension 的用户词典访问 | 同文件第 75 行 | 外部测试包含键盘可能在写时的恢复/重置，或声称并发安全时，默认 Blocker | 同上 |
| 未说明的遗漏 | 同文件第 77 行 | 说不清的遗漏既不是范围跳过也不是接受风险，会阻塞 TestFlight | 同上 |
| 真实 RIME T9 恢复集成 | [AUTH-INPUT-RELIABILITY-DELIVERY-003-PRODUCT-PR](../authorizations/AUTH-INPUT-RELIABILITY-DELIVERY-003-PRODUCT-PR.md) 第 10 行；[独立评审回执](../evidence/input-reliability-delivery-003/independent-review-received.md) 第 12–15 行 | 必须在 TestFlight 之前处置；[delivery-003](../assignments/input-reliability-delivery-003.md) 第 76 行写是否已处置为 UNKNOWN | 该授权记录仍在；是否已经处置：UNKNOWN。本列不改成“已完成” |
| 激活后 Extension 的真实系统交互 | 同上 | 同上 | 同上 |
| 上传、预检、分组、Beta Review 分开授权 | [发布清单](../RELEASE_CHECKLIST.md) 第 79 行起 | 上传不等于分配测试者或提交 Beta Review；重新构建即新候选身份 | 条文仍在；下一次是否走这条路径：未决定 |
| 历史 Release 决定 | 发布清单与 2026-08-01 / Build 55 / Build 94 的历史决定（见 `docs/assignments/release-2026-08-01.md` 一带；本任务未逐份重读） | 它们是否仍约束下一次：UNKNOWN | UNKNOWN，不在本任务里判定 |

## 讨论（未核对，不是决定）

Human 于 2026-10-23 说打算在 UI-4 完成之后做下一次 TestFlight。无日期，无候选构建。这不授权构建、上传或分发。

## 治理提示

分类 TD-002 / 003 / 004 / 005、接受风险、上传或分发，都要另有 Assignment 与 Human 授权。本文件不执行其中任何一项。

## 2026-10-24 外部 TestFlight 方案

Human 2026-10-24 决定走方案 B（目录 PF-031，Backlog，未立项）：UI-4 与 UI-3 放进同一构建；补 TD-003 性能基线与 TD-005 归档/符号文件保留及崩溃分类演练，待 iPhone 与 Mac 都是正式版系统后重采（旧证据在 Build 55 / Xcode 27 RC / iOS beta 上）；TD-004 若不声称覆盖完全访问开/关则“有范围的跳过”；TD-002 若不含“键盘可能在写时的恢复/重置”则写成范围约束。TD 分类按范围触发，不是每次重做证据（并入 PF-025）。逐项由 Human 批准；上传、外部组、Beta App Review 各自独立授权。本节不是授权。
