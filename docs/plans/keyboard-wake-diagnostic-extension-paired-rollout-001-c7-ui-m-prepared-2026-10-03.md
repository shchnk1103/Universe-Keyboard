# M 阶段 Maps 单轮取证准备包 — 2026-10-03

状态 **Prepared / Not Ready**。Human仅授权本准备包；没有M0备份／进程退出、M1新实例与Maps操作、M2调试器／arm／导出执行授权。父子Assignment保持Active。root兼Coordinator、准备Executor和未来Environment Executor；Human是Product Authority及Manual Operator，Domain Owner沿Assignment为Keyboard Experience Maintainer。没有新独立reviewer lane或预算。

## 已确认事实与证据

- 唯一工作树paired-rollout-preflight/Universe Keyboard、分支codex/keyboard-wake-v3-compatibility-gate、HEAD84b9c19227330b0fe6ff391be001ee398010fd6a。准备前完整dirty状态保存在private；1279源／构建／Vendor hash输入与78本地候选文件逐字节核验无漂移。该核验不访问当前安装容器，不证明当前设备身份或健康。
- 固定候选43d85d612af6c606b5434dcb0a989e43e3c472bf6f296df3bd7c2fcb6220ba50；[H1配对产物](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-h1-artifacts/paired-products.json)拥有78文件、6MachO身份。appex UUID C3FC7115-4215-3801-ABBB-C8A648ED0C32，debug dylib UUID77BD18E2-E090-37D7-865F-84D762E69F70；未来以新鲜loaded路径+UUID核实，不借旧PID/session/地址。
- [U1R1运行独立意见](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u1r1-review-validation-2026-10-03.md)覆盖正常路径的身份、raw配对和真实borrow／cleanup链；[Product处置](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u1r1-delivery-correction-validation-2026-10-03.md)仅接受U1R1交付记录限制，原Partial不改，不外推M。正常5行／528bytes不是M预期条数。
- [C6历史观察](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c6-maps-validation-2026-10-01.md)：直接打开AppSwitcher再回Maps出现按键反馈但候选／宿主输入框不更新；切到系统设置再返回的路径伴键盘关闭重开、未复现。两变体共用旧窗口，不能绑定失败事件或证明owner为空。
- Probe每实例只arm一次，128行、600秒TTL。当前已消费实例不能rearm；M需要新扩展进程。probe不依赖诊断journal，本方案两项诊断保持关闭，不读取宿主或候选文本。

## 问题、最小实验及阶段依赖

目标是同一新实例、同一run中比较切换前后的两个受控insert attempt，在故障表征出现时核实schedule记录点owner／receipt。正常基线一次n，保留其候选与composition；只打开AppSwitcher并直接点回Maps卡片；返回后再一次n，停手并冻结。不切设置、不选候选／提交／删除，不用清候选换取按钮；armed状态有候选时也应松手至少2秒显示“取证”。两个合成输入不是独立复现轮，不自动retry。

| 阶段 | 拟申请范围 | Ready依赖与停止条件 |
|---|---|---|
| M0 当前保护与恢复准备 | fresh独占；Human关闭主App和Maps、收起键盘；只读唯一原设备／已装候选／进程核验。若精确旧Keyboard扩展仍存活，仅经该切片明确授权且复核PID+路径+SHA后一次SIGTERM；完整备份当前主App data、App Group、已装App及库存／偏好／签名，验证副本，写具体恢复方案。 | 独占、当前身份、完整可验证备份及静止窗口均须有本轮证据；SIGTERM失败不强杀。备份失败或数据不稳定停止。恢复只是Prepared，不执行重装、覆盖、部署。 |
| M1 新实例与Maps入口 | M0交付验收后另授权Human打开Maps空搜索框、叫出Universe Keyboard；新实例PID+安装78SHA+loaded路径/UUID+源输入核验，读部署状态／诊断键，完全访问只看。 | 只有新实例且初始“观测”可见、未arm、健康状态／部署与保护条件已核才进入M2。真实Maps版本、schema、布局、PID、prefs当前值等全部现场填写；旧记录不代当前。 |
| M2 单次Maps取证 | M1通过且另获明确LLDB附加／出口断点／单次arm、两次n、一次AppSwitcher直接返回、freeze、一次有限read与cleanup授权；使用[操作卡](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m-operation-cards-2026-10-03.md)。 | 一个明确人工窗口，run绑定、600秒TTL、进程与模块一致。正常基线失败、额外误触、键盘关闭重开、PID变化、按钮／停点异常即停止，不拼接新实例或重试。 |

M0需要新鲜完整快照；I0/I1及旧T备份保留，只是历史窗口，不能覆盖当前U0/U1输入后的词典。备份不覆盖系统完全访问、Keychain或Maps数据；这些保持不改。raw只存private chmod0700目录，repo仅内容无关hash／计数／状态；不要复制用户词条、宿主文字或完整日志。下一授权只建议M0，不把准备授权当执行授权。

## 取证链、停止与恢复

