# AP-META-004 元数据停点身份匹配／范围偏差记录

## 授权与身份

Human批准36actualcalls／30分钟、原UDID独占，另批核实旧PID99161后一次正常SIGTERM。旧实例已退出；Human主App搜索空框叫出新PID778，观测可见／完全访问开。branch/HEAD/staged0、source5与安装78文件及模块UUID/SHA均匹配冻结输入，未build/test/install/deploy或生产修改。

## 单轮证据

配置回执callback已注册、async false、唯一bp1.1/hit0。pre-arm与pre-freeze各自独立新快照、原ps及逐项判定全部PASS。实际附加stat为SXs，仅记录不要求普通Ss；这不补证历史R3失败子项。Human一次观测→显示取证，零输入；随后一次取证，callback1次、breakpoint hit1。

callback：PID778、thread44589446、frame0、StopID2（attach为1）、stop reason breakpoint且data[1,1]；frame PC与bp_loc/冻结binding代码PC一致；frame/module/bp_loc UUID均4B207746-89A7-321F-83C4-91477259BB26；GetSymbol/GetFunction mangled均精确出口符号。最多8caller函数名含handleWakeOwnerProbeButton与Array.withUnsafeBytes，支持本次按钮及同步借用调用链。清理前CLI/SB快照同PID/thread/StopID/frame/PC/UUID，身份各项一致。

## 范围偏差及不作结论

技术元数据身份成立，不无条件宣称本轮完整验收通过：LLDB默认停点格式自动显示了address/byteCount参数，原始PTY如实保留。私有脚本未FindVariable、读参数、读buffer、ReadMemory或执行target expression；但默认formatter的参数解码存在，不宣称整场调试器参数／目标内存读取为零。原件保留，不复制参数值到公共报告、不事后抹除或拼补。此偏差处置仍待Product／独立验收，不自动接受。没有读取owner缓冲正文，不能据此声称owner为空、生命周期通知已验证、Maps修复或整体父任务完成。

## Exit

唯一断点删除true、列表空；process detach、单独quit exit0。同PID恢复Ss，无匹配debugserver，诊断三原键均仍ABSENT。本次callback→delete约27.316秒，callback→机器Exit读回约70.220秒为暂停上界（detach在此前完成），小于120秒；exact detach时间未独立标记，不称27.316秒为精确暂停长度。Human确认“界面正常，显示取证；App 已关闭”，视觉Exit完成，未要求试打。

## 产物与下一步

/private/tmp/ukey-host-activation-fix-appex-meta-r4-20261006：authorization、device-entry、old termination、fresh、脚本SHA、configuration/binding、两阶段snapshot/evaluation、Human arm/freeze、callback、rawPTY、stop-and-cleanup、machine-exit、run-summary。最终35/36actualcalls，逐调用账本及视觉Exit齐，不续采样。旧备份／证据保留，未Git或Release；无CHANGELOG或架构合同修改。下一仅建议对本轮真实原件做最小独立只读验收与范围偏差处置，不再自动重采。

最终关闭UTC 2026-10-06T03:11:45.158394+00:00，墙钟 324.0 秒。技术身份匹配，范围偏差处置／独立验收待定，不无条件标整轮Passed。
