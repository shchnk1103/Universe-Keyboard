# Assignment: RELEASE-2026-10-EXTERNAL-TESTFLIGHT-001 — 外部 TestFlight（UI-4 + UI-3）准备与证据采集

Policy version: 1.0.0
record_id: RELEASE-2026-10-EXTERNAL-TESTFLIGHT-001

## Current Status

- **Lifecycle：`Active`**（S1 已于 2026-10-25 在 Human 授权下开工并完成；S1、S3 的 Ready/Active 依据各自任务包与 Human 授权消息，见 Exit evidence）。Current phase：S1 预演完成，S3 只读演练完成，S2 待 Human 定 TD-003 数值标准，S3 真机报告采集与分类待做，S5 测试者说明待定稿，S6 版本 1.0 / 构建号由 Xcode Cloud 编排 / 候选来源提交待定；S7 待定义证据方案。

- **Material non-claims：** 本记录不是 TestFlight 或 Release 许可，也不是 Product Gate；未发生采集、归档或上传；Assigned，不计入 Ready/Active。

- **Next handoff / decision：** 本记录合并进 main 后，按阶段 Entry 与 Human 授权核对开工。

## Authority

- **Task ID / Title：** RELEASE-2026-10-EXTERNAL-TESTFLIGHT-001 — 外部 TestFlight（UI-4 + UI-3）准备与证据采集。

- **Assignment Authority：** Product Lead。

- **Decision Source / Date：** Human Product Owner 2026-10-24 与 2026-10-25（均为 Asia/Shanghai；2026-10-24 方案 B，见 `docs/PORTFOLIO.md` 决定记录与 PF-031；2026-10-25 版本与设备确认）；本记录由 RELEASE-ASSIGNMENT-LANDING-001 入库。

- **Product Approver：** Human Product Owner。

## Boundary

