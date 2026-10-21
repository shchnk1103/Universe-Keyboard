# QA-001 有界首显修复候选

状态：FIX READY FOR INDEPENDENT REVIEW。QA-001 仍 OPEN / MAJOR，真机修复效果未验证。

## 授权与入口

Human 当前聊天 LIMITED IMPLEMENTATION + TESTS：只改 T9PinyinPathBarView.swift、直接相关现有集成测试、本任务证据；允许本地提交，不含 Push/PR/Merge/发布或真机操作。
入口 HEAD fa8c2cb63c8be32d6723a7538bd1c39746af12e8，branch codex/keyboard-t9-adaptive-row-001，Writer不变。
入口即有 Human project.pbxproj、Scheme 未提交修改及 device-analysis-20261021 未跟踪证据，原样保护。Assignment阶段仍为旧的 Device trace ready；本轮按最新Human聊天授权推进，没有越过allowlist修改KOS载体。

## 证据等级与根因边界

设备原件/提取JSON/哈希/逐事件分析见 ../device-analysis-20261021/analysis.md 与 manifest.json，保持原字节。
首键 core/boundPaths=3，最终row34，visibleCells=0，无T4_LABEL_CONFIGURED；第二键5条Cell配置并可见。dropped=0；asyncAttributionUncertain=1、nativeOperationReturnObserved=false、triageHint=INCONCLUSIVE限制原生操作精确归属。
已经确认非空模型绑定后未生成可见Cell。源码确实先绑定模型再展开行；原reload/layout发生在hidden/0高阶段，reveal仅检查子collection正尺寸，不能排除父0/子33的中间状态。隐藏首显事务未可靠交接是最可能机制；UIKit内部缓存为何为空、此补丁是否解决真实设备缺陷尚未证实。不能称精确根因或真机PASS。

## 最小修改

生产文件仅 Keyboard/Views/T9PinyinPathBarView.swift：模型/revision立即保存；一个UI-only pending标记合并无效viewport期间的发布。父行和collection均为正尺寸且行未隐藏时，消费标记、invalidate布局、reload、布局，再允许reveal。layoutSubviews接手未提交事务；标记在UIKit调用前清除以防重入，普通layout不重复reload。无计时器、异步延迟、循环重试、输入重放或额外Session。
原0/34约束、Sticky、750根请求、Controller调用顺序、候选46pt、UI-1布局、RIME/Authority全部未改。F-1/F-2/F-3等未扩展处理。

## 测试及原始结果

新增现有 T9AdaptiveRowTests.testQA001HiddenViewportPublishesFirstCellsWithoutSecondInput：已附着window，父行先hidden/0；仅一次非空模型发布后展开，通过正常父布局验证实际Cell及m标签、非零bounds/alpha、viewport相交；不额外调用collection.reloadData或collection.layoutIfNeeded。随后ma更新、清空无旧Cell、保持34、隐藏0及无触控。它是View级测试，不调用真实RIME，不伪造Sticky flag。

- baseline.log：首次测试脚手架误占后续方法的@MainActor，编译失败 exit65；补回标注后未放宽断言，原始失败保留。
- baseline2.log：未修改生产源码，新增测试1 PASS / 0 FAIL / 0 SKIP，exit0。它未复现真机异常，不能当作red→green证据。
- fixed.log：修后 KeyboardLayoutIntegrationTests 20 PASS / 0 FAIL / 0 SKIP，exit0（CompactHeader12 + T9Adaptive8）。包括原Sticky/Recovery/生命周期、面板I-6/I-7及8种QA序列守卫。
- l2.log：KeyboardTests49 + KeyboardExtensionTests41，90 PASS / 0 FAIL / 0 SKIP，exit0。
- format.log/exit：相对origin/main共13个Swift文件strict lint通过，exit0；本轮两Swift已format。未修改其他Swift。
- Debug test编译成功；未另跑Release/全量Core/App/RimeBridge或真实Extension。
- fixed/l2日志未出现 Unable to simultaneously satisfy / Breaking constraint；这是日志检查，不是所有宿主约束的证明。存在hostless UIInputViewController连接警告与Xcode operatingSystemBuild解析警告，测试退出0，未隐藏。

独立构建使用本任务Simulator 5DEEF120-CB85-47BB-A690-303613DD85EC，DerivedData /private/tmp/t9-adaptive-row-001-integration-build。xcresult保存在 /private/tmp/ui2-qa001-minimal/{baseline,baseline2,fixed,l2}.xcresult。未操作真实设备、共享环境或其他工作区。

## Review与Human Gate

Claude材料：本次View/test diff、此报告、原始baseline/fixed/L2日志及哈希、此前真机analysis/raw/extracted/timeline。重点审查pending事务只消费一次、父/子viewport条件、reveal顺序、未附着窗口/再次隐藏时的边界。

Human在DSON 13 Pro重新唤醒T9，确认0pt，分别展开标点/颜文字后只按一颗字母并停住：检查34pt与路径立即出现。再按第二键确认完整路径且无重复；快速连续输入、删除/上屏Sticky保持、重新隐藏唤醒复位；面板收起/遮罩/触控/阅读位置正常。若仍空白，保留Human FAIL并再次采集无文本ui2-dump，不自动扩大到Core。

本轮不能关闭QA-001；设备首键效果、真实RIME时序及宿主交互仍需Human。没有Push、PR更新、Merge、发布。Human工程与Scheme哈希入口/结束一致，均不纳入本地提交。
