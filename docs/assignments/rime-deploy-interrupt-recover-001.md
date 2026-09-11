# Assignment: RIME-DEPLOY-INTERRUPT-RECOVER-001 — 部署中断后可取消并重试

**Policy version:** `1.0.0`

**Repository Change Type:** `Implementation` + `Documentation` + `State`

This record is a **backfill**. Implementation, Human-attested smoke, commit, push, PR, merge and engineering Close already happened under Human Product Owner authorization in session. It does **not** rewrite that history as `Ready` before code existed. PR [#115](https://github.com/shchnk1103/Universe-Keyboard/pull/115) is merged to `main` (`5bd7499`). TestFlight and Product Gate remain unauthorized.

KOS 2.2 optional contracts (E-01, A-01/B-01, P-01, D-01) are **not** opted in.

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Closed |
| Current Phase | Human closed this Assignment as engineering complete. PR [#115](https://github.com/shchnk1103/Universe-Keyboard/pull/115) merged `5bd7499`; Independent Quality **Pass with conditions**; Architecture `Not Applicable` |
| Material non-claims | Not Product Gate / TestFlight / Release; not Device-attested; not TD-018 implementation; Close is not Product Gate |
| Next handoff / decision | None for this Assignment. TD-018 remains a separate later slice |
| Residuals | `RDIR-01` `accept` · `RDIR-02` `tech_debt:TD-018` · `RDIR-03` `accept` — see Quality review M-03 table |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner in-session authorization “批准写 Assignment”, `2026-09-11 Asia/Shanghai`, after prior authorizations to diagnose, implement slice A, commit, push and open PR #115
- **Product Approver:** Human Product Owner acting as Product Lead

## Boundary

- **Scope:**
  1. Record the already-landed main-App deployment-state recovery: leftover `rime_deploying` with no live task becomes `.failed` with retry; in-progress deploy can be cancelled; cancelled outcomes must not overwrite a later retry.
  2. Name remaining gates for PR [#115](https://github.com/shchnk1103/Universe-Keyboard/pull/115) on branch `fix/rime-deploy-interrupted-recover`.
  3. Keep CS-05 inactive-uninstall routing unchanged (Wanxiang stays effective; no Luna fallback).
- **Non-goals:** merge or undraft-equivalent merge authority; TestFlight; App Release; Product Gate; TD-018 foreground auto-deploy after inactive uninstall; Scheme Platform / draft #102; ADR 0034 Accept; starting independent review in this Assignment-writing slice.
- **Required Inputs:** ADR 0001; CS-05 inactive uninstall contract; PR #115 / commit `805f6ce`; Human-attested overlay-install notes from `2026-09-11 Asia/Shanghai`; [`TD-018`](../TECH_DEBT.md#td-018-foreground-auto-deploy-after-inactive-scheme-uninstall).

## Assignment

- **Domain Owner:** Main App UI — RIME settings deployment orchestration.
- **Executor:** The Grok session that implemented `805f6ce` (worktree `/Users/doubleshy0n/Dev/uk-rime-deploy-recover`). That session **must not** act as Quality Reviewer.
- **Environment Executor:** Same session for already-run local Store tests; GitHub Actions for hosted CI on PR #115. Physical-device overlay install was Human-operated.
- **Human Dependency:** Human Product Owner — already provided overlay-install smoke; later merge/TestFlight decisions remain Human-only.
- **Architecture Reviewer:** `Not Applicable — no architecture boundary, Accepted ADR, or CS-05 routing change; the slice implements ADR 0001 follow-up that deployment status stay actionable.`
- **Quality Reviewer:** Independent Quality, Performance & Release Maintainer runtime that **did not** author `805f6ce`. Executor self-check is not this review.
- **Product Approver:** Human Product Owner.

## Gates

- **Entry Criteria (historical, already met):** Human authorized diagnosis then slice-A implementation; local `swift-format lint --strict` on changed Swift; three new `RimeSettingsStoreTests` on iPhone 17 Pro / iOS 26.0; Human-attested overlay install recovered `.failed` with retry.
- **Entry Criteria (current remaining phase):** This Assignment exists with named Quality Reviewer and justified Architecture `Not Applicable`; review SHA is `805f6ce` until a new tip is pushed.
- **Exit Criteria:** Independent Quality conclusion of Pass, or Pass with conditions with residual disposition (`fix` / `accept` / `tech_debt:<ID>`); hosted CI full path green on the **same** head as that review; Human merge decision is a **later** authorization, not an Exit of this writing slice.
- **Stop Conditions:** Reviewer independence missing; CS-05 or ADR 0034 scope expansion; merge/TestFlight requested without a new Human authorization; CI failure followed by a new commit without rebinding Quality review to the new head.

## Handoff

- **Handoff Target:** None. TD-018 remains a separate later slice.
- **Revalidation Trigger:** New commits on the PR; change to cancel/interrupt persistence semantics; TD-018 implementation mixed into this PR; Architecture `Not Applicable` disputed.

## History

- `2026-09-11 Asia/Shanghai`: Human reported stuck 「正在部署…」 after inactive Ice uninstall while Wanxiang was active; journal had `runtime_route` `before/inactive/staging/commit` with `commit/succeeded` and schema `wanxiang`. No `uninstallRoute` / `deployRimeConfig` Logger lines in v1 journal (expected).
- Same day: Human authorized diagnosis-only, then implementation of latch recovery + in-progress cancel (slice A). Foreground auto-deploy after uninstall deferred.
- Same day: Human-attested overlay install — first launch showed deploy failed with retry/cancel/reset; manual deploy succeeded. Later inactive Ice uninstall did not auto-start deploy in the foreground; manual deploy succeeded. Recorded as TD-018.
- Same day: Human authorized slice-A commit (`805f6ce`), then push and PR #115. No merge authorization.
- Same day: Human authorized this Assignment backfill only. Independent Quality review was **not** started by this authorization.
- Same day: Human reported hosted CI all-green on `805f6ce` and authorized independent Quality review. Independent Quality runtime (not the implementing executor) recorded **Pass with conditions** in [`rime-deploy-interrupt-recover-001-quality-review.md`](../reviews/rime-deploy-interrupt-recover-001-quality-review.md). Residuals `RDIR-01` accept, `RDIR-02` tech_debt:TD-018, `RDIR-03` accept. Merge not authorized.
- Same day: Human authorized push of the review record, then merge after hosted CI green on the new tip. Tip `edd3462` CI green; PR #115 merged `5bd7499`. `edd3462` is reachable from `origin/main`. Not Product Gate / TestFlight / Assignment Close.
- Same day: Human authorized “请你先检查一下本Assignment是否可关闭，如果可以就关闭”. Exit met: Quality Pass with conditions and M-03 residuals all disposed; hosted CI green on merge tip `edd3462`; implementation on `main`. Engineering Close. Not Product Gate / TestFlight / Device-attested / TD-018.
