# Assignment: KEYBOARD-WAKE-HOST-ACTIVATION-FIX-001 — 宿主激活配对恢复

Policy: 1.0.0 — [Assignment Policy](../ASSIGNMENT_POLICY.md)。未opt-in KOS2.2 profile，不调整.kos/project.json。

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Blocked — F3 Architecture A2-F1首帧旧回调防护缺口；Quality审计残项保留 |
| Current phase | A2新候选完整矩阵已完成、gate23/23，精确before已机器恢复；新有界A2独立复审获授权，待ACK/交付；F4未Ready |
| Material non-claims | 未F4安装/Maps/Release；矩阵runner安装副作用已恢复，旧App运行健康本轮未试打；F3未双Gate通过 |
| Next handoff | 原Architecture reviewer新round2定点A2复审；旧Quality预算残项保持，F4另授权 |
| Residuals | [设计R2交付及哈希文字差异](../evidence/keyboard-wake-host-activation-minimal-fix-architecture-r2-validation-2026-10-04.md)；历史skip与父accepted-unverified不继承为本任务通过 |

---

## Assignment Decision（Human已批准，Executor修订为Grok）

- Assignment Authority / Product Approver：Human Product Lead（本线程用户）。
- Decision Source / Date：2026-10-04 Asia/Shanghai；Human“我想要让 grok 来做后续的源码实施，现在我先批准草案中的责任绑定及 F1 五文件实施”。本决定批准F1并将原拟议root Executor替换为Grok，其余责任保留；[授权决定](../product-decisions/KEYBOARD-WAKE-HOST-ACTIVATION-FIX-001-f1-grok-authorization-2026-10-04.md)。
- Domain Owner：Keyboard Experience Maintainer，由root在本任务承担；Core协作仅只读，不授Core源码修改。
- Executor：Grok，唯一五文件源码writer；root仅Coordinator/Domain Owner及治理文档writer，不与Grok并写源码。
- Environment Executor：root负责未来F2；F1无模拟器执行，新环境Entry未满足。
- Human Dependency：Human Product Lead已批准F1；负责把实施包交给Grok；未来F2设备独占、F4人工Maps操作分别单独确认。
- Architecture Reviewer：复用独立GPT6 Luna `/root/m2r2_arch_r1`；设计R2已交付，最终实现审查另需精确候选packet、ACK与新预算，不自动续R2。
- Quality Reviewer：复用独立GPT6 Luna `/root/m2r2_quality_r1`；新实现Quality另冻结packet/预算/写出预检并ACK，旧未写出残项不冒充本任务交付。
- Handoff Target：Human Product Lead，随后上述Architecture/Quality reviewers；不创建新线程。

以上责任由Human批准，Executor按同一消息修订为Grok。root已ACK本轮Domain/Coordinator范围与冻结输入；Grok ACK及实施交付已由Human转交，root按交付原件与当前字节记录F1执行状态，不补造历史Entry机器回执。未来审查者ACK在F3精确packet阶段完成。

## Scope / Non-goals

仅五文件生产/测试/接线差量，既有dirty冻结为输入，不归本修复所有：

1. `Keyboard/Controllers/KeyboardViewController.swift`：当前展示状态、共享恢复入口、可见性/首帧/canary前置许可接线。
2. `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift`：成对host通知及同context过滤，已有首帧入口复用。
3. `Keyboard/Services/KeyboardHostLifecycleRecoveryGate.swift`（新）：MainActor内存事件/action模型，无UIKit/Core依赖、无I/O。
4. `KeyboardTests/KeyboardHostLifecycleRecoveryGateTests.swift`（新）：真实gate状态序列及批准action调用计数测试；不冒称真实通知/appex控制器覆盖。
5. `Universe Keyboard.xcodeproj/project.pbxproj`：gate源码明确加入Keyboard与KeyboardTests Sources，沿既有跨target模式，不改签名/bundle/deploy/runtime开关。

不改Core/RimeBridge、部署、诊断wire协议、UI布局、宿主输入合同；不恢复旧composition、不重投故障按键、不按键自愈或timer重试；不操作原模拟器容器/进程/LLDB，不安装、不清备份、不Git发布、Gate或Release。缺第六源码文件或Core新协议时停止。

## Required Inputs

