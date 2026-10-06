# C7-C 取证执行包：模拟器操作前准备

## Scope / Ownership / Authority

Human 2026-10-02：“那请你先把取证链准备完整吧”。本轮 C7-C-P 仅本地源码/历史产物核验、操作规程、固定传输的离线解析示例及独立定点 Quality。原Assignment角色不变：Keyboard Experience primary、Core secondary，root Current Codex Coordinator/Executor唯一repo writer；Environment Executor=root（本轮只读主机帮助/文件）；独立Quality复用 GPT6 Luna `stage_b_quality`。Architecture本轮不新增架构决策，使用[既有静态审查](../reviews/arch-c7-b1-review-2026-10-02.md)边界，不授予新candidate verdict。Human dependency当前无操作；未来现场Owner为Human Product Owner。

本轮不含产品源码、工程、Swift格式化、项目构建/测试、设备发现/容器读取、Simulator启动/安装/运行/输入/LLDB attach、Git提交推送或Gate。离线示例只演算虚构UInt64，不执行项目代码。下面的命令均为未来授权后的模板，未对进程执行。

## Confirmed Facts / Evidence

- 工作树 `paired-rollout-preflight/Universe Keyboard`，branch `codex/keyboard-wake-v3-compatibility-gate`，HEAD `84b9c19227330b0fe6ff391be001ee398010fd6a`。本轮Entry为2691非忽略文件、607dirty、staged0，完整保全另存。
- [C7-B2 Quality](../reviews/quality-c7-b1-r2-review-2026-10-02.md)仅解决F1；[原Quality F2/F3](../reviews/quality-c7-b1-review-2026-10-02.md)及旧整体Hold保持。1194 host Core通过不是iOS运行证据，57条格式诊断仍未解决。
- [C7-A合同](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-owner-probe-local-slice-2026-10-02.md)：专用Debug并排按钮，未arm且有候选隐藏；arm/frozen后无触摸停手2秒可见，即使旧候选仍在。`观测`只arm，`取证`只freeze/export，不清候选/上屏/恢复。
- [Core transport](../../Packages/KeyboardCore/Sources/KeyboardCore/KeyboardWakeOwnerProbe.swift)默认关闭、实例单轮、600s单调TTL、128记录。freeze锁外编码；只在`withUnsafeBytes`借用范围内，[noinline出口](../../Keyboard/Controllers/KeyboardViewController+WakeOwnerProbe.swift)提供address/byteCount。
- [schedule](../../Packages/KeyboardCore/Sources/KeyboardCore/ThreadAffineRimeSession.swift)在MainActor合同下先读owner!=nil，再调用owner?.accept，记录owner/receipt；receipt只证明接受回执，不证明engine执行、候选应用或host插入。UInt64 epoch/revision不是用户文本。
- 外层[viewWillAppear](../../Keyboard/Controllers/KeyboardViewController.swift)和内层coordinator均记录resumeBegin/resumeEnd；传输无producer/layer字段。原始行逐条保留，禁止去重、推定哪层或计为两次恢复。
- [现有paired products](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7b-artifacts/paired-products.json)是无签名generic SDK编译与build-for-testing后的历史产物，含test-host；尚非已晋级安装候选。当前准备不授予安装资格。

## Decision / 分阶段 Entry

| 阶段 | Owner | 放行证据 | 当前状态 |
|---|---|---|---|
| C7-C-P 准备 | root +独立Quality | 本包/解析规则/离线演算/精确packet及完整审查 | 本轮授权 |
| C7-B剩余验证 | Environment Executor +Quality | 精确candidate、所需实际iOS套件与当前skip处置，开放findings逐项判定 | 未执行；另范围授权+新鲜独占Entry |
| C7-C候选晋级/安装 | root，Product决定 | 源码→构建输入→最终App/appex/Mach-O/签名entitlements绑定、独立review、部署基线/恢复备份 | 未放行；另最小切片 |
| C7-C现场 | root +Human | 下表全部fresh Entry及明确attach/单轮arm/有限read授权 | 未放行 |

未来目标仍是 iPhone 18 Pro / iOS27.0，UDID `405D994F-28CB-4F89-BB22-B64AD81C05A2`。旧独占预约不能代替新鲜窗口。

现场Entry逐项记录actual/unavailable，不用预填通过：1）Human确认本轮独占和可参与；2）实际设备/OS及boot状态；3）候选与installed App/appex bundle ID/version/build、Info/executable/debug dylib/相关Core Mach-O哈希、UUID/dSYM逐项一致，安装与运行进程属于同一candidate；4）正常Debug/Release不含UI探针的证据与专用Debug启用条件分开绑定；5）当前schema/deployment既有健康状态，只观察不部署；6）完全访问fresh确认（窗口开始前）；7）日志、高保真及关联expiry/category键的原值和存在性，已装app恢复方法；8）现有安装包备份/可恢复来源与数据保护方案，无法恢复则不安装；9）真实Keyboard appex PID/executable path/loaded image UUID同安装候选一致，无同名PID猜测；10）断点唯一解析且borrow参数可读；11）正常键盘基线、候选栏空可见观测按钮，无新弹窗；12）run目录/manifest模板和停止协议已就绪。

