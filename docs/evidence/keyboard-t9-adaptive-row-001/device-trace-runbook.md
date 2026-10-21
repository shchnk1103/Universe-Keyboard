# QA-001 真机追踪：最短操作单

**DEVICE TRACE READY（准备就绪，不是QA通过）。QA-001仍OPEN / MAJOR，Human FAIL保留。**

## 一次性准备

1. 在UI-2工作区打开 `Universe Keyboard.xcodeproj`，选 **Universe Keyboard / Debug / 真实iPhone**，Run安装本地诊断构建。不要Archive或TestFlight，不改输入开关。工程已有Keyboard Scheme，但其中有历史Simulator RemotePath；为避免改Scheme，本轮推荐安装主App后手动附加。
2. iPhone在无个人信息的临时Notes中启用Universe Keyboard，切九宫格。Xcode选择 **Debug → Attach to Process by PID or Name → Keyboard**，确认是该iPhone上的 `com.DoubleShy0N.Universe-Keyboard.Keyboard`，不是主App进程。Keyboard未运行时可先选择等待该名称启动，再在手机切入键盘。[Apple键盘调试说明](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/CustomKeyboard.html)。本轮未替Human安装或附加真机。
3. Xcode暂停，选Debug Navigator的主线程 **Thread 1 / main**，Console粘贴一次：

```lldb
command source "/Users/doubleshy0n/.codex/worktrees/t9-adaptive-row-001/Universe Keyboard/docs/evidence/keyboard-t9-adaptive-row-001/device-trace.lldb"
ui2-check
```

应显示 `DebugT9QA001Trace`。若为nil，当前可能是旧构建、Release或错误进程：停止采集，先核对构建/进程；空输出不是通过。快捷命令已在本地LLDB解析，ObjC类和5个selector在UIKit自检通过；真实iPhone附加/导出尚待Human。

## 每次复现：开启 → 首键停住 → 标记/导出

1. 确认真正新呈现，九宫格Idle、Path0pt；此时暂停主线程，在Console输入 `ui2-arm`，再Continue。该命令只清空并开启内存探针，不重置键盘、Sticky或RIME。
2. 手机按原失败步骤：标点或颜文字候选展开 → **只按第一个字母键** → 观察路径是否空白。此时不要按第二键、切宿主或隐藏键盘。
3. 空白时在Xcode暂停、选主线程，依次输入：

```lldb
ui2-blank
ui2-dump
```

只复制 `ui2-dump` 输出的JSON到本地文本文件，标为“first-key-blank”。不要复制完整Console、`po output`、`po label.text`、宿主截图或视图层级全文。探针JSON只含固定阶段名、数值与布尔状态，不含输入文字。

可选：保持同一次arm，不执行stop，Continue后只按第二键。若恢复，暂停主线程执行 `ui2-visible`、`ui2-dump`，保存“second-key-visible”，最后 `ui2-stop`。若第一键已正常显示，用 `ui2-visible` 代替blank，并记录本次未复现，**不能据此关闭QA**。结束后总是 `ui2-stop`；下次arm会清除旧缓冲，务必先保存。

无需输入或提交具体字符内容；只需注明标点/颜文字、完整展开层/候选条/正在收起，以及Human看到空白或可见。若进程被系统回收，缓冲丢失，重新取得新一轮证据，不能拼接成同一次按键。

## 如何读第一次按键

`records`按 `seq` 单调排列，`event`复用Controller的inputEventSequence，`keyOrdinal=1`为本次arm第一键。`ms`是自arm起单调相对时间，**包含调试器暂停时间**，不要用跨暂停间隔评估输入耗时。先看 `dropped=0`、正确布局、首次sticky=0和首键T7。

