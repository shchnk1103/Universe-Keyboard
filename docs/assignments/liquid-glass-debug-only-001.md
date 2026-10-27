# Assignment: LIQUID-GLASS-DEBUG-ONLY-001 — 实验性 Liquid Glass 仅 DEBUG 可见

**Policy version:** `1.0.0`
**Task ID:** `LIQUID-GLASS-DEBUG-ONLY-001`
**Repository Change Type:** `Implementation` + `Documentation`

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Completed` |
| **Phase** | 实现与评审产出已交付，PR #249 已合并 |
| **Non-claims** | 不等于 Product Gate 或正式上架许可 |
| **Next** | Close 由 Human 决定 |
| **Residuals** | 真机与完全访问关闭时的表现：UNKNOWN |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human 对话原话（2026-10-26，Asia/Shanghai）：「下次发 TestFlight 的时候把外观设置中的『实验性 Liquid Glass 材质』按钮改为只有 DEBUG 版本才能看到，让其他用户已开启的默认回退为未开启的状态。」随后选择「今晚一起改」（随今晚的 TestFlight 一起发）。**加急：** Human 明确要求把 Assignment 记录与实现放在同一个 PR（本任务落成一个本地提交）；先例里登记与实现分在两个 PR。任务包 `~/.kos-work/Universe-Keyboard/LIQUID-GLASS-DEBUG-ONLY-001/instructions/task-package.md`，SHA-256 `404150bc0483e90159908072ad00776316ea724419dbbce92ed3d06d0e57004d`。
- **Product Approver:** Human Product Owner acting as Product Lead
- **Authorization:** 任务包授权消息激活；范围是本地 worktree、一个本地提交，不含 push / PR / merge

## Assignment

- **Domain Owner:** 📱 App & Data Operations Maintainer（外观设置与启动清除）；键盘读取路径与 ⌨️ Keyboard Experience Maintainer 相邻
- **Executor:** 获授权的执行会话（角色：App & Data Operations Maintainer / Keyboard Experience）
- **Environment Executor:** 获授权的执行会话（角色：模拟器编译与测试执行者）；真机 Not Applicable（未授权）
- **Human Dependency:** Human Product Owner — 独立评审后的 push / PR / TestFlight 仍需单独授权
- **Architecture Reviewer:** 🏛️ Architecture & Knowledge Steward — 独立会话，本提交不代替该评审
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer — 独立会话，本提交不代替该评审
- **Handoff Target:** Architecture Reviewer 与 Quality Reviewer（独立会话）

## Boundary

### Scope

外观设置中「实验性 Liquid Glass 材质」仅 DEBUG 编译可见；Release 忽略已保存开启值，主 App 启动时清除该键。有效值判定为 KeyboardCore 纯函数。一个本地提交包含本记录、实现与测试。

### Non-goals

其它外观设置；Liquid Glass 以外的材质逻辑；RIME / R174；放宽断言或超时；push、PR、merge；签名或设备操作；运行期判断是否 TestFlight。

### Required Inputs

- 任务包 SHA-256 `404150bc0483e90159908072ad00776316ea724419dbbce92ed3d06d0e57004d`
- 基线 `origin/main` `cd16fcb143f74a08cb3d6eb4f837a369a71d4317`
- `AppearanceSettingsView.swift`、`KeyboardAppearanceSettings.swift`、`KeyboardViewController+KeyStyle.swift`、`KeyboardViewController+Feedback.swift`、主 App 启动入口

### Entry Criteria

任务包哈希核对通过；基线上授权文件相对 `cd16fcb` 无他人改动；隔离 worktree 已创建。已满足。

### Exit Criteria

DEBUG 行为与改前相同；Release 设置页无该开关与仅含它的「实验性功能」分组；键盘一律按未开启；启动清除幂等且不动其它键；KeyboardCore 与相关测试通过；一个本地提交、未 push。

### Stop Conditions

需要改其它外观设置语义；需要放宽断言或超时；需要运行期判断构建类型；基线上授权文件被其它提交修改且冲突无法安全处理。

### Revalidation Trigger

授权文件在 `origin/main` 上相对 `cd16fcb` 被其它提交改写；或 Human 收回「今晚随 TestFlight、记录与实现同一 PR」的加急决定。

## Acknowledgement

执行会话接受上述范围。工作区 `~/.kos-work/Universe-Keyboard/LIQUID-GLASS-DEBUG-ONLY-001/worktree`，分支 `feature/liquid-glass-debug-only`，不触碰 Human 主检出。


## Exit evidence

- Executor：`/Users/doubleshy0n/.kos-work/Universe-Keyboard/LIQUID-GLASS-DEBUG-ONLY-001/reports/executor-report.md`，SHA-256 `2e104a4e61e12d096f9caf79a556e5ede73d065375362c088bbad584b00bb614`（外置，不入库）。
- 独立 Architecture：PASS WITH CONDITIONS，C1/C2 均低：`/Users/doubleshy0n/.kos-work/Universe-Keyboard/LIQUID-GLASS-DEBUG-ONLY-001/reports/review-arch.md`，SHA-256 `5dcdafeb916bd073335ee5feac238460d1830cb93f4e1212dd9d73e9379f10db`（外置，不入库）；独立 Quality：PASS：`/Users/doubleshy0n/.kos-work/Universe-Keyboard/LIQUID-GLASS-DEBUG-ONLY-001/reports/review-qual.md`，SHA-256 `d4d309a5e55c2e26c3893bf2ddd79f537fed144d4f9652b49056efd27beacd81`（外置，不入库）。
- [PR #249](https://github.com/shchnk1103/Universe-Keyboard/pull/249) 合并提交 `1c9a906c2d0baf12aa62cbb207740bcc16e87efb`；head `082cb0f` run `40345192774` success，PR 检查汇总 10 项全部 SUCCESS。引用 ci-evidence.md（PM 只读取自 GitHub，2026-10-27）：`/Users/doubleshy0n/.kos-work/Universe-Keyboard/RELEASE-CLOSEOUT-177-001/instructions/ci-evidence.md`，SHA-256 `91b8b036aa7e2fed5fd6e2774b5c97c6279ea0985a4fb139fba9a262f58885b2`（外置，不入库）。
- C1：清除只在主 App 冷启动，键盘仍按未开启，disposition `accept`；C2：责任按角色而非具名，disposition `accept`。Human 批准于授权本任务包：`/Users/doubleshy0n/.kos-work/Universe-Keyboard/RELEASE-CLOSEOUT-177-001/reports/human-authorization-r2-issued.md`，SHA-256 `eae66df89903e0a5076ca35f016f94657906e2eff2e10a3075063c4f4f2c5aa2`（外置，不入库）；R3 授权回执 `/Users/doubleshy0n/.kos-work/Universe-Keyboard/RELEASE-CLOSEOUT-177-001/reports/human-authorization-r3-issued.md`，SHA-256 `d20f59d103804e2856b2553e50ed6646b16c55ef94e3f30991078ed26ed900d4`（外置，不入库）。
- 真机“完全访问关闭”仍 UNKNOWN。Completed 表示 Executor 产出已交付，非 Closed。

## Closeout Decision

由 Human 决定。

## Lifecycle Status

Completed

Ready/Active 阶段未在本记录逐级标注；工作依各阶段外置任务包与 Human 授权消息进行（见 Exit evidence）。
