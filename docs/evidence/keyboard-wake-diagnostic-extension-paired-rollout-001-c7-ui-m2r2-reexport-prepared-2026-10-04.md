# M2R2 停点帧只读核查及同一历史窗口补导出准备 — 2026-10-04

状态：只读核查完成；执行包 Prepared，重新附加／点击／读取尚未授权或执行。原 M2R2 Incomplete、0 memory reads 记录保持。

## Symptom / Reproduction

同候选正常 U1R1 历史帧可显示 export 与静态 address/byteCount；M2R2 明确取证后的预期 hit1 却选择到初始 attach 的 mach_msg2_trap 帧。caller 有按钮同步 borrow，但不能替代出口参数。当前已核实的是 selected-frame 错位，LLDB 内部具体原因未确定，不证明符号缺失或 App 故障根因。

## Observed Timeline / Boundary Evidence

原 M2R2 step09/10 和视觉 Exit 不重写。只读主机检查显示原 PID55759、精确安装路径仍存在，启动 UTC04:48:08 早于原实例 discovery04:48:35.365440，flags0x4004 / P_TRACED clear。同实例保留是当前进程身份推断；冻结内存尚未读取。

Core freeze() 优先返回已有 frozenValue；refreshExpiry 仅影响 armed 状态。原 handler freeze 返回后才会调用已命中的 export，因而静态合同支持再次取证导出同一冻结值，而无需新 arm、输入或 Maps 复现。按钮标题不能独自证明冻结状态；runtime header、run identity、完整性仍待补读。

本机 LLDB breakpoint command add 文档说明 callback 的 frame 是实际命中帧，global lldb.frame 不会同步更新。Prepared debugger-host callback 使用传入 frame、eNoDynamicValues 与 non-synthetic 静态字段，验证 PID、frame0、符号、debug-dylib UUID及至多8帧的按钮同步 borrow；只输出参数元数据，不读 transport、调用目标函数、自动继续或 rearm。仅 AST 语法通过，未附加／导入／命中实测，不能承诺参数一定可读。

## 一次补导出 Entry 与冻结命令

目标仅原 iPhone18Pro/iOS27.0 UDID405D994F-28CB-4F89-BB22-B64AD81C05A2、保留 PID55759、43d85d612af6c606b5434dcb0a989e43e3c472bf6f296df3bd7c2fcb6220ba50 候选。Human 需确认本窗口仍独占，未再输入、删除、切换、点按钮、安装或部署；任何变化先报告。不关闭／终止当前扩展，不新 arm，不新建大备份。

执行授权后只读再核原 branch/HEAD、冻结 source/build inputs、安装字节/loaded UUID、进程 start/path 和两项诊断 off；复用 M2R2 已验证完整保护，回滚仍需单独授权。建立新的 native PTY 与 request/response/raw SHA 账本，不复用已退出47167。

1. 新 PTY：script -q /private/tmp/ukey-wake-m2r2-reexport-20261004/pty-transcript.txt xcrun lldb --no-lldbinit --no-use-colors --attach-pid 55759。
2. 核对实际 loaded appex UUID C3FC7115-4215-3801-ABBB-C8A648ED0C32 与 debug dylib UUID77BD18E2-E090-37D7-865F-84D762E69F70。仅新建自身出口断点，resolved单位置、初始hit0；记录实际断点ID。
3. command script import /private/tmp/ukey-wake-m2r2-20261004/frame-read-audit/export_frame_callback.py；breakpoint command add -F export_frame_callback.export_hit OWN_ID；continue。Human 此后只按一次“取证”，不输入或切换。
4. callback receipt 必须 actual hit frame 与静态参数全部通过。最多一次 exact byteCount 的 binary memory read；地址来自本次实际出口参数，8对齐，长度176..11352且8倍数。停点工作预算120秒、单工具等待不超过30秒；失败立即 cleanup，不自动重试、不用caller指针／寄存器／ABI／目标函数求值作替代。
5. 用冻结 decoder 验证 transport/header、run/process、完整性和记录关系；若长度与旧caller1056旁证不同，保留差异并停止解释，不凑数。原轮没有header，不能伪称与旧header逐字节一致。补证归属原 M2R2 历史窗口，单独账本，不覆盖原失败记录。
6. 删除自身断点并确认列表；仅停止时 continue，然后 detach/quit；核 P_TRACED clear 与本次 LLDB/debugserver退出，人工只观察视觉 Exit。不得追加健康输入或清空候选。

## Root Cause Status / Next Diagnostic Step / Owner

owner是否为空、engine接收与发布边界仍未知。完成一次历史补导出后直接交根因边界判读和必要独立 Architecture／Quality 验收；无自动重跑或其他子系统调查。父任务 Exit 要求关联基线／失败时间线、身份与证据来源、Debug Investigator 报告和独立结论。今晚完成是执行目标，不降低 Exit，也不把快照成功等同父任务关闭；不足则交明确缺口与交接，不宣称根因或修复。

证据：[Prepared artifacts](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m2r2-reexport-artifacts/manifest.json)。原证据：[M2R2停止交付](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m2r2-frame-stop-validation-2026-10-04.md)。无源码修改、构建、测试、安装、部署、恢复、Git发布或Release。
