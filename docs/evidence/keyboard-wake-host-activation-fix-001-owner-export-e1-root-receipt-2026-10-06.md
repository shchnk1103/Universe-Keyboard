# OWN-EXPORT-001 E1 root 收件及独立验收准备

root按用户转交仅只读收件：冻结decoder离线解码实际bin，与e1-decoded全文相等；binary1496bytes、SHA a8b3bde10c0c489e92b1e7f370e257d33c4156f805697af1597fe5d5fd35414d，callback/hash吻合，callback脚本冻结5fc756ed…不变。未操作模拟器、追加输入或改作者原件。

## 技术证据已收齐，仍待独立验收

PID7923/loaded UUID4B207746-89A7-321F-83C4-91477259BB26、PC4360859552、StopID2、断点1.1/hit1；callback actual身份/button/borrow齐，同停点一次ReadMemory，target expression0。16条v1记录buffer_complete，attempt1/2各paired；schedule seq4/15 owner=1、receipt=1，epoch由1到2。中间suspend→teardown completed/owner0→resume→replacement owner1→resumeEnd owner1、同coordinator/appearance记录齐。支持本轮观测边界，不能代完整系统通知、引擎提交、长期修复或Release。旧owner缺失故障窗口不拼到新候选。

Human本轮n基线、AppSwitcher直返键盘未重开、输入框n清空、h候选/输入更新按引述保留；单取证，无另输入或第二轮。recorded_utc只为收到确认时间。

## 清理与字段勘误

原e1-breakpoint-list.txt为No breakpoints currently set，e1-stop-and-cleanup.remaining_breakpoints=0、delete_success=true。e1-machine-exit.breakpoint_remaining_from_list=true字段命名有歧义，不能解释为还残留断点，原值保留，以原CLI/list0判定。cleanup文档target_memory_reads=0仅该收尾动作，不覆盖本轮callback实际ReadMemory=1。

stop04:35:03.350336→delete04:36:00.901052约57.55秒→quit_sent04:36:02.317465约58.97秒，machine_exit04:36:43.527568约100.18秒，保守退出上界<120秒；quit_sent不冒称独立session进程exitcode。后续机器ps无LLDB/debugserver，7923 statSs/nontraced，两诊断及category三键两读仍ABSENT。Human未卡住、两App已关闭，机器main/Maps0、appex1；驻留扩展不是调试残留，不自动再SIGTERM。

## 实际偏差保持，不自动接受

- 原48调用上限被超过。作者recount当时62 completed+本shell1记63，比上限多15；recount04:37:16在HumanExit04:38:49之前，63不是最终总数的独立证明，最终工具数至少63，尚未从原事件源核全。作者称约2063秒为recount时刻用量，不是最终作者结束时刻。不得改成预算合规，不因为成果有用而自动接受超限。
- 第一次attach/同步continue未返回prompt后同PID重挂，有一个人工采集窗口但多一次debugger附加。与Entry首失败停止边界须单独核范围/清理/影响，不能仅用runtime_attempts1掩盖重挂。

技术结果与治理偏差分开收件；独立验收未执行，Product未接受此E1偏差，旧AP-META接受不继承。

## 唯一下一建议

只对这轮现有证据进行独立只读验收，拟复用既有独立GPT6 Luna，四项：身份/单读；buffer/attempt与恢复整数链；现场/人工来源与清理；重挂及预算超限/原文一致性。准备packet/reader，20actualcalls/900秒新lane提案，至少最后6调用保交付；缺覆盖Partial，不自动续、重审静态pair或重采。此为Prepared，未授权派发。父诊断Completed保持，paired-rollout/修复Active。
