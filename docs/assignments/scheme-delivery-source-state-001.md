# Assignment: SCHEME-DELIVERY-SOURCE-STATE-001

Policy version: 1.0.0

## Current Status

**2026-09-08 current increment:** Cross-scheme **CS-03–CS-08 plus CS-F1/CS-F3** landed **locally** (not pushed): identical-receipt idempotent no-op, inactive-uninstall peer-retain, active-uninstall Luna-only peer coverage, and named failure injections in `SchemaManagerTests` and `SchemeResourcePreparationCoexistenceTests`. Base tip before the matrix work: `944477a`. CS-01/02 already on branch (`2813428`). Human superseded peer-prefer B with Luna-only fallback.

Prior increment (still valid history): rollback double-failure repair passed full App/Keyboard tests and [independent delta review](../reviews/scheme-delivery-rollback-double-failure-delta-2026-09-08.md): P2 Closed. The Limited Gate below describes prior revisions only.

| Field | Value |
|---|---|
| Lifecycle | Active |
| Current Phase | Cross-scheme matrix: **CS-01/02 done** (committed `2813428`); **CS-03/04 done locally** (identical no-op + peer retain / Wanxiang identity-change upgrade path; eng `cb06a08`); **CS-05/06 done locally** (inactive uninstall retains active peer and does not force Luna); **CS-07/08 done locally** (active uninstall always deploys Luna before target removal); **CS-F1/CS-F3 done locally** (named dual-scheme deployment and staging failures preserve peer/selection/receipt boundaries). Existing P4 production transaction is reused; this slice adds dual-scheme evidence. Isolation checkout: `/private/tmp/uk-scheme-delivery-fix` on `codex/scheme-delivery-fix`. PR #100 remains **draft**. Wanxiang P4 / ADR 0034 Proposed / TestFlight 仍开放 |
| Material non-claims | No push of local matrix work unless Human authorizes; no TestFlight/App Release; no full Product Gate Passed; no Device-attested upgrade; no ADR 0034 acceptance; no undraft/merge of PR #100; no Wanxiang P4 closure; no peer-prefer fallback B; no Recovery persistence |
| Next handoff / decision | **Independent review pending.** Then pause for separately authorized CS-09/10, device evidence, PR #100 undraft/merge, TestFlight, App Release or ADR Accept. |
| Residuals | CS-09/10 not started; CS-F1/CS-F3 have Ice-target coverage only; CS-F3 尚未把生产 `SchemaManager` 的 selection 保持断言与真实 installer 的 mid-move failure 合并证明；真机失败回滚未测（Limited Gate 历史）；无 Device-attested；Wanxiang P4 未全闭合；Ice Lua `dofile` 动态引用未闭合；backup/staging cleanup 仍 best-effort |

## Authority and scope

### 2026-09-08 Wanxiang exact-hash Lua ownership tests

Human authorized unit tests + evidence for pinned CNB Wanxiang 17.5.9 Lua exact-ownership staging (`WanxiangLuaOwnership` + `matchingWanxiangLuaPaths`). Evidence: [`scheme-delivery-wanxiang-lua-ownership-2026-09-08.md`](../evidence/scheme-delivery-wanxiang-lua-ownership-2026-09-08.md). Tests live in `SchemeResourcePreparationCoexistenceTests`. **Exact-hash staging slice recorded; not a full Wanxiang P4 close.** Does not claim Product Gate extension of the post-rollback revision, Wanxiang P4 closure, upgrade rollback, ADR 0034 Accept, or PR #100 undraft/merge/TestFlight.

## 2026-09-08 rollback double-failure follow-up

Human authorized Codex to repair a newly observed gap: failed rollback moves were ignored before deleting the staging root. This follow-up preserves the recovery checkpoint and reports incomplete rollback; the manager stops uninstall without redeploying the incomplete original tree. The prior limited gate remains historical evidence for its reviewed revision and does not accept this changed implementation. Fresh focused validation and review are required. Automatic recovery after restart and Wanxiang ownership/upgrade closure remain outside this bounded correction.

