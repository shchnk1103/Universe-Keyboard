# RELEASE-2026-0801-04 — Build 55 独立 Quality/Release re-review

> **Review ID:** `RELEASE-2026-0801-04-B55-QUALITY-RE-REVIEW-20260913`
> **Verdict:** **Blocked**
> **Reviewer:** 独立 Quality/Release Reviewer（只读复核）
> **Reviewed:** `2026-09-13 Asia/Shanghai`
>
> 本回执是对新增 Archive/export reconciliation 的独立复核，不修改或回写既有
> [`Build 55 Quality/Release review`](release-2026-09-13-build55-quality-release-review.md)。

## Scope

仅复核 Archive、dSYM、Store/Ad Hoc 导出包关系、TD-005 分类回执、Jetsam 判定规则、
既有 TD-003/TD-004/fresh-install 边界和 Release Checklist。没有访问或改变 iPhone，
没有重新构建、Git、上传、分发、发布或修改既有文件。

## Evidence Matrix

| 项目 | 独立结论 | 证据边界 |
|---|---|---|
| Archive ↔ 导出包 | **Conditionally accepted** | Archive/dSYM 直接报告 `1.0 (1)`；导出日志明确带入 `buildNumber=55`，Store/Ad Hoc 为 `1.0 (55)`，App/Keyboard UUID、dSYM UUID 和 57-file 非身份资源 manifest 一致（reconciliation，L35–71、L73–88）。 |
| “Archive 本身是 Build 55” | **未证明** | 不接受目录名、workflow 名或 UUID 相同作为 Archive 内嵌 `CFBundleVersion=55` 的证明；当前 Archive/dSYM 元数据仍为 `1`（reconciliation，L37–43、L77–83）。 |
| TD-003 | **Blocked** | 功能观察不是受控性能/内存基线；cold/warm、首键、候选、持续输入和数值内存证据仍不完整（既有 review，L24–30、L47–53；TECH_DEBT，L27–37）。 |
| TD-004 | **Blocked** | Full Access off 基础输入、haptic switch、同会话候选学习和诊断观察均是有界结果；共享诊断解释、降级/恢复、resource-not-ready 及持久化边界仍未闭合（Full Access matrix，L65–74、L76–99、L101–119、L121–180）。 |
| TD-005 | **Blocked / Jetsam `unclassified`** | 三份含 Build 55 UUID 的报告没有 `victim`/`jettisoned`/`killed`/进程级 reason；进程状态、存在或内存页数不能证明 Keyboard 被终止（classification follow-up，L42–66、L109–120；Crash/Jetsam handbook，分类表）。 |
| Fresh-install / App Group | **部分 Pass；整体 Blocked，clean App Group = `UNKNOWN`** | 已有 App uninstall/install 与首次引导的设备观察，但没有读取或重置共享容器、RIME 或用户词典（fresh-install boundary，L36–61、L103–106）。 |
| 公共 TestFlight / 更广泛外部公测 | **Blocked** | 包预检/上传关系不等于 ASC 处理完成、外部测试组、Beta Review、What to Test 或最终 Release Gate（public-beta handoff，L21–34、L48–81；RELEASE_CHECKLIST，TestFlight 与上传/分发边界）。 |

## Passed

- 接受以下有界候选关系声明：同一代码映像经导出阶段明确产生 `1.0 (55)` 的 Store/Ad Hoc 包；
  App/Keyboard UUID、dSYM 映射和非身份资源链一致。该声明不把 Archive/dSYM 的 `1.0 (1)` 改写为 `55`。
- 三份 Jetsam 可接受为“Build 55 UUID 层相关记录”；分类必须继续为 `unclassified`，不执行无因果目标的
  symbolication，也不声称 Keyboard 被系统终止。
- 可保留 TD-004 的局部声明：Full Access on 时 haptic switch 关闭/开启传播、同会话候选位置提前、
  主 App 诊断记录出现；Full Access off 时基本输入仍可用且本次未见新可见诊断记录或降级提示。
- 可保留雾凇九宫格和首次安装流程的既有有界设备观察；这些都不等同于整体 Release Pass。

## Failed/Blocked

- TD-003、TD-004、TD-005 均未闭环；TD-005 的“未分类”不是失败归因，而是证据不足。
- clean App Group / 共享 RIME / 用户词典的 fresh-install 边界仍为 `UNKNOWN`。
- haptic switch 新证据只证明该共享设置在本次 Full Access-on 会话中的传播；不能外推所有共享设置、off 状态、
  重启持久化或恢复。
- 候选学习只证明同会话效果；不证明重启、备份恢复或干净状态行为。
- resource-not-ready 诱导没有到达目标态；Human Product Owner 保留雾凇安装的决定不是 TD-004 关闭、风险接受或外部发布授权。

## Skipped With Reason

- 未重复真机、终止诱发、卸载/清理 App Group、重新构建或重新导出：不在本次独立复核授权内，且会改变既有证据边界。
- 未把三份 Jetsam 送入 symbolication：缺少已分类 victim 和因果终止证据；dSYM UUID 匹配不能补足该缺口。

## Release Decision

**独立 Quality/Release 结论：Blocked。当前证据不能把整体公测 Release Gate 标绿，也不支持更广泛外部 TestFlight 分发。**

对“是否需要真正 `CFBundleVersion=55` 的 Archive/dSYM”的明确判断：

1. 对“Build 55 候选关系”的有界复核，**不把它作为当前额外的独立阻断**；现有导出阶段 provenance 加 UUID/dSYM/资源链足以支持条件性关系声明。
2. 对“Archive/dSYM 本身嵌入构建号就是 55”的无条件声明，当前仍是**未证明**；若 Release/Artifact policy 要求该精确身份，
   则必须取得真正 `CFBundleVersion=55` 的 Archive/dSYM。该条件不改变当前由 TD-003/004/005、clean App Group 和发布控制面造成的 Blocked。

最小下一步是由 Product Lead 选择并记录：继续更广泛外部公测并授权针对明确缺口的证据切片，或将渠道收窄为受约束内部测试并明确风险责任、范围和有效期；
不是仅凭本次 Archive/export reconciliation 宣布放行。

## Owner Handoffs

- **Release/Artifact owner：** 保留 `Archive=1`、导出 `buildNumber=55` 的分层事实；如需无条件 exact-Archive 声明，补真正 `55` Archive/dSYM。
- **Crash/Jetsam owner：** 保持三条匹配记录 `unclassified`；只有获得带 victim/reason 的充分报告后再做 TD-005 分类。
- **Quality/Performance owner：** 补受控 TD-003 性能、首键、持续输入和内存证据。
- **TD-004 / fresh-install owner：** 在获得授权后补 Full Access-off 共享能力/恢复和 clean App Group 边界；当前不诱导、不清理。
- **Product Lead：** 决定 Release scope/risk disposition；Quality/Release Reviewer 不代行该 Product Gate。
