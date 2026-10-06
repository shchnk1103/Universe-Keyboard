# F2 actor测试修正接收及定点复验停止交付 — 2026-10-04

Human授权root继续定点复验并确认独占，随后明确关闭App并授权原扩展一次正常SIGTERM。root核对PID25428、启动时间与精确旧安装路径后发送一次SIGTERM；未处理其他进程。

## 源码接收

新测试文件SHA-256 `b4e8c6c1fdb79dc9f27ff3355e705a0dae0f45a07f9fb4610a51e43a7256b8bf`符合；内存反向替换两行得到原冻结`e9ef614702dff163ea1f1723e577f2f5af97394c919fb7d03544e15356d3c1a3`，差量+23 bytes。其余四文件hash、branch/HEAD与staged0符合。Grok format/lint及7调用仍按Human转交作者报告记录，root未冒称重跑。未编译，不能认定7actor诊断消失。

## 当前停止点

原UDID405D994F-28CB-4F89-BB22-B64AD81C05A2现场为iPhone18Pro/iOS27.0 Booted。1156构建输入文件hash符合原F2清单，唯一授权测试差量已替换绑定。隔离运行根 `/private/tmp/ukey-host-activation-fix-f2-actor-retest-20261004`；新鲜三组完整复制位于其`before-backup`，未覆盖历史备份。

备份脚本exit1：复制后的既有`com.apple.provenance`发生改写，超出原校验只允许新增provenance的条件。遵守首失败停止，测试0次，未自动重试或恢复。随后只读分类：903处新增、122处改写、0缺失；除该属性外，内容hash、大小、结构、mode、uid/gid及其他xattrs全部一致；源三次完整库存相等，主App/appex备份严格签名均exit0。不声称全部metadata精确相等，未签发备份通过回执。

[分类回执](keyboard-wake-host-activation-fix-001-f2-actor-retest-artifacts/backup-difference-classification.json)、[停止回执](keyboard-wake-host-activation-fix-001-f2-actor-retest-artifacts/STOP.json)、[冻结命令与授权范围](keyboard-wake-host-activation-fix-001-f2-actor-retest-artifacts/execution-entry.json)。源/副本完整库存与差异原件保留在私有运行根，不将用户数据入仓。

当前Hold等待Product决定：是否仅本轮接受provenance新增/改写为明确metadata例外，复核同一备份及live静默稳定后继续一次冻结focused测试。不得自动放宽至其他差异；F2旧skip处置不扩大，F3/F4未授权；修复仍Blocked，7actor诊断效果待验证。无源码修改、安装、测试、LLDB、Maps、Git暂存/提交/推送或备份删除；原设备独占未释放。

## Human例外处置及一次复验完成 — 2026-10-04

Human回复“同意”，仅本轮接受上述provenance例外。原停止回执保留，不删除、不冒称首次备份全metadata相同。复核同一备份未改，原设备静默，live两次库存与原before完整相等；签名通过、1156输入符合。由[新备份接受回执](keyboard-wake-host-activation-fix-001-f2-actor-retest-artifacts/backup-accepted-receipt.json)解除该备份Hold。

### 实际验证结果

2026-10-04 22:40:05–22:40:43 Asia/Shanghai执行冻结focused命令一次，38.18秒，exit0，未超60分钟自限。独立DerivedData，无增量旧缓存替代；原UDID、Swift6.0/complete/no suppression/warnings-as-errors与parallel-testing NO均绑定。[命令与运行回执](keyboard-wake-host-activation-fix-001-f2-actor-retest-artifacts/focused-receipt.json)。

- root严格lint exit0；untracked no-index白空格exit1无diagnostics，符合差异语义；未in-place format或改源码。
- [xcresult summary](keyboard-wake-host-activation-fix-001-f2-actor-retest-artifacts/gate-summary.json)及[17项实际列表](keyboard-wake-host-activation-fix-001-f2-actor-retest-artifacts/gate-actual-results.json)均为17 Passed / 0 Failed / 0 Skipped，方法与当前17 authored方法精确匹配。
- [编译诊断及覆盖核验](keyboard-wake-host-activation-fix-001-f2-actor-retest-artifacts/diagnostic-and-gate-verification.json)证明新测试文件实际SwiftCompile；gate/current/foreign/resumeCount/rearmCount/firstFrameCount/suspendCount七条原诊断逐项为0，当前测试文件warning/error为0，日志actor相关诊断为0。
- 完整编译日志 (`keyboard-wake-host-activation-fix-001-f2-actor-retest-artifacts/focused.log`)仍有4条AppIntents metadata extraction skipped工具警告，与原七条actor诊断不同。不声称全日志zero-warning。
- 1156输入执行后hash不变；其余四实施文件保留，唯一测试文件为`b4e8c6c1fdb79dc9f27ff3355e705a0dae0f45a07f9fb4610a51e43a7256b8bf`。

### 环境Exit

[两次after读回](keyboard-wake-host-activation-fix-001-f2-actor-retest-artifacts/environment-after-receipt.json)稳定，目标App/appex进程为空；[before/after完整库存对照](keyboard-wake-host-activation-fix-001-f2-actor-retest-artifacts/before-after-delta.json)证明三组完整相等（包括xattrs），无新增/删除/改动。因此本轮无需恢复，未执行恢复或再部署；本轮并未将修复候选安装到原键盘运行现场。旧版本机器身份及已部署RIME保留，两诊断键ABSENT，deployed=true、needs_deploy=false；不重复冒称新输入健康确认或Maps验证。

### 影响分析及后续权限

七条测试actor诊断Hold由本次实际编译与17项复验解除；不是独立Quality结论。生命周期恢复Active，下一F3精确实现与Quality独立审查另授权；F4候选安装/真实通知/Maps仍另授权。

与原F2相比只变fixture setUp两行，17断言不变，生产四文件及1156输入其余条目不变。旧F2完整矩阵、30skip仅F2精确处置和测试边界继续作为对应原候选历史证据，向F3提供本次差量影响分析，不把旧448完整套件或Release build冒称对新测试字节重跑。此次仅focused验证，非完整CI等价、非发布门禁、非真实通知/appex接线或Maps修复证明。

新鲜before三组、历史before/after/restore、F2与本次xcresult/DerivedData均保留；未删除、暂存、提交、推送、Release，未启LLDB/Maps或新采集。独占未释放。私有运行根保留，不将容器内容/完整xattrs库存或用户数据入仓；仓库只存有界机器回执和测试构建日志。[原件manifest](keyboard-wake-host-activation-fix-001-f2-actor-retest-artifacts/manifest.json)。
