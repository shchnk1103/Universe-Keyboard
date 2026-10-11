# OWN-EXPORT-001 真正 owner 缓冲有界导出 Entry

**Prepared，未 Ready、未授权执行。** Human 本轮仅授权准备。root 继续 Coordinator／Environment Executor／治理 writer，Grok 保留唯一生产源码 writer；独立运行验收拟复用原 Quality Luna，实际派发另冻结对象与新预算，不继承 AP-META-004 的残项接受。本轮不启动调试器、查询设备或写实施脚本。

## 目的与现有事实

只补新候选在一次 Maps 直接 App 切换器返回前后的 owner/receipt 观测缓冲与 attempt 对应关系。AP-META-004 已证明实际出口 callback 与同停点身份，阶段收件闭合；不再另做一轮 metadata-only 取证。旧 F4-M 人工返回后输入正常但无 snapshot；旧 M2R2 的失败 schedule owner/receipt 缺失不是新候选证据，不拼接样本。

原诊断父任务 KEYBOARD-WAKE-LIFECYCLE-DIAGNOSTICS-001 已在 2026-10-04 按有界诊断合同 Completed；paired-rollout 及本修复仍 Active。整体“修复完成”所需真实通知／恢复覆盖，不由单一 owner snapshot 自动满足。

## 冻结身份与工具来源

- 工作树 `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard`，分支 `codex/keyboard-wake-v3-compatibility-gate`，HEAD `84b9c19227330b0fe6ff391be001ee398010fd6a`，staged 0；大量既有 dirty 保留。
- F4-P 的 1156 行源码／App／Vendor、78 个候选 payload 本轮逐字节核验一致。源清单、pair 四模块身份及工具逐文件 SHA 在 [prepared-binding](keyboard-wake-host-activation-fix-001-owner-export-prepared-artifacts/prepared-binding.json)。不重新构建、测试、安装或部署。
- 唯一未来目标 iPhone 18 Pro／iOS 27.0，UDID `405D994F-28CB-4F89-BB22-B64AD81C05A2`。候选路径 `/private/tmp/ukey-host-activation-fix-f4-p-build-20261005/CandidateDerivedData/Build/Products/Debug-iphonesimulator/Universe Keyboard.app`；debug UUID `4B207746-89A7-321F-83C4-91477259BB26`，SHA `773c4eff9640b2623036e3f819301ead3914cb99b66c9c1496ece5986e762aab`；出口 `$s8Keyboard25wakeOwnerProbeExportReadyyySV_SitF`。
- 用 AP-META-004 callback 的 actual hit-frame 身份检查和逐项 pre-click 检查；旧 F4-M 参数提取／decoder 仅来源模板。旧 PID、PC、断点 ID、输出路径绝不可直接复用。
- 新运行根仅 AUTH 后创建 `/private/tmp/ukey-host-activation-fix-owner-export-20261006`，若已存在停止，不覆盖。私有输出权限 0700；缓冲二进制／参数原值 0600，公开回执只报大小、SHA、固定字段、成功或固定错误类别，不复制指针值。

## E0：主机准备与硬性预检（执行授权后，设备操作之前）

在新私有目录生成适配脚本，生产源码不动。回调将身份核验、静态参数解析及最多一次 ReadMemory 合并在同一停点，先落盘阶段计数／时间再读取。输出失败也不得重读。私有脚本支持保守 deadline 和失败留痕，不导入 target 模块／执行 target expression。

主机预检须覆盖：身份不符或多 hit 则 0 次读；指针无效／参数不可用／长度越界则 0 次读；一次 exact-size 成功；短读或 SBError 失败则不重试；输出失败不重读；停止 deadline；decoder 严格拒绝不完整、越界及错误 header。用 fake API 和固定非用户二进制 fixture，不能用模拟器样本冒充 host 测试。既有 decoder 源保持，失败停止、不修改格式协议。参数是否在真实 Swift frame 可得仍是 E1 的运行依赖，不提前声称通过。

LLDB 默认停点 formatter 改为仅固定线程／PC／停因的格式，不打印 frame 参数；本轮明确授权的 address/count 静态解析仅写私有回执。若无法抑制默认参数显示，预检停止交回，不继承旧范围偏差接受。E0 脚本、预检结果及实际冻结 SHA 齐后才能进入 E1，Prepared 文档本身不替代此检查。

## E1：一轮运行 Entry 与人工步骤

执行前需要新鲜 Human 独占到 Exit、上轮后打开／安装／部署情况，以及静默的新实例起点。Human 关闭 Maps／主 App 回主屏，两项诊断保持关闭；root 核现场设备、唯一精确安装 78 字节、四模块和部署状态、实际进程路径／start。主 App 未退出则请 Human 关闭。旧 appex 若存活，仅在本轮明确授权核实 PID/start/path 后一次正常 SIGTERM；不强杀、不终止其他进程。

