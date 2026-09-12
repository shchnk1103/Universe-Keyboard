# SCHEME-DELIVERY-WANXIANG-P4-CLOSURE-001 — Gap inventory (slice 1)

日期：2026-09-09 Asia/Shanghai

**性质：** 只读缺口盘点 + 推荐实现顺序。**不是**实现授权执行记录；**不是** ADR 0034 Accept；**不是** Product Gate / TestFlight / Release。

**Assignment：** [`SCHEME-DELIVERY-WANXIANG-P4-CLOSURE-001`](../assignments/scheme-delivery-wanxiang-p4-closure-001.md) — Lifecycle **Active（Resumed `2026-09-12`）**
**冻结 tip（historical S1）：** `origin/main` @ `814abfd7c03002256978d7658c176b80002d2539`（PR #100 merge）
**Resume freeze tip：** draft #102 tip `72b5987` on `codex/scheme-platform-001`
**工作分支（Resume）：** `codex/scheme-platform-001`（historical `codex/wanxiang-p4-closure-001` retained）
**A34-R1：** 仍为 `fix` / open（Architecture Accept residual）— **do not silent-close**；writeback = S6 after S5。
**E16/E17/E20：** Human `2026-09-12` **Accepted（narrow Exit）** — see [`scheme-delivery-wanxiang-p4-e16-e17-e20-disposition-2026-09-12.md`](scheme-delivery-wanxiang-p4-e16-e17-e20-disposition-2026-09-12.md)；**E14/E15 still Open**。

---

## 1. Inputs read (verified on freeze)

| Pointer | Role |
|---|---|
| [`ADR 0034`](../architecture/decisions/0034-multi-scheme-resource-ownership.md) | Proposed；候选 A 归属合同 |
| [`Architecture Accept review`](../reviews/adr-0034-architecture-accept-review-2026-09-09.md) | Conditional Accept；A34-R1 = `fix` |
| [`SOURCE-STATE-001`](../assignments/scheme-delivery-source-state-001.md) | Active parent；记 “Wanxiang P4 not fully closed” |
| [`Wanxiang Lua ownership evidence`](scheme-delivery-wanxiang-lua-ownership-2026-09-08.md) | exact-hash uninstall staging 切片 |
| [`upgrade-rollback contract`](../plans/scheme-delivery-wanxiang-upgrade-rollback-contract-2026-09-08.md) | Human Approved；有界 Wanxiang pin |
| [`upgrade-rollback IQ`](../reviews/scheme-delivery-wanxiang-upgrade-rollback-quality-2026-09-08.md) + [`Q-UR-P2-01`](../reviews/scheme-delivery-wanxiang-upgrade-rollback-quality-rereview-qurp201.md) | Pass with conditions；P2 residual Closed |
| [`P4 remaining matrix`](../plans/scheme-delivery-p4-remaining-matrix-2026-09-08.md) | 历史切片规划（peer-prefer B 已 supersede） |
| [`cross-scheme matrix contract`](../plans/scheme-delivery-cross-scheme-matrix-contract-2026-09-08.md) | Human Approved；Luna-only；CS-01…CS-10 / CS-F* |
| Cross-scheme IQ / evidence on `main` | CS09-10 / CSF / inventory / runtime-route device — Pass with conditions |
| Production sampling @ `814abfd` | `WanxiangLuaOwnership.swift`；`matchingWanxiangLuaPaths`；`createUpgradeCheckpoint` / `SchemaUpgradeRecoveryError` |

Pin under inventory（除非 Human 另授权）：CNB SHA-256 `9bfcf60e…` / `17.5.9` / `wanxiang-plan-1` / `wanxiang-post-1`。

---

## 2. Expectation matrix（Wanxiang P4 vs `main` @ `814abfd`）

标记：**Closed** = 冻结 tip 上已有生产行为 + 可引用自动化/IQ（或明确历史有限门）；**Open** = 本 Assignment 范围内仍须闭合才可回写 A34-R1；**Out-of-scope** = 本片 Non-goals / 硬停项。