## Reproduction / Human最短操作卡（未来放行后）

1. root先完成进程身份核验和断点设置；attach时的暂停单独记录，不在输入途中attach。不启用额外诊断，探针不依赖日志/高保真；原开关保持Entry读到的状态。
2. Human在Maps搜索框显示Universe Keyboard，候选栏先为空。确认输入正常与候选更新。这属于arm前基线；必要的选择候选/清理只在本步骤完成，不混进故障现场。
3. 停手≥2秒，点击`观测`一次。root记录arm的UTC操作时段；不再arm。Human输入一个合成字母`n`作为**arm后的基线attempt1**，确认候选更新，然后只在正常基线阶段选择一次候选使候选栏清空。候选选择不在insertKey attempt探针覆盖内，单独记为人为准备动作。
4. Human直接打开App切换器，再直接返回原Maps，不切到设置或其他App。记录切换开始/返回UTC顺序，以及键盘是否关闭重开；出现关闭重开算不同variant，保留记录且不重复补成目标复现。
5. 返回后只输入一个合成字母`n`，作为目标attempt2，报告按键反馈、候选是否更新、输入框是否变化。不同于既往的无更新才算复现；不连续多按，不点候选/展开/地球、不dismiss、不切其他App。
6. 首个异常后停手≥2秒，只点击`取证`。即使旧候选仍在，armed/frozen状态也允许该入口出现。按钮缺失、不响应或没有唯一断点即停止，记录出口未验证；不通过选择候选清空、不另输入、不自动重启/rearm。
7. root在断点暂停且borrow仍有效时按下一节有限导出。export断点命中后不step-out/continue/detach直到复制完成。复制后禁用本轮断点并继续/正常detach；接着只做授权内恢复。TTL到期/overflow也导出作incomplete，禁止自动重试。

操作时段和attempt归属必须由本轮受控仅两次insertKey、原始配对与Human记录一起确认；不能从“最后一条”或墙钟与uptime直接换算。若多按、更多attempt、进程重启、coordinator变更或不可解释时序，则本轮归属inconclusive。基线与目标key内容只用计划中的虚构字母，不保存任何真实搜索词/候选/周围文本截图。调试器本身会暂停主线程，本实验不作无调试器行为/时延结论。

## Export / LLDB有限读取卡

本机无target的`xcrun lldb --batch ... help`已核验命令选项，帮助回执 (`../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7c-prep-artifacts/lldb-help.txt`)不是attach/ABI可用性证明。未来先核验实际symbol与image；可使用：

```text
breakpoint set --func-regex 'wakeOwnerProbeExportReady' --shlib Keyboard.debug.dylib
frame variable --raw-output --dynamic-type no-dynamic-values --no-synthetic --depth 1 address byteCount
memory read --binary --size 1 --count BYTE_COUNT_LITERAL --outfile /private/tmp/RUN/snapshot.bin ADDRESS_LITERAL
```

模板占位需人工替换为已读参数的整数/十六进制地址与新run路径，不执行占位文本。不得EvaluateExpression/`p`/`po`、调用target方法、解引用owner/engine/text proxy、全进程dump、根据x0/x1猜Swift ABI，或把借用address保存后继续进程再读。`frame variable`只指定两参数且关闭dynamic/synthetic，不读其他局部/成员。参数被优化、Swift数据无法静态读、断点未解析/不唯一或borrow范围不能确认：停止，记`export_unavailable`。

读取上限来自源码：(11+128×11)×8 = **11352 bytes**；至少176bytes（header+首次synthetic armed），8字节对齐。address非零且合理对齐；byteCount先验≤11352，未知不读。复制恰好byteCount，不读前后任意内存、不append多个run。文件实际长度必须相同，记录SHA256、命令、断点位置/帧、PID/imageUUID、借用起止UTC与错误；复制失败保留失败，不能当空日志成功。

## Decode / 固定UInt64传输与完整性

专用arm64 simulator只按little-endian UInt64解码；不依赖UUID字符串端序。header有11words（0起始）：`magic=0x4B574F50524F4245, version=1, incomplete(0/1), runHigh, runLow, processHigh, processLow, armedAt, expiresAt, recordCount, overflowCount`。run/process用两个整数word原样配对。

