# ADR 0034 — Architecture Accept Review

日期：2026-09-09 Asia/Shanghai

**性质：** 独立、只读 Architecture Accept 复审结论。
**不是：** ADR Acceptance、Product Gate、TestFlight、Release、实现授权，或把 Status 从 Proposed 改为 Accepted。

**授权：** Human Product Owner 批准启动本复审（同日清单授权之后）。

---

## 1. Scope / Ownership

| Field | Value |
|---|---|
| In scope | ADR 0034（Proposed）候选 A 是否可作为长期归属合同；与 Accepted ADR 0001/0003/0006/0032/0033 一致性；`main` @ `814abfd` 实现抽样；残余 A34-R1…R8 disposition |
| Out of scope | 改 ADR Status；Product Gate / TestFlight / Release；改生产 Swift；`RTRD-01`/`RTRD-02` 实现；Recovery persistence 新范围 |
| Reviewer | Independent Architecture lane（Grok Bot executor subagent；只读审查，未实现生产代码） |
| Baseline | `main` merge tip `814abfd7c03002256978d7658c176b80002d2539`（PR #100）；docs 分支 tip at review start `7d5a7591c47266d38c7da09a6c17c1923baf8732` |
| Checklist | [`adr-0034-architecture-accept-checklist-2026-09-09.md`](adr-0034-architecture-accept-checklist-2026-09-09.md) |
| ADR under review | [`0034-multi-scheme-resource-ownership.md`](../architecture/decisions/0034-multi-scheme-resource-ownership.md) — **Status remains Proposed** |

| Role | This review |
|---|---|
| Architecture & Knowledge Steward | 出具 Recommend Accept / Conditional / Block；**不得**自行改 ADR Status |
| Product Lead / Human | 本结论之后决定 Accept / Keep Proposed / Revise |
| Quality | 仅引用既有 IQ / evidence；本文件不替代新的 Quality Gate |

---

## 2. Applicable contracts examined

1. ADR 0034 全文 + Follow-up Work（Proposed — 未批准，2026-09-07；2026-09-09 清单注记）
2. [共存计划](../plans/scheme-resource-ownership-and-coexistence-plan.md) §5 / §5.1
3. Accepted：ADR 0001、0003、0006（Accepted; implementation pending）、0032、0033
4. Assignment Current Status / Residuals：[`SCHEME-DELIVERY-SOURCE-STATE-001`](../assignments/scheme-delivery-source-state-001.md)
5. 抽样证据 / 评审（非穷尽；基线 `814abfd` 与已合入路径）：

| Pointer | Role |
|---|---|
| `docs/evidence/scheme-delivery-source-state-001-p0-2026-09-07.md` | Ice 覆盖 `default.yaml` → `.byteCountMismatch` |
| `docs/evidence/scheme-delivery-source-state-001-p1-2026-09-07.md` | 同名冲突 / Ice `dofile` unresolved / Wanxiang skip |
| Assignment P2 叙述 + `Universe Keyboard/Services/SchemaManagerTypes.swift` `rime-ice-plan-2` | 独立预设 `rime_ice_preset.yaml`；`skippedFiles: ["default.yaml"]`；按文件卸载 Ice lua/emoji |
| `Packages/RimeBridge/.../RimeBuiltinResourceInstaller.swift` (~L231) | 不可读 receipt → `.fileOperationFailed`，不授权任意删除 |
| `docs/reviews/scheme-delivery-source-state-001-p4-quality-review.md` + `…-qp201.md` | Ice 活跃卸载 fail-closed；Q-P2-01 Closed |
| `docs/evidence/scheme-delivery-source-state-001-p4-product-gate-2026-09-08.md` | **Limited** P4 Product Gate（历史有限门） |
| `docs/evidence/scheme-delivery-wanxiang-lua-ownership-2026-09-08.md` | Wanxiang exact-hash Lua ownership 切片（非完整 P4） |
| `docs/reviews/scheme-delivery-wanxiang-upgrade-rollback-quality-2026-09-08.md` + `…-qurp201.md` | upgrade-rollback IQ Pass with conditions；Q-UR-P2-01 Closed |
| `Universe Keyboard/Services/SchemaArchiveInstaller.swift` `stageSchemaUninstall` + `matchingWanxiangLuaPaths` | 卸载 = plan paths + exact-hash Wanxiang Lua；**无**整目录清空 `lua/`/`opencc/` |
| Cross-scheme reviews CS09-10 / CSF / inventory | Luna-only active-uninstall；矩阵有条件 Pass；device/App Group 证明有限 |
| Runtime-route device / integration reviews | 选路服务卸载后候选输入；**不**替代归属 ADR |

---

## 3. Checklist results（对照清单 §4）

标记：`[x]` 通过 / `[~]` 有条件 / `[!]` 阻断 / `[ ]` 未核

