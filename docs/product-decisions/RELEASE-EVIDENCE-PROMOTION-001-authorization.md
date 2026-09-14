# Product Decision: RELEASE-EVIDENCE-PROMOTION-001 — 授权实施发布证据增量切片

## Decision

Human Product Owner 在当前会话授权开始实施一项有界的发布流程改进：

- 普通 Beta 改动按变更路径执行 delta 验证；
- 命中键盘、RIME、权限、App Group、工具链、崩溃/性能或产物边界时升级为 triggered 或 baseline；
- 日常 Beta 证据可以服务于正式外部候选，但必须核对当前 candidate fact tuple；
- 完全相同的 archive/package 身份只是 current-proof 的必要条件；还必须满足相同的行为合同、验证档位、候选/版本/构建绑定、设备/系统、证据契约和 freshness；
- 新构建只能把旧 Beta 证据作为 comparator，并必须刷新当前变更和外部候选专属检查；
- Main App 提供内容无关的本地证据记录入口，减少在外部工具之间搬运状态。

本决定只授权实现、测试、文档和本地验证，不授权外部发布动作。

实现解释：artifact identity 与 provenance 分层；任一身份或证据上下文未知、不一致、失败或过期时，只能保留 comparator/none/pending，不能形成 current-proof。

## Scope

- scripts/release/release_evidence.py 及其自动化测试；
- Main App Diagnostics 下的发布证据会话、有限字段导出和 App Group 本地存储；
- RELEASE_CHECKLIST.md、建议稿、Proposed ADR、Assignment 和索引路由的同步；
- 本地 Swift 格式、单元测试、Simulator/build 验证。

## Explicit Exclusions

- App Store Connect 上传、处理状态确认、TestFlight 分组、公开链接、Beta Review；
- 真机操作、正式 Product Gate、独立 Quality/Release Pass、Release Pass；
- commit、push、merge、分支清理和任何账户/凭证/网络接入；
- 修改现有 CI full 门禁或把 release delta 当作 CI 豁免；
- 记录或导出输入内容、候选文字、宿主文字、词典、完整诊断日志或 RIME 原始文件。

## Authority Boundary

证据记录是可追溯性工具，不是批准状态。此决定不改变 KOS 2.0/2.1 冻结规则，也不把 KOS 2.2 advisory 合同变为 required。正式采纳 Proposed ADR、接受跳过风险、进入外部动作仍需各自的 Product / Quality / Release 权限。

## Related Records

- RELEASE-EVIDENCE-PROMOTION-001 Assignment: ../assignments/release-evidence-promotion-001.md
- AUTH-RELEASE-EVIDENCE-PROMOTION-001: ../authorizations/AUTH-RELEASE-EVIDENCE-PROMOTION-001.md
- Proposed ADR 0035: ../architecture/decisions/0035-release-evidence-accumulation-and-promotion.md
- 外部公测发布复盘建议稿: ../kos/kos-improvement-suggestions-public-beta-release-2026-09-13.md