| # | Expectation（相对 ADR 0034 候选 A / P4 规划） | Status | Evidence / note on `814abfd` |
|---|---|---|---|
| E01 | 万象安装继续 **skip** `default.yaml`；不覆盖官方 Prelude | **Closed** | `wanxiang-plan-1` `skippedFiles` 含 `default.yaml`；P0/P1/P2 路径 |
| E02 | 安装/卸载按 owner/manifest（具名 `removableFiles`/`dicts` + 批准共享关系） | **Closed** | plan removable 列表 + exact-hash Lua；无整目录 wipe |
| E03 | 万象 Lua 卸载：仅 pinned exact-hash 路径；未知/编辑字节保留 | **Closed** | `WanxiangLuaOwnership` + 5 项共存测试证据 `scheme-delivery-wanxiang-lua-ownership-2026-09-08.md`（提交路径已合入 `main`，含 `8147034`） |
| E04 | 升级前 checkpoint；失败恢复先验或保留 upgrade checkpoint；无成功 receipt until deploy | **Closed** | `d1c88e3` + IQ Pass with conditions；`Q-UR-P2-01 Closed` |
| E05 | 升级失败路径保留 unknown / user / Ice Lua / Prelude·OpenCC | **Closed** | 合同 §2.5 + installer 保存断言测试（IQ 已核） |
| E06 | 首次安装不伪造 prior-generation checkpoint | **Closed** | `testWanxiangFirstInstallCreatesNoUpgradeCheckpoint` |
| E07 | 跨方案 CS-01/02 双装共存（Ice↔Wanxiang） | **Closed** | CS-01/02 自动化 + IQ（合入 PR #100） |
| E08 | 跨方案 CS-03/04 同 identity 幂等 / 身份变更升级保 peer | **Closed** | CS-03/04 合入；`shouldSkipIdenticalReinstall` |
| E09 | 跨方案 CS-05/06 非活跃卸载保活跃 peer | **Closed** | CS-05/06 证据/评审在 `main` |
| E10 | 跨方案 CS-07/08 活跃卸载 → **Luna-only**（含万象活跃） | **Closed** | Luna-only 已 supersede peer-prefer B；CS-07/08 + runtime-route |
| E11 | CS-09/10 / CS-F* 失败注入与保留方案证据（工程自动化） | **Closed** | 矩阵 IQ Pass with conditions；CSF pair / CS09-10 reviews |
| E12 | 卸载 fail-closed：rollback 失败保留 staging checkpoint | **Closed** | double-failure repair（`fa9b3d1` 系）+ Q-P2-01 历史 Closed |
| E13 | 生产路径 **禁止** 整目录删除 `lua/` / `opencc/` | **Closed** | Architecture Accept 抽样；`stageSchemaUninstall` 行为 |
| E14 | 书面「Wanxiang P4 closure」核对表相对 ADR 全文完成，并可回写 A34-R1 | **Open** | 本文件为起点；Exit 前需正式 Closed 映射 + Assignment/ACTIVE_WORK 回写 |
| E15 | Independent Quality：**对本闭合 tip** 无开放 P0/P1（相对本片范围） | **Open** | 既有切片 IQ 已 Pass with conditions，但尚未以「P4 closure Exit」名义对冻结 tip 做汇总 IQ |
| E16 | 真机：万象 **升级失败回滚** Device-attested | **Accepted (narrow Exit)** | Human `2026-09-12`：书面缩窄 Exit — 无升级失败回滚真机要求；依赖自动化 + IQ |
| E17 | 真机：万象 **卸载失败回滚** Device-attested | **Accepted (narrow Exit)** | Human `2026-09-12`：书面缩窄 Exit — 无卸载失败回滚真机要求（同 E16） |
| E18 | 真机：万象安装/切换/输入成功路径 | **Closed**（历史 Human-attested） | `rime-scheme-delivery-wanxiang-success-2026-08-28.md` 等；**不**等同失败回滚闭合 |
| E19 | Runtime-route 设备：活跃卸载后 Luna 候选输入（含万象方向） | **Closed**（功能 Pass with conditions） | `SCHEME-DELIVERY-RUNTIME-ROUTE-DEVICE-001`；不替代归属/升级合同 |
| E20 | Cross-scheme **真实 App Group / device transaction** 全路径证明 | **Accepted (narrow Exit)** | Human `2026-09-12`：接受现有 Pass-with-conditions 限度；不把全路径 App Group 真机交易当作 A34-R1 阻塞 |
| E21 | Crash/restart Recovery persistence / checkpoint 发现 | **Out-of-scope** | 合同与 Assignment Non-goals |
| E22 | Ice `dofile`/`loadfile` 全量闭合（A34-R2 / TD-011） | **Out-of-scope** | 并行债；本片不关闭 |
| E23 | `RTRD-01` / `RTRD-02` | **Out-of-scope** | 独立 Assignment |
| E24 | ADR 0034 Status → Accepted | **Out-of-scope** | 需另一次 Human「Accept ADR」 |
| E25 | 更换 Wanxiang pin / 非 CNB `17.5.9` | **Out-of-scope** | 除非 Human 另授权 |
| E26 | peer-prefer B 回退 | **Out-of-scope** | 已 supersede；禁止再引入 |
| E27 | 完整 Product Gate Passed / TestFlight / App Release | **Out-of-scope** | Exit 不隐含这些 |
| E28 | 通用引用计数器 / 安装期 per-install receipt 新模型 | **Out-of-scope** | ADR §5.1 推荐有界 exact-hash；扩大模型需 Revise ADR |

