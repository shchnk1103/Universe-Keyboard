# Product Decision — HOST-ACTIVATION-FIX-001 F1 / Grok — 2026-10-04

Authority：Human Product Lead，本线程用户。来源原话：“我想要让 grok 来做后续的源码实施，现在我先批准草案中的责任绑定及 F1 五文件实施”。

批准[Assignment](../assignments/keyboard-wake-host-activation-fix-001.md)责任绑定与仅F1范围，明确Executor由原拟议root改为Grok。Grok是唯一五文件源码writer；root承担Keyboard Experience Domain Owner、Coordinator、未来Environment Executor和治理记录，独立Architecture/Quality仍为原指定GPT6 Luna reviewers，未来精确packet/预算/ACK另批准。

F1允许五文件本地实施、测试编写、范围内swift-format/lint与diff检查、最终新增差量/hash交付。60实际toolcalls/60分钟从Grok ACK并开始F1起计，先到停止，最后4calls预留输出/核验；不续预算。当前授权不含build/compiler/test运行、simulator/LLDB、安装/恢复、Maps、备份删除、Git操作或Release。新路径仅原指定两项，不加第六源码文件。

原工作树/branch/HEAD和dirty保全合同不变。root当前核16个required inputs与五路径3existing/2absent无漂移，staged0，Domain/Coordinator ACK完成；不能代替Grok ACK/工具可用性/写权限/即时writer核验。生命周期仅Assigned。Grok只读Entry通过并ACK后方可Ready/Active，不需再向Human重复请求相同F1授权；Entry不满足就报告停止。F2/F3/F4依赖/授权仍未满足。

F0历史manifest中的root拟议源码owner字段保留为历史，由本决定及[Grok交接包](../plans/keyboard-wake-host-activation-fix-001-grok-f1-handoff-2026-10-04.md)明确取代；不重写冻结F0。R1 Partial、R2设计条件通过、父Completed、旧rolloutActive不变。尚未发送到任何外部Grok会话，也不伪称Grok已接收或开工。
