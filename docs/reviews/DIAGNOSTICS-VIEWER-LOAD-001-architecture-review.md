# DIAGNOSTICS-VIEWER-LOAD-001 — Independent Architecture Review

## Review identity

| Field | Value |
|---|---|
| Reviewer | `architecture_review` / Hilbert（独立 Architecture Reviewer） |
| Date / timezone | `2026-08-27 Asia/Shanghai` |
| Frozen commit | `878b02a52e0ee0f63a1181afdfd7d514de1aac27` (`fix/diagnostics-viewer-load-001`) |
| Subject | `fix: distinguish diagnostics load from empty journal` |
| Objects | [`DIAGNOSTICS-VIEWER-LOAD-001`](../assignments/diagnostics-viewer-load-001.md) · [`AUTH-DIAGNOSTICS-VIEWER-LOAD-001-IMPLEMENT`](../authorizations/AUTH-DIAGNOSTICS-VIEWER-LOAD-001-IMPLEMENT.md) · [ADR 0027](../architecture/decisions/0027-enterprise-local-diagnostic-observability.md) · `DiagnosticsStore.swift` · `DiagnosticsLogContentView.swift` · `DiagnosticsView.swift` · `DiagnosticsLogSource.swift` · `DiagnosticsJournal.swift` `liveRefreshIdentity` · [`DEBUGGING.md`](../DEBUGGING.md) |
| Independence | 本审查不是 `878b02a` 的作者（该提交 Author 为 `Cowork 3P`）。审查只读；未改业务代码，未 commit / push / PR，未开启 `required`，未 merge PR #83。唯一写入为本审查文件。 |
| Scope | 复核加载态 vs 空态、三种空态可区分性、ADR 0027 5 MiB / 10,000 预算、writer / Extension 隔离、live refresh skip / watermark、1 秒跟随与手动 spinner、KOS 2.2 AUTH 收据语义。不是 Quality、不是 Product Gate、不是 merge。 |

**HEAD 核对：** 审查时 `git rev-parse HEAD` = `878b02a52e0ee0f63a1181afdfd7d514de1aac27`，分支 `fix/diagnostics-viewer-load-001`。`git show HEAD --stat`：15 files, +293/−21。Swift 触及 Main App 诊断 Store/UI/source、`DiagnosticsJournalReader` 新增 live-identity、对应测试与文档；**未**触及 `Keyboard/` Extension、writer append/flush/lease、RIME、方案下载。

---

## Verdict

**Pass with conditions**

根加载把 `isRefreshing && 无可见行` 从「暂无诊断日志」拆成独立加载面，三种空态文案仍分叉，ADR 0027 读取预算与 writer/Extension 热路径未被本提交改动，1 秒跟随不驱动右上角手动 spinner，IMPLEMENT AUTH 的 exclusions 覆盖 `required` / merge / PR #83。

条件：有一条 **P1**（live-skip 在「加载后重采样 watermark」窗口可能漏掉已落盘事件），须 `fix` 后才能把 live-follow 合同当成闭合。无未处置 **P0**。本 Verdict 不关闭 Assignment、不授权 merge、不等于 Quality Pass。

Finding counts: **P0: 0 · P1: 1 · P2: 3 · P3: 1**

---

## Answers to the review questions

### 1. 加载中是否仍可能显示「暂无诊断日志」？

**根加载 / 日期切换 / 无可见行的刷新：实现上不再走该文案。** 仍有两条须 Quality 用 UI 证据钉住的边。

`DiagnosticsView` 把 `store.isRefreshing` 传入内容区。`DiagnosticsLogContentView` 的第一分支是 `displayedLines.isEmpty && isRefreshing` → `DiagnosticsLoadingStateView`（「正在加载诊断日志」/「这不是空日志。」）。「暂无诊断日志」只在 `DiagnosticsEmptyStateView`，且仅当 `!hasLoggedLines && !isPartialWindow`。

`loadLog()` / `selectLogDay` 在进入 source await **之前**置 `isRefreshing = true`。`testRootLoadMarksRefreshingBeforeSourceReturns` 证明 Store 在 source 返回前已刷新中且 `lines` 仍空。

