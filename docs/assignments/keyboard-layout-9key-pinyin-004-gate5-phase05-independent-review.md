# KEYBOARD-LAYOUT-9KEY-PINYIN-004 Gate 5 Phase 0.5 — Independent Architecture + Quality Review

**Date:** 2026-07-23 Asia/Shanghai  
**Review roles (KOS 2.0 permanent ownership):**  
- 🏛️ Architecture & Knowledge Steward  
- 🧪 Quality, Performance & Release Maintainer  

**Reviewed work:** Phase 0.5 engine-native candidate coverage Spike（Executor: Grok 4.5）  
**Evidence source:** [`keyboard-layout-9key-pinyin-004-gate5-remediation-evidence.md`](keyboard-layout-9key-pinyin-004-gate5-remediation-evidence.md) §13  
**Handoff source:** [`keyboard-layout-9key-pinyin-004-gate5-phase05-grok-handoff.md`](keyboard-layout-9key-pinyin-004-gate5-phase05-grok-handoff.md)  
**Authority:** Assignment Phase 0.5 Authorization；PD-004 / ADR 0023 **未**被本 Spike 修改  

### Independence statement

本复审由 Product Lead 在 KOS 2.0 下授权**角色切换**完成：Reviewer 与 Phase 0.5 Executor 为不同任务角色，但可能共享同一 agent 进程。为降低自审风险，本复审强制：

1. 不采信聊天叙述，只采信仓库 diff、日志与再跑结果；  
2. 独立重算 allowlist 文件 SHA-256；  
3. 独立重跑 Phase 0.5 定向测试；  
4. 扫描 production 是否把 `selectionStart/End` 接入 Partial/Path reducer；  
5. 对抗性检查 Spike 测试是否存在循环断言 / 过弱 fixture。  

聊天内容不是架构或质量证据。

---

## 1. Scope of this review

| In scope | Out of scope |
|---|---|
| Phase 0.5 Spike 结论：`sel_start/sel_end` 是否可作为 per-candidate T9 槽位消费权威 | Phase 1 `T9CompositionIdentity` 实现 |
| 只读透传接口是否可保留 | Human Product Gate 重测或通过判定 |
| allowlist / 边界 / stop conditions 是否被遵守 | commit / push / PR |
| 定向测试与 evidence 完整性 | 完整 004 / Gate5 Phase 0 矩阵重开 |

---

## 2. Architecture Review

### 2.1 Source of Truth checked

- PD-004 / ADR 0023：catalog = Path 合法性；RIME = 候选与排序；禁止第二排序引擎与热路径 probe。  
- Gate 5 plan Phase 0.5：禁止用汉字数、comment、preedit、排名猜消费范围。  
- 三审 blocking finding：unchanged-raw B 缺 production-visible engine-native consumed range。

### 2.2 Coupling & boundary audit

| Check | Result |
|---|---|
| `T9CompositionIdentity.swift` | **ABSENT**（Phase 1 未开始） |
| `selectionStart/End` 出现在 PartialCommit / T9PinyinPath | **None** |
| 透传范围 | ObjC keys + parser + `RimeComposition` 可选字段 only |
| PD-004 / ADR 0023 / catalog / UIKit / 26-key | **未改** |
| allowlist 外生产代码 | **未发现** |
| `RimeEngineContractTests.swift` | allowlist 未点名；**可接受**为纯 parser 契约（零 librime、无生产语义变更） |

### 2.3 Empirical architecture finding (re-validated)

独立复跑日志（`phase05-independent-review-rerun.log`）再现：

```text
verdict=UNRELIABLE_MENU_SCOPED_ONLY
preSel=0..26
rawUnchangedSingle=true
outcomesDiffer=true
singlePostSel=3..24
multiCommitLen=7
```

架构解释（接受 Executor 结论，并补充约束）：

1. **`sel_*` 语义是 composition menu 的 active conversion segment，不是候选级消费宽度。**  
   同一 `replaceInput(anchoredRaw)` 快照下，单字与多字候选共享 pre-select `0..26`。  
2. **选择后 outcome 可以不同**（B：raw 不缩短 + 剩余候选；A 类整句：`commitLen=7` + composition 清空），但这证明引擎状态变化，**不**证明 pre-select `sel_*` 能命名“本次候选消费了哪些 sourceDigits 槽”。  
3. **B 后 `sel=3..24` 不是已消费前缀。** 更像 preedit 上剩余转换区（3 与单汉字 UTF-8 字节宽相容），单位在 **preedit 显示串**，不能唯一映射 T9 `sourceDigits` 的 `qing → 0..<4`。  
4. **Bridge 真机 + Spike 双重 raw unchanged** 继续成立：B 不能用 post-selection `remainingRaw` 当未消费后缀。  
5. **pre-selection segment→slot ledger  alone 仍不足。** 它只给出合法切点集合，不能证明本次候选消费到哪一切点。在禁止 comment/汉字数/排名的约束下，**仍缺权威消费信号**。

