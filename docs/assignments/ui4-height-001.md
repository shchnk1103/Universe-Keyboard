# Assignment: UI4-HEIGHT-001 — 自定义键盘高度（v1）实现

Policy version: 1.0.0
record_id: UI4-HEIGHT-001

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Closed（Human 2026-10-25 决定；在承载本记录的 PR 合并时生效） |
| Current phase | 代码已合并（PR #234，`ebf7e4fa51967b58be80c2cef00f7c3e9fdd8e17`）；合并后目录刷新已完成（本地登记，待本记录 PR 合并生效）；UI-3 已合并（PR #236） |
| Material non-claims | 不是 UI-3（候选字大小）；不是 Product Gate、TestFlight 或 Release；不合并 Spike 的实验分支或实验代码；不改默认高度与任何既有布局数值；不放宽任何超时或断言；本记录本身不含任何代码；不是 TestFlight / Release 许可；Human 观察不是测量；已知限制见 Exit evidence |
| Human 确认状态 | 产品决定已接受（Human Product Owner，2026-10-23）；各阶段由 Human 逐阶段授权（见外置 `reports/human-authorization-*.md`）；R-01、R-04 accept，R-06 接受为 UNKNOWN，R2-F01 边界接受（确认记录 `reports/human-confirmation-r2-f01-closeout.md`，SHA-256 `ec382ccba6f9b53102e4150f662b4a0f546d63530a0c21609970d76133973002`）；端点震动 accept |
| Next handoff / decision | 本登记记录待评审与 Human 后续发布决定；Close 在承载本记录的 PR 合并时生效；是否进入 TestFlight 候选由 Human 另行决定 |

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

本 Assignment 是产品开发（代码）类，**不适用 D7 的直接 Close**：Reviewer 评审、Human 真机验收（产品决定第 10 节八条）与 Human 对 PR 的决定之后，才由 Human 决定 Close。Close 之后是否并入 TestFlight 候选，由 Human 另行决定。本 Assignment 为产品开发类，Close 在 Human 对 PR 的决定与合并之后由 Human 决定。

