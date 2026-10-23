# Assignment: UI4-HEIGHT-001 — 自定义键盘高度（v1）实现

Policy version: 1.0.0
record_id: UI4-HEIGHT-001

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Assigned（职责已定；Entry Criteria 尚未全部满足，尤其 Human 授权派发。满足后由 Coordinator 在派发记录里改为 Ready，再随开工转 Active） |
| Current phase | 定稿，待 Human 授权派发 Executor。产品决定 [PD-UI4-KEYBOARD-HEIGHT-001](../product-decisions/UI4-KEYBOARD-HEIGHT-001-product-contract.md) 已于 2026-10-23 被接受；本 Assignment 把它落成产品代码、测试与镜像文档 |
| Material non-claims | 不是 UI-3（候选字大小）；不是 Product Gate、TestFlight 或 Release；不合并 Spike 的实验分支或实验代码；不改默认高度与任何既有布局数值；不放宽任何超时或断言；本记录本身不含任何代码 |
| Human 确认状态 | 产品决定的接受：**已确认**（Human Product Owner，2026-10-23）。开工授权：**待 Human**。Environment Executor 与真机分工（见下）：**待 Human 在派发时确认** |
| Next handoff / decision | Human 授权派发 → Executor 阶段 P0（先出预检报告）→ 逐阶段推进 → Coordinator 冻结 Reviewer 包 → Architecture / Quality Reviewer → Human 真机验收 → Human 决定 push / PR / merge |

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner 于 2026-10-23 Asia/Shanghai 接受 [PD-UI4-KEYBOARD-HEIGHT-001](../product-decisions/UI4-KEYBOARD-HEIGHT-001-product-contract.md)（范围、封顶规则、完全访问、调节态进入与退出、保存、验收标准以它为准，本记录不重写）；同日决定发布采用“下周验收后发布含 UI-4 的版本”，**不是本 Assignment 的授权范围**。
- **Product Approver:** Human Product Owner（Product Lead）

## 背景与输入

基线 `origin/main`：开工时由 Executor 重新核验并写进报告。输入（Executor 开工前全部读完）：

- 产品决定 `docs/product-decisions/UI4-KEYBOARD-HEIGHT-001-product-contract.md`（唯一的需求权威）。
- [`docs/KEYBOARD_VALUES.md`](../KEYBOARD_VALUES.md)（数值权威是代码，该文档是带来源索引；改数值前先读）。
- [UI4-SPIKE-001 结果摘要](../evidence/ui4-spike-001-summary.md) 与 [UI-4 详情](../portfolio/ui-4-keyboard-height.md)。
- 外置只读参考（Human 本机，不在仓库）：`~/.kos-work/Universe-Keyboard/UI4-SPIKE-001/worktree` 的分支 `spike/ui4-height-001`（实验探针；**只借鉴思路，不得拷贝或合并其代码**）；`~/.kos-work/Universe-Keyboard/KEYBOARD-HEIGHT-INVENTORY-001/reports/inventory-r1.md`（2026-10-22 的只读盘点，模型输出，使用前自行核对）。
- `AGENTS.md`、`docs/ASSIGNMENT_POLICY.md`、`docs/UI_STYLE_GUIDE.md`（V1 冻结基线）、`docs/PROJECT_CONTEXT.md`、`docs/TECH_DEBT.md`（TD-020）。

## Boundary

