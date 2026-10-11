# F4-M-RUNTIME-QUALITY round 1 独立只读评审

## 范围与结论

本评审绑定冻结 packet SHA-256 `0d7a2dfb46744b521058fb94dc6158a323c5202a29d8a86eb4d66a11ffed247c`、branch `codex/keyboard-wake-v3-compatibility-gate`、HEAD `84b9c19227330b0fe6ff391be001ee398010fd6a`、pair digest `d53523dba8c371c67424ff07c79163a66f41e3bc5bb402637cf9ee79ae7579cb` 及 run `/private/tmp/ukey-host-activation-f4-m-20261006`。15 份冻结输入均按 packet 的 byte 数和 SHA-256 核对；PTY、callback、设置原值、receipt、Human 消息副本与 F4 Prepared Entry 已实际阅读。

**结论：审查对象是一份如实标注 Partial 的单轮记录；F4-M runtime 不通过，也不构成修复、Release 或 owner/callback 验收。** 四个审查标准均按“记录是否准确呈现本轮证据与缺口”判 Covered；其所述运行与导出本身仍 Partial，且以下未验证项保持开放。

## Evidence Matrix

| 标准 | 判断 | 证据与边界 |
|---|---|---|
| M-Q1 | Covered（单轮 Human 观察范围） | `inputs/human-messages.json` 是 root 从当前线程机械复制的消息，不是独立截图。消息及 `inputs/receipt.json` 只支持本轮单 n 基线正常、AppSwitcher 直接返回后键盘保持开启而旧候选保留/输入框清空、随后单 h 有反馈且候选与输入框更新。没有机械观测、长期修复、通知或 owner 通过的证据；交付将此限制写明。 |
| M-Q2 | Covered（fail-closed 记录） | `inputs/pty-transcript.txt` 显示 callback 结果为 PID 64039、frame 0、symbol null、module UUID `B07862D0-C2DE-3AED-898C-88190E38064E`，与预期 symbol 及 `4B207746-89A7-321F-83C4-91477259BB26` 不符；导出为 `unavailable / hit_frame_identity_mismatch`，`memory_snapshot_reads=0`。`inputs/export_frame_callback.py` 在身份校验失败时先退出参数解码；记录未猜地址、没有替代地址读取或二次运行。故没有 buffer/owner/attempt 或 callback 成功证据。 |
| M-Q3 | Covered（仅记录支持） | PTY 显示删除断点、detach、quit，receipt 记录 LLDB exit code 0。`inputs/entry.json`、`inputs/display-category-key-correction.json`、`inputs/settings-restore.json` 与 receipt 记录原始诊断键 ABSENT；运行曾新增的 `logging_enabled=false` 已移除，实际显示类别键 `log_category_disp` 与其旧误名均在两次回读中 ABSENT，其余偏好保持。精确暂停时长为 UNKNOWN；没有另行提供退出前视觉状态。上述内容是冻结记录支持，并非本轮 reviewer 对设备、进程或设置的现场证明。 |
| M-Q4 | Covered（账本限于已提供记录） | packet 绑定预期 pair digest `d53523dba8c371c67424ff07c79163a66f41e3bc5bb402637cf9ee79ae7579cb` 与 branch/HEAD；F4-M validation 称其使用精确 F4-P 配对候选，entry 记录 `installed78payload_exact=true`，receipt 记录 `source5_hashes_match=true` 及同一 branch/HEAD。Assignment 当前状态与 Partial、58/60 calls 一致。它们是彼此相容的冻结记录；本轮没有对 live 安装字节独立复算 pair digest。未把导出缺口、历史 skip 或单轮 Human 输入升格为通过/Release。授权起点 `01:19:56.858735Z` 至 receipt 终点 `01:36:58.160486Z` 可独立复算为 1021.301751 秒，与 receipt 一致且低于 5400 秒。58 次 actual calls 是 receipt/Assignment 报告值，无法仅凭本次输入逐条重建，故只作为作者账本值，不作独立计数证明；`source5_hashes_match`、installed payload exact 也仅为冻结记录声明，本轮未重哈希 live 容器或候选。 |

## 已验证输入

15 份 packet 输入的路径、字节数和 SHA-256 均逐项匹配，明细在 `usage.json`。本评审只读冻结副本及 packet 指名的治理文档；没有查询 live 模拟器/容器，没有运行 LLDB、构建、测试、源码或 Git 操作，也没有网络访问。

## 未覆盖与限制

- 单轮返回后输入正常只说明本次 Human 操作路径；不证明长期修复或其它生命周期序列。
- 实际 callback frame 身份不匹配，buffer 读取为 0；真实通知、owner/receipt、attempt 配对、transport 完整性及实际 callback 语义仍未验证。
- 暂停时长不可复算；退出前视觉状态缺失。断点/进程退出与设置恢复由原件及收据支持，未经 live 复验。
- 58/60 的实际调用总数按作者账本引用；冻结材料不含逐调用完整账本。pair digest 由本轮 packet 绑定，输入副本记载 payload/hash 检查结果；本轮没有独立读取 live app 或完整复算 payload digest。
- `inputs/assignment.md` 的 Current Status 表与本轮 Partial/58-call 报告相符；其大段历史附录在命令回显中发生截断，故本评审不声称逐段复核整份 Assignment 历史。

## ACK 更正记录

首次 ACK 写入并成功读回，但误用 `lane_id`/`scope` 字段，二者为 null；原字节数 434、SHA-256 `152a6ef1098c5a015ecef18585758597380f0b58a75fbf4c890f0d2014642b8c`。本交付已按 packet 实际字段更正为 `lane`、`criteria`、`access`；历史 ACK 摘要仅作更正轨迹，不表示首次 schema 正确。

## 最终判断

本次只读验收确认“Partial 记录诚实呈现了单轮 Human 观察、callback fail-closed、清理与设置回读证据及其限制”。没有证据足以接受 runtime 修复完成；接收或接受剩余风险属于 Human Product 权限。
