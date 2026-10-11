# TYPO-CORRECTION-002-INT003-QUERY-COST-P2-EXISTING-RUN-ADMISSION-001 — Quality Review

## 结论与历史状态

**Scoped Pass with conditions**：冻结的既有 Run 可作为 Human 修订合同下的 bounded provider-facade query 计数与 elapsed 证据。结论仅限本 Run 的数字快照、实际输入映射和 DEBUG Simulator provider facade 范围。

本结论不修改 Round 1 当时记录的 **Partial / incomplete**：Round 1 在 360 秒限制下中断，未写正式报告和用量文件；Round 2 是获准的交付补齐，只将已完成的 C1–C4 核对整理归档，没有重读 raw/source、重解析、重测或增加证据。

## 冻结交付输入

Delivery packet SHA-256：`14373776d37ce5e0a3e97a8a834250785c385448307009a19ab0022e5e3fd695`。packet 列出的五项输入均独立匹配字节数与 SHA-256：

| 输入 | SHA-256 |
|---|---|
| `runtime-final-message.md` | `b57b4d5f67165598014c5e0f52ada3245e436b1cdbbb488a78f9146f688ed769` |
| `quality-usage-checkpoint.json` | `f401bf8d19059eefbbe7290d9eeee83678d68849add1e1870f076af5eb202cb8` |
| `quality-protocol-check.json` | `e6426682382109bedf6d90ba30ad3e3176b8dc00a96e1a124ceb1c123c3c2b3c` |
| `quality-mapping-stats-check.json` | `2a821237bf5044a5bbe23736f013d13c29cd6aaa16f0a417bcb7c733a30058b3` |
| `coordinator-usage-transcription.json` | `68758cb30a6ea809bdafa51b758805b630cc5f7a4efeb15b9be0d9643c4ec7f5` |

Round 1 的直接核查结果见其冻结小型核查输出与 runtime final transcription；Round 2 未重新运行这些核查。

## C1–C4 覆盖

### C1 — Covered：输入身份、v2 wire、scope 与导出生命周期

Round 1 对原 packet 及其 52 项输入核对了 SHA-256 和字节数。两份数字副本均为 12,896 bytes、逐字节相等，SHA-256 为 `729b9422660e891239235e84b869c2e6686c06c0ab40a775b924a5b23cac8106`。独立 v2 解析确认 32-word header、20-word record、79 records；7 个 sequence begin/end 闭合，61 个 query started/completed、active 0，2 个 operation started/terminal、active 0，rejected 0、reason bits 0，容量 4096、TTL 1.8e12 ns，clock-invalid 为 0。

Run UUID 与 assignment/arm 对应；scope 为 coordinator 1、lifetime epoch 3、schema Luna、Full Access code 2、thread-affine provider kind 2、facade ordinal 1。加载的主二进制及 debug dylib UUID 与绑定值相符，PID 46758；冻结导出停在指定 helper，地址/长度对应快照，双副本一致。detach 成功，随后进程仍为同一 PID 的运行态。证据支持本次限定导出的完整性与对应关系。

### C2 — Covered：Human 实际 mapping、六类 canonical 与额外 F01

Human 回执对应实际顺序为 ordinal 1–7：`F01, F01 extra, F02, F03, F04, F05, F06`。Canonical ordinals 是 1、3、4、5、6、7；额外 ordinal 2。逐 ordinal 从 raw 重建的 query 数与实际 mapping 一致：

| 实际输入 | ordinal | queries | Stage 1 / Stage 2 | operations |
|---|---:|---:|---:|---:|
| F01 | 1 | 0 | 0 / 0 | 0 |
| F01 extra | 2 | 0 | 0 / 0 | 0 |
| F02 | 3 | 0 | 0 / 0 | 0 |
| F03 | 4 | 30 | 24 / 6 | 1 |
| F04 | 5 | 31 | 24 / 7 | 1 |
| F05 | 6 | 0 | 0 / 0 | 0 |
| F06 | 7 | 0 | 0 / 0 | 0 |

Canonical 和全部序列的 query 总数均为 61；额外 F01 没有 query/operation，因此不改变计数。Raw 中的 encoded fixture/arm 是自动 ordinal 标签：例如 ordinal 2 encoded fixture 2、ordinal 7 encoded arm 2。它们不能覆盖 Human 实际 mapping；ordinal 7 不能称 warm。两次 F01 计数相同也不证明内部状态相同。

### C3 — Covered：字段分布、elapsed 与可复用 claims

从 61 条完整 query record 复算得到 Stage 1/2 为 48/13；readiness code 3（unknown）61 条；result code 1、candidate bucket code 1、disposition code 1、duration-state code 1 均各 61 条。按 source enum，result 为 candidates-returned、bucket 为 zero、disposition 为 applied、duration 为 measured。readiness 保持 unknown，不把它改写成 ready。

61 个有效 facade elapsed 样本（微秒）为 min 0、median 0、nearest-rank p95 3、max 6。0 µs 是微秒量化值，不表示零成本。可复用 claims 限于本次完整 provider-facade query 计数、Stage/bucket/disposition/readiness 原值，以及 DEBUG Simulator facade wall elapsed。该计时不是 native librime correction 查询时间、CPU 时间、完整 UI 延迟或 Release 成本；本次也不支持 cold/warm 稳健性或总体 observer 影响结论。

### C4 — Covered：历史证据边界与后续权限

R4/R5 的旧 synthetic macOS Debug 结论只作为历史 methodology 边界。冻结的旧 source manifest 与当前 `QueryCostMemoryProbe.swift`、`KeyboardViewController+QueryCostProbe.swift`、`TypoCorrectionRecallCoordinator.swift` 的 hash 不同，且旧 manifest 不含当前 `QueryCostArmDiagnostic.swift`；因此旧 R4/R5 不自动认证当前 v2 observer。当前 Run 自身只支持上面的 bounded provider-facade claims。

本 review 不作 Product query budget、残项接受、Gate、父任务关闭或 Release 决定。Human Product Lead 仍需按原有权限决定 query budget 与 residual disposition；父任务最终 Gate 对总体性能残项仍需对应证据或 Human 单独的范围/风险决定。Human 已明确不希望重测；本报告不增加重录、测试、大型 trace、持久化或 UI 前置条件。

## Findings 与 disposition

- **QPA-R2-BOUND-PROVIDER-EVIDENCE-001 — Scoped Pass with conditions。** 此 Run 可复用为 Human 修订覆盖下的完整 bounded provider-facade query/elapsed 证据；不代表整个 P2 或父任务已关闭。
- **QPA-R2-ACTUAL-MAPPING-001 — Covered。** Canonical 六类与额外 F01 的实际输入映射可用；encoded arm2 不构成 warm 证据。
- **QPA-R2-LEGACY-SYNTHETIC-NONREUSE-001 — Boundary recorded。** R4/R5 仅为历史 synthetic methodology，不能替代当前 v2 observer 的运行证据。
- **QPA-R2-PRODUCT-RESIDUAL-DECISION-001 — Open；owner：Human Product Lead。** 需独立作出预算与 residual disposition；本 Quality 结论不代行该决定。

## 操作边界

Round 2 只读取 packet 与其五项固定小输入并核对其 hash；未读取 raw/source/live 工作区，未使用设备、LLDB、build、test、network 或 Git。只写本报告与配套用量文件。
