# Assignment: BUILD167-D4-TOUCH-ROW-SHIFT-001 — 九宫格拼音栏出现后快速按键命中下一行（D4）的诊断与修复

Policy version: 1.0.0
record_id: BUILD167-D4-TOUCH-ROW-SHIFT-001

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Assigned |
| Current phase | 登记；S1–S3 每阶段另需 Human 任务包授权 |
| Material non-claims | 本次仅文档登记；无阶段开工、独立评审结论、push / PR / merge 或 Release |
| Next handoff / decision | 本记录合并进 main 后，Human 授权阶段任务包 |

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

（执行时填）

## Closeout Decision

由Human决定。

## Lifecycle Status

Assigned
