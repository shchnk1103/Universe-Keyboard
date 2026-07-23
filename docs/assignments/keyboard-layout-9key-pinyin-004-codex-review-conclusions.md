# KEYBOARD-LAYOUT-9KEY-PINYIN-004 Codex 独立三次审查结论

**Review date:** `2026-07-22 Asia/Shanghai`  
**Review input:** [`keyboard-layout-9key-pinyin-004-codex-review-remediation.md`](keyboard-layout-9key-pinyin-004-codex-review-remediation.md) 文末「三审前增量」  
**Reviewed tree:** `101b88919d5387d3d49c61fe20b2116f5365367e` + 当前未提交的 `003 + 004` 混合工作树  
**Review authority:** Independent Architecture & Knowledge Steward + Independent Quality Reviewer  
**Product Gate:** **未执行、未代填、未宣布通过**

> 本文取代同一路径下的一审、二审结论作为当前审查状态。历史结论分别为
> `Architecture Reject / Quality Fail` 与 `Architecture Reject / Quality Pass with findings`；
> 本次三审重新检查当前工作树并独立复跑证据，不直接采信 Executor 声明。

## 1. 三审总论

| Gate | 三审结论 | 说明 |
|---|---|---|
| Architecture | **Accept with findings** | A-004-03 严格 PD 分类和 A-004-04 单 snapshot 主刷新合同已关闭；剩余项不改变核心权威或状态语义。 |
| Automated Quality | **Pass** | 指定矩阵独立复跑 `122/122 PASS`；新增 Q-004-09 三类回归通过；Simulator 整包构建成功。 |
| Human Product Gate readiness | **Not allowed yet** | RimeBridge pinned-runtime Spike 与 focused UIKit contract tests 仍未执行；先补齐 Assignment/Playbook 自动化证据，再交人类真机 Gate。 |

本次没有修改产品实现，没有运行全量测试，没有执行或代填 Human Product Gate，
也没有 commit、push 或创建 PR。

## 2. 对三审问题的直接回答

1. **A-004-03 已关闭。** 单位 focus 只把 catalog 合法单字母音节（如 `a/e/o`）标成
   `completeSyllable`；`m/n/b/c` 等为 `letterPrefix`。Core 仅允许完整音节确认/推进，
   prefix 只锁定当前 focus。
2. **A-004-04 已关闭，保留非阻断 finding。** T9 活跃 composition 的 `syncUI` 会捕获
   一次 `T9CompositionPresentationSnapshot`，并用同一 revision 更新 Path Bar、首屏候选与
   expanded Path panel；延迟候选窗口同时校验 UIKit generation、raw identity 和 Core
   composition revision。分页 metadata 仍有少量独立 Core state 读取，建议后续并入 snapshot。
3. **Q-004-09 足以关闭当前 coverage finding。** 普通 Partial、T9 Partial、typo Partial
   的 paging/checkpoint，以及 paging 后继续输入失效 checkpoint 均有自动化覆盖。
4. **122 定向矩阵构成 Automated Quality Pass。** 本次独立结果为 122/122、0 failures。
5. **Architecture 已通过，但当前仍不允许进入 Human Product Gate。** 原因不是 A-004-03/
   A-004-04，而是 Assignment 明列的 RimeBridge pinned-runtime Spike 与 focused UIKit
   contract tests 尚未完成。补齐后可交 Human Product Owner 执行 Gate；审查者不得代填或
   宣布真机 Gate 通过。

## 3. Architecture Review（交接第 9 节）

### A1 — ADR 0023 取代边界

**PASS**

- 本地 catalog 只替代 Path 合法性来源；RIME 仍是唯一中文候选引擎。
- 未发现第二候选引擎、Extension 热路径文件解析、schema/vendor 或部署扩张。

### A2 — Catalog 来源、hash、417 基线与许可证

**PASS with Release/Legal finding**

- 源文件 SHA-256：
  `971baa1f38a42d3d82f858b5bbdcad6482371f8d93a2f5d5c4ab341046419e3b`。
- 生成器 v2 过滤 `xx` 与无元音 token；baseline 为 417 syllables、221 signatures。
- 来源路径、声明版本、精确 hash、过滤策略、派生物说明和小写生成命令已记录。
- 上游官方仓库标示 LGPL-3.0：<https://github.com/rime/rime-luna-pinyin>。
- Architecture 的“无法记录”Stop Condition 已关闭；面向发行物的 LICENSE/NOTICE inventory
  仍应由 Release/Legal owner 在发布前确认。

### A3 — 热路径成本与唯一 Path 权威

**PASS with performance finding**

