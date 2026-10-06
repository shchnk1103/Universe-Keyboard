# U1R1 独立运行证据审查

**范围意见：窄范围 Positive scoped runtime-chain acceptance。** 仅针对冻结的 candidate `43d85d612af6c606b5434dcb0a989e43e3c472bf6f296df3bd7c2fcb6220ba50` 在指定 iPhone 18 Pro Simulator 上的一次 U1 正常路径取证链。Packet whole SHA `e3faf25fbd3d1b0b854ea475aa17b35ee77c04d85561be2a8274179c0c1b8c74`、canonical self SHA `a447488e9e2568f78638ce4b41d4bd776507aa2a78f804c4acdd905a8558c2a5` 均匹配；65 项 content allowlist 与 1279 项 source/Vendor hash-only inventory 零漂移。允许的两个 Swift 文件仅按 allowlist 阅读；未运行 producer/collector/decoder/ledger/旧 T reader 程序，也未访问设备或用户内容。

## P1–P3 评审矩阵

| Criterion | Status | Primary locators / assessment |
|---|---|---|
| P1 | **Covered** | `docs/evidence/...-c7-ui-u1-artifacts/binding-readiness/authorization.json` 批准仅本轮按 fresh PID、安装路径/hash、同 session loaded module path/UUID 绑定，并保留工具 UDID 标签冲突；`tool-routing-analysis.json` 记录 defaults/receipt label `884CAC1A…` 与目标 UDID `405D994F…` 不一致，且 defaults 未改。`...-u1r1-artifacts/new-instance/attach-ready.json` 将旧 PID 80843 与新 PID 88188 区分，记录原 UDID、app container、Keyboard UUID `C3FC…`、debug UUID `77BD…`、session `4895…`。Call 1 `image list -u -f` 的 raw receipt 显示两个模块均从该 UDID 的当前安装路径加载；PID/候选和 78-file payload 身份、source/Vendor hashes与冻结身份一致。旧 PID 仅一次经授权 SIGTERM 后退出。 |
| P2 | **Covered** | 独立以 little-endian 66 个 UInt64 words 解析 `...-u1r1-artifacts/snapshot.bin`，没有调用 decoder。SHA256 `40ff2daf44c1a6495ea9188b4a10a7aa9160f3d38b35a4c8a99c1d9e41d8e467`，长度 528，header: version 1、incomplete=0、5 records、overflow=0、非零 run/process words、TTL=600,000,000,000ns。5 行所有字段（sequence/timestamp/stage/coordinator/appearance/attempt/owner/receipt/teardown/epoch/revision）均合法、连续且时间在 armed/expiry 内；synthetic arm seq1 的 owner/receipt=0 保留。唯一 attempt 1 由 seq3 insertBegin、seq4 schedule、seq5 insertEnd 构成，coordinator/appearance 均为 1；schedule 的 owner=1、receipt=1、epoch=1、revision=1，仅支持该记录 owner-present 且 receipt-present 的窄语义，不支持 owner absence 或 engine/host/Maps 结论。逐字段与冻结 `decoded.json` 独立比较全部相同；offline receipt 的 raw hash/count/size 也匹配。 |
| P3 | **Covered** | 允许读取的 `KeyboardViewController+WakeOwnerProbe.swift` 显示实际 export caller 位于 `words.withUnsafeBytes` 闭包内；同候选 raw `thread backtrace -c 8` 从 `wakeOwnerProbeExportReady` 经闭包、`Array.withUnsafeBytes` 回到 controller。frame info/variable 两份 receipt 均为同一地址 `0x11e62ad20`、byteCount 528；地址 8-byte aligned、长度在合同边界内。15-call ledger 为 30 行、每序号一 request/response，01–15 全配对；15 个 raw receipt SHA 与 ledger 一致。唯一 `memory read --binary --size 1 --count 528` 前有 caller/参数检查，之后依次 `breakpoint delete 1`、`breakpoint list 1` 空、continue、detach。机器退出读回显示同 PID/路径且运行态 `Ss`；source inputs 零 drift；诊断两键仍原缺失，值/存在性未变。Human 仅确认视觉 Exit，明确没有额外试打或点击响应测试。 |

## 时间与限制

Ledger 精确记有 15 次 debugger tool calls；新实例 ready 前的 6-call ledger 是同一前缀，raw SHA 与完整 ledger 前 6 次相同，不重复计作另一轮。`stop-timing.json` 的 root 可观察停点工作区间为 63.106 秒（13:19:53.978–13:20:57.084），在 120 秒工作预算内；实际 Human freeze click、target pause 起点与 borrow 创建 UTC 均未知，因此该数不是完整 target pause 时长。工具回执的 UDID 标签冲突保持原样；实际 PID/path/UUID 是依获批补正建立的绑定。

本意见不证明 Maps、engine、host、根因、额外交互响应、最新完整数据字节相等或 Release，也不构成 Quality/Product/Release Gate。只接受上述单次运行证据链的有限覆盖。
