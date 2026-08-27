# DIAGNOSTICS-VIEWER-LOAD-001 — Independent Architecture Re-review (reader-load follow-up)

## Review identity

| Field | Value |
|---|---|
| Reviewer | `architecture_review` / 独立 Architecture Reviewer（本 reader-load 复审会话） |
| Date / timezone | `2026-08-27 Asia/Shanghai` |
| Frozen commit | `5b4a0eacfe262917ec26bfbcf39198df89003666` (`fix/diagnostics-viewer-load-001`) |
| Subject | `fix: stop diagnostics live skip from taking exclusive snapshot fence` |
| Prior Architecture | [`architecture-review.md`](DIAGNOSTICS-VIEWER-LOAD-001-architecture-review.md) of `878b02a` — **Pass with conditions**（P1 A-P1-01）；[`architecture-rereview.md`](DIAGNOSTICS-VIEWER-LOAD-001-architecture-rereview.md) of `ec5e8e9` — **Pass**（P0=0 · P1=0） |
| Prior Quality | [`quality-review.md`](DIAGNOSTICS-VIEWER-LOAD-001-quality-review.md) of `ec5e8e9` — **Pass with conditions** |
| Objects | [`DIAGNOSTICS-VIEWER-LOAD-001`](../assignments/diagnostics-viewer-load-001.md) · [`AUTH-DIAGNOSTICS-VIEWER-LOAD-001-IMPLEMENT`](../authorizations/AUTH-DIAGNOSTICS-VIEWER-LOAD-001-IMPLEMENT.md) · [ADR 0027](../architecture/decisions/0027-enterprise-local-diagnostic-observability.md)（snapshot fence：exclusive 用于 reader 捕获 membership + watermark）· [`DEBUGGING.md`](../DEBUGGING.md) 诊断页合同 · `DiagnosticsJournal.swift`（`liveRefreshIdentity` / `availableDateCatalog` / `pageSnapshot` `resolve` / `beginPage` 仍 exclusive）· `DiagnosticsStore.swift`（shared store、`loadLog` skip、nil-identity skip、retryable notice 不绑定 identity）· `DiagnosticsView.swift` · `DiagnosticsLogSource.swift` · `DiagnosticsJournalTests.testLiveRefreshIdentityAndDateCatalogDoNotTakeExclusiveFence` · Store skip 测试 · [`diagnostics-viewer-load-implementation-2026-08-27.md`](../evidence/diagnostics-viewer-load-implementation-2026-08-27.md) Human device follow-up |
| Independence | 本复审不是 `5b4a0ea` 的作者（reflog Author 为 `Cowork 3P`）。不把 `878b02a` / `ec5e8e9` 的 Verdict 当成对本 SHA 的覆盖。审查只读生产 Swift；未改生产代码，未 commit / push / PR，未开启 `required`，未 merge PR #83 / #85，未关 Assignment / Human Product Gate。唯一写入为本复审文件。 |
| Scope | 复核「1 秒 skip / 日期目录不再抢 exclusive fence」是否违反 ADR 0027，以及 peek-bind、skip-miss / lockBusy 风暴、shared Store 再进入、预算与 writer/Extension 隔离、高保真非本 Gate、IMPLEMENT AUTH 非 merge token。不是 Quality、不是 Product Gate、不是 merge。KOS 2.2 仍为 advisory。 |

**HEAD 核对：** `.git/HEAD` = `ref: refs/heads/fix/diagnostics-viewer-load-001`；`refs/heads/fix/diagnostics-viewer-load-001` = `5b4a0eacfe262917ec26bfbcf39198df89003666`（等价 `git rev-parse HEAD`；本审查未拉起 git 二进制）。`COMMIT_EDITMSG` subject 与冻结 commit 一致。`.git/logs/HEAD` / 分支 reflog：`ec5e8e9`（peek-bind）→ `54d33fa` / `832ef50`（记录 `ec5e8e9` 审查与 PR #85）→ **`5b4a0ea`（本冻结点）**。

**`git show` 范围：** 经 GitHub 公开 commit diff 与工作树对照（未解本地 zlib object）：