- **Scope：** 实现产品决定的第 1 至 8 节：
  1. **KeyboardCore：** 行高设置模型（默认 45、下限 40、按方向的上限计算、整数 pt、重置即删除），纯 Swift、可单测，不依赖 UIKit。
  2. **键盘扩展：** 把行高从控制器上不可变的 `keyHeight`（现为实例 `let`，值 45）改成可变的有效行高；所有由它派生的数值（九键 chrome 高度、路径展开面板最小高度、表情页网格高度、总高请求等）同步跟随；每次出现时读取保存值，不在输入中途重排；有效行高 = 保存值夹在“当前方向的上限”与下限之间，夹低只影响显示、不写回；宿主压缩高度时有效行高跟随，不影响保存值。
  3. **调节态：** 键盘内的遮罩与控件（拖动、重置、取消、确定）；输入拦截（调节态下按键、删除键、候选都不能输入或上屏）；调节控件的点击优先于按键扩大后的触控范围；进入与退出协议（随机标记只处理一次；确定 / 取消 / 离开页面 / 切换键盘 / 窗口消失任一发生都退出并复位；同一标记不重入；调节态不跨宿主、跨会话保留）；确定在键盘自己的进程里写入扩展自己的存储，**不依赖完全访问与共享存储**。
  4. **主 App：** “键盘布局”下新增“键盘高度”入口与调节页；页面上没有用户可见的输入框（用看不见的输入框弹出键盘并带随机标记，须处理 VoiceOver 与关闭方式）；入口旁一行固定的完全访问说明文字；搜索目录登记；主 App 不显示具体行高数字、不读键盘的存储。
  5. **测试：** 把写死 254 / 288 / 45 / 46 的断言改成引用默认常量或参数化（涉及 `KeyboardTests/ControllerLayout/CompactHeaderControllerLayoutTests.swift` 与 `KeyboardLayoutIntegrationTests/T9AdaptiveRowTests.swift`，后者含 TD-020 的间歇性失败测试）；新增：设置模型与夹取的单元测试、输入拦截、退出协议各场景、默认值不变的回归、九键组字态（含路径栏）。**不得放宽任何超时或断言来掩盖失败**；改动 `T9AdaptiveRowTests` 或面板几何前先按停止条件报告。
  6. **镜像文档（同一次变更里更新）：** `docs/KEYBOARD_VALUES.md`（必须）、`docs/KEYBOARD_LAYOUT.md`、`docs/UI_STYLE_GUIDE.md`（V1 冻结基线仍是默认 45，注明现在可由用户调节）、`docs/PROJECT_CONTEXT.md`；是否需要新 ADR 先核对 Policy 再报告；`CHANGELOG.md` 按现有约定；过时的注释（`+Layout.swift:49-50`、`+Presentation.swift:5`）顺带更新。
- **Non-goals：** 产品决定第 9 节全部（按设备自动计算默认高度、按方向分别保存、调宽度、单独某一行高度、实时预览、键盘内入口、UI-3、TestFlight / Release）；任何 RIME 逻辑与输入链路改动；改动默认数值；改 CI 配置；合并实验分支；push / PR / merge（除非 Human 另行授权）。
- **Required Inputs：** 见“背景与输入”。

## 阶段与停止点

| 阶段 | 内容 | 产物 / 停止 |
|---|---|---|
| P0 预检 | 追踪并写清三件 UNKNOWN：(a) 设置读取与首次布局安装的先后（`viewWillAppear → installKeyboardUIIfNeeded` 与 `refreshCachedSettings` 的顺序，怎样做到“不先闪现默认高度”）；(b) 在键盘扩展里可靠取得屏幕高度与方向的来源；(c) 看不见的输入框的 VoiceOver 行为与关闭方式。读 Spike 实验代码只作参考。 | 预检报告 `reports/executor-report-p0.md`，**停下等 Coordinator 确认再继续** |
| P1 核心 | KeyboardCore 的设置模型与夹取，含单元测试 | 本地 `swift test`（KeyboardCore）通过；报告 |
| P2 布局 | 键盘扩展行高可变与派生数值；默认值不变的证据（含九键、表情、数字、符号页） | 测试与模拟器截图（Executor 做可脚本化部分）；报告 |
| P3 调节态 | 遮罩、控件、输入拦截、点击优先级、进入与退出协议 | 单元 / 集成测试；模拟器日志；报告 |
| P4 主 App | 入口、调节页、固定说明、搜索登记 | 编译与模拟器截图；报告 |
| P5 镜像与门禁 | 镜像文档、strict swift-format、KeyboardCore 全量测试、App 与 Keyboard 的 Debug build-for-testing、链接检查 | 门禁结果表；报告 |
| P6 验收准备 | 写 Human 的真机验收清单（按产品决定第 10 节八条，照片与日志取证点写清，沿用此前“每一步做什么、什么时候拍什么”的写法）并出 Reviewer 材料 | `docs/` 之外的外置清单；Coordinator 冻结 Reviewer 包 |

每个阶段结束写增量报告，报告开头声明运行时身份；最终消息要短，不复述报告。

## Environment Executor 与真机分工

模拟器：可脚本化的构建、安装、启动、日志、`simctl` 截图由 Executor 做；需要手点的步骤由 Executor 写成清单，交 Human 执行并把结果交回（**不要用 GUI 自动化操作系统设置**，此前出过失误）。真机：Human Product Owner（iPhone 13 Pro，iOS 27.0.1，自己用 Xcode 签名并安装）。Spike 之后模拟器上专用的“UI4 Spike iPhone 13 Pro”已不在设备列表里，需要时 Executor 另选并写明。

## Reviewer claim register

