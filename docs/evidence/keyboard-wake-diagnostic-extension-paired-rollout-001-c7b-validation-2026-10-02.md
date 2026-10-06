# C7-B1 非设备阶段 — SDK 编译与独立静态评审交付

## 当前结论

Human 2026-10-02授权继续C7-B，但未回到Mac，无法手动Simulator测试。本轮先完成不依赖设备实例的SDK编译与独立static review；整体C7-B及C7-C仍未完成，父Assignment Active。未启动、安装、运行、输入Simulator，未attach/debugger/arm/读取其容器，未改源码或Git发布。四个generic编译action不是测试执行。

## 输入和产物绑定

原worktree/branch/HEAD保持：paired-rollout-preflight/Universe Keyboard / codex/keyboard-wake-v3-compatibility-gate /84b9c19227330b0fe6ff391be001ee398010fd6a。C7 nine-file identity `9730e254cb8afd48f857ad9bef1659017fe90d26700ea3c9b1809249e3c751c8`。

本轮整合build candidate `0095841393c45895ae5ee861878a03c0c9a8de3643759be47a9ac1cb5d8953f8`，571 source/build inputs +630 Vendor files hash冻结。由历史C4输入集合扩入C7三新增路径，再重算全部当前hash；历史source不同仅六个C7既有文件，旧C4结果不当成本次通过。12 xcframework simulator slices及四force-load路径均存在；没有Vendor fetch/复制/修复。Xcode27.0 (27A266a)，iOS Simulator SDK27.0，generic/platform=iOS Simulator、arm64、无签名、Swift6 strict concurrency complete / warnings-as-errors，禁自动package resolve/update；DerivedData/result全部scratch。

| action | 结果 | 覆盖边界 |
|---|---|---|
| Debug App+Keyboard build，DEBUG+KEYBOARD_WAKE_OWNER_PROBE | BUILD SUCCEEDED / exit0 | 真实UIKit SDK类型检查、Extension链接与配对嵌入；不是运行 |
| 同候选 App/Keyboard build-for-testing | TEST BUILD SUCCEEDED / exit0 | 两个实际测试target编译产出UniverseKeyboardTests.xctest与KeyboardTests.xctest；没有执行一项测试 |
| 普通Debug App+Keyboard build，无probe opt-in | BUILD SUCCEEDED / exit0 | 编译边界检查：无诊断UI/导出符号；Core DEBUG hook仍存在且默认未arm，不声称零初始化成本 |
| Release App+Keyboard build，无probe opt-in | BUILD SUCCEEDED / exit0 | Release编译/链接和配对产物；不是Release发布 |

完整命令/开始Unix/elapsed/exit及raw logs保留。Debug build25.37s，test-build6.47s，Release70.10s，普通Debug22.90s。raw logs分别2/4/2/2条AppIntents metadata extraction skipped warning，Swift strict检查无error；不称绝对无warning。

最终Debug产品取自build-for-testing之后，保留test-host products，不能视为已晋级安装候选。三组产物的App均包含Keyboard.appex；逐bundle Info/executable SHA以及unique 专用Debug11/Release2/普通Debug6 Mach-O SHA保留。Debug Keyboard.debug.dylib含`wakeOwnerProbeExportReady`/`installWakeOwnerProbeButton`符号，普通Debug与Release所查Mach-O无这两个符号，且编译未加Debug/probe条件。符号存在只证明编入，不证明appex中的breakpoint参数/借用读取、export decoder或按钮可点。三对均未安装，当前Simulator原App未通过本轮重建/替换。

## 独立评审

两个未参与C7实现的Luna runtime独立校验52/52 inputs，按冻结packet只审静态候选，未读取本轮新增编译结果。Architecture ARCH-C7-B1 round1：A1-A3完整static coverage，未发现材料性source blocker；Quality QUALITY-C7-B1 round1：Q1-Q3 Covered，推进Hold，完整Core阻断与动态证据仍欠缺。不能把root新增build receipts写成reviewer重新验收或解除Hold。

原review/usage不改写。Architecture原usage软时限字段自相矛盾（622.311秒checkpoint→delivery却称600秒内）；reviewer在最终交付自行指出，单独factual reconciliation更正为超过soft。由packet mtime早于dispatch给出838.486秒保守上界，低于900hard；实际首call起时未采。其18calls含16exec+2collaboration，已用尽。Quality13exec+2collaboration=15总工具调用，上界842.193秒，soft未达但hard以内；多次初始digest规范化尝试、一次report/usage脚本错误和漏逐call时间如实保留。不能声称严格全部流程合规；没有自动续预算。

