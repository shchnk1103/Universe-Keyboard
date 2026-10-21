# UI-1 × UI-2 本地集成验证

## 身份与边界

Task KEYBOARD-T9-ADAPTIVE-ROW-001，Writer codex-t9-adaptive-row，P=none。工作区 `/Users/doubleshy0n/.codex/worktrees/t9-adaptive-row-001/Universe Keyboard`；分支 `codex/keyboard-t9-adaptive-row-001`。本轮仅本地，未Push、未修改PR217、未Merge到main、未发布TestFlight。

入口本地HEAD52568c3e707fe196fe1774bdec9a8e29608ffe36，远端6f6fc129d7eb959f695de09a46e6808d146dd819；两个文档6001416/52568c3保留。普通Merge b34cea88a4633194908e0c1f0793b65db7cb2bd6，双亲272abb91449e01bbd891c9e61b2588e1771b9f87与78b795fb1429bd30721907b3035ce261d0342e6f。没有重写原产品55283ff或文档历史。

## 前置main证据

main78b795f、UI-1 reviewed e308033e同tree380288c7eefce971f7c7b35edfc3031914210f1e；PR216已合并。Actions39431043068 attempt2九项success，Xcode Cloud success。attempt1诊断读取超时保留为Human归类的疑似flaky，不作当前阻断，也不宣称绝对稳定；本轮未改其测试。远端main复核仍78b795f。

## I-1～I-5

- I-1：唯一KeyboardLayoutIntegrationTests Target D32170000000000000001，合并双方同步源组、必要编译/链接设置及包引用；Scheme仅一个BuildActionEntry/TestableReference，全部指向D321。UI-1原11项及UI-2原5项测试完整保留，另增1项集成验证。工程plist/Ruby解析与实际编译通过。设置对账保留在raw目录target-setting-reconciliation.json。
- I-2：旧256/290断言采用生产计算属性；单独明确验证254/288。
- I-3：展开面板顶部candidateBar，左右keyboardSurfaceView，底部rootStack；不再假设覆盖整个根视图。
- I-4：UI-1夹具明确26键、T9初始0、有效路径34、Sticky空路径34。真实生产snapshot进入Sticky；不直接设置latch。稳定态触控断言关闭动画，真实动画另有独立用例。
- I-5：当前合同46pt候选、0/34pt路径、254/288pt请求；旧开发阶段描述明确标为历史，冻结旧证据不改写。

## 高度与帧

公式：top2 + candidate46 + key45×4 + spacing8×2 + group10 + bottom0 =254；Sticky额外34=288。单一priority750请求、透明根、延迟安装、复用与保守生命周期门禁保留；不引入allowsSelfSizing。

320/390/430宽度真实Controller进程内断言通过。390宽时T9 Sticky根frame=(7,2,376,286)，目标288，Path=(0,0,376,34)，候选=(0,36,390,46)，首键=(7,82,69.6667,45)，底部空格=(158,243,145,45)。初始26/T9候选均=(0,2,390,46)，Path0，根252/目标254。候选始终46；按键45，候选与按键相对偏移不变；相同键对象/高度请求复用，隐藏路径无命中及AX残留。

这些帧是进程内测试，假定宿主接受请求，不能证明真实Extension屏幕坐标稳定。

## I-6/I-7与失败归因

新增testAdaptiveExpansionKeepsPanelReadingAndMaskGeometry：展开后滚到index40、记录阅读锚点，在静态及真实动画completion路径中0→34，检查面板/viewport/遮罩/快照/offset/锚点、收起后触控与阅读位置恢复。

修复前可复现：面板位置已更新，遮罩frame仍252而根286；动画中路径区域也未正确保留。根因是面板仅平移不resize时自身layout不一定再次调用，且旧代码转场中跳过遮罩更新。最小修复为Controller完成根布局后同步面板遮罩，面板自身layout及动画completion也同步；坐标变化移除旧坐标的遮罩path插值。不重建键、不改阅读数据或输入语义。I-6阅读锚点无新增失败；I-7复现后已通过。

历史运行：l1-initial编译失败（夹具缺@testable导入）；l1-second17项中3个用例失败、10条断言（遮罩、旧固定34夹具、转场禁用按钮被错误当稳定态）；l1-final中2个用例5条断言（hostless直接loadView需明确投递viewDidLayoutSubviews，及稳定态动画隔离）。这些日志全部保留；未删/skip测试。最终targeted-final全部通过。

## 最终L1/L2

- L1 Controller：17/0/0；CompactHeaderControllerLayoutTests12，T9AdaptiveRowTests5。覆盖Sticky、空路径、删空/重输入、页面/布局切换、Recovery/Partial Commit、明确生命周期边界复位、展开滚动/收起、转场高度变化、命中与约束等。
- L2 KeyboardTests：49/0/0；KeyboardExtensionTests：41/0/0。总计107通过、0失败、0跳过。
- Debug build-for-testing通过（严格Swift6/concurrency/warnings-as-errors）；相对main全部10个差异Swift严格格式通过。
- final日志无Unable to simultaneously satisfy constraints；必需等式断言通过。hostless needsInputModeSwitchKey警告与SDK build24A94232解析警告存在，不代表宿主已连接。
- 未运行Core/App/RimeBridge全量、Release或L3；本轮没有真实Extension激活/真机操作。

原始结果与日志：`/private/tmp/t9-adaptive-row-001-integration/targeted-final.xcresult`及同目录各log；独立DerivedData `/private/tmp/t9-adaptive-row-001-integration-build`。哈希与持久摘要见[integration-manifest.json](integration-manifest.json)、[integration-test-extract.txt](integration-test-extract.txt)。

## 保护与审查结论

Packages/Core/RIME与.gitguardian.yaml相对main无差异；未修改Authority、native select、R174默认值及诊断flaky测试。UI-1 Continuous Surface、46/56×46/42合同与V7–V10沿用，双方用例通过；这不等于本次集成真机验收。未访问/恢复已归档UI-1工作区或Human未提交工程文件。

Integration Implementation: PASS（有界本地实现）
Integration Quality: CONDITIONAL PASS（本地定向门绿，独立复核及Runtime Gate待完成）
Reviewer Handoff Recommendation: READY FOR INDEPENDENT REVIEW

Claude输入：本报告、manifest、测试摘要、普通merge及后续修复diff、Assignment/AUTH/最终BRIEF。无未解决的本地代码阻断。

Human重新验收：真实首键254→288与系统高度同步、宿主文本是否跳动；上屏/删空/下一词Sticky；隐藏再唤醒/进程复用复位；26/T9/数字符号切换留白；Recovery/Partial Commit；展开滚动收起阅读锚点；展开/收起动画中首次展开与遮罩、操作区触控、真实RIME时序及VoiceOver。不可复用UI-1验收冒充集成验收。
