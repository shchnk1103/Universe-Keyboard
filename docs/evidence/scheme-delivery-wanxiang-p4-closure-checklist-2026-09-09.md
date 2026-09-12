# SCHEME-DELIVERY-WANXIANG-P4-CLOSURE-001 — Narrow closure checklist (S2)

日期：2026-09-09 Asia/Shanghai

**性质：** Exit 核对表（窄 A34-R1）。映射 gap inventory E01–E28 → Exit 状态。**不是** ADR 0034 Accept；**不是** Product Gate / TestFlight / Release；**不是** Scheme Platform extract / P1 Swift。

**Assignment：** [`SCHEME-DELIVERY-WANXIANG-P4-CLOSURE-001`](../assignments/scheme-delivery-wanxiang-p4-closure-001.md) — Lifecycle **Active（Resumed `2026-09-12 Asia/Shanghai`）**
**Gap inventory：** [`scheme-delivery-wanxiang-p4-closure-gaps-2026-09-09.md`](scheme-delivery-wanxiang-p4-closure-gaps-2026-09-09.md)
**E16/E17/E20 disposition：** [`scheme-delivery-wanxiang-p4-e16-e17-e20-disposition-2026-09-12.md`](scheme-delivery-wanxiang-p4-e16-e17-e20-disposition-2026-09-12.md)
**冻结 tip（Resume path）：** draft #102 tip `72b5987dc4434221f4b4aa57c836369723bd7fb9` on `codex/scheme-platform-001`（historical S2 base `814abfd` / branch `codex/wanxiang-p4-closure-001` retained）
**工作分支（Resume）：** `codex/scheme-platform-001`（leave #101 alone）
**Scope：** **narrow A34-R1 only** — Human accepted draft narrow Exit for E16/E17/E20。Platform Assignment [`SCHEME-DELIVERY-SCHEME-PLATFORM-001`](../assignments/scheme-delivery-scheme-platform-001.md) stays **Active**（P3 Exit certified；no Close）。**不** Accept ADR 0034。

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
- **Closed（writeback）** = E14：S6 Human-authorized A34-R1 disposition writeback Done（narrow）。
- **Open — writeback path** = （历史）E14 曾用此态；S6 后 E14 = **Closed（writeback）**。
- **Open — IQ** = （历史）E15 曾用此态；S5 后 E15 = **Closed（evidence）**。
- **Accepted (narrow Exit)** = E16/E17/E20：Human（`2026-09-12`）接受 draft narrow Exit（不再 Needs Human disposition）。
- **Needs Human disposition** = （历史）E16/E17/E20 曾用此态；现已 Accepted（narrow Exit）。
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
| E14 | 书面「Wanxiang P4 closure」核对表 + 可回写 A34-R1 | **Closed（writeback）** | **S6** `2026-09-12`：Human-authorized A34-R1 writeback Done — residual **Closed（narrow Wanxiang P4 Exit）**。Cite S5 IQ + Human E16/E17/E20 narrow + freeze `72b5987` / S5 tip `6f29f64`。**不** Accept ADR 0034。 |
| E15 | Independent Quality：对本闭合 tip 无开放 P0/P1（本片范围） | **Closed（evidence）** | S5 IQ [`../reviews/scheme-delivery-wanxiang-p4-closure-001-s5-quality-review.md`](../reviews/scheme-delivery-wanxiang-p4-closure-001-s5-quality-review.md) — **Pass with conditions** on freeze `72b5987`；无开放 P0/P1（narrow scope）。Hosted CI run `34676751887` attempt 2 full green；flake residual `WX-P4-S5-IQ-01` accept。**不**等同 A34-R1 Closed。 |
| E16 | 真机：万象 **升级失败回滚** Device-attested | **Accepted (narrow Exit)** | Human `2026-09-12 Asia/Shanghai`：**Accepted（narrow Exit）** — 接受「无万象升级失败回滚真机」；依赖自动化 + IQ；不要求 device failure-rollback 真机。详见 disposition note。 |
| E17 | 真机：万象 **卸载失败回滚** Device-attested | **Accepted (narrow Exit)** | Human `2026-09-12 Asia/Shanghai`：**Accepted（narrow Exit）** — 同 E16；不要求卸载失败回滚真机。详见 disposition note。 |
| E18 | 真机：万象安装/切换/输入成功路径 | **Closed（evidence）** | `rime-scheme-delivery-wanxiang-success-2026-08-28.md`；**不**等同失败回滚 |
| E19 | Runtime-route 设备：活跃卸载后 Luna 候选 | **Closed（evidence）** | `SCHEME-DELIVERY-RUNTIME-ROUTE-DEVICE-001` Pass with conditions |
| E20 | Cross-scheme **真实 App Group / device transaction** 全路径 | **Accepted (narrow Exit)** | Human `2026-09-12 Asia/Shanghai`：**Accepted（narrow Exit）** — 保持现有 Pass-with-conditions 限度；不把全路径 App Group 真机交易证明当作 A34-R1 阻塞。详见 disposition note。 |
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
| **Closed（evidence）** | 17（E01–E13, E15, E18, E19） |
| **Closed（writeback）** | 1（E14 — S6 A34-R1 Closed narrow） |
| **Open — writeback path** | 0 |
| **Open — IQ** | 0 |
| **Accepted (narrow Exit)** | 3（E16, E17, E20） — Human `2026-09-12` |
| **Needs Human disposition** | 0 |
| **Out-of-scope** | 7（E21–E28）+ platform extract |

