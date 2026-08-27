# DIAGNOSTICS-VIEWER-LOAD-001 — Independent Quality Review (reader-load follow-up)

## Review identity

| Field | Value |
|---|---|
| Reviewer | `quality_review` / 独立 Quality Reviewer（本 reader-load 审查会话） |
| Date / timezone | `2026-08-27 Asia/Shanghai` |
| Frozen commit | `5b4a0eacfe262917ec26bfbcf39198df89003666` (`fix/diagnostics-viewer-load-001`) |
| Subject | `fix: stop diagnostics live skip from taking exclusive snapshot fence` |
| Architecture input | [`DIAGNOSTICS-VIEWER-LOAD-001-architecture-rereview-reader-load.md`](DIAGNOSTICS-VIEWER-LOAD-001-architecture-rereview-reader-load.md) of `5b4a0ea` — **Pass with conditions**（P0=0 · P1=0）。Architecture 已允许 Quality 开始。 |
| Prior Quality | [`quality-review.md`](DIAGNOSTICS-VIEWER-LOAD-001-quality-review.md) of `ec5e8e9` — **Pass with conditions**。**不覆盖**本 SHA。 |
| Objects | [`DIAGNOSTICS-VIEWER-LOAD-001`](../assignments/diagnostics-viewer-load-001.md) · [`AUTH-DIAGNOSTICS-VIEWER-LOAD-001-IMPLEMENT`](../authorizations/AUTH-DIAGNOSTICS-VIEWER-LOAD-001-IMPLEMENT.md) · [ADR 0027](../architecture/decisions/0027-enterprise-local-diagnostic-observability.md) · [`DEBUGGING.md`](../DEBUGGING.md) · `DiagnosticsJournal.swift`（无锁 probe / exclusive `beginPage`）· `DiagnosticsStore.swift` · `DiagnosticsView.swift` · `DiagnosticsLogSource.swift` · `DiagnosticsLogContentView.swift`（本 SHA 未改；加载面采信先前 Quality + 工作树）· `DiagnosticsJournalTests.testLiveRefreshIdentityAndDateCatalogDoNotTakeExclusiveFence` · `UniverseKeyboardTests/DiagnosticsStoreTests.swift` · Executor evidence [`diagnostics-viewer-load-implementation-2026-08-27.md`](../evidence/diagnostics-viewer-load-implementation-2026-08-27.md) |
| Independence | 本审查不是 `5b4a0ea` 的作者（reflog Author 为 `Cowork 3P`）。不把 `ec5e8e9` Quality 或对话史当成本 SHA 的覆盖。审查只读生产 Swift；未改生产代码，未 commit / push / PR，未开启 `required`，未 merge PR #83 / #85，未关 Assignment / Human Product Gate。唯一写入为本审查文件。 |
| Scope | 复核 Architecture Conditions for Quality 1–6：shared-fence 下 identity/catalog vs `beginPage` lockBusy；peek-bind 与 retryable 不绑定；nil-after-bind skip / 未 bind 不 skip / 再进入 skip；预算与 Extension/writer 隔离；加载面与三种空态未回退；AUTH / Architecture / KOS / Activity Monitor **不是** merge / `required` / 新内存合同 / 高保真 Gate。不是 Architecture 重写、不是 Product Gate、不是 merge。KOS 2.2 仍为 advisory。 |

**HEAD 核对：** `.git/HEAD` = `ref: refs/heads/fix/diagnostics-viewer-load-001`；`refs/heads/fix/diagnostics-viewer-load-001` = `5b4a0eacfe262917ec26bfbcf39198df89003666`。`COMMIT_EDITMSG` subject 与冻结 commit 一致。`.git/logs/HEAD`：`ec5e8e9`（peek-bind）→ `54d33fa` / `832ef50`（记录审查与 PR #85）→ **`5b4a0ea`（本冻结点）**。

**`git show` 范围：** 本 Quality 对照 GitHub 公开 commit `5b4a0ea` 文件树与工作树（未解本地 zlib object、未拉起 git 二进制）。生产 Swift 出现在：`DiagnosticsJournal.swift`、`DiagnosticsJournalTests.swift`、`DiagnosticsStore.swift`、`DiagnosticsView.swift`、`DiagnosticsLogSource.swift`、`DiagnosticsStoreTests.swift`。文档：`CHANGELOG.md`、`DEBUGGING.md`、Assignment / evidence / dashboard。**未**出现：`Keyboard/` Extension、`DiagnosticsJournalWriter` append/lease、`DiagnosticsLogContentView.swift`、RIME、方案下载、PR #83 范围。

