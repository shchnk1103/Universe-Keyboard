# U1 正常观测→冻结→有界导出准备 — 2026-10-03

状态：Prepared，Human本轮仅授权准备，尚未授权执行或下一人工窗口独占。不得以本文进入运行 Ready。沿现有 Assignment 由 root Coordinator / Environment Executor 唯一写入证据，Human 为 Product Authority / Manual Operator；Domain Owner 与既有长期角色不变。准备阶段不新分配独立 reviewer lane；运行证据独立验收如需开展，另冻结 scope/预算并授权。

## 固定范围与来源

唯一原工作树 / branch / HEAD 不变：paired-rollout-preflight/Universe Keyboard，codex/keyboard-wake-v3-compatibility-gate，84b9c19227330b0fe6ff391be001ee398010fd6a。唯一模拟器 iPhone 18 Pro / iOS 27.0，UDID 405D994F-28CB-4F89-BB22-B64AD81C05A2。

固定新候选 43d85d612af6c606b5434dcb0a989e43e3c472bf6f296df3bd7c2fcb6220ba50；H1 App/appex payload78、MachO6、配对身份在 freeze-inputs.json 中绑定。重点 appex UUID C3FC7115-4215-3801-ABBB-C8A648ED0C32、Keyboard.debug.dylib UUID 77BD18E2-E090-37D7-865F-84D762E69F70。无独立 dSYM，不预填真实停点参数可读。1279 hash-only source/build/Vendor inputs 本准备轮零漂移。

[U0交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u0-validation-2026-10-03.md)证明本轮正常候选/提交、空栏初始可见、有候选时未arm按钮隐藏、提交后可见；78文件与H1一致、两诊断键原ABSENT/off保留。未测精确按钮延迟，不推普遍修复。旧候选 ddd557… 的 PID24050、UUID、528字节/5行只作历史方法参考，不移用于本候选。

## 执行前依赖与分阶段 Entry

1. Human明确授权本U1单轮及调试器附加/有限读取/清理，并确认直到结束原模拟器独占；重新确认无重装/部署、完全访问仍开、键盘正常空候选且未点观测。两项诊断保持关闭。
2. root执行 fresh 只读身份/78SHA、源输入、两诊断键存在性及值核验。精确PID必须来自原UDID当前安装路径下唯一 Keyboard.appex executable，并核其SHA；不按同名进程、旧PID或共享MCP defaults附加。若无进程/多进程/路径变化/值漂移，停止，不自动启动、终止、重装或重置。
3. I0完整备份与I1 after-preservation继续保留，先核快照可用性；它们是U0输入前历史恢复点，不声称覆盖U0之后的最新词典。U1不修改持久诊断配置、不安装/恢复数据。此轮恢复限定调试器清理与运行恢复；若需磁盘回滚或必须补新完整备份，先停止、保全差异并另申请具体动作，不直接拿历史备份覆盖当前状态。
4. root先记录本轮before dirty与文件hash，创建全新私有 execution目录，保留原证据。使用 MCP debug_attach_sim 精确PID、continueOnAttach=false、makeCurrent=false；返回session后所有工具显式绑定sessionId。仅读模块路径/UUID和精确symbol，唯一断点resolved且0hits后continue。失败就清理退出，未成功前不让Human arm。
5. 现场Ready只指pre-arm身份、工具、控件与授权齐备。真实freeze借用参数可读必须出口命中后现场核验，不能提前填成功。

## Human操作卡（实际执行时逐步下发）

- arm卡：收到root“断点已就绪、进程已恢复”后，空候选且松手至少2秒，点击“观测”一次。停手等待文字；回报实际显示文字。应显示“取证”，最多观察30秒；仍为“观测”或异常则停，不点第二次、不输入。记录实测时间；无秒表就NOT MEASURED，不造点击UTC。
- 输入卡：仅在上一回报合规后，只输入合成字母 n 一次，不选候选、不提交、不删除、不换键盘、不切AppSwitcher/Maps。回报候选是否更新；arm后有候选也应在松手>=2秒显示“取证”（与U0未arm隐藏政策不同）。异常/标题不符停止，不为补成功追加输入。
- freeze卡：root准备好读取后，点击“取证”一次并停手。断点命中时键盘短暂停顿是预期调试暂停，不追加点击、不以此认定输入故障。Human点击精确时间无法测得就留null，接收回报时间单列。整轮arm到freeze须在600秒TTL内；已到期就记Incomplete，不重新arm。

