# QA-001 Finding A — Writer修订回交

状态：REMEDIATION READY FOR RE-REVIEW。QA-001保持OPEN / MAJOR；需Claude再审及Human真机复验，不是QA通过。

## 入口、授权与保护

Human当前聊天 Independent Review Finding Closure / LIMITED REMEDIATION + TARGETED TESTS为本轮授权；Claude Findings输入为Human完整转述：RETURN TO WRITER，Architecture/Quality CONDITIONAL PASS，Finding A MAJOR。未伪称读取了独立Reviewer的原始文件。
固定branch codex/keyboard-t9-adaptive-row-001，入口HEAD af339d9df00eb834a66fa4a38991449fc17719a9。仅原有project.pbxproj、Scheme为dirty，两者入口/结束哈希一致，没有新未知修改。已读Assignment及ASSIGNMENT_POLICY的独立review约束；Writer不变，未新派Reviewer/关闭任务/修改KOS Policy或载体。当前允许写入仅View、直接测试、本任务证据。
此前真机raw/extracted/analysis保持不变，见 ../device-analysis-20261021/；原修复报告见 ../minimal-fix-20261021/report.md。

## Finding A — 复现与修复

新增 testHiddenPathShrinkEmptyAndRepeatedShowKeepCollectionConsistent，在af339d9生产代码上运行：先显示3项并查询Collection缓存，隐藏后setPaths为1项，Collection仍返回3，XCTAssertEqual(3,1)失败。此为确定的**数据源数量不同步**证据，并非仅理论风险。断言后guard退出，仅在失败情况下避免刻意继续触发旧索引崩溃；没有跳过/放宽该失败断言。没有观察到实际越界崩溃，不把数量差异称为已经发生的崩溃。

修订：每次setPaths立即保存paths/selected，然后同步reloadPathData→reloadData，且在applyIdleHint等后续UI修改前通知UIKit。仅把首次有效viewport的补充reload/layout延后；可用条件包含父行未隐藏、collection未隐藏、父/子正尺寸。已经可用时只同步reload/layout；不可用时保留一个pending标记。首次可用layout消费标记、invalidate、reload/layout，再处理reveal。

一致性与异步边界：View继承UIKit主线程隔离；setPaths及数据源回调无await/异步调度，模型替换和reload之间没有其他UI操作或挂起点。每次发布（包括缩减/空数组）都向UICollectionView同步发送reload，恢复原先数据源通知语义；UIKit内部仍可延迟实际Cell创建，但后续layout使用的是已通知的新数量。隐藏期间多次发布也逐次通知最新模型，不另存旧数据数组。没有靠bounds guard返回伪Cell来掩盖不同步。

不会循环：setPaths的同步reload每次发布一次；额外刷新只在pending且viewport有效时执行，标记在invalidate/reload/layout前清除，重入或重复layout不能再次消费。不存在timer、固定延迟、轮询或异步重放。最新模型始终保存在paths，补充刷新读取最新模型，不等待第二键。DEBUG-only debugPathReloadCount只统计真实reload调用，不采集内容、不增加调度，Release无该字段。

与设备证据对应：首键模型已bound3但visibleCells0，原始现象仍指向首显Cell未配置；保留有效viewport补充刷新用于该场景。本轮确定修复的是Reviewer暴露的数据源一致性缺陷。设备缺陷具体UIKit内部机制、补充刷新是否足以治愈真实首键空白，仍未证明。asyncAttributionUncertain/nativeReturn限制继续有效，不改变输入链路。

## 测试及结果

实际路径是 KeyboardLayoutIntegrationTests/T9AdaptiveRowTests.swift；不是不存在的KeyboardTests/T9AdaptiveRowTests.swift。