| Path | Role |
|---|---|
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournal.swift` | skip/catalog 去掉 exclusive；`beginPage`/`stableSegmentManifest` 仍 exclusive；`resolve` 改为一次 `segmentManifest` 后再线性查找；复用 `utcHourFormatter` / `eventDecoder` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalTests.swift` | `testLiveRefreshIdentityAndDateCatalogDoNotTakeExclusiveFence` |
| `Universe Keyboard/Views/Diagnostics/DiagnosticsStore.swift` | `shared`、再进入 skip、nil-after-bind skip、retryable notice 不写 `last` |
| `Universe Keyboard/Views/Diagnostics/DiagnosticsView.swift` | `@State store = DiagnosticsStore.shared` |
| `Universe Keyboard/Views/Diagnostics/DiagnosticsLogSource.swift` | `retainedReader`；空页不再丢弃 reader |
| `UniverseKeyboardTests/DiagnosticsStoreTests.swift` | 再进入 skip + nil-after-bind skip |
| `docs/*` · `CHANGELOG.md` | 合同、Assignment 相位、证据、非主张 |

**未**出现在本 diff：`Keyboard/` Extension、`DiagnosticsJournalWriter` append/flush/lease、generation/retention 协议、RIME、方案下载、PR #83 范围。预算常量未改。

先前对 `878b02a` / `ec5e8e9` 的 Architecture / Quality **不覆盖** `5b4a0ea`。

---

## Verdict

**Pass with conditions**

1 秒 skip 与日期目录改为无锁目录水位，是对 ADR 0027 的**有效职责拆分**，不是放弃「解码前冻结 membership + watermark」：`beginPage` / `stableSegmentManifest` 仍走 nonblocking exclusive snapshot fence；probe 允许与 writer shared fence 竞态，最坏是约 1 秒延迟或一次失败页重试，而不是 skip 自己抢 exclusive 失败后逼出整页 JSONL 重扫。A-P1-01 peek-bind 仍成立；retryable 失败页不绑定 identity 是对该合同的收紧。成功 bind 后 nil identity 改为 skip，在 identity 已不再取 exclusive 的前提下可接受。Shared Store 再进入在水位未变时跳过根解码；clear / generation 变化有身份令牌或空列表路径兜底。5 MiB / 10,000 未抬高；writer / Extension 热路径不在 diff 内。高保真不在本 Assignment Gate。IMPLEMENT AUTH 不是 merge / `required` / PR #83 令牌。

无未处置 **P0**。无新的开放 **P1**。A-P1-01 保持 `closed`。本 Verdict **允许独立 Quality 开始**，**不**关闭 Assignment，**不**授权 merge，**不等于** Quality Pass 或 Human Product Gate。Human Activity Monitor 数字（旧约 1 GB、新截图若有）**不是**新的正式内存合同。

Finding counts: **P0: 0 · P1: 0 · P2: 4 · P3: 4**

条件（不把 Verdict 升为 Fail / 不阻塞 Quality 开工）：Quality 必须按下列 Conditions 复核 fence 拆分测试、peek-bind、nil-after-bind、retryable 不绑定、再进入 skip；不得把 Executor 的真机前数字或本文件写成内存合同 / merge 授权。ADR 正文尚未改写为「probe 无锁 / decode exclusive」——记为文档残留，不构成本 SHA 的协议破坏。

---

## Answers

### 1. 去掉 `liveRefreshIdentity` / `availableDateCatalog` 的 exclusive fence，是违反 ADR 0027，还是有效拆分？

**有效拆分（racy skip / 日索引 vs exclusive `beginPage` 事件解码）。不构成对本 Assignment 冻结不变量的违反。**

ADR 0027 表项：`snapshot.lock` 上，Main App reader **在捕获成员集合与 segment watermark 时**取 nonblocking exclusive；exclusive busy 时返回受控「刷新」状态。writer/clear/reclaim 取 shared。决策 4：诊断页可见时实时约为 **一秒内可见**，不是逐键耐久。查询/复制使用 immutable query snapshot。

`ec5e8e9` 把 skip 也放进 `stableSegmentManifest`（exclusive + 双观察）。Human 复测：约 69 条可见、高保真关，仍近 1 GB 工作集与满核 CPU；二次进入再次长加载。机制：1 秒 tick 的 identity/catalog 与 writer shared fence 互斥 → exclusive `lockBusy` → 旧 A-P2-01「nil 不 skip」→ 整页 catalog + JSONL 解码。这是把 **probe** 误做成 **冻结查询快照**。

`5b4a0ea` 拆分：

