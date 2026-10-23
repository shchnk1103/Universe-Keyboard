# UI4-SPIKE-001 — 结果摘要与外置证据清单

**指针与摘要，不是产品决定。** 2026-10-23 Asia/Shanghai；Human 已接受报告声明范围内的结论，未实现 UI-4。Spike 的 Close 在承载记录的 PR 合并时生效，见 [Assignment](../assignments/ui4-spike-001.md)。

## 阅读规则与适用范围

最终报告须与补充 1、2、3 同读；后续更正优先，原件保留。本文转录既有证据，不重跑实验；证据类别与核验等级分别列示。
模拟器：UI4 Spike iPhone 13 Pro / iOS 27.0（Executor 记录）；真机：Human 提供的一台 iPhone 13 Pro / iOS 27.0.1。仅该设备、系统与该轮样本，不能外推平台保证。
早期真机安装提交是报告记载的 `952489bf09c986ddd1c186704c123a07d2c06e74`；F 仅有 af0b29b 变体线索，缺精确安装提交、机型与系统核验照片。磁盘 HEAD 不等于安装身份。

## 结论表

| 结论 | 证据类别 | 适用范围与指针（相对外置 Spike 根） | 证据等级 |
|---|---|---|---|
| 宿主没有在计入样本中压低请求高，含横屏 542pt；不是所有宿主不限高 | 日志 | 该模拟器、信息宿主、26 键：第64行 45/254/254/390，第77行117/542/542/390，第78行117/542/542/694，第86行81/398/398/694（行高/请求/实际/宽度）；均为该轮单条测量。`evidence/ui4-observations-r2.jsonl`、结果表 | Quality-reverified |
| 123 / 符号 / 表情及 Safari / 提醒事项计入样本请求=实际=398 | 日志 | 同一模拟器，行高81、宽390；日志101/103/105/111/119；宿主标签不能证明具体焦点位置。不是九键测量 | Quality-reverified |
| 横屏63完整，81与117被截断；81的q–p行完整可见，其上方区域被裁；117的候选栏区域和q–p行均不在画面内 | Human 目测、照片 | 该模拟器信息场景三张横屏照片；按补充3精确拆分。63没有宽694的可信实高日志；不能推导81安全或产品上限 | Executor-recorded |
| 竖屏117请求/实际542来自日志77；名为“竖屏大行高”的旧图实际45/254/254，不能作117图证 | 日志、照片 | 该模拟器单次样本；补充3第2节；本轮补测没有竖屏117截图 | Executor-recorded |
| 调节态遮罩接到三次点按，终态输入框无新字；不能证明所有输入路径均无提交 | 日志、照片、Human 目测 | 模拟器信息宿主该轮：日志88进入，91/93/95 overlayTap 1/2/3且adjusting=true，96取消；调节页照片与Human观察。rejectedOperations=0不是拦截成功标准 | Quality-reverified |
| 完全访问关/开：主App写后读回均成功；appRead=true、suiteHeight=hit、extWrite=true；主App读键盘分别未读到/已读到 | 照片 | 真机单机、单系统、单次安装，按清单在备忘录唤起键盘；十张device照片。appRead仅表示键存在，不证明值刚更新；row仍45，未采用主App滑杆72/90；不是平台保证 | Quality-reverified |
| 自有存储ownPrev在再次出现、划掉宿主后再出现均true（开/关）；关的首次为false；ownWrite被挡住、未测 | 照片 | 同一真机、同一轮；划掉宿主不证明扩展进程回收。模拟器共享存储不作结论 | Quality-reverified |
| 隐形输入框加哨兵：完全访问关/开两组照片均见调节遮罩；可见框关组一次无罩，原因UNKNOWN | 照片、UNKNOWN | F：关隐形01–05、07；开隐形01–04；关可见01–03。两组02已带罩，不能排除残留或证明本次自动触发；开可见全组、开隐形删除等NOT RUN | Quality-reverified |
| F两组字母前后读数同为一致“是”/0，03/04分别字节重复；关组删除05为独立文件且读数相同 | 照片、Human 目测 | Human后来说明按提示点字母三次后无可见变化（补充2第5节、评审口述）；口述不等于两次独立拍摄，不证明瞬时/候选/异步路径。关隐形07无罩不证明同进程复位 | Quality-reverified |
| 进入调节先放弃未提交拼音；字母及候选消失 | 代码核查、Human 目测 | 实验代码abandonCompositionForVisibilityChange与模拟器旧清单D一次目测；不是正式产品行为决定。最终报告、补充1及r15 | Quality-reverified |
| 调节控件须先于按键扩大触控范围接到点击 | 代码核查、Human 目测 | 模拟器横屏117曾点下沿按钮却命中按键；后加点击层按整个controls.frame命中，含空隙，非逐按钮矩形；未补真机点击验证。补充2第2节 | Quality-reverified |
| 哨兵没有稳定退出协议；取消/确定后条件仍满足可能重入，页面离开/上下文改变无调节复位路径 | 代码核查、推断 | af0b29b探针、r15、补充1；0.5秒Timer在window有效且未blocked时比较光标前上下文；可能重入是代码推断，不是已拍到的过程。隐形控件仍真实可编辑 | Quality-reverified |
| 九宫格空闲请求/实际254有真机照片；组字态288未测 | 照片、UNKNOWN | 同一真机六张device键盘照片；模拟器九键因RIME部署失败跳过。254/288正式请求公式见[数值索引](../KEYBOARD_VALUES.md)，不等于全部场景实授合同 | Quality-reverified |