| finding | 当前边界 / owner |
|---|---|
| Architecture F-01 / Quality C7-B1-F2 | synthetic armed/ordinal0不是owner absence；receipt只代表accept receipt，不代表engine/UI/host成功。内外resume会同stage重复，无producer字段，不把它解释为两个独立恢复。读取者/Executor负责保留有限语义，尚无runtime验收。 |
| Architecture F-02 | 隐藏触点范围是键盘与候选栏，诊断按钮自身被gesture observer排除以完成点击；动态交互仍待Human/Environment。未变更Product成“所有触摸都隐藏”。 |
| Quality C7-B1-F1 | full Core strict编译阻断Open，secondary Core owner + Product决定新增最小修复范围；本轮不自动改范围外test。 |
| Quality C7-B1-F3 | root SDK编译证据补齐专用Debug/Release及测试target编译；普通Debug边界按建议补编译且无UI/导出符号。actual target执行/现场仍Open；原review Hold未改写。 |

[Architecture原review](../reviews/arch-c7-b1-review-2026-10-02.md) · [Architecture原usage](../reviews/arch-c7-b1-usage-2026-10-02.json) · [Quality原review](../reviews/quality-c7-b1-review-2026-10-02.md) · [Quality原usage](../reviews/quality-c7-b1-usage-2026-10-02.json) · [usage事实更正](keyboard-wake-diagnostic-extension-paired-rollout-001-c7b-review-usage-reconciliation-2026-10-02.md)。

## 未完成与handoff

- 完整host Core strict suite仍因C7-A归档的T9PinyinPathTests.swift:1429 optional interpolation编译失败。本轮未改该范围外文件、未重复失败套件；36项host聚焦通过仅其范围，full Core不是绿。旧C4普通host suite有同位置warning，不能凭此豁免本次strict blocker。
- 实际RimeBridge/App+Keyboard/签名Keychain套件执行仍未做；本轮没有fresh device exclusive Entry。旧20+10skips仍unverified，不作为当前通过/接受。
- 按钮布局、touch/候选/展开、idle恢复、真实appex取证出口及单次Maps直接AppSwitcher复现均待动态验证。Human手动步骤等其回来；C7-C安装/调试器/现场运行还要另scope authority/fresh独占。
- 下一步优先处置review findings/完整Core编译blocker；只在owner与精确新增修改范围授权后实施。C7-B后续自动tests需要新环境Entry，未来部署不能复用此无签名generic test-host产物为安装授权。

## 保全/文档同步

完整前基线2628文件/543dirty，当前source/build+Vendor hash无漂移；最终保全见artifacts。root唯一repo writer，仅新增本任务证据/授权/packet并定点同步所属Assignment、parent与已有三个状态镜像条目。无source/build config/package修改，无stage/commit/push/reset/清理/切换worktree。CHANGELOG/ADR不更新，本轮验证没有发布行为改变或新长期架构决定。本轮只有普通阶段交付，没有Product Gate/ADR Accept/Assignment Close/merge，因此不是新M-02触发（ops M-02明文：ordinary documentation edits alone are not triggers）。只修订所属Assignment/parent Current Status与现有Dashboard/Index/Active Work条目的当前阶段，不递归生成M-02；旧C7-A标题的M-02称谓不被用作Gate或独立触发证明，原记录保持历史。知识Index路由镜像是review后唯一受影响的52-input文件，review前原字节及pre-sync52/52核验归档；9source/tests/project和build-input identity保持不变。

[授权](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-c7b-authorization-2026-10-02.md) · [Entry](keyboard-wake-diagnostic-extension-paired-rollout-001-c7b-entry-2026-10-02.md) · [build input manifest](keyboard-wake-diagnostic-extension-paired-rollout-001-c7b-artifacts/build-input-manifest.json) · [compile summary](keyboard-wake-diagnostic-extension-paired-rollout-001-c7b-artifacts/compile-summary.json) · [paired products](keyboard-wake-diagnostic-extension-paired-rollout-001-c7b-artifacts/paired-products.json) · [preservation](keyboard-wake-diagnostic-extension-paired-rollout-001-c7b-artifacts/preservation.json)。
