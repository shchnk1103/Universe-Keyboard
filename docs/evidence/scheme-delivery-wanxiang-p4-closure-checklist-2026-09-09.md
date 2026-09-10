# SCHEME-DELIVERY-WANXIANG-P4-CLOSURE-001 — Narrow closure checklist (S2)

日期：2026-09-09 Asia/Shanghai

**性质：** Exit 核对表（窄 A34-R1）。映射 gap inventory E01–E28 → Exit 状态。**不是** ADR 0034 Accept；**不是** Product Gate / TestFlight / Release；**不是** Scheme Platform extract / P1 Swift。

**Assignment：** [`SCHEME-DELIVERY-WANXIANG-P4-CLOSURE-001`](../assignments/scheme-delivery-wanxiang-p4-closure-001.md) — Lifecycle **Active**（Human choice **(b)**）
**Gap inventory：** [`scheme-delivery-wanxiang-p4-closure-gaps-2026-09-09.md`](scheme-delivery-wanxiang-p4-closure-gaps-2026-09-09.md)
**冻结 tip：** `origin/main` @ `814abfd7c03002256978d7658c176b80002d2539`
**工作分支：** `codex/wanxiang-p4-closure-001`
**Scope：** **narrow A34-R1 only** — Scheme Platform / Ice-as-reference P1–P3 **explicitly out of scope** until [`SCHEME-DELIVERY-SCHEME-PLATFORM-001`](../assignments/scheme-delivery-scheme-platform-001.md) is separately **Active**.

---

## 0. Human decision recorded

| Item | Value |
|---|---|
| Date | `2026-09-09 Asia/Shanghai` |
| Choice | **(b)** keep Wanxiang P4 Active for narrow A34-R1 |
| Excludes | Scheme Platform extract；Ice-as-reference P1–P3；mega-refactor |
| Platform Assignment | **Ready**（deferred Active；并行不抢实现权） |
| Blocker `(a)/(b)` | **Cleared** |

---

## 1. Exit checklist — E01–E28 → narrow closure

状态约定：

- **Closed（evidence）** = 冻结 tip 上已有可引用生产行为 + 自动化/IQ（或明确历史有限门）；本 checklist 复用 gap inventory 指针，**不**新宣称 Closed。
- **Open — writeback path** = E14：本表是起点；正式回写 A34-R1 仍待后续 S6 + Human 确认。
- **Open — IQ** = E15：尚未以「P4 closure Exit」名义对冻结 tip 做汇总 IQ。
- **Needs Human disposition** = E16/E17/E20：不得静默 Closed；须 Human 选择接受条件 / 缩窄范围 / 补真机或证据。
- **Out-of-scope** = 本片 Non-goals（含平台抽取）。

| # | Expectation | Exit status (narrow) | Evidence pointer / disposition note |
|---|---|---|---|
| E01 | 万象安装 skip `default.yaml`；不覆盖 Prelude | **Closed（evidence）** | gap E01；`wanxiang-plan-1` `skippedFiles` |
| E02 | 安装/卸载按 owner/manifest | **Closed（evidence）** | gap E02；plan removable + exact-hash Lua |
| E03 | 万象 Lua 卸载：pinned exact-hash；未知字节保留 | **Closed（evidence）** | [`scheme-delivery-wanxiang-lua-ownership-2026-09-08.md`](scheme-delivery-wanxiang-lua-ownership-2026-09-08.md) |
| E04 | 升级前 checkpoint；失败恢复；无成功 receipt until deploy | **Closed（evidence）** | upgrade-rollback IQ；`Q-UR-P2-01 Closed` |
| E05 | 升级失败保留 unknown / user / Ice Lua / Prelude·OpenCC | **Closed（evidence）** | 合同 §2.5 + installer 断言测试 |
| E06 | 首次安装不伪造 prior-generation checkpoint | **Closed（evidence）** | `testWanxiangFirstInstallCreatesNoUpgradeCheckpoint` |
| E07 | CS-01/02 双装共存 | **Closed（evidence）** | CS-01/02 + IQ（PR #100） |
| E08 | CS-03/04 幂等 / 身份变更保 peer | **Closed（evidence）** | CS-03/04；`shouldSkipIdenticalReinstall` |
| E09 | CS-05/06 非活跃卸载保活跃 peer | **Closed（evidence）** | CS-05/06 on `main` |
| E10 | CS-07/08 活跃卸载 → Luna-only | **Closed（evidence）** | Luna-only + runtime-route |
| E11 | CS-09/10 / CS-F* 失败注入（工程自动化） | **Closed（evidence）** | 矩阵 IQ Pass with conditions |
| E12 | 卸载 fail-closed：rollback 失败保留 staging | **Closed（evidence）** | double-failure repair + Q-P2-01 |
| E13 | 禁止整目录删除 `lua/` / `opencc/` | **Closed（evidence）** | Architecture Accept 抽样；`stageSchemaUninstall` |
| E14 | 书面「Wanxiang P4 closure」核对表 + 可回写 A34-R1 | **Open — writeback path** | **本文件 = S2 核对表落盘**；A34-R1 disposition writeback（S6）仍待：须 Human 对 Open 项拍板后，再回写 Architecture review / Assignment / ACTIVE_WORK。**不**在本片自动 Closed A34-R1。 |
| E15 | Independent Quality：对本闭合 tip 无开放 P0/P1（本片范围） | **Open — IQ** | 既有切片 IQ Pass with conditions；**尚未**以「P4 closure Exit」名义对 `814abfd` / 本分支 tip 做汇总 IQ（S5）。保持 Open。 |
| E16 | 真机：万象 **升级失败回滚** Device-attested | **Needs Human disposition** | 升级切片未要求真机。**Draft default（非 Human accept）：** 书面缩窄 Exit — 接受「无万象升级失败回滚真机」为条件，依赖自动化 + IQ，直至 Human 另授权 Device。**仍需 Human 明示：接受条件 / 缩窄 / 补真机。** |
| E17 | 真机：万象 **卸载失败回滚** Device-attested | **Needs Human disposition** | Limited P4 Gate 接受 device failure-rollback 未测（偏 Ice）。万象对等未记。**Draft default（非 Human accept）：** 书面缩窄 Exit — 同 E16 条件接受，直至另授权 Device。**仍需 Human 明示。** |
| E18 | 真机：万象安装/切换/输入成功路径 | **Closed（evidence）** | `rime-scheme-delivery-wanxiang-success-2026-08-28.md`；**不**等同失败回滚 |
| E19 | Runtime-route 设备：活跃卸载后 Luna 候选 | **Closed（evidence）** | `SCHEME-DELIVERY-RUNTIME-ROUTE-DEVICE-001` Pass with conditions |
| E20 | Cross-scheme **真实 App Group / device transaction** 全路径 | **Needs Human disposition** | CSF / CS09-10 条件项。**Draft default（非 Human accept）：** 接受现有 Pass with conditions 限度作为窄闭合条件，不把全路径 App Group 真机交易证明当作 A34-R1 阻塞，直至 Human 另要求补证据。**仍需 Human 明示。** |
| E21 | Crash/restart Recovery persistence | **Out-of-scope** | Non-goals |
| E22 | Ice `dofile`/`loadfile`（A34-R2 / TD-011） | **Out-of-scope** | 并行债 |
| E23 | `RTRD-01` / `RTRD-02` | **Out-of-scope** | 独立 Assignment |
| E24 | ADR 0034 → Accepted | **Out-of-scope** | 需另一次 Human Accept ADR |
| E25 | 更换 Wanxiang pin / 非 CNB `17.5.9` | **Out-of-scope** | 除非另授权 |
| E26 | peer-prefer B 回退 | **Out-of-scope** | 已 supersede |
| E27 | 完整 Product Gate / TestFlight / Release | **Out-of-scope** | Exit 不隐含 |
| E28 | 通用引用计数器 / 新 receipt 模型 | **Out-of-scope** | 扩大需 Revise ADR |
| — | Scheme Platform extract / Ice-as-reference P1–P3 | **Out-of-scope（Human b）** | [`SCHEME-DELIVERY-SCHEME-PLATFORM-001`](../assignments/scheme-delivery-scheme-platform-001.md) Ready；另 Active 后才进 |

