# DIAGNOSTICS-VIEWER-LOAD-001 — Independent Quality Review

## Review identity

| Field | Value |
|---|---|
| Reviewer | `quality_review` / 独立 Quality Reviewer（本审查会话） |
| Date / timezone | `2026-08-27 Asia/Shanghai` |
| Frozen commit | `ec5e8e9086fbf72537d6d20215f48ea301bfdd66` (`fix/diagnostics-viewer-load-001`) |
| Subject | `fix: bind diagnostics live skip to the pre-load identity` |
| Architecture input | [`DIAGNOSTICS-VIEWER-LOAD-001-architecture-review.md`](DIAGNOSTICS-VIEWER-LOAD-001-architecture-review.md) of `878b02a` — **Pass with conditions**（P1 A-P1-01）；[`DIAGNOSTICS-VIEWER-LOAD-001-architecture-rereview.md`](DIAGNOSTICS-VIEWER-LOAD-001-architecture-rereview.md) of `ec5e8e9` — **Pass**（P0=0 · P1=0）。Architecture 已允许 Quality 开始。 |
| Objects | [`DIAGNOSTICS-VIEWER-LOAD-001`](../assignments/diagnostics-viewer-load-001.md) · [`AUTH-DIAGNOSTICS-VIEWER-LOAD-001-IMPLEMENT`](../authorizations/AUTH-DIAGNOSTICS-VIEWER-LOAD-001-IMPLEMENT.md) · [ADR 0027](../architecture/decisions/0027-enterprise-local-diagnostic-observability.md) · [`DEBUGGING.md`](../DEBUGGING.md) 诊断页合同 · `DiagnosticsLogContentView.swift` · `DiagnosticsView.swift` · `DiagnosticsStore.swift` · `DiagnosticsToolbar.swift` · `DiagnosticsLogSource.swift` · `DiagnosticsJournal.swift`（Reader `liveRefreshIdentity` / 预算常量）· `UniverseKeyboardTests/DiagnosticsStoreTests.swift` · Executor evidence [`diagnostics-viewer-load-implementation-2026-08-27.md`](../evidence/diagnostics-viewer-load-implementation-2026-08-27.md) |
| Independence | 本审查不是 `878b02a` 或 `ec5e8e9` 的作者（reflog Author 均为 `Cowork 3P`）。不把对话史当权威。审查只读生产 Swift；未 commit / push / PR，未开启 `required`，未 merge PR #83，未关 Assignment / Gate。唯一写入为本审查文件。 |
| Scope | 复核 Architecture Conditions for Quality 1–6：加载态 vs 空态、三种空态、ADR 0027 预算与 Extension/writer 隔离、peek-bind live skip、手动 spinner、AUTH 非 bearer。不是 Architecture 重写、不是 Product Gate、不是 merge。KOS 2.2 仍为 advisory。 |

**HEAD 核对：** `.git/HEAD` = `ref: refs/heads/fix/diagnostics-viewer-load-001`；`refs/heads/fix/diagnostics-viewer-load-001` = `ec5e8e9086fbf72537d6d20215f48ea301bfdd66`。`.git/logs/HEAD`：`74e85b3` → amend `878b02a`（`fix: distinguish diagnostics load from empty journal`）→ `5aa09a7`（记录 `878b02a` Architecture）→ `ec5e8e9`（本冻结点）。`COMMIT_EDITMSG` subject 与冻结 commit 一致。

**`git show` 方法限制：** 本 Quality 会话无 git CLI；GitHub 上该 SHA 返回 404（分支未作为可抓取 commit 公开）。未能独立解压 zlib object 得到 `--stat`。范围核对依赖：(1) 上述 freeze/reflog；(2) 工作树源码与测试；(3) Architecture 记录的 `878b02a` 15 files, +293/−21，以及 `ec5e8e9` 仅改 Store skip 提交点 + `testLiveRefreshReloadsWhenIdentityAdvancesDuringLoad` + `DEBUGGING.md` 合同。见 Q-P3-04。这不改变冻结 SHA 的身份核对。

---

## Verdict

**Pass with conditions**

根加载在 source 返回前由 Store 置 `isRefreshing`；内容区第一分支在「无可见行且刷新中」时走「正在加载诊断日志」，「暂无诊断日志」不在该窗口。筛选空 / partial 空 / 真·无 journal 在 `isRefreshing == false` 时仍分叉。ADR 0027 常量仍为 5 MiB / 10,000；工作树中 `Keyboard/` 无 live-identity / 加载面符号，Reader `liveRefreshIdentity` 不解码 JSONL。`lastLiveRefreshIdentity` 只提交触发解码的 peek；`testLiveRefreshReloadsWhenIdentityAdvancesDuringLoad` 覆盖加载期间 identity 前进后下一 tick 必须再加载。工具栏 spinner 只绑 `isManualRefreshing`。IMPLEMENT AUTH 不是 merge / `required` / PR #83 的 bearer token。

