# C7 候选栏探针绑定修复本地交付

本轮Human授权直接按建议继续。先完成定点只读来源核查，再按[单文件切片/Entry](../plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-probe-ui-binding-slice-2026-10-02.md)执行。root Keyboard Experience/Executor唯一writer；Parent/child仍Active，根因未确认，无运行/Gate/Release结论。

## 改了什么 / 为什么

唯一源码文件 `Keyboard/Controllers/KeyboardViewController+Presentation.swift`，只增加12行：三处 `candidateBar = makeCandidateBar()` 紧接专用Debug条件下刷新probe，各附意图注释。相对本轮before [精确patch](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-probe-ui-binding-artifacts/patch.diff)不含既有改动。makeCandidateBar的构造内install/fill会refresh旧candidateBar或nil；赋值后刷新将当前显示状态和idle task落到新对象，避免新按钮仅依赖后续候选/生命周期事件触发。

这是明确静态接线缺口修复；没有运行对象/touch/task/标题实测，不能证明它就是原一分钟延迟或冻后观测文字的唯一根因。Core lifecycle/TTL/缓冲/owner/attempt、两秒显示policy、触摸手势和布局、输入及RIME部署未修改。普通Debug/Release无新增probe调用。

## 验证与新身份

[静态命令回执](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-probe-ui-binding-artifacts/static-checks.json)：专用Debug `swiftc -frontend -parse -D DEBUG -D KEYBOARD_WAKE_OWNER_PROBE`、普通Debug `-D DEBUG`、普通Release不带宏，共三parse exit0；`swift-format lint --strict --configuration .swift-format` 单文件exit0。语法parse不是类型检查/编译或UIKit运行证据。简单接线不新增镜像实现的测试；未运行Core/iOS target或完整套件，未build/install/device/LLDB/Maps。仍需后续阶段具体授权/Entry，不拿旧运行结果算新源码通过。

[新source/build-input身份](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-probe-ui-binding-artifacts/source-identity.json)：原571输入中仅Presentation一项变化，新规范化571字典SHA `5f16aa1031b1ee4a90d72e4d15693e3656b0c746bcd71a10874e90655a0269c9`；before file `42ce407eb15cc851cb0ea2c6a11819604f334d5c61c62b2dbd6ff226f0cfbbfa`，after file `767c2817054484d4d4c328cb7a8deaf676509b76bbc3cb45868b6e3cf721319a`。原候选产物/installed78及原5行运行链绑定旧源码，仍保存有效历史，不绑定此修复。分支/HEAD原身份不变，不暂存/提交/推送/切分支/清理。

## 下一切片

建议先定点独立Quality静态补审：仅三处新对象绑定顺序/Debug排除/不改Core与输入合同，报告明确无actual UI证明；保留原正常路径验收Partial及账本超时。补审应重新freeze本轮输入/预算，不复用旧已耗尽轮次。随后新的配对产物和实际iOS阶段才讨论安装/UI及Maps，须fresh精确模拟器独占和恢复Entry。当前原probe已消费，不自动reset/rearm。

两UI现场残项、caller-stack/UTC限制、57历史格式diagnostics、skip未验证及旧AppGroup未恢复均保留。无需CHANGELOG或架构合同改动；仅当前任务Assignment镜像同步，无M-02触发。

## 新范围定点独立补审交付

Human直接继续授权下，复用独立GPT6 Luna Quality，新lane QUALITY-C7-PROBE-UI-BINDING round1；7输入/三文件限定源码行/P1-P3，4底层calls/240s hard/150soft。冻结[packet](../reviews/quality-c7-probe-ui-binding-r1-packet-2026-10-02.json) digest `d76b28381d5789ed0a013e08cee163027fe85f82e990a192e4b55348248c4ff1`。这是本轮源码静态补审，不是旧运行验收续轮。

原[报告](../reviews/quality-c7-probe-ui-binding-r1-review-2026-10-02.md)与[usage](../reviews/quality-c7-probe-ui-binding-r1-usage-2026-10-02.json)已一起落盘并按原字节保存：P1 Covered，P2/P3 Partial，整体Partial。7/7输入hash matching，2实际exec_command调用，自报另一次functions包装语法错误未产生底层调用；usage terminal198.704458s<240hard但>150soft，call2 end为null，平台/会话最终完成时刻未另核，不能说完整流程绝对符合hard。报告SHA `393ba44def7f311e413ebf668ab0437b1957f03a0c99a66ee397e37980781c5d`。

协调者发现交付矛盾：报告P2正文称单Presentation文件/无Core输入合同改变，usage却single_presentation_file_only=false；patch头before/Presentation.swift与after/Presentation.swift是同源码的缩短before/after标签，不能单凭标签判另一源码。P3正文说明现场根因未知、旧runtime不可承接，本来就是packet静态结论限制而非范围内runtime必需证据；报告未给Partial所缺具体scope证据。root不替独立reviewer改判。已要求仅在原hard内补一致性，随后在hard结束后interrupt，未新工具/新预算补正；原输出/缺口保留，无Positive晋级资格。

实现本地交付完整，但独立静态意见尚未闭环。后续如Human另授权，只需定点报告/ledger逻辑一致性补正，不重复源码修改或运行采集；真正新候选build/actual iOS/安装/UI/Maps仍各需范围和fresh Entry。本轮不请求扩大设备权限。
