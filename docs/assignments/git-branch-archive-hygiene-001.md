# Assignment: GIT-BRANCH-ARCHIVE-HYGIENE-001 — Group A parked-branch archive

Policy version: `1.0.0`

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Closed` |
| **Phase** | PR [#118](https://github.com/shchnk1103/Universe-Keyboard/pull/118) merged `bb15b27` (head `fc7d8b1`); feature branch deleted after `origin/main` reachability |
| **Non-claims** | No Group B tag/delete in this Assignment; no #101/#102; no Product Gate / TestFlight / Release; unique Group A commits are **not** merged to `main` |
| **Next** | Group B tags are [`GIT-BRANCH-ARCHIVE-HYGIENE-002`](git-branch-archive-hygiene-002.md) |
| **Residuals** | `A-GB-HYG-P2-01` `resolved` |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** [PD](../product-decisions/GIT-BRANCH-ARCHIVE-HYGIENE-001-authorization.md), Human Product Owner, `2026-09-11 Asia/Shanghai`
- **Product Approver:** Human Product Owner
- **Authorization:** [AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-001](../authorizations/AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-001.md) (consumed) · [AUTH-…-MERGE](../authorizations/AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-001-MERGE.md) (consumed)

## KOS v0.8.0 optional-contract selection

| Contract | Selection | Boundary and owner source |
|---|---|---|
| E-01 claim-bound observation | Not applicable | Git-ref hygiene; no product/runtime/device claim |
| A-01 / B-01 authorization chain and briefing | Adopted | This Assignment → Authorization → Accepted Product Decision bound only Group A |
| P-01 publication facts | Adopted | Docs-only feature branch and archive tags; table filled at publication handoff |
| D-01 final-documentation receipt | Not applicable | Ordinary docs-only link check after the last Markdown edit is not claimed as D-01 |

### Authorization frontier (A-01 / B-01)

| Slice | Status | Action / target / boundary | Authority source |
|---|---|---|---|
| Current authorized slice | Not applicable | Group A execution and merge consumed; Assignment Closed | [AUTH](../authorizations/AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-001.md) · [MERGE AUTH](../authorizations/AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-001-MERGE.md) |
| Merge of the docs PR | Authorized | Consumed: PR [#118](https://github.com/shchnk1103/Universe-Keyboard/pull/118) merged `bb15b27` | Human: “批准合并 #118” |
| Group B tag or delete | Not authorized | Successor [`GIT-BRANCH-ARCHIVE-HYGIENE-002`](git-branch-archive-hygiene-002.md) owns tags only | New bounded Assignment |
| Environment or external slice | Authorized | Current session GitHub: push annotated tags and `git push origin --delete` for the three Group A names only | Same AUTH; host GitHub |

### Publication facts (P-01)

| Fact | Value |
|---|---|
| `local_candidate` | `fc7d8b18ab1aa78914c00679c1efeeb13e2c4b8e` |
| `published_head` | `fc7d8b18ab1aa78914c00679c1efeeb13e2c4b8e` |
| `hosted_ci_head` | `fc7d8b18ab1aa78914c00679c1efeeb13e2c4b8e` |
| `hosted_ci_result` | `green` (classify / lightweight / final-quality-gate SUCCESS; build-and-test SKIPPED) |
| `coverage` | `same-head` |
| `pr_state` | `merged` [#118](https://github.com/shchnk1103/Universe-Keyboard/pull/118) `bb15b27` |
| `local_ahead_of_published` | 0 |

## Boundary

### Objective

Park the three closed/superseded Group A branch tips behind annotated archive
tags, then remove those branch names from local and `origin`, without merging
the leftover unique commits into `main`.

### Scope

1. Record this Assignment, Authorization, and Accepted Product Decision.
2. Revalidate open PRs and Group A SHAs against
   [`parked-branch-archive-hygiene-2026-09-11.md`](../plans/parked-branch-archive-hygiene-2026-09-11.md).
3. Create and push annotated tags:
   - `archive/codex-kos-v080-upgrade-review/20260911` → `7e090bd`
   - `archive/codex-td016-docs-only-fixture/20260911` → `bd4b6eb`
   - `archive/docs-t9-single-key-mixed-candidates-discussion/20260911` → `270f45b`
4. After each tag is on `origin` and `git rev-parse <tag>` equals the tip,
   delete the matching local and `origin` branch names.
5. Write execution evidence; independent Architecture and Quality document review.
6. Commit and push branch `docs/git-branch-archive-hygiene-001`; open a docs-only PR.

### Non-goals

- Tagging or deleting Group B (`wanxiang-p4-closure-001`, `release-2026-0801-kaomoji`, `release-2026-08-01-coordination-next`).
- Touching `codex/scheme-platform-001` / draft [#102](https://github.com/shchnk1103/Universe-Keyboard/pull/102) or `docs/adr-0034-architecture-accept-checklist` / draft [#101](https://github.com/shchnk1103/Universe-Keyboard/pull/101).
- Merging unique Group A commits onto `main`.
- Merging the documentation PR, Product Gate, TestFlight, Release, ADR Accept, Swift, SUG-08.
- Executing from the Scheme Platform checkout.

### Required Inputs

- Proposed packet [`parked-branch-archive-hygiene-2026-09-11.md`](../plans/parked-branch-archive-hygiene-2026-09-11.md) (commit `2c12cea`, cherry-picked).
- Human instruction in this session authorizing Group A only.
- Live `git fetch --prune origin` and `gh pr list --state open`.
- Closed PRs #103, #88, #46.

## Assignment

- **Domain Owner:** Architecture & Knowledge Steward
- **Executor:** Current Grok session
- **Environment Executor:** Current session — GitHub host operations limited to pushing the three archive tags, deleting the three Group A branch names on `origin`, and pushing the docs-only feature branch
- **Human Dependency:** Not Applicable — this chat is the Product authorization; force-delete of an untagged unique tip is forbidden, so no extra Human action is required
- **Architecture Reviewer:** independent runtime, lane `GIT-BRANCH-ARCHIVE-HYGIENE-001/document-architecture`, after execution evidence
- **Quality Reviewer:** independent runtime, lane `GIT-BRANCH-ARCHIVE-HYGIENE-001/document-quality`, after execution evidence
- **Handoff Target:** Human Product Owner (merge of docs PR; any Group B work)

## Gates

### Entry Criteria

- [x] Accepted Product Decision and Authorization resolve to Group A only.
- [x] No `UNKNOWN` responsibility field.
- [x] Open PRs at execution start are only #101 and #102; neither head is in the Group A allowlist.
- [x] Group A tips still match the packet: `7e090bd`, `bd4b6eb`, `270f45b`; none is an ancestor of `origin/main`.
- [x] Working copy is `/private/tmp/universe-keyboard-group-a-hygiene` on `docs/git-branch-archive-hygiene-001` from `origin/main` `6b24c37`, not `codex/scheme-platform-001`.

### Exit Criteria

- [x] Each Group A tag exists on `origin` and points at the recorded tip. See [evidence](../evidence/git-branch-archive-hygiene-001-group-a-2026-09-11.md).
- [x] Each Group A branch name is absent from `git ls-remote --heads origin <name>` and deleted locally.
- [x] Unique commits remain recoverable via `git rev-parse archive/…^{commit}`.
- [x] Evidence records commands, SHAs, tag names, `ls-remote` results, and the open-PR list.
- [x] Independent Architecture and Quality document reviews on the final docs diff: [`Architecture Pass`](../reviews/GIT-BRANCH-ARCHIVE-HYGIENE-001-architecture-review.md) · [`Quality Pass`](../reviews/GIT-BRANCH-ARCHIVE-HYGIENE-001-quality-review.md).
- [x] Docs-only feature branch pushed; PR [#118](https://github.com/shchnk1103/Universe-Keyboard/pull/118) opened. Merge is not an exit criterion.

### Stop Conditions

- An open PR whose head is a Group A name.
- A Group A tip SHA moved relative to the packet and no retag of the **current** tip was recorded.
- Attempt to delete a tip that is not tagged on `origin`.
- Working copy is `codex/scheme-platform-001`, or the grok bot still needs a Group A branch (it does not).
- Request to include Group B, #101, #102, merge, or Release in this slice.

## Handoff

- **Required Handoff Content:** tag names and SHAs; branch delete results; evidence path; both independent reviews; docs PR URL; explicit non-claims for Group B / #101 / #102 / merge.
- **Revalidation Trigger:** a Group A tip SHA change before tag push; an open PR appearing on a Group A head; a review finding that changes scope; any request to delete Group B or merge the docs PR.

## History

- `2026-09-11 Asia/Shanghai` — SUG-05 Proposed packet recorded at `2c12cea` on `docs/parked-branch-hygiene-proposed` (local only).
- `2026-09-11 Asia/Shanghai` — Human Product Owner authorized Group A execution in the current Grok session. This Assignment implements Group A only.
- `2026-09-11 Asia/Shanghai` — Group A annotated tags pushed; three branch names deleted on `origin` and locally. Evidence written. Unique commits not on `main`.
- `2026-09-11 Asia/Shanghai` — Independent Architecture first Pass with conditions (`A-GB-HYG-P2-01` `fix`); plan Execution narrowed to Group A; Architecture re-review Pass 0/0/0/0 residual resolved. Quality Pass 0/0/0/0.
- `2026-09-11 Asia/Shanghai` — Human authorized merge of #118. Merged `bb15b27`; `fc7d8b1` is an ancestor of `origin/main`; remote and local feature branch deleted. Assignment Closed. Group B moved to 002.
