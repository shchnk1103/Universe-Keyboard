# Human — 万象下载成功但 v1 journal 无交付行 — 2026-08-27

**Assignment / debt:** [`TD-015`](../TECH_DEBT.md#td-015-方案交付日志未进入诊断-v1-journal)（尚未单独 Authorization）
**Evidence grade:** `Device-attested`（Human 口述；无入库截图）
**Collection date / timezone:** `2026-08-27 Asia/Shanghai`

## Observation

- Human 在等待 PR #85 CI 时重试下载万象拼音：UI 报告下载并部署成功。
- 「记录诊断数据」与全部分类（含部署）开启；首屏高保真关闭。
- 诊断页（v1）没有任何关于万象、下载或部署的行。

## Interpretation (Executor)

不是高保真把事件藏起来。下载路径几乎不打点；部署 `Logger.shared` 写入 legacy `rime_diag_log`；查看器在 v1 有记录后不回退 legacy。

## Non-claims

- 不是 INTEGRITY-001 根因分类完成。
- 不是万象下载已稳定可合并。
- 不授权 merge PR #83，不授权改高保真规则，不授权当晚实现。