每行11words：`sequence, uptimeNs, stage, coordinatorOrdinal, appearanceOrdinal, attemptOrdinal, ownerPresent(0/1), receiptPresent(0/1), teardownResult, epoch, revision`。stage 1–11依次appearance/armed/insertBegin/insertEnd/suspendBegin/suspendEnd/resumeBegin/resumeEnd/schedule/teardown/replacement；teardownResult 0–3依次notApplicable/completed/failed/cancelled，不解释成产品恢复成功。

拒绝未知版本/枚举、长度/count不符、trailing bytes、sequence不连续、时间逆序/超TTL、overflow>0但incomplete=0；保留原文件不修补。`incomplete=1`/overflow均只作证据不足。即使buffer complete，也只证明本实例的有限记录没有标记损失，不证明所有UIKit callback、engine执行或host更新均被记录。未调用的路径/未记录的阶段无negative证明。

首synthetic armed是seq1、coordinator/appearance/attempt/owner/receipt等均零，绝不能作owner为空。后续UI armed的coordinator0也可能仅代表无coordinator，不能作真实coordinator owner为空。attempt>0的insertBegin/insertEnd必须唯一且顺序配对、同非零coordinator/appearance；schedule必须在两者之间，同一run/process。只输出每条实际schedule上的owner和receipt；不把nilreceipt单独当owner absent。

[离线解析说明与可提取Python片段](keyboard-wake-diagnostic-extension-paired-rollout-001-c7c-offline-decoder-2026-10-02.md)及[18项虚构例子](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7c-prep-artifacts/offline-example-results.json)覆盖完整/缺失/overflow/孤立attempt/零coordinator/重复resume等。只处理fixed metadata，不读取模拟器文件；该示例不能替代真实borrow/export验证。

## Boundary Evidence / 判读矩阵

| 实际证据 | 允许结论 | 不能推出 |
|---|---|---|
| complete、受控attempt2配对、同非零coordinator/appearance、实际schedule owner0/receipt0，前后操作归属清楚 | 返回后该process/coordinator的这一同步schedule读点，owner引用为nil且没有accept receipt | 所有时间owner为空、host activation未触发、owner销毁根因、修复方案 |
| 同条件schedule owner1/receipt1 | 该读点owner存在且有接受回执 | engine完成、RIME健康、候选应用、host上屏 |
| 同条件schedule owner1/receipt0 | 该读点owner存在，无接受回执；交Core owner查accept拒绝边界 | owner为空或队列工作必然执行 |
| 只有synthetic/UI armed、schedule attempt0、coordinator0、无insert配对、出口失败、incomplete、归属不清 | inconclusive，明确缺少哪项证据 | 根因、通过、自动重试/猜修 |
| 没有resume、或重复resumeBegin/End | 仅本缓冲中记录有/无，保留所有行 | 没有发生系统callback、调用两次恢复、识别内外层 |

若同attempt多个schedule或owner状态混合，逐条报告并保持整次故障解释inconclusive；不选择性只取owner0。decoder输出absence候选sequence仅帮助定位，最终结论还需runtime身份、操作归属、完整性与独立Quality。F2仍是观测合同限制，本包不关闭它，不增加engine/host阶段。

## Required Verification / 恢复及交付清单

run manifest必须包括scope授权/Entry、工作树branch/HEAD/最终source identity及manifest SHA、build action/flag/toolchain/destination、App/appex版本/哈希/UUID/entitlements、installed readback、UDID/OS/exclusive窗口、schema/deploy/FullAccess、日志及高保真等键before/after值与存在性、arm/基线/candidate选择/切换/返回/目标key/freeze/read/detach UTC、人为variant与异常描述、raw字节数/hash、decode版本/hash/count/completeness/overflow、所有原始记录/attempt表、停止原因/限制/独立review路径。

结束时恢复**实际Entry原值及原存在性**，高保真原expiry也保留，不把“关闭”当成原值/存在性等价；原值不可读则须Human接受具体限制后才能采集。探针冻结是进程内不可rearm终态，无持久开关需恢复；不能调用reset，下一轮须另授权生命周期与新Entry。恢复旧App若会替换安装/影响数据，必须使用已批准恢复路径，不能自动卸载清数据。未执行安装则不做安装恢复。保留证据与失败情况，root出报告，Quality独立验收；不自动二轮复现或猜修。

## Risks / Documentation Impact

实际iOS套件、最终可安装paired candidate、真实断点参数/borrow、按钮可点、异常复现均是未来命名依赖，当前未验证。57格式diagnostics、旧整体Hold与20+10历史skip保留。当前docs-only，跳过xcodebuild和项目测试；不更新CHANGELOG/架构合同。仅本任务Assignment/状态镜像按交付同步，不产生M-02/Gate/Close。发现必须改源码/观测字段/权限才可取证时停止并交Product决定最小新增切片。