- `t9PinyinPathWindow()` 只切片当前 catalog `compactPaths`，不调用 `candidateWindow`、
  不通过 comment 签发 Path，且 `hasMoreCandidates=false`。
- Path 构建不逐 spelling probe RIME；catalog rank 为一次性静态 map。
- `T9PinyinPathBarView.setPaths` 仍无条件 `reloadData + layoutIfNeeded`。本次不作为
  Architecture blocker，但真机性能 Gate 应继续观察长串输入和 Path 选择延迟。

### A4 — complete syllable 与 letter prefix 语义（A-004-03）

**PASS — Closed**

- `singleDigitKeyGroupPaths` 从 catalog 判断单字母是否合法完整音节：按键 `6` 的 `m/n`
  为 `letterPrefix`，`o` 为 `completeSyllable`。
- remap 也重新按 catalog 分类，未再把“消费一个 slot”等同于完整音节。
- `canConfirmAndAdvance` 只接受 `.completeSyllable`；prefix 不确认、不推进。
- 自动化同时覆盖 `m/n/o` 类型、`28 + b` 锁定不推进、完整音节有剩余 slot 时推进。
- 非阻断可读性 finding：`canConfirmAndAdvance` 上方注释仍写着“一槽 key-group choices
  都发布为 completeSyllable”，与现实现不符，应在后续整理中修正注释。

### A5 — UIKit Path 渲染与选择载荷

**PASS with UI finding**

- UIKit 只渲染并转发 Core-issued `T9PinyinPath`，不拼接 replacement raw。
- Core 与 UIKit 均有 revision fail-closed guard。
- 34pt Path Bar 的 44pt 实际 cell 命中效果仍缺 focused UI test/真机证据；容器层
  `point(inside:)` 的扩展不自动证明 collection cell 能收到 bounds 外触点。

### A6 — 26 键隔离

**PASS**

- 单 snapshot 分支只在 active T9 composition 下启用；26 键继续走既有
  `refreshCandidateBar/resetCandidateSnapshotFromController` 路径。
- `usesT9InputSemantics=false` 不生成 catalog Path；runtime 隔离 14/14 通过。
- 原 shared candidate paging checkpoint 回归及对应 26 键风险已关闭。

### A7 — Expanded Path panel

**PASS**

- panel 只消费同一 snapshot 的 `paths/revision`，不再是第二条 Path 发现或授权链。
- `pinyinPathHasMore=false`，旧 lazy paging 不参与 Path completeness。

### A8 — 原子 snapshot、revision 与恢复链（A-004-04）

**PASS with encapsulation finding — Closed**

- `syncUI` 在 active T9 composition 的 composition/path effect 上统一调用
  `refreshT9PresentationFromCoreSnapshot()`。
- 该方法只捕获一次 Core snapshot，并在一个 MainActor 调用链中更新 Path Bar、
  snapshot candidates 和 expanded Path panel。
- `resetCandidateSnapshot(from:)` 把 candidate cache 绑定到 `snapshot.revision` 和
  `snapshot.rimeRawInput`。
- 延迟 `candidateWindow` 返回后必须同时满足 UIKit generation、raw identity、缓存 revision
  与 live Core revision；旧结果 fail closed。
- Core Path action 保持 composition revision guard，restore/remap 会 restamp live revision。
- 非阻断 finding：`resetCandidateSnapshot(from:)` 仍从 live controller 读取 preedit、
  candidate page number 和 `hasMorePages`；这些值当前在同一 MainActor 同步调用中一致，
  但为强化类型合同，后续可把分页 metadata 一并加入 snapshot，完全取消适配层重读。

### A9 — Swift 6 / MainActor / Sendable

**PASS**

- 未发现新增 `@unchecked Sendable`、`nonisolated(unsafe)` 或隔离绕过。
- Keyboard Extension 以 Swift 6、default MainActor、warnings-as-errors 成功完成 Simulator build。

### A10 — Stop Conditions

**PASS**

- `xx` 已过滤；来源/许可证/生成 provenance 可追踪。
- catalog 是唯一 Path 法律性来源，RIME 仍是唯一候选引擎。
- 无 whole-sentence cartesian product、Extension 热路径文件 I/O、26 键行为扩张或部署扩张。

## 4. Quality Review（交接第 10 节）

