# A2 新候选验证 Prepared Entry — 2026-10-05

准备授权来自2026-10-04本线程；源清单只读快照采于2026-10-04 23:59:42 Asia/Shanghai，跨午夜后完成治理交付。

**Prepared，未 Ready，未执行。** Human只授权root准备新候选验证Entry。root为Environment Executor/Coordinator，Grok源码writer已停止；Product为本线程Human。对应[Assignment](../assignments/keyboard-wake-host-activation-fix-001.md)、[四文件接收](keyboard-wake-host-activation-fix-001-a2-f1-received-2026-10-04.md)、[原F3独立交付](keyboard-wake-host-activation-fix-001-f3-independent-validation-2026-10-04.md)。整体修复Blocked保持，父诊断Completed不重开。

## 当前只读核验

唯一worktree `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard`；branch `codex/keyboard-wake-v3-compatibility-gate`；HEAD `84b9c19227330b0fe6ff391be001ee398010fd6a`；staged0。五文件hash与接收一致，pbx保持。358源文件、168主App文件、630Vendor常规文件共1156清单行全部重算，并重列路径成员核对无新增/缺失；13钉死scheme/package/receipt/依赖字节保持。完整dirty快照保留，不将全仓dirty归本修复所有。

可复算清单：[source](keyboard-wake-host-activation-fix-001-a2-validation-artifacts/source-tree-manifest.json)、[App](keyboard-wake-host-activation-fix-001-a2-validation-artifacts/app-source-manifest.json)、[Vendor](keyboard-wake-host-activation-fix-001-a2-validation-artifacts/vendor-byte-manifest.json)。算法：各文件raw bytes SHA256；按path升序 `{path}\t{bytes}\t{sha256}\n`（真实TAB/LF）UTF8拼接再SHA256。新source聚合 `a27296c557af763728365e197ce7c5ec541203f9b40445b1033509cbf8cc2fb4`；App/Vendor聚合与原F2相同。Vendor verify仅结构/receipt，实际payload另外绑定；本轮未verify/fetch。

[准备回执](keyboard-wake-host-activation-fix-001-a2-validation-artifacts/prepared-check.json)记录23项authored、五hash、清单聚合和实际dirty粒度。方法列表：[23项身份](keyboard-wake-host-activation-fix-001-a2-validation-artifacts/required-gate-methods.json)。23只是该class覆盖要求，完整套件总数不预先钉成任何值，按实际xcresult记账，不凑数重跑。

## 冻结验证顺序（执行另授权）

[完整命令](keyboard-wake-host-activation-fix-001-a2-validation-artifacts/frozen-commands.json)按序串行执行，使用新隔离run/backup根；不创建替代工作树、不源码编辑、不stage/commit/push。

1. AUTH后Entry现场重核身份、当前输入、设备/独占/进程、工具链、Vendor verify及完整新before保护。
2. 本地变更分类表（未提交源码必须full）、tracked及untracked whitespace、.kos JSON、CI helper tests、Entry/环境合同链接。
3. 四Swift严格lint；不自动in-place format或修源码。
4. KeyboardCore `swift test`，独立`--build-path`。
5. RimeBridgeTests Debug `test`。
6. Universe Keyboard Debug完整`test`，xcresult必须显示当前23项全Passed/0skip/0fail。原17方法名和6新增方法集合均按清单核验；未列出或跳过/失败停止，不能把发现数当实际执行数。
7. 同destination Release配置`build`，不是发布。
8. 同destination签名Keychain冻结唯一专项，不用其1/1删除无签名全套的skip。
9. 只读结果解析、输入再核、完整after库存/差量及必要after保全、独立证据交付。

全部iOS测试绑定原UDID `405D994F-28CB-4F89-BB22-B64AD81C05A2`，`-parallel-testing-enabled NO`；公共参数 `SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES`。普通job `CODE_SIGNING_ALLOWED=NO`；Keychain专项 `CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO`。不默认换CI机名iPhone17Pro，不并行另一套runner。

默认**不安排额外focused23**，完整suite已实际通过23项则不得重复。若完整suite覆盖缺失，保存缺口并停止，由具体补跑授权另冻结命令，不能临时补跑隐藏full-suite failure。

执行日志必须证明四个新Swift文件实际编译、原七条actor诊断仍为0且无新增本切片Swift warning/error；exit0不能代诊断检查。AppIntents工具metadata warning与Swift诊断分开记录，不泛称全日志zero-warning。不是hosted完整CI等价；本标签为“完整测试与构建矩阵，外加适用本地分类与轻量检查”。

## 环境、残项与退出

[环境合同](keyboard-wake-host-activation-fix-001-a2-validation-artifacts/environment-contract.md)冻结精确device、静默完整before、provenance例外决策、after保全、恢复提案和首失败停止。root准备期间未simctl、检查进程、读取live容器、复制备份或创建run/backup目录。现场Booted/独占/进程与live工具链UNKNOWN，故不Ready；设备谱系与历史工具链不冒称当前现场。

原30skip身份：[Bridge20历史列表](keyboard-wake-host-activation-fix-001-a2-validation-artifacts/historical-rimebridge-skip-list.json)、[App10历史列表](keyboard-wake-host-activation-fix-001-a2-validation-artifacts/historical-app-keyboard-skip-list.json)。旧Product处置只F2，不继承；本阶段是否接受同一30项未验证非阻塞，可由Human另明确决定。新skip、23gate任一skip/fail不在该提案内。

预算提案**180分钟**，首失败/超时先到停止；须由执行AUTH确认，从其Entry第一步起计，包含环境/备份/矩阵/Exit，不续旧预算。不自动重试、修源码、终止进程或恢复。

矩阵绿后只交付新候选证据，不能自行解除Architecture A2-F1。下一独立定点复审另冻结round2候选/范围/预算/ACK及报告写出预检；旧Quality超时不在本Entry处置。真实通知/appex有效回调、Maps及owner/receipt仍属F4，未授权。

## 执行授权所需决定

- 本次完整测试/构建矩阵、180分钟及runner安装/启动副作用，before与必要after私有保全。
- 原精确模拟器的新鲜独占、静默条件及上轮后是否安装/部署/打开过App。
- 本阶段是否仅接受已列同一30skip为未验证非阻塞；是否允许新副本仅provenance新增/改写这一狭义metadata例外。未决定则保留相应停止点，不擅自放宽。

本准备已完成治理文档和只读hash/路径核验；未编译、测试、模拟器操作、Git发布、Release或备份删除。CHANGELOG未授权不改。[产物manifest](keyboard-wake-host-activation-fix-001-a2-validation-artifacts/manifest.json)。