### 2.4 Architecture answers (handoff §13.9)

| # | Question | Architecture decision |
|---|---|---|
| 1 | `sel_*` 是否仅为 menu-scoped，不能作 per-candidate T9 槽位权威？ | **Yes — Agree.** Verdict `UNRELIABLE_MENU_SCOPED_ONLY` **Accepted**. |
| 2 | 只读透传是否可保留为观测契约？ | **Yes — Accept with constraints.** 见 §2.5。 |
| 3 | Phase 1 是否仍缺 engine-native 或其它权威路径？ | **Yes — still missing.** Ledger-only **不**被本复审批准为 B unchanged-raw 的充分条件。 |
| 4 | 替代覆盖信号调研？ | **Recommend Product Lead 新授权**（新 allowlist / 新 Spike），本复审**不**自行开新调研实现。 |
| 5 | 能否进入 Phase 1？ | **No.** |

### 2.5 Read-only interface contract (Architecture Accept)

允许保留当前 production-visible **只读**字段：

- ObjC：`selStart` / `selEnd`  
- Swift：`RimeComposition.selectionStart` / `selectionEnd`（`Int?`，缺省 `nil`）

**硬约束：**

1. **不得**作为 T9 `sourceDigits` 候选消费权威；  
2. **不得**接入 Partial Commit / Path identity reducer，直至未来 Architecture 另行 Accept 且有新证据；  
3. 消费者对缺失 / 越界 / 与 source 签名冲突必须 **fail-closed**，禁止 clamp 或猜测；  
4. 文档与代码注释须继续标明 “menu segment ≠ coverage”；  
5. 本接受**不**修改 PD-004 / ADR 0023 正文；若未来要把 coverage 升为契约，需独立 ADR 或 Gate5 补丁 ADR。

### 2.6 Phase 1 gate (Architecture)

| Decision | Value |
|---|---|
| Enter Phase 1 `T9CompositionIdentity`? | **No** |
| Reason | per-candidate engine-native coverage 仍为 `UNKNOWN`；`sel_*` 否定证据已钉死；ledger 不能单独证明 B 消费 `qing` |
| Required before Phase 1 Yes | 满足下列之一并经 Architecture 再审：**(A)** 找到可靠 engine-native per-candidate coverage；**(B)** Product Lead 书面接受 **fail-closed** 产品语义：unchanged-raw 且无法确定消费切点时不重基准 Path（可清空或保持一致失败态），且 shortened-remainder 分支仍严格后缀对齐；**(C)** 新的、不依赖禁止信号的权威模型经 Spike 证明 |

选项 B 是产品取舍，不是实现捷径；**未**在本复审中代 Product Lead 接受。

### 2.7 Architecture disposition

**Architecture: Reject Phase 1 / Accept Phase 0.5 negative finding / Accept read-only sel passthrough with constraints.**

---

## 3. Quality Review

### 3.1 Evidence matrix

| Item | Result | Notes |
|---|---|---|
| Parser 透传契约 | **PASS**（独立复跑） | `testOutputParserPassesThroughEngineNativeSelectionRange` |
| nil 兼容 | **PASS** | missing keys → nil |
| 越界不 clamp | **PASS** | fail-closed parser contract |
| Real Bridge Spike | **PASS**（独立复跑 0.470s） | pinned t9 fixture + Simulator |
| Hash inventory | **PASS** | 与 evidence §13.8 逐文件一致 |
| Reducer 未接入 | **PASS** | Partial/T9Path 无 `selectionStart/End` |
| Core smoke（实现期） | PASS（历史） | 本复审未强制全量 Gate5 Core 矩阵 |
| Fake coverage 实现 | **正确地未做** | range 不可靠时禁止猜修 |
| commit/push/PR | **未发生** | worktree dirty 可接受 |
| Human Gate claim | **未发生** | |

**独立复跑命令：**

```bash
# evidence/…/logs/phase05-independent-review-rerun.log
xcodebuild test -scheme RimeBridgeTests \
  -destination "platform=iOS Simulator,id=06C5BC3E-7599-4761-A1A2-71DAEA991474" \
  -only-testing:…Phase05…  # 四例全部 PASS；TEST SUCCEEDED
```

### 3.2 Quality findings（non-blocking unless noted）

