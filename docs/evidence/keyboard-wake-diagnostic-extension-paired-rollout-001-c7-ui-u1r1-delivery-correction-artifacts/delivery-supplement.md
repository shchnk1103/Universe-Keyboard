# U1R1 交付一致性补证

本补证只校正既有审查交付的一致性，不重审 P1–P3；原 `review.md`、`usage.json`、`independent-analysis.json` 保持原样。原窄运行链意见不变：P1/P2/P3 Covered，范围 Coverage Complete，对冻结候选单次 U1 正常路径成立。

## D001–D004

| 项 | 结果 | 补正 |
|---|---|---|
| D001 | Covered | `image list -u -f` 对应 debug call 02；debug call 01 是 attach。原 review 的 call 编号定位有误。 |
| D002 | Covered | 原 usage 实际 `self_sha_matches=true`、`external_identity_matches=false`。computed whole-file SHA 对照 external identity 的 `whole_file_sha256` 相符；computed canonical self SHA 对照 `canonical_self_digest` 相符。旧外部布尔字段为误算/错误键对照；此前最终消息将它说成 self digest 错误，现更正。 |
| D003 | Covered | 旧 usage 的 `status: formal partial issued by call4; ... in progress` 是 call4 checkpoint 残留；call6 正式交付状态覆盖该 checkpoint。原最终 coverage 为 Complete：P1、P2、P3 均 Covered。窄意见不变。 |
| D004 | Covered with timing limitation | 可从本 agent 调用序列列明 6 次 leaf call 类型；旧 lane 没有保存每次真实 request/output UTC 或 monotonic timestamp，故均为 null/unavailable。不得用 aggregate 259.904644 秒或 root 收件时间伪造逐次时间。 |

### 旧 lane 的 6 次 leaf call

| # | 类型 | request UTC | output UTC | 单次 monotonic / duration |
|---:|---|---|---|---|
| 1 | `functions.exec` → `exec_command`：packet/hash 核对与骨架 | null / unavailable | null / unavailable | 未采集 |
| 2 | `collaboration.send_message`：向 root 发 checkpoint | null / unavailable | null / unavailable | 未采集 |
| 3 | `functions.exec` → `exec_command`：列 allowlist/准则 locators | null / unavailable | null / unavailable | 未采集 |
| 4 | `functions.exec` → `exec_command`：审阅证据并写 Partial checkpoint | null / unavailable | null / unavailable | 未采集 |
| 5 | `functions.exec` → `exec_command`：独立解析 raw snapshot 与 ledger | null / unavailable | null / unavailable | 未采集 |
| 6 | `functions.exec` → `exec_command`：正式 report/usage/analysis 与回读 | null / unavailable | null / unavailable | 未采集 |

旧 lane aggregate 仍为 6 calls / 259.904644 seconds；此 aggregate 不能还原单次时刻，也不是完整 target pause 时间。三个原件 SHA256 列在补证 usage，原件未修改。

## 本补证时间记录与边界

本 lane 的首个工具脚本在计时值落盘前因读取 packet allowlist 字段名错误退出；其 wall/monotonic 起点未持久化。因此不伪称精确跨 call 总耗时。此次恢复 call 记录自身 wall/monotonic 起止；总 leaf call 数为 2/2。该计时记录缺口不改变 D001–D004 的字段纠正，但 usage 将整体时长标为 unavailable。补证不增加 Product、Maps、Release Gate 或 Release 结论；点击/target pause/borrow 的 UTC 仍沿用原报告的未知限制。