- [原五文件方案](../plans/keyboard-wake-host-activation-minimal-fix-proposal-2026-10-04.md)和[状态合同](../plans/keyboard-wake-host-activation-minimal-fix-state-contract-supplement-2026-10-04.md)作为同一实施设计输入。
- [R1 Partial](../evidence/keyboard-wake-host-activation-minimal-fix-architecture-r1-validation-2026-10-04.md)历史原件、[R2条件通过](../evidence/keyboard-wake-host-activation-minimal-fix-architecture-r2-validation-2026-10-04.md)及root身份纠字receipt；不重写原独立报告。
- ADR0002、UI/keyboard-core/test-release playbooks、AGENTS、PROJECT_CONTEXT、UI_STYLE_GUIDE、ASSIGNMENT_POLICY、AI_WORKFLOW；[F0 manifest](../evidence/keyboard-wake-host-activation-fix-001-f0-artifacts/entry-manifest.json)冻结原字节及只读依赖。
- 原工作树/branch/HEAD、完整dirty状态和两新路径不存在。旧dirty作者无法从git推定；保留全部内容，后续只审本次新增差量。
- 父诊断有界Completed与旧rollout Active均保持，新增修复不继承其验证/环境/残项接受权限。

## 分阶段授权与Entry

| 阶段 | 范围 | 必需Entry / 当前状态 |
|---|---|---|
| F0 | 文档准备 | 当前已授权、Prepared；源码未实施 |
| F1 | 五文件本地实施、测试编写、范围内swift-format及diff检查、冻结最终差量 | Human已批准F1；root Domain ACK完成；Grok已交ACK/五文件实施与私有交付，root字节复算通过；历史writer核验/约30调用为Grok记录而非完整root审计；预算60实际toolcalls/60分钟先到停止，预留最后4calls冻结/交付，超限需Product决定 |
| F2 | gate实际target+完整CI等价验证、配对产物字节绑定 | 另授权；F1候选冻结、工具链/Vendor、原精确模拟器新鲜独占、完整备份及恢复方案必须满足；测试runner安装/启动属于环境副作用，不能借F1执行 |
| F3 | 最终同候选Architecture/Quality独立审查 | 另授权精确范围packet/预算/输出写出预检/ACK；设计R2不替代实现审查，禁止自动续旧budget |
| F4 | 精确候选安装与单轮Maps/owner回归 | 另授权；F2/F3满足、fresh独占与备份/恢复、明确Human操作与Exit；实际通知/owner/receipt与键盘结果未证不得称修复完成 |

阶段依赖是本新Assignment已批准合同，不能回头豁免旧rollout门禁。本轮先记录Assigned；Grok在满足即时Entry后交ACK与Ready/Active凭据，root据凭据镜像生命周期；不要求未来未启动审查者提前伪造ACK。F3 reviewer ACK属于F3自身Entry，未满足阻止F3，非自动启动。

## Exit Criteria

F1交付：恰五文件差量、之前三文件字节与原dirty保全、新gate/action及列举状态序列测试 authored、Swift6安全隔离、范围内严格格式lint和diff检查，最终source/patch hashes与未执行测试说明。format若扩大到历史无关行，停止并保留原内容，不全仓格式化或自动修其他dirty。

整体修复完成还须F2完整质量证据、F3独立实现/Quality、F4正常与AppSwitcher直接返回后的候选/宿主更新及owner/receipt证据。至少覆盖重复通知、appear交错、hidden/foreign/no-window、首帧取消重arm/late tick、canary deny与前置许可、旧请求失效/不清新composition。gate单测不能代controller或系统回调验证。未复现记inconclusive，不强推根因。真实设备/Release结果不从模拟器外推。

F2需AGENTS完整矩阵：KeyboardCore swift test；iOS RimeBridgeTests Debug test；Universe Keyboard Debug test（实际执行新KeyboardTests）；同destination Release配置build。严格Swift6参数、命令、工具链、xcresult、完整skip身份与actual counts落盘；必要gate focused run不替完整矩阵。Release配置build不是Release发布。历史29/30skip处置不继承；新skip另由Product决定，不凑数重跑。CHANGELOG在修复验证/交付阶段另明确授权追加，不能用第五文件外改动偷扩F1。