| ID | Severity | Finding | Disposition |
|---|---|---|---|
| Q1 | **Medium** | Spike 中 `canDistinguishCandidatesBySelAlone = false` **硬编码**，verdict 断言存在循环成分；真正的实证依赖观测表（同 preSel、outcomesDiffer、rawUnchanged）。 | **Pass-with-findings.** 不推翻 `UNRELIABLE` 结论，但要求后续若再测 sel 语义，改为**由观测推导**（例如 highlight 导航后 sel 是否随候选变化；或断言 “single/multi 共享 preSel”）。 |
| Q2 | **Low** | A 冷 fixture **未**命中精确「请喂饭到」；实际 multi 为 `textLen=7` 整句提交。对 “部分多音节候选” 覆盖弱于设备 A。 | 不阻塞 Phase 0.5 否定结论（B 已足够否定 sel 作 coverage）；Phase 1 前若再开 A 类 Spike，需学习态或 seed 保证目标候选。 |
| Q3 | **Low** | `RimeEngineContractTests` 不在原 handoff 主 allowlist。 | **Accept** 为合理相邻纯 parser 测试；建议 Assignment 补记。 |
| Q4 | **Info** | 完整 Gate5 Core Phase 0 红测矩阵本轮未由 Quality 全量复跑。 | 可接受：Phase 0.5 范围是 Bridge coverage；Core 身份算法未改。 |
| Q5 | **Info** | 日志含 `singleCommitLen=na` 与 observation `commitLen=0` 的 optional 表示差异。 | 不改变 raw unchanged 事实。 |

### 3.3 Quality answers

| Question | Answer |
|---|---|
| Phase 0.5 自动化证据是否足以支持 “sel 不可靠”？ | **Yes**（观测 + 独立复跑），附 Q1 测试硬度 finding |
| 是否存在把失败测成通过的造假？ | **No** 造假未发现；存在硬编码 verdict 风险（Q1），但不伪造 Bridge 观测行 |
| 是否批准进入 Phase 1？ | **No**（与 Architecture 一致；coverage 仍 UNKNOWN） |
| 只读透传是否引入回归风险？ | **Low** — 可选字段默认 nil；未见 reducer 消费 |

### 3.4 Quality disposition

**Quality: Pass-with-findings on Phase 0.5 Spike evidence; Phase 1 = No.**

---

## 4. Combined Gate decision

| Gate | Status |
|---|---|
| Phase 0.5 Spike execution completeness | **Accept / Done** |
| Phase 0.5 technical verdict (`sel_*` unreliable for T9 slot coverage) | **Accept** |
| Read-only `selStart/selEnd` passthrough | **Accept with constraints**（§2.5） |
| Phase 1 `T9CompositionIdentity` | **Blocked — No** |
| Human Product Gate | **Still Failed / not re-entered** |
| commit / push / PR | **Not authorized by this review** |

**Stakeholder line:**

> Phase 0.5 independent review: Architecture **No Phase 1** + Accept negative sel verdict; Quality **Pass-with-findings**; coverage input remains **UNKNOWN**; Product Lead must authorize next step (alternative coverage spike **or** explicit fail-closed product semantics).

---

## 5. Owner decisions required

| Owner | Decision needed | Status after Product Lead `2026-07-23` |
|---|---|---|
| **Product Lead** | 是否授权下一 Spike / 调研替代 engine-native 信号；或是否书面接受 unchanged-raw 下 fail-closed 的产品语义（§2.6 选项 B） | **Done** — α = Phase 0.6 主路径；β = 强制安全底线（非单独关 Gate）；γ 拒；见 `PD-…-004-GATE5-PATH` |
| **Architecture** | 在新证据到达前维持 Phase 1 No；监督 `sel_*` 不被误用为 coverage | **Still in force** |
| **RIME Platform / Input Intelligence** | 在新 allowlist 下实现下一调研（若 Product Lead 授权） | **Authorized** as Phase 0.6 Executor work |
| **Quality** | 下一 Spike 要求非硬编码 verdict、A 精确候选可复现 fixture | **In force** for Phase 0.6 |
| **Human Product Owner** | 在 Phase 1 修复并自动化通过前，不重开完整 Human Gate | **In force** |

---

## 6. Recommended next actions（非授权实现）

1. Product Lead 在 Assignment 记录 Phase 0.5 复审结论与 Phase 1 继续 blocked。  
2. 可选产品路径（择一，需显式授权）：  
   - **Path α：** 新 Spike 寻找其它 librime 原生字段 / select 前后差分（仍禁止 comment/汉字数猜测）；  
   - **Path β：** 接受 B unchanged-raw 在无 coverage 时 fail-closed（Path 不错误重基准；用户可感知需再选），并只实现 shortened-remainder 严格后缀分支；  
   - **Path γ：** 暂停 Gate5 修复优先级（产品决定）。  
3. 在 Path α/β 获授权前，**禁止**任何 `T9CompositionIdentity` 生产接入。  
4. 修复 Q1（非阻塞）：Spike 测试改为观测驱动 verdict，避免硬编码布尔。

---

## 7. Explicit non-claims

- 本复审 **不**宣布 Human Product Gate 通过。  
- 本复审 **不**授权 commit / push / PR。  
- 本复审 **不**授权 Phase 1 实现。  
- 本复审 **不**修改 PD-004 / ADR 0023。  
- 历史 Gate 5 Fail（B/C 真机）**保留**。
