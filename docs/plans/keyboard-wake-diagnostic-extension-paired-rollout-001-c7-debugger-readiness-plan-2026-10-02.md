# C7 调试器就绪最小切片（待明确授权）

目标：验证已安装candidate实际appex process与编译MachO配对、LLDB入口与export符号/断点可resolve，避免先arm后才发现工具不可用。root EnvironmentExecutor solewriter，Human保持不输入/点击probe；沿用原独立准备审查，不新增review lane。

Entry：指定iPhone18Pro/iOS27.0/UDID405D994F-28CB-4F89-BB22-B64AD81C05A2本轮独占、明确attach读取scope；现installed78candidate字节与appex PID身份、诊断off、正常输入和FullAccess已核，本轮fresh完整main827/group53/app111备份保持。键盘当前正常、probe未arm。

最小执行：只读查精确Keyboard appex PID/可执行路径，不按模糊进程名误attach；MCP debug_attach_sim(pid,continueOnAttach=false)，记录session并以精确sessionId后续；只image list/lookup读模块UUID/实际符号，与冻结MachO清单匹配。通过breakpoint add精确wakeOwnerProbeExportReady符号验证resolved，不触发它，不执行任意表达式、函数、寄存器写或内存写；remove该断点，continue/detach完成。若任何身份/符号未匹配即detach并停。暂停可能使键盘短暂不响应，Human期间不操作。工具不可用只记录，不能另开shell LLDB偷偷attach。

Exit：身份/UUID/符号/断点resolve/断点移除及detach回执，候选仍未arm、诊断off。不通过此步骤证明address/byteCount局部变量可读：必须到真实出口停住才可核，未来单轮arm/freeze/export/固定memory read需另明确授权与准备好的decoder。无独立dSYM现事实保留，不猜x0/x1，不EvaluateExpression。

不含Maps/AppSwitcher、正常或异常输入、新build/test/install/deploy、源码/Git/Release/整体Gate。已实际安装与UI入口Exit不自动放行现场。