| 操作 | Fence | 语义 |
|---|---|---|
| `liveRefreshIdentity()` | **无** exclusive。读 `control.json` + 枚举 jsonl + `attributes[.size]` | 「有没有 JSONL 变大？」racy probe |
| `availableDateCatalog()` | **无** exclusive。只解析文件名里的 UTC 小时 | 日索引，不是事件水位 |
| `beginPage` → `pageSnapshot` → `stableSegmentManifest` | **仍** `withExclusiveSnapshotFence` + identity locks | 解码前冻结 membership + per-segment watermark |
| `recentPreview` | 仍经 `stableSegmentManifest` | 超预算有界窗同样冻结 |

`testLiveRefreshIdentityAndDateCatalogDoNotTakeExclusiveFence`：持 **shared** fence 时 identity 与 catalog **成功**；`beginPage` 仍 `.lockBusy`。这正是拆分的可证伪点。

允许的竞态（不升 P0）：

- probe 可能晚一拍看到 append / 新段（约 1 秒，符合 ADR「约一秒内可见」）。
- 日索引可能短暂缺一个正在创建的小时文件；下一次 identity 变化（`segmentCount` 或字节）会 `refreshDays: true`。
- probe 看到增长后 `beginPage` 仍可能 `lockBusy` → 受控失败页，**不**把该 peek 写成已展示（见答 2–3）。

ADR **字面**仍写「捕获 membership + watermark 时 exclusive」。实现把「捕获」收窄为 **decode/copy 快照**，probe 不再算捕获。这是兼容细化，不是偷偷删围栏。本 Assignment 未授权改 ADR 正文；见 A-P2-04。不得把无锁 probe 推广到 `beginPage`。

### 2. A-P1-01 peek-bind 是否仍成立？（`last` = 触发解码的 peek；加载中 append 下一 tick 仍会再加载）

**成立。`last` 仍只提交触发本次解码的 peek；加载期间 identity 前进后下一 tick 不得 skip。retryable 失败页比 `ec5e8e9` 更严：不写 `last`。**

形状未变：

```text
performLiveRefreshTick:
  I = liveRefreshIdentity()          // 现为无锁目录水位
  若 I != nil 且 I == last → skip（不 loadLogText）
  若 I == nil 且 last != nil → skip（见答 3）
  否则 replaceWithLatestPage(..., peekedLiveRefreshIdentity: I)

成功 apply 且 notice 非 retryable:
  last = peekedLiveRefreshIdentity   // 禁止加载后再采样盘面
```

`testLiveRefreshReloadsWhenIdentityAdvancesDuringLoad` 仍在：peek/load 用 `g1:1:20`，`loadLogText` 返回时身份变成 `g1:1:30`；第一次 tick 展示 `second event` 且不得把 `last` 变成 `30`；第二次 tick 再加载得到 `third event`。

本 SHA 相对 `ec5e8e9` 的收紧：`isRetryableReadFailureNotice` 匹配「日志正在轮转或回收…」与「诊断日志暂时不可用…」（即 catalog `.unavailable` 早退之外，`beginPage` `lockBusy` / `.snapshotUnavailable` / `.journalUnavailable` 路径）。这些页 **没有展示该 peek**，不写 `last`，下一 tick 若水位仍不同于已展示身份则必须再试。这关闭了「失败页绑定 peek → 下一秒 skip、列表已被写成空」的窗口。

Peek（无锁）与 `beginPage`（exclusive）仍是两次观察。append 落在两观察之间时：解码可能新于 peek → `last` 仍为 peek → 下一 tick 多一次跟进加载（保守，不是 skip-miss）；或 exclusive busy → retryable、不绑定。同 fence 身份仍不在本 Assignment 授权范围。见 A-P3-02。

catalog `.unavailable` 早退仍 **不** 走到 bind。与上一轮一致。

### 3. skip 会不会漏新事件，或在 lockBusy 上风暴重载？成功 bind 后 nil identity 改为 skip，是否安全？

**水位增长不会被稳定 skip 掉。lockBusy 不再发生在 skip probe 上，因此不会再靠「nil → 全量解码」打出 GB 级重扫。成功 bind 后 nil skip 在当前 fence 拆分下可接受；残余是短暂 IO 竞态延迟，不是 A-P1-01 那种已落盘永久消失。**

不会漏（正常 append-only）：

