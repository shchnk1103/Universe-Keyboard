# Assignment: BUILD167-D4-TOUCH-ROW-SHIFT-001 — 九宫格拼音栏出现后快速按键命中下一行（D4）的诊断与修复

Policy version: 1.0.0
record_id: BUILD167-D4-TOUCH-ROW-SHIFT-001

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Completed |
| Current phase | S1–S7 产出已交付，Close 由 Human 决定 |
| Material non-claims | Human 观察不等于 D4 已被诊断证明解决；长期真机与其它宿主/机型未覆盖 |
| Next handoff / decision | Human 决定 Close；D1 修复保持 Assigned，S1 未开工 |

## Authority

- **Task ID / Title:** BUILD167-D4-TOUCH-ROW-SHIFT-001 — 九宫格拼音栏出现后快速按键命中下一行（D4）的诊断与修复。
- **Assignment Authority:** Product Lead。
- **Decision Source / Date:** Human Product Owner，2026-10-26（Asia/Shanghai，对话）：报告 D4、复测并同意立项，原话“可以，现在就写 D4 的登记，和 R3 并行”；由 [登记 Assignment](build167-d4-assignment-landing-001.md) 记录冻结包与激活回执。
- **Product Approver:** Human Product Owner。

## Human 观察、读数与证据边界

Human 观察不是测量；下列事实、推断与假设分别标明，原始证据仅外置。

- iPhone 13 Pro，2026-10-26 12:13–12:16，Human 按阶段 B 步骤操作。
- Human 补充原话：“我不是全程只按“JKL”键，是先按了其他键唤起拼音栏之后快速按了多次“JKL”键。”
- `stage-b-device-diag-lines.txt`：L10（12:15:00.822），y=161.667、path=34、bounds=288，映射 TUV（第 2 行）；L11（12:15:01.010），y、path、bounds 相同，映射 JKL（第 1 行）。
- 计时口径：首次 path=34 是 L6（12:15:00.594），bounds 到288是 L8（12:15:00.630）；L10、L11距L6约228ms、416ms，距L8约192ms、380ms。时间戳只到毫秒；`heightChangeMs` 从最近一次高度相关量变化起算，不等于距拼音栏首次出现。
- L22（12:15:09.539）也映射 TUV；该段首次 path=34 为 L19（12:15:09.438），bounds 到288为 L21（12:15:09.471）；距L19约101ms，距L21约68ms（日志 `heightChangeMs=67.290`）。
- 高度修复候选 `4a381df`（BUILD167-FIX-S3-HEIGHT-001）同次复测保留的5段拼音栏出现记录，bounds 均在33–58ms内到位，过程中 `accepted=nil`、`active=1`、`status=ready`。诊断没有alpha字段，“全程没有隐藏”及隐藏窗口完整性仍为 **UNKNOWN**。
- **推断，非测量：** L10、L22均记录命中TUV，即触摸落到按钮上，而不是没有响应；由此推断这两次错行不是“隐藏窗口里按不到”造成。此推断不证明隐藏窗口完整性。
- 原始用户反馈与 Human 早先观察（2026-10-26，原话）：“现在有用户反馈我们的键盘存在不跟手，打快了会有漏字的情况，我自己试了一下，在九宫格的情况下，第一次按键之后拼音栏出现，后续第二到第三次按键确实有可能出现错位（响应的比实际按下去的键矮一层，比如我按“TUV”响应的可能是空格键）。”
- **PM 只读假设，未验证：** 拼音栏出现后的数百毫秒内，按键命中所用的触区几何仍是旧位置；相关位置是 [KeyboardInputHitAreaStackView](../../Keyboard/Controllers/KeyboardInputHitAreaStackView.swift) 与 [KeyboardViewController](../../Keyboard/Controllers/KeyboardViewController.swift) 中 `viewDidLayoutSubviews` 的触区重建。不是根因结论。

## Boundary

- **Scope:** 分阶段推进，每阶段另需 Human 的任务包授权。
  - **S1 诊断：** 只读核对触区几何的建立与更新时机；模拟器用注入时序复现拼音栏出现后0–400ms内的触摸命中；必要时添加仅Debug生效的触点x/y、命中按钮frame、触区几何代际、touch-end及action是否执行记录，通过Human真机操作与只读取回验证。
  - **S2 修复：** 让触区几何与按键视觉位置同步更新，配回归测试。
  - **S3 真机复测：** Human操作。
  - **S7：** 依据下述Human决定，本地实现九键始终预留34pt、保留adaptive策略与本地归档标签、同步合同/ADR、回归base失败/fix通过及两轮模拟器与Core；至多两本地提交，不push；阶段A结束停交Human派独立评审，阶段B真机与发布另授。