Human Product Owner / Assignment Authority approved the proposed source-pin, probe-classification and per-scheme failure fixes in the current conversation: “你的建议比较合理，继续吧” (2026-09-06 Asia/Shanghai).

Scope: repair mutable Rime Ice download artifact binding, distinguish unreachable sources from changed artifacts, record bounded per-source failures, bind error display/retry to stable scheme ID; regression tests and documentation. Main-App deployment ownership, archive/digest/staged checks, cancellation and commit lease remain intact. No unrelated product changes, automatic TestFlight, merge or device actions.

Governance baseline: KOS v0.7.0 advisory, Kit f7f4dad6750b59dc827c1366fcd276447b2820b2. Existing tasks remain pinned. This bounded Markdown Assignment is not added to advisory Envelope include; no invented historical authority fields.

## Responsibilities

- Domain Owner / Executor: Main App UI / current Codex executor.
- Environment Executor: current Codex executor, isolated clone and dedicated Simulator.
- UI worker: Ohm subagent, separate clone, per-scheme failure state only.
- Architecture Reviewer: independent read-only review subagent after implementation.
- Quality Reviewer: independent read-only review subagent after implementation.
- Human Dependency / Product Approver: Human Product Owner, physical-device download/switch-page retest and final merge acceptance.

## Gates

Inputs: user logs; current catalog/probe/UI; ADR 0001/0003/0006/0032; scheme management and diagnostic contracts; official dated artifacts.
Entry: explicit repair authorization, isolated baseline 4c9f424, proven HEAD length drift and unscoped UI failure.
Exit: exact source/digest/staged binding evidence; negative/fallback/cancel/UI regression tests; local strict CI-equivalent gates; independent review; human retest handoff.
Stop: unverified artifact origin, staged mismatch, unsafe fallback, source contract expansion, scope conflict or failed cleanup. Do not waive these to make tests green.
Handoff Target: Human Product Owner. Revalidate on artifact/pin, processing plan, schema identity, environment, evidence or scope change.

## Engineering handoff