读取并保存诊断三个原键值／存在性，保持原值，不开日志／高保真、不改其他偏好。本轮只用内存 probe，真实系统通知日志覆盖不在此切片。无安装和数据覆盖，因此不新增整包／data 大备份；所有已有恢复保护保持，不能删除。

1. Human 进入 Maps 空搜索框，叫出 Universe Keyboard，确认完全访问开、候选空、“观测”出现；不要提前点或输入。
2. root 核新 PID/start/path、已加载 debug UUID、出口唯一 location/hit0、新 attach StopID，短 command source 注册 callback，并读回实际函数名；continue 返回后保存新 pre-arm LLDB 状态及 ps 原值并逐项 PASS。
3. Human 只点一次“观测”，确认“取证”。只输入一次合成 `n`，报告按键反馈／候选／输入框变化，等“取证”可见，不提交或清空候选。
4. Human 只打开 App 切换器然后直接回同一 Maps，不切设置或其他 App；报告键盘是否关闭重开、候选和输入框变化。发生关闭重开则本轮不证明目标返回场景，停止人工输入并清理，不自动重试。
5. Human 只输入一次合成 `h`，报告按键反馈／新候选和输入框变化，停手。失败同样可取证，不重复按键、删除、提交或切 App。
6. root 新 pre-freeze LLDB／ps 原值检查 PASS、hit0／callback0，再请 Human 只点一次“取证”。随后不操作，短暂停顿为 debugger stop；root 一次有界复制并立即清理。
7. root 删除本轮唯一断点并确认列表空、detach、单独 quit、核原 PID 非 traced 及本 session debugserver 退出，诊断原值／存在性不变两读。Human 只做视觉 Exit，再关闭两 App 收起键盘；不追加试打／提交。

## 同停点读取合同

只使用 callback 传入的 frame／bp_loc，要求 PID、新 StopID、线程、frame0、PC==locationPC==本轮配置PC、UUID、mangled、stop reason 与断点 pair 一致；callback/hit 各恰好 1，最多 8 个 caller 名须含按钮 handler 及同步 `withUnsafeBytes`。不切换线程或找替代 frame。

在全部身份和 borrow 检查通过后，用 `FindVariable(..., eNoDynamicValues).GetNonSyntheticValue()` 静态提取 `address._rawValue` 和 `byteCount._value`。参数无效停止，不猜寄存器或 ABI，不执行 expression，不取对象描述。指针非零且 8 对齐，长度 176..11352 且是 8 的倍数，指针加长度无地址空间溢出。最多一次 `SBProcess.ReadMemory(address, byteCount, error)`；请求前记 attempted=1，请求后必须 SBError 成功且返回长度完全一致。短读／失败／超时均为 unavailable，不读取 header 再读 payload，不续读、不重读、不保留裸指针供恢复运行后使用。

11352 = (11 + 128×11)×8；11-word header 与 11-word row、magic KWOPROBE、v1、10分钟TTL 是当前冻结源码合同。只复制该地址范围的内容无关整数记录。callback 在同步 borrow 活着时将 bytes 留在 debugger-side 并私有落盘，恢复运行之后才离线解码；不得在 detach 后按旧地址读。

decoder 须核 exact-size、版本、run/process 标识、count≤128、sequence／timestamp／TTL／enum、incomplete／overflow，并拒绝 trailing bytes。完整性或 attempt begin/end/coordinator/appearance 对应不足，记 inconclusive；合成 armed 首行 owner=0 不代表故障。比较同 snapshot 的前后 input attempt schedule owner/receipt/epoch/revision，不能把普通 baseline owner=0 强判 bug，不能把 receipt 当引擎提交完成证明。真实通知／全部恢复原因未由这些整数直接记录，保持未验证。

## 预算、停止与交付

提案仅本轮 E0+E1 合计 **60 actual tool calls／60分钟**，wrapper、nested、人工请求均计数；E0 建议≤12调用，48前停止增加非清理动作，至少12调用留清理与归档。一次 runtime attempt、一 arm、一 freeze、最多一次 memory read，不自动第二轮。命中起 debugger 停点≤120秒，单工具 wait≤30秒；身份／配置／参数／预检首失败、意外命中或新增 scope 立即停并收尾。UTC和monotonic在 attach／命中／read尝试／断点删除／detach请求与返回／quit／machine Exit 持久化；人工 recorded_utc 只称收到确认时间。

交付 source→pair→installed→loaded 身份链、callback和参数判定、单读计数／size／SHA、私有 binary／offline decode、同run attempt对应、Human合成步骤、清理／诊断原值、逐调用账本与实际 wall。原证据不拼接、不修补，不因一次 UI 正常就宣告修复完成。

独立验收另冻结本轮对象，仅查缓冲身份／完整性、前后 attempt、结论及 Exit；不重审已通过静态 gate／pair 四路径，不自动重复取证。Product 原阶段接受不继承本轮。父诊断 Completed 保持，paired-rollout 与修复 Active；本 Entry 不授权 Git、Release、真机、部署、源码、安装／恢复、清备份或新日志采集。
