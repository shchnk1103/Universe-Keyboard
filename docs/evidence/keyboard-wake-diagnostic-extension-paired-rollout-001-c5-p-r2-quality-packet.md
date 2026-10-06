# QUALITY-C5-P frozen round2 packet

Work Item `KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001`；稳定lane `QUALITY-C5-P`；positive round2。唯一worktree `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard`；HEAD `84b9c19227330b0fe6ff391be001ee398010fd6a`，branch `codex/keyboard-wake-v3-compatibility-gate`；candidate `af38fac6758df45f6686ff00845a065157c6679fd57de8dcf015c0e9f283cbd9`。Human仅授权本轮Quality确认（4底层工具／300秒），不授权Product晋级/残项接受或C5-I/R。

输入manifest `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard/docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-p-r2-input-manifest.json`，SHA256 `56d6c3b4875712dee712ef93c7e691fd0bf905cbdfd555b96539bed006e34f15`；Entry `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard/docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-p-r2-entry.md`，SHA256 `f4ce5e922d70f15ff0c3de011cbe007b57a528b4379e9e004dc11b8dfffbc282`；本packet digest由派发消息绑定，不自引用。原Quality round1报告/usage保持原样，610.087秒超时Partial历史有效，不追认其程序性Pass。本轮是独立新确认，不修改旧verdict。

## Decision / complete positive coverage

D1：新packet/manifest/Entry/当前Assignment、HEAD/branch、568源及111Debug文件身份匹配，旧C4及本lane结果可复用到该精确候选。原manifest中旧AssignmentSHA是历史review字节，当前bookkeeping由新manifest绑定；不要把这种已解释记录变更当source漂移。
D2：依据本人round1已完成的P-Q1/Q2/Q3证据和必要既有源片段，重新明确三个正向coverage结论与残项：30skip仍未验证，C4accept不carry到C5；11Mach-O安装后身份及FullAccess/AppGroup/RIME/宿主仍需futureEntry；一次回调和reader语义限制、隐私恢复/无重试、duplicate-member残项保留。不展开新根因/host/实现研究。
D3：在本轮实际预算内明确本lane最终确认；区分“本scope独立review完成”与ProductC5晋级/skip决定及C5-I/R授权仍未完成。每个D必须正向证据/位置，未覆盖或超时均Partial，不以noBlocker代完整覆盖。

## Allowed reads/writes/tools/access/data

只读manifest列明文件（47项文档/关键源、568source/build输入、111指定bundle文件），以及manifest/Entry/本packet。源码仅核验旧证据必要边界；不要新遍历文档或猜路径，不读未列另一reviewer输出，不读日志/用户数据。仅写scratch `/private/tmp/ukey-wake-c5-p-r2-20261001/quality-review-r2.md`、`quality-usage-r2.json`，为精确计时可写 `/private/tmp/ukey-wake-c5-p-r2-20261001/timer.json`。不得写仓库/产物。无网络、无device/Simulator发现或UI/容器访问、无build/test/install/launch/arm/input/Maps/source/Git mutation。

## Exact budget / checkpoint / stop

最多**4底层工具调用、300秒**，从首次packet审查调用开始，包含packet读取/hash及最终输出写入。首次exec_command内用Python datetime+monotonic立即记timer.json，然后读packet/hash；核对身份后向rootACK。wrapper与协作消息不算底层工具但其耗时计墙钟。第二底层调用完成后立即checkpoint，必须保留至少一次输出写入工具；每次调用记录起止UTC，最终写入后不得再调工具。建议第1调用packet+manifest+Entry读取/hash，第2调用本地hash/既有报告与计划批量读取，第3仅必要call-path核查，第4写输出；可少于4。禁止用第4次写完后再调用clock或ls验证造成第5次。墙钟接近270秒立即写Partial/输出，不占满300秒。

timer能精确记录ACK时间则记录，若未单独读取clock则声明ACK在首次核验之后，packet审查时间已计入；不要漏初读耗时或将tool自身运行时间代elapsed。每个functions.exec内exec_command/clock等嵌套工具分别算底层调用，wrapper/message单列。不新增timer clock tool。预算耗尽/身份漂移/证据missing/权限或scope未知立即Hold/Partial，root或reviewer不能扩轮次、scope或budget，只有Human Product Lead有权另行决定。

## Outputs

中文report：精确identity；D1/D2/D3矩阵；P-Q1/Q2/Q3证据复用及边界；findings/残项owner；严格本轮verdict。usageJSON：lane/round、三摘要、timer始末实际elapsed、底层调用账本、checkpoint、预算内/超限、未执行动作；保留原轮Partial。即使本轮确认完成，也不得宣称整体QualityPass/ProductGate/ReleaseGate、设备/安装/callback已通过或30skip已接受。
