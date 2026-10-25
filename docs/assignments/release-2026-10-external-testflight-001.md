# Assignment: RELEASE-2026-10-EXTERNAL-TESTFLIGHT-001 — 外部 TestFlight（UI-4 + UI-3）准备与证据采集

Policy version: 1.0.0
record_id: RELEASE-2026-10-EXTERNAL-TESTFLIGHT-001

## Current Status

- **Lifecycle：`Assigned`**（职责已定；Entry 未全部满足；不计入 Ready/Active）。Current phase：登记；尚无采集、归档或上传发生。

- **Material non-claims：** 本记录不是 TestFlight 或 Release 许可，也不是 Product Gate；未发生采集、归档或上传；Assigned，不计入 Ready/Active。

- **Next handoff / decision：** 本记录合并进 main 后，按阶段 Entry 与 Human 授权核对开工。

## Authority

- **Task ID / Title：** RELEASE-2026-10-EXTERNAL-TESTFLIGHT-001 — 外部 TestFlight（UI-4 + UI-3）准备与证据采集。

- **Assignment Authority：** Product Lead。

- **Decision Source / Date：** Human Product Owner 2026-10-24（方案 B，见 `docs/PORTFOLIO.md` 决定记录与 PF-031）与 2026-10-25（版本与设备确认）；本记录由 RELEASE-ASSIGNMENT-LANDING-001 入库。

- **Product Approver：** Human Product Owner。

## Boundary

- **Scope：** S1 Mac 侧预演（环境事实、构建配置事实、本地 Release 归档演练、`scripts/release/release_evidence.py plan`，**不导出、不上传**；对应外置 `PF031-PREP-001` 任务包）；S2 TD-003 性能基线在 iPhone 13 Pro（iOS 27.0.1）、macOS 27.0、Xcode 27.1 上重新采集（数值验收标准由 Human 先定，`docs/PERFORMANCE_BASELINE.md` 目前没有数值标准）；S3 TD-005：保留确切 archive/dSYM、UUID 对应、Archive 与导出包构建号对齐（历史上 1 对 55/94 未闭合）、走一遍采集与分类流程；S4 TD-004 与 TD-002 的分类由 Human 逐项批准（条件以 `docs/RELEASE_CHECKLIST.md` 为准）；S5 面向测试者的说明草稿（外置 GROK-BOT-TRIAL-017 产出）经 Human 批准后才能使用；S6 候选构建的身份记录（版本号、构建号、来源提交由 Human 决定后写入）。

- **Non-goals：** 上传 TestFlight、创建或修改外部测试组、Beta App Review、出口合规、App Store Connect 上的任何动作（**各自须 Human 另行授权**，见 `docs/RELEASE_CHECKLIST.md` 第 79 行起）；决定版本号/构建号；发布自动化的实现（见 PF-036，另立）；PF-029；任何产品代码改动；本记录不是 TestFlight 或 Release 许可，也不是 Product Gate。

- **Required Inputs：** `docs/RELEASE_CHECKLIST.md`、`docs/PERFORMANCE_BASELINE.md`、`docs/CRASH_JETSAM_SYMBOLICATION.md`、`docs/TECH_DEBT.md`、`docs/portfolio/testflight-gates.md`、`docs/PORTFOLIO.md` PF-031；Build 94 先例 `docs/assignments/release-2026-09-25-build94-external-testflight.md` 与 `docs/product-decisions/RELEASE-2026-09-25-BUILD94-public-beta-decision.md`；外置盘点 `~/.kos-work/Universe-Keyboard/GROK-BOT-TRIAL-016/reports/testflight-prep-inventory.md`（SHA-256 `33009d5065c95fa2a64ad3572c089c3d07d7d0f310a366c12a798c97aa48f10d`，非独立复核）。

## 上一次外部构建基准