### 4.1 决策完整性

- [x] 候选 A 仍是唯一拟 Accept 的决策（禁止覆盖 `default.yaml`；万象 skip；雾凇独立预设；按 owner/manifest 安装卸载）。正文 Decision 与 `main` 计划修订一致；B/C/现状/直接丢弃均被拒绝为终点。
- [~] §5.1 入口决策：Human 已指定候选 A（Ice）+ Luna-only 活跃卸载回退（原 §5.1.6 / 矩阵 supersede peer-prefer B）。**Accept 时须把 §5.1 七项写成显式** `Accept` / `fix` / `tech_debt:<ID>` / `out_of_scope`（本轮 Architecture 在下方 Residual/§5.1 表给出推荐，尚未写入 ADR 正文）。
- [x] 明确 **不** 通过本 ADR 偷偷修改 ADR 0033 官方不可变字节合同（ADR 0034 Decision 明文；Ice 用独立预设旁路）。
- [x] 明确 **不** 借共存关闭 ADR 0006 / TD-001（Decision + 0006 仍 “implementation pending”）。

### 4.2 与既有 Accepted ADR 的一致性

- [x] ADR 0001：安装/恢复/卸载/部署仍在主 App；Extension 只消费。抽样路径未引入 Extension writer。
- [x] ADR 0003：下载方案写入仍经主 App → App Group `Rime/shared`；未破坏共享容器读写边界叙述。
- [x] ADR 0006：归属规则与 lease / stage / commit / rollback **相容**；本 ADR **不**声称已还清原子安装债（仍 pending / TD-001）。
- [x] ADR 0032：按 owner/exact-hash 删除与来源恢复分类相容；不可读 receipt fail-closed 避免用失效 receipt 授权覆盖/删除。
- [x] ADR 0033：官方 Prelude/`default.yaml` 仍由 builtin receipt 门禁；候选 A 禁止第三方覆盖，与不可变闭包一致。

### 4.3 实现对照（`main` @ `814abfd` 抽样）

- [x] Ice：`rime-ice-plan-2` / `rime-ice-post-2`；`rime_ice_preset.yaml`；`skippedFiles` 含 `default.yaml`；Human-attested P3 重下可部署。
- [x] 卸载：Ice 具名 `removableFiles` + `lua/cold_word_drop`；Wanxiang `removableFiles`/`dicts` + `matchingWanxiangLuaPaths` exact-hash；生产 `stageSchemaUninstall` 无整目录 wipe `lua/` 或 `opencc/`。
- [~] Wanxiang：exact-hash Lua + upgrade-rollback 边界与 ADR「按 owner/manifest」方向一致。**A34-R1 Closed（narrow Wanxiang P4 Exit）** via S6 `2026-09-12`（S5 IQ Pass with conditions + Human E16/E17/E20 narrow + freeze `72b5987`）。**不**升格无条件 ADR 全文 / device failure-rollback / App Group 全路径。仍 `[~]`：narrow Exit ≠ ADR Accept。
- [x] 跨方案：Luna-only active-uninstall（Human supersede peer-prefer B）与 ADR「失败保留原选择/文件；回退内置 Luna」叙述无冲突。
- [x] Fail-closed：不可读 receipt 抛 `.fileOperationFailed`；未知污染不自动恢复；uninstall/upgrade rollback 保留 staging/checkpoint。

### 4.4 残余与债务 — 见 §4 Residual table

### 4.5 编号与治理

- [x] `docs/architecture/decisions/` 在 `main` @ `814abfd` 仅一份 `0034-multi-scheme-resource-ownership.md`（无第二份 `0034-*`）。
- [x] Accept 时草稿措辞已准备（**本轮不落盘**）：`Accepted — 2026-09-09 Asia/Shanghai`（实际日期以 Human 书面批准日为准），并链本清单 + 本结论 + Human 批准记录。
- [x] Accept 记录将链 checklist + 本 review + Human 书面批准（流程已在清单 §6 写明）。

---

## 4. Residual table A34-R1…R8（disposition 推荐）

规则：`fix` = Accept 前必修；仅 `accept` / `tech_debt` / 明确 `defer` 可支撑 Conditional / Recommend Accept。

