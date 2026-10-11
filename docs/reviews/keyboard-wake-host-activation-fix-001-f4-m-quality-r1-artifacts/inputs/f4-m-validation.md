# F4-M 单轮 Maps 回归交付 — 2026-10-06

状态：Partial。原 UDID 405D994F-28CB-4F89-BB22-B64AD81C05A2、精确 F4-P 诊断配对候选。未构建、测试、安装、部署、改源码或 Git，未自动第二轮。

Human 单 n 基线正常；AppSwitcher 直接返回时键盘未关闭重开，旧候选保留、Maps 输入框清空；再单 h 的按键反馈、候选及输入框正常更新。只支持这一次返回后输入正常，不证明长期修复。

单次取证触发出口断点，但实际 callback frame0 的 symbol 为 null、module UUID 不匹配，状态 hit_frame_identity_mismatch。未猜 ABI、寄存器或地址；目标缓冲读取 0 次，无 snapshot，不声称 owner、attempt 配对、完整性或真实通知覆盖通过。日志覆盖未提取，不以缺行判未送达。

本轮断点 1 已删除、进程 detach、LLDB 正常退出。暂停精确时长缺持久时间戳，标 UNKNOWN。Human 关闭两项诊断和两 App；logging_enabled 恢复原 ABSENT，high fidelity 及两个类别键保持原 ABSENT，两次读回、其他偏好不变。未另供关闭前视觉状态。

原件：`/private/tmp/ukey-host-activation-fix-f4-m-20261006`。结构化证据见 [receipt](keyboard-wake-host-activation-fix-001-f4-m-artifacts/receipt.json)，私有原件 hash 清单保持。所有旧备份保留。

后续仅建议独立只读验收此 Partial 及清理证据；不得把导出缺口记作通过，不自动重新取证。修复 Assignment 保持 Active。

最终账本：58/60 actual calls；墙钟 1021.302/5400 秒。最终五文件/hash、branch/HEAD及staged0符合，诊断四键仍ABSENT。