无未处置 **P0 / P1**。条件（不把 Verdict 升为 Fail）：View 层无字符串断言（接受 Store+代码审查）；Quality **未**独立重跑 xcodebuild / `swift test` / swift-format（按交接指示采信 Executor-recorded，且不得把全量 `DiagnosticsStoreTests` 写成绿）；Human 真机复验仍为 Assignment handoff。

Finding counts: **P0: 0 · P1: 0 · P2: 2 · P3: 4**

本 Verdict：

- **不是** Assignment Close；
- **不是** Human 真机复验或 Product Gate；
- **不**授权 merge、`required`、Release、TestFlight 或 PR #83；
- **不**把 KOS validator 绿当成 Gate。

---

## Answers to Architecture Conditions 1–6

### 1. 根加载在 source 未返回时，UI 是否为「正在加载诊断日志」而不是「暂无诊断日志」？

**实现上是。证据是 Store 测试 + 内容区第一分支代码审查，不是 View 字符串断言。**

- `DiagnosticsStore.loadLog()` / `selectLogDay(_:)` 在进入 source `await` **之前**置 `isRefreshing = true`。
- `DiagnosticsView` 把 `store.isRefreshing` 与 `store.displayedLines` 传入内容区。
- `DiagnosticsLogContentView` 第一分支：`displayedLines.isEmpty && isRefreshing` → `DiagnosticsLoadingStateView`（标题「正在加载诊断日志」；说明「正在读取本地记录，这不是空日志。」）。
- 「暂无诊断日志」只出现在 `DiagnosticsEmptyStateView.emptyTitle` 的最后回退，且该视图只在 `displayedLines.isEmpty` **且** `!isRefreshing` 时挂载。

`testRootLoadMarksRefreshingBeforeSourceReturns`：`loadLog()` 后等到 source continuation 仍未完成时，`isRefreshing == true`、`lines` 为空、`isManualRefreshing == false`。

Architecture A-P2-02 允许 Quality 接受 Store+代码审查。本审查接受该路径，**不**把 Condition 1 判失败。残留：没有任何测试断言 SwiftUI 在 `isRefreshing` 时字符串「暂无诊断日志」不出现。见 Q-P2-01。Quality **没有** Simulator 截图钉住加载面。

判定用的是**可见行**（筛选后）。筛选无匹配时一次根/live 刷新会暂时盖住筛选空态、显示加载面，而不是「暂无诊断日志」。与 [`DEBUGGING.md`](../DEBUGGING.md)「`isRefreshing` 且当前没有可见行」一致。

### 2. 筛选空 / partial 空 / 真·无 journal 在 `isRefreshing == false` 时是否仍可区分？

**是。未刷新完成时加载面优先；刷新完成后三种标题仍分叉。`ec5e8e9` 未改空态字符串。**

| 条件（`isRefreshing == false`） | 标题 | 代码依据 |
|---|---|---|
| `hasLoggedLines`（`!store.lines.isEmpty`）且 `displayedLines` 空 | 当前筛选无匹配日志 | `emptyTitle` 第一支 |
| `!hasLoggedLines && isPartialWindow` | 当前窗口暂无可展示记录 | `emptyTitle` 第二支 |
| 其余空列表 | 暂无诊断日志 | 回退 |

`isPartialWindow` 来自 `lastPageStatus == .partialRecentWindow`。`V1DiagnosticsLogSource.loadLogText()` 在 `events.isEmpty` 早退**之前**写入 `lastPageStatus` 与 `usedV1Result`（`status != .completed` 时为真），因此空事件 + partial 不会被改写成 true-empty，也不会掉进 legacy 自由文本。`testPartialWindowCanBeEmptyWithoutLookingLikeNoLogsExist` 钉住 Store：刷新结束后 `lines` 空且 `isPartialWindow == true`。筛选空没有单独 Store 字符串测试，但 `hasLoggedLines` 绑定未筛选的 `store.lines`，与 `displayedLines`（筛选后）分离。符合 Assignment 非目标「不把有界窗口描述为完整历史」。

catalog `.unavailable` 且当前 `lines` 已空、刷新已结束时，仍可能同时出现 paging notice 与「暂无诊断日志」。这是刷新**完成后**的受控不可读，不是加载中伪装。

