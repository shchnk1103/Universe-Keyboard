# QUALITY-C7-NORMAL-EXPORT round 1：正常路径有界导出独立验收

**结论：Positive scoped runtime-chain acceptance（仅限本次正常路径、单轮、内容无关导出链）。** P1–P3 均 Covered。它不证明 Maps、RIME engine 成功、host 提交、根因、整体 Gate 或 Release；不抹去两项 UI 残项。

| Criterion | 结论 | 审查结果 |
|---|---|---|
| P1 身份与停点绑定 | Covered | 24/24 输入摘要匹配。build manifest 与 machine-entry 指向同 branch/HEAD、候选 digest、571 source/build、630 Vendor、78 installed 项及相同十文件 source identity；machine-entry 无 mismatch。session 3c463407… 与 attach-ready 的 PID 24050 相同；加载的 Keyboard UUID 7E0813A6…、debug dylib UUID FE12AEDC…均匹配 paired-products。断点唯一 resolved 后 hit=1；同 session 的 frame 0 停在 wakeOwnerProbeExportReady，machine-exit仍是同 PID/路径，HEAD和诊断偏好未变。停点身份链成立。 |
| P2 原始 buffer、decoder 与 attempt | Covered（有限语义） | 我独立解析 raw 528 bytes，SHA-256 3a2a46a7…，66 个 UInt64 words；magic/version、长度、非零 run/process words、TTL、count、overflow、序号、时间边界和枚举检查均通过，recordCount=5、buffer complete。独立解析事件与冻结 decoded.json 五行逐字段相同。attempt 1 由 seq3 insertBegin 和 seq5 insertEnd 唯一配对，同 coordinator/appearance；唯一 seq4 schedule 为 owner=1、receipt=1，未发现 owner-absent sequence。它只证明一次调度记录含 owner/receipt，不证明 RIME engine 执行或 host 提交；synthetic arm 的 owner=0 不外推为空 owner。 |
| P3 借用边界、读取/清理、恢复与残项 | Covered（caller-stack / 时间戳限制明示） | controller 源码第83–89行先 freeze，再在 words.withUnsafeBytes 闭包内把 address/count 传给标记函数；Core freeze 在锁内复制固定记录、锁外编码（KeyboardWakeOwnerProbe.swift:222–250），容量128条；11-word header + 每条11 words、8字节/word 对应 decoder 上限11352 bytes，最小单记录176 bytes。出口回执记录 address非零、byteCount=528、对齐且范围内，并在停点按恰好528字节读取；之后 remove、continue、detach成功。Machine exit 的偏好存在性和值等于 Entry（两项诊断键此前不存在且仍不存在）；Human exit 确认键盘恢复正常。 |

**必要边界与残项。** 没有单独采 caller backtrace；但已冻结候选的静态 caller 在 withUnsafeBytes 闭包中，真实 frame/参数与该符号、已加载 UUID 和唯一命中断点同 session 一致。因此本意见只接受“该停点内固定地址/长度被有界复制并完成清理”的窄链，不声称额外 caller-stack 证据。点击、停点、借用及命令没有逐项 UTC；五条单调时间戳和回执顺序仍足以核对本轮 buffer 的先后，不据此关联外部日志或推算按钮延迟。按钮延迟仅为 Human 主观“超过一分钟”且未实测；导出后文字仍为“观测”也是保留的 UI 文案残项。Human 随后确认键盘正常，不能倒改先前卡顿/文案事实，也不赋予 Maps 结论。

审查仅读冻结 allowlist，独立解析归档 bytes；未访问当前设备/Simulator/UI/container/LLDB，未运行 build/test/install/network/Git，未改仓库。报告与使用账本保存在 packet 指定 scratch。
