# ADR 0034 — Architecture Accept 复审清单

日期：2026-09-09 Asia/Shanghai

**授权：** Human Product Owner 批准「单独开一轮 Architecture Accept 复审清单」。

**本文件性质：** 只读复审入口与核对表。
**不是：** ADR Acceptance、Product Gate、TestFlight、Release、实现授权，或把 Status 从 Proposed 改为 Accepted。

**审查对象：** [`docs/architecture/decisions/0034-multi-scheme-resource-ownership.md`](../architecture/decisions/0034-multi-scheme-resource-ownership.md)（当前 **Accepted** — Conditional Accept package, 2026-09-12）
**基线 tip：** `main` @ `814abfd`（PR #100 已合入）；**Accept prep 抽样补充：** post-#102 `main` @ `be91ca5` / merge `a6fc6f0`
**关联 Assignment：** [`SCHEME-DELIVERY-SOURCE-STATE-001`](../assignments/scheme-delivery-source-state-001.md)

---

## 1. Scope（本轮只审这些）

| In scope | Out of scope |
|---|---|
| ADR 0034 正文与候选 A 是否仍是正确的长期归属合同 | 直接把 ADR Status 改为 Accepted |
| 与 Accepted ADR 0001 / 0003 / 0006 / 0032 / 0033 的冲突或需修订项 | Product Gate Passed / TestFlight / App Release |
| `main` 上已落地实现是否与候选 A 一致（抽样证据指针） | 新写生产代码或扩大 TD-001 |
| Accept 前必须关闭、`accept` 或转入 tech debt 的残余清单 | `RTRD-01` / `RTRD-02` 诊断 UI 实现（独立 Assignment） |
| 编号占用复核（`0034` 在 `main` 唯一性） | Recovery persistence 新范围 |

---

## 2. Ownership

| Role | Responsibility |
|---|---|
| Architecture & Knowledge Steward | 独立、只读 Accept 复审；给出 **Recommend Accept / Conditional / Block**；不得自行改 ADR Status |
| Product Lead / Human Product Owner | 在 Architecture 结论之后决定是否书面 Accept；保留否决权 |
| Quality（只读配合） | 提供已有 IQ / delta 指针；本清单不替代新的 Quality Gate |
| Executor / Coordinator | 只维护本清单与链接；**不得**在本轮把 ADR 标为 Accepted |

---

## 3. Applicable contracts（复审必读）

1. ADR 0034（Proposed）全文 + Follow-up Work
2. [共存实施计划](../plans/scheme-resource-ownership-and-coexistence-plan.md) §5 / §5.1
3. Accepted：ADR 0001、0003、0006、0032、0033
4. Assignment Current Status / Residuals：`SCHEME-DELIVERY-SOURCE-STATE-001`
5. 关键证据（抽样，非穷尽）：
   - P0/P1/P3/P4 与 Limited Product Gate 记录（历史有限门 **不** 自动等于 ADR Accept）
   - Wanxiang exact-hash / upgrade-rollback reviews
   - Cross-scheme matrix + CSF / CS09-10 reviews
   - Runtime-route contract / integration / device reviews（route 修复服务卸载后选路，不替代归属 ADR）

---

## 4. Accept 准入核对表（Architecture 逐项勾选）

标记：`[ ]` 未核 / `[x]` 通过 / `[~]` 有条件 / `[!]` 阻断

### 4.1 决策完整性

- [x] 候选 A 仍是唯一拟 Accept 的决策（禁止覆盖 `default.yaml`；万象 skip；雾凇独立预设；按 owner/manifest 安装卸载）
- [x] §5.1 入口决策结论已写入 ADR 为 **Accepted dispositions**（Human Accept 2026-09-12）
- [x] 明确 **不** 通过本 ADR 偷偷修改 ADR 0033 官方不可变字节合同
- [x] 明确 **不** 借共存关闭 ADR 0006 / TD-001，除非另有书面还债授权

### 4.2 与既有 Accepted ADR 的一致性