残留边（不升 P0）：

- 判定用的是 **可见行**（`displayedLines` = 筛选后），与 [`DEBUGGING.md`](../DEBUGGING.md)「`isRefreshing` 且当前没有可见行」一致。筛选无匹配时一次 live/根刷新会暂时盖住筛选空态，显示加载面，而不是「暂无诊断日志」。
- **没有** View 层断言「`isRefreshing` 时字符串 `暂无诊断日志` 不出现」。Store 测了 flag，没测 SwiftUI 分支。见 A-P2-02。
- catalog `.unavailable` 且当前 `lines` 已空、刷新已结束时，仍可能同时出现 paging notice 与「暂无诊断日志」。这是刷新**完成**后的受控不可读，不是加载中伪装。

### 2. 三种空态是否仍可区分？

**是。未刷新完成时加载面优先；刷新完成后三种文案仍分叉。**

| 条件 | 标题 | 说明 |
|---|---|---|
| `displayedLines.isEmpty && isRefreshing` | 正在加载诊断日志 | 不是空态 |
| `hasLoggedLines`（`!store.lines.isEmpty`）且筛选/搜索无命中 | 当前筛选无匹配日志 | 有 journal 行 |
| `!hasLoggedLines && isPartialWindow` | 当前窗口暂无可展示记录 | 有界窗口无完整记录 |
| 其余空列表 | 暂无诊断日志 | 真正无展示 journal |

`isPartialWindow` 仍来自 `lastPageStatus == .partialRecentWindow`。V1 `loadLogText` 在 `events.isEmpty` 早退前已写入 `lastPageStatus`，因此空事件 + partial 不会被改写成 true-empty。`usedV1Result` 在 `status != .completed` 时为真，避免 partial 空窗掉进 legacy 自由文本。

本提交未改三种空态字符串本身，只是在它们前面加了加载门。符合 Assignment 非目标「不把有界窗口描述为完整历史」。

### 3. 是否提高了 5 MiB / 10k 预算？是否改了 writer / Extension hot path？

**否；否。**

- `DiagnosticsJournalReader.defaultMaximumEventCount = 10_000`、`defaultMaximumReadBytes = 5 * 1_024 * 1_024` 未被本 diff 修改；`beginPage` / `nextPage` / `recentPreview` 仍 `min(..., defaultMaximum*)`。
- `DiagnosticsStore.exportMaximumRecordCount` / `exportMaximumByteCount` 仍为 10_000 / 5 MiB。
- KeyboardCore 增量是 `DiagnosticsJournalLiveRefreshIdentity` 值类型 + **Reader** `liveRefreshIdentity()`（`stableSegmentManifest`，不解码 JSONL）。Writer append / lease / generation / retention、`Keyboard/` Extension 热路径、ingress 队列均不在 `git show HEAD --stat` 内。
- AUTH exclusions 含 `writer_or_extension_hot_path`、`raise_read_budget`；实现与收据一致。

`liveRefreshIdentity` 仍走与分页相同的 **exclusive snapshot fence** 并枚举段 `stat`。这比无界 JSONL 轻，但 1 秒 tick 在 skip 命中时仍会抢 fence（writer 侧继续 nonblocking shared、busy 则既有 drop/retry）。见 A-P3-01。不构成提高读取预算。

### 4. live refresh skip 是否只跳过未变更 snapshot，会不会漏掉新事件（watermark 是否随 append 变）？

**watermark 随 append 增大（有测试）。Skip 比较的不是「刚展示的那次 snapshot」，加载后重采样可能漏掉窗口内已落盘事件。**

身份令牌是 `generation + segmentCount + Σ byteWatermark`。`byteWatermark` 来自段文件 `attributes[.size]`。`testLiveRefreshIdentityChangesWhenBytesAreAppended` 证明同 generation 下二次 `append` 后 `totalByteWatermark` 严格增大。新段（`segmentCount`）或 `advanceGeneration` 也会改变令牌。Journal 为 append-only JSONL，正常路径下 size 不会在无 append 时单边回缩到巧合相等（删除段会改 `segmentCount`）。

