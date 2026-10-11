# F4-P 独立 Architecture 核验（round 3）

**结论：Pass with conditions，仅限冻结 F4-P 诊断产物与 flags 对另行授权的有界 F4-I 安装资格。** A-P1、A-P2、A-P3 均 Covered。此结论不授权安装或 Maps 操作，也不代表 UI/probe runtime、恢复行为、F4 Ready、whole-F3 或 Release 通过。

## 对象与依据

- Worktree `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard`，branch `codex/keyboard-wake-v3-compatibility-gate`，HEAD `84b9c19227330b0fe6ff391be001ee398010fd6a`；候选 pair digest `d53523dba8c371c67424ff07c79163a66f41e3bc5bb402637cf9ee79ae7579cb`。
- 冻结 packet `architecture-packet.json` SHA-256 `7e358f674b2877afb58073fad78734fb5e8ffe4a417cd668b18378d21038d309`；target reader `architecture-target-reader.json` SHA-256 `02dc2bdaa7247148b51b7cef5f6be0fe78b304d09a23661bd309a0eb386c9f8d`、167286 bytes。reader 自述为无 verdict 的 targeted source/flags/evidence view；其中 private-host 内容按其源路径、SHA、line/JSONPath 作代理证据核验，不声称直接访问 private DerivedData 或设备。
- `$.sources` 的 11 项均有 `sha256 == expected_sha256`。依赖身份 `$.dependency_manifest_identity` 的 358、168、630 项三个 manifest，其 actual aggregate 分别与 expected 相同。F4-P build receipt SHA `bc9467a029d4ece78c861e7acd257976f8f09a33ce5cefd1e2523d3334c17add`：exit 0、33.435 秒、`test_run=false`、`device_instance_targeted=false`、`source_written=false`。以上是构建/身份材料，不是 runtime 结果。

## A-P1 — Covered

独立遍历 frozen reader 提供的全部 20 个 `KEYBOARD_WAKE_OWNER_PROBE` 条件块；除下列 UI probe source 外，其余块没有额外的恢复、部署或引擎模式分支：

| Source（reader 内原路径及 SHA-256） | 条件块行号 |
|---|---|
| `Keyboard/Controllers/KeyboardViewController+CandidateBar.swift` — `ae1b78d5a311f60054914093458b0c78fe3d35923d82b487fd7f30d886074c80` | 39–41, 170–172 |
| `Keyboard/Controllers/KeyboardViewController+InputActions.swift` — `16abce7d6e6752be641ea333cc60706217c9d84211f1007315850acbc62ee2ae` | 20–27 |
| `Keyboard/Controllers/KeyboardViewController+KeyPressFeedback.swift` — `c1d361a34e5aa788a4a518f46cbb7370ff5903e05736a72281da04f859a0fe7a` | 12–14 |
| `Keyboard/Controllers/KeyboardViewController+Presentation.swift` — `767c2817054484d4d4c328cb7a8deaf676509b76bbc3cb45868b6e3cf721319a` | 94–97, 139–142, 155–158 |
| `Keyboard/Controllers/KeyboardViewController+WakeOwnerProbe.swift` — `bca0391355d9a3a60880dfdc08260095d02d6618bf0a38d40bfcc61734a891e9` | 4–100（完整编号源码；一个外层 gate） |
| `Keyboard/Controllers/KeyboardViewController.swift` — `8f2d9a9644da439d3c954f920000e2379bfc6dcba9ddec523d07fbcb86bb155a` | 257–263, 393–395, 493–495, 534–536, 607–609, 663–665, 667–669 |
| `Keyboard/Views/CandidateBar/CandidateBarView.swift` — `5c468dcde434a8b91ac1be692d60d02e6b5139b148edb6a1acaeb0006cf162f8` | 48–54, 99–103, 313–317, 417–463, 703–734 |

`KeyboardWakeOwnerProbe.swift` in KeyboardCore（reader `$.sources[10]`，SHA-256 `679d55e8669d7c68db2fbe58fd1b436cbb19bc61e770f9a701751326fa669af6`）由 `#if DEBUG` 保护；Extension 侧控件、事件 hooks 与 touch observer 另外受诊断 define 控制。冻结 build request（`$.flags_request_receipts[0]`，`build-request.json`，SHA-256 `af100aa4c68fb99f27c5239440f93ef62396ece1f8980416f67a0fae92335d50`）请求 `$(inherited) DEBUG KEYBOARD_WAKE_OWNER_PROBE`。原始 build receipt 表明这是 generic Simulator Debug build，不是测试或设备运行。实际 target invocations 分别见 `$.flags_request_receipts[2].actual_target_invocations.Keyboard[0]` 与 `.Universe_Keyboard[0]`（来源 `actual-compiler-flags.json`，SHA-256 `ea5971c247a1390b0512f9105ff05beebd1c6789fd8aeb82bbbabc1d1a5beec8`）。`Keyboard` Extension invocation 中含启用这些 UI 条件所需的诊断 define；结论绑定于捕获的 Debug 候选，不推广到任意仅设置其中一个编译条件的配置。

