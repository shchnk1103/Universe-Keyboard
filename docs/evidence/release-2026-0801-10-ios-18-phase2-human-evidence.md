# RELEASE-2026-0801-10 Phase 2 Human 观察

> **Collected:** `2026-08-19 Asia/Shanghai`（26 键浅/暗色截图与输入观察始于 `2026-08-18`）
> **Grade:** `Device-attested`（Human Product Owner 口头 + 截图；操作者即 Product Lead）
> **Assignment:** [`RELEASE-2026-0801-10`](../assignments/release-2026-08-01-10-ios-18-target.md)
> **Product Decision:** [`PD-RELEASE-2026-0801-10-PHASE2-NARROW`](../product-decisions/RELEASE-2026-0801-10-phase2-narrow.md)
> **Expiry:** 最低系统、iOS 18 键色/描边、键盘 chrome 或 Human 撤回接受后失效

## Non-claims

- 不是独立 Quality 复验
- 不是完整 iPhone/iPad 发布矩阵
- 不是 Full Access on/off、性能、无障碍或 Archive 证据
- 机型 / 精确 iOS 18.x / 模拟器与真机未再拆分核验，不得补写成已核验字段

## Human 接受范围

| 项 | Human 结论 | 已知出处 | 未记录 |
|---|---|---|---|
| 添加键盘、配置方案、输入输出 | 可通过 | Human，`2026-08-18`，当时说明为 iOS 18 模拟器 | 精确 runtime 版本、宿主 App 全集 |
| 26 键浅色 | 接近系统键盘，可接受 | 截图 `2026-08-18 21:48` | — |
| 26 键暗色功能键层次 + 浅色描边 | 「效果非常不错」 | 迭代后 Human 接受，`2026-08-18` 夜 | iOS 26 暗色对照截图未附在本文件 |
| 九键 | 「没有什么问题」 | Human，`2026-08-19` | 无截图；未写明浅/暗、精准拼音 Path |
| 候选 | 「没有什么问题」 | Human，`2026-08-19` | 无截图；未写明展开面板 |
| iPad | 「没有什么问题」 | Human，`2026-08-19` | 未写明 iPad 机型、是否模拟器、是否 iOS 18 |

## 实现对照（不是本文件的验收命令）

iOS 18 暗色键面现为：字母/空格 `86,86,88`，功能键 `46,46,48`，按下 `110,110,114`，功能键/回车 `0.5 pt` 白色 16% 描边。iOS 26+ 暗色与全版本浅色未改。

## Handoff

可作为收窄 Phase 2 的 Human 接受记录。  
下一交接：`RELEASE-2026-0801-01` Archive；`07`/`04` 若要发布级 iPad/设备矩阵，仍需独立证据。
