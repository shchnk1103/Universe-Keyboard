# ADR 0039: Wanxiang nine-key scheme

Status: Proposed
Date: 2026-11-06 Asia/Shanghai

## 背景

万象九键是已安装万象家族上的第二套九键，不是新的可下载基础方案。设计定稿要求九键走登记、与雾凇同等的兼容改写和就绪，拼音各出口共用同一校验投影，并且不使用运行时开关，功能分支整体完成后再一次合并（`design-final.md` §E「不使用运行时开关」；切片 3 PM 决定第 1 条，文件 `design-s3-decisions.md`）。切片 3a 已把候选栏拼音项改到投影，并在隔离资源上跑过真实引擎断言（`reports/executor-report-s3a-r1.md`、`reports/executor-report-s3a-r2a.md`）。本 ADR 只记录该边界，不声称最终复核或 Human 真机已经发生。

## 决定

- 九键第二方案用登记表 `NineKeySchemeRegistry`（`Packages/KeyboardCore/Sources/KeyboardCore/NineKeySchemeRegistry.swift`），不新增可下载方案目录项。已登记的是雾凇 `t9` 与万象 `wanxiang_t9i`。
- 万象九键与雾凇使用同等的兼容改写、编译物检查与就绪标记。启用编排在共享部署前作废各方案标记，部署成功后按方案重写检查、冒烟并写标记（`NineKeyEnableOrchestrator.swift` 的 `invalidateAllMarkers` 与随后的 `rewriteCheck` / `smoke` / `writeMarker`）。切片 2 修复把作废放在共享资源准备之前；启用发布绑定和布局之后再核对最终路由，对不上则收回九键绑定并回到 26 键（`reports/review-s2-fix.md`；`NineKeyEnableOrchestrator.swift` 的 `finalRouteMatchesTarget`）。
- 统一路由入口是 `RimeRuntimeSelection.resolveRegistered`（`RimeRuntimeSelection.swift`）。`schemeBinding9` 为空，或解析到的登记项家族是雾凇时，走原来的雾凇入口。
- 拼音栏、测试里的 marked，以及候选栏里的拼音项，只显示经过同一校验的投影。候选栏快照路径使用 `visiblePreedit`，空则不出拼音项，不再优先用引擎原文 `compositionPreedit`（切片 3 PM 决定第 2 条；`reports/executor-report-s3a-r1.md`「候选栏」）。
- 不增加运行时开关。功能分支整体完成并通过最终复核与 Human 真机验收之后一次合并进 main，中间不进 main（切片 3 PM 决定第 1 条）。本记录不表示该合并已经发生。

## 后果

真实宿主上的 marked text 仍只能由 Human 真机验收，模拟器里的测试 marked 不能代替它（设计定稿 §E「真实宿主 marked text」标 UNKNOWN；实施说明第 3 节「Human 真机」）。设计定稿 §F 的技术债（部署 generation 身份、依赖闭包、编译产物与词典内容身份、扩展快照一致性、用户修改文件的身份追溯）不在本 ADR 声称已加强。

雾凇基线在切片 3a R2a 的隔离矩阵里，`R2_` 行与当时基线逐行一致（`reports/executor-report-s3a-r2a.md`）。这只是该次本地日志，不代表托管 CI、Human 真机或 Release 通过。Architecture 状态仍为 Proposed；独立 Architecture / Quality 由后续复核另派。