- Human 2026-10-25 口述：最近一次上传到外部 TestFlight 的构建为 **Build 132**，与 Build 94 是同一个外部测试组；本次未核对 TestFlight / App Store Connect。
- **Human 截图，构建页本身未核对**；截图不入库。Xcode Cloud 构建页显示：工作流 `Archive Pilot (No Distribution)`；启动条件 `Manual build`；开始 `2026-10-10 19:15`；时长 2 分钟；`Xcode 27 (27A266a)`；`macOS Golden Gate 27 (26A428)`；最后一次提交短 SHA `5927233`，标题 `feat(keyboard): add delete-key settings switches (#206)`；动作 `Archive - iOS` 成功。截图时间的时区未另行核对。
- 本 worktree 用 `git rev-parse 5927233` 复核完整来源提交为 `59272331b3627856c1c4480b0b5d7ad0ddade0ad`，前缀唯一且为缓存 `origin/main` 的祖先；提交时间 `2026-10-07 16:41:33 +0800`。从它到 main 快照 `23601c06420b1955d141b6c9a70f1baa9f9f4013`，first-parent 提交复算为 32 个，其中触及产品代码路径 9 个（逐提交对第一父提交比较，产品路径定义为 `Keyboard/`、`Universe Keyboard/`、`Packages/*/Sources/`；排除测试、文档、工程配置）。
- **增量证据与“自上次外部构建以来的变化”均以 Build 132 的来源提交为基准**（不是 Build 94）。Build 94 决定记录里来源提交只有 39 位的小错已知，未更正。
- 流程（Human 口述，覆盖此前“两个来源并列 UNKNOWN”）：Xcode Cloud（该无分发工作流）完成构建 → Human 在页面下载构建产物 → 经 Mac 本地的 Transporter 上传到 TestFlight；Build 94 由 Codex 经 Transporter 上传，之后又上传过 Build 132；Build 132 由 Human 手动上传，在 Codex 的指导下（Human 2026-10-25 口述）；上传回执：UNKNOWN（口述称可能没有记录）。
- 仓库此前无 Build 132 记录：本次在快照 `23601c06420b1955d141b6c9a70f1baa9f9f4013` 的全部受跟踪文件中按 `Build[[:space:]]*132|build132|\(132\)` 不区分大小写搜索，结果零命中；这仅是上述搜索范围与模式的结果，不代表已独立核对构建页或上传回执。

## Assignment

- **Domain Owner：** Test / Release Maintainer。

- **Executor：** Codex（GPT-6，当前 Executor 会话；精确后端版本未确认）。

- **Environment Executor：** Codex（Xcode、`xcodebuild`、`devicectl`、`xctrace` 本机命令）；设备上的人工操作由 Human 完成。

- **Human Dependency：** Human Product Owner——设备（iPhone 13 Pro）操作、TD 分类批准、数值验收标准、版本号/构建号、所有 App Store Connect / TestFlight 动作的授权。

- **Architecture Reviewer：** Not Applicable，除非后续出现代码、脚本或架构改动（届时另行指定）。

- **Quality Reviewer：** 独立 Quality Reviewer，在采集结果与归档证据阶段派发，非 Executor 会话。

- **Human 确认状态：** 方案 B 已确认（2026-10-24）；版本与设备已确认（2026-10-25，见上）；开工授权按阶段由 Human 另行给出；TD-004 / TD-002 分类、数值验收标准、版本号、上传：**待 Human**。

## Reviewer claim register

| ID | 声称 |
|---|---|
| R1 | 设备与系统版本记录属实 |
| R2 | 归档的版本/构建号/UUID 与二进制一致 |
| R3 | `plan` 输出原样 |
| R4 | 采集用合成输入且环境记录完整 |
| R5 | Human 观察不升级为测量 |
| R6 | 无任何上传或 App Store Connect 动作发生 |

## Gates

- **Entry Criteria：** 本记录合并进 main；Human 对版本/设备的确认（已在本记录写明）；S1 另需 Human 的任务包授权；S2 需 Human 先定数值验收标准；S3 需 S1 的归档演练无阻断；任何上传相关动作需要独立授权。

- **Exit Criteria：** S1–S6 各自有外置报告与 Quality Reviewer 结论，或被 Human 以“范围约束”批准跳过（TD-004/TD-002）；候选构建身份已由 Human 写定；**之后**是否上传、外部组与 Beta Review 另行决定。

- **Stop Conditions：** 任何需要联网写入的 Apple 侧动作、需要创建/修改证书或配置文件、需要改版本号/构建号而无 Human 决定、Archive 与二进制 UUID 对不上、设备不可用、证据缺失而 Human 未批准范围跳过。

## Handoff

- **Handoff Target：** Coordinator → Codex（S1–S3）→ Quality Reviewer → Human Product Owner。**Required Handoff Content：** 环境版本表、构建配置事实、归档元数据与 UUID 对应表、`plan` 输出、每项采集的原始数据路径与 SHA-256、所有 UNKNOWN。

- **Revalidation Trigger：** 版本/设备变化、main 上产品代码变化、Human 改变方案、Build 号决定、任何门禁分类变化。

## Reports

各阶段外置报告（路径与 SHA-256 在执行时追加）；授权仅外置，不入库。

## Exit evidence

| 项 | Result |
|---|---|
| S1 Mac 侧预演 | （执行时填） |
| S2 TD-003 性能基线 | （执行时填） |
| S3 TD-005 归档与分类流程 | （执行时填） |
| S4 TD-004 / TD-002 分类 | （执行时填） |
| S5 测试者说明 | （执行时填） |
| S6 候选构建身份 | （执行时填） |
| 独立 Quality Reviewer 结论 | （执行时填） |

## Closeout Decision

本 Assignment 是发布准备（证据采集）类，不适用 D7 直接 Close：证据与评审完成后，由 Human 决定 Close；Close 不是上传或发布许可。

## Lifecycle Status

Assigned
