# DIAGNOSTICS-VIEWER-LOAD-001 — Independent Architecture Re-review

## Review identity

| Field | Value |
|---|---|
| Reviewer | `architecture_review` / 独立 Architecture Reviewer（本复审会话） |
| Date / timezone | `2026-08-27 Asia/Shanghai` |
| Frozen commit | `ec5e8e9086fbf72537d6d20215f48ea301bfdd66` (`fix/diagnostics-viewer-load-001`) |
| Subject | `fix: bind diagnostics live skip to the pre-load identity` |
| Prior Architecture | [`DIAGNOSTICS-VIEWER-LOAD-001-architecture-review.md`](DIAGNOSTICS-VIEWER-LOAD-001-architecture-review.md) of `878b02a` — **Pass with conditions**，阻塞项 **A-P1-01** |
| Objects | [`DIAGNOSTICS-VIEWER-LOAD-001`](../assignments/diagnostics-viewer-load-001.md) · [`AUTH-DIAGNOSTICS-VIEWER-LOAD-001-IMPLEMENT`](../authorizations/AUTH-DIAGNOSTICS-VIEWER-LOAD-001-IMPLEMENT.md) · [ADR 0027](../architecture/decisions/0027-enterprise-local-diagnostic-observability.md) · [`DEBUGGING.md`](../DEBUGGING.md) 诊断页合同 · `DiagnosticsStore.swift`（`performLiveRefreshTick` / `replaceWithLatestPagePeeking` / `replaceWithLatestPage` / `lastLiveRefreshIdentity`）· `DiagnosticsLogContentView.swift` · `DiagnosticsView.swift` · `DiagnosticsLogSource.swift` · `DiagnosticsJournal.swift` `liveRefreshIdentity` · `UniverseKeyboardTests/DiagnosticsStoreTests.swift` |
| Independence | 本复审不是 `878b02a` 或 `ec5e8e9` 的作者（两提交 Author 均为 `Cowork 3P`）。不把对话史当权威。审查只读；未改生产 Swift，未 commit / push / PR，未开启 `required`，未 merge PR #83。唯一写入为本复审文件。 |
| Scope | 闭合 A-P1-01（skip 必须绑定触发解码的 peek，不得用加载后盘面身份），并复答 Assignment 架构问题。不是 Quality、不是 Product Gate、不是 merge。KOS 2.2 仍为 advisory（[`UPGRADE_STATUS.md`](../kos/UPGRADE_STATUS.md)）。 |

**HEAD 核对：** `.git/HEAD` = `ref: refs/heads/fix/diagnostics-viewer-load-001`；`refs/heads/fix/diagnostics-viewer-load-001` = `ec5e8e9086fbf72537d6d20215f48ea301bfdd66`（等价 `git rev-parse HEAD`；本审查未拉起 git 二进制）。`.git/logs/HEAD`：`878b02a`（实现 amend）→ `5aa09a7`（记录 `878b02a` Architecture）→ `ec5e8e9`（本冻结点）。`COMMIT_EDITMSG` 与冻结 subject 一致。

**`git show` 范围（由 reflog + 工作树对照，未解 zlib object）：**

| Commit | Notes |
|---|---|
| `878b02a` | 上一轮：15 files, +293/−21。加载面、live-identity、Store/UI 测试、文档。未触及 `Keyboard/` Extension、writer append/flush/lease、RIME、方案下载。 |
| `ec5e8e9` | 在 Architecture 文档提交之后：Store skip 改为 peek-bind；`testLiveRefreshReloadsWhenIdentityAdvancesDuringLoad`；`DEBUGGING.md` 合同写明 skip 绑定触发解码的 peek。仍无 Extension / writer 热路径。 |

---

## Verdict

**Pass**

A-P1-01 已在 `ec5e8e9` 按上一轮要求落地：`lastLiveRefreshIdentity` 只提交**触发本次解码的 peek**，加载期间 identity 前进后下一 tick **不得 skip**。根加载仍把 `isRefreshing && 无可见行` 从「暂无诊断日志」拆出；三种空态在刷新完成后仍分叉；ADR 0027 5 MiB / 10,000 与 writer / Extension 热路径未被本工作项抬高或改写；1 秒跟随不驱动手动 spinner；IMPLEMENT AUTH 不是 merge / `required` / PR #83 的 bearer token。

无未处置 **P0**。A-P1-01 不再作为开放 P1。上一轮已 `accept` / `tech_debt` 的 P2/P3 仍残留，**不**阻塞进入独立 Quality。本 Verdict **不**关闭 Assignment、**不**授权 merge、**不等于** Quality Pass、**不是** Human Product Gate。