等级指本项既有核验来源：Quality R3核验了有限证据与报告的一致性；补充3的图片更正仍仅Executor-recorded。Human操作本身是Device-attested来源，不因转录成为本轮设备复测。

## Human 的产品方向决定

仅记录 Human Product Owner 于2026-10-23 Asia/Shanghai的决定，**不是Spike结论，没有实现**（来源：补充1、接受记录及本次Closeout Assignment）。

- v1由主App管理调节入口，键盘里暂不放入口；调节页不出现用户可输入的文字区域。
- 完全访问开/关都允许调节；完全访问仅作建议提醒，不作门槛。
- 存储方案一：只存一个以pt为单位的行高，按当前方向夹低显示，不把夹低后的值写回。
- 横竖屏分别按屏高比例限制整块键盘总高，路径栏等额外部分计入；比例未定，竖屏约50%、横屏约65%仅为候选。
- v1不按设备自动计算默认高度。
- 下一次TestFlight打算在UI-4完成之后发布；无日期、无候选构建，不是发布许可。

## 仍然 UNKNOWN / 没有证明

- 第二设备/系统、更小更大模拟器、真机26键横屏、九键组字态及Sticky/跨行键/触控/可访问性完整覆盖。
- 横屏63可信实高日志；宿主压缩时Effective Row Height、布局与输入可用性；候选比例的安全性。
- F精确安装身份、进入前状态与连续触发过程、稳定退出/同进程复位、所有候选/marked text/异步输入无提交。
- 共享权限的平台合同；主App保存→扩展采用行高的端到端链路；完全访问开关两态下新存储方案及方向夹低不写回。
- 原始报告与补充记录的编译/lint不是设备运行、产品、Quality整体无条件Pass或Release证据；本次不重跑。

## 给 Product Decision 的输入与待决问题

已有输入：正式默认行高45、候选栏46，254=2+46+4×45+2×8+10+0，路径0/34对应请求254/288；路径Sticky不是每次清组字即折叠。总高/按键行请求750、候选/路径固定栏1000；源码与细节见[数值索引](../KEYBOARD_VALUES.md)及补充2第4节。请求=实际样本没有回答被压缩时的表现。
主App已有静态缩略图，没有与Extension联动的实时预览。原比较的成本高低、路径长短、范围排除均为推断/历史建议，未做等价成本测量，不取代Human决定。

- 比例具体值、屏高口径、总高计入项及宿主压缩后的有效行高规则如何定？
- 进入调节能否丢未提交拼音，还是必须保留/恢复？
- 完全访问建议提醒放哪里、何时出现、依据何种可证明状态？主App没有live Extension完全访问检测原语。
- 确定/取消、离页、切App/键盘/宿主及上下文变化各自要求如何退出，怎样避免哨兵重入并验证同进程复位？
- 保存精度、取整规则与36pt实验下限如何定；触控、误触、VoiceOver/Dynamic Type需要什么证据？
- 正式快照viewDidLoad刷新，返回已有键盘才在viewDidAppear刷新，首次布局在viewWillAppear；如何保证下次出现采用主App值且不先默认再跳变？探针读自有行高不证明正式链路。
- 拖动随手请求还是松手/确定再请求、静态缩略图是否复用、确定后是否试打、是否提示当前可达上限？均待产品决定，不在本文定实现。

## 评审记录

路径均相对Spike根，SHA-256见下清单。

| lane/轮次 | 结论 | 条件、停止与处置 |
|---|---|---|
| Architecture R1 | Pass with conditions | F01决策输入、F02点击层措辞、F03静态预览/成本比较；R2复核关闭。首次写权限停止后经Human恢复；命令allowlist偏差和精确计时缺口保留为历史披露 |
| Architecture R2 | Pass | F01–F03已关闭，无新增残项；仅技术主张与决策输入文档审查 |
| Quality R1 | Partial | 旧device-build-notes索引摘要过期即停止，余项Uncovered；补充2更正，R3核验为已解释的历史索引问题，不回写R1 |
| Quality R2 | Partial | 要求复算94行索引却禁止读取其中Architecture报告，包内权限冲突而停止；R3明确排除该行后继续，R2不回写 |
| Quality R3 | Pass with conditions | U4S-Q3-F01裁切对象、U4S-Q3-N01旧竖屏图用途；补充3已作Executor更正，Human在已披露边界下接受；不升级为无条件Pass |

