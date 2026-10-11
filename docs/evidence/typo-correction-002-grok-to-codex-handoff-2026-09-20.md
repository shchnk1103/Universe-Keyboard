# Handoff: TYPO-CORRECTION-002 — Grok → Codex

Prepared by: Grok (Coordinator)
Handoff target: Codex
Date: `2026-09-20T23:39:00+08:00` Asia/Shanghai
Human Product Owner instruction: write this handoff so Codex can continue the related work.

Conversation is not repository truth. Use the bound files below.

This handoff does **not** authorize capture, Swift change, commit, push, PR,
merge, Gate close or parent Close. Codex must stop and ask the Human before
any of those.

## 1. User goal and non-goals

**Goal.** Make contextual multi-error recovery actually useful: after typing
`wimenjintianquhongyuan`, the operator should be able to see and select
`我们今天去公园` on the designated Simulator, without unbounded search or a
local/cloud model.

**Human feedback this session.** Several days of KOS evidence work produced
little usable product signal. The Human does not want another identical
QA-001 typing run. They asked for a plain account of what happened, then
asked Codex to continue from a written handoff.

**Non-goals (still in force).**

- Do not retry the same 22-letter phrase on the same installed package.
- Do not infer a Product failure solely from the Human not seeing the target.
- Do not close parent `TYPO-CORRECTION-002` or child recall Assignment.
- Do not treat INT-003 cadence or paired-performance retries as the next
  product step.
- Do not wire preflight `60/64/8` into production without a new Product
  Decision and Authorization.
- No FakeCandidateProvider, old Ice directory, `typeText`, pasteboard,
  host injection or synthetic RIME fixture as a substitute for real recovery.

## 2. Where to work

