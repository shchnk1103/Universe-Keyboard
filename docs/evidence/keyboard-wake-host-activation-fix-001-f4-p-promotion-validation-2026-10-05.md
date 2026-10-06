# F4-P独立产物/flags核验停点 — 2026-10-05

**未完成，未满足F4-I晋级条件。** Human“可以按照你的建议继续”批准最小双lane只读核验；原Architecture/Quality独立Luna runtime均实际复用。root最初根据live列表漏项推测Architecture需新runtime，spawn返回path already exists后已用followup原runtime；[路由补正](../reviews/keyboard-wake-host-activation-fix-001-f4-p-promotion-artifacts/runtime-routing-correction.json)保留错误与实际路线，不冒称替换成功。

## 证据与停点

[Architecture packet](../reviews/keyboard-wake-host-activation-fix-001-f4-p-promotion-artifacts/architecture-packet.json) SHA44a83a73…；[Quality packet](../reviews/keyboard-wake-host-activation-fix-001-f4-p-promotion-artifacts/quality-packet.json) SHAf5c6f4c2…；冻结1292输入、pair完整78文件/91448700bytes。两lane各16actualcalls/900秒、8/12检查点、最后4calls交付，不自动续；依赖不齐不能晋级。

Quality作者原生回复报告16/16calls，Q-P1..4全未覆盖，私有host路径不可见；没写ACK/review/usage/readback，实际起点/elapsed未知，不能断言墙钟合规。只保留[root停点回执](../reviews/keyboard-wake-host-activation-fix-001-f4-p-promotion-artifacts/quality/root-stop-receipt.json)与[原生回复内容归档](../reviews/keyboard-wake-host-activation-fix-001-f4-p-promotion-artifacts/quality/root-preserved-native-reply.md)，不是作者正式报告。

Architecture作者原生结论Partial/incomplete，16/16calls，A-P1..3未覆盖；局部条件点/依赖摘要/构建成功标记不能替全覆盖。host原件不可见，root原始reader视图批量输出又被截断；四份作者产物未写，精确结束/elapsed未知。[停点回执](../reviews/keyboard-wake-host-activation-fix-001-f4-p-promotion-artifacts/architecture/root-stop-receipt.json)及[原生回复内容归档](../reviews/keyboard-wake-host-activation-fix-001-f4-p-promotion-artifacts/architecture/root-preserved-native-reply.md)保持限制。此处不补造作者ACK或Pass。

## Reader修复准备与剩余依赖

root根据两位具体请求在真实host执行同冻结输入只读代理：文件原文/行定位/actual与expected SHA，nm/dwarfdump/codesign/otool真实输出与原compiler行，无root审查verdict。[完整Architecture原始视图](../reviews/keyboard-wake-host-activation-fix-001-f4-p-promotion-artifacts/architecture-raw-reader.json) SHA c3e2e764…，[完整Quality原始视图](../reviews/keyboard-wake-host-activation-fix-001-f4-p-promotion-artifacts/quality-raw-reader.json) SHA409e7364…；两个大视图仍保留，不强迫reader整篇打印。新[分页索引](../reviews/keyboard-wake-host-activation-fix-001-f4-p-promotion-artifacts/bounded-raw-views/index.json)按源文件60行小段保存逐页路径/行号/hash；下一reader必须按索引精准提取，先由实际reviewer证明可读，不能仅root自检替代。作者写出宜使用同已证实可见的repo路径或机械writer代理，并先以假数据实际写/读回；判断、真实起止和usage仍由作者负责。下一packet需显式绑定此read/write通道，先freeze再审，不边审边扩。

剩余仅A-P1..3及Q-P1..4与完整作者交付，旧A2/Q3不重审。新review预算/round或范围修订须Human批准；本轮已停止，不自动续审，不要求重跑矩阵。F4-P构建成功与源码/配对冻结仍有效；审查流程失败不证明源码或产物错误，也不授安装。

本轮未源码/build/test/lint/simctl/安装/设备/LLDB/Maps/Git发布，不删任何备份。F4-I新鲜独占、静默完整before保护及安装另授权；F4-M真实通知/owner/Maps尚未验证。整体修复Active但F4-I晋级依赖Blocked；无CHANGELOG/ADR变更。
