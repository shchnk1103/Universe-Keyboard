# Assignment: UI3-FONT-001 — 候选字大小（v1）实现

Policy version: 1.0.0
record_id: UI3-FONT-001

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Closed（Human 2026-10-25 决定；在承载本记录的 PR 合并时生效） |
| Current phase | 代码已合并（PR #236，`b8f6b6516064c4721c884a53e1437e01d83449e7`）；本轮登记合并与 Human Close 决定，生效边界见 Lifecycle |
| Material non-claims | 未发布；不是 Product Gate、TestFlight 或 Release 许可；Human 真机观察（不是测量）仅覆盖 `b0e0361`（iPhone 13 Pro、iOS 27.0.1）；完全访问关/开表现无区别；Debug/Release UNKNOWN；之后的预览提交 `eae739e`、`0db9b27` 与测试/文档提交 `16bab5c`、`f489968` 未经真机验收；默认档证据与历史失败见 Exit evidence |
| Human 确认状态 | 产品决定已接受（2026-10-23）；开工与阶段授权见 `~/.kos-work/Universe-Keyboard/UI3-FONT-001/reports/executor-report-p0.md`（SHA-256 `9bd6e2a9ad1957cd8747523e43cb31c49cdd7c1b00aca7b74365d66f03aacab1`） 及各阶段报告；真机观察见 Exit evidence；Human 2026-10-25 决定 Close，授权回执 `~/.kos-work/Universe-Keyboard/PORTFOLIO-REFRESH-005A/reports/human-authorization-005a-v2-issued.md`（SHA-256 `5ea45537ca6c609306f3b2637c4261a4411ba86284b647eec644d741f70238df`） |
| Next handoff / decision | 本登记记录待评审与 Human 后续发布决定；Close 在承载本记录的 PR 合并时生效；是否进入 TestFlight 候选由 Human 另行决定 |

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner 于 2026-10-23 Asia/Shanghai 接受 [PD-UI3-CANDIDATE-FONT-SIZE-001](../product-decisions/UI3-CANDIDATE-FONT-SIZE-001-product-contract.md)（档位、保存与读取、入口、保持不变项、验收标准以它为准，本记录不重写）。发布节奏意向不是本 Assignment 的授权范围。
- **Product Approver:** Human Product Owner（Product Lead）

## 背景与输入

基线 `origin/main`：开工时由 Executor 重新核验并写进报告；UI-4 入库 PR 须已在其中。输入（开工前全部读完）：

- 产品决定 `docs/product-decisions/UI3-CANDIDATE-FONT-SIZE-001-product-contract.md`（唯一的需求权威）。
- [`docs/KEYBOARD_VALUES.md`](../KEYBOARD_VALUES.md)（数值权威是代码，该文档是带来源索引）、`docs/UI_STYLE_GUIDE.md`、`docs/KEYBOARD_LAYOUT.md`、`docs/PROJECT_CONTEXT.md`、`docs/TECH_DEBT.md`（TD-020）、`AGENTS.md`、`docs/ASSIGNMENT_POLICY.md`。
- 外置只读参考（Human 本机，不在仓库）：`~/.kos-work/Universe-Keyboard/GROK-BOT-TRIAL-007/reports/ui3-facts.md`（r2 事实清单，bot 输出，行号使用前自行核对）。

## Boundary

- **Scope：** 实现产品决定的第 1 至 8 节：
  1. **KeyboardCore：** 候选字号档位模型（10 档 13–22；默认档 17 = 保持今天的行为；固定档的候选词字号；组字拼音 = 候选词 − 2；缺省/删除 = 默认档；非法值回退默认档），纯 Swift、可单测，不依赖 UIKit。
  2. **键盘扩展：** 渲染（`CandidateCell.configureTitle`）与宽度测量（`+CandidateDataSource` 里的两份 15/17/28）改为由**同一个字号解析入口**得出数值；默认档逐值保持今天的行为（15/17、`UIFontMetrics(.body)` 缩放、上限 28）；固定档不随系统字体变化；每次键盘出现时读取一次，不在输入中途改变。展开面板与候选栏、26 键与九宫格一致。
  3. **主 App：** 「键盘布局」下新增「候选字大小」入口与页面（真实渲染大小的预览条加 10 档滑杆，无试打框；固定说明文字；搜索目录登记）。主 App 写、键盘读；沿用现有布局设置的存取方式与键命名风格，新增键先登记到 `docs/KEYBOARD_VALUES.md`；不读键盘的存储；不做完全访问检测。
  4. **测试：** 新增：档位模型与回退、默认档与今天逐值一致、固定档数值、组字比候选小 2、渲染与测量一致、读不到值时的回退。写死 46/42/254/288 的既有测试保持有效；**不得放宽任何超时或断言来掩盖失败**；改动 `T9AdaptiveRowTests` 或面板几何前先按停止条件报告。
  5. **镜像文档（同一次变更里更新）：** `docs/KEYBOARD_VALUES.md`（必须）、`docs/UI_STYLE_GUIDE.md`（候选基准字号 17/15/28 仍是默认档，注明现在可由用户调节）、`docs/KEYBOARD_LAYOUT.md`、`docs/PROJECT_CONTEXT.md`；是否需要新 ADR 先核对 Policy 再报告；`CHANGELOG.md` 按现有约定。