Finding counts: **P0: 0 · P1: 0 · P2: 3（均为既有 `accept` / `tech_debt`，无新增） · P3: 2（1 既有 `accept` + 1 新 `accept`）**

---

## Answers to the review questions

### 1. A-P1-01 是否闭合？Skip 是否绑定触发解码的 peek，而不是加载后盘面采样？加载中 append 后下一 tick 会不会 skip？

**闭合。Skip 绑定 peek。加载中 identity 前进后下一 tick 必须再加载，不能 skip。**

`878b02a` 的缺陷：`replaceWithLatestPage` / tick 结束处再次 `liveRefreshIdentity()`，把 fence 释放后的盘面写成 `last`。时序 W1 解码 → writer append 到 W2 → `last = W2` → 下一秒 skip，(W1, W2] 可从视图消失。

`ec5e8e9` 形状（与上一轮规定的「tick 开头采样 I；相等则 skip；加载后 **last = I**」一致）：

```text
performLiveRefreshTick:
  I = liveRefreshIdentity()
  若 I != nil 且 I == last  →  return（不调用 loadLogText）
  否则 replaceWithLatestPage(..., peekedLiveRefreshIdentity: I)

replaceWithLatestPagePeeking（根加载 / 手动刷新 / 日期切换）:
  I = liveRefreshIdentity()
  replaceWithLatestPage(..., peekedLiveRefreshIdentity: I)

replaceWithLatestPage 在成功 apply 之后:
  lastLiveRefreshIdentity = peekedLiveRefreshIdentity   // 禁止再采样
```

加载中 append：

1. Peek I = W1，`beginPage` 解码 W1（或之后同一 exclusive fence 能见到的快照）。
2. `loadLogText` 返回后 writer 可把盘面推到 W2。Store **不**把 W2 写入 `last`。
3. `last = W1`。下一 tick peek 到 W2 ≠ last → **再加载**，不会 skip。

`testLiveRefreshReloadsWhenIdentityAdvancesDuringLoad`：peek/load 用 `g1:1:20`，`loadLogText` 返回时把 identity 改成 `g1:1:30`；第一次 tick 展示 `second event` 且 `last` 不得变成 `30`；第二次 tick 在 identity 已是 `30` 时仍再调 `loadLogText` 得到 `third event`。这正是上一轮 stub「load 期间 identity 不变」覆盖不到的窗口。

Peek 与 `beginPage` 仍是**两次** exclusive fence（见 A-P3-02）。那只会在 peek < 实际解码水位时多一次跟进加载，**不会**把更新的盘面身份当成已展示而 skip。上一轮允许的两种正确形状之一（peek-bind，而非必须同 fence）已经满足。catalog `.unavailable` 早退、revision 失配早退都**不**写 `last`，偏保守。

### 2. 加载中是否仍可能显示「暂无诊断日志」？

**根加载 / 日期切换 / 无可见行的刷新：实现上不再走该文案。** 与 `878b02a` 相同，仍有须 Quality 用 UI 证据钉住的边；`ec5e8e9` 未回退该分支。

`DiagnosticsView` 把 `store.isRefreshing` 传入内容区。`DiagnosticsLogContentView` 第一分支是 `displayedLines.isEmpty && isRefreshing` → `DiagnosticsLoadingStateView`（「正在加载诊断日志」/「这不是空日志。」）。「暂无诊断日志」只在 `DiagnosticsEmptyStateView`，且仅当 `!hasLoggedLines && !isPartialWindow`。

`loadLog()` / `selectLogDay` 在进入 source await **之前**置 `isRefreshing = true`。`testRootLoadMarksRefreshingBeforeSourceReturns` 证明 Store 在 source 返回前已刷新中且 `lines` 仍空。

残留边（不升 P0 / 不重开 A-P1-01）：

- 判定用的是 **可见行**（`displayedLines` = 筛选后），与 [`DEBUGGING.md`](../DEBUGGING.md)「`isRefreshing` 且当前没有可见行」一致。筛选无匹配时一次 live/根刷新会暂时盖住筛选空态，显示加载面，而不是「暂无诊断日志」。
- **没有** View 层断言「`isRefreshing` 时字符串 `暂无诊断日志` 不出现」。Store 测了 flag，没测 SwiftUI 分支。见 A-P2-02。
- catalog `.unavailable` 且当前 `lines` 已空、刷新已结束时，仍可能同时出现 paging notice 与「暂无诊断日志」。这是刷新**完成**后的受控不可读，不是加载中伪装。

### 3. 三种空态在加载完成后是否仍可区分？

**是。未刷新完成时加载面优先；刷新完成后三种文案仍分叉。`ec5e8e9` 未改空态字符串。**

