# 宿主激活恢复状态合同补充稿 — 2026-10-04

**Prepared / author proposal only，未独立复审、未授权实施。** 针对Architecture R1 D2 Blocker/Major和D3接线约束，只补设计；原五文件proposal和R1输入字节不改，以下作为下一轮必需补充，不是已运行事实。

## 内存状态与事件身份

Gate保持MainActor隔离，只存UI生命周期决策：当前presentationGeneration、phase（hidden/appearing/visible）、当前extensionContext identity、pendingHostSuspend（generation/context/挂起时runtime是否已激活）、firstFrameRearmPending。generation是仅内存的presentation标识，不写diagnostic wire、不成为新的日志operation ID。Core canary业务状态不复制进gate；UI调用处按当前Core状态传入一次性的恢复权限判定。

host notification必须匹配当前NSExtensionContext；缺失/foreign context不产生挂起或恢复决策。两通知成对使用同一过滤策略，不能只过滤active而把foreign resign记成当前pending。匹配规则不fallback到全进程UIApplication通知；实际系统object/投递适配在运行阶段确认，若不吻合不得在实施时静默放宽。

## 事件—状态—副作用表（MainActor同步序列）

| 事件与前置条件 | 状态变化 | 副作用及验收 |
|---|---|---|
| viewWillAppear，新展示 | generation更新，phase=appearing，旧pending/rearm失效 | 走正常appearance初始化/既有恢复路径，但共享resume同样先判canary权限；不消费旧展示的host恢复请求。 |
| viewDidAppear且窗口存在 | phase=visible | 首次尚未激活runtime沿原两帧gate；已激活不新建owner、不额外弃composition。 |
| 当前context resign，phase=visible | 仅第一次记pending(g,ctx,activatedAtSuspend)，取消尚未完成的rearm | 现有suspend/清composition仍只发生一次；duplicate resign不重复teardown或清理新状态。可见状态保持visible以表示未发生view消失，不能把历史hasViewAppeared当此状态。 |
| 当前context resign，phase=appearing/hidden | 不建立可即时resume的visible pending；取消首帧等待 | 按既有安全suspend要求释放资源；未展示实例不得因之后host active开启引擎，首次真正viewDidAppear才能恢复首帧门。 |
| host active，context匹配、phase=visible、当前window存在、pending g/ctx匹配、无已排队rearm | 若activatedAtSuspend=true且canary允许，则在调用前预占并消费pending | 仅一次共享resume；恢复现有已清空状态、heartbeat/journal/selection；不补交之前按键或旧composition。函数调用重入/重复active看到已消费pending无副作用。 |
| 同上，但activatedAtSuspend=false，首次gate未完成 | 置rearmPending(g,ctx)，pending保留直到有效frame结果 | 仅重新arm已有两帧gate，不立即generic resume、不打开librime。重复active因rearmPending而no-op。 |
| 两帧gate到期且g/ctx/visible/window/权限仍有效 | 调用前消费pending/rearm，沿已有首次activation入口 | 仍不直调startOwner，不跳过既有canary/配置判定。触发次数必须1。无法在五文件内给已有display-link入口加这些检查则Stop，不把要求转到Core私改。 |
| viewWillDisappear或展示被替换 | phase=hidden，generation失效，pending/rearm清除 | 取消display link，按既有visibility清理；随后active不能重建owner。下一viewWillAppear是新generation正常进入。 |
| active无pending、重复、old g、context缺/foreign、hidden或无window | 状态不变 | 无resume/owner创建、无heartbeat重启、无UI清理、无首次gate重arm。 |
| active触发后再真实viewWillAppear | 按新展示/原appearance规则进入 | 不能再消费已完成旧host恢复。真正新展示允许ADR0002正常清理；同展示重复active不能清新输入。 |

hostActive先发生但window尚未可见不应安排不受控异步Task。pending可等待正常viewDidAppear接管；该事件在g/ctx仍匹配且window成立时执行与上表相同分支。若再无view事件/通知，则本五文件方案不保证恢复，后续运行证据据实报告，不偷偷增加按键自愈、计时重试或新宿主事件。

## Canary权限必须在任何owner-starting调用之前

以下为UI读取当前状态后的action许可，不存储/重写Core状态，不为gate传递Core状态机所有权：

| 当前canary条件 | 新host-active／共享resume许可 |
|---|---|
| 非canary构建 | normal visible恢复可走既有Core resume。 |
| baselineActive | 仅沿已获准baseline runtime路径恢复，不激活canary；正常首次初始化仍受首帧门。 |
| visibilitySuspended | 已有completeVisibilityExit(positive)成立；只调用现有beginVisibilityResume，确认true后才允许这一次owner-starting resume，再沿既有ready/markCanaryReady协议。 |
| fenceIssued / visibilityEnding / fencedUnavailable | 拒绝generic resume和firstframe创建，不改状态、不授baseline、不绕过positive terminal。pending标为blocked，本路径无自动retry。 |
| canaryStarting / canaryActive | 不借host-active启动第二owner或再次beginVisibilityResume；startup/现存owner由原协议拥有。pending若与该状态矛盾，保留blocked/明确失败，不能改成baseline。 |
| baselineRecoveryPermitted | 新host-active不消费该权限、不调用generic resume；只允许既有明确恢复协议的专门入口处理，避免绕过terminal/身份核对。 |

必须先判许可，再调用controller.resumeRimeAfterVisibilityChange；不能“先resume、后检查ready/fence”。仅visibilitySuspended→beginVisibilityResume返回true可授权该canary重建；isOwnerReady/readiness不是通用重建权限，owner创建不等于Ready。异步ready无法沿既有协议完成或需要新Core状态/等待语义时停止并另定Core scope，不凭本表创造新完成路径。

## 五文件及测试映射

gate源无UIKit/Core依赖，明确加入Keyboard Extension和KeyboardTests两个Sources；KeyboardTests已有同步folder纳入新test文件。使用既有UITextDocumentProxyAdapter跨target引用模式，不把整个Controllers目录编入test，不把@testable import Keyboard写成可链接appex。

测试必须覆盖：visible resign-active恰一次恢复；重复active/resign与两种appear顺序；g/context mismatch、hidden/no-window、预创建；首次gate取消→rearm恰一次且无即时owner；late display tick取消；canary许可表每类否决及先许可后resume顺序；不清新composition、旧展示请求失效。测试gate actions及执行调用计数，模拟owner-starting effect只通过批准action可调用，不把测试stub的ready值当runtime结果。

静态review验证真实controller用同一gate动作并在Core resume前判权限；新候选真实通知/Maps/候选/host及owner/receipt仍属后续单独授权运行验证。原R1 Partial不能因作者补文档自行改成Pass；需精确新的设计review packet并取得授权/预算。当前不创建实施Assignment、不写Swift或pbx、不测试/安装/设备操作。
