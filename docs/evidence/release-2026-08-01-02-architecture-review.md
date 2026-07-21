# RELEASE-2026-0801-02 架构审查记录

> **审查日期：** `2026-07-21 Asia/Shanghai`
>
> **审查角色：** 独立 Architecture Reviewer（🏛️ Architecture & Knowledge Steward）
>
> **审查对象：** [`RELEASE-2026-0801-02`](../assignments/release-2026-08-01-02-scope-freeze.md) 的 V1.0 范围冻结记录
>
> **证据类型：** 只读架构与契约审查；不包含实现、构建、archive、设备、性能、无障碍或 App Store 证据。

## 结论

**Pass（附强制跟进项）。**

冻结范围与当前已接受的运行时所有权、RIME 生命周期和 Full Access 隐私边界兼容。它不证明任何能力已交付，也不授权实现、创建 archive、变更 Assignment 生命周期、作出 Quality 结论或作出 Product Gate 结论。

本次结论不是 `Fail`：iOS 26.0、iPad 与颜表情的待完成工作均已有具名的独立 Assignment。也不是 `Blocked`：当前资料足以确定每项最小架构边界和停止条件。

## 审查范围与来源

- [范围冻结 Assignment](../assignments/release-2026-08-01-02-scope-freeze.md)：V1.0 承诺 iPhone/iPad、iOS 26.0+、颜表情，保留 Full Access 可选性，并排除高级 Typing Intelligence 与上下文拼写纠错的首发宣称。
- [审查交接](../assignments/release-2026-08-01-02-review-handoff.md)：本审查只回答架构兼容性和最小边界，明确不含 release 结论。
- [ADR 0007](../architecture/decisions/0007-full-access-and-privacy-boundary.md)：基础输入可在无 Full Access 时保留；App Group 相关能力必须诚实降级；键盘输入与隐私数据不得上传。
- [共享容器与 RIME 生命周期](../architecture/shared-container-and-rime-lifecycle.md)：主 App 负责部署、同步和持久文件操作；Keyboard Extension 只消费已部署运行时并不得在输入热路径执行部署或慢 I/O。
- 当前工程配置：所有 deployment-target 条目仍为 iOS 26.4；`TARGETED_DEVICE_FAMILY` 为 `1,2`。此为当前状态，不等于 iOS 26.0 或 iPad 支持证据。

## 架构判断与强制跟进项

| 范围 | 架构判断 | 强制跟进与责任边界 |
|---|---|---|
| iOS 26.0 最低系统 | **Pass with follow-up** | 在 [`RELEASE-2026-0801-09`](../assignments/release-2026-08-01-09-ios-26-target.md) 内先审计全部 App、Extension 与测试 target 的 API availability 和配置矩阵，再作受限 target 修改；必须使用稳定工具链构建，并由 task 01 的最终 archive 验证。实施者不得以 availability suppression、beta-only 构建或改变 RIME/Extension 所有权绕过兼容性问题。 |
| iPad 首发支持 | **Pass with follow-up** | [`RELEASE-2026-0801-07`](../assignments/release-2026-08-01-07-ipad-support.md) 必须覆盖主 App 与 Extension 的尺寸、横竖屏、VoiceOver、Dynamic Type、Full Access 状态和最终设备矩阵；不得把探索性截图或 iPhone 结果外推为 iPad 发布支持。不得改变输入语义、RIME 部署边界或 Full Access 合同。 |
| 颜表情 | **Pass with follow-up** | [`RELEASE-2026-0801-08`](../assignments/release-2026-08-01-08-kaomoji-content.md) 仅可在 Product Lead 批准 catalog 来源、许可与内容边界后，采用有限、内置、离线的 catalog 进行展示与插入。当前 `^_^` 是不展示候选也不提交内容的占位入口，不能作为已交付功能宣称。不得引入网络、账户、分析、同步、学习排序、用户内容或持久化内容。 |
| Full Access 与隐私 | **Pass with follow-up** | 关闭 Full Access 后，基础输入可用不等于共享 RIME、设置、诊断、反馈或用户词典均健康。必须遵循 ADR 0007 的 capability-specific 降级与可恢复文案；主 App 不得虚构 Extension 的实时权限状态。TD-004 的完整降级矩阵仍是未完成限制，不能被本审查消除。 |
| 首发排除项 | **Pass** | 高级 Typing Intelligence 和上下文拼写纠错可以继续受各自既有合同治理，但 App Store 文案、截图、审核说明和产品界面不得宣称这些能力属于 V1.0。范围冻结本身不授权删除、隐藏或改写其已有实现。 |

## 必须保持的架构护栏

1. Main App 继续独占 RIME 部署、安装、同步和持久文件操作；Extension 不得部署、修复运行目录，或在按键热路径进行网络、扫描、同步或重持久化。
2. 颜表情保持为不读取宿主上下文、不收集输入内容的本地内容能力；插入行为不得改变既有组合输入、候选提交或 RIME session 生命周期。
3. iPad 适配只能调整已批准的呈现与验证边界；若需要变更键盘几何不变量、生命周期、目标配置策略或跨 target 合同，必须停止并进入 ADR 决策。
4. 无 Full Access 的实际能力必须以观测到的 capability/failure 为准，不能以主 App 的推断状态、历史设备记录或静态开关代替。

## ADR 触发条件

下列任一情况发生时，实施前必须新建或 supersede ADR：

- iOS 26.0 支持需要在 iOS 26.4-only API 与长期兼容替代方案之间作选择，或改变多个 target 的支持策略；
- iPad 支持要求改变键盘几何不变量、Extension 生命周期、跨 target 所有权或 RIME/Full Access 边界；
- 颜表情引入持久化、用户自定义内容、网络下载、同步、账号、分析、学习排序或跨 target 内容管理；
- Full Access 的降级语义、数据离端规则、权限探测方式或 App/Extension 职责发生变化；
- 为避免排除项曝光而修改了持久产品合同，而非仅更新首发材料与文案。

若仅在既有边界内完成 iOS target 配置、iPad 布局/验证或静态离线颜表情 catalog，且没有上述长期取舍或边界变化，则不因机械实现本身新增 ADR；仍须更新相应 Assignment、架构来源和发布证据。

## 未作出的结论

- 未作 Quality、性能、设备、可访问性、隐私材料一致性或 App Store 就绪结论。
- 未验证 iOS 26.0 构建、最终 archive、iPad 物理设备、Full Access on/off 矩阵或颜表情交互。
- 未作 Product Gate、提交审核、发布或风险接受结论。
- 本记录不改变任何 Assignment 的 `Completed`、`Reviewed` 或 `Closed` 状态。

## 重新审查触发条件

范围、最低系统、设备/方向支持、颜表情来源或存储边界、Full Access/隐私合同、RIME 生命周期、目标矩阵或最终 archive 任一变化后，须重新进行架构审查。
