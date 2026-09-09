# ADR 0034 — Architecture Accept 复审清单

日期：2026-09-09 Asia/Shanghai

**授权：** Human Product Owner 批准「单独开一轮 Architecture Accept 复审清单」。

**本文件性质：** 只读复审入口与核对表。
**不是：** ADR Acceptance、Product Gate、TestFlight、Release、实现授权，或把 Status 从 Proposed 改为 Accepted。

**审查对象：** [`docs/architecture/decisions/0034-multi-scheme-resource-ownership.md`](../architecture/decisions/0034-multi-scheme-resource-ownership.md)（当前 **Proposed**）
**基线 tip：** `main` @ `814abfd`（PR #100 已合入）
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

- [ ] 候选 A 仍是唯一拟 Accept 的决策（禁止覆盖 `default.yaml`；万象 skip；雾凇独立预设；按 owner/manifest 安装卸载）
- [ ] §5.1 入口决策中仍开放项已列出结论：`Accept` / `fix` / `tech_debt:<ID>` / `out_of_scope`
- [ ] 明确 **不** 通过本 ADR 偷偷修改 ADR 0033 官方不可变字节合同
- [ ] 明确 **不** 借共存关闭 ADR 0006 / TD-001，除非另有书面还债授权

### 4.2 与既有 Accepted ADR 的一致性

- [ ] ADR 0001：主 App 仍为唯一完整 deployment writer
- [ ] ADR 0003：共享容器读写边界未被下载方案安装路径破坏
- [ ] ADR 0006：安装/卸载事务（lease / stage / commit / rollback）与归属规则相容
- [ ] ADR 0032：来源恢复与完整性分类未被「按 owner 删除」削弱
- [ ] ADR 0033：官方 Prelude/`default.yaml` 不可变闭包在候选 A 下仍成立

### 4.3 实现对照（`main` @ `814abfd` 抽样）

- [ ] Ice：独立预设 / 不再覆盖官方 `default.yaml` 的生产路径有证据指针
- [ ] 卸载：按文件归属 staging，无整目录清空 `lua/` 或 `opencc/` 的合同违规
- [ ] Wanxiang：exact-hash Lua ownership + upgrade-rollback 边界与 ADR 条文一致或已记残余
- [ ] 跨方案矩阵：Luna-only active-uninstall（Human 已 supersede peer-prefer B）与 ADR 归属条文无冲突说明
- [ ] Fail-closed：不可读 receipt / 失败回滚不会用失效 receipt 授权任意删除

### 4.4 残余与债务（Accept 前必须处置）

对每一项给出 disposition：`fix`（Accept 前必修） / `accept`（Accept 时书面接受） / `tech_debt:<ID>` / `defer-with-owner`

| ID | Residual | Suggested owner | Disposition (fill) | Notes / evidence pointer |
|---|---|---|---|---|
| A34-R1 | Wanxiang P4 未全闭合（升级/卸载矩阵相对 ADR 全文） | Scheme Delivery / Quality | | |
| A34-R2 | Ice Lua `dofile` 动态引用未闭合 | KeyboardCore / RIME | | |
| A34-R3 | backup/staging cleanup 仍 best-effort | App & Data Ops | | |
| A34-R4 | Limited P4 Product Gate 仅为历史有限门；真机失败回滚未测 | Product / Quality | | |
| A34-R5 | CSF / 部分矩阵：真实 App Group·device transaction 证明有限 | Quality / Device | | |
| A34-R6 | CS09-10-01 archive provenance / P2/P3 limits | Scheme Delivery | | |
| A34-R7 | `RTRD-01` / `RTRD-02`（诊断 UI / elapsed） | Diagnostics | `defer` 默认：独立 Assignment，**不阻塞**归属 ADR 除非 Architecture 认定可观测性不足 | |
| A34-R8 | ADR 正文 Follow-up 中过时 tip/分支表述需 Accept 时一并修订 | Architecture / Docs | | |

**规则：** 任一 `fix` 且 Architecture 标为 Accept 阻断 → **Block**。仅 `accept` / `tech_debt` / 明确 `defer` 时可给 Conditional 或 Recommend Accept。

### 4.5 编号与治理

- [ ] `docs/architecture/decisions/` 在 `main` 上无第二份 `0034-*`
- [ ] Accept 时 Status 行拟改为 `Accepted — <date>` 的草稿措辞已准备（**本轮不落盘为 Accepted**）
- [ ] Accept 记录将链到本清单 + Architecture 结论文件 + Human 书面批准

---

## 5. Architecture 结论模板（复审结束时填写）

| Field | Value |
|---|---|
| Reviewer | （独立 Architecture lane） |
| Baseline SHA | |
| Verdict | `Recommend Accept` / `Conditional Accept` / `Block` |
| P0 / P1 open | |
| Conditions（若 Conditional） | |
| Blocking items（若 Block） | |
| Recommended Human next step | |

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
