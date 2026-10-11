# QUALITY-C7-C-PREP round 1 静态补审

## 范围与身份

独立 reviewer 未参与探针、单行修复或本轮 runbook 实现。冻结 packet digest `97838719a772dc3334175fb28082d6d1a659fc71aa56f941ac90d8ac0839e147` 已匹配；22/22 allowlist SHA 匹配，无缺失或差异。只核查 P-Q1 至 P-Q3 的准备协议和冻结材料，没有执行 decoder/例子、build/test、设备或 LLDB 操作。当前 branch/HEAD 实际只读核验为 `codex/keyboard-wake-v3-compatibility-gate` / `84b9c19227330b0fe6ff391be001ee398010fd6a`，与 packet 匹配。

## 判定

| 标准 | 覆盖 | 结论 |
|---|---|---|
| P-Q1 | Covered | 操作顺序、候选/进程身份、失败后冻结、未来阶段闸门及恢复/停止约束均可静态复核。 |
| P-Q2 | Covered | 11/11 UInt64 布局、借用窗口/字节上限、静态参数读取失败停止条件、解析拒绝规则和合成反例互相一致。 |
| P-Q3 | Covered | 仅把完整的非零 coordinator/appearance 配对 attempt 内实际 schedule 的 owner/receipt 作为有限观察；保留 F2、synthetic、重复 resume 与多 schedule 的不确定性。 |

### P-Q1 — 操作顺序与阶段边界

[C7-C 计划](../plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c7c-evidence-chain-plan-2026-10-02.md#L21) 先列出准备、C7-B剩余验证、候选晋级/安装和现场四个独立阶段，并要求未来现场 Entry 逐项记录实际值或 unavailable（计划 21–30 行）。复现卡先做 arm 前正常输入/候选基线，arm 后 attempt1 与单次候选选择只用于建立空候选基线，再只走 App Switcher 返回和单个 attempt2；首个异常后停手等待，仅冻结导出、不再选候选、不补输入、不自动重启/rearm（计划 32–42 行）。UI 实现为独立控制路径，armed/frozen 时无论候选是否仍存在都可显示 idle 导出入口；点击冻结不经 Core、proxy 或键盘 dismiss，且字节只在 `withUnsafeBytes` 闭包内借用（[探针控制器](../../Keyboard/Controllers/KeyboardViewController+WakeOwnerProbe.swift#L26)、[候选栏](../../Keyboard/Views/CandidateBar/CandidateBarView.swift#L418)）。`insertKey` 的探针 begin/end 用 `defer` 成对记录（[输入入口](../../Keyboard/Controllers/KeyboardViewController+InputActions.swift#L19)）。计划要求 App/appex、调试 dylib、Mach-O、UUID 与已安装/运行进程绑定；不匹配或无可恢复备份就不安装。结束时恢复 Entry 实际原值与原存在性；未知值需 Human 对具体限制另行接受，冻结实例不 reset、不自动二轮（计划 30、84–86 行）。这些均为未来门槛，不是本轮完成了设备准备或安装。

### P-Q2 — 固定传输和安全解析

Core 定义 128 条容量、600 秒单调 TTL、11 个 header word 和 11 个 record word；编码顺序与计划列明的 UInt64 字段一致（[KeyboardWakeOwnerProbe.swift](../../Packages/KeyboardCore/Sources/KeyboardCore/KeyboardWakeOwnerProbe.swift#L69)、292–320 行）。snapshot 明确 raw pointer 仅在闭包体内有效；UI 在 freeze 解锁后于该闭包中调用 noinline 出口，传入 address/byteCount（源文件 38–48 行；[导出桥](../../Keyboard/Controllers/KeyboardViewController+WakeOwnerProbe.swift#L83)）。操作卡先取两个具名参数，禁止表达式求值、对象解引用或猜 ABI；参数不可读、断点不唯一/未解析或借用无效即停为 `export_unavailable`。仅当 byteCount 已读且 ≤11352、地址合理时，按该精确长度一次性复制；至少 176 bytes、8 字节对齐，不读相邻内存（计划 44–56 行）。冻结的无 target LLDB help 与模板用到的 `frame variable`、`memory read` 参数语法相符，但不证明真实设备 symbol、ABI 或 attach。

Decoder 将 bytes 按 little-endian UInt64 解析，核对 magic/version、1–128 记录、精确长度、身份、TTL、枚举、连续 sequence、单调时间、overflow/incomplete 一致性，并保留所有 events；attempt 必须唯一 begin/end 且同一非零 coordinator/appearance，才生成 absence 候选。输出 verdict 固定要求人工绑定与独立审查（[离线解析计划](../plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c7c-offline-decoder-2026-10-02.md#L12)、20–71 行）。冻结 artifact 的 18 个合成例子覆盖 paired absence、synthetic/coordinator-zero/orphan/unclosed、overflow、owner-present/no-receipt、重复 resume、截断/尾随/计数错误/未知版本或枚举、矛盾状态及 11352-byte 上限；记录为 all expected，但本 reviewer 未运行示例（解析计划 82–119 行；[结果清单](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7c-prep-artifacts/offline-example-results.json#L1)）。

### P-Q3 — 有限归因

schedule 记录在 `owner != nil` 采样后调用 `owner?.accept`，再记录 ownerPresent 与 receiptPresent；receipt 仅是接受回执（[ThreadAffineRimeSession.swift](../../Packages/KeyboardCore/Sources/KeyboardCore/ThreadAffineRimeSession.swift#L405)）。synthetic armed 的零值及 coordinator=0 不作为 owner absent；计划只允许完整 attempt2 内实际 schedule 的 owner=0/receipt=0 支持“该同步读点 owner 引用为空”，不外推 engine、host、根因或修复（计划 60–80 行）。外层 `viewWillAppear` 与内层 coordinator 分别记录 resumeBegin/resumeEnd，schema 没有层标记，必须保留重复原行，不能去重或推断发生两次恢复（[KeyboardViewController.swift](../../Keyboard/Controllers/KeyboardViewController.swift#L381)；Core 源文件 566–579 行）。receipt 不表示 engine 执行、候选应用或 host 插入；旧 C7-B1-F2 仍是观察合同边界，本包明示不关闭它（计划 74–80 行；[旧 Quality finding](quality-c7-b1-review-2026-10-02.md#L19)）。多 schedule 或混合 owner 状态必须逐条保留并将整次故障解释标为 inconclusive。

## 有限意见与保留项

Positive scoped preparation opinion：三个准备 criterion 均有静态覆盖，未发现材料性准备协议缺陷。该意见只确认未来取证步骤/解释边界足够明确；不是 target 编译、installed candidate、运行/复现、Gate、Product 或 Release 验收。C7-B1 原整体 Hold、F2/F3、历史 skip、57 条格式诊断及未来真实 iOS/设备/恢复验证均保持既有状态。


**预算实耗**：本轮跨过 420 秒 soft delivery，但未越过 600 秒 hard ceiling；准确首尾 UTC 差和完整逐次调用记录见 `usage.json`。这不扩张任何审查标准或运行权限。