| 检查点 | 记录 | 重点字段/解释 |
|---|---|---|
| T0 | KEY_ENTER | event、layoutNineKey/lettersSurface/chinese、sticky、pendingPunctuation/Kaomoji、原revision、panelPresent/Expanded/Transitioning |
| T1 | HANDLE_RETURN | Controller.handle返回时rawLength/corePaths/revision；**不是native操作返回** |
| T1补充 | UI_PUBLISH_CALLBACK | 现有响应式UI发布回调入口；responsive=1时异步归属始终标不确定 |
| T2 | MODEL_CAPTURED | 现有单快照传入UI时modelPaths/modelPathLength/modelRevision/modelRawLength，没有额外调用RIME或重算模型 |
| T3 | REFRESH_ENTER | entry1=refreshT9PinyinPathBar，entry2=refreshT9PresentationFromCoreSnapshot；真实调用可能T3先于T2，按seq看，不强造编号顺序 |
| T4 | PATHS_BOUND / LABEL_CONFIGURED | 绑定路径数量、Cell Label是否空及长度/hidden/alpha/bounds；Cell配置时bounds尚未完成布局可以为0 |
| T5 | PATH_LAYOUT / ROOT_LAYOUT | 实际rowHeight、collectionHeight、label尺寸、有效alpha、祖先hidden、requested/rootHeight、maskContains |
| T6 | PANEL_START / COMPLETION / AFTER_COMPLETION | 动画serial、原始event（0=启动时未关联）、tokenMatches、当前展开/存在/转场、revealed及presentation高度；完成回调记录和完成后的状态分开 |
| T7 | HUMAN | humanVisible=0/1及暂停时的新鲜只读视图观测；不是自动像素判断 |

`labelMatchesModel=1`仅表示当前可见Cell文字匹配已绑定路径之一，不导出文字。`maskModelContains=0`表示模型遮罩排除了文字中心；presentation=-1表示不可观测。`panelModelCoversLabel`只按模型矩形粗查，不等于屏幕像素遮挡证据。没有T5时不能声称布局完成。

`triageHint`只是排查线索，不能作为根因或验收结论：

| 分类 | 可以支持的判断 |
|---|---|
| DATA_NOT_READY | 同revision的首次展示模型路径为空；不等于输入丢失或RIME出错 |
| MODEL_NOT_REFRESHED | UI侧已观测Core路径非空，却没有当次模型捕获 |
| LABEL_NOT_UPDATED | 模型非空，但路径未绑定或可见Label不匹配模型 |
| VIEW_NOT_VISIBLE | 非空模型下有零高、祖先隐藏、alpha、模型mask或覆盖证据 |
| INCONCLUSIVE | 异步归属不明、revision不匹配、缓冲覆盖，或结构正常但Human仍看见空白等 |

**T1的边界：** 本轮禁止扩大Core/RIME，因此未在那里加回调。现有 `T9SEG event=... rawLen=... paths=...` 可辅助关联同步键；已有RIME BRIDGE END只证明bridge返回，不是路径就绪。若必须核实native结果，可在**另一轮会改变时序的调试运行**对 `Packages/RimeBridge/Sources/RimeBridge/RimeEngineImpl+Input.swift:81`（`return output`）加普通断点，只看 `output.rawInput?.count`、`output.candidates.count` 等数值。不要展开/导出output或raw对象，不把断点运行的首帧时序与无中断缓冲混为同一证据。

异步发布没有可用的native operation ID；缓冲event是UI侧观察区间，`asyncAttributionUncertain=1`时不得强称该callback属于某键。这能指出H5需要进一步证据，不能仅据此宣称H5为根因。若所有模型/Label/几何指标正常而屏幕空白，保留INCONCLUSIVE，再由Human本机检查视图层级的数值状态。

## 隔离、开销与保存

- 全部探针及调用点包在 `#if DEBUG`，默认关闭，只能由调试器arm。Release Simulator编译通过，nm/strings无探针类与阶段字面量；不代表本轮做了Archive/TestFlight。
- 内存环形容量128条，最多两次T9键；每键最多8条Cell样本、12条变化后的布局样本。第三键停止捕获；stop显式结束，arm清空。`dropped>0`一律INCONCLUSIVE。对象只弱引用Controller。
- 记录只含阶段常量和数值/布尔：不持有路径/输入/Label文字，不复制快照或RIME上下文，不记录宿主、词库、密钥或用户内容。长度和匹配布尔在观察时计算，缓冲不保留字符串。
- 不调用layoutIfNeeded、reload、hitTest、RIME、Authority、重建键盘或输入重放；不修改约束/Sticky/数据，不增加timer、轮询、后台任务、文件写入或上传。只有调试器请求report时在内存生成JSON；由Human自行保存该JSON。
- 关闭时先guard返回，不采样视图；开启后有限内存分配和UIKit只读查询仍会增加观察开销，**不承诺零时序影响**。若探针下缺陷消失，仅标未复现/INCONCLUSIVE，不能QA PASS。

本轮只增加1个探针自检，验证未开启不记录、128容量、两键限制、敏感测试字符串不导出及LLDB selector存在。既有Controller19/0/0、Extension41/0/0回归通过；最终T9子集7/0/0及单项自检通过。它们验证诊断设施和兼容性，绝不替代真实设备捕获。