---

## 2. Residual disposition notes

> Human `2026-09-12 Asia/Shanghai` **Accepted（narrow Exit）** for E16/E17/E20（原 draft defaults）。**E15 Closed** via S5 IQ；**E14 Closed** via S6；**A34-R1 Closed（narrow）**。**不** Accept ADR。

| Residual | Status | Disposition | What remains |
|---|---|---|---|
| E14 writeback | **Closed（writeback）** | S6 A34-R1 **Closed（narrow）** | **不** Accept ADR；**不** Assignment Close |
| E15 IQ | **Closed（evidence）** | S5 IQ Pass with conditions — [`../reviews/scheme-delivery-wanxiang-p4-closure-001-s5-quality-review.md`](../reviews/scheme-delivery-wanxiang-p4-closure-001-s5-quality-review.md) | 无（直至 scope 变更）；残差见 IQ residuals |
| E16 升级失败回滚真机 | **Accepted (narrow Exit)** | Human accept draft：无升级失败回滚真机 | 无（直至另授权 Device） |
| E17 卸载失败回滚真机 | **Accepted (narrow Exit)** | Human accept draft：无卸载失败回滚真机 | 无（直至另授权 Device） |
| E20 App Group / device transaction | **Accepted (narrow Exit)** | Human accept：keep Pass-with-conditions | 无（直至另要求补证据） |
| Platform Assignment | **Active**（P3 Exit certified） | Stays Active；no Close | #101 / undraft-merge #102 / optional Close = separate auth |
| Push / merge | Not authorized | 本地 docs only | 是否 push（ask before push） |
| ADR 0034 Accept | Out-of-scope | 不在本片；leave #101 | 另授权 Accept |

---

## 3. Recommended next steps（Resume path）

1. ~~Human 对 E16 / E17 / E20 disposition~~ — **Done** `2026-09-12`（Accepted narrow Exit）。
2. ~~**S5**：Independent Quality closure delta~~ — **Done** `2026-09-12`（E15 Closed；Pass with conditions）。
3. ~~**S6**：A34-R1 disposition writeback~~ — **Done** `2026-09-12`（E14 Closed；A34-R1 Closed narrow；**仍不**改 ADR Status / **不** Accept ADR）。
4. **S3 Swift** 仅当核对发现具体生产缺口；**禁止**平台 mega-refactor 扩 scope。
5. 对外 **push/merge** 仍需 Human；**leave #101 alone**；no undraft/merge #102 without auth。

---

## 4. Explicit non-claims

- A34-R1 **Closed（narrow Wanxiang P4 Exit）** via S6；E14 Closed；E15 Closed via S5 — **不**宣称完整无条件 Wanxiang P4 / **不** Accept ADR
- E16/E17/E20 = Human **Accepted（narrow Exit）** — **不**等同 device evidence Closed；**不**等同 ADR Accept
- 不 Accept ADR 0034；leave #101 alone；不关闭 TD-011 / A34-R2 / RTRD-* / Recovery
- 不授权 TestFlight、完整 Product Gate、push/merge（除非 Human 另说）
- Platform Assignment P3 Exit certified **≠** Assignment Close；keep Platform Active

---

## 5. History

- `2026-09-09 Asia/Shanghai`：S2 narrow closure checklist 落盘；记录 Human **(b)**；E14 = writeback path；E15 IQ open；E16/E17/E20 = **needs Human disposition**（draft defaults 明确标注）。
- `2026-09-12 Asia/Shanghai`：Human **Resume** Wanxiang P4（Paused→Active）for A34-R1；**Accepted（narrow Exit）** for E16/E17/E20；freeze tip now `72b5987` / `codex/scheme-platform-001`；counts updated（Needs Human disposition → 0）；next S5 then S6；leave #101；**no** ADR Accept；Assignment Lifecycle **Active（Resumed）**。
- `2026-09-12 Asia/Shanghai`（**S5**）：Independent Quality **Pass with conditions** on freeze `72b5987`；**E15 → Closed（evidence）**；counts：Closed 17 / Open writeback 1（E14）/ Open IQ 0；A34-R1 still open until S6；leave #101；**no** ADR Accept；ask before push。
- `2026-09-12 Asia/Shanghai`（**S6**）：Human-authorized A34-R1 writeback — **E14 → Closed（writeback）**；**A34-R1 Closed（narrow）**；counts：Closed(evidence) 17 / Closed(writeback) 1 / Open writeback 0；leave #101；**no** ADR Accept；ask before push。