[PR #100](https://github.com/shchnk1103/Universe-Keyboard/pull/100), [evidence](../evidence/scheme-delivery-source-state-001.md), [independent review](../reviews/scheme-delivery-source-state-001.md). Engineering completion is not Product acceptance or Closed; physical-device retest and merge/TestFlight authority remain with Human Product Owner.

## 2026-09-07 planning follow-up

Human Product Owner authorized planning only: “很好，开始做计划吧” (`2026-09-07 Asia/Shanghai`), after device logs showed `resource_preparation` failed following a successful dated 雾凇 install.

Scope of this slice: complete the coexistence/resource-ownership plan and a **Proposed** ADR; link them from this Assignment; keep facts, recommendations and pending decisions separate. Codex left an untracked draft in `/private/tmp/uk-scheme-delivery-fix` then exhausted quota; the current Grok session finished the planning documents only.

Non-scope: Swift/ObjC/resource edits; committing the uncommitted deployment-phase journal diagnostics; P0 reproduction; accepting ADR 0034; device recovery; merge; TestFlight. P0+ Executor is not appointed by this follow-up.

Planning outputs:

- [计划](../plans/scheme-resource-ownership-and-coexistence-plan.md)
- [ADR 0034 Proposed](../architecture/decisions/0034-multi-scheme-resource-ownership.md)

Planning Exit for this follow-up: those two documents plus this Assignment/Active Work/index linkage exist on `codex/scheme-delivery-fix`; ADR has the required governance sections. Independent Architecture review of the plan is still outstanding and is not inferred from document completeness. P0 was authorized separately and is recorded below.

## 2026-09-07 P0 reproduction

Human authorized P0: “授权P0复现”. Executor: current Grok session on `/private/tmp/uk-scheme-delivery-fix`.

Evidence: [`scheme-delivery-source-state-001-p0-2026-09-07.md`](../evidence/scheme-delivery-source-state-001-p0-2026-09-07.md).

P0 Exit: production Ice install plan overwrites Prelude `default.yaml`; with a prior builtin receipt, `RimeBuiltinResourceInstaller.install` throws `.byteCountMismatch` and does not restore official bytes. Wanxiang plan skips the file. Ice uninstall does not remove it. No-receipt redeploy restores official bytes.

## 2026-09-07 P1 inventory

Human: “先不上真机，继续下一步.” Executor: current Grok session.

Evidence: [`scheme-delivery-source-state-001-p1-2026-09-07.md`](../evidence/scheme-delivery-source-state-001-p1-2026-09-07.md).

P1 Exit (engineering): same-path different-bytes collision is only `default.yaml`; Ice/T9/`melt_eng` still import that file; Ice uninstall leaves `default.yaml`, `lua/**`, `opencc/**`. CNB Wanxiang zip verified; Lua paths do not collide with Ice; Wanxiang also `import_preset: default` but does not install its own `default.yaml`. Candidate A is not reference-closed.

Stop: do not accept ADR 0034; do not start P2 rewrite or recovery.

## 2026-09-07 P2 Ice preset

Human: “万象先继续跳过，政策统一禁止覆盖，继续下一步.”

Implementation: Ice `rime-ice-plan-2` / `rime-ice-post-2` copies bundled `default.yaml` to `rime_ice_preset.yaml`, rewrites Ice/T9/melt_eng/radical includes, skips installing `default.yaml`, and uninstalls Ice lua files + `lua/cold_word_drop` + `opencc/emoji*` without removing official OpenCC. Wanxiang still skips `default.yaml`.

Stop: no whole-directory `lua/` or `opencc/` deletion; no Wanxiang preset rewrite; no ADR Accepted.

## 2026-09-07 P3 bounded recovery

Human: “继续做 P3 有界恢复.”

Restore Prelude `default.yaml` from the already-validated builtin source only when the live file SHA matches the pinned Ice 2026.06.30 fingerprint. Unknown bytes still fail closed. Backup is discarded after a successful install. Does not rewrite on-disk Ice schemas; re-download Ice to get `rime_ice_preset.yaml`.

## 2026-09-07 Human device (P3 follow-up)

Human: “我已经重下了雾凇并确认能部署，并且可以切换LUNA也不报错，都可以正常输入。” 同日更早还有一次隔离工程 redeploy 不再报错的口头报告。

Evidence: [`scheme-delivery-source-state-001-p3-device-2026-09-07.md`](../evidence/scheme-delivery-source-state-001-p3-device-2026-09-07.md). Grade: **Human-attested**, not Device-attested (no binary UUID/SHA, no journal paste).

This does not accept ADR 0034, close P4, or authorize merge/TestFlight. Architecture review of ADR 0034 starts after this record.

## 2026-09-07 Codex takeover and P3 transaction correction

Human asked current Codex to take over Grok session `01a07b72-444a-7000-a7f2-49487a7f8469`. The Codex task API could not read that external session ID, so takeover reconstructed state from branch history, the current worktree and repository evidence. Grok's committed P0–P3 work through `b90d236` and its uncommitted Human-attested governance records were preserved.

Independent Architecture first review found P3 recovery outside the install mutation ledger and using a static backup path. Executor corrected the existing P3 implementation: known-pollution recovery now uses the current operation-scoped `.builtin-backup-<UUID>` root and is the first mutation in the same reverse rollback ledger. A later install failure therefore restores the exact pre-transaction polluted bytes; success and handled failure clean the operation backup root. A focused failure-injection test covers this sequence.

Architecture delta re-review closed those P1/P2 findings. It did not accept ADR 0034 and retained Wanxiang P4, dynamic Ice Lua references, best-effort cleanup observability and device-evidence limits as residuals.

Independent Quality then found one P1: a present-but-unreadable builtin resource receipt was treated as absent. Executor changed receipt loading to fail before any runtime mutation, added deterministic unreadable-receipt coverage, strengthened real-archive reference-closure assertions, and added the combined pollution-recovery/partial-overlay rollback matrix. Full local gates passed. Delta-review tasks completed without returning retrievable conclusion text, so formal Quality remains pending rather than inferred from task status.

## 2026-09-07 P4 active uninstall fail-closed

Human authorized the active-scheme uninstall contract: switch to builtin `luna_pinyin` without treating deferred deploy as success; await successful Luna deployment before removing target files; then stage → commit scheme files (rollback on failure); any failure keeps the original scheme selection and files.

Engineering: `SchemaManager.uninstallSchema` acquires the commit lease, deploys Luna under that lease when the target is active, stages removals, and only then commits. Restore redeploy runs before lease release. Unit coverage includes active success, Luna deploy failure, staging failure, and non-active uninstall. ADR 0034 remains Proposed. Wanxiang upgrade/uninstall and device Product Gate are not closed by this slice.

## 2026-09-07 Human device (P4 active uninstall)

Human Product Owner observed active Ice uninstall: first switches to Luna; no error; Luna input works after; Settings shows Ice as 未安装. Failure rollback was **not** tested.

Evidence: [`scheme-delivery-source-state-001-p4-device-2026-09-07.md`](../evidence/scheme-delivery-source-state-001-p4-device-2026-09-07.md). Grade: **Human-attested ONLY** — not Device-attested, not Product Gate Passed, not ADR Accepted, not merge/TestFlight.

Engineering HEAD at report: `afa0c0ef8caca04579f8f0dfa1b1122110463557` (P4 `e213a25`; CI fixes `eed453d`, `afa0c0e`; CI green).

## 2026-09-07 Independent Quality (P4 + prior residual)

Independent Quality review of freeze `18f0d07`: [`scheme-delivery-source-state-001-p4-quality-review.md`](../reviews/scheme-delivery-source-state-001-p4-quality-review.md).

- P4 active uninstall fail-closed: **Pass with conditions**（P0=0 · P1=0 · P2=1 · P3=4）。
- Prior unreadable-receipt Quality pending: **closed (Pass)** on code+test evidence at tip.
- Non-claims: not ADR Accepted, not Product Gate, not merge/TestFlight, not Wanxiang P4 closure.

## 2026-09-07 Executor remediation — Q-P2-01

Human authorized closing Quality finding Q-P2-01. Executor added `testIceUninstallStagingMidMoveFailureRestoresOwnedFiles` (FileManager Nth-`moveItem` seam into production `stageSchemaUninstall`; fail-closed restore asserted). Docs note only in the P4 Quality review; Verdict not rewritten. No ADR Accept / Product Gate / merge / Wanxiang.

## 2026-09-07 Independent Quality delta — Q-P2-01 Closed

Independent Quality delta of freeze `0315908`: [`scheme-delivery-source-state-001-p4-quality-rereview-qp201.md`](../reviews/scheme-delivery-source-state-001-p4-quality-rereview-qp201.md). **Q-P2-01 Closed**（P2 residual: 0）。原 P4 Pass with conditions 未整体改写。Non-claims: not ADR Accepted, not Product Gate, not Assignment Closed, not merge/TestFlight.

## 2026-09-08 Limited P4 Product Gate

Human Product Owner (`2026-09-08 Asia/Shanghai`): 「有限 Product Gate：接受自动化覆盖失败回滚，仍不合」.

Evidence: [`scheme-delivery-source-state-001-p4-product-gate-2026-09-08.md`](../evidence/scheme-delivery-source-state-001-p4-product-gate-2026-09-08.md).

**Grade:** **Limited Product Gate Passed (automation-backed failure rollback)** — **not** full Product Gate / **not** Device-attested.

Accepted: device failure-rollback remains untested; residual risk for this slice relies on automation (unit tests + Q-P2-01 mid-move injection at `0315908` + CI) plus the already-recorded Human-attested success path ([`p4-device`](../evidence/scheme-delivery-source-state-001-p4-device-2026-09-07.md)). Quality inputs: `372ad8c` / `bf9de51` / `0315908`.

**Explicitly not authorized:** undraft PR #100, merge, TestFlight, App Release, ADR 0034 Accepted, Wanxiang P4 closure, Device-attested evidence upgrade.
