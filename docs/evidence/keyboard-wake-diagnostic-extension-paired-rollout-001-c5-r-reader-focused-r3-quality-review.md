# QUALITY-C5-R-ACCEPT round3 独立补审

**范围与身份。** 本轮只审 F1/F2：冻结 reader 证据中 17 条目标显示对应关系和 reader 完整性；不重开整体验证 Q1/Q4。Packet、manifest、Entry 与 18 个指定输入摘要匹配；HEAD 84b9c19227330b0fe6ff391be001ee398010fd6a、branch codex/keyboard-wake-v3-compatibility-gate，candidate af38fac6758df45f6686ff00845a065157c6679fd57de8dcf015c0e9f283cbd9，run C5-R-20261001-01。source/built identity 沿用 root 预检，未重做 568/111 全量遍历。

| 条件 | 结果 | 证据与边界 |
|---|---|---|
| F1：目标事件的显示行 | Covered | 从 typed-window.events 按源码 formatter 字段顺序重建 17 行；从每个 snapshot.text 逐行解析，再按跨 snapshot 的逐行最大计数合并。两侧均为 17 行、15 个不同值，Counter 完全相等、差异为空。10:46:30 的 set_marked_text entered 与 returned 各出现两次；seq30 的 14 个目标代理行均可见。 |
| F2：reader 完整性提示 | Covered（仅存档窗口） | seq33 的 67 是总行数，其中目标生命周期/恢复行为 3 行、非目标同秒行 7 行；没有把 67 误作目标行数。检查存档快照未发现 incomplete、unsupported、unavailable、budget、partial 提示；页面显示筛选/总数与 pagingNotice 的代码路径相符。 |

**时区判断与 HOST-Q-R-01。** 已核查 formatter 使用 HH:mm:ss.SSS 和事件 UTC 时间、未硬编码固定时区；同一 Main App reader 的计划要求展示目标窗口及其实际完整性状态，没有要求跨时区固定渲染。此次存档 UI 与原事件来自同一被核验环境，UTC 02:46 对应捕获显示 10:46（本地 +08:00），17/17 多重集独立吻合。故缺少固定时区设置不构成此历史窗口显示证明的必要缺口；但本轮不证明其他时区下的行为。基于此有限范围，解除旧 HOST-Q-R-01 对该存档窗口 reader 核验的 Hold。round1 Hold 与 round2 Partial 原文和结论均不改。

**限制。** UI 不显示 origin/process/appearance/localSequence，重复行只证明显示层多重集，不能反推出相同秒行的隐藏身份。存档快照核验不证明当前 App/设备状态，也不替代 Gate、安装、Release 或 Product 接受。30 skips 仍是 skipped；既有 logger/expiry 残项及无 insert_text/tail 证明保持原边界。本轮未访问当前 Simulator、installed/AppGroup、prefs、journal 或 live UI，未执行采集脚本，未构建、测试或修改仓库。

**结论。** F1/F2 在冻结存档窗口内 Covered；HOST-Q-R-01 限域解除。此结论只适用于该 reader 证据包，不扩大为整体运行或发布验收。