| 条件 | 标题 | 说明 |
|---|---|---|
| `displayedLines.isEmpty && isRefreshing` | 正在加载诊断日志 | 不是空态 |
| `hasLoggedLines`（`!store.lines.isEmpty`）且筛选/搜索无命中 | 当前筛选无匹配日志 | 有 journal 行 |
| `!hasLoggedLines && isPartialWindow` | 当前窗口暂无可展示记录 | 有界窗口无完整记录 |
| 其余空列表 | 暂无诊断日志 | 真正无展示 journal |

`isPartialWindow` 仍来自 `lastPageStatus == .partialRecentWindow`。V1 `loadLogText` 在 `events.isEmpty` 早退前已写入 `lastPageStatus`，因此空事件 + partial 不会被改写成 true-empty。`usedV1Result` 在 `status != .completed` 时为真，避免 partial 空窗掉进 legacy 自由文本。符合 Assignment 非目标「不把有界窗口描述为完整历史」。

### 4. ADR 0027 5 MiB / 10,000 预算是否被提高？writer / Keyboard Extension 热路径是否被改？

**否；否。**

- `DiagnosticsJournalReader.defaultMaximumEventCount = 10_000`、`defaultMaximumReadBytes = 5 * 1_024 * 1_024` 未被本工作项修改；`beginPage` / `nextPage` / `recentPreview` 仍 `min(..., defaultMaximum*)`。
- `DiagnosticsStore.exportMaximumRecordCount` / `exportMaximumByteCount` 仍为 10,000 / 5 MiB。
- KeyboardCore 增量仍是 Reader 侧 `DiagnosticsJournalLiveRefreshIdentity` + `liveRefreshIdentity()`（`stableSegmentManifest`，不解码 JSONL）。Writer append / lease / generation / retention、`Keyboard/` Extension 热路径、ingress 队列不在本冻结点的实现范围内。`ec5e8e9` 只改 Store skip 提交点与测试/合同，不改 Reader/Writer 锁协议。
- AUTH exclusions 含 `writer_or_extension_hot_path`、`raise_read_budget`；实现与收据一致。

`liveRefreshIdentity` 仍走与分页相同的 exclusive snapshot fence 并枚举段 `stat`。Skip 命中时仍每秒抢 fence（writer 侧 nonblocking shared、busy 则既有 drop/retry）。见 A-P3-01。不构成提高读取预算。

### 5. 1 秒跟随是否仍不抢手动刷新 spinner？

**是。`ec5e8e9` 未改 spinner 绑定。**

- 工具栏 `DiagnosticsToolbar.isRefreshing` 绑定 `store.isManualRefreshing`，不是 `store.isRefreshing`。
- `refresh()` 置二者为 true；`performLiveRefreshTick` 只置 `isRefreshing`，且要求 `!isRefreshing` 才进入，因此不会与手动刷新重叠。
- `testLiveRootRefreshPreventsOlderPageFromStartingWhileCatalogIsInFlight` 断言 live tick 期间 `isRefreshing && !isManualRefreshing`。
- 有可见行时，live/日期根刷新走 caption 内 `showsInlineRefreshProgress`（`isRefreshing && !isManualRefreshing`），无障碍标签「正在更新诊断日志」，不是右上角按钮。

### 6. IMPLEMENT AUTH 是否被当成 bearer token？exclusions 是否仍覆盖 merge / required / PR #83？

**没有当成可执行的无限令牌。exclusions 仍覆盖所问三项。**

- Assignment `authorization_action` / `authorization_refs` 对齐 `AUTH-DIAGNOSTICS-VIEWER-LOAD-001-IMPLEMENT`（`action: implement`，`target: DIAGNOSTICS-VIEWER-LOAD-001`）。先前 `AUTH-DIAGNOSTICS-VIEWER-LOAD-001`（`establish_assignment`）已 `consumed`，没有拿「建 Assignment」收据改代码。
- IMPLEMENT 收据 `exclusions`: `required_mode`, `merge`, `release`, `scheme_download_fix`, `pr_83_merge`, `writer_or_extension_hot_path`, `raise_read_budget`。正文：「不授权 merge、`required`、方案下载或 PR #83」。
- 冻结 HEAD 未 merge、未改 PR #83 范围、未切 `required`。KOS 仍为 advisory pin（[`UPGRADE_STATUS.md`](../kos/UPGRADE_STATUS.md)）。本复审也不授权上述任何一项。
- IMPLEMENT `consumption_state` 在 `878b02a` 与 `ec5e8e9` 均已落入仓库后仍为 `unconsumed`。这是 TD-014 同类审计滞后，不是用收据去 merge / required。Kit 把 consumption 当观察、不提供 replay 保护。见 A-P2-03。

---

## Findings