Quality R1、R2停止由Coordinator评审包设计造成（停止条件过粗、要求与允许集冲突），不是Reviewer失误。**补充3没有经过独立复核**；接受记录披露只有Coordinator机械核对及亲看两图。两个Reviewer为不同新会话，和Codex Executor同厂商不同会话；报告自述记忆影响与独立性边界，不宣称完全盲审。

## 外置证据清单

证据保存在Human本机 `~/.kos-work/Universe-Keyboard/UI4-SPIKE-001/`，**不在仓库，是否另行备份由Human决定**。以下摘要由Closeout Executor对当前原始字节复算；不表示重新执行实验。旧索引的device-build-notes摘要已由补充2更正，使用下列现值。

| 名称（相对Spike根） | SHA-256 | 类别 |
|---|---|---|
| `instructions/assignment-final.md` | `88b843f669cdbaedcc037898ad3b99f45169bb0f01bcd22b25c4f6c1ca63992f` | 原Assignment |
| `reports/executor-report-final.md` | `bce6eac3e2161835da59a461baa52044568689dd046e4f25c22c27e080387565` | 最终报告 |
| `reports/executor-report-final-addendum-1.md` | `c4565efe07da63abc6fe57128fa7c6caab52ad9dca20f360c70f964a8d757482` | 补充1 |
| `reports/executor-report-final-addendum-2.md` | `d3a84c8b3c4bde14c61496dc3ec63e4bd0e1e5f51b05587272fc38f7f4ee3a47` | 补充2 |
| `reports/executor-report-final-addendum-3.md` | `1a2ac4173de138af07fd496944a4b735fe4ab5af3a19db3163b86787dbc32167` | 补充3 |
| `reports/review-architecture-r1.md` | `bf2e6a76ec8cf9e2e7c7ddd98885966b9d7cbf9ab8c41886ccad9e7a232f1d8c` | Architecture R1 |
| `reports/review-architecture-r2.md` | `5404fbf02ceec563d5f2c23b94f1ab19f6398d776180b5108d09a936b2815c88` | Architecture R2 |
| `reports/review-quality-r1.md` | `65272ca8e82faa656f6428528865fdecd3496382b0481e9707b0e7beda17db76` | Quality R1 |
| `reports/review-quality-r2.md` | `c02bd83657ce50ee8738b0e79042af27fc91d73848cca0e49fc512744da4306a` | Quality R2 |
| `reports/review-quality-r3.md` | `1bec8cb2a17697dd16077f54f67ec5e5eee3f8757a0de6ebe803f96f14c4e02e` | Quality R3 |
| `reports/human-acceptance-2026-10-23.md` | `e10347b2c2e623a87ac047948adbcbdfbac99294fea7821756080b9abc7b08fb` | Human接受 |
| `reports/executor-report-r11.md` | `d5a463955f5dc7577de46c8d1bce16ae1e8b98af2327db145732c3c6663954f8` | 阶段报告 |
| `reports/executor-report-r13.md` | `43a186f0ea9e11b70e31677ff9803f75da390930275c27a0369200b28e047382` | 阶段报告 |
| `reports/executor-report-r15.md` | `ee535fba4084de32d4052074e15c4ac850d0317c0ae083b62bbdc7d94765b5be` | 阶段报告 |
| `reports/executor-report-r16.md` | `275ea2c482bf21de20d03ccd060be46e04fc7442bdf999c545fb9a6d988d0e08` | 阶段报告 |
| `evidence/ui4-observations-r2.jsonl` | `40172732f19f2d8ffc112c64be485dc2e8730906ec37f3051d37e7054bb06564` | 日志 |
| `evidence/measurements-r2.csv` | `98867d2310c301c26dfdc44f6dc3aea8a63ad9a81ec8f8e907ab1d4420b5f0ab` | 结果表 |
| `evidence/device-checklist.md` | `84b4cafe9130887c0c08f64adb392623ba3aa566939b3d63f8f94f17d3cadc53` | 真机清单与结果 |
| `evidence/device-checklist-f.md` | `d39773b2163df7e382f62507fbb4144804fd0efb6f5860527c5758accc540e5a` | F清单与结果 |
| `evidence/device-build-notes.md` | `61f92e5258e1d16f8d8a37896d55696873b14d22a098088391aa3113f8071918` | 构建说明（更正现值） |
| `evidence/human-observations.md` | `bdd966fc99256d9107d0d969ff31eca309739cc92164df13ae8d2c7875c1e11d` | Human观察 |
| `evidence/design-comparison.md` | `73e94201f2163f465f39a9b2bbbdb3a76de0519bcbed07b44bcdfc562a17429d` | 历史比较，须同读补充2/3 |

照片目录：`evidence/screenshots/`；清单见补充2第6节，不逐张入库。更多历史构建/采集文件亦见该节；上表是关键文件清单，不声称完整复制全部外置索引。

失效/重核条件：来源字节变化、设备/系统/宿主改变、正式代码/存储/退出协议实施或Human决定变化。原始证据仍是核查入口，摘要不授予开发、merge、TestFlight或Release权限。
