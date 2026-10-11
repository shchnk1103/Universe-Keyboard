# C7 探针候选栏绑定最小本地切片

Human：“OK，那我们接下来做什么呢？授权你直接按照你的建议继续”。root选择先定点核查UI入口可靠性，确认候选栏构造时序存在明确静态缺口，再将实施收窄为单文件三处Debug接线。本轮不以未知现场原因猜修；不宣称按钮延迟或标题问题根因已确认。

## Scope / Ownership / Entry

Keyboard Experience primary / root Executor唯一writer，Core只作已冻结合同输入不修改；root新scope ACK在源码前成立。原worktree branch `codex/keyboard-wake-v3-compatibility-gate`，HEAD `84b9c19227330b0fe6ff391be001ee398010fd6a`；完整2819非忽略文件before hash/full dirty、单文件原字节在 `/private/tmp/ukey-wake-probe-ui-binding-20261002`。其余既有改动保留，禁止暂存/提交/推送/重置/切分支/替代worktree。

源码allowlist只有 `Keyboard/Controllers/KeyboardViewController+Presentation.swift`。在reloadKeyboard及reloadKeyboardContent两个compact候选栏分支（总三处）中，`candidateBar = makeCandidateBar()`之后、加入布局前，通过 `#if DEBUG && KEYBOARD_WAKE_OWNER_PROBE` 调用已存在的refreshWakeOwnerProbeControls。注释解释构造期间candidateBar仍指旧对象，必须绑定新对象后刷新。

## 已确认事实 / 待证假设

makeCandidateBar内先安装按钮、fillCandidateBar，再return；install和fill均调用refresh，后者从controller.candidateBar取对象。Swift赋值在RHS构造返回后才替换candidateBar，新按钮默认隐藏；现三个赋值点未补refresh。构造过程中刷新旧bar/nil以及取消idle task是确定接线缺口；后续事件才refresh新bar是可能延迟路径。

尚未取得UI现场内部touch/idle/task/候选对象/标题值，不能证明本轮一分钟延迟或冻结后Human仍见观测的根因。已有snapshot5行/owner1/receipt1及原正常路径报告不改变；单轮frozen不可由UI文字视为可再arm。

## 约束与分阶段验证

不改two-second policy、probe lifecycle/TTL/容量/borrow/owner恢复、候选布局尺寸、触摸识别、输入处理、RIME部署或用户合同。普通Debug/Release不编译新增调用。仅静态本地核验：最终file Swift syntax parse（专用Debug/普通Debug/普通Release分开），单文件diff/保全。该简单接线不新增镜像实现的测试；既有showsControl/Core测试仍只覆盖纯policy，不称UIKit验证。

新源码改变候选identity：原installed78及运行证据仅旧候选有效，不能复用为新build/运行通过。实际iOS target/配对候选构建/独立定点评审/安装及UI验证为后续阶段，须有新范围、冻结输入和fresh exactdevice独占/恢复Entry；本轮不操作Simulator/build/test/install/LLDB/Maps/Release。其余57格式diagnostics/skip/账本hard超时与原Partial保留。无需CHANGELOG或架构合同变更，无M-02生命周期触发。
