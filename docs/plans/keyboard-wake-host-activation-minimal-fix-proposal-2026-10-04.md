# 键盘宿主重新激活最小修复方案 — 2026-10-04

**Proposed / 只读准备完成，未授权实施。** 授权来源为Human“授权你准备修复任务的最小方案”。不是正式Assigned/Ready修复Assignment、独立review结论或设备窗口；父诊断Completed不重开。仍使用原工作树/branch/HEAD，保留全部既有dirty，不切分支、暂存、提交或推送。

## User Interaction / 已证边界与静态缺口

当前43d85d历史窗口：正常schedule有owner和receipt；宿主失活/visibility teardown之后返回失败schedule二者缺失，双独立局部Covered。精确系统回调投递历史未观测；不能声称已证明系统不调用viewWillAppear。

静态链：Bootstrap.swift:814–846仅观察NSExtensionHostWillResignActive，调用suspendKeyboardRuntime(updateUI:false)。KeyboardViewController.swift:515–604调用Core suspend并清状态，停止first-frame gate/heartbeat/journal；Core ThreadAffineRimeSession.swift:533–562在positive teardown后owner=nil。生产恢复在viewWillAppear:381–453调用controller.resumeRimeAfterVisibilityChange；Core:566–580仅owner==nil时startOwner。Key路径RimeRecovery.swift:85–111只在coordinator本身为nil时重建；coordinator保留但owner为nil时直接schedule，ThreadAffineRimeSession.swift:405–422的optional accept得不到receipt。

该源码确有“失活通知触发挂起、恢复只依赖视图出现”的不对称，与实测owner缺失吻合，构成首选修复假设；修复效果仍需新候选验证。