- 令牌仍是 `generation : segmentCount : Σ size`。`testLiveRefreshIdentityChangesWhenBytesAreAppended` 仍证明 append 后 `totalByteWatermark` 严格增大。
- 新小时段 → `segmentCount` 变。clear / generation 推进 → `generation` 变。
- 无锁 TOCTOU 最多让本秒 skip、下一秒看到增长（ADR 约 1 秒）。

不会在 **skip** 路径上风暴：

- 旧风暴：exclusive identity `lockBusy` → nil → 不 skip → `beginPage` 再抢 exclusive 再 busy 或整页解码。每秒一次。
- 新 skip：identity 不抢 exclusive；writer 持 shared 时 probe 仍成功。水位未变 → 不调用 `loadLogText`。`testLiveRefreshSkipsRootLoadWhenIdentityIsUnchanged` 仍覆盖。

`beginPage` 仍可能 `lockBusy`（测试钉住这一点）。此时：

1. 仅当 probe 已显示水位 **不同于** `last` 才会进入加载。
2. `V1DiagnosticsLogSource` catch → `.journalUnavailable`，notice 为 retryable，**不** bind `last`。
3. exclusive 失败发生在 `stableSegmentManifest`，**尚未** JSONL 根解码。
4. 下一秒再试，直到 exclusive 成功。这是有界重试，不是「未变更 snapshot 无界重扫」。

成功 bind 后 `I == nil` skip（`testLiveRefreshSkipsWhenIdentityPeekFailsAfterASuccessfulBind`；`reloadRootIfIdentityChanged` 同样 `nil || == last` 则 return）：

- 反转了 `878b02a` 的 A-P2-01（当时 nil 不 skip 是为了不漏事件，但 exclusive probe 把 lockBusy 变成每秒全量加载）。
- identity **不再**因 snapshot shared 而 throw `lockBusy`。nil 现在主要是 App Group/control/IO（例如 list 与 `stat` 之间文件被移走）。
- 下一秒 probe 成功且令牌 ≠ `last` 会再加载。持续 nil 时 journal 本身也难读。
- 未成功 bind 过（`last == nil`）时 nil **不** skip，避免空列表永远不试。

残留：retryable 成功路径仍会先 `lines = lines(from: nil)` 清空可见行，live tick 期间 `isRefreshing` 走加载面，结束后可能短暂空列表 + notice，直到下一秒成功。不漏最终可见性，有闪烁。见 A-P2-06。Store **没有**「retryable 不 bind」的直接断言（只有源码 + 字符串表）。见 A-P2-05。

### 4. Shared `DiagnosticsStore`：再进入 skip vs clear / generation 变化后的陈旧 UI？

**水位未变的再进入 skip 符合新合同。clear 与 generation 变化有独立失效路径，不会把已清空或新 generation 当成已展示。**

- `DiagnosticsView`：`@State private var store = DiagnosticsStore.shared`。`onDisappear` 只 `stopLiveRefresh`，不销毁 Store。
- `loadLog()`：`!lines.isEmpty && last != nil` → `reloadRootIfIdentityChanged()`（identity 同或 nil 则 return，不置根加载 spinner）。`testLoadLogSkipsWhenCachedIdentityIsUnchanged`。
- `DEBUGGING.md`：离开后再进入，水位未变不得重新全量解码。

失效：

| 事件 | 为何不陈旧 |
|---|---|
| `performClear` 成功 | `lines = []`，`last = nil`，日期状态重置。再进入因空列表 **不** 走 skip，强制根加载。revision 丢弃在途页。 |
| generation 推进 | identity 含 `generation`。peek ≠ `last` → 再解码。 |
| 隐藏期间 append | `segmentCount` / 字节变 → 再进入 reload。 |
| reclaim 删段 | 字节或段数变 → 再进入 reload。 |
| 仅 seal 移动 | 令牌可能不变；事件已在上一快照中。可接受。 |

`@State` 包 class 单例：测试一律 `DiagnosticsStore(logSource:)`，**不**碰到 `shared`，避免单例污染。生产只有诊断页持有该单例。筛选/搜索字符串会随单例留下——合同未要求再进入重置筛选。

在途 `isRefreshing` 时再进入：skip 路径若 `isRefreshing` 则 `reloadRootIfIdentityChanged` 早退，等在途页或后续 live tick。空列表再进入会 `advanceQueryRevision`，丢弃旧加载。不构成 generation 级陈旧。