- **Scope：** S1 Mac 侧预演（环境事实、构建配置事实、本地 Release 归档演练、`scripts/release/release_evidence.py plan`，**不导出、不上传**；对应外置 `PF031-PREP-001` 任务包）；S2 TD-003 性能基线在 iPhone 13 Pro（iOS 27.0.1）、macOS 27.0、Xcode 27.1 上重新采集（数值验收标准由 Human 先定，`docs/PERFORMANCE_BASELINE.md` 目前没有数值标准）；S3 TD-005：保留确切 archive/dSYM、UUID 对应、Archive 与导出包构建号对齐（历史上 1 对 55/94 未闭合）、走一遍采集与分类流程；S4 TD-004 与 TD-002 的分类由 Human 逐项批准（条件以 `docs/RELEASE_CHECKLIST.md` 为准）；S5 面向测试者的说明草稿（外置 GROK-BOT-TRIAL-017 产出）经 Human 批准后才能使用；S6 候选构建的身份记录（版本号、构建号、来源提交由 Human 决定后写入）；S7 输入可靠性 003 发布门禁：真实 RIME T9 恢复集成与激活后 Extension 的真实系统交互，依据 [AUTH-INPUT-RELIABILITY-DELIVERY-003-PRODUCT-PR](../authorizations/AUTH-INPUT-RELIABILITY-DELIVERY-003-PRODUCT-PR.md#L10) 第 10 行短引“TestFlight”；上述两项须在 TestFlight 之前处理；Quality Partial 仍为 Partial。PR #213（`bb430f914deaf7b19a61183f744b5dcf2fdb8eae`）、#214（`d08175b915aee40998398d7fdc03f2fd7cf0833f`）、#215（`096183ca118cc40ffc16854d1a5336a42cfcbd89`）均在 Build 132 来源提交 `59272331b3627856c1c4480b0b5d7ad0ddade0ad` 之后合并，已包含于本次候选基线（逐项 `git merge-base --is-ancestor` 核验，见本次 R1 外置报告）。Human 2026-10-25（Asia/Shanghai，对话）决定以补证据的方式处理，不是有边界接受；真实 RIME T9 恢复集成的验证方法、激活后 Extension 真实系统交互的检查项及所用设备 iPhone 13 Pro，待后续任务包定义并由 Human 授权。

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

- **Human 确认状态：** 方案 B 已确认（2026-10-24）；版本与设备已确认（2026-10-25，见上）；开工授权按阶段由 Human 另行给出；TD-004 / TD-002 分类、数值验收标准、版本号、上传：**待 Human**。 Human 2026-10-25（Asia/Shanghai，对话）决定 S7 以补证据处理，不是有边界接受；具体证据方案（真实 RIME T9 恢复集成验证方法、激活后 Extension 真实系统交互检查项、所用设备 iPhone 13 Pro）待后续任务包定义并由 Human 授权。

Human 2026-10-25（Asia/Shanghai，对话；本次登记依据外置 RELEASE-PREP-RECORD-001 任务包 F3 与 Human 授权）：① TD-004 与 TD-002 沿用 Build 55/94 的做法：TD-004 走“有范围的跳过”（构建限定于被明确要求开启完全访问的测试者，不对降级行为作任何声称），TD-002 走“范围约束”（恢复/重置须在键盘关闭时手动进行并向测试者说明，不声称并发安全），条件以 `docs/RELEASE_CHECKLIST.md` 为准；② 营销版本暂定 1.0（Human：App 仍处于测试阶段）；③ 测试组沿用 Build 132 的同一个外部测试组；④ Build 94、132 等构建号是 Xcode Cloud 按构建顺序自动编排的（Human 澄清）；⑤ 测试者说明的范围以 UI-4 与 UI-3 为主。

## Reviewer claim register

| ID | 声称 |
|---|---|
| R1 | 设备与系统版本记录属实 |
| R2 | 归档的版本/构建号/UUID 与二进制一致 |
| R3 | `plan` 输出原样 |
| R4 | 采集用合成输入且环境记录完整 |
| R5 | Human 观察不升级为测量 |
| R6 | 无任何上传或 App Store Connect 动作发生 |
| R7 | S7 的门禁原文与适用性记录属实，未写成已处理 |

## Gates

- **Entry Criteria：** 本记录合并进 main；Human 对版本/设备的确认（已在本记录写明）；S1 另需 Human 的任务包授权；S2 需 Human 先定数值验收标准；S3 需 S1 的归档演练无阻断；任何上传相关动作需要独立授权。 S7 需 Human 授权证据方案的任务包。

- **Exit Criteria：** S1–S7 各自有外置报告与 Quality Reviewer 结论，或被 Human 以“范围约束”批准跳过（TD-004/TD-002）；候选构建身份已由 Human 写定；**之后**是否上传、外部组与 Beta Review 另行决定。

- **Stop Conditions：** 任何需要联网写入的 Apple 侧动作、需要创建/修改证书或配置文件、需要改版本号/构建号而无 Human 决定、Archive 与二进制 UUID 对不上、设备不可用、证据缺失而 Human 未批准范围跳过。

## Handoff

- **Handoff Target：** Coordinator → Codex（S1–S3）→ Quality Reviewer → Human Product Owner。**Required Handoff Content：** 环境版本表、构建配置事实、归档元数据与 UUID 对应表、`plan` 输出、每项采集的原始数据路径与 SHA-256、所有 UNKNOWN。

- **Revalidation Trigger：** 版本/设备变化、main 上产品代码变化、Human 改变方案、Build 号决定、任何门禁分类变化。

## Reports

各阶段外置报告（路径与 SHA-256 在执行时追加）；授权仅外置，不入库。

## S3 演练事实与固定步骤

Human 从 Xcode Cloud 下载的 Build 132 产物：归档内 App 与 Keyboard 为 1.0 (1)，app-store IPA 为 1.0 (132)；两者 App 与 Keyboard 二进制的 arm64 UUID 相同，归档自带的两个 dSYM 与之一一对应；IPA 构建号为 132；导出元数据 `uploadSymbols=true` 是配置值，不等于 App Store Connect 已收到符号；离线 `atos` 在 App 与 Keyboard 各两个地址还原出函数名（静态、非真实崩溃）。未覆盖真机崩溃/Jetsam 报告的采集与分类、App Store Connect 是否收到符号、产物中的来源提交、Xcode Cloud 产物保留期限；不裁定 TD-005 关闭或原因。

每次上传外部候选时，除上传用的 app-store 包外，同时下载并保留同一 Xcode Cloud 构建的 “Archive” 产物，并按 UUID 核对其 dSYM 与上传包二进制一致（PM 提议，Human 已同意本次登记；依据本次任务包 F4 与 S3 报告）。

## Exit evidence

| 项 | Result |
|---|---|
| S1 Mac 侧预演 | `~/.kos-work/Universe-Keyboard/PF031-PREP-001/instructions/task-package-v3.md`（SHA-256 `c569f97181abaead11a5f0eb9a3613e9e19e10644c5b988c56b808a9a969b460`）；`~/.kos-work/Universe-Keyboard/PF031-PREP-001/reports/human-authorization-v3-issued.md`（SHA-256 `9a9a98dfda64c745fe134ab87453ee6e458aac596c3156623430e7f35f7401a0`）；`~/.kos-work/Universe-Keyboard/PF031-PREP-001/reports/executor-report.md`（SHA-256 `f89bf2dc97e025c700e6d2cacad2595656ee7766b7e5d888fee59690c848200c`）；macOS 27.0 (26A428)、Xcode 27.1 (27A9275)、Swift 6.4；iPhone 13 Pro（iPhone14,2）iOS 27.0.1 (24A446) 已连接、开发者模式开启；本机开发签名 Release 归档成功，App 与 Keyboard 均 1.0 (1)，各自二进制与 dSYM 的 arm64 UUID 一一对应；未导出、未上传。`release_evidence.py plan` 以 Build 132 来源提交 `59272331b3627856c1c4480b0b5d7ad0ddade0ad` 为 base，profile `baseline`；8 项 `required_checks`：`candidate_fact_tuple`、`artifact_mapping`、`existing_ci_full_gate`、`affected_path_validation`、`physical_device_baseline`、`performance_and_crash_classification`、`fresh_install_or_shared_container_boundary`、`external_only_checks`，均未执行、不算通过。 Executor-recorded，非独立复核。 |
| S2 TD-003 性能基线 | （执行时填） |
| S3 TD-005 归档与分类流程 | `~/.kos-work/Universe-Keyboard/PF031-S3-REHEARSAL-001/instructions/task-package.md`（SHA-256 `ba1c26a246e45eef475cbbfa13310ea990eea9c40fba900268d5353e172ce2ff`）；`~/.kos-work/Universe-Keyboard/PF031-S3-REHEARSAL-001/reports/human-authorization-issued.md`（SHA-256 `6f86f95dfdcfad870ce2f79570fa9e2530e451a9e00d9358012d3f0df758577a`）；`~/.kos-work/Universe-Keyboard/PF031-S3-REHEARSAL-001/reports/executor-report.md`（SHA-256 `a4d13becc374c0cd0fc27bffe0d7fa8aa87b305ba33da58d13dd1e989a94357a`）；Human 从 Xcode Cloud 下载的 Build 132 产物：归档内 App 与 Keyboard 为 1.0 (1)，app-store IPA 为 1.0 (132)；两者 App 与 Keyboard 二进制的 arm64 UUID 相同，归档自带的两个 dSYM 与之一一对应；IPA 构建号为 132；导出元数据 `uploadSymbols=true` 是配置值，不等于 App Store Connect 已收到符号；离线 `atos` 在 App 与 Keyboard 各两个地址还原出函数名（静态、非真实崩溃）。 Executor-recorded，非独立复核；仅只读演练，未覆盖项见上。 |
| S4 TD-004 / TD-002 分类 | （执行时填） |
| S5 测试者说明 | （执行时填） |
| S6 候选构建身份 | （执行时填） |
| S7 输入可靠性 003 发布门禁 | （执行时填） |
| 独立 Quality Reviewer 结论 | （执行时填） |

## Closeout Decision

本 Assignment 是发布准备（证据采集）类，不适用 D7 直接 Close：证据与评审完成后，由 Human 决定 Close；Close 不是上传或发布许可。

## Lifecycle Status

Active