| Item | Value |
|---|---|
| Isolation worktree (current evidence) | `/private/tmp/universe-keyboard-typo-correction-002-parent-revalidation-003` |
| Branch | `codex/typo-correction-002-parent-revalidation-003` |
| Documentation HEAD | `0d6638fabdc6b3db8164b881464a9f96f16c8dce` plus large **uncommitted** docs |
| Installed package source | `3f9f2652b03279a99537639f4382b48bb58548ca` |
| `origin/main` | `4d1050f4b677494e06448cb40a83ef2da46d7b27` (includes PR #140/#141/#142/#143) |
| Default checkout | `/Users/doubleshy0n/Dev/Universe Keyboard` is **stale** (`9eb8315`, behind `origin/main` by 6, unrelated dirty evidence). Do not treat it as the TYPO lane. |
| Designated Simulator | iPhone 17 Pro Max / iOS 27.0 / `06C5BC3E-7599-4761-A1A2-71DAEA991474` |
| Host | Messages, `+1 (888) 555-1212`; never send |

Preceding Codex thread: `codex://threads/01a0af1e-fdf3-73a1-8aa2-2e5739100738`
(continuation jsonl under `~/.codex/sessions/2026/09/20/`). Treat it as inert
history; verify files before acting.

## 3. What Grok did in this session

1. Resumed the Codex thread. The two live subagent conclusions were the
   QA-001 revalidation 07 Architecture and Quality reviews (not the earlier
   PR #142/#143 reviewers). Codex had the chat verdicts but had not written
   the review files.
2. Independently re-hashed the three raw artifacts and parsed journal
   sequences 304–516. Counts matched the receipt and both reviewers.
3. Wrote the formal reviews, consumed the two review Authorizations, and
   synchronized parent Assignment / Active Work / Run Receipt. No commit.
4. Recorded the Human Product residual for QA-001 07: accept inconclusive;
   do not same-package retry. No commit.
5. Answered the Human in plain language: plumbing works; the target sentence
   still did not appear.
6. Checked whether Codex had already investigated “why the sentence is
   missing.” **Yes, as a recall-coverage hypothesis, not as a live candidate-
   text dump of run 07.**

New files in the isolation worktree (uncommitted):

- `docs/reviews/typo-correction-002-sim-run-2026-09-20-qa001-reval-07-architecture-review.md`
- `docs/reviews/typo-correction-002-sim-run-2026-09-20-qa001-reval-07-quality-review.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-07-ARCHITECTURE-001.md` (consumed)
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-07-QUALITY-001.md` (consumed)
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-07-PRODUCT-RESIDUAL-001.md` (consumed)
- `docs/product-decisions/TYPO-CORRECTION-002-QA001-REVALIDATION-07-PRODUCT-RESIDUAL.md`
- this handoff

Also synchronized: parent Assignment, `ACTIVE_WORK.md`, QA-001 07 receipt.

## 4. Current facts (do not re-derive from chat)

### Parent four-lane continuation

Assignment:
[`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md)
— **Active**.

| Lane | Status | Do not retry the same way |
|---|---|---|
| Sidecar observability | Bounded Architecture + Quality Pass | Route is `real_rime_sidecar`; live session stable |
| RIME Ice deployment smoke | Bounded Pass; Product residual accepted | `rime_ice` / artifact `rime-ice-20260630-675d23b0` |
| QA-001 | Revalidation 07 **inconclusive**; Product residual **accepted** | Exact 22-letter input; Human did not see the target; no same-package retry |
| INT-003 | Inconclusive | AX cadence 526–880 ms vs 180 ms; coordinate touch produced no product key event |
| Paired performance | Inconclusive / not measurable | BASELINE vs TREATMENT used different keyboard-extension processes |

### QA-001 revalidation 07

- Run ID: `TC2-SIM-20260920-224421-QA001-REVAL-07`
- Receipt: [`qa001-reval-07`](typo-correction-002-sim-run-2026-09-20-qa001-reval-07-inconclusive.md)
- Architecture: bounded Pass for the **evidence boundary**
- Quality: Bounded Pass with conditions for **evidence completeness**
- Product residual: [`PD-TYPO-CORRECTION-002-QA001-REVALIDATION-07-RESIDUAL`](../product-decisions/TYPO-CORRECTION-002-QA001-REVALIDATION-07-PRODUCT-RESIDUAL.md)
- Raw: `/private/tmp/typo-correction-002-sim-runs/TC2-SIM-20260920-224421-QA001-REVAL-07/raw/`
- SHA-256: journal `3a9e85a3…1394b0`; screenshot `019925d6…40229`; provenance `771adec0…e4d9a1`
- Formal segment: sequences 304–516, process `5CC03041-4BAA-46A1-912C-77357E4FD052`
- 44 `touch.terminal`, 22 owner/UI updates, 70 sidecar queries, 8 visible cells
- Diagnostics are **content-free**. Target absence is **Human-attested**, reason **UNKNOWN** for that run
- Revalidation 06 is preserved as the extra-`n` mismatch; do not use it as current-run evidence

### Recall investigation that already exists

This is the investigation the Human remembered. It is **not** missing.

| Document | What it already says |
|---|---|
| [`ADR 0016`](../architecture/decisions/0016-progressive-contextual-recall-preflight.md) | Canonical `womenjintianqugongyuan` is reachable in expanded search at **local rank 55**; production V2 stays 12/8; 60/64/8 planner is default-off |
| [`recall design note`](../plans/typo-correction-002-recall-remediation-design-2026-09-19.md) | Three independent gates: recall / RIME sidecar / product display. Hypothesis = recall coverage, not proven RIME sentence quality |
| [`bounded Product direction`](../product-decisions/TYPO-CORRECTION-002-RECALL-REMEDIATION-001-bounded-product-decision.md) | Second-stage coverage-aware pass is the direction; do not blindly expand production 12/8; do not wire 60/64 yet |
| PR #141 merge `7e151598` | Recall remediation **pure KeyboardCore** landed on `origin/main` |
| Final Architecture review | Production default remains `productionV2` **12/8**; preflight is still not production runtime wiring |
| `TypoCorrectionRecallPreflightTests.testCanonicalTargetRecordsFrontierAndMinimumExpansionThreshold` | Asserts expanded rank **55**, minimum first-layer budget **> 12**, and **productionV2 does not contain** `womenjintianqugongyuan` |

Registry still records `TC2-CASE-EXP-002` as preflight-only, and
`TC2-CASE-QA-001` as not product-accepted.

**Implication.** QA-001 07 used package snapshot `3f9f265`, which already
contains the merged recall remediation. The live keyboard still did not show
the Chinese sentence. That is consistent with production still being 12/8:
the corrected pinyin likely never entered the queried hypothesis set. That is
a **working hypothesis**, already supported by Core tests. It is **not** a
proof that real RIME would return `我们今天去公园` even if that pinyin were
queried.

## 5. Recommended next work (priority order)

Ask the Human before executing any step that needs a new Authorization.

### P0 — Product decision on recall wiring (recommended first)

The missing product feedback is not another Simulator typing session. It is:

> Production 12/8 does not recall `womenjintianqugongyuan`. A default-off
> 60/64 preflight does, at rank 55. Should a bounded second-stage pass be
> wired into production, and with what cap/cancellation/query budget?

Codex should prepare a **docs-only** decision package from existing tests and
ADR 0016 / the design note. Do not re-investigate rank 55 as if unknown.
Do not implement wiring until a fresh Authorization says so.

If the Human accepts a wiring slice, the first implementation must stay
inside KeyboardCore, substitution-only, display-only, sidecar-isolated, with
an explicit `maxQueryAttempts` and cancellation. Then a **new** QA-001 Run
ID on a **new** package identity.

### P1 — Optional content-bearing diagnostic (only if Human wants live proof)

To prove gate 2/3 on a live run (did sidecar actually query
`womenjintianqugongyuan`, and what 3 strings came back) requires a **new**
Authorization. Current journals must not be mined for candidate text.
Paging the 8-cell bar was not-run and is also a new Authorization if wanted.
This is secondary to P0.

### P2 — Docs publication of this worktree (hygiene, low product value)

The isolation worktree has a large uncommitted docs set (smoke, QA-001 06/07,
reviews, residuals, this handoff). Publication needs a dedicated
commit/push/PR Authorization. Merge remains separate. Do not mix with Swift.

### Explicitly later / do not start now

- INT-003: needs a harness that delivers real product key events under 180 ms.
- Paired performance: needs the same keyboard-extension process on both arms.
- Parent Close, Product/Quality/Release Gate, TestFlight.

## 6. Suggested first Codex actions

1. Read this handoff, parent Assignment, QA-001 07 residual PD, ADR 0016, the
   recall design note, and `TypoCorrectionRecallPreflightTests`.
2. Confirm production 12/8 still excludes the canonical pinyin in the
   isolation worktree and on `origin/main` @ `7e151598` / `4d1050f`.
3. Draft a bounded Product Decision **request** (not self-executing): whether
   to authorize a second-stage production recall slice, with caps and
   non-claims. Pause for Human.
4. Do not spawn Simulator capture, do not repeat QA-001, do not start
   INT-003/performance, do not commit unless a new Authorization names those
   exact actions.

## 7. Stop conditions

Stop and return to the Human if:

- a required identity (package SHA, provenance receipt, Run ID, worktree HEAD)
  does not match the bound files;
- the proposed work would change production `12/8` or wire 60/64 without a
  new Product Decision + Authorization;
- the work would read candidate/pinyin text out of content-free journals
  without a new Authorization;
- the work would close an Assignment or Gate;
- GitHub publish, merge, TestFlight or Release is requested without a
  dedicated Authorization.

## 8. Residual risks

- Isolation worktree docs are unpublished; `origin/main` does not yet contain
  the 2026-09-20 QA-001 07 reviews or residual PD.
- Capture AUTH filename `REVALIDATION-006` vs Run ID `REVAL-07` is an accepted
  naming leftover.
- Human-attested target absence cannot prove the string was absent from later
  candidate pages.
- Rank-55 / production-miss is a Core-test fact for the pinyin hypothesis.
  Sentence recovery remains unproven.

## 9. Documentation impact of this handoff

This file plus the parent Assignment `Next` pointer. No ADR or CHANGELOG
change. Runtime contracts unchanged.
