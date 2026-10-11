# F4-M 独立只读验收收件 — 2026-10-06

Human授权“可以，请你开始只读验收吧”。复用独立 GPT6 Luna `/root/f4p_quality_four_paths_fresh`；新 lane F4-M-RUNTIME-QUALITY round1。只读本轮冻结证据，无设备、LLDB、构建、测试、源码或 Git 操作。

## 结论

[作者原报告](../reviews/keyboard-wake-host-activation-fix-001-f4-m-quality-r1-artifacts/review.md)对M-Q1..4的记录准确性判Covered（明确限于冻结记录与缺口呈现）。F4-M运行结论仍为Partial；没有完成修复、owner/通知取证、runtime Gate或Release的结论。不是接受运行残项。

- Human证据仅支持本轮n基线和AppSwitcher直接返回后单h候选/输入框正常更新。
- PTY/callback身份不符，缓冲读取0；停止、不猜地址、无第二轮。
- 断点删除、detach、退出及诊断原ABSENT恢复有原记录支持，未现场复验。
- 1021.301751秒可由授权起止复算；58calls是运行作者账本值，本次输入不足以逐条独立重建。

## 保留缺口与责任

| ID | 缺口 | 下一责任／处置 |
|---|---|---|
| F4-M-Q-001 | callback实际frame0身份异常，无buffer/owner/receipt/attempt完整性证据 | root Debug Investigator；建议先仅主机侧调试通道分析，执行另授权；不猜修生产源码 |
| F4-M-Q-002 | 精确暂停时长UNKNOWN | root记录／Human Product后续决定；不回填或假造 |
| F4-M-Q-003 | 未另供关闭前视觉Exit | Human证据依赖；不以App已关闭替代，后续决定另授权 |
| F4-M-Q-004 | 58次运行调用无法由本轮输入逐条独立复算 | root账本证据责任；作者值保留，不冒称独立计数证明 |

审查仅读冻结副本，未现场复算live payload、设置或进程，这是本次只读范围，不等于已确认漂移。pair/源码身份沿本轮原有机器记录绑定，不声称reviewer现场读取。历史skip仍未验证；父任务有界Completed不重开，修复Assignment保持Active。

## 交付与收件

四作者文件ACK/review/usage/delivery-readback均写出并读回；root再次核15输入与四输出SHA。作者记录16actualcalls/371.499713秒，在16/900预算内；root不冒称逐工具独立审计作者账本。首次ACK lane/scope误字段已作者补正，原错误SHA在作者报告保留，原文件字节未另存；无原schema合格声明。作者报告run路径少了`-fix`，正确原件目录为 `/private/tmp/ukey-host-activation-fix-f4-m-20261006`；root在[收件回执](../reviews/keyboard-wake-host-activation-fix-001-f4-m-quality-r1-artifacts/root-receipt.json)另列勘误，不改作者报告或packet。

本轮只完成独立收件，不自动新增模拟器验证、风险接受、源码实施或Release。下一建议仅排查取证通道，先避免再次人工复现。
