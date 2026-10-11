# OWN-EXPORT-E1-QUALITY-R1 独立验收

**总判定：Partial。** 这只说明冻结证据在限定范围内达到下列覆盖；Q4 的超预算和同 PID 重挂偏差未获 Human/Product 接受，不能作为合规运行、Release 或产品修复结论。

## 输入与边界

本审查绑定 packet SHA-256 `9fcb7abeccbe3dd3d7c42d85c44bf0a4355cf6dd854f6cb5a7c19b847d54434c` 与 reader SHA-256 `870a31c9bbb84888058810ec36fbdaab54f35c3e33caab576761fb3caa010923`。30 份文本原件均按 packet 路径原生读取，字节数与 SHA-256 同时匹配 packet 和 reader；1496-byte `owner-buffer.bin` 原件 SHA-256 为 `a8b3bde10c0c489e92b1e7f370e257d33c4156f805697af1597fe5d5fd35414d`，reader 的完整 hex 解码后逐字节相同。没有做设备查询、LLDB 操作、构建、测试、采集或生产改动。

## 四项判断

### Q1：Pass（限于本次绑定和单次读取）

`live-binding.json` 绑定 PID 7923、模块 UUID `4B207746-89A7-321F-83C4-91477259BB26`、PC 4360859552、breakpoint/location 1/1、attach StopID 1。callback 记录 StopID 2、frame 0、相同 PID/UUID/PC、断点停止原因及 `[1,1]` 断点数据；九项 identity check 全 true。调用栈含 `Keyboard.KeyboardViewController.handleWakeOwnerProbeButton()` 与 `Array.withUnsafeBytes`，button caller 和 synchronous borrow caller 均 true。

冻结 callback 实现从该 frame/thread/process 获取参数，再以 `process.ReadMemory` 读取；检查地址对齐、长度 176–11352、8 字节对齐和地址加长度溢出，READ_ATTEMPTS 非零时拒绝重试。callback_count=1、read_attempted=1、memory_snapshot_reads=1、bytes=1496、target_expressions=0、deadline_exceeded=false。这里通过的是证据记录的本次同停点绑定及单次有界读取；没有将其推广为多运行、多设备或产品级保证。

### Q2：Pass（限于冻结 buffer 解码与已记录整数链）

我用原始 decoder 对原始 binary 离线解码，结果与冻结 `e1-decoded.json` 完全相等。1496 字节等于 11 个头字加 16×11 个记录字（187×8），`buffer_complete=true`。attempt 1 与 2 各自有一个 begin/end，协调器和 appearance 一致；schedule 序号 4、15 的 owner/receipt 均为 1/1。生命周期记录序号 6–13 包含 suspend、teardown(owner=0, epoch=1)、resume、replacement(owner=1, epoch=2)，末尾 owner=1。没有把这些整数扩展解释为系统通知、引擎提交或完整主机覆盖。

decoder 的自身结论仍为 `requires_manual_run_binding_and_independent_review`；buffer complete 只描述这份 probe buffer，不证明生命周期或应用行为覆盖完整。

### Q3：Pass（来源及清理结论受记录边界限制）

`e1-human-n.json`、`e1-human-appswitcher.json`、`e1-human-h.json` 记录了单轮观察：n 候选后输入框出现 n；返回同一 Maps 搜索框后键盘/取证按钮仍在，但 n 被清空；之后 h 和候选出现。记录中 `Human` 字段作为本轮人工陈述收件，不能把文本记录当成独立视频或把 `utc` 当成精确按键时刻。`e1-human-exit.json` 的 04:38:49.720636Z 是收到/写入确认时间；Human 陈述为未卡住、两 App 已关。机器读回对应 main/Maps 进程为空、appex PID 7923 仍在 `Ss` 且未 traced、lldb/debugserver 为空。保留这个 appex 是记录事实，不视作调试残留。

清理记录 stop `04:35:03.350336Z`、delete `04:36:00.901052Z`、quit sent `04:36:02.317465Z`、machine exit snapshot `04:36:43.527568Z`；对应 stop→snapshot 约 100.18 秒，小于 120 秒。原 breakpoint list 明确为 “No breakpoints currently set”，cleanup 的 `delete_success=true` 且 `remaining_breakpoints=0`。`e1-machine-exit.breakpoint_remaining_from_list=true` 名称/值含义不清；结合原始 CLI list 与 cleanup 回执，不能把它读作仍有残留断点，原始字段仍保留。cleanup 的 `target_memory_reads=0` 只计收尾动作；callback 的本次 ReadMemory=1，不能用 cleanup 字段覆盖它。`quit_sent` 不是独立 LLDB 退出码，机器 ps 无 lldb/debugserver 只支持后续现场快照。

### Q4：Partial（治理偏差仍待接受）

`e1-failed-continue` 留存了 `TimeoutError: lldb prompt timeout: continue`。之后相同 PID 7923 再次配置并附加，执行报告/receipt 也明确记载同 PID 重挂；这仍只有一次成功 callback/runtime capture，但增加了一次 debugger attach 和人工采集窗口，不能用 `runtime_attempts=1` 消去 Entry 停点/重挂范围偏差。现有材料没有 Human/Product 对该偏差的接受。

`e1-call-ledger.json` 的上限为 48 calls，记录 62 calls before ledger-writing shell、63 calls including that shell，`remaining_calls=-15`、`budget_overrun=true`。recount 时间 `04:37:16.217350Z`，在 Human Exit 收件/记录 `04:38:49.720636Z` 之前。故可判断至少 63 calls、已超过 48；最终精确总数未知。约 2063.42 秒是 recount 时墙钟，不是最终结束时间；不能由其推断最终 total 或预算合规。作者在运行报告中也陈述 63/48，未隐藏超限。

## 不作出的结论

这轮资料支持一份冻结 binary 的完整解码、一个同停点单次复制、两次 paired schedule 的整数记录，以及有限的人类观察和清理快照。它不证明 n 状态恢复、完整系统通知覆盖、长期修复或 Release；Q4 偏差须由有权方另行接受，不能由本 reviewer 代 Product 接受。