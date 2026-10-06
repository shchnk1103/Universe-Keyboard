# Grok F1 实施交接包 — 2026-10-04

以下可直接复制给具备本地仓库读写能力的Grok。Grok为Human指定唯一F1源码writer；root不并写源码。交接文件准备好不代表Grok已接收/ACK。若Grok仅聊天且无法读取本地文件，只能提供方案，不宣称执行；不要另建worktree或猜测重建历史内容。

## 可复制接手指令

你作为Grok接手 **KEYBOARD-WAKE-HOST-ACTIVATION-FIX-001 的 F1 五文件源码实施**，Human已授权，具体生效边界以以下Assignment/Product决定为准。始终中文，注意可读性与边界注释。原父诊断已Completed，不重开；现有owner缺失是修复假设输入，不是已证通知根因。

唯一工作树：`/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard`
branch：`codex/keyboard-wake-v3-compatibility-gate`
HEAD：`84b9c19227330b0fe6ff391be001ee398010fd6a`

先只读核验identity、完整dirty、staged0、manifest所有required inputs字节与3existing/2absent。完整dirty允许root后续治理文档导致路径数变化，不能用总数相同替代源码hash，也不能据此清理。不要创建替代worktree、reset/clean/stage/checkout/commit/push。既有dirty全部保留，不用git HEAD作本任务差量基线：三existing文件的当前冻结字节才是基线。

先按AGENTS/KNOWLEDGE_INDEX/ACTIVE_WORK/READING_MAPS/ASSIGNMENT_POLICY/AI_WORKFLOW读取入口，涉及实施再读PROJECT_CONTEXT、UI_STYLE_GUIDE、keyboard-ui/keyboard-core/test-release手册与ADR0002。随后必读：

- `docs/assignments/keyboard-wake-host-activation-fix-001.md`
- `docs/product-decisions/KEYBOARD-WAKE-HOST-ACTIVATION-FIX-001-f1-grok-authorization-2026-10-04.md`
- `docs/plans/keyboard-wake-host-activation-minimal-fix-proposal-2026-10-04.md`
- `docs/plans/keyboard-wake-host-activation-minimal-fix-state-contract-supplement-2026-10-04.md`
- `docs/evidence/keyboard-wake-host-activation-minimal-fix-architecture-r2-validation-2026-10-04.md`及对应独立report/root一致性receipt；独立packet文字抄录错误已披露，真实packet hash以receipt为准。
- `docs/evidence/keyboard-wake-host-activation-fix-001-f0-artifacts/entry-manifest.json`和`dirty-status-before.txt`。

确认全部精确输入、文件可写、五路径无其他活动writer之后，先给出Grok Executor ACK：身份/hash/new-path absence、保全dirty、可执行工具、scope/预算及Entry通过。不要伪造尚未发生的ACK或忽略冲突。满足后从ACK起计F1预算60实际工具调用/60分钟，先到停止，最后4calls预留交付核验；不是从root准备交接的时间起计。不需重复请求Human已批准的F1。

**仅以下五文件可改源码：**
1. `Keyboard/Controllers/KeyboardViewController.swift`
2. `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift`
3. `Keyboard/Services/KeyboardHostLifecycleRecoveryGate.swift`（新）
4. `KeyboardTests/KeyboardHostLifecycleRecoveryGateTests.swift`（新）
5. `Universe Keyboard.xcodeproj/project.pbxproj`

先完整保存三现有文件的当前字节作为本次差量基线到独立小型私有输出目录，并核对manifest hash；root的F0小型副本仅辅助，失效时不能凭猜恢复。只改本次新增差量，不抹历史dirty。

实现必须遵守已审核状态合同：MainActor generation/context/hidden-appearing-visible，pending单次消费，通知对称context过滤，首帧未激活仅重arm原两帧门，已激活才共享resume；canary许可必须在可能创建owner之前判定；visibilitySuspended只能beginVisibilityResume()==true后恢复，fence/failed不授baseline。重复active不得清新composition；真实visibility弃旧composition，不重放输入。使用现有Core协议，不改Core/RimeBridge、wire、部署、UI布局、按键自愈或timer。gate无UIKit/Core/I/O依赖，明确加入两个target Sources。测试只证gate真实状态/action及执行计数，不说证明通知/控制器/runtime。

F1只允许**编写测试**；不能运行测试、swiftc/xcodebuild/compiler、swift test、simctl、LLDB、安装/部署/恢复或Maps。可用范围内xcrun swift-format format/lint和diff检查；若格式化改到历史无关行，停止，不全仓修格式，不reset整文件。需要第六文件/Core新协议、上下文不匹配、hash/身份漂移、其他writer或预算耗尽时停止并保存交付，交给root/Product决定。

**交付到你自己的私有输出目录**（建议`/private/tmp/ukey-host-activation-fix-grok-f1-20261004`；工具环境不支持时报告实际路径），不要修改root拥有的Assignment/镜像或历史证据。包含：ACK及start/end UTC、实际工具调用账本、三原文件字节/hash、逐文件新增差量patch、新文件内容与最终五文件hash、完整受影响路径清单、format/lint/diff结果、全部测试authored/not-run及原因、R2条件对应实现位置、剩余风险/超范围需要。与当前冻结字节比较，不拿全部git diff归本任务；确认三文件既有内容保全。给出总结和绝对产物路径，root据原件更新治理记录及准备后续验证。

不要把F1实现交付叫修复已验证/Release；F2真实测试、F3最终独立审查、F4安装/Maps运行效果均待后续授权。交付后停止源码写入，等待root核验。

## 权威与交接边界

[Assignment](../assignments/keyboard-wake-host-activation-fix-001.md)、[Human授权](../product-decisions/KEYBOARD-WAKE-HOST-ACTIVATION-FIX-001-f1-grok-authorization-2026-10-04.md)、[F0冻结manifest](../evidence/keyboard-wake-host-activation-fix-001-f0-artifacts/entry-manifest.json)。root完成文档与只读Entry预核，不代Grok实施/ACK，不自动创建Grok线程或发送外部消息。Human可以将上面的指令交给Grok；Grok交付后root负责独立验收流程协调。