按现有U1R1实测方法：explicit PID attach、所有后续调用显式session；不改共享MCP defaults。debug_attach_sim回执UDID可能取共享profile标签，必须保留冲突，并用原设备下精确可执行路径、SHA、同session loaded原UDID路径与UUID判实际身份。任何真实路径冲突停止，不能靠标签解释放行。

出口符号唯一resolved、0hit时continue后才下发arm。freeze后只核frame0、有限backtrace -c8及静态address/byteCount，确认handleWakeOwnerProbeButton中的words.withUnsafeBytes同步borrow。byteCount须176..11352、8倍数，地址来自真实停点且非空／8对齐；只读一次恰好byteCount bytes。不猜历史地址／ABI寄存器，不expression、目标函数调用、写内存或全进程读取。停点工作预算120秒，各工具timeout<=30秒；从首次观测停点计时，实际target pause开始未知就保留UNKNOWN。超时／参数不可读／读取失败优先cleanup，不追加读取。

清理直接使用LLDB breakpoint delete OWN_ID，然后breakpoint list核自身断点不存在（保留其他任务断点），continue、detach。U1历史MCP remove的registry差异不再作为首选路径；不删除all断点。cleanup失败立即通知Human停手，不kill／relaunch代替清理。离线复用已核decoder字节，不修改，不拼接／修补snapshot。

成功／失败／未复现都交付真实原件账本：每个tool调用前request UTC/monotonic，后response/elapsed/raw回执及SHA；Human真实操作时刻不可测就null，回报接收时间另列，不能冒充点击时间。收尾核运行／detach、候选payload、源输入与两诊断原值及存在性；不声称全部data字节不变。先只问Human视觉Exit，额外试打或故障恢复另列授权，不用它覆盖冻结故障现场。

若需数据回滚：先保全after快照、列before/after逐路径差异及影响，再申请精确恢复切片。不可自动拿旧C7/I0覆盖当前候选／当前数据。现阶段不安装、不重新部署RIME、不恢复用户数据。

## 判读标准与非结论

| 证据形态 | 可以说什么 | 不能说什么 |
|---|---|---|
| Human基线正常、返回后目标症状；同process/run且协议未偏离 | 本轮目标变体被观察，两个attempt顺序可由操作卡和记录唯一绑定 | Human按键音／震动不证明insertKey或RIME收到输入 |
| 两个唯一非零attempt，各有一对insertBegin/end，coordinator/appearance有效且各attempt内部一致；buffer完整且无overflow | 两次Extension同步输入窗口可配对；appearance可跨切换递增，coordinator如改变按实际序号记录 | 不能强制两次coordinator／appearance相同掩盖replacement；buffer完整不是所有callback都被观察 |
| 返回后配对attempt内schedule的owner=0、receipt=0、coordinator非零 | 该次schedule记录点owner实际不存在，owner字段来自owner != nil | 不证明全过程owner为空、唯一根因、resume失败或修复方向；synthetic arm owner0不能使用 |
| 返回后schedule owner=1、receipt=0 | 记录点owner存在，但此accept未取得receipt | 不能据此直接判engine挂死或host错误 |
| 返回后schedule owner=1、receipt=1 | 调度记录点存在owner并得到accept receipt | receipt不证明engine完成、候选绘制或宿主接受 |
| 没有返回后begin/end或没有schedule | 当前链路未取得目标记录点证据，按覆盖缺口交付 | 缺事件不能判owner为空；controller/coordinator nil的UI owner0也不能代schedule owner0 |
| owner0只出现在suspend/teardown/resumeBegin；后续schedule owner1 | 只描述生命周期记录点，按顺序关联 | 不将正常过渡状态算故障owner为空 |
| 返回正常、PID换了、TTL到期、额外attempt或overflow／incomplete | 未复现或配对Incomplete/Hold，保留原件，零自动retry | 不将新进程、历史窗口或缺行补成完整故障链 |

每次attempt预期最多一个schedule；出现多条须逐条保留并解释，不能挑owner0。完整目标判读要求正好两个输入attempt、按协议唯一顺序及各自配对；若返回后input没到记录点，本轮仍可交付有价值的缺口，但owner判读必须未覆盖。生命周期缺少回调时不借event absence填host活跃状态。

## 交付、验收与授权边界

交付固定candidate、Maps/OS/schema/FullAccess状态、before/after库存、Human卡原话及偏离、全tool账本和raw、snapshot/hash、decoder/hash、所有行、attempt映射、cleanup/Exit与剩余依赖。所需[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m-entry-prepared-2026-10-03.md)当前现场项均UNKNOWN，不Ready。

后续独立验收另冻结新的有限scope/packet/预算，仅读本M窗口；U1R1的残项处置与reviewer预算不续用。原30skip与T29残项仍未验证，不传M或Release，不为计数差异重跑。现无源码改动／新构建测试／安装／Git发布／Maps运行／整体Gate或Release授权。该准备不需要CHANGELOG或ADR修改；若M产生可复用事实，再由对应owner更新DEBUGGING，而不是先写猜测规则。