1. 新增 testHiddenPathShrinkEmptyAndRepeatedShowKeepCollectionConsistent：已有3项→hidden缩为1（立即校验UIKit count）→invalidate→显示实际m Cell；hidden清空+hint，count0；显示后无旧Cell；hidden collection不消费viewport补充reload；随后非空恢复3个Cell。完整循环3轮。修前失败，修后通过。
2. 改进 testQA001HiddenViewportPublishesFirstCellsWithoutSecondInput：保留真实Cell/Label/触控断言；新增实际reload计数：隐藏发布+1、零高layout不增加、首次有效viewport再+1、普通后续layout+0。hint测试也校验collection隐藏期间没有额外reload。它在上一轮已作为guard通过；新增计数验证的是修复行为，不是设备red→green证明。
3. after.log：KeyboardLayoutIntegrationTests **21 PASS / 0 FAIL / 0 SKIP**（T9Adaptive9 + CompactHeader12），exit0。全部精确名称见tests.json。原Sticky、恢复、面板/I-6/I-7、生命周期、实际首Cell相关测试全部保留。
4. before.log：新缩减测试 **0 PASS / 1 FAIL / 0 SKIP**，断言明确见日志。xctest进程已退出，xcodebuild随后收尾停滞，等待约2分钟后仅终止本任务精确PID49670（先INT后TERM）；最终exit143 / BUILD INTERRUPTED，而不是正常测试exit65。失败记录原样保存，before.xcresult可能未完整收尾，不能冒充完整结果包。
5. format.log/exit：相对origin/main13个Swift严格lint，exit0；本轮两Swift已format。源码diff检查通过。证据暂存后，git diff --cached --check报告原始构建日志及patch上下文空行的尾随空白；为保持原始字节和哈希，未清洗这些证据。这不是Swift格式失败。
6. Debug test编译及执行成功；未修改签名/Scheme/project。after日志没有Unable to simultaneously satisfy / Breaking constraint。hostless连接警告与Xcode operatingSystemBuild解析警告保留，不等于真实Extension验证。

命令：xcodebuild -project 'Universe Keyboard.xcodeproj' -scheme 'Universe Keyboard' -configuration Debug -destination 'platform=iOS Simulator,id=5DEEF120-CB85-47BB-A690-303613DD85EC' -derivedDataPath /private/tmp/t9-adaptive-row-001-integration-build -resultBundlePath /private/tmp/ui2-qa001-review-remediation/after.xcresult -only-testing:KeyboardLayoutIntegrationTests CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES test
修前命令使用before.xcresult及-only-testing:KeyboardLayoutIntegrationTests/T9AdaptiveRowTests/testHiddenPathShrinkEmptyAndRepeatedShowKeepCollectionConsistent。日志首行也保存完整构建调用。

未执行：本轮未重跑Keyboard49/Extension41、Core/App/RimeBridge全量、Release和真机。当前改动仅View/直接集成测试，采用21项集成回归作为本轮最小验证；此前90项通过证据不冒充本修订HEAD的运行结果。未操作真实iPhone或其他工作区/任务目录；只使用本任务原Simulator/DD与新的/tmp日志目录。

## 差异及下一Gate

original-fix.patch为fa8c2cb→af339d9的原View/test修复；revision.patch为af339d9→本修订的增量。生产范围仍只有T9PinyinPathBarView.swift，未触及Controller、Core/RIME/Authority、根高度/Sticky状态机、UI-1合同或Human工程/Scheme。

需Claude再审数据源通知顺序、viewport补充刷新单次性、隐藏hint与实际Cell断言；依据此报告/patch/log/hash判断Finding A关闭，不自动升级设备结论。
Human在DSON 13 Pro：真正重新唤醒T9从0开始，分别打开标点和颜文字，首键后停住检查34pt及路径立即出现；再按第二键看完整路径且无重复，快速连续输入，删除/上屏Sticky保持，隐藏重唤醒复位，面板遮罩/触控正常。失败则继续保存无文本device trace。

没有Push、PR更新、Merge、发布，没有修改其他任务目录。最终本地提交仅View、现有测试与本目录证据；两个Human dirty文件继续保留且不暂存。
