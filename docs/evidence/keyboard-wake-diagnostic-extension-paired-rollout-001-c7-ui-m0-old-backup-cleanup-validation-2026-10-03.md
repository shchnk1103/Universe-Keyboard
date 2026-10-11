# M0 历史T快照清理交付 — 2026-10-03

Human明确授权删除已列4个旧T快照目录。[执行回执](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m0-artifacts/old-backup-deletion-receipt.json)逐项记录精确路径；[保留核验](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m0-artifacts/old-backup-deletion-preservation.json)记录当前M0／I0／I1大小与receipt摘要。

删除前重新核验M0完整副本文件摘要、尺寸、结构与链接；4个目标均为真实目录，路径及du库存一致，无新的恢复依赖。执行仅使用精确4目录allowlist，未删parent目录。4个目录均已消失，删除目录原分配空间合计499.832MiB；不将全系统可用空间变化独占归因于本清理。各parent直接凭据／脚本文件摘要保持，repo证据、审查报告、xcresult未操作；I0、I1与M0完整快照保留，共约382.83MiB。

四个历史T完整数据回滚副本已永久移除，不再声称能够从这些路径恢复或复读历史原始副本；原完整备份及恢复核验事实、库存／摘要、审查／阶段处置记录仍保持历史效力。后续复验这些已删原始副本须标Unavailable，不重建或冒用当前M0。I0旧C7回退路径与I1安装比较继续保留；未来无依赖时再提出清理清单，不自动删除。

本轮仅授权的scratch快照清理与文档归档，无模拟器、源码、构建、测试、安装、LLDB、Maps操作或Git发布。M0已完成，M1/M2未授权；父子Assignment Active，根因仍开放。
