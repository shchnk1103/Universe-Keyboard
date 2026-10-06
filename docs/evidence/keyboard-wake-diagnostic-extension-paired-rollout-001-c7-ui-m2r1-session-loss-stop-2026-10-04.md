# M2R1 基线后调试会话不可用 — 2026-10-04

本轮在正常基线后、目标AppSwitcher前停止，Incomplete；无freeze、0memory read、无snapshot，不拼接新session/窗口。Human回报“有按键反馈，候选栏更新，输入框有变化，‘取证’可见且尚未点击”；文本/candidate内容未读取。原M2孤立提前hit1继续仅记录，本停止原因不同，不把它记成重现。

新41635实际原UDID loaded UUID匹配、原出口断点1 resolved0hit、continue running。Human arm后call07仍0hit；call08是上一turn的同计数查询原件，时间来源以ledger为准。当前root临时store wrapper不可用，首attempt未调用目标工具；从private持久化账本恢复seq/session后call09，显式session27ecbb96-90d1-4755-bc33-e742b014fc63返回No active debug session。call10显式detach同样失败；不记成功，没有重attach或盲删其他断点。

10debug calls/20账本rows与raw SHA保全。目标进程41635最终Ss、精确path/SHA一致；只读process inventory无debugserver/lldb-dap，另有lldb-rpc-server元数据未动，不据此断言所有debugger均已退出。自身断点删除/list及原session detach无法核验，记UNKNOWN；不是clean Exit。安装78、源码1279、6MachO/双签名、956保护副本、诊断ABSENT/off与部署再次只读通过。machine-exit模板loaded deferred字段是模板局限，真实loaded核验见call02，未重复加载读取。

Human提出可能是沙箱，授权只读提升权限对照：相同ps在沙箱Operation not permitted，主机提升权限成功，原设备Booted、41635 Ss。确有shell沙箱访问差异；MCP没有escalation参数，No active debug session不等于ps权限拒绝，当前对照不能证明MCP会话失效的原因或恢复旧session。未用新attach伪造原session连续性，未重启工具/Simulator。

后续先解决调试会话持续性/cleanup证明，再准备新run权限；不得将旧窗口缺失数据补成配对owner结论。本轮人工视觉Exit已确认，仅观察未试打。该停止交付是root事实记录，不是独立Quality/Architecture/Gate/Release。

[原件保全](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m2r1-artifacts/preservation.json)；[Entry](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m2r1-entry-2026-10-04.md)。


## 人工视觉 Exit 增量

Human回报界面仍正常、按钮仍取证、候选与输入框内容未删除；不抄内容，不将视觉正常等同owner/输入健康或debugger清理。原session/自身断点cleanup及detach仍UNKNOWN；本轮Incomplete，不追加输入、切换或冻结。
