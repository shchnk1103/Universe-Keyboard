# Assignment: GIT-BRANCH-ARCHIVE-HYGIENE-003 — Group B keep disposition

Policy version: `1.0.0`

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Active` |
| **Phase** | Keep executed; Architecture/Quality Pass 0/0/0/0; docs-only PR [#120](https://github.com/shchnk1103/Universe-Keyboard/pull/120) open |
| **Non-claims** | No Group B delete; no merge of unique commits to `main`; no #101/#102; no Scheme Platform; no merge of this docs PR; no Product Gate / TestFlight / Release |
| **Next** | Human names merge of [#120](https://github.com/shchnk1103/Universe-Keyboard/pull/120) if accepted |
| **Residuals** | `A-GB-HYG-003-P2-01` / `P3-01` / `GBAH-003-Q-P2-01` `resolved` |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** [PD](../product-decisions/GIT-BRANCH-ARCHIVE-HYGIENE-003-authorization.md), Human Product Owner, `2026-09-11 Asia/Shanghai`
- **Product Approver:** Human Product Owner (delegated keep/delete judgment under KOS)
- **Authorization:** [AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-003](../authorizations/AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-003.md)
- **Predecessor:** Closed [GIT-BRANCH-ARCHIVE-HYGIENE-002](git-branch-archive-hygiene-002.md) after PR [#119](https://github.com/shchnk1103/Universe-Keyboard/pull/119) merged `bf0e6ec`

## KOS v0.8.0 optional-contract selection

| Contract | Selection | Boundary and owner source |
|---|---|---|
| E-01 claim-bound observation | Not applicable | Git-ref hygiene; no product/runtime/device claim |
| A-01 / B-01 authorization chain and briefing | Adopted | This Assignment → Authorization → Accepted Product Decision |
| P-01 publication facts | Adopted | Docs-only feature branch; table filled at publication handoff |
| D-01 final-documentation receipt | Not applicable | Ordinary docs-only link check is not claimed as D-01 |

### Authorization frontier (A-01 / B-01)

| Slice | Status | Action / target / boundary | Authority source |
|---|---|---|---|
| Current authorized slice | In progress | Keep recorded; docs PR [#120](https://github.com/shchnk1103/Universe-Keyboard/pull/120) open; merge remaining out of slice | This Assignment → [AUTH](../authorizations/AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-003.md) → [PD](../product-decisions/GIT-BRANCH-ARCHIVE-HYGIENE-003-authorization.md) |
| Merge of this docs PR | Not authorized | Merge | New Human authorization |
| Later Group B delete | Not authorized | Delete any of the three names | New bounded Assignment after Paused/Active owners Close or Product rejects the unique diffs |
| Environment or external slice | Not applicable | No ref mutation in this slice | Docs and local verification only |

### Publication facts (P-01)

| Fact | Value |
|---|---|
| `local_candidate` | `c942b96` at PR open; this handoff commit follows |
| `published_head` | `origin/docs/git-branch-archive-hygiene-003` (PR [#120](https://github.com/shchnk1103/Universe-Keyboard/pull/120)) |
| `hosted_ci_head` | unknown |
| `hosted_ci_result` | pending |
| `coverage` | unknown |
| `pr_state` | `open` [#120](https://github.com/shchnk1103/Universe-Keyboard/pull/120) |
| `local_ahead_of_published` | this commit, then 0 after push |

## Boundary

### Objective

Decide keep versus delete for the three Group B local branch names after
archive tags exist, using KOS fail-closed rules and a live diff against
`origin/main` `bf0e6ec`.

### Scope

1. Close [GIT-BRANCH-ARCHIVE-HYGIENE-002](git-branch-archive-hygiene-002.md) after PR #119 (M-02).
2. Record the keep disposition and the comparison evidence.
3. Do not delete the three local names. Do not create `origin` heads for them.
4. Independent Architecture and Quality document review; docs-only PR.

### Non-goals

- Deleting Group B branches.
- Cherry-picking or merging unique commits onto `main`.
- #101 / #102 / Scheme Platform / Product Gate / TestFlight / Release / Swift / SUG-08.
- Merging this documentation PR.

### Required Inputs

- Plan Group B inventory and 002 tags.
- Wanxiang P4 Assignment (not on `main`): local `codex/wanxiang-p4-closure-001` / tag `archive/codex-wanxiang-p4-closure-001/20260911` peel `e83e635`; Platform copy on `codex/scheme-platform-001` `5c42546` is **Paused ≠ Closed** and still names that historical tip. Do not treat a missing `docs/assignments/scheme-delivery-wanxiang-p4-closure-001.md` on `main` as Closed.
- Active [`RELEASE-2026-08-01`](release-2026-08-01.md) (Task 06 polish Active; Task 08 kaomoji Closed).
- Live `git diff origin/main...<tip>` after #119.

## Assignment

- **Domain Owner:** Architecture & Knowledge Steward
- **Executor:** Current Grok session
- **Environment Executor:** Not Applicable — no GitHub ref mutation; docs-only
- **Human Dependency:** Not Applicable — this chat delegated the keep/delete judgment
- **Architecture Reviewer:** independent runtime, lane `GIT-BRANCH-ARCHIVE-HYGIENE-003/document-architecture`
- **Quality Reviewer:** independent runtime, lane `GIT-BRANCH-ARCHIVE-HYGIENE-003/document-quality`
- **Handoff Target:** Human Product Owner (merge of docs PR; any later delete)

## Gates

### Entry Criteria

- [x] PR #119 merged; `e372268` ancestor of `origin/main` `bf0e6ec`.
- [x] Three Group B archive tags still peel to `e83e635` / `d3680c3` / `3444826`.
- [x] Open PRs are only #101 and #102.
- [x] No `UNKNOWN` responsibility field.

### Exit Criteria

- [x] Keep disposition recorded; no Group B name deleted.
- [x] Independent Architecture and Quality document reviews: [`Architecture Pass`](../reviews/GIT-BRANCH-ARCHIVE-HYGIENE-003-architecture-review.md) · [`Quality Pass`](../reviews/GIT-BRANCH-ARCHIVE-HYGIENE-003-quality-review.md).
- [x] Docs-only PR [#120](https://github.com/shchnk1103/Universe-Keyboard/pull/120) opened. Merge is not an exit criterion.
- [x] Assignment 002 Closed and Active Work / Dashboard synced.

### Stop Conditions

- Attempt to delete a Group B name in this slice.
- Working copy is `codex/scheme-platform-001`.
- Request to merge unique commits, #101/#102, or Release.

## Decision (executed)

Fail-closed: keep the named pointer when (a) a Paused/Active Assignment still
cites the tip, or (b) unique unmerged product/test code is not on `main` and
has not been Product-rejected while the parent program is Active.

| Branch | Disposition | Why |
|---|---|---|
| `codex/wanxiang-p4-closure-001` | **keep** | Paused Wanxiang P4 Assignment names this frozen tip; unique checklist/gaps **absent** on `main` (present on Platform branch with a different tip) |
| `codex/release-2026-0801-kaomoji` | **keep** | Unique Swift/tests/evidence **absent** on `main`; parent `RELEASE-2026-08-01` still Active even though Task 08 is Closed; not Product-rejected |
| `codex/release-2026-08-01-coordination-next` | **keep** | Unique Swift (home counts, hide settings entries, DEBUG-only typo) vs `main`; Task 06 polish still Active — candidate implementation, not a superseded closed PR |

Tags remain the recovery path. Deleting names would not lose commits, but would
hide live/paused working pointers. That is Group A behavior, which required
Closed/superseded PRs. These three are not that.

## Handoff

- **Required Handoff Content:** keep table; proof branches still resolve; 002 Closed; both reviews; docs PR URL.
- **Revalidation Trigger:** Wanxiang P4 Resume/Close; RELEASE-08 extra tests Product-rejected or merged; RELEASE-06 polish merged or abandoned; any later delete request.

## History

- `2026-09-11 Asia/Shanghai` — Human merged #119 and delegated Group B keep/delete to KOS. Disposition: keep all three.
- `2026-09-11 Asia/Shanghai` — Architecture first Pass with conditions (missing Wanxiang link + plan §3 “this slice”); fixed; re-review Pass 0/0/0/0. Quality HOLD then Pass 0/0/0/0 after the same link fix.