本机SDK NSExtensionContext.h声明didBecomeActive API iOS8.2起可用。[Apple官方说明](https://developer.apple.com/documentation/foundation/nsnotification/name-swift.struct/nsextensionhostdidbecomeactive)：宿主由inactive变active时发出该通知，供扩展调整活动；object为NSExtensionContext。该API语义不保证本次具体Maps窗口已实际投递或时序固定，不采用普通UIApplication前后台通知替代。

## 建议方案与不变量

补NSExtensionHostDidBecomeActive监听，与已有resign路径配对。仅处理属于当前扩展上下文、当前展示已成立并仍有可见窗口、且本实例确有尚未恢复的宿主挂起；预创建/隐藏/已消失实例不得因宿主active打开runtime。visibility标记不能只用hasViewAppeared（它永远为历史首次出现true），需要明确当前presentation状态。

两条入口viewWillAppear和hostDidBecomeActive共享一个小恢复入口，消费一次挂起状态，避免通知和appear不同顺序/重复导致重复owner、清空新composition或重复注册。恢复主逻辑复用现有controller.resumeRimeAfterVisibilityChange、realized selection、heartbeat、journal、canary fence/owner-ready流程；保留原首次viewWillAppear行为，不把已经运行的普通键盘当成待恢复。

若宿主失活取消了尚未完成的首次frame gate，返回只重新arm现有两帧gate，不能提前打开librime；已激活runtime的同展示返回才走既有resume。已有canary fence/kill/failed teardown不能通过新active入口获得owner重建或baseline权限。若不修改Core无法保持这些合同，停止该slice并另提Core scope，不顺手改schedule自愈。

恢复显示从已清空的现有状态同步，避免继续展示旧候选；不重放/补交失活前输入、不恢复marked range、不重投故障按键。遵守ADR0002的visibility弃composition。无RIME部署、词典修复、热路径文件访问或新增诊断wire enum/记录协议。

## 最小五文件候选（实施前必须另冻结）

| 文件 | Proposed作用 |
|---|---|
| Keyboard/Controllers/KeyboardViewController.swift | 当前presentation/待恢复状态接线；viewWillAppear、viewDidAppear、viewWillDisappear/suspend与共享resume入口协作，保留原canary/first-frame/selection逻辑。 |
| Keyboard/Controllers/KeyboardViewController+Bootstrap.swift | 注册对应host-active通知，过滤上下文并把恢复决策交共享入口；现有resign状态成对记录。 |
| Keyboard/Services/KeyboardHostLifecycleRecoveryGate.swift（新） | 小型MainActor内存状态/决策模型，仅表达可见性、待恢复、首次gate与重复事件；不持有Core业务状态/引擎、不执行I/O。 |
| KeyboardTests/KeyboardHostLifecycleRecoveryGateTests.swift（新） | 使用真实gate验证下面的状态序列，不启动RIME/访问AppGroup；不能声称单元测试证明系统实际投递通知。 |
| Universe Keyboard.xcodeproj/project.pbxproj | 把不依赖UIKit的gate源码明确编入现有KeyboardTests，沿已存在的跨target源码引用方式；不改bundle id/签名/部署配置或runtime开关。 |

需要gate测试文件和target接线：现有KeyboardExtensionTests只验证bundle可加载，注释明确appex不是linkable XCTest host，不能声称@testable import Keyboard足以执行控制器测试。当前KeyboardTests为folder同步组，可纳入新测试；共享gate需要明确Sources membership。实现必须测试gate决策，实际controller/通知接线仍靠独立源码review和后续真实配对验证，不能仅凭gate单测宣称修复有效。

## 分阶段Entry及验收

F0准备/独立设计补审：新修复职责以Keyboard Experience为primary，Core协作只读，root执行；Architecture/Quality审查者独立。正式实施Assignment的授权/ACK/精确5路径source hash、新文件absence、dirty owner来源、工具预算需完整冻结；当前方案不是Ready。沿既有工作树，不复制其他未提交改动。新源码实施仍需Human明确授权。

F1本地实施与测试（未来授权）：gate至少验证同展示resign→active恢复一次、active/appear两种顺序及重复active幂等、隐藏/预创建/foreign context不恢复、首次gate被取消后只rearm、真实disappearance后旧挂起失效、canary fence/failed teardown不被新路径绕过。源接线review要确认既有resume仅提取/复用，未把owner重建放到按键热路径。严格Swift6和格式lint；工程改动不能按docs-only或仅Core测试声称整体通过。按AGENTS跑Core、iOS RimeBridge、App+Keyboard、Release build等本地完整门禁，阶段执行需环境授权且skip另处置，不为数差重跑。

F2独立候选审查：冻结最终source/build/paired manifest，Architecture审生命周期、canary/epoch/first-frame/ADR0002；Quality审真实执行目标、覆盖/skip/格式及产物字节。旧43d85d reviews不自动成为新候选通过，不接受只测gate就标修复完成。

F3安装和单轮Maps回归（未来另授权）：原精确模拟器新独占、新鲜备份/恢复方案、精确新paired安装与部署状态；正常baseline、只开AppSwitcher直接返回而不切Settings、返回后单次按键、候选/宿主正常更新。必要时用已有内容无关probe验证恢复owner及receipt，并核epoch fence旧结果拒绝；日志开关/调试器清理各自Entry与Exit。不得复制私人输入/候选/宿主文字。正常keyboard关闭重开、未启用/无完全访问或预创建路径也要按明确回归scope验证，物理设备结果另记，不从模拟器外推。

## Regression Risk / Documentation Impact

主要风险是hidden controller仍建owner、duplicate active清掉新输入、first-frame提前建runtime、canary kill fence被绕过、旧epoch结果污染新presentation。以上是必须验收的不变量，不是已发生新故障。最小slice不改Core/RimeBridge或部署所有权，不修改ADR0002合同；若要求自动恢复旧输入，必须停止并另作产品/ADR决定。

shipping修复若实施并验证，需要新增修复Assignment、实施证据及CHANGELOG条目；不是改父诊断Completed或把其accepted-unverified残项变成pass。当前只有方案文档，未代码/build/test/simulator/install/恢复/Git/Release动作，不需CHANGELOG。

证据：[只读source hashes与拟定路径](keyboard-wake-host-activation-minimal-fix-artifacts/source-boundary-check.json)、[父有界诊断交付](../evidence/keyboard-wake-lifecycle-diagnostics-001-bounded-completion-2026-10-04.md)。