- **Non-goals:** 高度协商（属 [BUILD167-FEEDBACK-FIX-001](build167-feedback-fix-001.md)）；D1；RIME输入链路；打开R174；改UI-4或九宫格产品合同（需要则停止交Human决定）；放宽断言或超时；TestFlight / App Store Connect动作；push / PR / merge各自另行授权。
- **Required Inputs:** [KEYBOARD_LAYOUT](../KEYBOARD_LAYOUT.md)（Sticky路径栏）、[KEYBOARD_VALUES](../KEYBOARD_VALUES.md)、[PERFORMANCE_BASELINE](../PERFORMANCE_BASELINE.md)（真机打字由Human执行）；BUILD167-FEEDBACK-FIX-001的S2与S3报告；以下外置证据（路径与SHA，不复制原件）：
  - `~/.kos-work/Universe-Keyboard/BUILD167-FIX-S3-HEIGHT-001/reports/executor-report.md`，SHA-256 `8f901389a7617afb3e0190a10e65eb5c0cee0f7404c6657831e5ffb254e1c354`。
  - 同目录 `stage-b-touch-audit.csv`，SHA-256 `ec566b8ffe7a55c79665f5c767f610eda9d9444e6ece71f3ab1c6b72d22d439a`。
  - 同目录 `stage-b-device-diag-lines.txt`，SHA-256 `32ee91aa0a3a3474711efb8335201c519f12b93847123db73c92909b47f7029f`。
  - 同目录 `human-stage-b-result.md`，SHA-256 `be563b5bbbee5162093a0ba639292c0b4385075839fac191225751a3f56b7e68`。
  - S2报告 `~/.kos-work/Universe-Keyboard/BUILD167-FIX-S2-DEVICE-DIAG-001/reports/executor-report.md`，SHA-256 `3961240f6cbdb959a6cff554ca4d0ef567d486659252e28365f3df33f7cc6672`；S3报告即上列S3 executor-report。

## Assignment

- **Domain Owner:** Keyboard Experience Maintainer，出处同 [既有修复 Assignment](build167-feedback-fix-001.md) 与 [永久所有权](../VIRTUAL_ENGINEERING_TEAM.md)。
- **Executor:** Codex。
- **Environment Executor:** Codex（Xcode、模拟器、只读的 `devicectl`）；真机安装与操作由Human完成。
- **Human Dependency:** Human Product Owner——各阶段授权、真机操作；涉及交互行为变化时由Human选方案。
- **Architecture Reviewer:** 独立 Architecture Reviewer（S2必需），非Executor会话。
- **Quality Reviewer:** 独立 Quality Reviewer（每阶段），非Executor或Architecture同一会话。

## Gates

- **Entry Criteria:** 本记录合并进main，并且该阶段有Human任务包授权。
- **Exit Criteria:** 每阶段有外置报告与独立评审；修复经PR合并；Human真机复测不再出现D4，或由Human决定接受某种残余。
- **Stop Conditions:** 需要改产品合同、放宽断言或超时、碰RIME或打开R174；需要签名或账号操作；设备不可用。

## Handoff

- **Handoff Target:** Coordinator → Codex → Architecture / Quality → Human。
- **Required Handoff Content:** 阶段授权、观察与推断边界、复现与几何时序证据、修复与回归证据、独立评审、Human复测结果、偏差与残余。
- **Revalidation Trigger:** main上相关布局或触摸代码变化；BUILD167-FEEDBACK-FIX-001的修复合并；Human新报告。

## Reports

（执行时填）

## Exit evidence

