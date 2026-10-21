# QA-001 Device Trace — 本地准备证据

Status: DEVICE TRACE READY。QA-001 OPEN / MAJOR；Human8PASS/1FAIL不变。没有根因修复、没有真实设备运行或提前PASS。[Human操作单](device-trace-runbook.md)；[LLDB快捷命令](device-trace.lldb)。

## 入口及Human工程保护

入口HEAD44bc548032873cab4fd03be10d3acd1055a7dcfb，正确task/Writer/Worktree，起始干净；011d3fa..44bc548仅测试、证据及KOS，没有产品源码改动。准备期间project.pbxproj被Xcode保存，Human明确确认“是我的修改，可用于编译但不提交”。该文件保留原字节、排除本轮提交；编译证据绑定该未提交工程哈希，不能伪称干净checkout的完全相同工程。无reset/clean/stash/main/UI-1操作。

## 为什么需要最小探针

零代码调试可读取某一暂停时刻的几何，并用现有KEY/T9SEG日志看事件与数量，但无法重建同一首键的模型/Label/layout/panel完整轨迹；逐断点还会改变时序。因此仅增加DEBUG显式arm的有界内存观察。没有把现有模拟测试PASS解释为QA修复。

## 精确修改范围

- 新 `Keyboard/Controllers/T9QA001DeviceTrace.swift`：DEBUG-only、128环形、数值字段、两键/Cell/布局采样上限、ObjC调试入口、保守分类。没有Core/native hook，T1明确是UI侧handle返回/现有发布callback。
- `KeyboardViewController+InputActions.swift:32/79`：既有event序号处T0、既有handle之后T1。未修改handle顺序或次数。
- `KeyboardViewController+Bootstrap.swift:22`：现有响应式UI回调只读记录。
- `KeyboardViewController+T9PinyinPath.swift:96/104/181/191`：既有刷新入口与已捕获模型，只读数量/长度/revision，不额外调用Core快照。
- `T9PinyinPathBarView.swift:143/203/235/350/405/634`：只读视图数值、路径绑定、Cell配置和既有layout观察；不新增layout或刷新。
- `KeyboardViewController.swift:821`：既有post-layout后的变化去重观察。
- `KeyboardViewController+ExpandedCandidatePanel.swift:341/354/366`：记录原动画序号关联、token是否仍匹配及完成前/后状态。无动画/token/revealedHeight策略修改。
- `KeyboardLayoutIntegrationTests/T9AdaptiveRowTests.swift:424`：唯一新增自检；DEBUG包裹，无新Target/工程配置。其余旧测试不删除/放宽。

全部修改都是DEBUG插入与只读helper，既有生产语句保持顺序；F-1/F-2/F-3、Core/RIME/CandidateAuthority、UI-1合同均未改。相对main13个差异Swift格式严格通过。

## 运行结果与边界

- probe：Controller19/0/0，exit0，验证初版诊断及既有Controller行为。
- final：Controller19/0/0、Extension41/0/0，exit0，共60通过，无失败/跳过。
- diagnostic-final：1/0/0，exit0，最终ObjC5个selector、容量/隐私自检。
- ready：T9AdaptiveRowTests7/0/0，exit0；最终刷新入口/模型观测顺序及保守异步归属调整后通过。sealed：最终补齐页面/pending布尔字段后的探针单项1/0/0，exit0。
- Release、release-final及最终封口release-sealed本地Simulator build均exit0；最终nm/strings隔离检查通过，Debug ObjC类存在，Release类及阶段字面量不存在。没有Archive、签名分发或TestFlight操作。
- LLDB aliases本地无设备加载/解析exit0；实际iPhone附加、Objective-C表达式导出和缺陷触发等待Human，不声明已实测。
- 无新增必需Auto Layout冲突。现有hostless UIInputViewController警告、SDK build24A94232解析警告、Vendor架构note保留，不等于宿主已连接。
- 未跑Core/App/RimeBridge全量、L3。KeyboardTests49项沿用上一轮未受影响证据，不计为本轮重跑。

raw `/private/tmp/t9-qa001-trace`；Debug DerivedData复用本任务独立目录，Release用该raw下release-build。所有日志封口后才计算哈希；[manifest](device-trace-manifest.json)保存源/日志/二进制隔离与Human工程哈希。诊断关闭不输出/不采集，开启也无日志上传/磁盘写入。

交付后仅Human按操作单采集同一次首键T7 JSON；异步归属、revision或render证据不足保留INCONCLUSIVE。QA-001不关闭，不Push/PR/main merge/release。等待真实设备证据。
