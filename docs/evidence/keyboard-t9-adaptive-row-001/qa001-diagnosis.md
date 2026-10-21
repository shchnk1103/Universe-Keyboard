# UI2-DEVICE-QA-001 — 有界本地诊断，缺陷尚未解决

## 身份与结果

Task KEYBOARD-T9-ADAPTIVE-ROW-001 / Writer codex-t9-adaptive-row / P=none。开始HEAD011d3fa592a938fb1f7eff83f125f96bbecaad18，命名Worktree和分支正确、干净，无Human未提交修改。授权见[QA-001 AUTH](../../authorizations/AUTH-KEYBOARD-T9-ADAPTIVE-ROW-001-QA001.md)。

Human真实iPhone两轮合计8 PASS/1 FAIL。首次输入后路径栏34但无字，第二键恢复包含两键的完整路径；截图宿主标记m且候选已出现。接受该FAIL，不把它认定为输入丢失，不以本轮绿测推翻。真实根因仍未知；本轮未修改产品源码，没有可声称消除根因的最小修复。不能继续沿用READY FOR HUMAN DEVICE ACCEPTANCE。

QA-001 Implementation: BLOCK（根因未复现，尚无产品修复）
QA-001 Validation: CONDITIONAL PASS（仅进程内同步边界守卫与既有回归；真机FAIL未关闭）
Recommendation: INSUFFICIENT EVIDENCE

## 源码调用链（011d3fa产品源码保持原字节）

1. Keyboard/Controllers/KeyboardViewController+ModeActions.swift:50/61：标点/颜文字进入controller.handle后syncUI。
2. Keyboard/Controllers/KeyboardViewController+CandidateBar.swift:68：toggleCandidateExpand更新展开模式，pending候选重建后present；动画中重复toggle会被拒绝。
3. Keyboard/Controllers/KeyboardViewController+InputActions.swift:5/74/127：九宫格按钮按accessibilityIdentifier发送数字身份；一次controller.handle后syncUI。没有发现该入口会自动收起仍打开的候选面板；需区分Human所说“候选展开”是完整overlay还是标点候选条/刚收起的overlay。
4. Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController.swift:1429：接受pending标点/颜文字后处理insertKey；KeyboardController+RimeRecovery.swift:145起同步engine.processKey、应用output与更新路径；响应式分支另有异步publish路径，本轮未更改或真实运行native异步session。
5. Keyboard/Controllers/KeyboardViewController+Presentation.swift:297：active T9走单快照发布；KeyboardViewController+T9PinyinPath.swift:94/99先读取快照并setPaths，同一函数末尾defer刷新可见性。不是先刷新一次再无条件等待第二键的显式逻辑。
6. KeyboardViewController+T9PinyinPath.swift:56：仅UI latch、行约束和单一750根请求；首次有效快照展开后Sticky不因空闲清除。
7. Keyboard/Views/T9PinyinPathBarView.swift:160/287/341：setPaths存模型、reloadData，Cell配置文字；layout用真实viewport处理待滚动。首次零高度尚未materialize Cell和最终文字不可见是不同证据。
8. KeyboardViewController+ExpandedCandidatePanel.swift:481：dismiss先恢复compact阅读位置，然后token保护的动画completion还原mask/AX、移除panel；过期token会跳过completion。refreshExpandedPanel:579只重载同一面板和按快照身份重置阅读位置。
9. KeyboardViewController.swift:808：viewDidLayoutSubviews完成root/panel布局后同步遮罩；ExpandedCandidatePanel.swift:295/337保留I-7的坐标变化同步与token逻辑。

H1/H4数据晚一拍、H2零高视图、H3顺序覆盖、H5遮挡均未被本轮真实设备日志确认。不可把源码可能性写成设备根因。

## 确定性守卫与证据边界

新增KeyboardLayoutIntegrationTests/T9AdaptiveRowTests.swift:292 testQA001FirstPathIsVisibleAfterPendingPanelBeforeSecondKey。它使用真实Controller、标点/颜文字入口、toggle、实际九宫格6按钮、真实Core handle和catalog路径生成、syncUI/atomic publish、UIKit窗口与Cell；没有直接设置Sticky latch或注入路径snapshot。

engine是同步RimeEngine替身，返回raw6/preedit m/候选哦；TextInputClient为进程内标记文本替身。未加载native librime，不证明设备RIME/session/异步发布真实状态。窗口只附着view，略过Extension启动/生命周期；像既有测试一样手动接受preferred高度并投递post-layout回调，不证明真实宿主是否及时接受高度和调用layout。UILabel/模型mask检查不是屏幕像素或系统触控验收。

覆盖2入口×4时序：完全展开、刚开始收起、真实半途收起、真实半途展开。后两者用CADisplayLink观察presentation bounds落在46与252之间的25%～75%，同一观察回调立即发送首键，不用固定sleep、不依赖第二键。最终日志半途观测高度196.80、176.08、105.38、108.39pt。