| 阶段 | 外置依据（不入库） | 结论 | PR / 提交 |
|---|---|---|---|
| S1 | `/Users/doubleshy0n/.kos-work/Universe-Keyboard/BUILD167-D4-S1-DIAG-001/reports/executor-report.md`，SHA-256 `560b6ff14a1f9e11ad085de3a102dc9233fd27f99a8e43235ab7ca99d60d6eda`（外置，不入库） | 合成宿主与真机 Debug 读数支持视觉/触区几何不一致候选；完整持续窗口及历史因果未证实 | 本地 `ef44fb5` |
| S2 | `/Users/doubleshy0n/.kos-work/Universe-Keyboard/BUILD167-D4-S2-FIX-001/reports/executor-report.md`，SHA-256 `ddf1d642977edfb267ca5f956cc52fe507586cbd710551a6f5ccdc9cb49594d2`（外置，不入库） | 触区快照与 canvas 跟随当前几何；Human 阶段 B 仍观察错行 | [#247](https://github.com/shchnk1103/Universe-Keyboard/pull/247) `cd16fcb` |
| S3 | `/Users/doubleshy0n/.kos-work/Universe-Keyboard/BUILD167-D4-S3-DIAG-001/reports/executor-report.md`，SHA-256 `b46cf2ef60144e52c756d12a00fa74bc7b22e523851e79462aa37bd3ff72a4d6`（外置，不入库） | Human 观察错键动画与输入；保留读数受日志截断限制 | 本地 `8cdd65d` |
| S4 | `/Users/doubleshy0n/.kos-work/Universe-Keyboard/BUILD167-D4-S4-DIAG-001/reports/executor-report.md`，SHA-256 `f564136e8c6b0901f80427c41176f2635d91bd23851d3af6ab394676265bc437`（外置，不入库） | 首键后路径 0→34、高度 254→288，第二下落到 ABC；15 簇中 12 簇落 ABC，8 簇实际发送 slot=2；限本次 Debug 样本 | 本地 `6f3732f` |
| S5 | `/Users/doubleshy0n/.kos-work/Universe-Keyboard/BUILD167-D4-S5-DESIGN-001/reports/d4-design-options.md`，SHA-256 `8274bf9b5dec00ab5861fd396326f2d95a86bc3905ef93d96d74eca64e77cda3`（外置，不入库） | 比较预留、原子过渡及 overlay 等方案，屏幕运动机制仍 UNKNOWN | 无提交 |
| S6 | `/Users/doubleshy0n/.kos-work/Universe-Keyboard/RELEASE-CLOSEOUT-177-001/instructions/human-decisions.md`，SHA-256 `83a4e410bb52e84cbf2db485fedf92e9887d4236a05740ecb1ad8e29461a5b6f`（外置，不入库） | Human 取消 B2/录屏 | 无提交 |
| S7 | `/Users/doubleshy0n/.kos-work/Universe-Keyboard/BUILD167-D4-S7-RESERVE-001/reports/executor-report.md`，SHA-256 `e3f4fb282aae2335a6bf08bf3cf9e0cf59899438da592692d58cb267642c385d`（外置，不入库） | 始终预留 34pt；产品决定 Accepted by Human，ADR 0038 Proposed | [#248](https://github.com/shchnk1103/Universe-Keyboard/pull/248) `4477435` |

独立评审：
- S2 Architecture R1b：PASS WITH CONDITIONS：命中时发布不运行 layout，后续真实布局可能不同；`/Users/doubleshy0n/.kos-work/Universe-Keyboard/BUILD167-D4-S2-FIX-001/reports/review-arch-r1b.md`，SHA-256 `b0eb5bbd2226b161dc14f34bf9011ab3a0c7d885ac75777308f6d20700d0e84a`（外置，不入库）。
- S2 Quality R1b：PASS，无条件；`/Users/doubleshy0n/.kos-work/Universe-Keyboard/BUILD167-D4-S2-FIX-001/reports/review-qual-r1b.md`，SHA-256 `6009155b1d1fecdd3e487be16debab5c9f39cb88c07ba0c9ff47c451345c9d24`（外置，不入库）。
- S5 Quality R2：DONE：比较中披露合同冲突；当轮产品权威未决；`/Users/doubleshy0n/.kos-work/Universe-Keyboard/BUILD167-D4-S5-DESIGN-001/reports/quality-review.md`，SHA-256 `12f8fd5eefc619b6a89fde8af1fda96e56da4ae0a7536eaa19502d19d0bafb80`（外置，不入库）。
- S7 Architecture R1：PASS WITH CONDITIONS：C1 历史文段易混淆；C2 无 path 的 composition/Recovery 空白预留需确认；`/Users/doubleshy0n/.kos-work/Universe-Keyboard/BUILD167-D4-S7-RESERVE-001/reports/review-arch-r1.md`，SHA-256 `58438101c2ea46314269e3071c05469802c0b07171f251a8dd48c5510bc14c66`（外置，不入库）。
- S7 Quality R1：PASS WITH CONDITIONS：QF-1 不将跨宿主汇总误称不重复用例；QF-2 模拟器截图无法辨认预留带；`/Users/doubleshy0n/.kos-work/Universe-Keyboard/BUILD167-D4-S7-RESERVE-001/reports/review-qual-r1.md`，SHA-256 `dc669cebbbf7f3e6872d174ea26f94d9e8d2f7a54efd67417b7cf6a8c3583e0d`（外置，不入库）。
- S7 Quality R2：PASS WITH CONDITIONS：当轮 #248 测试仍运行，不得称 CI 全绿，截图失败是否消失待 hosted 终态；`/Users/doubleshy0n/.kos-work/Universe-Keyboard/BUILD167-D4-S7-RESERVE-001/reports/review-qual-r2.md`，SHA-256 `3fde34bdcd6142e6e03b7e9d671f8af6f0a11ac5a004090f263c381b0c43091d`（外置，不入库）。

S2 阶段 B Human 仍观察错行：`/Users/doubleshy0n/.kos-work/Universe-Keyboard/BUILD167-D4-S2-FIX-001/reports/human-stage-b-result.md`，SHA-256 `228c9b144b199995a6c566d152c26cddd9ad829fa23e1000a3fcb86a57f174ff`（外置，不入库）。S7 阶段 B Human 观察 12 轮无错字母：`/Users/doubleshy0n/.kos-work/Universe-Keyboard/BUILD167-D4-S7-RESERVE-001/reports/stage-b-human-feedback.md`，SHA-256 `0bf4915de1f529caedc30050dc6e1d44048d21b58497470a5ecfd565a9800bb5`（外置，不入库）；诊断日志轮转只保留末段，不能证明全覆盖。长期真机、其它宿主/机型未覆盖。

#248 CI：首个 head `cb65289` run `40340940563` failure（截图无权限，R2 修复）；head `46304f1` run `40344050348` success。其间一次与本 PR 无关的间歇失败，Human 只重跑失败项后通过（Human 陈述；原因 UNKNOWN）。引用 ci-evidence.md（PM 只读取自 GitHub，2026-10-27）：`/Users/doubleshy0n/.kos-work/Universe-Keyboard/RELEASE-CLOSEOUT-177-001/instructions/ci-evidence.md`，SHA-256 `91b8b036aa7e2fed5fd6e2774b5c97c6279ea0985a4fb139fba9a262f58885b2`（外置，不入库）。

D1 Human 2026-10-26 选 C+A：“D1 选 C+A：现在先不改，出门期间限时只读调研”，见 `/Users/doubleshy0n/.kos-work/Universe-Keyboard/RELEASE-CLOSEOUT-177-001/instructions/human-decisions.md`，SHA-256 `83a4e410bb52e84cbf2db485fedf92e9887d4236a05740ecb1ad8e29461a5b6f`（外置，不入库）。[D1 修复 Assignment](build167-feedback-fix-001.md) 保持 `Assigned`（本任务不改其 Lifecycle；D1 按 Human 2026-10-26 决定 C+A 暂不改，S1 未开工）。

生命周期 Completed 表示 Executor 产出已交付，不是 Reviewed 或 Closed；批准依据 `/Users/doubleshy0n/.kos-work/Universe-Keyboard/RELEASE-CLOSEOUT-177-001/reports/human-authorization-r2-issued.md`，SHA-256 `eae66df89903e0a5076ca35f016f94657906e2eff2e10a3075063c4f4f2c5aa2`（外置，不入库）。


## Closeout Decision

由Human决定。

## Lifecycle Status

Completed

Ready/Active 阶段未在本记录逐级标注；工作依各阶段外置任务包与 Human 授权消息进行（见 Exit evidence）。

## S7 Human 决定与精确授权

Human Product Owner，2026-10-26 Asia/Shanghai，S7 任务包及本会话匹配 SHA-256 的激活授权；授权原文保存在外置 reports/human-authorization-issued.md。

- “我发现苹果原生键盘也是直接预留了拼音栏的位置，我们可以先存档现有自动出现的这个功能。”
- 他肉眼从未看到键盘在屏幕上往下挪，所以不再做屏幕录像（S6 已取消）。
- 此前的倾向：“希望拼音栏可以在需要的时候再出现”，现已被上一条取代。

任务包 `BUILD167-D4-S7-RESERVE-001/instructions/task-package.md` SHA-256 `385c7035ef1fd769f28fcf36199f4cbbe34b100b395b22b8563f792097aa1155`，授权Codex执行阶段A。原Non-goals中产品合同停止条款仅在本次明确的0/34→始终预留34范围由Human决定解除；其它UI-4条款、RIME/R174、#244/#247保持不变。产品决定见 [Accepted记录](../product-decisions/T9-PATH-ROW-RESERVED-001-product-decision.md)，架构见 [Proposed ADR0038](../architecture/decisions/0038-t9-path-row-always-reserved.md)。Lifecycle保持Assigned的父任务历史不构成S7质量或真机通过。