| ID | Sev | Disposition | Description |
|---|---|---|---|
| A-P1-01 | P1 | `closed`（`ec5e8e9` `fix`） | 上一轮：skip 在加载后重采样 watermark。现：`lastLiveRefreshIdentity` 只等于触发解码的 peek；`testLiveRefreshReloadsWhenIdentityAdvancesDuringLoad` 覆盖 `loadLogText` 返回后 identity 前进。不得再把 live-follow 合同写成未闭合。 |
| A-P2-01 | P2 | `accept` | `liveRefreshIdentity()` 失败返回 `nil` 时不 skip，空列表下 1 秒 tick 会反复 `isRefreshing` 并显示加载面（含 snapshot fence busy）。偏保守、不漏事件。不阻塞 Quality；不必为本 Assignment 改 writer 锁协议。 |
| A-P2-02 | P2 | `accept` | 无 `DiagnosticsLogContentView` 级回归断言「`isRefreshing` 时不出现暂无诊断日志」。Store 已覆盖 flag。属 Quality 证据完整度，不改变架构分支。 |
| A-P2-03 | P2 | `tech_debt:TD-014` | `AUTH-DIAGNOSTICS-VIEWER-LOAD-001-IMPLEMENT` 在实现提交后仍 `unconsumed`。exclusions 已挡住 merge / `required` / PR #83。后续 Envelope 卫生处理，不要在本审查里改收据或切 `required`。 |
| A-P3-01 | P3 | `accept` | skip 命中仍每秒 exclusive snapshot fence + 全段 `stat`。比 JSONL 根解码轻，未抬预算。Writer 仍 nonblocking。若日后 1 秒 CPU 成为真机问题，再单独立项，不得用提高 5 MiB/10k 解决。 |
| A-P3-02 | P3 | `accept` | peek 与 `beginPage` 仍分两次 exclusive fence。append 落在两锁之间时，解码可能新于 peek，`last` 仍为 peek，下一 tick 多一次跟进加载。这是保守余量，不是 A-P1-01 的 skip-miss。同 fence 身份不在本 Assignment 授权范围内。 |

---

## Residuals (M-03)

| Residual ID | Owner | Disposition | Pointer |
|---|---|---|---|
| A-P1-01 live-skip TOCTOU | — | `closed` at `ec5e8e9` | Quality 须复验 peek-bind 测试，而不是再开架构 P1 |
| A-P2-01 nil identity reload | Quality（观测即可） | `accept` | lockBusy → 全量加载 |
| A-P2-02 缺 View 断言 | Quality | `accept` | 可在 Quality 补测或接受 Store+代码审查 |
| A-P2-03 IMPLEMENT AUTH unconsumed | Architecture & Knowledge Steward | `tech_debt:TD-014` | [`TECH_DEBT.md` TD-014](../TECH_DEBT.md) |
| A-P3-01 每秒 fence+stat | 无（非本 Assignment） | `accept` | ADR 0027 约 1 秒可见 |
| A-P3-02 peek≠beginPage fence | 无（非本 Assignment） | `accept` | 多一次跟进加载 |

**Close 含义：** 架构侧 A-P1-01 已落地，独立 Quality **可以开始**。`accept` / `tech_debt:TD-014` 不阻塞 Quality。本 Assignment **仍不得** Close：还缺独立 Quality 结论与 Human 真机复验。Quality 不得把本文件当成 merge / PR #83 / `required` / Human Product Gate 授权。

---

## Conditions for Quality

独立 Quality 可以开始。至少核对：

1. 根加载在 source 未返回时 UI 为「正在加载诊断日志」，不是「暂无诊断日志」。
2. 筛选空 / partial 空 / 真·无 journal 三种文案在 `isRefreshing == false` 时仍可区分。
3. 预算常量未变；无 Extension/writer 热路径 diff。
4. A-P1-01：`last` 等于触发解码的 peek；`testLiveRefreshReloadsWhenIdentityAdvancesDuringLoad`（或等价「加载期间追加」）证明下一 tick 不 skip。可以把 live-follow skip 合同写成已按 peek-bind 闭合，但不得写成已真机验证或已 merge。
5. 手动刷新 spinner 仅 `isManualRefreshing`。
6. 不把 IMPLEMENT AUTH、上一轮 Architecture 或本 Re-review Verdict 写成 merge / Release / `required` / PR #83。

---

## Non-claims

- 不是 Human 真机复验。
- 不是 Simulator 全量套件重跑（审查未执行 xcodebuild / `swift test`）。
- 不是 ADR 0028 Acceptance。
- 不是 PR #83、方案下载、INTEGRITY-001 万象分类、TestFlight、Release 或 `required`。
- 不是 Assignment Close。
- 不是授权把 KOS 2.2 从 advisory 升级为 required。
