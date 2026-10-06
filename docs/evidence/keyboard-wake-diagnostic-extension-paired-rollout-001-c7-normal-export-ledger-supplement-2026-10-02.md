# C7 同一历史轮缺失账本补证 — 2026-10-02

Human仅授权补同一历史轮缺失账本。root从原reviewer已存在session回执重建[usage supplement](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-normal-export-review-artifacts/usage-supplement.json)，未重开reviewer、实质审查或任何设备采集。原packet/报告/timer/stop receipt保留原字节；新证据补核旧UNKNOWN，并更正实际终止时刻，不倒写历史。

## 可证实记账

精确原reviewer session `01a0f298-7a06-74a0-9167-8a0e04aea197` 的历史窗口来自2026-09-30创建的复用会话文件，审查实际窗口仍2026-10-02；不会因文件名日期把它误归旧轮。只提取本轮调用ID、类型、历史行号、request/output平台时间及脚本已打印计时，不复制整段会话/加密消息/其他任务内容到仓库。历史slice2628–2779的SHA和source locator保存在ledger，便于复核。未调用新target或执行旧审查命令。

- 实际9底层calls：7个exec封装分别只含1个exec_command，2个send_message；同call ID的output不重复计数，reasoning/event日志不是工具调用。
- call1实际脚本起点 `14:43:23.299964Z`；报告写入 `14:50:54.416480Z`，墙钟elapsed451.116516s；call9回执另有monotonic累计451.116251s。两种计时来源分开保留。
- 原session `turn_aborted` 为 `14:51:33.208Z`；从原脚本起点到中止的墙钟累计489.908036s，超过480s hard约9.908s。soft360s目标亦未达到。此前root仅观测14:51:22Z、精确interrupt UTC未知的历史记录保留；现有历史回执补足中止时刻。不能声称hard完全合规。协调停止晚于hard，是本轮治理缺陷。
- 第3call是ACK/初checkpoint，第7call是第6底层call后checkpoint消息本身。checkpoint内容已有原协调回执；不把消息自身漏出总calls。
- call1/2/4/5/6/8/9脚本起止由旧打印回执补出；collaboration无脚本内部计时，使用平台request/output时间，内部字段null。call9内部elapsed没有原值，保留null；不从四舍五入工具duration补造。最终monotonic end仍null，terminal墙钟计算单独标识。

## 状态与边界

缺失调用次数及逐次回执记账已补，24原review inputs未漂移，报告SHA仍 `19c3e11ce508f7ac01a905617d9191a480f84f36cdc15e252de22514e153007d`，P1/P2/P3 Covered有限意见不变。本文件是协调者对历史回执的重建补证，不是reviewer当时提交的usage.json，不虚构原本不存在的最终独立交付。原交付Partial仍保留；新增实际hard超时事实，不借补账本自动改为完整通过，也不新作独立verdict或Product残项接受。

本次授权工作已完成，无新审查/自动续预算。正常路径运行链不因治理超时改为runtime失败；按钮延迟/标题、caller-stack/操作UTC限制、Maps未验证、历史skip和旧数据未恢复事实保留。未Simulator/LLDB/UI/container/build/test/install/deploy/source/Git/Release。无需CHANGELOG/架构合同，非M-02触发。
