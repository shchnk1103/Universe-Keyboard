# KEYBOARD-LAYOUT-9KEY-PINYIN-002 — Amendment B 架构审查记录

> **审查日期：** `2026-07-21 Asia/Shanghai`
>
> **审查角色：** 独立 Architecture Reviewer（🏛️ Architecture & Knowledge Steward）
>
> **审查对象：** 当前 `main` 中的 `6a3e082`（Amendment B：渐进式音节紧凑路径栏）及其现行权威文档。
>
> **证据类型：** 只读架构/契约审查；不构成 Quality、性能、无障碍、真机或 Product Gate 结论。

## 结论

**Pass（附强制质量与真机跟进项）。**

Amendment B 在已接受的 ADR 0018、ADR 0020 与 ADR 0021 边界内实现：KeyboardCore 持有渐进式音节、确认状态、授权路径和事务恢复；RIME 继续独占 live raw、候选和中文排序；UIKit 只渲染 Core 已签发的路径并转发操作。未发现需要新建或 supersede ADR 的长期所有权、部署、几何或数据边界变化。

这不是任务关闭、Quality Pass 或 Product Gate。`KEYBOARD-LAYOUT-9KEY-PINYIN-002` 必须继续保持 `Active`，直至独立 Quality 结论、干净提交的 Spike 证据和人工真机 Product Gate 完成。

## 审查范围与依据

- Assignment [`KEYBOARD-LAYOUT-9KEY-PINYIN-002`](../assignments/keyboard-layout-9key-pinyin-002.md) 与其 [Review Handoff](../assignments/keyboard-layout-9key-pinyin-002-review-handoff.md)。
- Product Decision [`PD-KEYBOARD-LAYOUT-9KEY-PINYIN-002`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-002-authorization.md) 的 Amendment B。
- [ADR 0021](../architecture/decisions/0021-t9-deterministic-single-key-choices-and-cycle-selection.md)，并核对 ADR 0018 与 ADR 0020 的 T9 runtime、RIME session 与无 raw-host-commit 合同。
- 现行实现：`T9PinyinPath.swift`、`KeyboardController+T9PinyinPath.swift`、`T9PinyinPathTests.swift`、`KeyboardViewController+T9PinyinPath.swift` 与 `T9PinyinPathBarView.swift`。
- [输入管线](../architecture/input-pipeline-and-marked-text.md)、[Swift 6 架构](../architecture/swift6-migration.md)、[键盘布局](../KEYBOARD_LAYOUT.md) 与 UI Style Guide。

## 架构判断

| 边界 | 判断 | 依据 |
|---|---|---|
| 键盘几何与紧凑展示 | **Pass** | 路径栏仍固定保留 34 pt；Core 限制紧凑路径最多 5 项，UI 仅单行截断。多音节 whole comment 被转换为当前音节，而不会作为单个 cell 展示。 |
| RIME 候选与 provenance | **Pass** | 单键仍仅使用 canonical key identity；多键/后续音节从 live comments 提取并经 digit compatibility 和 exact-segment authorization 校验。没有 Cartesian 展开或第二中文候选引擎。 |
| 确认/推进事务 | **Pass** | 直接点按与“选拼音”共用同一 Core refine transaction；只有直接点按会确认/推进，且失败会回滚 RIME output、marked text、choices 与 selection。 |
| 运行时/部署所有权 | **Pass** | 变更只调用现有 session `replaceInput` / bounded `candidateWindow`；未见 deploy、schema 写入、Vendor 变更、网络、同步或持久化进入 Extension 热路径。 |
| Swift 6 与层次分工 | **Pass** | UIKit 不持有 cycle/segment 业务状态，也不从 accessibility metadata 重建路径；Core 保持 UIKit 无关，未引入不安全并发逃逸。 |
| 旧 expanded-path panel | **Pass with follow-up** | 现有 `presentPinyinPathExpandedPanel()` 及其呈现辅助代码仍在，但当前 `选拼音` 仅 dispatch `.cycleT9PinyinPath`，未发现生产调用入口可重新打开该面板。保留不可达兼容代码不改变运行时合同；未来删除须由独立、明确范围的清理任务完成。 |

## 已观察到的证据与限制

- `6a3e082` 已在当前 `main`；本审查未改代码，也没有将历史本地验证结果改写为当前 Quality 结论。
- 静态核对显示 Amendment B 对后续音节使用有界 `candidateWindow`；每次 probe 后恢复先前 raw，符合 ADR 0021 的 session-only/provenance 合同。
- 本轮尝试运行 `swift test --package-path Packages/KeyboardCore --filter T9PinyinPathTests`，被当前受限环境的 SwiftPM/Xcode-beta manifest sandbox 拦截，未获得可采信的新测试结果。这不推翻既有架构判断，也不能作为 Quality 通过证据。

## ADR 判断

**无需新增 ADR。** Amendment B 已由 Product Decision 与 ADR 0021 明确接受，且实现未改变下列长期边界：

1. Main App 独占部署/readiness；Extension 仅处理当前 session。
2. RIME 独占候选、排序与 live composition；Core 仅持有受限路径/provenance 状态。
3. 路径选择为 composition refinement，非 host 文本提交。
4. 固定路径栏几何与 single-line 呈现合同。

如将来引入离线多音节词图、放宽 live-comment authorization、改变确认手势、改变 Extension/主 App 职责、或需要超过当前固定栏的几何策略，须先新建或 supersede ADR。

## 必须交接给 Quality / Product Gate 的未关闭事项

1. 独立 Quality Reviewer 必须在可用标准环境重跑 focused/full Core、RimeBridge 和 App/Keyboard 测试，并审查任何失败；本记录不引用 Executor 的自报测试为结论。
2. 干净提交上重跑并归档 pinned librime Spike，涵盖 `m/n/o`、`n4`、`n'g/n'h/n'i` 的授权和无 host commit 断言。
3. 人工真机 Product Gate 必须覆盖 Amendment B：多音节不换行/不重叠、直接点按一次确认并推进、选拼音仅循环、Delete/commit/page/language/visibility/recovery 失效、VoiceOver、路径栏高度与按键延迟。
4. Quality 应专门测量 confirmation probes 的输入延迟，并验证三段及以上、跨 confirmed segment Delete 等未由原生观察穷尽的情形。

## 未作出的结论

- 未作 Quality、性能、无障碍、隐私、设备、发布或 Product Gate 结论。
- 未验证任何 iOS 26.0 运行时；该发布层面的最低系统阻塞仍由 `RELEASE-2026-0801-09` 管理。
- 未关闭 Assignment，未接受风险，未授权合并、推送或发布。

## 重新审查触发条件

Choice source、comment authorization、确认/推进手势、路径栏高度/布局、RIME session/deploy ownership、或 T9 schema/librime 行为发生变化时，必须重新进行架构审查。