- [x] ADR 0001：主 App 仍为唯一完整 deployment writer
- [x] ADR 0003：共享容器读写边界未被下载方案安装路径破坏
- [x] ADR 0006：安装/卸载事务（lease / stage / commit / rollback）与归属规则相容
- [x] ADR 0032：来源恢复与完整性分类未被「按 owner 删除」削弱
- [x] ADR 0033：官方 Prelude/`default.yaml` 不可变闭包在候选 A 下仍成立

### 4.3 实现对照（`main` @ `814abfd` 抽样；Accept prep 亦对照 `be91ca5` / `a6fc6f0`）

- [x] Ice：独立预设 / 不再覆盖官方 `default.yaml` 的生产路径有证据指针
- [x] 卸载：按文件归属 staging，无整目录清空 `lua/` 或 `opencc/` 的合同违规
- [~] Wanxiang：exact-hash Lua ownership + upgrade-rollback 边界与 ADR 条文一致；**A34-R1 Closed（narrow Wanxiang P4 Exit）** via S6 `2026-09-12`（仍 `[~]`：narrow ≠ ADR Accept / 全文无条件闭合）
- [x] 跨方案矩阵：Luna-only active-uninstall（Human 已 supersede peer-prefer B）与 ADR 归属条文无冲突说明
- [x] Fail-closed：不可读 receipt / 失败回滚不会用失效 receipt 授权任意删除

### 4.4 残余与债务（Accept 前必须处置）

对每一项给出 disposition：`fix`（Accept 前必修） / `accept`（Accept 时书面接受） / `tech_debt:<ID>` / `defer-with-owner`

| ID | Residual | Suggested owner | Disposition (fill) | Notes / evidence pointer |
|---|---|---|---|---|
| A34-R1 | Wanxiang P4 未全闭合（升级/卸载矩阵相对 ADR 全文） | Scheme Delivery / Quality | **`Closed`** — narrow Wanxiang P4 Exit | S6 `2026-09-12` writeback；cite S5 IQ + Human E16/E17/E20 narrow + freeze `72b5987` / S5 tip `6f29f64`。**Does not** Accept ADR 0034。Ice `dofile` remains A34-R2 / `tech_debt:TD-011` |
| A34-R2 | Ice Lua `dofile` 动态引用未闭合 | KeyboardCore / RIME | `tech_debt:TD-011` | P1 inventory unresolved；非 P0 |
| A34-R3 | backup/staging cleanup 仍 best-effort | App & Data Ops | `accept` | P3 delta residual |
| A34-R4 | Limited P4 Product Gate 仅为历史有限门；真机失败回滚未测 | Product / Quality | `accept` | 不升格完整 Product Gate；不构成 ADR Accept |
| A34-R5 | CSF / 部分矩阵：真实 App Group·device transaction 证明有限 | Quality / Device | `accept` | IQ Pass with conditions |
| A34-R6 | CS09-10-01 archive provenance / P2/P3 limits | Scheme Delivery | `accept` | 可不阻塞归属 ADR |
| A34-R7 | `RTRD-01` / `RTRD-02`（诊断 UI / elapsed） | Diagnostics | `defer-with-owner` | 独立 Assignment，**不阻塞**归属 ADR |
| A34-R8 | ADR 正文 Follow-up 中过时 tip/分支表述 | Architecture / Docs | **Closed**（Accept docs） | Follow-up refreshed in Accept prep；Accept commit flipped Status → **Accepted**（Conditional）。tip → `be91ca5`/`a6fc6f0`。**leave #101 draft** |

**规则：** 任一 `fix` 且 Architecture 标为 Accept 阻断 → **Block**。仅 `accept` / `tech_debt` / 明确 `defer` 时可给 Conditional 或 Recommend Accept。

### 4.5 编号与治理

- [x] `docs/architecture/decisions/` 在 `main` 上无第二份 `0034-*`
- [x] Status 已落盘为 **Accepted — Conditional Accept package, 2026-09-12 Asia/Shanghai**
- [x] Accept 记录将链到本清单 + Architecture 结论文件 + Human 书面批准

---

## 5. Architecture 结论模板（复审结束时填写）