- **Non-goals：** 产品决定第 7 节全部（分页面字号、候选栏高度、字重/纠错提示/路径栏字号、实时预览、`CandidateButtonFactory` 的清理、UI-4、字母大小写显示、TestFlight / Release）；任何 RIME 逻辑与输入链路改动；改动默认数值；改 CI 配置；push / PR / merge（除非 Human 另行授权）。
- **Required Inputs：** 见“背景与输入”。

## 阶段与停止点

| 阶段 | 内容 | 产物 / 停止 |
|---|---|---|
| P0 预检 | 追踪并写清：(a) 键盘读取设置与首次候选渲染的先后（怎样做到“不先闪现旧字号”）；(b) 现有布局设置的存取方式与键命名，以及它们在完全访问关闭时的读取行为（只读代码与既有证据，不做新的真机实验）；(c) 单一字号解析入口放在哪一层（KeyboardCore 还是扩展），才能同时被渲染与测量使用并可单测；(d) 固定档不使用 `UIFontMetrics`、默认档继续使用时，两条路径如何在同一入口表达 | 预检报告 `reports/executor-report-p0.md`，**停下等 Coordinator 确认再继续** |
| P1 核心 | KeyboardCore 档位模型与回退，含单元测试 | 本地 `swift test`（KeyboardCore）通过；报告 |
| P2 键盘 | 单一解析入口、渲染与测量同源、读取时机；默认档逐值不变的证据（26 键、九宫格、展开面板） | 测试与模拟器截图（Executor 做可脚本化部分）；报告 |
| P3 主 App | 入口、页面、预览、固定说明、搜索登记 | 编译与模拟器截图；报告 |
| P4 镜像与门禁 | 镜像文档、strict swift-format、KeyboardCore 全量测试、App 与 Keyboard 的 Debug build-for-testing、链接检查 | 门禁结果表；报告 |
| P5 验收准备 | 写 Human 的真机验收清单（按产品决定第 8 节七条，含 22 档最长候选的 26 键 / 九宫格各一次、完全访问开与关各一次、系统“更大字体”一次，照片与日志取证点写清，沿用此前“每一步做什么、什么时候拍什么”的写法）并出 Reviewer 材料 | `docs/` 之外的外置清单；Coordinator 冻结 Reviewer 包 |

每个阶段结束写增量报告，报告开头声明运行时身份；最终消息要短，不复述报告。

## 与 UI-4 的协调

两个特性都会改 `KeyboardViewController` 相关文件、`KEYBOARD_VALUES` 与布局测试。若 UI-4 的实现尚未合并，Executor 在 P0 报告中列出与 UI4-HEIGHT-001 重叠的文件，**由 Coordinator 决定先后与分支基线**，不得自行 rebase 对方的分支。

## Environment Executor 与真机分工

模拟器：可脚本化的构建、安装、启动、日志、`simctl` 截图由 Executor 做；需要手点的步骤由 Executor 写成清单交 Human（**不要用 GUI 自动化操作系统设置**）。真机：Human Product Owner（iPhone 13 Pro，iOS 27.0.1，自己用 Xcode 签名并安装）。

## Reviewer claim register

