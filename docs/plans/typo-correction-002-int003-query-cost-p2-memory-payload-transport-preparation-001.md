# P2固定Debug产物与无输入取证准备 — Proposed

2026-10-10 有效范围更新：[批准的收窄合同](../product-decisions/TYPO-CORRECTION-002-INT003-QUERY-COST-P2-LOCAL-EVIDENCE-REQUIREMENTS-001.md)及[最小准备](typo-correction-002-int003-query-cost-p2-minimal-route-preparation-001.md)替代下一Run的外部profile必需项；B1独立空快照和C外部profiler不再强制。保留同次字节借用、有限读取、prefs与detach边界；本文旧执行授权不复用。

2026-10-09T11:13:05.417351+08:00

## 已具备的证据

R4真实raw结构/统计复核、R5五attach调用顺序核对完成；限定raw-retention/synthetic methodology静态Scoped Pass。不是iOS observer可用性、RunReady、Capture、Product、Gate或Release通过。29skip按原scope保留，Lua/R4-B实际runtime命题不可用synthetic代替。源码固定72dd217+22冻结候选，main推进不反复rebase/重验。

## 建议下一次授权只做准备文档

另立准备Assignment/AUTH，先只读已有设计和构建/安装证据，制定精确Debug opt-in payload、build identity/flags/entitlements/symbols、环境与无输入transport分阶段合同；不立刻build/install/LLDB/Simulator/Capture。将manifest算术erratum明确绑定：22候选、1helper路径变化、其余21；冻结旧manifest不重写，生成未来产物manifest须通过列表推导计数而非手写常量。review读取用预检精确manifest helper，不再手拼Evidence前缀，checkpoint先写后读取。

阶段A：Human单独执行授权后，一次固定Debug opt-in build及产物readout，明确main不更新绑定。复用同内容/覆盖的已有CI证据，不自动全套重跑；可观测flags/符号必须绑定新实际binary，默认/Release隔离证据与当前适用范围分开。失败停，无自动重试。

阶段B：再次确认405D994F-28CB-4F89-BB22-B64AD81C05A2当前空闲，才建立安装及无输入transport独立执行AUTH；选定同一debug binary、scope/FullAccess/schema/diagnostics前置检查、idle arm/freeze零querysnapshot、准确bytecopy/decode/identity与debuggerstopledger、before/after有限prefs。no-input检查不算产品Capture。当前未重新预约该Simulator，不触碰其他线程设备。

阶段C：独立readiness覆盖当前payload/observer/profiler/export/Run manifest后，另需正式Capture AUTH；绑定一次Human stimulus与完整raw留存，不恢复180ms硬门槛，不因main推进循环重试。随后独立Architecture/Quality及Product决策，Gate/父Close仍需各自授权。

## 退出与边界

准备阶段交付具体命令、一次预算、读写路径、角色、required evidence与stop条件，UNKNOWN必须先解决；不把未来设备依赖写成现在可用。本文仅Proposed建议，未新建或释放后续AUTH，不执行上述A/B/C。父TYPO-CORRECTION-002 Active；无source/commit/push/merge/ADR Accept/TestFlight/Release。


## 本轮Human授权准备结果

2026-10-09T11:23:30.578517+08:00：当前Human继续授权只读准备，新准备AUTH已消费；本方案准备完成，未执行A/B/C。阶段A精确argv/env/私有root/600秒一次/读写例外及产物检查已冻结于[Debugpayload方案](typo-correction-002-int003-query-cost-p2-memory-debug-payload-build-001.md)和机器binding。新buildAssignment Pending、AUTH Proposed/unconsumed，下一Human动作可直接批准该精确一次编译及cache例外，无需重复规划。

阶段B分为安装和零输入transport两种执行AUTH，不混成Capture。设备405D当前未重新确认空闲，无simctl/UI读取。安装先只bytefreeze新App/embeddedKeyboard，launch与FullAccess/schema/host/diagnostics有限检查另绑定；过往“已开启”/luna截图不能替代新Extension实例的runtimescope。

### B0新增明确前置：旁路会话懒创建

固定source RimeSessionManager.m:89初始correctionSession0；393 ensureCorrectionSession仅随实际query路径调用；589–599 getter在无session时返回0/unknown且不创建；632–653真正创建。probe arm QueryCostMemoryProbe.swift:147–153必须非零sessionOrdinal+luna+FullAccess，否则终态rejected，同进程不可重arm。故从fresh进程“不输入任何内容直接arm/空snapshot”的成功路径不能承诺，不能为了证据调用getter之外ensure/query/换schema/TESTINGfactory。

建议Human未来另批准一次明确固定公开拼音暖机输入（测量外、探针未arm、记录原输入与清理，不操作私文）；成功建立实际querysession后待2秒且touch/callbackidle，才进入无输入transport。暖机不算18个正式测量序列/不能宣称其查询总量为0，零输入只限后续transport区间。未获暖机授权则B0保持Blocked；此准备不改变产品查询调度或批准任何输入。若自然query未建立会话/实际schemaunknown则停止、不重试/创建/改源。Human设备已空闲确认也不自动授权暖机。

### B1零输入transport待授权合同

未来一次idle arm→不按序列按钮、不输入键→freeze；此probe一次冻结后不能reset继续正式Capture，因此正式P2需另授权新的Extension实例与独立暖机/observerpreflight，不能复用已frozenprobe。建议一个精确exportReady breakpoint、一次attach、1次export停点，留完整stopledger；不在正式measurement期间attach。必须用实际debug信息读取address/byteCount（frame variable，而非任意expression/enginecall），当前ABI/变量可见性未运行确认，缺失就停。符号/进程/UUID必须来自阶段A实际embeddedcodeimage。

copy需要2次同borrow内读取：byteCount验证256..655616且wire长度匹配，首份及second独立文件比较bytes/SHA，发生于继续线程前，指针不跨borrow；仅`memory read --binary --size 1 --count <actualBoundCount> --outfile <privatefile> <actualBorrowAddress>`，不扫heap/复用savedpointer。零输入已armed scope应header256 bytes/record0/queryStarted0/queryCompleted0/queryActive0/operation/sequence皆0、incomplete0、luna/fullAccess有限码与scope/UUID一致，cap4096/version1/header32/record20、TTL/clock合法，保留完整原始文件。不是合成C样本161216；完整4096快照才655616，避免混用长度。严格decoder复用已测的format规则，parser若需要新的可执行脚本需先演练/冻结并绑定未来AUTH，当前没有执行decoder工具或LLDB。

prefs仅允许已支持有限只读键（presence/type/value）：logging_enabled、log_category_display、diagnostics_high_fidelity_expiration；AppGroup明确group.com.DoubleShy0N.Universe-Keyboard。现有机器读取路由必须在未来权限内核实，若未支持只记unavailable、不遍历全部prefs/读hosttext/直接plist写入/killcfprefsd；缺必需readback则readinessBlocked。当前不接触任何设备container或userdefaults。

### C observer/readiness仍独立

选定实际Xcode profiler模板/命令、Clock/timebase、MainThread采样与内存指标、所有自动产物路径/权限/扰动限制后才冻结observer AUTH。准备阶段没有xctrace list/help运行，实际模板/变量可见性均unavailable；必须独立只读环境预检，不凭名称猜。原design需要continuous A0/A1/A2采样；unsupported mapping/clock/trace不得将partial成本问题伪装已完成；no-input transport本身不算observer适用性或Capture readiness。capture仍新Run/<=18sequences/无180ms硬门槛、独立readiness及独立CaptureAUTH，无Gate/父Close。