### 3. ADR 0027 常量是否仍为 5 MiB / 10,000？diff 是否不含 Extension / writer 热路径？

**常量未变。工作树核对未发现 Keyboard Extension 或 writer append/lease 热路径被本工作项改写。独立 `git show --stat` 未执行。**

- `DiagnosticsJournalReader.defaultMaximumEventCount = 10_000`
- `DiagnosticsJournalReader.defaultMaximumReadBytes = 5 * 1_024 * 1_024`
- `beginPage` / `nextPage` / `recentPreview` 仍 `min(..., defaultMaximum*)`
- `DiagnosticsStore.exportMaximumRecordCount` / `exportMaximumByteCount` 仍为 10_000 / 5 MiB

`liveRefreshIdentity()` 在 **Reader** 上：`stableSegmentManifest` + 段 `byteWatermark`，注释写明不解码事件。`Keyboard/` 对 `liveRefreshIdentity` / `DiagnosticsJournalLiveRefreshIdentity` / 「正在加载诊断日志」**零匹配**。`DiagnosticsJournalWriter.append` 仍是既有独占段追加 API；本审查未见加载态或 skip 逻辑进入 writer / lease / generation / retention。AUTH exclusions 含 `writer_or_extension_hot_path`、`raise_read_budget`。

因无独立 `--stat`，Quality **不**把「15 files」复述成亲自 `git show` 的结果。Architecture 两轮均记录无 Extension/writer 热路径；工作树 grep 与之相容。见 Q-P3-04。

### 4. A-P1-01：`last` 是否等于触发解码的 peek？加载期间前进后下一 tick 是否不 skip？

**是。live-follow skip 合同按 peek-bind 闭合。不得写成已真机验证或已 merge。**

当前形状：

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

`lastLiveRefreshIdentity` 在工作树中只有三处写入：成功 apply、`performClear` 置 `nil`、以及 skip 比较。catalog `.unavailable` 早退与 revision 失配早退**不**写 `last`（偏保守）。

`IdentityStubLogSource`：`loadLogText` 返回后把 identity 改成 `identityAfterReturningLoad`。`testLiveRefreshReloadsWhenIdentityAdvancesDuringLoad`：peek/load 用 `g1:1:20` 得到 `second event`；load 返回时 identity 变为 `g1:1:30`；第二次 tick 在 identity 已是 `30` 时仍再调 `loadLogText` 得到 `third event`。测试未直接读 private `last`，但第二次 `loadCallCount` +1 即证明下一 tick **没有** skip。

Executor-recorded：该用例含在隔离 `DiagnosticsStoreTests` **TEST SUCCEEDED (4/0)** 中。本 Quality **未**重跑。

**允许的说法：** skip 已按「触发解码的 peek」绑定闭合。  
**禁止的说法：** 已真机验证；已 merge；全量 `DiagnosticsStoreTests` 绿。

Peek 与 `beginPage` 仍是两次 exclusive fence（Architecture A-P3-02）。那只会在 peek < 实际解码水位时多一次跟进加载，**不会**把更新的盘面身份当成已展示而 skip。

### 5. 手动刷新 spinner 是否仅 `isManualRefreshing`？

**是。**

- `DiagnosticsView` 工具栏：`isRefreshing: store.isManualRefreshing`。
- `DiagnosticsToolbar` 右上角 `ProgressView` 只看该入参。
- `refresh()` 同时置 `isRefreshing` 与 `isManualRefreshing`。
- `performLiveRefreshTick` 只置 `isRefreshing`，且要求 `!isRefreshing` 才进入，不与手动刷新重叠。
- 有可见行时的 caption 转圈：`showsInlineRefreshProgress = store.isRefreshing && !store.isManualRefreshing`，无障碍「正在更新诊断日志」，不是右上角按钮。
- `testRootLoadMarksRefreshingBeforeSourceReturns`：根加载 `!isManualRefreshing`。
- `testLiveRootRefreshPreventsOlderPageFromStartingWhileCatalogIsInFlight`：live tick 期间 `isRefreshing && !isManualRefreshing`。

### 6. IMPLEMENT AUTH / Architecture Verdict 是否被写成 merge / Release / `required` / PR #83？

**本审查不把它们写成上述任何一项。收据 exclusions 仍覆盖所问项。**