### Counts

| Status | Count |
|---|---|
| **Closed** | 16（E01–E13, E18, E19） |
| **Open** | 2（E14, E15） |
| **Accepted (narrow Exit)** | 3（E16, E17, E20） — Human `2026-09-12` |
| **Out-of-scope** | 7（E21–E28） |

---

## 3. Interpretation（A34-R1）

在 `814abfd` 上，**Wanxiang 单方案工程切片**（skip `default.yaml`、exact-hash Lua 卸载、upgrade-rollback、跨方案矩阵自动化）大体已合入，且多份 Independent Quality 为 **Pass with conditions**。

A34-R1 仍为 `fix` 的原因不是「生产仍整目录 wipe / 覆盖 Prelude」类 P0 合同自相矛盾，而是：

1. **缺少正式闭合核对**（E14）把 ADR 全文期望映射到 Closed 证据并授权回写 disposition；
2. **条件项：** E16/E17/E20 Human 已 Accepted（narrow Exit）`2026-09-12`；**E15** 汇总 IQ 仍 Open；E14 writeback / A34-R1 仍 open（**不**静默 Closed）；
3. 历史文档仍显式写 “Wanxiang P4 not fully closed”，Architecture Accept 因此不能无条件 Recommend Accept。

本片优先路径：**文档与治理闭合 + Human 对 Open 项接受/缩窄/补证据**；仅当核对发现生产缺口时才开 Swift 最小片。

---

## 4. Recommended ordered minimal slices（尚未实现）

| Order | Slice | Kind | Goal | Stop if |
|---|---|---|---|---|
| **S1** | Gap inventory + Active governance | Docs（本片） | Active；冻结 tip；本清单 | — |
| **S2** | Closure checklist + residual disposition draft | Docs | 将 E01–E28 固化为 Exit 核对表；对 E16/E17/E20 提出 Human 三选一（接受条件 / 缩窄范围 / 补真机或证据） | Human 要求改 pin / Accept ADR |
| **S3** |（条件）生产缺口补丁 | Swift **仅当** S2 发现具体行为缺口 | 最小生产修复 + format 硬门槛 + 聚焦测试 | 扩大到 Ice dofile / Recovery / RTRD |
| **S4** |（条件）Device failure-rollback | Device + evidence | 仅当 Human 选择 E16/E17 为 Exit 必修 | 无 Device Operator 授权 |
| **S5** | Independent Quality closure delta | Review | 对冻结 tip 出具「无开放 P0/P1（本片范围）」或列出残留 | 把条件项静默当成 Closed |
| **S6** | A34-R1 disposition writeback | Docs | Assignment / ACTIVE_WORK / Architecture review：A34-R1 → `Closed` 或 Human 书面缩窄；**仍不**改 ADR Status | 无 Human 对 writeback 的确认 |

**S1 已完成。** S2 checklist 已落盘。Human Resume `2026-09-12`：E16/E17/E20 Accepted（narrow）；next **S5** IQ on `72b5987` → **S6** A34-R1 writeback（**不** silent-close A34-R1；**不** Accept ADR）。

---

## 5. Explicit non-claims

- 不宣称 Wanxiang P4 已 Closed / A34-R1 已关闭
- 不 Accept ADR 0034；Status 保持 Proposed
- 不关闭 TD-011 / A34-R2 / RTRD-* / Recovery persistence
- 不授权 TestFlight、完整 Product Gate、undraft/merge 本分支（除非 Human 另说）
- 不把 Limited P4 Product Gate 或 PR #100 merge 解释为 Wanxiang P4 闭合

---

## 6. History

- `2026-09-09 Asia/Shanghai`：slice 1 缺口清单落盘于分支 `codex/wanxiang-p4-closure-001`（base `814abfd`）；Assignment → Active。
- `2026-09-09 Asia/Shanghai`：Human 选择 **(b)** — keep Wanxiang P4 Active for **narrow A34-R1**；Scope 明确排除 Scheme Platform extract / Ice-as-reference P1–P3。S2 checklist：[`scheme-delivery-wanxiang-p4-closure-checklist-2026-09-09.md`](scheme-delivery-wanxiang-p4-closure-checklist-2026-09-09.md)。E14–E17/E20 仍 Open / needs disposition；**不**静默 Closed。
- `2026-09-12 Asia/Shanghai`：Human **Accepted（narrow Exit）** for E16/E17/E20；Resume freeze tip `72b5987` on `codex/scheme-platform-001`；**E14/E15 still Open**；**do not silent-close A34-R1**；next S5→S6；no ADR Accept；leave #101。
