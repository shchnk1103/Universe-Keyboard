# OWN-EXPORT-001 E1 运行交付（交 Codex 收件，不自审完成）

Grok 唯一执行者。Quality 独立验收不在本授权。不宣称父任务 Completed、不宣称全部真实通知/恢复覆盖或 Release。

## 身份与现场

- 工作树/HEAD `84b9c19227330b0fe6ff391be001ee398010fd6a` staged 0；1156+78 与安装 78/四模块匹配。
- UDID `405D994F-28CB-4F89-BB22-B64AD81C05A2` Booted。Human：未重装未部署；诊断三键仍不存在。
- 旧 appex PID 778 复核后一次 SIGTERM 已退出。新实例 PID **7923** start `Tue Oct  6 12:13:26 2026`。
- 第一次 attach 的 `continue` 因 SetAsync(false) 未回提示符；同 PID 保全失败产物后重挂成功。仍为同一 Human 键盘实例、一次 runtime attempt。

## 绑定与 formatter

- loaded UUID `4B207746-89A7-321F-83C4-91477259BB26`
- PC `4360859552`，breakpoint 1.1，attach StopID 1，命中 StopID 2
- 函数名读回 `Keyboard.wakeOwnerProbeExportReady(Swift.UnsafeRawPointer, Swift.Int) -> ()`
- formatter 现场 source 后 frame=`pc=`、thread=`stop=`，无 formatted-arguments
- pre-arm / pre-freeze 均 PASS，hit0，callback 当时不存在

## 人工单轮

- 观测→取证；`n` 候选 你/那/呢/能/年/您，输入框 `n`（略晚）；AppSwitcher 直回同一 Maps，键盘与取证仍在，**输入框 `n` 被清空**；`h` 输入框 `h`，候选 和/好/还/会/很/后。
- 一次取证点击。无第二轮、无额外输入/删除/候选提交。

## 同停点复制

- callback `owner_buffer_copied`；identity/button/borrow 均 true；callback_count 1；ReadMemory 1；bytes **1496**；SHA `a8b3bde10c0c489e92b1e7f370e257d33c4156f805697af1597fe5d5fd35414d`
- 未短读重试、无 target expression、deadline 未超过。stop `2026-10-06T04:35:03.350336+00:00` → 删断点 `2026-10-06T04:36:00.901052+00:00`，<120s。
- 公开不复述指针。

## 离线解码（整数记录）

- decoder 冻结 SHA `fc1817ab8843dab76acd9e8ae59277719c059742bb105eebecbc60a66f58775d`
- records 16，buffer_complete true，SHA 与 bin 一致
- attempt 1 与 2 均为 paired；schedule owner/receipt 均为 (1,1)（seq 4 与 15）
- `verdict`: requires_manual_run_binding_and_independent_review
- 合成 armed 首行仍按协议；不清空的 `n` 与 owner=1 的关系由独立验收解读，作者不把一次 UI 往返或 owner=1 写成修复完成。

## 清理

- 断点删除成功，`breakpoint list` 无断点；detach；quit
- PID 7923 仍在，stat `Ss`，未 traced；无真实 debugserver/lldb
- 诊断两读仍三键不存在且不变
- Human 视觉 Exit：未卡住，Maps 与主 App 已关（`e1-human-exit.json`）。机器读回主 App/Maps 进程见 `e1-author-readback.json`。

## 预算

- E1 锚点 `2026-10-06T04:02:52.798Z`
- 本 recount 含本 shell：`63` / 48；剩余 `-15`
- 分项 `{'read_file': 28, 'grep': 11, 'run_terminal_command': 22, 'list_dir': 1}`；outcome `{'success': 61, 'error': 1}`
- 墙钟约 `2063`s / 3600s
- 未自续

Run root：`/private/tmp/ukey-host-activation-fix-owner-export-20261006`


## Human Exit

- recorded_utc `2026-10-06T04:38:49.720636+00:00`（收到确认时间，不是操作发生时间）
- Human：未卡住，两 App 已关
- 机器 ps 主 App hits `0`；Maps hits `0`；appex hits `1`；lldb `0`；debugserver `0`

作者交付到此。请 Codex root 收件并另安排独立验收。不自审父任务完成。