| ID | 声称 |
|---|---|
| F1 | 默认档下候选词/组字拼音/提示的字号、字重、缩放与上限、栏高与今天逐项一致；既有测试仍通过；没有削弱断言 |
| F2 | 固定档 13–22 数值正确，不随系统字体变化；组字拼音比候选小 2；默认档仍跟随系统并以 28 封顶 |
| F3 | 渲染与宽度测量由同一入口得出数值，不再各写一份；展开面板、候选栏、26 键、九宫格一致 |
| F4 | 保存与读取：整数档位、缺省/删除 = 默认档；非法值回退默认档；下次键盘出现时采用且不先闪现旧字号；主 App 写、键盘读，主 App 没有读键盘存储或完全访问检测的代码 |
| F5 | 完全访问不作门槛：页面只有固定说明文字；读不到值时回退默认档有测试 |
| F6 | 候选栏高度、行高、操作区、路径栏字号、纠错提示 13 与字重规则均未变；没有 Scope 外文件变化 |
| F7 | 没有放宽任何超时或断言；TD-020 相关测试未被削弱；没有 RIME 或输入链路改动；日志不记录用户输入的文字 |
| F8 | 镜像文档与代码一致；Executor 报告与仓库事实一致，UNKNOWN 没有被偷偷填充，每个阶段有运行时身份 |

## Closeout Decision

本 Assignment 是产品开发（代码）类，**不适用 D7 的直接 Close**：Reviewer 评审、Human 真机验收（产品决定第 8 节七条）与 Human 对 PR 的决定之后，才由 Human 决定 Close。Close 之后是否并入 TestFlight 候选，由 Human 另行决定。

2026-10-25 Asia/Shanghai：Human 已决定本 Assignment Close（来源：`~/.kos-work/Universe-Keyboard/PORTFOLIO-REFRESH-005A/reports/human-authorization-005a-v2-issued.md`（SHA-256 `5ea45537ca6c609306f3b2637c4261a4411ba86284b647eec644d741f70238df`））；在承载本记录的 PR 合并时生效，不适用 D7，不代表并入 TestFlight 候选或发布许可。

## Assignment

- **Domain Owner:** Keyboard UI（Architecture and Knowledge Steward 协同）
- **Executor:** Executor 角色（AI 不限）；建议 effort medium；实际配置：（Executor 填；拿不到写“未确认”）
- **Environment Executor:** 模拟器：Executor（可脚本化部分）与 Human Product Owner（手点步骤）；真机：Human Product Owner（见上，待 Human 在派发时确认）
- **Human Dependency:** Human Product Owner：开工授权、真机签名与安装、真机验收、22 档的真机手测、push / PR / merge
- **Architecture Reviewer / Quality Reviewer:** 独立 Reviewer 会话（AI 不限）；独立性条件：未参与本任务实现，且不是另一位 Reviewer 的同一会话；lane `U3F-ARCH`、`U3F-QUAL`

## Reports

Executor 与 Reviewer 的指令、packet、报告均保存为文件，根目录 `~/.kos-work/Universe-Keyboard/UI3-FONT-001/`（`instructions/`、`packets/`、`reports/`）；仓库内只记录路径与 SHA-256。派发 = 角色 + 文件路径 + SHA-256。

## Gates

- **Entry:** Human 授权派发（含 Environment Executor 与真机分工的确认）；独立 worktree 与新分支 `feature/ui3-font-001`，从最新 `origin/main` 开；Human 本地 main 的 dirty 文件不得触碰；Executor 先完成 P0 并经 Coordinator 确认。
- **Exit:** 产品决定第 8 节七条验收标准都有证据；P1 至 P4 门禁通过；Reviewer 评审完成；Human 真机验收完成。
- **Stop（任一出现就停下报告，不自行处理）：** 需要放宽任何超时或断言；需要改 RIME 逻辑或输入链路；需要改默认数值或候选栏高度；需要依赖主 App 读键盘存储；基线移动且与改动文件重叠（含与 UI-4 重叠）；TD-020 相关测试出现新的失败；发现与 `docs/KEYBOARD_VALUES.md` 不一致的数值（记录并报告，不顺手修）；任何 push / merge。
- **Handoff Target:** Human Product Owner。**Revalidation:** 产品决定变更、基线明显漂移、设备或系统版本变化。

## Exit evidence

