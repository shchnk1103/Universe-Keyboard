# INT003-P2-MEMORY-QUALITY-EVIDENCE-ADMISSION — R4 独立复核

## 范围与输入身份

本轮只复核冻结 packet 的 E1–E4，以及其列出的 29 项固定输入。没有重审整个实现，也没有运行 Swift 测试、构建、格式化、设备或网络操作。

- Packet SHA-256：`260eb39ff568ccc5e1be5b39395882f3879680861794ea308d809bd4d392c1d8`
- Input manifest SHA-256：`707004d151ada2a74ba3538c265f4302cc07b5ac936b6207e1d27f5af3ad8dbf`；29 项的 hash 和 byte count 全部匹配。
- 核查脚本 SHA-256：`36ede0811e4b323a004bea84b83c14b920ed5f5a789d7bfdf9e574a1d6c6a550`。已检查其逐行读取 manifest、限制路径在 `Inputs` 下、验证文件 hash/bytes 和数据断言；未发现目录遍历或额外路径读取。
- 独立执行脚本 exit 0。`Review/independent-checks.json` SHA-256：`a3c4f8c02a1340b6549108c494f5ea316a974e68d374a193207667b0f4c194b7`。这是本轮执行结果；Coordinator preflight 本身不作为独立结论。
- 候选 manifest SHA-256：`d0e491083df08df27ff8e463ad9f4824c5d083c0804ccc0cdf9c811e23cdf4ad`；HEAD `72dd21710f2a86c9f951d489f645bae89b053b58`。

## Evidence Matrix

| Claim | 状态 | 核对结果与边界 |
|---|---|---|
| E1 — skips 与本轮 scope | **Covered** | Rime Debug 20 项、App Debug 10 项，共 30 skips。分组为 Lua 2、T9 17、R4-B 1、scheme 6、TD-012 3、Keychain 1。相同 Keychain case 有独立 signed lane 1/1 passed；其余 29 项仍未验证。它们与 test-only raw helper / synthetic benchmark 无关，不计为通过，也不构成风险接受或 Gate waiver。 |
| E2 — helper、当前测试与旧 iOS 证据复用 | **Partial** | Before/After 只有一个 helper hunk，candidate manifest 只变更测试文件，其余 20 项不变。helper 把编码结果存为 `Data`，同一字节可按环境变量写至外部目录，使用 `withoutOverwriting`，并交给 `XCTAttachment`。回执绑定当前 candidate；filtered 日志显示三项测试通过、0 failures；strict lint exit 0。**未独立核实所有 helper 调用点都发生在计时结束之后**；这点目前仅由 patch 注释陈述，不能据此确认写盘不会落入某个 measured interval。旧 flags/symbol 只限复用到未变的旧产品二进制；不证明当前 iOS runtime 或性能适用性。 |
| E3 — raw identity、schema 与统计 | **Covered** | 9 个 raw 文件与 manifest 的 hash/bytes 匹配，总字节数 11,881,864。独立脚本验证 90 C units × 1,000 calls、30 signed differences、90 R、60 S、90 freeze units，以及 header/schema、clock、schedule、immutability、R1 expected incomplete 和汇总统计。脚本退出 0，所有断言通过。 |
| E4 — 方法适用范围 | **Covered（仅边界）** | 证据是 synthetic macOS Debug opt-in run。外层 wall 包含调度与 barrier；C 的 `overlapAvailable` 全部为 false，因此不能声称存在 Mutex wait/锁竞争。写盘在 measured interval 外，但处于测试之间，仍可能影响后续 cache。日志总时长和单测耗时不是 latency/overhead 结论。 |

### E3 独立复算的统计

单位均为 ns；“worst”是本组最大观测值，negative 为负值计数。

| 数据 | n | Median | Worst | Negative |
|---|---:|---:|---:|---:|
| C pair mode 0 | 30,000 | 125 | 6,000 | 0 |
| C pair mode 1 | 30,000 | 750 | 14,125 | 0 |
| C pair mode 2 | 30,000 | 42 | 6,375 | 0 |
| C elapsed mode 0 | 30 | 2,039,895.5 | 2,388,375 | 0 |
| C elapsed mode 1 | 30 | 2,926,479.5 | 3,559,000 | 0 |
| C elapsed mode 2 | 30 | 1,944,625 | 2,128,959 | 0 |
| Armed − disabled | 30 | 850,979.5 | 1,322,208 | 0 |
| Armed − control | 30 | 976,979 | 1,430,041 | 0 |
| R schedule 0 | 30 | 7,583.5 | 21,916 | 0 |
| R schedule 1 | 30 | 17,500 | 70,333 | 0 |
| R schedule 2 | 30 | 21,708 | 25,042 | 0 |
| S mode 0 | 30 | 173,063 | 206,166 | 0 |
| S mode 1 | 30 | 650,041.5 | 788,417 | 0 |
| Freeze cohort 0 | 30 | 8,270.5 | 22,834 | 0 |
| Freeze cohort 1 | 30 | 571,958.5 | 598,000 | 0 |
| Freeze cohort 2 | 30 | 6,347,103.5 | 6,594,333 | 0 |