Store skip：

```text
identity == lastLiveRefreshIdentity  → 不调用 loadLogText
否则 replaceWithLatestPage，并在加载结束后再次 liveRefreshIdentity() 写回 last
```

`replaceWithLatestPage` 末尾已经采样一次；`performLiveRefreshTick` 在 `isRefreshing = false` 后再采一次。两次采样都在 **page 的 exclusive fence 释放之后**。时序：

1. `beginPage` 在 fence 内冻结 membership/watermark W1 并解码；
2. fence 释放，writer 可 append 到 W2；
3. Store 把 `lastLiveRefreshIdentity` 写成 W2；
4. 下一 tick 见身份仍为 W2 → **skip**；
5. (W1, W2] 已在盘上，但当前根页未包含；若之后不再 append，须手动刷新才出现。

这违反 ADR 0027「诊断页可见时实时约一秒内可见」的 skip 安全性：skip 必须绑定「已展示 snapshot 的身份」，而不是「加载完成后的最新盘面」。正确形状是：tick 开头采样 identity I；若 I == last 则 skip；加载后 **last = I**（或把 identity 放进与 `beginPage` 同一 fence）。见 **A-P1-01**。

`identity == nil`（`lockBusy`、无 root、catch）不会 skip，会走全量根加载——偏保守，不漏事件，但空列表时会反复进入加载面。见 A-P2-01。

Composite 的 identity **只问 v1**。v1 根已存在且 watermark 稳定为空时，skip 会连 legacy `rime_diag_log` 回退也不再读。迁移完成后的主路径是 v1；列为 P2 边，不升 P0。

### 5. 1 秒跟随是否仍不抢手动刷新 spinner？

**是。**

- 工具栏 `DiagnosticsToolbar.isRefreshing` 绑定 `store.isManualRefreshing`，不是 `store.isRefreshing`。
- `refresh()` 置二者为 true；`performLiveRefreshTick` 只置 `isRefreshing`，且要求 `!isRefreshing` 才进入，因此不会与手动刷新重叠。
- `testLiveRootRefreshPreventsOlderPageFromStartingWhileCatalogIsInFlight` 断言 live tick 期间 `isRefreshing && !isManualRefreshing`。
- 有可见行时，live/日期根刷新走 caption 内 `showsInlineRefreshProgress`（`isRefreshing && !isManualRefreshing`），无障碍标签「正在更新诊断日志」，不是右上角按钮。

### 6. KOS 2.2：implement AUTH 是否被当 bearer token？exclusions 是否覆盖 merge / PR 83 / required？

**没有当成可执行的无限令牌。exclusions 覆盖所问三项。**

- Assignment `authorization_action` / `authorization_refs` 对齐 `AUTH-DIAGNOSTICS-VIEWER-LOAD-001-IMPLEMENT`（`action: implement`，`target: DIAGNOSTICS-VIEWER-LOAD-001`）。先前 `AUTH-DIAGNOSTICS-VIEWER-LOAD-001`（`establish_assignment`）已 `consumed`，没有拿「建 Assignment」收据改代码。
- IMPLEMENT 收据 `exclusions`: `required_mode`, `merge`, `release`, `scheme_download_fix`, `pr_83_merge`, `writer_or_extension_hot_path`, `raise_read_budget`。正文：「不授权 merge、`required`、方案下载或 PR #83」。
- HEAD 未 merge、未改 PR #83 范围、未切 `required`。KOS 仍为 advisory pin（[`UPGRADE_STATUS.md`](../kos/UPGRADE_STATUS.md)）。
- `consumption_state` 在实现已落入 `878b02a` 后仍为 `unconsumed`。这是与 TD-014 同类的审计滞后，不是用收据去 merge / required。Kit 把 consumption 当观察、不提供 replay 保护。见 A-P2-03。

---

## Findings

