# F4 调试通道主机侧只读分析 — 2026-10-06

Human“可以，请继续吧”仅续上一建议的主机侧分析。本轮未启动LLDB、未附加进程、未查询设备、未写采样脚本/夹具、未build/test或改生产源码。工作树branch/HEAD及staged0核对一致。

## 确认事实

本轮callback已使用`export_hit(frame,bp_loc,internal_dict)`传入frame，而不是全局`lldb.frame`。此形式与[LLDB官方回调合同](https://lldb.llvm.org/use/tutorials/breakpoint-triggered-scripts.html)一致；官方区分回调frame与CLI选择frame。故不能把“改用传入frame”当成尚未做过的修复。

PTY中出口位置解析为Keyboard.debug.dylib、wakeOwnerProbeExportReady+60，地址0x105f7efa0；附加时与之后breakpoint-stop展示的frame0均为libsystem_kernel/mach_msg2_trap+8、0x104b18b5c。callback记录symbol null、模块UUID不符，但没存frame PC、thread ID、stop ID或bp_loc身份。记录足以判失败并停止读取，不足以判根因。

候选解释是停点/帧缓存或调试通道同步异常；只是推断。现有材料不能区分这些解释，也不能追溯补出有效指针。不能换成系统模块UUID放宽校验，不能把断点代码地址作为buffer指针，不能读另一选中frame冒充本次出口。

## 最小下一步（Prepared，未授权执行）

建议H0仅主机侧隔离夹具预检，新20actualcalls/20分钟提案，最后6calls留清理与交付：

1. 在全新private tmp目录制作极小macOS夹具及debugger-side元数据callback副本，编译夹具，使用本机LLDB仅调试该新进程。夹具无键盘/App/RIME依赖、无用户输入或文件数据；模拟首次attach等待停点、continue后唯一专用出口命中。禁止附加任何既有用户/Simulator进程。
2. 只记录PID、线程ID、process stop ID、stop reason/断点ID对、bp_loc代码地址/模块以及传入frame PC/符号/模块；代码PC只作身份比对，绝不作buffer指针。必要的CLI frame0只作独立对照，不能替代callback。不要读取目标内存、调用target expression、猜ABI或导出内容。
3. 判定同一停点的callback frame、bp_loc及线程对应关系，记录不一致；不改框架、不静默重试、不扩大成Simulator验证。任一工具错误停止依赖部分。主机通过也不证明appex回调通过。
4. 清理仅本轮创建的断点/调试器/夹具进程，保留日志及UTC时间戳。不碰已安装候选、容器偏好或旧备份。任何无法正常退出需停止交回，不强制结束既有进程。

授权前不写夹具或采样实现，不运行LLDB/编译。生产五文件冻结不动。先验证取证工具本身，若主机仍不一致再交回工具归属；不再次要求Human复现Maps。运行残项不因本分析关闭，修复Assignment仍Active/Partial。

详细证据和本机API来源SHA见[analysis.json](keyboard-wake-host-activation-fix-001-f4-debug-channel-analysis-artifacts/analysis.json)。