| ID | Residual | Suggested owner | Disposition | Notes / evidence |
|---|---|---|---|---|
| A34-R1 | Wanxiang P4 未全闭合（升级/卸载/设备矩阵相对 ADR 全文） | Scheme Delivery / Quality | **`Closed`** — narrow Wanxiang P4 Exit | **Closed** — narrow Wanxiang P4 Exit: engineering Closed(evidence) E01–E13/E18/E19; E15 S5 IQ Pass with conditions; E16/E17/E20 Human Accepted (narrow Exit) 2026-09-12; freeze `72b5987` / S5 tip `6f29f64`. **Does not** Accept ADR 0034; device failure-rollback not attested; App Group full-path not elevated beyond Pass-with-conditions. Cite [`S5 IQ`](scheme-delivery-wanxiang-p4-closure-001-s5-quality-review.md) + Human E16/E17/E20 + [`WANXIANG-P4-CLOSURE-001`](../assignments/scheme-delivery-wanxiang-p4-closure-001.md)（Active；E14 Closed via S6）. Parallel Ice `dofile` remains A34-R2 / `tech_debt:TD-011`. |
| A34-R2 | Ice Lua `dofile`/`loadfile` 动态引用未闭合 | KeyboardCore / RIME | **`tech_debt:TD-011`**（或等价新债 ID） | P1 inventory 仍 unresolved；静态 `__include`/`import_preset` 已改独立预设。不阻断候选 A 决策字面，但阻断「引用改写已完全保真」宣称 |
| A34-R3 | backup/staging cleanup 仍 best-effort | App & Data Ops | **`accept`** | P3 Architecture delta 已保留；可观测性不足，非归属合同错误 |
| A34-R4 | Limited P4 Product Gate 仅为历史有限门；真机失败回滚未测 | Product / Quality | **`accept`** + **不**升格为完整 Product Gate | [`p4-product-gate-2026-09-08`](../evidence/scheme-delivery-source-state-001-p4-product-gate-2026-09-08.md)；**不**构成 ADR Accept |
| A34-R5 | CSF / 部分矩阵：真实 App Group·device transaction 证明有限 | Quality / Device | **`accept`** | CSF / CS09-10 reviews：Pass with conditions；自动化 ≠ 真机全路径 |
| A34-R6 | CS09-10-01 archive provenance / P2/P3 limits | Scheme Delivery | **`accept`**（或后续独立证据片 `fix` 但不阻塞归属 ADR） | inventory review 条件项；route device 已功能补偿 CS09-10-02 输入侧 |
| A34-R7 | `RTRD-01` / `RTRD-02` | Diagnostics | **`defer-with-owner`**（DEVICE / 独立 Assignment） | **不阻塞**归属 ADR |
| A34-R8 | ADR Follow-up 中过时 tip/分支/「Quality 尚无 delta」等表述 | Architecture / Docs | **`fix` on Accept commit only**（docs）；**不**单独 Block 决策 | Accept 落盘时一并修订 Follow-up 与编号检查叙述；本轮 **不得**改 Status |

### §5.1 推荐书面结论（Accept 时写入 ADR 或附录）

| # | Topic | Recommended disposition |
|---|---|---|
| 1 | 采纳候选 A | **Accept**（唯一长期归属策略；B/C 拒绝为默认） |
| 2 | 全局设置 / 方案预设 / 用户 `*.custom.yaml` 优先级 | **Accept** 方向：官方不可变基线 + App overlay + 方案独立预设 + 用户 custom；细节保持 ADR 0033 overlay 合同 |
| 3 | 允许的上游行为差异 | **`accept`**：Ice 经 `rime_ice_preset` 保真；不要求与 Prelude 逐键一致 |
| 4 | 同名字节相同共享 / 引用计数 | **`tech_debt` / 有界**：Ice 具名列表；Wanxiang Lua exact-hash；非通用引用计数器 |
| 5 | 历史污染恢复 | **Accept** 已知 Ice fingerprint 有界恢复；未知修改 fail-closed（已实现） |
| 6 | 活跃卸载回退 | **Accept**：Luna-only（Human 已 supersede peer-prefer B） |
| 7 | 角色任命 | **`out_of_scope`**（会话角色不写入 ADR 决策体） |

---

## 5. Verdict

### **Conditional Accept**

候选 A 作为长期多方案资源归属合同在决策层 **自洽**，与 Accepted ADR 0001/0003/0006/0032/0033 **无冲突**，且 `main` @ `814abfd` 抽样实现与「禁覆盖官方 `default.yaml` / Ice 独立预设 / 按文件或 exact-hash 卸载 / fail-closed receipt」一致。

**不**给出 Recommend Accept：A34-R1 已 **Closed（narrow）**；A34-R2（Ice `dofile`）与 A34-R8（Accept-commit docs）仍开放，且 §5.1 尚未以 ADR 正文形式逐项落盘。

**不**给出 Block：未发现 P0 级别「合同自相矛盾」或与 Accepted ADR 的硬冲突；实现抽样未显示整目录 `lua/`/`opencc/` 清空或第三方覆盖官方 Prelude 的现行生产路径。

### P0 / P1

