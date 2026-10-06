# M2R2 Maps复现／出口帧参数不可读停止 — 2026-10-04

## 限定结果

Human正常基线与同实例AppSwitcher直接返回后失败观察齐；真实出口在明确freeze点击之后按预期hit1，bounded caller栈指向观测按钮同步borrow。但LLDB报告的frame0为mach_msg2_trap，出口static byteCount不可读。按冻结停止合同立即cleanup，0 memory reads、无snapshot/decoder/attempt机器配对；本轮运行取证Incomplete，不能判返回后owner为空或根因。不是旧孤立提前hit1的再现，原Product仅记录决定保持。

## 同一窗口与人工反馈

原设备iPhone18Pro/iOS27.0 UDID405D994F-28CB-4F89-BB22-B64AD81C05A2，固定43d85d候选；新PID55759，Maps55725；PTY47167、LLDB55990/debugserver55991。pre-arm真实loaded两个UUID匹配，安装78/6MachO/双签名、源码1279与保护956通过，诊断ABSENT/off、部署正常。身份/进程在arm/基线/切换返回/freeze前逐卡同一核验，原生通道跨Human回复持续。

Human单次观测回报取证，出口hit0；一次n基线反馈正常、候选更新、输入框变化、取证可见。仅打开AppSwitcher直接返回Maps后：键盘无关闭重开，取证可见，输入框被清空，候选保持原样，未点按钮。随后一次n：按键反馈正常、候选与输入框均无变化，取证再次出现。最后依卡只点一次取证。按键/UI状态来源为Human，不把反馈当engine接收，不抄内容；实际UI action数和click时间未独立测量。freeze前保守elapsed从pre-arm readiness为526.074秒，未超过600；实际arm/freeze设备时刻未直接采，header/TTL/completeness因无snapshot未验证。

## 出口与参数停止

native step09查询断点/帧/8帧栈/static address-byteCount：断点1 resolved单位置hit1，stop reason breakpoint1.1，但frame0仍显示libsystem_kernel mach_msg2_trap+8；栈后续为handleWakeOwnerProbeButton闭包、Array.withUnsafeBytes和按钮handler。caller中显示transport borrow大小1056值只是调试器元数据，不是已读取snapshot；不据此推行数、完整性或owner，也不取该地址/大小代替合同所需实际export frame参数。frame variable返回byteCount undeclared。没有切其他帧猜参数/ABI、目标函数调用、寄存器或内存读取，没有重试。

## Cleanup与证据

native step10：delete自身断点1、list无断点、continue resuming、process detach明确55759 detached、quit code0。最终55759 Ss/flags0x4004/P_TRACED clear，55990/55991退出；安装/source/保护/诊断与部署只读再核一致。无恢复/安装/重新部署/新源码构建测试/Git动作。人工视觉Exit已确认状态保留，只观察未追加试打。

10native工具步骤/20request-response账本顺序与全部raw SHA核验，PTY原文与Human原话保全。[保全清单](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m2r2-artifacts/preservation.json)、[PTY](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m2r2-artifacts/pty-transcript.txt)、[停止记录](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m2r2-artifacts/freeze-stop.json)、[cleanup](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m2r2-artifacts/cleanup-exit.json)。实际target pause开始UNKNOWN；收到Human回复的精准客户端时刻未独立采，用工具首次followup UTC和记录时刻分开，不补造。10steps包含启动/轮询和多命令批次，不冒充10个LLDB命令。

## 后续边界

本轮不续采/auto retry，不从caller字节或历史snapshot拼出owner证据。最小建议先只读核清原生LLDB的停点帧错位与参数读取方法，准备可审核修正，再另授权正常路径停点读取预检；机器验证实际export frame参数可读后，才申请新Maps配对窗口。该建议Prepared未执行，当前父子Active、Maps根因仍开放；无独立验收或Gate/Release结论。


## 人工视觉Exit增量

Human确认界面仍是AppSwitcher返回后的样子，按钮取证；附件可见键盘和候选栏、宿主搜索框当前状态。只记录状态，不抄候选/宿主文字，截图不复制进repo，仅附件摘要可用时登记。此视觉Exit不是“打字已恢复”：输入恢复未验证，无追加输入/删除/选词/切换。machine cleanup及人工视觉Exit齐，本轮仍Incomplete/无snapshot、owner未覆盖。
