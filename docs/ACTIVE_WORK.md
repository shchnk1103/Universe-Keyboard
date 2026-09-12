# Active Work Summary

Current SCHEME-DELIVERY increment: `2026-09-08` rollback double-failure repair passed App/Keyboard tests and independent delta review (P2 Closed); prior Limited Product Gate does not automatically accept this increment. See the Assignment's current-increment note.

> **KOS 2.1 ops · M-05**
> Cap: **≤ 10** items.
> **Lifecycle Source of Truth = Assignment Record** (not this file, not Dashboard).
> This page only **links** and restates **Current Status** fields.

Status snapshot (existing rows): `2026-09-09 Asia/Shanghai` — PR #100 tip includes docs sync `a007681` (engineering tip `33b35d3`); Human authorized **undraft+merge after docs sync + hosted CI green**. `SCHEME-DELIVERY-SOURCE-STATE-001` matrix slices remain on branch with prior reviews. Runtime-route DEVICE Assignment recorded functional CS09-10-02 Pass with conditions; `RTRD-01`/`RTRD-02` stay out of this PR / not closed by merge. Luna-only active-uninstall policy supersedes peer-prefer B. Limited P4 Gate remains historical. 产品 Active Work 仍以本表计数为准。KOS-UPGRADE-UK-003 Closed 仍以 Assignment 为准。

Current update: `2026-09-09 Asia/Shanghai` — Runtime-route CONTRACT reviewed；INTEGRATION P1 已复审；DEVICE 真机功能 Pass with conditions；docs tip `a007681`；Human 已授权 hosted CI 全绿后 undraft+merge PR #100。`RTRD-01`/`RTRD-02` 仍 out of PR / 不因 merge 关闭。Product Gate / TestFlight / Release / ADR Accept 仍未授权。