## Stop / Revalidation

身份/hash/新路径absence漂移、发现并发writer、需要五文件外源码、context实际不匹配、Core许可/ready协议不能复用、格式化扰动历史无关内容、环境/backup/恢复不满足、任一预算耗尽：停止相应依赖阶段并保存交付，不reset/revert全文件、不替换worktree、不顺手追加Core scope。权限、状态表/依赖/源码/工程/Vendor/toolchain变化均重验证；新候选review不复用旧source结果。父Completed不重开，旧独立Partial/skip保持。

## F1 Grok delivery received — 2026-10-04

[接收与核验](../evidence/keyboard-wake-host-activation-fix-001-f1-received-2026-10-04.md)冻结五文件候选；hash/baseline/patch/依赖符合交付。格式PASS摘要与分组工具账本限制明确，未执行测试/运行验证，不称独立acceptance。下一F2 Entry及授权，整体任务尚未Completed，Grok停止源码写入。

## F2 execution authority and environment Entry — 2026-10-04

[Human授权](../product-decisions/KEYBOARD-WAKE-HOST-ACTIVATION-FIX-001-f2-execution-authorization-2026-10-04.md)接受root执行、180分钟/首失败停止及精确独占。现场身份与冻结输入通过，旧扩展仍活跃，静默backup待满足；测试尚未启动，不自动SIGTERM/恢复/源码修复。

## F2 delivered / blocked handoff — 2026-10-04

[执行交付](../evidence/keyboard-wake-host-activation-fix-001-f2-validation-2026-10-04.md)所有required job exit0，gate17实际通过；30skip获Human仅F2两次精确接受。新test7actor诊断未接受；测试后Group待部署且容器UUID变化，before保护存在、未恢复。当前Blocked不是父重开；下一精确恢复及Grok测试初始化修正各自授权，不自动续F1/F2或F3review。

## F2-before restore received — 2026-10-04

[接收核验](../evidence/keyboard-wake-host-activation-fix-001-f2-restore-received-2026-10-04.md)确认Grok恢复交付与live字节一致，before旧安装及RIME状态恢复；不称输入健康/新修复验证或全部metadata相等。仅恢复依赖解除，7actor诊断保持Blocked；下一健康确认和单测试修正各自授权。

## F2-before恢复后人工健康确认 — 2026-10-04

[恢复接收记录](../evidence/keyboard-wake-host-activation-fix-001-f2-restore-received-2026-10-04.md)追加Human人工健康结果：独占、两项诊断关闭、完全访问开启、候选与提交正常。旧版本恢复健康依赖满足；7条actor诊断仍为当前Blocked原因，未验证新修复或Maps，F3/F4权限不扩展。

## F2 actor-test-fix Prepared Entry — 2026-10-04

[单文件修正Entry](../evidence/keyboard-wake-host-activation-fix-001-f2-actor-test-fix-prepared-entry-2026-10-04.md)仅覆盖`KeyboardHostLifecycleRecoveryGateTests.swift`的同步`setUp`七条MainActor警告。状态Prepared、未执行、未改源码。旧版本健康确认不得作新候选证据。交Codex核验后再申请实施与测试环境授权。

## F2 actor修正接收与定点复验Hold — 2026-10-04

[接收及停止交付](../evidence/keyboard-wake-host-activation-fix-001-f2-actor-retest-validation-2026-10-04.md)：两行单测试差量符合，1156输入绑定；Human授权focused复验及原扩展一次SIGTERM。新鲜备份复制仅provenance新增903/改写122差异，原校验exit1，测试未启动，等待明确metadata例外处置。旧版本仍未被测试安装替换；7actor诊断尚未复验，Blocked保持，F3/F4未授权。

## F2 actor定点复验完成 — 2026-10-04

[实际交付](../evidence/keyboard-wake-host-activation-fix-001-f2-actor-retest-validation-2026-10-04.md)：Human仅本轮接受provenance备份例外后，root复核通过并执行一次focused test；新测试17/17 Passed/0skip/0fail，七条原actor诊断逐项0，其他四源码与1156输入保持。三组before/after完整相等，无需恢复。七条诊断Hold解除，生命周期Active；F3独立审查及F4实际安装/Maps另授权，不称完整矩阵新字节重跑或修复完成。