C 的 90,000 个 call record 保留每个 unit 的 1,000 个样本，worker/epoch 组合完整且无替换。C mode 1 的 header 为 32 words，record count 1,006，wire byte count 为 161,216：256-byte header 加 160,960-byte record area。R1 的 30 个 incomplete snapshot 被保留为预期结果；各组 clock-invalid、failed-schedule 和 invalid-C-call 计数均为 0。

核查限于保存的 header、counter、byte count 和统计样本；脚本明确注明，它没有从 raw header 重建整个 payload 的字节内容。因此本结论不代表逐字节 payload 解码验证。

### 关键证据引用

- E1：`skipped-tests.json` `a4a4019e…0f0360`；`skip-scope-assessment.json` `b5950261…e588be`；`last-evidence.json` `e0c2e25f…8b8fea`
- E2：`Before.swift` `8cb29695…1f762c1`；`After.swift` `04b856ea…16c1bf014`；`approved-helper.patch` `3b63cd8d…17a5d6265`；`execution-receipt.json` `3bccc4dd…b501f73fa`；`execution-binding.json` `1f9f6cfc…03cbab39`；`lint-receipt.json` `b151c8fd…e731431`；`reuse-boundary.json` `bdb27444…af925c8c`；`flag-symbol-inspection.json` `a22af86e…2ccef80`
- E3：`raw-manifest.json` `429ef118…9c250210`；`raw-summary.json` `9a4c5135…788b3ce`。9 个 raw 的 SHA 分别为：R0 `6eb2ba4b…57217d7`；freeze-0 `cf29ea81…10badb`；C signed differences `9e294ce1…415921d`；C raw units `89517ac5…f5363b26`；freeze-1 `1d5e87d5…c0a48e`；R1 `514a59cc…b6eb742bd`；S `17cd7597…b5401ed`；R2 `5c49c7d6…5ced1872`；freeze-2 `b3401008…06c1dde3`。
- E4：`performance-baseline.md` `58e7d92d…cb526a1`；`interface-design.md` `e4578ede…6f6604`；filtered run log `db8926ed…c2a3f39`。

## Findings 与 disposition

- **QEA-R1-SKIPS-029 — Open；owner：RimeBridge/T9、Scheme/resource、TD-012/Test-Release 对应维护者。** 29 项仍是未验证的 runtime、fixture 或 device residual；本轮只确认其与 raw-helper scope 的关系，不要求跨 scope 重跑，也不接受为风险。
- **QEA-R1-PERF-RAW-001 — 已解决，仅限 raw evidence availability/integrity。** 本轮固定输入、raw manifest、schema、计数、统计和 summary 一致；不外推为 iOS 或产品性能通过。
- **QEA-R1-P2-ADMISSION-001 — E3 数据阻塞已解除；正式 P2 Capture/RunReady 仍未评估。** 本轮新发现 **R4-E2-CALLSITE-001**：需由 Quality/test owner 核实各 `attach` 调用确实在计时结束后；定位为 `Inputs/Evidence/After.swift` 中的 `attach<T: Encodable>` helper 与其调用点。这是静态覆盖缺口，不是已证实的实现缺陷。
- R1/R2/R3 报告保持不变。固定 integrity audit 标记 R1 为未获独立 Quality acceptance，且记录了预算超限和 inventory 计数错误；R4 不追认或改写此前结论。

## Decision

**Partial / incomplete。** E1、E3、E4 的限定覆盖完成；E2 的 measured-interval 调用顺序尚未独立闭合，所以本轮不授予 raw-retention 与 bounded-methodology 的 Scoped Pass。29 项 skips、iOS observer Capture/profiler、Product、Release、Gate 和正式风险接受均未通过或未评估。

## 用量与时间

- UTC start：`2026-10-09T02:58:08.393194Z`
- UTC end：`2026-10-09T02:58:59.164872Z`
- Elapsed：**50.772 秒**
- 工具用量：4 次 `exec_command`、4 次 wrapper、0 次失败；未触及 600 秒上限。
- 本轮没有运行 Swift 测试或构建；测试通过结论来自固定 execution receipt 与日志。未读取 allowlist 外路径，未修改源码。