### Counts (narrow Exit view)

| Exit status | Count |
|---|---|
| **Closed（evidence）** | 16（E01–E13, E18, E19） |
| **Open — writeback path** | 1（E14） |
| **Open — IQ** | 1（E15） |
| **Needs Human disposition** | 3（E16, E17, E20） |
| **Out-of-scope** | 7（E21–E28）+ platform extract |

---

## 2. Residual disposition notes（draft — not Human accept）

> 以下「Draft default」仅为 Executor 便于 Human 决策的建议，**明确标注 draft**。**不得**解释为 Human 已接受 device residuals。

| Residual | Status | Draft default（labeled draft） | What Human must still decide |
|---|---|---|---|
| E14 writeback | Open | 完成本 checklist 后，待 E15–E17/E20 处置 + S5 IQ，再走 S6 A34-R1 writeback | 是否授权 A34-R1 disposition 回写（仍 **不** Accept ADR） |
| E15 IQ | Open | 安排 Independent Quality「P4 narrow closure」delta on 冻结 tip | 何时 / 对哪个 tip 跑汇总 IQ |
| E16 升级失败回滚真机 | **Needs Human disposition** | Draft：缩窄 Exit，接受无真机 | 接受条件 / 缩窄 / 补 Device |
| E17 卸载失败回滚真机 | **Needs Human disposition** | Draft：缩窄 Exit，接受无真机 | 接受条件 / 缩窄 / 补 Device |
| E20 App Group / device transaction | **Needs Human disposition** | Draft：接受现有 Pass with conditions 限度 | 接受条件 / 补证据 |
| Platform Active | Deferred | 保持 Ready；与窄 P4 并行 | 何时 Active `SCHEME-DELIVERY-SCHEME-PLATFORM-001` |
| Push / merge | Not authorized | 本地 docs only | 是否 push 本分支 |
| ADR 0034 Accept | Out-of-scope | 不在本片 | 另授权 Accept |

---

## 3. Recommended next steps（narrow path）

1. Human 对 **E16 / E17 / E20** 明示 disposition（或明确采用上表 draft defaults）。
2. **S5**：Independent Quality closure delta（本片范围；不静默 Closed 条件项）。
3. **S6**：A34-R1 disposition writeback（仅在 Open 项处置后；**仍不**改 ADR Status）。
4. **S3 Swift** 仅当核对发现具体生产缺口；**禁止**平台抽取。
5. 对外 **push/merge** 仍需 Human。

---

## 4. Explicit non-claims

- 不宣称 Wanxiang P4 已 Closed / A34-R1 已关闭
- 不把 E16/E17/E20 draft defaults 当作 Human accept
- 不 Accept ADR 0034；不关闭 TD-011 / A34-R2 / RTRD-* / Recovery
- 不授权 TestFlight、完整 Product Gate、push/merge（除非 Human 另说）
- 不把本 checklist 解释为 Scheme Platform Active 或 P1 Swift 授权

---

## 5. History

- `2026-09-09 Asia/Shanghai`：S2 narrow closure checklist 落盘；记录 Human **(b)**；E14 = writeback path；E15 IQ open；E16/E17/E20 = **needs Human disposition**（draft defaults 明确标注）。