| Field | Value |
|---|---|
| Reviewer | Independent Architecture lane（Grok Bot executor subagent） |
| Baseline SHA | 初审 `main` `814abfd`；docs 分支起点 `7d5a759`；**Accept prep freeze** `main` @ `be91ca5` / `a6fc6f0` |
| Verdict | **Conditional Accept** |
| P0 / P1 open | P0=0；P1-C1…C4 见 [review](adr-0034-architecture-accept-review-2026-09-09.md) §5 |
| Conditions（若 Conditional） | A34-R1 **Closed（narrow）**；R2→TD-011；§5.1 **Accepted dispositions** formalized；A34-R8 **Closed**（Accept docs）；Limited Gate ≠ Accept；**Not** Product Gate / TF / Platform Close |
| Blocking items（若 Block） | 无现行 P0 |
| Recommended Human next step | **Done:** Human Accept ADR 0034（Conditional）。ADR Status **Accepted**。PR #101 **仍 draft** — **no** Recommend undraft without separate auth；Platform stays Active（no Close） |

**禁止：** 在本文件勾选完成后自动改 ADR Status；须另有 Human「Accept ADR 0034」授权 + 独立 Architecture 结论文件。

---

## 6. Human Product 决策门（本清单之后）

1. Architecture 出具结论文件（新建 `docs/reviews/adr-0034-architecture-accept-review-YYYY-MM-DD.md`）。
2. Human 明确三选一：
   - **Accept ADR 0034**（可附带 Conditional 残余表）
   - **Keep Proposed**（列出还缺什么）
   - **Revise ADR**（回写作文案/决策变更，再开一轮）
3. 仅在 (1)+(2)=Accept 后，Executor 才可改 ADR Status 并更新 Assignment / ACTIVE_WORK / KNOWLEDGE_INDEX。

---

## 7. Non-claims

- 本清单 **不** Accept ADR 0034
- 本清单 **不** 通过完整 Product Gate
- 本清单 **不** 授权 TestFlight / Release
- PR #100 已合入 **不** 构成 Acceptance
- 历史 Limited P4 Product Gate **不** 构成 Acceptance

---

## 8. History

- `2026-09-09 Asia/Shanghai`：Human 批准单独开本 Architecture Accept 复审清单；Status 保持 Proposed。
- `2026-09-09 Asia/Shanghai`：Architecture Accept **review 已完成** — [`adr-0034-architecture-accept-review-2026-09-09.md`](adr-0034-architecture-accept-review-2026-09-09.md)；Verdict = **Conditional Accept**。清单勾选已填。**仍不是** ADR Accept；Status 保持 Proposed。
- `2026-09-12 Asia/Shanghai`（**S6**）：A34-R1 → **Closed（narrow Wanxiang P4 Exit）**。Verdict remains **Conditional Accept**（A34-R2 / §5.1 / A34-R8）。**ADR Status still Proposed**；leave #101；**no** Accept。
- `2026-09-12 Asia/Shanghai`（**Accept prep**）：Human-authorized draft #101 Accept prep only。Freeze `main` @ `be91ca5` / `a6fc6f0`。A34-R8 Follow-up refreshed；§5.1 draft prep in ADR。Verdict remains **Conditional Accept**（R2 / formal §5.1 Accept-commit / Status）。**ADR Status still Proposed**；leave #101 draft；**prep ≠ Accept**；Platform Active（no Close）。证据：[`../evidence/adr-0034-accept-prep-2026-09-12.md`](../evidence/adr-0034-accept-prep-2026-09-12.md)。
- `2026-09-12 Asia/Shanghai`（**Accept**）：Human authorized **Accept ADR 0034**（Conditional；typo Accrpt=Accept）。Status → **Accepted**。A34-R8 **Closed**（Accept docs）。§5.1 formalized。leave #101 **draft**（**no** Recommend undraft without auth）；Platform Active（no Close）；**not** Product Gate / TF / Release。证据：[`../evidence/adr-0034-accept-2026-09-12.md`](../evidence/adr-0034-accept-2026-09-12.md) · 授权：[`../product-decisions/ADR-0034-ACCEPT-authorization.md`](../product-decisions/ADR-0034-ACCEPT-authorization.md)。