Current update: `2026-09-10 Asia/Shanghai` — PR [#109](https://github.com/shchnk1103/Universe-Keyboard/pull/109) merged `0fd3518`（SUG-07 preflight，无卸载）；PR [#110](https://github.com/shchnk1103/Universe-Keyboard/pull/110) merged `4e4164f`（RTRD-01 诊断 UI）。本 M-02 将 `KOS-SUG-OBS-DEVICE-001` 与 `SCHEME-DELIVERY-RUNTIME-ROUTE-DIAGNOSTICS-UI-001` 标为 Closed 并从本表移除。`SCHEME-DELIVERY-RUNTIME-ROUTE-DEVICE-001` 仍 Active（`RTRD-02` open）。无卸载、无 SUG-08、无 Product Gate / TestFlight / Release。

Current update: `2026-09-11 Asia/Shanghai` — Human 关闭 [`SCHEME-DELIVERY-RUNTIME-ROUTE-DEVICE-001`](assignments/scheme-delivery-runtime-route-device-001.md)（工程 Close；非 Product Gate）。本表移除第 8 行。无 TestFlight / Release。

Current update: `2026-09-11 Asia/Shanghai` — Human 批准补录 [`RIME-DEPLOY-INTERRUPT-RECOVER-001`](assignments/rime-deploy-interrupt-recover-001.md)（PR [#115](https://github.com/shchnk1103/Universe-Keyboard/pull/115) `805f6ce`）。本表加为第 8 行。独立 Quality 审查尚未授权启动。无 merge / TestFlight / TD-018 实现。

Current update: `2026-09-11 Asia/Shanghai` — Independent Quality **Pass with conditions** on `805f6ce`（[`review`](reviews/rime-deploy-interrupt-recover-001-quality-review.md)）。残差 `RDIR-01` accept / `RDIR-02` TD-018 / `RDIR-03` accept。无 merge。

Current update: `2026-09-11 Asia/Shanghai` — PR [#115](https://github.com/shchnk1103/Universe-Keyboard/pull/115) merged `5bd7499`（tip `edd3462`）。工程 merge，非 Product Gate / TestFlight / Assignment Close。TD-018 仍开放。

Current update: `2026-09-11 Asia/Shanghai` — Human 关闭 [`RIME-DEPLOY-INTERRUPT-RECOVER-001`](assignments/rime-deploy-interrupt-recover-001.md)（工程 Close；非 Product Gate）。本表移除第 8 行。TD-018 仍开放。无 TestFlight / Release。

Current update: `2026-09-11 Asia/Shanghai` — Human 授权 [`GIT-BRANCH-ARCHIVE-HYGIENE-001`](assignments/git-branch-archive-hygiene-001.md) **Group A only**（tag 后删三个已关闭/被替代分支）。本表加为第 8 行。无 Group B；无 #101/#102；无 merge。

Current update: `2026-09-11 Asia/Shanghai` — PR [#118](https://github.com/shchnk1103/Universe-Keyboard/pull/118) merged `bb15b27`。本 M-02 将 `GIT-BRANCH-ARCHIVE-HYGIENE-001` 标为 Closed 并从本表移除。Human 授权 Group B **只 tag 不删**，本表加 [`GIT-BRANCH-ARCHIVE-HYGIENE-002`](assignments/git-branch-archive-hygiene-002.md) 为第 8 行。无 Group B delete；无 #101/#102 merge。

Current update: `2026-09-11 Asia/Shanghai` — PR [#119](https://github.com/shchnk1103/Universe-Keyboard/pull/119) merged `bf0e6ec`。本 M-02 将 `GIT-BRANCH-ARCHIVE-HYGIENE-002` 标为 Closed 并从本表移除。KOS keep 决定：三条 Group B 本地分支名全部保留。本表加 [`GIT-BRANCH-ARCHIVE-HYGIENE-003`](assignments/git-branch-archive-hygiene-003.md) 为第 8 行。无 delete；无 #101/#102。

Current update: `2026-09-12 Asia/Shanghai` — PR [#120](https://github.com/shchnk1103/Universe-Keyboard/pull/120) merged `04e2240`。Human 授权 Close [`GIT-BRANCH-ARCHIVE-HYGIENE-003`](assignments/git-branch-archive-hygiene-003.md) 并 Archived parked-branch 计划。本表移除第 8 行。无 Group B delete；无 TestFlight / Release。

Current update: `2026-09-12 Asia/Shanghai` — Human 真机目视 Pass [`RIME-SCHEME-DETAIL-PROVENANCE-SHEET-001`](assignments/rime-scheme-detail-provenance-sheet-001.md)；PR [#122](https://github.com/shchnk1103/Universe-Keyboard/pull/122) 已开。本表加为第 8 行。无 merge；不并入 #102。

Current update: `2026-09-12 Asia/Shanghai` — PR [#122](https://github.com/shchnk1103/Universe-Keyboard/pull/122) merged `2203c9d`。本 M-02 将 `RIME-SCHEME-DETAIL-PROVENANCE-SHEET-001` 标为 Closed 并从本表移除。无 Product Gate / TestFlight / Release。

Current update: `2026-09-12 Asia/Shanghai` — Scheme Platform **P1-6 on draft #102** tip `39e4f92`：P1 summary + Independent Quality **Pass with conditions**（freeze `3cfa355`）。Re-merged `origin/main`（#122 provenance-sheet Closed）— ACTIVE_WORK 保留 Platform 为第 8 行。keep Active；next **P2 awaiting auth**；no ADR Accept。

Current update: `2026-09-12 Asia/Shanghai` — Scheme Platform **P2 landed locally** on `codex/scheme-platform-001`：Wanxiang SharedDefault `consumePrelude` → Ice-shaped `privatePreset`（`wanxiang_preset.yaml`）；ownership stays `exactHash`；staged identity `wanxiang-17.5.9-plan2-post2` / plan `wanxiang-plan-2` / post `wanxiang-post-2`。**Local commit only**；**ask before push**；keep Active；next after push = CI / product regression note。无 Wanxiang nine-key；无 Discovery UI；无 ADR Accept；无 #101；无 Assignment Close。

Current update: `2026-09-12 Asia/Shanghai` — Scheme Platform **SP-P1-IQ-01 closed**（KOS residual writeback）on draft #102 tip `cd4fa65` base + pending docs tip：freeze `3cfa355` run `34628171114` success；`cd4fa65` run `34629774209` full green / MERGEABLE CLEAN。keep Active；next **P2 awaiting auth**；no ADR Accept；no undraft/merge #102。

Current update: `2026-09-12 Asia/Shanghai` — Scheme Platform **P2 Done** tip `7c93904`（hosted CI run `34672873379` full green；Simulator product smoke Pass）+ **P3 started**：plan [`scheme-platform-p3-fork-cleanup-2026-09-12.md`](plans/scheme-platform-p3-fork-cleanup-2026-09-12.md)；DELETE `downloadState` rename + registry `postProcessingRevision` + `SchemePostExtractHooks`；KEEP list written。keep Active；**ask before push**；next finish P3；no ADR Accept；no Assignment Close；leave #101；no undraft/merge #102；no Wanxiang nine-key；no Discovery UI。

Current update: `2026-09-12 Asia/Shanghai` — Scheme Platform **P3 Exit certified** by Human on tip `a0d3481`（plan DELETE+KEEP；smoke A–D Pass；hosted CI green）。**Lifecycle remains Active** — **no Assignment Close**。P3 Exit Criteria met；may stay Active for post-platform follow-ups。Awaiting Human on A34-R1 revisit / #101 / undraft-merge #102 / optional Close（all separate auth）。无 ADR Accept；leave #101；keep #101≠#102；无 Wanxiang nine-key；无 Discovery UI。

Current update: `2026-09-12 Asia/Shanghai` — **Resume** Wanxiang P4 for A34-R1；Human **E16/E17/E20 Accepted（narrow Exit）**；freeze tip `72b5987` on `codex/scheme-platform-001`；next **S5** IQ then **S6** A34-R1 writeback；leave #101；**no** ADR Accept；**no** undraft/merge #102；platform Assignment stays **Active**（P3 Exit certified；no Close）。Local docs only；ask before push。

Current update: `2026-09-12 Asia/Shanghai` — Wanxiang P4 **S5 Independent Quality** landed — [`reviews/scheme-delivery-wanxiang-p4-closure-001-s5-quality-review.md`](reviews/scheme-delivery-wanxiang-p4-closure-001-s5-quality-review.md) **Pass with conditions** on freeze `72b5987`；**E15 Closed**；hosted CI run `34676751887` attempt 2 full green（attempt 1 flake residual accept）。Next **S6** A34-R1 writeback **awaiting Human**；A34-R1 / E14 still open；leave #101；**no** ADR Accept；platform stays **Active**（no Close）；Wanxiang P4 stays **Active**；local docs only；ask before push。

Current update: `2026-09-12 Asia/Shanghai` — Wanxiang P4 **S6 A34-R1 writeback** — residual **A34-R1 Closed（narrow Wanxiang P4 Exit）**；**E14 Closed**；cite S5 IQ Pass with conditions + Human E16/E17/E20 narrow + freeze `72b5987` / S5 tip `6f29f64`。ADR 0034 **still Proposed**；leave #101；**no** Accept；platform stays **Active**（no Close）；Wanxiang P4 stays **Active**（Human may Close Assignment later — not authorized now）；local docs only；ask before push。

Current update: `2026-09-12 Asia/Shanghai` — Human-authorized **Close** [`SCHEME-DELIVERY-WANXIANG-P4-CLOSURE-001`](assignments/scheme-delivery-wanxiang-p4-closure-001.md) （narrow A34-R1 Exit met）。本表移除第 9 行 Wanxiang P4。Platform row 8：Wanxiang P4 now **Closed**；still **no** ADR Accept；leave #101；platform stays **Active**（P3 Exit certified；no Close）。**Close ≠ ADR Accept**；**no** undraft/merge #101/#102；local docs only；**no push**。

Current update: `2026-09-12 Asia/Shanghai` — PR [#102](https://github.com/shchnk1103/Universe-Keyboard/pull/102) merged `a6fc6f0`（tip before merge `92a0d0b`）。**Engineering merge ≠ Product Gate / TestFlight / ADR Accept / Platform Close**。Platform Assignment stays **Active**；leave #101；**A34-R1 remains Closed（narrow）**。Human may later #101 Accept prep / Platform Close / Accept ADR（**separate auth**）。无 TF；无 Swift this slice。


| # | Work Item | Lifecycle (from Assignment) | Phase / next | Assignment |
|---|---|---|---|---|
| 1 | RELEASE-2026-08-01 | Active | Human 已创建 Build 7 内部组并邀请两名 tester；Task11 F-01/F-02 仍 Pending。F-03 工程片已随 #83 合入 `main`，TestFlight tester 仍在 Build 7（不含该修复）。04/TD-003/004/005 仍需不同/稳定采集环境 | [`assignment`](assignments/release-2026-08-01.md) · [`Task11`](assignments/release-2026-08-01-11-internal-testflight-feedback.md) · [`feedback`](evidence/release-2026-08-01-11-internal-testflight-feedback-2026-08-25.md) · [`04 Assignment`](assignments/release-2026-08-01-04-device-performance.md) |
| 2 | RIME-BUILTIN-LUNA-QUALITY-001 | Active | PR [#98](https://github.com/shchnk1103/Universe-Keyboard/pull/98) merged `f352f50`。本片收工；Executor 无下一动作。无 Exit / TestFlight / Release | [`assignment`](assignments/rime-builtin-luna-quality-001.md) · [`Gate-98`](product-decisions/RIME-BUILTIN-LUNA-QUALITY-001-product-gate-98.md) |
| 3 | TYPING-INTELLIGENCE-001 | Active | 自动化验证完成；真机 / 无障碍 / 外观门未关 | [`assignments/typing-intelligence-001.md`](assignments/typing-intelligence-001.md) |
| 4 | TYPO-CORRECTION-002 | Active | Contextual recovery；指定 Simulator 场景 pending | [`assignments/typo-correction-002.md`](assignments/typo-correction-002.md) |
| 5 | RIME-SYNC-001 | Active | Run 02 单事务完成；正式 `INVALID` 审计结果保留，Human Product Owner 接受工程结论并决定暂不重测。仅在复发或路径实质变更时重开；旧轮次精确错误、`TD-002` pending | [`assignment`](assignments/rime-sync-001.md) · [`diagnostics`](assignments/rime-sync-diagnostics-v1-001.md) · [`Product Review`](product-decisions/RIME-SYNC-DIAGNOSTICS-V1-001-product-gate.md) · [`Run 01`](evidence/rime-background-sync-natural-device-run-2026-08-31.md) · [`Run 02`](evidence/rime-background-sync-natural-device-run-2026-09-01-r2.md) |
| 6 | SCHEME-DELIVERY-SOURCE-STATE-001 | Active | Tip includes docs sync **`a007681`** (engineering `33b35d3`) on PR #100; Human authorized **undraft+merge after docs sync + hosted CI green**. Matrix CS-01–CS-10 / CS-F* / CSF-PAIR / CS09-10-01 on branch with prior IQ. Runtime-route device evidence supersedes historical CS09-10-02 no-candidate failure for functional candidate-input. `RTRD-01`/`RTRD-02` out of this PR / not closed by merge; no TestFlight/ADR Accept/Product Gate Passed; checkout `/private/tmp/uk-scheme-delivery-fix` | [`assignment`](assignments/scheme-delivery-source-state-001.md) · [`CS09-10-02 device evidence`](evidence/scheme-delivery-cross-scheme-cs09-cs10-device-2026-09-08.md) · [`route proposal`](plans/scheme-delivery-active-uninstall-runtime-route-reconciliation-2026-09-08.md) · [`CS09-10-01 evidence`](evidence/scheme-delivery-cross-scheme-cs09-cs10-inventory-2026-09-08.md) · [`CS09-10-01 review`](reviews/scheme-delivery-cross-scheme-cs09-cs10-inventory-2026-09-08.md) · [`CSF pair evidence`](evidence/scheme-delivery-cross-scheme-csf-pair-2026-09-08.md) · [`CSF pair review`](reviews/scheme-delivery-cross-scheme-csf-pair-2026-09-08.md) · [`CS-09/10 evidence`](evidence/scheme-delivery-cross-scheme-cs09-cs10-2026-09-08.md) · [`CS-09/10 review`](reviews/scheme-delivery-cross-scheme-cs09-cs10-2026-09-08.md) · [`CS-F1/F3 review`](reviews/scheme-delivery-cross-scheme-csf1-csf3-2026-09-08.md) · [`matrix contract`](plans/scheme-delivery-cross-scheme-matrix-contract-2026-09-08.md) · [`p4-remaining`](plans/scheme-delivery-p4-remaining-matrix-2026-09-08.md) · [`Limited PG`](evidence/scheme-delivery-source-state-001-p4-product-gate-2026-09-08.md) · [`ADR 0034`](architecture/decisions/0034-multi-scheme-resource-ownership.md) · [PR #100](https://github.com/shchnk1103/Universe-Keyboard/pull/100) |

| 7 | SCHEME-DELIVERY-RUNTIME-ROUTE-INTEGRATION-001 | Active | P1 已通过最终独立复审；DEVICE-001 **Closed**（功能 Pass with conditions；RTRD-01 glanced；RTRD-02 accept）。不因 DEVICE Close 关闭本 Assignment / Release。 | [`assignment`](assignments/scheme-delivery-runtime-route-integration-001.md) · [`P1 final review`](reviews/scheme-delivery-runtime-route-integration-001-p1-final-independent-review.md) |
| 8 | SCHEME-DELIVERY-SCHEME-PLATFORM-001 | **Active** | **merged via #102** `a6fc6f0`（tip before merge `92a0d0b`）— **keep Active**；**no Assignment Close**。Engineering merge ≠ Product Gate / TF / ADR Accept / Platform Close。Wanxiang P4 **Closed**；**A34-R1 Closed（narrow）** remains Closed；still **no** ADR Accept。leave draft #101；keep #101≠#102。Next：Human may #101 Accept prep / Platform Close / Accept ADR（**separate**）。无 TF；无 Wanxiang nine-key；无 Discovery UI。 | [`assignment`](assignments/scheme-delivery-scheme-platform-001.md) · [`P3 plan`](plans/scheme-platform-p3-fork-cleanup-2026-09-12.md) · [`P1 summary`](plans/scheme-platform-p1-summary-2026-09-12.md) · [`P1 IQ`](reviews/scheme-delivery-scheme-platform-001-p1-quality-review.md) · [`KOS runbook`](plans/scheme-platform-execution-kos-2026-09-09.md) · [`Wanxiang P4 Close`](evidence/scheme-delivery-wanxiang-p4-closure-close-2026-09-12.md) · [`A34-R1 writeback`](evidence/scheme-delivery-wanxiang-p4-a34-r1-writeback-2026-09-12.md) · [PR #102](https://github.com/shchnk1103/Universe-Keyboard/pull/102) |

历史工作从 [Assignment 目录](assignments/) 查找；债务从 [TECH_DEBT](TECH_DEBT.md) 查找。
这里只保留 Ready / Active 工作，上限十项；Assignment 是生命周期事实来源，冲突时修正本镜像。