2026-10-25 Asia/Shanghai：Human 已决定本 Assignment Close（来源：`~/.kos-work/Universe-Keyboard/PORTFOLIO-REFRESH-005A/reports/human-authorization-005a-v2-issued.md`（SHA-256 `5ea45537ca6c609306f3b2637c4261a4411ba86284b647eec644d741f70238df`））；在承载本记录的 PR 合并时生效，不适用 D7，不代表并入 TestFlight 候选或发布许可。

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
| P0 预检报告（三件 UNKNOWN 的结论） | `reports/executor-report-p0.md`（SHA-256 `1154f327931e8d438b29bbe6cf7b34e4dbffed1ce9803dd503ba67c857c0d0d5`） |
| 阶段 P1 至 P5 的门禁结果与测试摘要 | `reports/executor-report-p1.md`（`bc9601d7ee52db0abfe4596a384d517340609c0e35b290e72ecf73972a3f253b`）；`reports/executor-report-p2.md`（`deeaf418503f6621f206a2dd6cb87b28fa2bd33242c49cbebedf73613081fe92`）；`reports/executor-report-p3.md`（`db6afef22dd936ed9d9ede439d1f316a723b33f0fd61f421ba84532dad96d573`）；`reports/executor-report-p4.md`（`09336a0ee0fab2431991e75a836e6cc2651f267cea82442ab8ec2c066d9bd31d`）；`reports/executor-report-p5.md`（`5b52d0a3ae89aeac4bba1301a65960a618a3332453318424d8294ae7b593cbc8`）；P5 重跑 `reports/executor-report-p5-rerun.md`（`5b0f8a2e5b71883875e3be199bd115f766eddaff24cf5b58ce5b6d417818ccb5`） |
| P6 验收准备 | `reports/executor-report-p6.md`（`95d3772db9bd89b10273afe9ed5e0d0c50bd2a45f4a17a9d8572e5dad1036ffe`） |
| QA-001 | `reports/executor-report-qa001.md`（`8228151052842a3a67d6313ae363d6281cd1cf81636a2edc39d4b8b6d1465cbd`） |
| P3-R1 修订 | `reports/executor-report-p3-r1-fix.md`（`5cd6e610f32c9cc98caadd94a2cb9ff8c2c8f84c0f33546924d260e8c51f2bc7`）；`reports/executor-report-p3-r1-commit.md`（`c065cd3cd82c0b2e156a2210582d9dcd591b1a0395c382f9635cf686e7b265d7`） |
| P3-R2 修订（方向修复实现） | `reports/executor-report-orientation-fix-impl.md`（`cec6aa66812346ab02f4e722e8697f0f97f291b4fe6edc03a75c5952d60626ad`） |
| P3-R3 修订（Round 1 评审整改） | `reports/executor-report-review-r1-remediation.md`（`ad2d1daf4cb177140898e69436106aad6d329f383b0f6eef1d5a59f373690747`） |
| 默认值不变的证据（H1） | `reports/executor-report-p2.md`（同上 SHA-256）第 33–34 行：T9 与 CompactHeader 默认 254 / 288 / 45 / 46 断言改为引用默认常量，期望不放宽；默认值测试为进程内夹具证据，不是真实宿主测量 |
| Reviewer 报告路径与 SHA-256 | Architecture R1 `reports/review-architecture-r1.md`（`290c14c075e8a7c42592166e7f2815cec2271f25f8e1cd52cb8e1b14a61715c6`）：Pass with conditions（仅 Architecture lane）；Quality R1 `reports/review-quality-r1.md`（`507d78894bff7e26ecadeac78dd7726b6fd81b818c66cca1180bdabb1a9963a7`）：Pass with conditions（残项待 Authority 处置）；Architecture R2 `reports/review-architecture-r2.md`（`b2cd6c0fa052781c92d17e4ebbff441c52d7ae42d4d9583591a34eb83cfc1731`）：Pass with conditions（增量审查，无 Blocker）；Quality R2 `reports/review-quality-r2.md`（`de81ac660ab564b1e7f300ac7bb5e055e91d375d01197a0dd9178079aca00302`）：Pass（窄范围，新增发现 0） |
| Human 真机验收清单与结果 | Human 单机观察，不是测量：`reports/p4-human-device-result.md`（`a66311ba6df47679210ec5141f35fb9ec11e2e8164c761d53f267fcf1862a359`）；`reports/p6-human-gap-result.md`（`f5a7f083afe35e188daacb8ef40198897ba8f1c127a0763fe1ecc9eeb3e52c65`）；`reports/p3-r1-human-recheck.md`（`96f498bce01238dc05ee5ab2d1766fa989a50f3d36bfa9ac39fd49ded691a89b`）；`reports/orientation-fix-impl-human-result.md`（`935a5d2c9799e2330f27a0a25a2e9e1ab2e75fbd27605192ef1169d225c5db3d`）；`reports/human-gap-answers-2026-10-24.md`（`61d21d312777a00b3b12794e596f60cd99d0ec77085bb987213579463bc4fc53`）及附录 `reports/human-gap-answers-2026-10-24-addendum.md`（`8216cd3d796f57828882d26600d57c8742e8f9c4ffcf810821f17dea6ff5a37a`）；`reports/review-r1-remediation-human-result.md`（`482e2ec95781cb465655062e8ea462c255f55473e97612df3739d19ea6081a67`） |
| 残项处置 | 端点震动 accept `reports/human-decision-p3r1-endpoint-vibration.md`（`a517c364179c11c8c0fd9b61941c9b5cd358fc1de2d1e547ad064242e624d4cf`）；R-01、R-04 accept、R-06 接受为 UNKNOWN `reports/review-r1-human-disposition-confirmation.md`（`341ed14926cdebc92939563daea59148dd82d4d1712526e70505fdfd2a3cc147`）；R2-F01 边界接受 `reports/human-confirmation-r2-f01-closeout.md`（`ec382ccba6f9b53102e4150f662b4a0f546d63530a0c21609970d76133973002`） |
| 当前验收矩阵 | `reports/pm-acceptance-matrix-v3.md`（`f54efe17f5c6a5f4fb5c8681584cfec92658c5f36e79994b9cea05a7ba2244c5`） |
| 已知限制 | 端点震动（完全访问开时，来源 UNKNOWN，已接受）；竖屏最大值占屏比例未测量（Human 目测不是测量）；宿主预算不足四行 40pt 时整面隐藏；999 与真实低预算 / iPad 分屏 / 浮动键盘未验证；标记去重只保证最近 64 次成功消费内不重入；Release 真机二进制配置 UNKNOWN |
| 合并 | [PR #234](https://github.com/shchnk1103/Universe-Keyboard/pull/234)，合并提交 `ebf7e4fa51967b58be80c2cef00f7c3e9fdd8e17`；10 项检查全部 SUCCESS；来源：2026-10-25 `gh pr view 234 --repo shchnk1103/Universe-Keyboard` |
