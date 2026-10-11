# 固定main一次整合候选 — 源码冻结完成

日期：2026-10-11。Human针对固定main单次整合建议回复“继续吧”；本轮独立AUTH先释放并消费。父TYPO-CORRECTION-002保持Active。

## 身份和结果

- 新隔离writer：`/Users/doubleshy0n/.codex/worktrees/int003-final-integration-592/Universe Keyboard`，HEAD/main固定 `59272331b3627856c1c4480b0b5d7ad0ddade0ad`。原S/G和primary未整合、未清理，原28源hash全部仍匹配。
- [候选manifest](typo-correction-002-fixed-main-integration-001-candidate.json)：SHA256 `8cf4b3d3cd11dbff9baddb343cf25aa2dc3f2a2d92f864040db83286eb6d2b35`；28路径、23Swift；25文件与原冻结源逐字节相同，三文件整合main已有变化。
- 仅这28路径dirty，index为空。未创建源码提交或推送。

## 冲突处理与经验

| 文件 | 处理 | main成果 |
|---|---|---|
| KeyboardViewController.swift | 一个同位置插入冲突，保留wake/lifecycle标记，再使query-cost探针/anchor失效，随后原recall失效 | host recovery gate、v6 writer、delete状态和wake钩子保留 |
| project.pbxproj | 两个相邻新增项冲突，合并引用列表；保留既有hostless测试切换，移除旧appex Framework引用 | proxy/recovery两个KeyboardTests源引用保留 |
| swift6-quality.yml | 三路自动整合 | 四个ensure simulator步骤保留，增加ExtensionTests格式覆盖 |

用共同基线、main、本任务候选进行三路合并；不把旧整文件复制覆盖main。仅三个重叠文件的最终字节变化，没有额外兼容修正或新增功能。无需为纯插入合并自动重开已完成的P1/P2审查或手动采集。

## 静态检查与证据边界

23Swift `format --in-place`及`lint --strict`成功；项目plutil、scheme XML、无冲突标记、scoped diff check通过。核对main生命周期/工程/CI新增项保留；这些是执行者静态检查，不能代替编译和运行证据。

旧完整CI仍绑定原72dd217组合；新main有运行依赖变化，故新组合尚未通过测试。已接受P2与独立结论保留为其原Run事实；本轮不重采、不操作模拟器。下一只对本候选绑定一次完整CI及DEBUG flag-on覆盖，首失败停止；main继续前进不自动重新整合/重跑。

## 文档影响及下一边界

仅既有设计增量整合，未改变长期架构/产品合同，不需要新增或Accept ADR。DEBUG探针、hostless测试、格式覆盖与复用方法应在后续交付文档/CHANGELOG按已发生改动记录；本轮不把历史经验塞入PROJECT_CONTEXT。

已授权整合完成，AUTH consumed/exhausted；下一一次验证须独立AUTH和具体环境独占确认。commit/push/PR、merge、Gate/Close、TestFlight/Release未授权。