---

## Verdict

**Pass with conditions**

1 秒 skip 与日期目录在持 shared fence 时仍能读出 identity/catalog；`beginPage` 仍 `.lockBusy`。A-P1-01 peek-bind 仍在：`last` 只提交触发解码的 peek；加载中 identity 前进后下一 tick 再加载；retryable notice 不写 `last`（代码审查，无直接 Store 断言）。成功 bind 后 nil peek skip；未 bind 时 nil 不 skip。再进入在非空 `lines` 且水位未变时不调用 `loadLogText`。5 MiB / 10,000 未抬高；本 SHA 无 Extension / writer 热路径。加载面与三种空态不在本 diff 内，工作树第一分支仍是「正在加载诊断日志」。IMPLEMENT AUTH、本 Verdict、KOS 绿与 Activity Monitor 数字都不是 merge / `required` / 新内存合同 / 高保真 Gate。

无未处置 **P0 / P1**。条件（不把 Verdict 升为 Fail）：Quality **未**独立重跑 `swift test` / xcodebuild；retryable 不绑定与 nil-before-bind 靠代码审查；View 层仍无字符串断言；Human Product Gate 仍为 Assignment handoff。Human 所称今日/昨日 journal 查看 <100 MB（高保真关）是意图路径的设备观察，**不是**正式内存合同，也 **不是** Product Gate。

Finding counts: **P0: 0 · P1: 0 · P2: 3 · P3: 4**

本 Verdict：

- **不是** Assignment Close；
- **不是** Human Product Gate 或修复后加载空态截图合同；
- **不**授权 merge、`required`、Release、TestFlight、PR #83 或 PR #85；
- **不**把 KOS validator 绿当成 Gate；
- **不**把 Activity Monitor / 工作集数字写成新的内存预算；
- **不是**高保真探针 Gate，也 **不是** 万象 / INTEGRITY-001。

---

## Answers to Architecture Conditions 1–6

### 1. `testLiveRefreshIdentityAndDateCatalogDoNotTakeExclusiveFence`：shared fence 下 identity/catalog 成功，`beginPage` 仍 lockBusy？

**测试合同与实现形状一致。Quality 未重跑；采信 Executor-recorded 25 passed（含该例）。**

实现：

- `liveRefreshIdentity()`：`readControl` + `segmentURLs` + `attributes[.size]`。注释与代码均不调用 `withExclusiveSnapshotFence`。
- `availableDateCatalog()`：只解析文件名里的 UTC 小时。不取 exclusive。
- `beginPage` → `pageSnapshot` → `stableSegmentManifest`：仍 `withExclusiveSnapshotFence` + identity locks。

测试：后台线程 `withSharedSnapshotFence` 内 `started.resume()` 后阻塞；主路径 `try await liveRefreshIdentity()` / `availableDateCatalog()` 必须成功（`totalByteWatermark > 0`、`ranges` 非空）；`beginPage` 必须 throw `.lockBusy`，成功则 `XCTFail`。若 probe 仍抢 exclusive，identity/catalog 会在共享占用下失败，测试不会绿。

Executor-recorded：`swift test --package-path Packages/KeyboardCore --filter DiagnosticsJournalTests` — 25 passed，including this test。Quality **未**重跑，不把该命令写成亲自绿。

### 2. A-P1-01 peek-bind 是否仍成立？加载中 append 下一 tick 再加载？retryable notice 不 bind last？

**peek-bind 与加载中前进仍由 Store 测试钉住。retryable 不绑定：代码审查接受（A-P2-05），无直接 Store 断言。**

形状：

```text
performLiveRefreshTick:
  I = liveRefreshIdentity()          // 无锁目录水位
  若 I != nil 且 I == last → skip
  若 I == nil 且 last != nil → skip（Condition 3）
  否则 replaceWithLatestPage(..., peeked: I)

replaceWithLatestPage 在 apply 之后:
  若 notice 非 retryable → last = peeked   // 禁止再采样盘面
  若 retryable → 不写 last
```

`testLiveRefreshReloadsWhenIdentityAdvancesDuringLoad`：peek/load 用 `g1:1:20` 得到 `second event`；`loadLogText` 返回后 identity 变为 `g1:1:30`；下一 tick 再调 `loadLogText` 得到 `third event`。第二次 `loadCallCount +1` 证明没有把 `30` 当成已展示而 skip。