首键立即断言：engine只收到[6]；raw6、marked m；Core路径[m,n,o]；Path34、collection含3项，m的UILabel有非零bounds/alpha1、所有相关祖先未隐藏；Cell在viewport内；模型及可用presentation遮罩保留文字中心；候选哦/raw快照6一致；面板按candidate/surface/root几何；生产动画完成后panel/mask移除及按键hit-test正常。首键这些检查全部在第二键之前。之后再发送第二个6，engine精确[6,6]、raw66、marked mo、Sticky34。catalog会将无效mn归一到有效mo，因此最终夹具直接返回有效mo，未调整Core语义。

**011d3fa产品代码在这些条件下已经通过**：该测试是排查反证与后续回归守卫，并非成功复现/修复QA-001。

## A～H及Human补充九问

| 层 | 真机证据 | 进程内实测 |
|---|---|---|
| A 首键送达 | 标记m、第二键含两键，支持首键被处理；无调用计数日志 | processKey一次、key6 |
| B RIME状态 | 真实raw/session未知，截图仅宿主m | 替身raw6、Core marked m |
| C 路径模型 | 未采集 | 第一次即[m,n,o] |
| D/E 首次刷新及读取值 | 未采集 | 正常syncUI、快照和3项Cell一致 |
| F/G UILabel及遮挡 | 截图确实空白，无法读text/bounds/mask | m、非零、alpha1、未隐藏，mask保留文字 |
| H 第二键恢复原因 | 真实机制未知，不能断言是补刷或输入丢失 | 首键已显示；第二键正常处理，没有“恢复”现象 |

因此：1首键很可能已处理但设备计数未知；2设备native状态未知；3首次设备路径模型未知；4设备UILabel内部状态未知；5第二键恢复原因未知；6根因未确认；7未提交猜测性修复；8有不依赖第二键的同步边界测试，但未复现native bug；9仍需Human定向采集与复测。

## 验证运行与失败归因

raw目录 `/private/tmp/t9-qa001`，DerivedData复用本任务独立 `/private/tmp/t9-adaptive-row-001-integration-build`，同一任务Simulator5DEEF120-CB85-47BB-A690-303613DD85EC；无GUI尝试、设备重置或其他Agent设备操作。

- repro：1通过，exit0；直接快照隔离探测（中间夹具，最终未保留直接snapshot注入）。
- engine-repro：1用例失败2条断言，exit65；预期1路径实际为正确的m/n/o三项，首键文字可见。属于夹具预期错误，不是QA复现。
- sequence：1用例失败7条断言；预期mn实际Core规范化为mo，且全局动画开关泄漏到下一轮夹具导致toggle拒绝。修正每轮初始动画状态与有效mo，无产品修改。测试完成后旧xcodebuild99096卡诊断收集，仅TERM该本任务进程，最终exit143/BUILD INTERRUPTED；不作通过证据，未重置Simulator。
- halfway：1通过，exit0；真实半途收起已覆盖。
- final：L1 Controller18/0/0（CompactHeader12、T9Adaptive6）；L2 Keyboard49/0/0、KeyboardExtension41/0/0；共108通过/0失败/0跳过，exit0。
- Swift相对main10文件严格format/lint通过；git diff --check通过；final日志无新增Unable to simultaneously satisfy constraints。原I-6/I-7、Sticky/Recovery/Partial Commit/生命周期测试均通过。
- 只新增测试与文档，产品源码未改；Debug test已编译受影响target，无需额外全量build-for-testing。Core/App/RimeBridge全量、Release/L3未运行。没有新的真实Extension或真机运行结果。

## F-1来源纠正与F-2/F-3/F-5

旧integration-manifest未改、旧l1-second.log未覆盖。原manifest哈希19e8167f...精确匹配当前日志前705951字节；完整707137字节现哈希232d66aa...，追加1186字节包括600秒诊断收集超时、最终TEST FAILED尾部。此前记录了未封口日志前缀的哈希，不能当完整最终日志哈希。独立保存前缀和完整副本、长度及两哈希于raw的f1-provenance.json和本轮manifest。该次测试本来就是失败；本纠正不把失败变通过，也不改变最终107项已通过运行。

F-2注释位置问题保留待后续微清理，本轮没有借机修改产品。F-3揭示高度旧值风险仍未关闭；本次Path增加34且panel top同步增加34时panel高度252保持不变，不能由该风险推导QA-001因果。F-5在本轮同步序列中补充了可测量的真实半途展开和收起帧，但不能替代native设备重现；没有证据说明F-3/F-5造成Human空白。

## 下一步与停止

需要同一设备、同一缺陷运行的首键前后证据：实际输入/发布revision与raw长度、路径数量、setPaths收到的revision/count、row/collection/Cell尺寸与可见性、根/面板mask及revealToken完成记录。应先区分完整展开面板、候选条以及刚收起场景；现有T9SEGMENTS可先核对首键paths/rawLen/cands，必要时另行批准精准UI诊断构建。禁止仅为让测试失败而改输入语义或靠重复刷新、延迟强行“修复”。

本轮保留Human FAIL。没有已确认根因的产品修复可交付；停止等待Human/Claude复核这些排查证据及后续设备诊断安排，不Push/PR/main/release。