### 5. 5 MiB / 10,000 是否被提高？Writer / Extension 热路径是否被改？

**否；否。**

- `DiagnosticsJournalReader.defaultMaximumEventCount = 10_000`
- `DiagnosticsJournalReader.defaultMaximumReadBytes = 5 * 1_024 * 1_024`
- `beginPage` / `nextPage` / `recentPreview` 仍 `min(..., defaultMaximum*)`
- `DiagnosticsStore.exportMaximumRecordCount` / `exportMaximumByteCount` 仍 10,000 / 5 MiB
- GitHub diff **无** `Keyboard/`、**无** Writer append/lease/generation/retention
- AUTH exclusions 含 `writer_or_extension_hot_path`、`raise_read_budget`

Reader 侧 `utcHourFormatter` / `eventDecoder` 复用、`resolve` 改为先枚举一次再查，是解码路径的分配/I/O 形状，不是预算抬高。Executor 所称「`resolve` 是 O(n) 不是 O(n²)」指 **不再每个 segment 重新 `segmentManifest`（目录 I/O）**；内存里仍对每个 segment 线性扫当前 manifest（段文件数平方比较，段数有界）。不升 P0。见 A-P3-04。

不得把 Human 旧约 1 GB、或后续更小工作集截图数字写成正式内存合同。

### 6. 高保真是否在本 Assignment Gate 之外？

**是。明确不在本 Gate。**

Assignment non-goals：不改首屏高保真探针合同，不用高保真诊断方案下载。Human 复测记录为高保真 **关**、约 69 条可见。本 diff 不触及高保真开关、30 分钟窗或候选探针字段。本审查 **不是** 高保真验收，也 **不是** INTEGRITY-001 / 万象分类 Gate。

### 7. IMPLEMENT AUTH 是否仍不是 merge bearer token？

**仍不是。exclusions 仍挡住 merge / `required` / PR #83。**

- `AUTH-DIAGNOSTICS-VIEWER-LOAD-001-IMPLEMENT`：`action: implement`，`target: DIAGNOSTICS-VIEWER-LOAD-001`，`status: active`，`consumption_state: unconsumed`。
- exclusions：`required_mode`, `merge`, `release`, `scheme_download_fix`, `pr_83_merge`, `writer_or_extension_hot_path`, `raise_read_budget`。
- 正文：「不授权 merge、`required`、方案下载或 PR #83」。
- KOS 2.2 仍 advisory（[`UPGRADE_STATUS.md`](../kos/UPGRADE_STATUS.md)）。本复审不授权上述任何一项，也不把 AUTH 或本 Verdict 当成 PR #85 merge 令牌。
- `unconsumed` 在 `878b02a` / `ec5e8e9` / `5b4a0ea` 落地后仍为观察滞后（TD-014），不是 replay 成 merge。见 A-P2-03。

---

## Findings

| ID | Sev | Disposition | Description |
|---|---|---|---|
| A-P1-01 | P1 | `closed`（`ec5e8e9`，本 SHA 保持） | peek-bind 仍在；retryable 失败页不写 `last`，避免失败页被当成已展示。 |
| A-P2-03 | P2 | `tech_debt:TD-014` | IMPLEMENT AUTH 仍 `unconsumed`。exclusions 已挡 merge / `required` / PR #83。不要在本审查改收据或切 `required`。 |
| A-P2-04 | P2 | `accept` | ADR 0027 表项仍写 reader 捕获 membership+watermark 时 exclusive。实现将捕获收窄为 `beginPage` 冻结点，probe/日索引无锁。行为与「解码快照必须冻结」一致；ADR 正文未改。日后授权文档修订时补一句拆分，不得借机改 writer 锁序。 |
| A-P2-05 | P2 | `accept` | 无 Store 测试直接断言 retryable notice 使下一 tick 仍 `loadLogText`。有源码分支 + `isRetryableReadFailureNotice` 字符串。Quality 可用代码审查接受，或补测；不升 P1。 |
| A-P2-06 | P2 | `accept` | retryable `loadLogText` 仍把 `lines` 写成空；live tick 期间靠 `isRefreshing` 加载面。最终会因未 bind 再试。允许短暂空/加载闪烁，不是永久 skip-miss。 |
| A-P2-01 | P2 | `superseded` | 旧「nil 不 skip」在 exclusive probe 下造成风暴。本 SHA 在 **已 bind** 后 nil skip。未 bind 时仍不 skip。 |
| A-P3-01 | P3 | `closed` at `5b4a0ea` | skip 命中不再每秒 exclusive fence。 |
| A-P3-02 | P3 | `accept` | 无锁 peek 与 exclusive `beginPage` 仍两次观察。多一次跟进或一次 retryable，不是 skip-miss。 |
| A-P3-03 | P3 | `accept` | 无锁 size/枚举 TOCTOU 最多延迟约 1 秒。 |
| A-P3-04 | P3 | `accept` | `resolve` 的目录 I/O 从每段一次改为每页一次；比较仍 O(段数²)。段数远小于事件预算。 |
| A-P3-05 | P3 | `accept` | Assignment `updated_at` 从 `22:40` 改回 `21:30`（相位重写）。不改变 AUTH 范围。 |