retryable 字符串与 `V1DiagnosticsLogSource.pagingNotice` 对齐：

| notice | 来源 |
|---|---|
| `日志正在轮转或回收，请刷新后查看当前记录。` | catalog `.unavailable` 早退 **以及** `.snapshotUnavailable` |
| `诊断日志暂时不可用；旧日志不会在此状态下自动混入当前视图。` | `beginPage` throw → `.journalUnavailable`（含 exclusive `lockBusy`） |

catalog `.unavailable` 早退本身就不走到 bind。`IdentityStubLogSource` 不是 paging source，`replaceWithLatestPage` 在该 stub 上 `notice == nil`，因此 **没有** Store 测试直接断言 retryable 使下一 tick 仍 `loadLogText`。Quality 按 Architecture 允许路径用源码分支接受，见 Q-P2-02。不得写成已真机验证或已 merge。

### 3. 成功 bind 后 nil peek skip；未 bind 时 nil 不 skip。再进入：非空 lines + 未变水位不调用 loadLogText？

**是。nil-after-bind 与再进入有 Store 测试；nil-before-bind 靠代码审查。**

成功 bind 后 nil skip：`testLiveRefreshSkipsWhenIdentityPeekFailsAfterASuccessfulBind` — 先加载 `g1:1:10` 得到可见行，再把 identity 置 `nil`，tick 后 `loadCallCount` 不变、行仍在、`!isRefreshing`。

未 bind 时 nil 不 skip：`performLiveRefreshTick` 仅当 `peekedIdentity == nil && lastLiveRefreshIdentity != nil` 才 return。`last == nil`（从未成功提交非空 peek）时该分支为假，继续 `replaceWithLatestPage`。`loadLog()` 在空列表路径同样不走再进入 skip。无单独用例钉住「首次 tick + nil identity 仍 load」；见 Q-P3-01。不升 P1：空列表根加载本来就会 `loadLogText`。

再进入：`loadLog()` 在 `!lines.isEmpty && last != nil` 时 `reloadRootIfIdentityChanged()`；identity 为 nil 或等于 `last` 则 return，不置根 spinner、不 `loadLogText`。`testLoadLogSkipsWhenCachedIdentityIsUnchanged` 钉住第二次 `loadLog()` 的 `loadCallCount` 不变。水位变化则 peek ≠ last，会再解码。

`DiagnosticsView`：`@State private var store = DiagnosticsStore.shared`。测试一律 `DiagnosticsStore(logSource:)`，不碰单例。

### 4. 预算常量是否未变？本 SHA 是否无 Extension / writer 热路径？

**常量未变。GitHub `5b4a0ea` 文件树与工作树 grep 均无 Keyboard Extension 或 writer append/lease 热路径。**

- `DiagnosticsJournalReader.defaultMaximumEventCount = 10_000`
- `DiagnosticsJournalReader.defaultMaximumReadBytes = 5 * 1_024 * 1_024`
- `beginPage` / `nextPage` / `recentPreview` 仍 `min(..., defaultMaximum*)`
- `DiagnosticsStore.exportMaximumRecordCount` / `exportMaximumByteCount` 仍 10_000 / 5 MiB

`Keyboard/` 对 `liveRefreshIdentity` / `DiagnosticsJournalLiveRefreshIdentity` / 「正在加载诊断日志」**零匹配**。Reader 侧 `utcHourFormatter` / `eventDecoder` 复用与 `resolve` 先枚举再查，是解码路径分配形状，不是预算抬高。AUTH exclusions 仍含 `writer_or_extension_hot_path`、`raise_read_budget`。

不得把旧约 1 GB、或 Human 所称 <100 MB 写成正式内存合同。

### 5. 加载面 / 三种空态是否被本 SHA 回退？

**未回退。`DiagnosticsLogContentView.swift` 不在 `5b4a0ea` diff。Quality 采信 `ec5e8e9` Quality + 当前工作树代码。**

工作树第一分支仍是 `displayedLines.isEmpty && isRefreshing` → 「正在加载诊断日志」。`DiagnosticsEmptyStateView` 只在 `!isRefreshing` 时挂载；标题仍分：筛选无匹配 / 当前窗口暂无可展示记录 / 暂无诊断日志。`testRootLoadMarksRefreshingBeforeSourceReturns` 与 `testPartialWindowCanBeEmptyWithoutLookingLikeNoLogsExist` 仍在。View 字符串断言仍缺（先前 Q-P2-01 / A-P2-02）；不因此 Fail。