| ID | 声称 |
|---|---|
| H1 | 没有保存值时，默认高度与既有数值逐项一致（26 键 254、九键空闲 254 / 组字 288、行高 45、候选栏 46、路径栏 0 / 34）；既有测试仍通过；写死数字的测试已改为引用常量或参数化而没有削弱断言 |
| H2 | 调节态下按键、删除键与候选都不能输入或上屏，有日志或测试证据，而不只是目测；调节控件的点击优先于按键触控范围（含横屏高行高） |
| H3 | 保存与读取：整数 pt、重置即删除；确定写进扩展自己的存储，不依赖完全访问与共享存储；下次出现时采用新值且不先闪现默认高度 |
| H4 | 封顶：横屏有效行高不超过 45；竖屏整块总高不超过屏高 50%（含路径栏）；下限 40；夹低只影响显示、不写回；宿主压缩时有效行高跟随；九宫格组字态也满足 |
| H5 | 进入与退出协议各场景（确定、取消、离开页面、切换键盘、窗口消失）都有测试或证据；同一随机标记不重入；调节态不跨宿主、跨会话保留 |
| H6 | 完全访问：不作门槛；主 App 入口旁有固定说明文字；主 App 没有任何完全访问检测或读键盘存储的代码 |
| H7 | 没有放宽任何超时或断言；TD-020 相关测试没有被削弱；没有新增 RIME 或输入链路改动；日志里不记录用户输入的文字 |
| H8 | 镜像文档与代码一致（`KEYBOARD_VALUES.md` 等）；没有拷入 Spike 实验代码；没有 Scope 外文件变化；看不见的输入框的 VoiceOver 与关闭方式有处理 |
| H9 | Executor 报告与仓库事实一致，UNKNOWN 没有被偷偷填充，每个阶段有运行时身份 |

## Closeout Decision

本 Assignment 是产品开发（代码）类，**不适用 D7 的直接 Close**：Reviewer 评审、Human 真机验收（产品决定第 10 节八条）与 Human 对 PR 的决定之后，才由 Human 决定 Close。Close 之后是否并入 TestFlight 候选，由 Human 另行决定。

## Assignment

- **Domain Owner:** Keyboard UI（Architecture and Knowledge Steward 协同）
- **Executor:** Executor 角色（AI 不限）；建议 effort high（涉及核心布局与输入链路旁的改动）；实际配置：（Executor 填；拿不到写“未确认”）
- **Environment Executor:** 模拟器：Executor（可脚本化部分）与 Human Product Owner（手点步骤）；真机：Human Product Owner（见上，待 Human 在派发时确认）
- **Human Dependency:** Human Product Owner：开工授权、真机签名与安装、真机验收、push / PR / merge、下限 40pt 的真机手测
- **Architecture Reviewer / Quality Reviewer:** 独立 Reviewer 会话（AI 不限）；独立性条件：未参与本任务实现，且不是另一位 Reviewer 的同一会话；lane `U4H-ARCH`、`U4H-QUAL`

## Reports

Executor 与 Reviewer 的指令、packet、报告均保存为文件，根目录 `~/.kos-work/Universe-Keyboard/UI4-HEIGHT-001/`（`instructions/`、`packets/`、`reports/`）；仓库内只记录路径与 SHA-256。派发 = 角色 + 文件路径 + SHA-256。

## Gates

- **Entry:** Human 授权派发（含 Environment Executor 与真机分工的确认）；独立 worktree 与新分支 `feature/ui4-height-001`，从最新 `origin/main` 开；Human 本地 main 的 dirty 文件不得触碰；Executor 先完成 P0 并经 Coordinator 确认。
- **Exit:** 产品决定第 10 节八条验收标准都有证据；P1 至 P5 门禁通过；Reviewer 评审完成；Human 真机验收完成。
- **Stop（任一出现就停下报告，不自行处理）：** 需要放宽任何超时或断言；需要改 RIME 逻辑或输入链路；需要改默认数值；需要依赖完全访问或共享存储；需要把调节态做成键盘内入口；基线移动且与改动文件重叠；TD-020 相关测试出现新的失败；发现与 `docs/KEYBOARD_VALUES.md` 不一致的数值（记录并报告，不顺手修）；任何 push / merge。
- **Handoff Target:** Human Product Owner。**Revalidation:** 产品决定变更、基线明显漂移、设备或系统版本变化。

## Exit evidence

| 项 | Result |
|---|---|
| P0 预检报告（三件 UNKNOWN 的结论） | （Executor 填） |
| 阶段 P1 至 P5 的门禁结果与测试摘要 | （Executor 填） |
| 默认值不变的证据（H1） | （Executor 填） |
| Reviewer 报告路径与 SHA-256 | （Coordinator 填） |
| Human 真机验收清单与结果 | （Human / Executor 填） |