| ID | Sev | Disposition | Description |
|---|---|---|---|
| A-P1-01 | P1 | `fix` | live skip 在 `replaceWithLatestPage` / tick 结束处 **重新** `liveRefreshIdentity()`，令牌可能新于刚解码的 snapshot。append 发生在两次 exclusive fence 之间时，下一秒会 skip，已落盘事件可直到下一次 watermark 变化或手动刷新才出现。应把 `lastLiveRefreshIdentity` 设为 **触发本次加载的那次** identity（或与 `beginPage` 同 fence 的 watermark），禁止用加载后的盘面身份当作「已展示」。现有 stub 测试在 load 期间 identity 不变，覆盖不了该窗口。 |
| A-P2-01 | P2 | `accept` | `liveRefreshIdentity()` 失败返回 `nil` 时不 skip，空列表下 1 秒 tick 会反复 `isRefreshing` 并显示加载面（含 snapshot fence busy）。偏保守、不漏事件。不阻塞 Quality；不必为本 Assignment 改 writer 锁协议。 |
| A-P2-02 | P2 | `accept` | 无 `DiagnosticsLogContentView` 级回归断言「`isRefreshing` 时不出现暂无诊断日志」。Store 已覆盖 flag。属 Quality 证据完整度，不改变架构分支。 |
| A-P2-03 | P2 | `tech_debt:TD-014` | `AUTH-DIAGNOSTICS-VIEWER-LOAD-001-IMPLEMENT` 在实现提交后仍 `unconsumed`。exclusions 已挡住 merge / `required` / PR #83。后续 Envelope 卫生处理，不要在本审查里改收据或切 `required`。 |
| A-P3-01 | P3 | `accept` | skip 命中仍每秒 exclusive snapshot fence + 全段 `stat`。比 JSONL 根解码轻，未抬预算。Writer 仍 nonblocking。若日后 1 秒 CPU 成为真机问题，再单独立项，不得用提高 5 MiB/10k 解决。 |

---

## Residuals (M-03)

| Residual ID | Owner | Disposition | Pointer |
|---|---|---|---|
| A-P1-01 live-skip TOCTOU | Main App UI / 实现 Executor（Quality 须复验） | `fix` | 本节 Findings；`DiagnosticsStore.performLiveRefreshTick` / `replaceWithLatestPage` |
| A-P2-01 nil identity reload | Quality（观测即可） | `accept` | lockBusy → 全量加载 |
| A-P2-02 缺 View 断言 | Quality | `accept` | 可在 Quality 补测或接受 Store+代码审查 |
| A-P2-03 IMPLEMENT AUTH unconsumed | Architecture & Knowledge Steward | `tech_debt:TD-014` | [`TECH_DEBT.md` TD-014](../TECH_DEBT.md) |
| A-P3-01 每秒 fence+stat | 无（非本 Assignment） | `accept` | ADR 0027 约 1 秒可见 |

**Close 含义：** `fix` 的 A-P1-01 未落地前，本 Assignment **不得** Close。`accept` / `tech_debt:TD-014` 不阻塞进入独立 Quality。Quality 不得把本文件当成 merge / PR #83 / `required` 授权。

---

## Conditions for Quality

独立 Quality 可以开始，建议至少核对：

1. 根加载在 source 未返回时 UI 为「正在加载诊断日志」，不是「暂无诊断日志」。
2. 筛选空 / partial 空 / 真·无 journal 三种文案在 `isRefreshing == false` 时仍可区分。
3. 预算常量未变；无 Extension/writer 热路径 diff。
4. 对 A-P1-01：或确认将随后续 `fix` 提交，或用「加载期间追加」证明不会 skip 掉 W1→W2。未处置则 Quality 不应把 live-follow 写成合同已闭合。
5. 手动刷新 spinner 仅 `isManualRefreshing`。
6. 不把 IMPLEMENT AUTH 或本 Architecture Verdict 写成 merge / Release / `required`。

---

## Non-claims

- 不是 Human 真机复验。
- 不是 Simulator 全量套件重跑（审查未执行 xcodebuild）。
- 不是 ADR 0028 Acceptance。
- 不是 PR #83、方案下载、INTEGRITY-001 万象分类或 TestFlight。