| Severity | Item |
|---|---|
| **P0** | **无** |
| **P1-C1** | A34-R1 **Closed（narrow Wanxiang P4 Exit）** via S6 `2026-09-12` — 不再是 Accept 前 `fix` 阻断。Human Accept ADR 时须知情：narrow ≠ 全文无条件闭合；device failure-rollback 未 attested；App Group 全路径未升格 |
| **P1-C2** | A34-R2 转入 `tech_debt:TD-011`（或新债）并禁止宣称「动态 Lua 引用已完全闭合」 |
| **P1-C3** | Accept 提交同步：§5.1 七项显式 disposition + A34-R8 Follow-up 过时 tip 修订；**仅在另有 Human「Accept ADR 0034」授权后**改 Status |
| **P1-C4** | 明确 Limited P4 Product Gate / PR #100 merge **不等于** ADR Accept（A34-R4） |

### Conditions（Conditional）

1. 上表 P1-C1…C4 在 Human 书面 Accept 包内全部满足。
2. 任一条件若 Human 要求改为 Accept 前必修且未完成 → 本结论自动降级为 **Block**（由 Human/下一轮 Architecture 标注），不得静默 Accept。

### Blocking items

无现行 P0 Block。潜在升格路径：Human 拒绝接受 A34-R2 且坚持无条件 Recommend Accept。A34-R1 已 Closed（narrow）— **不**因此 Recommend Accept。

---

## 6. Explicit non-claims

- **不** Accept ADR 0034；Status 仍为 **Proposed**
- **不** 通过完整 Product Gate；**不**授权 TestFlight / App Release
- **不** 因 PR #100 合入（`814abfd`）或 Limited P4 Product Gate 而 Accept
- **不** 关闭 Ice `dofile`、Device-attested 全 Assignment、Recovery persistence；A34-R1 **Closed（narrow）** ≠ 完整无条件 Wanxiang P4 / ADR Accept
- **不** 关闭 `RTRD-01` / `RTRD-02`
- **不** 关闭 ADR 0006 / TD-001
- **不** 修改 ADR 0033 官方不可变字节合同
- 本审查 **未**改生产 Swift；**未** undraft/merge PR #101

---

## 7. Recommended Human next step

1. 阅读本结论 + 清单勾选结果。
2. 三选一书面决定：
   - **Accept ADR 0034（Conditional）** — A34-R1 已 Closed（narrow）；附带接受 R3–R6，R2→TD-011，R7 defer，R8 随 Accept docs 修订；或
   - **Keep Proposed** — 指定必须先 `fix` 的项（典型：Ice `dofile` / A34-R2）；或
   - **Revise ADR** — 若要对 ownership 模型（例如强制安装期 per-install receipt）做决策变更。
3. **仅当**选择 Accept 并满足 P1-C1…C4 后，另授权 Executor 改 ADR Status 并更新 Assignment / ACTIVE_WORK / KNOWLEDGE_INDEX。
4. 保持 PR #101 draft，直至 Human 另有指示。

---

## 8. History

- `2026-09-09 Asia/Shanghai`：独立 Architecture Accept 复审完成；Verdict = **Conditional Accept**；ADR Status 保持 Proposed。
- `2026-09-12 Asia/Shanghai`（**S6**）：Human-authorized A34-R1 writeback — residual **A34-R1 → Closed**（narrow Wanxiang P4 Exit；cite S5 IQ Pass with conditions + Human E16/E17/E20 narrow + platform tip `72b5987` / S5 tip `6f29f64`）。**ADR Status still Proposed**；leave draft #101；**no** Accept。Verdict remains **Conditional Accept**（A34-R2 / §5.1 / A34-R8 still open — **not** Recommend Accept）。

## History

- `2026-09-09 Asia/Shanghai`：Human 拒绝书面 `accept` A34-R1；A34-R1 按 `fix` 路径处理；独立 Assignment `SCHEME-DELIVERY-WANXIANG-P4-CLOSURE-001` 已起草（Ready，未 Active）。**ADR Status 仍为 Proposed。**
- `2026-09-09 Asia/Shanghai`（稍后）：Human 授权 `SCHEME-DELIVERY-WANXIANG-P4-CLOSURE-001` **Active**；A34-R1 仍为 `fix` / open until Assignment Exit；缺口清单见 [`../evidence/scheme-delivery-wanxiang-p4-closure-gaps-2026-09-09.md`](../evidence/scheme-delivery-wanxiang-p4-closure-gaps-2026-09-09.md)。**ADR Status 仍为 Proposed（未 Accept）。**
- `2026-09-12 Asia/Shanghai`（**S6**）：Human-authorized A34-R1 writeback — residual **A34-R1 → Closed**（narrow Wanxiang P4 Exit；cite S5 IQ Pass with conditions + Human E16/E17/E20 narrow + platform tip `72b5987` / S5 tip `6f29f64`）。**ADR Status still Proposed**；leave draft #101；**no** Accept。Verdict remains **Conditional Accept**（A34-R2 / §5.1 / A34-R8 still open — **not** Recommend Accept）。
