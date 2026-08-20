# RELEASE-2026-0801-10 iOS 18.0 目标架构审查

> **审查日期：** `2026-08-18 Asia/Shanghai`
>
> **审查角色：** 🏛️ Architecture & Knowledge Steward（与 Executor 同一 Codex 线程；见独立性说明）
>
> **审查对象：** [`RELEASE-2026-0801-10`](../assignments/release-2026-08-01-10-ios-18-target.md) 的 Phase 1 编译对齐边界
>
> **Product Decision:** [`PD-RELEASE-2026-0801-MINIMUM-OS-IOS18`](../product-decisions/RELEASE-2026-0801-minimum-os-ios18.md)
>
> **证据类型：** 配置 / API 预检。不是 Archive、不是 Quality 结论、不是 iOS 18 运行时或发布证明。

## 独立性说明

本审查与后续实施发生在同一 Codex 线程。它只授权**配置边界**，不能替代独立 Quality Review。审查结论不得被改写成“第二人已验收”。

## 结论

**Go — 仅授权 Phase 1 编译对齐。**

Human Product Owner 已把 V1.0 最低系统从 iOS 26.0 改为 iOS 18.0，并明确接受“先过编译、样式后补”。在该 Product Decision 下，继续把 26.0 runtime / 稳定 Xcode 当作实施 Entry blocker 已不再成立。

本结论 **不是**：

- iOS 18 外观可用
- iOS 18 输入 / Full Access / RIME 已验证
- 稳定工具链或签名 Archive 通过
- 可上架

## 观察事实

- 入库工程级与测试 target 仍为 `IPHONEOS_DEPLOYMENT_TARGET = 26.4`。
- 工作区已把 Keyboard Extension 单独改成 `18.0`，这正是当前
  `KeyboardCore has a minimum deployment target of iOS 26.4` 编译失败的原因。
- `Packages/KeyboardCore/Package.swift` 与 `Packages/RimeBridge/Package.swift` 仍声明 iOS `26.4`。
- KeyboardCore 的 `Synchronization.Mutex` 路径把**硬地板**钉在 iOS 18.0；再降到 17 未授权。
- 源码中显式 iOS 版本守卫均为 `#available(iOS 26.0, *)`（`UIScrollEdgeEffect`、`UIGlassEffect`、`.glassEffect`）。未发现 26.1–26.4 专属标记。
- 键盘表面当前按 iOS 26 系统容器设计：`view.backgroundColor` 与 `keyboardSurfaceView` 默认为 clear。这是 Phase 2 风险，不是 Phase 1 编译 blocker。
- 本地 Xcode 为 `27.0` / `27A5237l`（beta）。按 Product Decision，它只可用于 Phase 1 编译证据。
- Vendor xcframework 切片未声明 `MinimumOSVersion`。这不影响 Phase 1 编译授权，但阻止任何 iOS 18 运行时宣称。

## 授权实施边界

实施者只可改：

1. `Universe Keyboard.xcodeproj/project.pbxproj` 中全部 `IPHONEOS_DEPLOYMENT_TARGET` 到 `18.0`（含工程级、Keyboard、全部测试 target）；
2. 两个本地 Package 的 iOS platform 声明到 `18.0`；
3. `docs/PROJECT_CONTEXT.md` 的当前 deployment-target 陈述，以及被本 Decision 取代的 Minimum OS 文档指针；
4. 编译器证明“引入于 iOS 18.0 之后”的 API 的最小 `#available` 替代；
5. 撤回与最低系统无关的 `Keyboard.xcscheme` 宿主改动。

## 禁止

- 修改 RIME 部署所有权、Extension 热路径、Vendor 内容、entitlements、签名或 SDK 选择。
- 关闭 availability / warning / concurrency 检查来换编译通过。
- 把键盘 chrome、颜色、圆角或高度调整塞进 Phase 1。
- 用 beta 编译、更高系统模拟器或历史 26/27 证据宣称 iOS 18 已验证。
- 在本 Assignment 下 archive、上传、提交或发布。

## 不要求新 ADR 的理由

最低系统是 Product 范围合同，历史 iOS 26.0 地板也记录在 `RELEASE-2026-0801-02`，不是独立 ADR。本次只 supersede 该行。RIME 主 App 独占部署、Extension session-only、Full Access 边界均不变，因此不新开 ADR。

## 重新验证

以下任一变化都要使本审查重做：Product 再次改最低系统、target / Package 矩阵漂移、出现未守卫的 iOS 26 API、Phase 2 chrome 被授权、或最终 Archive / 稳定工具链变化。