| # | 检查项 | 三审结论 | 独立证据 |
|---|---|---|---|
| Q1 | remediation 指定 filter | **PASS** | 122 tests，0 failures。 |
| Q2 | Catalog metadata/hash/合法音节 | **PASS** | 417 baseline；`xx` 不存在；单键 kind 符合严格 PD。 |
| Q3 | `28` / `94` / prefix / 调用预算 | **PASS** | Catalog 8/8、Controller 3/3、Path 49/49。 |
| Q4 | Host marked-text 无内部数字 | **PASS** | Host safety 6/6；T9 paging history 断言通过。 |
| Q5 | 26 键隔离 | **PASS** | Runtime 14/14；非 T9 refresh 路径保留。 |
| Q6 | Partial Commit / Q-004-09 | **PASS** | Partial 42/42；普通、typo、T9 paging 与继续输入失效均覆盖。 |
| Q7 | Keyboard Extension Simulator build | **PASS** | generic iOS Simulator，Swift 6，warnings-as-errors，`BUILD SUCCEEDED`。 |
| Q8 | Automation / Product Gate 分离 | **PASS** | 本文没有执行或宣布 Product Gate。 |

### Q-004-09 — Closed

- `testCandidatePagingDuringNormalPartialCommitDoesNotInvalidateCheckpoint`：paging 后 checkpoint
  保留，Delete 恢复完整 raw。
- `testCandidatePagingDuringT9PartialCommitKeepsPathsAndCheckpoint`：覆盖 T9 专属 Path refresh，
  paging 后 Path/checkpoint 仍在，marked-text history 无内部数字。
- `testTypingAfterCandidatePagingInvalidatesPartialCheckpoint`：不可逆新输入清 checkpoint，
  后续 Delete 不跨越该输入恢复旧 composition。
- 原 typo paging 用例继续通过，三类 Partial 路径已形成对称回归保护。

## 5. 独立验证

### 5.1 KeyboardCore 定向矩阵

```bash
cd Packages/KeyboardCore
swift test --filter 'T9PinyinCatalogTests|T9PinyinCatalogControllerTests|T9HostPreeditSafetyTests|T9PinyinPathTests|KeyboardLayoutAndT9RuntimeTests|PartialCommitControllerTests'
```

| Suite | 结果 |
|---|---:|
| `KeyboardLayoutAndT9RuntimeTests` | 14/14 PASS |
| `PartialCommitControllerTests` | 42/42 PASS |
| `T9HostPreeditSafetyTests` | 6/6 PASS |
| `T9PinyinCatalogControllerTests` | 3/3 PASS |
| `T9PinyinCatalogTests` | 8/8 PASS |
| `T9PinyinPathTests` | 49/49 PASS |
| **合计** | **122/122 PASS，0 failures** |

环境：Swift `6.4`、Xcode `27.0 (27A5228h)`、`arm64-apple-macosx27.0.0`。

### 5.2 Keyboard Extension / 主 App Simulator build

```bash
xcodebuild \
  -project 'Universe Keyboard.xcodeproj' \
  -scheme Keyboard \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /private/tmp/universe-keyboard-t9-004-third-review-2203 \
  CODE_SIGNING_ALLOWED=NO \
  build
```

结果：**BUILD SUCCEEDED**。Keyboard Extension 与主 App 均完成 arm64/x86_64 Simulator
编译和链接；存在 vendor boost XCFramework 缺少部分 x86_64 object 的既有 warning/note，
未导致构建失败，也没有 Swift warnings-as-errors 失败。

## 6. 仍未执行及 Gate 决策

- **RimeBridge pinned-runtime Spike：未跑。** `28/b8/cu/94→zi/qiu'53/qiul` 的真实
  librime 接受面仍未由三审证明。
- **Focused UIKit contract tests：未跑/未提供。** 单 snapshot 数据流已通过代码审查和
  target 编译，但 refresh 原子性、stale prefetch 丢弃、44pt 命中、scroll retention、
  VoiceOver 尚无自动化 UI contract 结果。
- **KeyboardCore 全量：未跑。** 按用户要求只运行对应的定向测试。
- **iPhone 13 Pro + Notes：未跑。** 这是 Human Product Gate，审查者无权代填。

### Human Product Gate 入口结论

**当前仍不允许进入。** Architecture 和当前 Automated Quality 已通过，但 Assignment 与
Keyboard UI Playbook 要求的 Bridge/Focused UI 证据仍有缺口。Environment Executor 应先：

1. 运行 pinned RimeBridge Spike；
2. 运行或补充 focused UIKit contract tests，至少覆盖同 snapshot revision、stale delayed
   candidate 丢弃和 Path Bar 命中/滚动；
3. 把命令、环境、结果及仍跳过项写回 evidence/remediation。

上述自动化证据完成并无阻断失败后，才可把任务交给 Human Product Owner 在 iPhone 13 Pro
备忘录执行 Product Gate。届时三审的 Architecture/Quality 结论只是入场证据，绝不等于
Human Product Gate 通过。