- `AUTH-DIAGNOSTICS-VIEWER-LOAD-001-IMPLEMENT`：`action: implement`；exclusions：`required_mode`, `merge`, `release`, `scheme_download_fix`, `pr_83_merge`, `writer_or_extension_hot_path`, `raise_read_budget`。正文：「不授权 merge、`required`、方案下载或 PR #83」。
- Assignment 仍 `active`；handoff 是 Human 真机复验，然后回到 INTEGRITY-001。
- `GATE-DIAGNOSTICS-VIEWER-LOAD-IMPLEMENTATION` 仍 `open`；`required_evidence_refs` 仍是入口 Human 阻塞截图，不是本实现回归。Quality **不**关 Gate。
- `.kos/project.json` `record_envelopes.mode` 仍为 `advisory`。Executor 记录的 `validate-kos.sh` `PASS KOS2000` **不是** Gate。
- IMPLEMENT `consumption_state` 在代码已落入 `ec5e8e9` 后仍为 `unconsumed`。属 TD-014 同类审计滞后，不是用收据去 merge。见 Q-P2-02。

---

## Evidence table

Quality **未**重跑下列命令（交接指示：Executor-recorded 已采集，除非必须否则不重跑）。下表区分「Executor 已记录」与「本审查亲自执行」。Quality **不**把未跑项写成通过。

| Check | Who | Result Quality will claim |
|---|---|---|
| Freeze SHA `ec5e8e9` on `fix/diagnostics-viewer-load-001` | Quality（读 `.git/HEAD` / ref / reflog / `COMMIT_EDITMSG`） | 已核对 |
| 加载面 / 空态 / peek-bind / spinner / 预算常量 代码审查 | Quality | 已核对；见 Conditions 1–5 |
| `Keyboard/` 无 live-identity / 加载面符号 | Quality（grep） | 零匹配 |
| `swift test --package-path Packages/KeyboardCore --filter DiagnosticsJournalTests.testLiveRefreshIdentityChangesWhenBytesAreAppended` | Executor-recorded | passed。Quality 未重跑 |
| 隔离 `UniverseKeyboardTests/DiagnosticsStoreTests` 四例（含 `testRootLoadMarksRefreshingBeforeSourceReturns`、`testLiveRefreshSkipsRootLoadWhenIdentityIsUnchanged`、`testLiveRefreshReloadsWhenIdentityChanges`、`testLiveRefreshReloadsWhenIdentityAdvancesDuringLoad`） | Executor-recorded | `TEST SUCCEEDED (4/0)`；destination `iPhone 17 Pro` UDID `8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2`（iOS 26.0）。Quality 未重跑 |
| 全量 `DiagnosticsStoreTests` | 未作为本工作项绿证据 | **不得**写成 suite green。Executor 与交接均记录 Xcode 27 / IOHIDLib/malloc **host crash** 历史 |
| 仅名称 destination `iPhone 17 Pro`（无 id） | Executor-recorded | 因多 OS 版本失败；证据必须带 UDID |
| Debug build 同 UDID | 交接 briefing 称 Executor SUCCEEDED | **未**写入 [`diagnostics-viewer-load-implementation-2026-08-27.md`](../evidence/diagnostics-viewer-load-implementation-2026-08-27.md)。Quality 未重跑，**不**升格为独立验证 |
| Release build 同 UDID | 同上 | 同上 |
| `swift-format lint --strict` on `DiagnosticsStore.swift` / `DiagnosticsStoreTests.swift` | 交接 briefing 称 passed | **未**写入上述 evidence 文件。Quality 未重跑，**不**升格为独立验证 |
| View 层字符串断言 / SwiftUI snapshot | 无 | 未跑；Q-P2-01 `accept` |
| `KOS_AS_OF=2026-08-27T22:00:00+08:00 bash kos-agent-kit/scripts/validate-kos.sh` | Executor-recorded | `PASS KOS2000`。advisory only；**不是** Gate |
| Human 真机加载复验 | 未做 | Assignment 仍要求。入口证据 [`diagnostics-viewer-load-2026-08-27.md`](../evidence/diagnostics-viewer-load-2026-08-27.md) 是**阻塞前**截图，不是修复后复验 |
| 独立 `git show --stat` | Quality 未能执行 | 见 Q-P3-04 |
| CI 全量 / App+Keyboard 套件 / RimeBridgeTests | 未跑 | 不在本审查亲自执行范围 |

---

## Findings

