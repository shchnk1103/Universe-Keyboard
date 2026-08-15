# Assignment: KEY-TOUCH-FILL-001 — 各键盘触摸盒铺满键区且 overlay 不得改命中

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Completed`（Human 真机 Product Gate Passed） |
| **Phase** | 26 键与九键在 overlay 关/开两种状态下，键面、按键间隙及原生长按/切换路径均通过真机复验 |
| **Non-claims** | 不改键面视觉尺寸；不代表已提交、推送或合并 |
| **Next** | 实现任务无剩余；诊断页加载与搜索缺陷继续由 TD-013 独立追踪 |
| **Residuals** | Extension 当前没有可直接断言真机 UIKit delivery 的自动化 UI target；gap control 只代理点击/删除键 target-action，可见键面上的长按、空格光标和地球仪仍走原按钮路径 |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** [`PD-KEY-TOUCH-FILL-001`](../product-decisions/KEY-TOUCH-FILL-001-authorization.md)；Human Product Owner 截图 + 两则 bug，`2026-08-15 Asia/Shanghai`
- **Product Approver:** Human Product Owner / 当前 Product 线程

## Boundary

### Scope

1. 修复 26 键触摸盒未铺满键区：尤其第三行嵌套字母 `z…m` 丢失竖向缝与 Shift/删除缝；第二行 18 pt 左右槽归首尾键。
2. 修复九键快照为空、整列高度误当键面、以及触摸落到列顶键：布局工厂显式提供左右列与行语义，根容器仅在嵌套 UIKit 布局完成后读取真实键面。
3. 修复「显示按键触摸范围」关闭后命中变小：overlay 不得成为第二条命中路径；开/关使用同一份 `touchFrame` 快照。
4. 命中、`point(inside)` outset、overlay 实线必须来自同一份 `KeyTouchCellLayout` 快照。
5. 普通布局从根容器读取完成布局后的按钮键面；九键使用显式左右列/行合同生成结构化快照，不扫描约束或猜测高度。

### Non-goals

- 改键高、行距、18 pt 错位、圆角或系统地球仪/麦克风条。
- 把九键回车摊成整键盘宽，或改变任一键盘的视觉布局。
- Release / TestFlight overlay。
- 候选栏 / Path 合同、万象模型、发布子项。

### Required Inputs

- [`PD-KEY-TOUCH-FILL-001`](../product-decisions/KEY-TOUCH-FILL-001-authorization.md)
- [`PD-DEBUG-KEY-HITBOX-001`](../product-decisions/DEBUG-KEY-HITBOX-001-authorization.md)
- [`KeyTouchCellLayout.swift`](../../Packages/KeyboardCore/Sources/KeyboardCore/KeyTouchCellLayout.swift)
- [`KeyboardInputHitAreaStackView.swift`](../../Keyboard/Controllers/KeyboardInputHitAreaStackView.swift)
- Human 截图：第三行字母橙框明显矮于 Shift/删除，第二行 `a`/`l` 外侧米色槽未铺满

## Assignment

- **Domain Owner:** ⌨️ Keyboard Experience Maintainer
- **Executor:** 当前 Codex 会话（Human Product Owner 于 2026-08-15 明确重指派）
- **Environment Executor:** 当前 Codex 会话（本地 Core / UIKit target 构建与测试）
- **Human Dependency:** Resolved — Human Product Owner 已完成 Debug overlay 关/开同点真机复验
- **Architecture Reviewer:** Not Applicable — 不改 ADR / 部署边界；只把已接受的中线填缝快照重新接到 26 键嵌套行
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer（尚未独立复核；本轮只有 Executor-recorded 自动化证据）
- **Product Approver:** Human Product Owner / 当前 Product 线程

## Investigation (Executor, before code)

Observed in `makeLetterThirdRow`: `[Shift | letterRow(z…m) | Delete]`。`touchInsets(for:)` 只看 **直接父** `UIStackView`：

- `z…m` 的父是内层字母行；`parent.superview` 是水平第三行，不是垂直根栈 → `topGap`/`bottomGap` = 0。
- `z`/`m` 相对内层行是首/尾，左右缝按内层 bounds 计算 ≈ 0，**拿不到** `thirdRowFunctionSpacing`（10 pt）与 Shift/删除的中线。
- Shift/删除的 peers 只有彼此，竖向缝只分给它们，字母行米色槽成为死区。

这与 26 键截图一致（第三行字母橙框明显矮一圈），不是间距常量算错。

九键最新截图的 `path=t9 k=0 tap snap=0` 则说明运行期没有发布任何触摸快照。旧实现从根 stack 的 `layoutSubviews` 向下扫描嵌套约束，并用高度范围、整列高度钳制和手工 Y 堆叠来反推行；该时点不能保证更深层九键 stack 已完成布局。修复不再增加阈值，而是由九键布局工厂保留已知行列语义，并在 `KeyboardViewController.viewDidLayoutSubviews()` 后读取真实按钮键面。

第二则：当前 `keyContainingTouch` 与 overlay 虽号称同一 inset，但父栈算法留出的死区在 overlay 开启时仍可能被「看得见的键区」误导；PD 要求开/关同一点同一键。正确收敛是根容器快照，禁止 overlay 子视图成为补充命中面。

## Gates

### Entry Criteria

- [x] Human 授权修复两则 bug，并要求先查后改。
- [x] Product Decision 已记录；规则仍是中线填缝。
- [x] Active Work 容量允许（进入时 3/10）。
- [x] 根因已用布局结构核对，不是猜测改 inset 常数。

### Exit Criteria

- [x] 26 键几何测试：内缩行首尾铺到容器左右；嵌套第三行字母拿到竖向中线与功能键缝。
- [x] `hitTest` / outset / overlay 使用同一份快照；关闭 overlay 只隐藏绘制。
- [x] 九键结构化列测试保持绿。
- [x] KeyboardCore 套件通过。
- [x] App + Keyboard 测试 target 通过（含 Extension 严格并发编译）。
- [x] RimeBridgeTests 与 Release 严格并发构建通过。
- [x] CHANGELOG / Active Work / 本 Assignment 状态已更新。
- [x] Human Debug overlay 开/关同一点目视。

### Stop Conditions

- 为铺满 26 键而破坏九键列隔离。
- Overlay 参与 hit-test，或开/关两套矩形。
- `convert(bounds)` 再次把列祖先框当成键面。
- 热路径读 App Group。

## Handoff

- **Handoff Target:** 完成；Human Product Owner 已接受真机行为
- **Required Handoff Content:** 根因、改动文件、自动化结果与 Human 真机 Product Gate 已记录
- **Revalidation Trigger:** 再改触摸几何、九键列合同、Release 可见性

## History

- 2026-08-15: Human 截图报告两则 bug；Executor 先读布局与 `touchInsets`，确认嵌套第三行丢失邻接缝，再立本 Assignment。
- 2026-08-15: Human 复验：26 键 overlay 开着正常；九键未铺满且只响应每列顶键；关闭 overlay 后各布局缩回键面。判定上一轮把 overlay 挂在按钮上 + 用 `CGRect ==` 回配快照会拆掉九键列结构。改为 caller-id 快照，overlay 画在 `keyboardSurfaceView`（非 UIStackView）。
- 2026-08-15: Human 认可「先对照再收一条管线」。只加 `TOUCHPROBE` 只读摘要，不改 `makeCells` / 命中公式。
- 2026-08-15: 探针 `maxVH=599 xs=5` 钉死九键量到的是整列。钳回行/按钮高度约束，原点用父槽；`point(inside)` 改读快照 `localTouchBounds`。
- 2026-08-15: Human 复验：26 键底行橙框只盖上半（`maxVH=45`）；九键 `maxTH=340 colTall=10`，点 WXYZ 到 DEF。改为按 arranged 行序堆叠 Y，底行只吸收合理剩余高度；横行采集不再 flatten 竖列。
- 2026-08-15: Human 最新截图显示九键 `path=t9 k=0 tap snap=0`，前述探针收口失败；Human 重申视觉键帽小于实际触摸单元、触摸单元按中线铺满整个键区的产品准则，并将 Executor / Environment Executor 从 Grok 会话重指派给当前 Codex 会话。当前 Codex 已确认 Scope、Non-goals 与 Human 真机依赖，Assignment 恢复为 `Active`。
- 2026-08-15: 当前 Executor 移除九键约束扫描、魔法高度钳制与手工行坐标，改由布局工厂声明左右列/行语义；根容器在 `viewDidLayoutSubviews` 后发布唯一快照，命中、按钮 tracking 与 Debug overlay 共用它。普通布局继续按真实键面中线铺满根键区。
- 2026-08-15: Executor-recorded：`swift-format` strict 通过；KeyboardCore `1005/0`；App + Keyboard `195/0`（另 3 个真机专属用例按预期 skip）；RimeBridgeTests `68/0`（20 个 spike/runtime-dir 用例按预期 skip）；Debug / Release 严格并发 build 均通过。使用 iOS 26.5 `iPhone 17 Pro`，因为本机 iOS 26.0 runtime 低于项目 26.4 deployment target。Lifecycle 转 `Completed`，Human 真机 Product Gate 保持未关闭。
- 2026-08-15: Human 真机 overlay 复验确认 `path=t9 k=18`、各键行列已正确，但第四列与第五列之间仍有一条无橙框区域。该区域是左右 column container 之间的 host spacing，未被任一 column bounds 包含。Human 授权继续；Assignment 回退为 `Active`，只授权按跨列中线分配该间距。
- 2026-08-15: 结构化列几何现将相邻 column bounds 之间的 host spacing 切在中点：左四列触摸盒延伸至中线，右功能列从中线开始；视觉 bounds、纵向行合同与高回车均未改变。新增跨列左右点选回归，聚焦套件 `21/0`；最终 KeyboardCore `1006/0`、App + Keyboard `195/0`（3 个真机专属 skip）、RimeBridgeTests `68/0`（20 个环境依赖 skip）、Release 严格并发 build 均通过。Lifecycle 返回 `Completed`，等待 Human 真机门。
- 2026-08-15: Human 真机确认 overlay 开启时九键与 26 键的按键间隙均正确响应，但 overlay 关闭后两种布局的间隙均无响应，Product Gate 未通过。静态代码中开关只切换绘制状态并增删非交互 canvas，尚不足以确认是 snapshot 生命周期、根 hit-test 路由还是 UIControl delivery。按计划搜索 `TOUCHPROBE` 时，诊断页长时间加载；当天最终显示 500 条后仍无匹配。触摸 Assignment 恢复 `Active`，诊断残余登记至 TD-013；未授权猜修。
- 2026-08-15: Human 按固定 overlay-off 序列完成真机 LLDB 取证：根 `hitTest` 与 snapshot-hit 各 8 次、snapshot-miss 0 次，但 `KeyboardKeyButton.beginTracking` / `keyTouchDown` 各仅 4 次。由此排除快照与中线几何，根因收敛为 UIKit 不会为越出按钮/祖先有效交互树的返回值建立稳定 UIControl tracking；同场出现的跨 `UIScreen` coordinate-space 警告不是该分层证据的充分根因。
- 2026-08-15: Executor 移除根 stack 直接返回越界按钮的命中路径，新增与 Debug 绘制完全解耦的持久 sibling routing canvas。每个触摸单元以不可见 `UIControl` 只承接键面外空隙，并通过原按钮既有 target-action 发送 down/up/cancel；键面内返回 nil，保留字母长按、空格光标、地球仪等原生按钮/手势路径。空隙 control 沿用候选栏真机先例的 `0.001 alpha` backing，overlay 开关不创建、移除或改变它。
- 2026-08-15: Executor-recorded：最终 Swift 文件 `swift-format --strict` 通过；KeyboardCore `1006/0`；App + Keyboard `195/0`（3 个真机专属 skip）；RimeBridgeTests `68/0`（20 个环境依赖 skip）；Debug / Release 严格并发 build 均通过。使用 iOS 26.5 `iPhone 17 Pro`；Lifecycle 保持 `Active`，等待新构建的 Human 真机 overlay 关/开同点复验。
- 2026-08-15: Human Product Owner 在真机完成最终矩阵并报告“测试全通过”：overlay 关闭与开启时，26 键、九键各方向按键间隙均命中正确；普通键面、字母长按、删除长按、空格光标与地球仪路径亦通过。Human Product Gate Passed，Assignment 转 `Completed`；TD-013 诊断加载/搜索问题不阻断本任务并继续独立追踪。
