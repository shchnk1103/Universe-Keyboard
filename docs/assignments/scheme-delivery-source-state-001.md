# Assignment: SCHEME-DELIVERY-SOURCE-STATE-001

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Active |
| Current Phase | P4 活跃方案卸载 fail-closed 工程切片已实现（本地未推送）。Quality 与 Wanxiang P4 / 升级合同仍待完成，ADR 0034 仍 Proposed |
| Material non-claims | No TestFlight/App Release, no device acceptance, no disabled integrity check, no ADR 0034 acceptance, no device-unique root-cause claim, no Device-attested payload identity |
| Next handoff / decision | Independent Quality review；Human 已冻结活跃卸载回退合同（Luna 部署成功后再删文件，失败保留原方案）。Wanxiang 升级/卸载与 PR #100 merge / TestFlight 仍单独授权 |
| Residuals | 真机未发出 `InstallationError`；无 App/Extension UUID·SHA；无万象复测；Wanxiang P4 升级/卸载未闭合；Ice Lua `dofile` 动态引用未闭合；backup cleanup 仍 best-effort；活跃卸载尚未真机 Product Gate |

## Authority and scope

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