| ID | Sev | Disposition | Description |
|---|---|---|---|
| Q-P2-01 | P2 | `accept` | 与 Architecture A-P2-02 同一观察：无 `DiagnosticsLogContentView` 级回归断言「`isRefreshing` 时不出现暂无诊断日志」。Store 已覆盖 flag 与 partial 空窗。Quality 按允许路径接受 Store+代码审查满足 Condition 1–2，**不**因此 Fail。 |
| Q-P2-02 | P2 | `tech_debt:TD-014` | `AUTH-DIAGNOSTICS-VIEWER-LOAD-001-IMPLEMENT` 在 `ec5e8e9` 落地后仍 `unconsumed`。exclusions 已挡住 merge / `required` / PR #83。后续 Envelope 卫生处理；本审查不改收据、不切 `required`。 |
| Q-P3-01 | P3 | `accept` | Architecture A-P2-01：`liveRefreshIdentity()` 失败（`nil` / lockBusy）不 skip，空列表下 1 秒 tick 可能反复加载面。偏保守、不漏事件。观测即可。 |
| Q-P3-02 | P3 | `accept` | Architecture A-P3-01 / A-P3-02：skip 命中仍每秒 exclusive fence + 段 `stat`；peek 与 `beginPage` 分两次 fence，最坏多一次跟进加载。未抬 5 MiB/10k。不在本 Assignment 授权范围内改锁协议。 |
| Q-P3-03 | P3 | `accept` | `GATE-DIAGNOSTICS-VIEWER-LOAD-IMPLEMENTATION` 仍 `open`，标题/正文仍写「Implementation not started」。入口证据仍是 Human 阻塞截图。Quality **不**关 Gate，也不把 Executor Simulator 结果写成 Gate Pass。 |
| Q-P3-04 | P3 | `accept` | 本会话无 git CLI，未能独立 `git show --stat`；GitHub 对该 SHA 404。Extension/writer 隔离靠工作树 grep + Architecture `--stat` 记录。不把 Architecture 的文件计数复述成 Quality 亲自 `git show`。 |

无新增 P0/P1。无 `tech_debt` 以外的新债项。

### Architecture residuals — Quality disposition

| Arch ID | Quality 判定 |
|---|---|
| A-P1-01 peek-bind | **闭合（代码 + 定向测试合同）**。不得写成真机/merge。 |
| A-P2-01 nil identity | 不阻塞。Q-P3-01 `accept`。 |
| A-P2-02 缺 View 断言 | 不阻塞 Quality Pass with conditions。Q-P2-01 `accept`。 |
| A-P2-03 IMPLEMENT unconsumed | 不阻塞。Q-P2-02 `tech_debt:TD-014`。 |
| A-P3-01 fence+stat | 不阻塞。Q-P3-02。 |
| A-P3-02 双 fence | 不阻塞。Q-P3-02。 |

---

## Residuals (M-03)

| Residual ID | Owner | Disposition | Pointer |
|---|---|---|---|
| Human 诊断页真机加载复验 | Human Product Owner | **required by Assignment handoff** | 同一诊断页；之后按 INTEGRITY-001 复测万象。入口截图不是修复后证据 |
| View 字符串断言 | 可选后续 | `accept` | Q-P2-01 / A-P2-02 |
| 全量 `DiagnosticsStoreTests` host crash | 已知环境限制 | 不得当绿 | Xcode 27 IOHIDLib/malloc |
| Debug/Release / swift-format 独立复跑 | 未在本审查执行 | Executor briefing 声称通过；evidence 文件未完整收录 | 不得写成 Quality 亲自验证 |
| IMPLEMENT AUTH `unconsumed` | Architecture & Knowledge Steward | `tech_debt:TD-014` | [`TECH_DEBT.md` TD-014](../TECH_DEBT.md) |
| Gate 仍 open / 文案过期 | Human Product Owner | 保持 open | 不由本 Quality 关闭 |
| 1.39 GB / 133% CPU 入口观察 | 非本 Assignment 合同 | 不得写成新内存预算 | [`diagnostics-viewer-load-2026-08-27.md`](../evidence/diagnostics-viewer-load-2026-08-27.md) |

**Close 含义：** 独立 Quality 已记录。本 Assignment **仍不得** Close：还缺 Human 真机复验。本文件 **不是** merge / PR #83 / `required` / Human Product Gate / Release 授权。

---

## Non-claims

- 不是 Human 真机复验，也不是修复后加载空态截图合同。
- 不是本审查亲自执行的 Simulator 套件、Debug/Release build、swift-format 或 KOS validator。
- 不是全量 `DiagnosticsStoreTests` 绿。
- 不是 ADR 0028 Acceptance。
- 不是 PR #83、方案下载、INTEGRITY-001 万象分类、TestFlight、Release 或 `required`。
- 不是 Assignment Close，也不是 `GATE-DIAGNOSTICS-VIEWER-LOAD-IMPLEMENTATION` 关闭。
- 不是授权把 KOS 2.2 从 advisory 升级为 required。
- 不是把入口 Activity Monitor 1.39 GB / 133% CPU 写成正式内存/CPU 合同。
- 不是 live-follow 已在真机上验证，也不是该分支已 merge。