既有 A-P2-02（无 View 字符串断言）仍 `accept`，本 SHA 未回退加载面分支。

---

## Residuals (M-03)

| Residual ID | Owner | Disposition | Pointer |
|---|---|---|---|
| A-P1-01 peek-bind | Quality 复验 | `closed` | `replaceWithLatestPage` bind + `testLiveRefreshReloadsWhenIdentityAdvancesDuringLoad` |
| A-P2-04 ADR 字面 vs 拆分 | Architecture（日后文档） | `accept` | ADR 0027 snapshot 表；本文件答 1 |
| A-P2-05 retryable 不 bind 无直接测 | Quality | `accept` | `isRetryableReadFailureNotice` |
| A-P2-06 失败页清空 lines | Quality 观测 | `accept` | live tick + journalUnavailable |
| A-P2-03 AUTH unconsumed | Knowledge Steward | `tech_debt:TD-014` | [`TECH_DEBT.md` TD-014](../TECH_DEBT.md) |
| Human 真机复测 reader-load 修复 | Human Product Owner | **open** | Assignment handoff；同一诊断页 CPU/内存/二次进入 |
| 高保真 / 万象 | 非本 Gate | out of scope | Assignment non-goals |

**Close 含义：** 无 P0，无开放 P1，独立 Quality **可以开始**。`accept` / `tech_debt:TD-014` 不阻塞 Quality。本 Assignment **仍不得** Close：还缺本 SHA 的独立 Quality 与 Human 对 reader-load 修复的真机复验。Quality 不得把本文件当成 merge / PR #83 / PR #85 / `required` / Human Product Gate / 万象验收。

---

## Conditions for Quality

独立 Quality 可以开始。至少核对：

1. `testLiveRefreshIdentityAndDateCatalogDoNotTakeExclusiveFence`：shared fence 下 identity/catalog 成功，`beginPage` 仍 `.lockBusy`。
2. A-P1-01：`last` 等于触发解码的 peek；加载中 append 下一 tick 再加载；retryable notice **不** bind（代码审查可接受）。
3. 成功 bind 后 nil peek skip；未 bind 时 nil 不 skip。再进入：`lines` 非空且水位未变不 `loadLogText`。
4. 预算常量未变；diff 无 Extension/writer 热路径。
5. 加载面 / 三种空态分支未被本 SHA 回退（可采信 `ec5e8e9` Quality + 代码未改 `DiagnosticsLogContentView`）。
6. 不把 IMPLEMENT AUTH、先前 `ec5e8e9` Verdict、本 Re-review、KOS 绿或 Activity Monitor 数字写成 merge / Release / `required` / PR #83 / 新内存合同 / 高保真 Gate / 万象。

---

## Non-claims

- 不是 Human 对 **reader-load 修复** 的真机复验或 Product Gate。
- 不是把约 1 GB 旧工作集或任何新截图数字升级为正式内存合同。
- 不是 Simulator 全量 CI 等价套件（审查未执行 xcodebuild / `swift test`；Executor-recorded 由 Quality 取舍）。
- 不是 ADR 0027 / 0028 Acceptance，也不是授权改 ADR 正文。
- 不是高保真探针 Gate。
- 不是 PR #83、方案下载、INTEGRITY-001 万象分类、TestFlight、Release 或 `required`。
- 不是 PR #85 merge 授权。
- 不是 Assignment Close。
- 不是授权把 KOS 2.2 从 advisory 升级为 required。
