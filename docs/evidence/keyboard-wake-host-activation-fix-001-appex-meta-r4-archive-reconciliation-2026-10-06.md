# AP-META-004 归档一致性补正与待决定残项

Human 授权按上一建议继续；本切片仅 root 归档及治理补正，不重采、不独立重审、不改生产源码、不操作模拟器。独立结论维持 Partial。

## 已完成的归档补正

误写摘要已在本目录的 `keyboard-wake-host-activation-fix-001-appex-meta-r4-reconciled-artifacts/final-runtime-summary-original.json` 字节一致归档，SHA-256 `99c39f6c8988a9c9116e59f460fe6fbdbd2391c3866ef33f4b2a24773b7b262b`；原误写保全副本、私有旧 summary、冻结 reader 和独立作者原报告均不修改。旧 summary 的 33／视觉 Pending 是历史快照；最终 35／Human 视觉退出来自正确归档的最终摘要。原摘要的 independent_review 未执行字段仅是当时状态，由后来的独立验收收件取代，不改写原件。

35 次调用另有 root 原审计机械复算。该补充及 ACTIVE 精确恢复证明未被本独立 lane 审过，因此本次归档修正不将 Q4 提升为独立 Pass。恢复后 ACTIVE 内容已有精确哈希证明，不再重复恢复或替换 dirty 文档。

`human-arm`、`human-freeze` 与视觉确认中的 `recorded_utc` 表示协调者收到／记录确认的时间，不能当作人工点击发生的精确 UTC；不凭记账时间晚于 callback 推定额外点击或键盘异常。

## 提请 Product 的狭义处置（待明确决定）

仅对 AP-META-004 元数据阶段，建议将以下保持公开的限制接受为非阻塞、未验证残项：

1. 精确人工点击时刻及精确 detach 时刻未独立证明；清理、暂停上界及 Human 视觉确认只按各自来源使用。
2. LLDB 默认 formatter 显示参数这一实际范围偏差：脚本主动参数／缓冲读取为 0，整场默认参数显示不是 0；不再显示或复制参数值，不将其当作 owner 证据。
3. 最终摘要由 root 补归档、35 次调用及 ACTIVE 恢复由 root 机械核验，未追加独立覆盖；独立 reviewer 完整墙钟 UNKNOWN，不能声称其 900 秒预算已证明合规。

接受后只关闭本阶段的收件依赖，保留独立 Partial、历史偏差与未验证标签；不证明 owner/session、真实通知完整性、Maps 长期修复、父任务或 Release。不得继承到下一轮。未获此决定前，本轮归档完成，阶段接受保持 Pending。

下一步无需操作模拟器。真正 owner 缓冲有界导出如仍为必需证据，应另准备最小 Entry；本补正不授权导出、重新运行或更改诊断脚本。

## 后续决定（2026-10-06）

Human 已明确“接受”上述三组限制仅本元数据阶段非阻塞、未验证处置，[决定回执](keyboard-wake-host-activation-fix-001-appex-meta-r4-product-acceptance-2026-10-06.md)取代上文待决定状态；历史提案和原件保持。本阶段收件依赖关闭，独立Partial及整体Active保持。