### 6. 是否把 AUTH / 先前 Verdict / 本 Re-review / KOS / Activity Monitor 写成 merge / Release / required / PR #83 / 新内存合同 / 高保真 Gate / 万象？

**本审查不把它们写成上述任何一项。**

- `AUTH-DIAGNOSTICS-VIEWER-LOAD-001-IMPLEMENT`：`action: implement`；`consumption_state: unconsumed`；exclusions 含 `required_mode`, `merge`, `release`, `scheme_download_fix`, `pr_83_merge`。正文：「不授权 merge、`required`、方案下载或 PR #83」。
- Assignment 仍 `active`；handoff 仍是 Human 真机复验，然后 INTEGRITY-001 万象。
- `GATE-DIAGNOSTICS-VIEWER-LOAD-IMPLEMENTATION` 仍 `open`。Quality **不**关 Gate。
- `.kos/project.json` `record_envelopes.mode` 仍为 `advisory`。KOS 2.2 仍 advisory。
- Human 入口约 1 GB、以及交接所称今日/昨日 journal 查看 <100 MB（高保真关），都是设备观察，**不是**新预算，**不是**高保真 Gate。

`unconsumed` 在 `5b4a0ea` 落地后仍为 TD-014 审计滞后，不是 replay 成 merge。见 Q-P2-01。

---

## Evidence table

Quality **未**重跑下列命令（交接：Executor-recorded 已采集，除非必须否则不重跑）。下表区分「Executor 已记录」与「本审查亲自执行」。Quality **不**把未跑项写成亲自通过。

| Check | Who | Result Quality will claim |
|---|---|---|
| Freeze SHA `5b4a0ea` on `fix/diagnostics-viewer-load-001` | Quality（`.git/HEAD` / ref / reflog / `COMMIT_EDITMSG`） | 已核对 |
| GitHub 公开 commit 文件树 | Quality | 生产 Swift 六文件 + 文档；无 `Keyboard/`、无 `DiagnosticsLogContentView`、无 Writer 热路径 |
| Conditions 1–6 代码审查 | Quality | 已核对 |
| `Keyboard/` 无 live-identity / 加载面符号 | Quality（grep） | 零匹配 |
| 预算常量 5 MiB / 10,000 | Quality | 未改 |
| `swift test --package-path Packages/KeyboardCore --filter DiagnosticsJournalTests` | Executor-recorded | 25 passed，含 fence 测试。Quality 未重跑 |
| `swift test --package-path Packages/KeyboardCore` | Executor-recorded | passed。Quality 未重跑 |
| 隔离 6 `DiagnosticsStoreTests` | Executor-recorded | `TEST SUCCEEDED`；destination `iPhone 17 Pro` UDID `8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2`。证据未逐一点名六例；本 SHA 新增 `testLoadLogSkipsWhenCachedIdentityIsUnchanged` 与 `testLiveRefreshSkipsWhenIdentityPeekFailsAfterASuccessfulBind`。Quality 未重跑 |
| 全量 `DiagnosticsStoreTests` / RimeBridgeTests / App+Keyboard CI 套件 | 未作为本 SHA 绿证据 | **不得**写成 suite green |
| View 字符串断言 / SwiftUI snapshot | 无 | 未跑；Q-P2-03 `accept` |
| Human 今日/昨日 journal 查看 <100 MB（高保真关） | Human-reported in-session `2026-08-27` | 意图路径设备观察。**不是**合同、**不是** Product Gate |
| Human Product Gate / 修复后截图合同 | 未关 | Assignment 仍要求 |
| KOS validator | 本 SHA 未要求 Quality 重跑 | advisory only；**不是** Gate |

---

## Findings