| 项 | Result |
|---|---|
| P0 预检报告（读取时机、存取方式、入口位置、双路径表达的结论） | `~/.kos-work/Universe-Keyboard/UI3-FONT-001/reports/executor-report-p0.md`（SHA-256 `9bd6e2a9ad1957cd8747523e43cb31c49cdd7c1b00aca7b74365d66f03aacab1`） |
| 阶段 P1 至 P4 的门禁结果与测试摘要 | `~/.kos-work/Universe-Keyboard/UI3-FONT-001/reports/executor-report-p1-p2.md`（SHA-256 `cd3ca3af75669a67ae38af583ef56361e4d9fa539c57a01d67798f979ecf9887`）；`~/.kos-work/Universe-Keyboard/UI3-FONT-001/reports/executor-report-p3-p4.md`（SHA-256 `b36639767ebebb4bf0e6a0084258e71292cd58aea19330f93d12eb5c02fb8407`）；后续预览与补证：`~/.kos-work/Universe-Keyboard/UI3-FONT-001/reports/executor-report-p6-r1.md`（SHA-256 `ba510a3f0050c434cb72c8f6c29a8d479d5e231e2f2d128890de32c0940c78e7`）；`~/.kos-work/Universe-Keyboard/UI3-FONT-001/reports/executor-report-p7.md`（SHA-256 `695f231265f0a6572162dba5871173ecce83f38c34445b0e676617ce2688f2da`）。结果为 Executor-recorded；历史 Core 两项三条断言失败保留，串行重跑绿不证明稳定性或根因 |
| 默认档逐值不变的证据（F1） | `~/.kos-work/Universe-Keyboard/UI3-FONT-001/reports/executor-report-p1-p2.md`（SHA-256 `cd3ca3af75669a67ae38af583ef56361e4d9fa539c57a01d67798f979ecf9887`）：默认候选17 / 组字15分别按 body 缩放并各封顶28，small / large / XXXL / 最大辅助字体与旧 UIFontMetrics 表达式逐值比较；真实普通 cell 字体与测量同源、展开 cell 字体覆盖；夹具隔离引擎/宿主，不等于真实 Extension 激活。新增字号7项与相关目标通过为 Executor-recorded |
| Reviewer 报告路径与 SHA-256 | `~/.kos-work/Universe-Keyboard/UI3-FONT-001/reports/review-arch-r1.md`（SHA-256 `7255dbccb02ebccfea056410f0fd142c2bb87364e887aeeb07d3a8117803e72a`）：Pass with conditions；`~/.kos-work/Universe-Keyboard/UI3-FONT-001/reports/review-qual-r1.md`（SHA-256 `42839430e054f34a374dea8b6121ebfbe026d1d7fd7465df366fa5565e45cfeb`）：Blocker（测试覆盖缺口，不是产品缺陷）；`~/.kos-work/Universe-Keyboard/UI3-FONT-001/reports/review-arch-r2.md`（SHA-256 `11d2637cc673f000d4a1435c40c4de5c326de65fce025c6300a4d60d4d69b207`）：Pass（P7 窄复核）；`~/.kos-work/Universe-Keyboard/UI3-FONT-001/reports/review-qual-r2.md`（SHA-256 `1cf91ef9f3db0d0a03daf21a37d656778a6f0e63f018c5ed8c5e9d547a744d8f`）：Pass with conditions（测试结果为 Executor-recorded，Reviewer 未重跑）；Round 1 缺口由 Round 2 覆盖，不抹去历史结论 |
| Human 真机验收清单与结果 | `~/.kos-work/Universe-Keyboard/UI3-FONT-001/reports/p5-human-checklist.md`（SHA-256 `18261b731e9a4adc0962cd23ede8988aaac70606b226515aa691c726dcfaaa57`）；`~/.kos-work/Universe-Keyboard/UI3-FONT-001/reports/human-device-results-2026-10-24.md`（SHA-256 `17f3d5e9daebd18f179a4a4f333dc505499cf47b6a3ba089644156b7dce24c47`）；清单全部通过为 Human 报告；Human 真机观察（不是测量）仅覆盖 `b0e0361`（iPhone 13 Pro、iOS 27.0.1）；完全访问关/开表现无区别；Debug/Release UNKNOWN；之后的预览提交 `eae739e`、`0db9b27` 与测试/文档提交 `16bab5c`、`f489968` 未经真机验收 |
| 合并 | [PR #236](https://github.com/shchnk1103/Universe-Keyboard/pull/236)，头提交 `f48996884effb33156bbfc13d9a5d986455a4bdb`，合并提交 `b8f6b6516064c4721c884a53e1437e01d83449e7`，2026-10-24 23:54 Asia/Shanghai；10 项检查全部 SUCCESS（含 test-app-keyboard、final-quality-gate）；来源：2026-10-25 `gh pr view 236 --repo shchnk1103/Universe-Keyboard` |