## F3独立审查授权 — 2026-10-04

Human“可以按照你的建议继续”授权root此前建议的F3独立实现与Quality审查，未扩展至安装/设备/Maps。五文件当前候选绑定原F0冻结字节及单测试修正；Architecture责任仍为`/root/m2r2_arch_r1`（旧runtime不在live清单，使用同名新独立runtime），Quality复用`/root/m2r2_quality_r1`。两lane各24工具调用/20分钟自限，8/16/21调用检查点，预留最后3调用写交付；不自动续预算。只读源码/已有证据，报告写各自private目录，由root原件归档；F4仍另授权。

## F3独立交付及阻塞 — 2026-10-04

[双lane交付](../evidence/keyboard-wake-host-activation-fix-001-f3-independent-validation-2026-10-04.md)：Architecture A2-F1首帧代际/arm身份缺口使整体Partial/incomplete，F4不能晋级；Quality内容条件通过与1258秒超预算/stop_reason冲突分别保留。两位均复用原runtime，不是新Architecture runtime；前准备文字由此明确纠正。生命周期Blocked，建议只准备Grok定点修正Entry；未授新源码或F4。

## A2-F1 first-frame guard Prepared Entry — 2026-10-04

[首帧防护Entry](../evidence/keyboard-wake-host-activation-fix-001-a2-f1-first-frame-guard-prepared-entry-2026-10-04.md)拟改Controller、Bootstrap、RecoveryGate、GateTests四文件；pbx保持。generation+arm token传入回调，失活/重arm后旧tick为no-op，仅当前可见窗口可arm。状态Prepared、未执行、未改源码。Q2-R1与Quality超时不在范围。交Codex核验后再申请实施与测试授权。

## A2-F1四文件修正接收 — 2026-10-04

[接收核验](../evidence/keyboard-wake-host-activation-fix-001-a2-f1-received-2026-10-04.md)：四hash、原F3字节独立重建、pbx不变、其余1152构建输入符合；原17方法名保留加6新例共23authored。Grok已停止写入，format/预算仅作者摘要。新候选编译/实际target及A2定点独立复审尚未执行，Blocked保持；后续环境/F4/Maps不自动授权。

## A2新候选验证Entry准备 — 2026-10-05

Human于2026-10-04“授权你来准备新候选验证 Entry”；root[Prepared交付](../evidence/keyboard-wake-host-activation-fix-001-a2-validation-prepared-entry-2026-10-05.md)冻结五hash、重列358/168/630文件共1156行与13pinned输入，23项authored方法和12步骤命令。没有执行测试/构建/模拟器或创建run/backup。新执行Entry的实际device/独占/进程/工具链UNKNOWN，不能Ready；执行预算提案180分钟与first-failure stop待AUTH。旧skip与provenance处置不自动移植，新阶段可由Product在执行AUTH狭义决定。修复Blocked保持，独立A2复审/F4另授权。

## A2新候选完整矩阵交付 — 2026-10-05

Human批准180分钟执行、原设备独占及本阶段同一30skip/provenance狭义处置；[实际交付](../evidence/keyboard-wake-host-activation-fix-001-a2-validation-2026-10-05.md)12步骤exit0，Core1194、Bridge85/20skip、App444/10skip、gate23/23、Release构建及signedKeychain1/1，四Swift实际编译且原七actor诊断0，冻结输入全等。测试改变安装及Group部署状态，完整before/after保全，精确恢复Prepared但未执行。当前Blocked依赖恢复/新候选A2独立复审及旧Quality预算残项处置；F4/Maps不自动授权，父Completed保持。

## A2 before恢复及独立复审授权 — 2026-10-05

Human“OK，那我授权你继续吧，直到完成新候选的 A2 独立复审为止。”批准root精确恢复及provenance新增/改写例外、原Architecture reviewer新round2有界复审。[恢复交付](../evidence/keyboard-wake-host-activation-fix-001-a2-before-restore-2026-10-05.md)两读机器通过，不要求人工健康作为静态A2依赖。review仅A2-F1首帧防护差量/相关接线/23项证据与边界，24calls/20分钟先到停止、预留3calls交付，8/16/21检查点；禁止续旧budget、源码/build/test/simulator或F4，旧Quality审计残项不处置。