| ID | Sev | Disposition | Description |
|---|---|---|---|
| Q-P2-01 | P2 | `tech_debt:TD-014` | IMPLEMENT AUTH 在 `5b4a0ea` 落地后仍 `unconsumed`。exclusions 已挡 merge / `required` / PR #83。本审查不改收据、不切 `required`。 |
| Q-P2-02 | P2 | `accept` | 无 Store 测试直接断言 retryable notice 使下一 tick 仍 `loadLogText`。源码 `isRetryableReadFailureNotice` 与 paging 文案对齐。Architecture A-P2-05 允许代码审查；不升 P1。 |
| Q-P2-03 | P2 | `accept` | 与先前 A-P2-02 / Q-P2-01 同一观察：无 View 级字符串断言。本 SHA 未改 `DiagnosticsLogContentView`。Condition 5 按允许路径接受。 |
| Q-P3-01 | P3 | `accept` | 无单独测试钉住「未 bind 时 nil peek 不 skip」。代码：`last == nil` 时 nil 分支不 return。根加载空列表也会解码。 |
| Q-P3-02 | P3 | `accept` | 无锁 peek 与 exclusive `beginPage` 仍两次观察。最坏多一次跟进或一次 retryable，不是 skip-miss。 |
| Q-P3-03 | P3 | `accept` | retryable 成功路径仍可能先把 `lines` 写成空；live tick 靠 `isRefreshing` 加载面。允许短暂闪烁（A-P2-06）。 |
| Q-P3-04 | P3 | `accept` | Quality 未独立重跑测试/build。Executor 隔离 6 例未在 evidence 正文逐一列名。不把 briefing 升格为亲自验证。 |

先前 Quality `ec5e8e9` 的 Q-P3-01（nil 不 skip 可能反复加载）与 Q-P3-02（skip 仍每秒 exclusive）被本 SHA **supersede**：probe 不再抢 exclusive；成功 bind 后 nil skip。

### Architecture residuals — Quality disposition

| Arch ID | Quality 判定 |
|---|---|
| A-P1-01 peek-bind | **闭合（代码 + `testLiveRefreshReloadsWhenIdentityAdvancesDuringLoad`）**。不得写成真机/merge。 |
| A-P2-03 AUTH unconsumed | 不阻塞。Q-P2-01 `tech_debt:TD-014`。 |
| A-P2-04 ADR 字面 vs 拆分 | 不阻塞 Quality。ADR 正文修订属日后 Architecture 文档，本审查不改 ADR。 |
| A-P2-05 retryable 无直接测 | 不阻塞。Q-P2-02 `accept`。 |
| A-P2-06 失败页清空 lines | 不阻塞。Q-P3-03 `accept`。 |
| Human 真机复测 | **仍 open**。<100 MB 观察不是 Gate。 |

---

## Residuals (M-03)

| Residual ID | Owner | Disposition | Pointer |
|---|---|---|---|
| Human Product Gate（reader-load 修复后同一诊断页） | Human Product Owner | **required by Assignment handoff** | CPU/内存/二次进入；高保真 **不是**本 Gate；之后按 INTEGRITY-001 复测万象 |
| 高保真探针 / 万象分类 | 非本 Gate | out of scope | Assignment non-goals |
| View 字符串断言 | 可选后续 | `accept` | Q-P2-03 |
| retryable 不 bind 无直接测 | 可选后续 | `accept` | Q-P2-02 |
| IMPLEMENT AUTH `unconsumed` | Architecture & Knowledge Steward | `tech_debt:TD-014` | [`TECH_DEBT.md` TD-014](../TECH_DEBT.md) |
| Gate 仍 open | Human Product Owner | 保持 open | 不由本 Quality 关闭 |
| Human 工作集数字（旧约 1 GB；新称 <100 MB） | 非合同 | 不得写成内存预算 | 交接 in-session `2026-08-27` |

**Close 含义：** 独立 Quality 已记录本 SHA。本 Assignment **仍不得** Close：还缺 Human Product Gate。本文件 **不是** merge / PR #83 / PR #85 / `required` / Human Product Gate / Release / 高保真 / 万象授权。

---

## Non-claims

- 不是 Human Product Gate，也不是修复后加载空态截图合同。
- 不是把约 1 GB 旧工作集或 <100 MB 新观察升级为正式内存合同。
- 不是本审查亲自执行的 `swift test`、xcodebuild、swift-format 或 KOS validator。
- 不是全量 `DiagnosticsStoreTests` / RimeBridgeTests / App+Keyboard CI 绿。
- 不是 ADR 0027 / 0028 Acceptance，也不是授权改 ADR 正文。
- 不是高保真探针 Gate。
- 不是 PR #83、方案下载、INTEGRITY-001 万象分类、TestFlight、Release 或 `required`。
- 不是 PR #85 merge 授权。
- 不是 Assignment Close，也不是 `GATE-DIAGNOSTICS-VIEWER-LOAD-IMPLEMENTATION` 关闭。
- 不是授权把 KOS 2.2 从 advisory 升级为 required。
