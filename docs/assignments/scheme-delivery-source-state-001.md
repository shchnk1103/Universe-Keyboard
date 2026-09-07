# Assignment: SCHEME-DELIVERY-SOURCE-STATE-001

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Active |
| Current Phase | P2 雾凇独立预设实现中/已落地：禁止覆盖共享 default.yaml；万象继续 skip。ADR 0034 仍 Proposed |
| Material non-claims | No TestFlight/App Release, no device acceptance, no disabled integrity check, no ADR 0034 acceptance, no device-unique root-cause claim |
| Next handoff / decision | Human 用隔离工程复测雾凇下载+部署；Architecture 评审 ADR 0034。PR #100 merge 仍单独授权 |
| Residuals | 真机未发出 `InstallationError`；Ice Lua `dofile` 动态引用未闭合 |

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

Stop: no whole-directory `lua/` or `opencc/` deletion; no Wanxiang preset rewrite; no ADR Accepted; no device recovery of already-polluted phones (P3).