源码调用用于安装/刷新隐藏候选栏控件、在输入操作周围记录 begin/end 元数据、观察生命周期边界，以及跟踪触摸标识以决定控件何时显示。这些位置没有分支到 `KeyboardHostLifecycleRecoveryGate`、部署 RIME、改变 session 选择、绕过 proxy 或恢复 composition，也没有引入假的生命周期触发。诊断构建会增加 UIKit gesture observer，可能重排候选栏并在空闲后显示小控件；该观察与布局开销可能影响诊断 UI，尚未在 runtime 测量。它受本次捕获的诊断 Debug 编译条件限制。

## A-P2 — Covered

可复用范围限于未变 source/dependency 身份和历史普通候选 gate 结果。Assignment 记录先前 A2 矩阵及其自身的计数/结果（SHA-256 `94d2c322c2d5aeaefc63939a34ca04ca55cbc73dfb7bbdeb00e3b30f9f5967e0`，第 127–149 行）；frozen ordinary command set 在 reader `$.ordinary_frozen_commands` 中独立标识（来源 `keyboard-wake-host-activation-fix-001-a2-validation-artifacts/frozen-commands.json`，SHA-256 `f22f3199fb2977a018fd73ed06fd5745aacd19e6d3f481312be34d42a580972c`）。它表示命令/证据边界，本身不是测试结果。F4-P 证据明确指出普通矩阵与新诊断 pair 不是同一组已测字节（SHA-256 `c15a598810ca194751c3fa273a7d5b4b0c436b0da51f0943553d59c759988331`，第 34–38 行）。F4 Prepared Entry 也指出先前普通包不含诊断出口，而该 flag 启用诊断 UI 接线（SHA-256 `980a84a4b4ffd329efdf75398ef338c46224a1d0ecac3aafad0213b49ea281bb`，第 15、28 行）。

因此，先前 A2/F3 矩阵可作为其候选身份所对应的普通 source/gate 状态基线；不能用来声称已测试新编译的 probe UI、手势处理、arm/freeze、debugger handoff 或其运行时影响。新 pair 只有 build 证据。已接受的 30 个 skip 仍是未验证 skip，不是通过项，也不构成 Release 证据（F4-P validation 第 34–38 行；F4 Prepared Entry 第 71 行）。本轮不重审 A2/Q3。

**前置测试判断：** 对一次另行授权的有界诊断安装，我没有发现必须在安装前额外单独执行的测试。源码/flags 差异记录观察，不改变恢复/部署选择。F4-I 仍必须先完成其冻结的 fresh Entry、精确 pair 身份和普通输入健康检查，之后才 arm；一次 UI/touch/probe 行为仍要等另行授权的 F4-M runtime 证据才能核验。出现异常或缺少 runtime 关联时应停止或判 inconclusive，不能由静态审查代替。

## A-P3 — Covered

完整 Extension probe 文件（`KeyboardViewController+WakeOwnerProbe.swift`，上述 SHA，4–100 行）只有一条按钮流程：第一次点击尝试一次性 `arm()`；之后点击 freeze，并仅在 `withUnsafeBytes` 的作用域内把有限 word buffer 交给 `wakeOwnerProbeExportReady`（75–99 行）。相邻注释说明该控件不会经由 Core、proxy 或键盘 dismiss 路径（第 76 行）。导出就绪函数只在 callback 生命周期内保留 pointer/count（94–99 行）；这些源码不持久化文件，也不发送 journal/logger 内容。

完整 Core 源码（`KeyboardWakeOwnerProbe.swift`，上述 SHA）定义有限 stage enum（8–27 行）、整数 word snapshot 和有界 pointer borrow（29–58 行）、128 条记录上限与 600 秒生命周期（69–76 行）、一次性 arm 状态（110–136 行）、同步 attempt 配对（149–184 行）、只在 armed 状态记录元数据（186–220 行）、释放 mutex 后复制并 freeze（222–251 行），以及定宽编码、overflow/expiry 行为（253–359 行）。记录字段是时间戳、stage/sequence、coordinator/appearance/attempt ordinal、owner/receipt 布尔值、teardown enum、epoch 和 revision（253–320、362–384 行）；不包含输入文本、按键文本、候选文本或 composition payload。overflow、expiry 和无效/重入 attempt context 会标成 incomplete，不会静默修补。snapshot 是有界内存 word 数组（11 个 header word，加最多 128 条、每条 11 个 word）；本轮未运行实际 debugger transport/read。

这支持 content-free、有界的静态资格判断，也未发现源码级恢复绕过；它不能证明运行中的 UIKit hit testing、安装、已加载模块、callback 解析、capture 或 cleanup 正常。F4 Prepared Entry 的 runtime 顺序与 stop 规则仍独立适用（SHA `980a84a4b4ffd329efdf75398ef338c46224a1d0ecac3aafad0213b49ea281bb`，第 21–28、42–71 行）。

## 边界与最终判定

A-P1、A-P2、A-P3 均 Covered；因此本 Architecture lane 对冻结 F4-P pair/flags 的**有界诊断安装前置资格**为 Pass with conditions。后续仅可使用本次精确 source/pair/Debug flags，并通过另行授权的 F4-I/F4-M Entry；本报告不是安装许可。本轮没有 build、test、lint、模拟器/设备查询、安装、LLDB、Maps 或 Git 操作；不重审 A2/Q3，也不改变源码、产品权威或 Release 状态。
