# Assignment: UI3-FONT-001 — 候选字大小（v1）实现

Policy version: 1.0.0
record_id: UI3-FONT-001

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Assigned（职责已定；Entry Criteria 尚未全部满足，尤其 Human 授权派发。满足后由 Coordinator 在派发记录里改为 Ready，再随开工转 Active） |
| Current phase | 定稿，待 Human 授权派发 Executor。产品决定 [PD-UI3-CANDIDATE-FONT-SIZE-001](../product-decisions/UI3-CANDIDATE-FONT-SIZE-001-product-contract.md) 已于 2026-10-23 被接受；本 Assignment 把它落成产品代码、测试与镜像文档 |
| Material non-claims | 不是 UI-4（键盘高度）；不是 Product Gate、TestFlight 或 Release；不改默认字号与任何既有布局数值；不放宽任何超时或断言；本记录本身不含任何代码 |
| Human 确认状态 | 产品决定的接受：**已确认**（Human Product Owner，2026-10-23）。开工授权：**待 Human**。Environment Executor 与真机分工（见下）：**待 Human 在派发时确认** |
| Next handoff / decision | Human 授权派发 → Executor 阶段 P0（先出预检报告）→ 逐阶段推进 → Coordinator 冻结 Reviewer 包 → Architecture / Quality Reviewer → Human 真机验收 → Human 决定 push / PR / merge |

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
| P0 预检报告（读取时机、存取方式、入口位置、双路径表达的结论） | （Executor 填） |
| 阶段 P1 至 P4 的门禁结果与测试摘要 | （Executor 填） |
| 默认档逐值不变的证据（F1） | （Executor 填） |
| Reviewer 报告路径与 SHA-256 | （Coordinator 填） |
| Human 真机验收清单与结果 | （Human / Executor 填） |
