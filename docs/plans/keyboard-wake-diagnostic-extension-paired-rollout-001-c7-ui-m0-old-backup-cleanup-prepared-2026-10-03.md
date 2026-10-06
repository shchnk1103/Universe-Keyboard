# 历史T快照清理当前状态 — 2026-10-03

Human已授权清单4目录删除，执行完成，原分配499.83MiB已移除；I0/I1/M0约382.83MiB保留。见[清理交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m0-old-backup-cleanup-validation-2026-10-03.md)。下方Prepared原文为历史，不再表示待授权／尚未删除。

## 历史Prepared清单

# 历史T快照清理清单（Prepared，待删除授权）

M0新鲜完整备份已核验；T独立覆盖、恢复健康与当前29残项Product处置已收尾。因此下列4组快照退出当前恢复依赖，可申请删除，合计499.83 MiB（du分配空间；实际释放空间受APFS影响）。删除会失去这些历史窗口的完整数据回滚副本，但审查／库存凭据保留。尚未删除。

| 精确目录 | 分配MiB |
|---|---:|
| /private/tmp/ukey-wake-ui-keychain-continuation-20261003/backup | 131.47 |
| /private/tmp/ukey-wake-ui-keychain-continuation-20261003/test-after-preservation | 136.5 |
| /private/tmp/ukey-wake-ui-t0-20261003/backup | 131.27 |
| /private/tmp/ukey-wake-ui-t1-execution-20261003/test-after-preservation | 100.59 |

只允许删除上表4个目录；各parent目录中的backup-receipt、before/after inventories、恢复回执、collector／报告必须保留，repo证据、xcresult及reviewer原件均不删。每个根为真实directory非symlink，parent存在独立JSON凭据；删除前再核目标身份及无新增恢复依赖，使用精确allowlist，不按通配符删整个任务目录。

暂留M0当前127.63MiB、I0旧C7约127.60MiB、I1安装后约127.60MiB。I0保留旧C7退回路径，I1保留安装前后比较；待M运行与恢复依赖结束再提出清理，不长期无条件堆积。

Human本轮要求可删时告知，并未授权删除。执行需针对上表具体目录批准；目前755.03MiB旧快照＋127.63MiB本M0，约882.66MiB。四组清理完成后这些快照约382.83MiB（不含DerivedData、xcresults和其他scratch）。