## 真实停点与复制合同

commands.json冻结命令模板，仅执行时替换本轮PID/session/breakpoint/address/byteCount。出口精确符号 $s8Keyboard25wakeOwnerProbeExportReadyyySV_SitF 必须唯一resolved且首次hit1；frame0、模块UUID及有限 thread backtrace -c 8 只记录函数/模块/地址/源码定位，不展开其他变量/参数内容。需可确认caller属于同候选 handleWakeOwnerProbeButton 中 words.withUnsafeBytes 的同步路径；无法辨识就记Hold，不偷偷继承旧轮caller限制为通过。

仅读静态局部参数 address/byteCount：raw-output、no-dynamic-values、no-synthetic、depth1；不EvaluateExpression、不调用目标方法、不猜x0/x1、不写寄存器/内存。参数不可读、停点非预期、地址为空/不对齐、byteCount非8倍数或不在176..11352，即停止读取并清理。

在仍停于同出口、借用未结束时只执行一次 binary memory read，恰好 byteCount 字节到私有 snapshot.bin，禁止读前后内存/全进程。复制完成立即remove自身断点、continue、detach，再离线解码；绝不在continue后复用旧地址。读取失败/字节不足不重读或拼接修补。单命令timeout<=30秒；root以停点开始计120秒有界工作预算，超限/不确定即终止采集并优先清理，不为了补caller或账本延长暂停。

## 账本、离线判读与 Exit

每个调用执行前写request UTC/单调时钟/参数，返回即写response UTC/elapsed/完整原始回执及SHA；Human操作回报与真实点击时间分开。不通过日志接收时间推精确borrow开始，也不把文件名时间当操作时间。ledger-template.json为未执行空模板，收尾需逐项核对调用次数、出口命中、读取长度、清理与终止时间；发生失败也交付账本，不留到以后补历史。

decoder.py字节原样复用已审v1离线decoder（SHA fc1817ab…），此次不运行测试或对旧snapshot冒充新采集。真实raw到手后才解码：magic/version、11word头/每行11word、count<=128、长度、run/process、序号/时间/TTL/enum、overflow/incomplete全核，所有记录保留，不去重、不补字段。header与synthetic armed owner0不能推owner为空；schedule的owner/receipt只证明记录点状态，不证明engine或host提交。当前正常路径目标是一次insert begin/schedule/end配对与链路可用，不规定必须恰好528字节或5行。

成功/失败均移除本session自身断点、continue、detach，确认工具running/detached；不可清理别的任务断点或改共享defaults。清理工具失败原样记并立即告知Human停手，不kill/relaunch代替退出；恢复异常需新具体授权。Human先只确认键盘界面恢复响应及实际标题，不追加试打。

Exit只读同候选/进程/两诊断原存在性和值；probe实例一次性frozen后保留，不重启清零、不rearm。历史I0/I1备份不删除；正常输入后无全data字节相等声明。artifact包括entry、机器身份、Human回报、ledger、所有工具raw回执、snapshot/hash、decoder/hash、所有decoded行、cleanup和exit，raw用户数据留private。

## 交付与权限边界

准备已完成；执行授权、fresh独占、当前PID/session/断点/真实参数/新导出均Pending或null，不是Ready或通过。无模拟器读取/操作、LLDB、arm、build/test/install/deploy、源码、Git发布。本次仅文档与既有decoder副本，不需CHANGELOG或架构合同改动。

下一步只申请上述U1单轮执行与该窗口独占。完成后如需独立验收，另给冻结证据/精准P1身份停点、P2raw完整性配对、P3borrow/清理账本范围与新预算；本准备不授权reviewer。Maps需新实例/独立Entry授权，不复用消费后的probe。原30skip与T29阶段残项决定不改，不扩到U1或Release；父子Active、根因未确认。
