# Plan: parked-branch archive hygiene

**Lifecycle:** `Active`
**Status:** Group A **executed** `2026-09-11 Asia/Shanghai` (tags on `origin`, branch names deleted). Group B remains parked and **not** implementation-authorized. See [`evidence`](../evidence/git-branch-archive-hygiene-001-group-a-2026-09-11.md).

> **S-03:** The SUG-05 `Proposed` header below is historical recording context. It does **not** authorize Group A (that authority is the Assignment / AUTH / Product Decision). It still does **not** authorize Group B.

**Inventory baseline at recording:** `origin/main` `fe2655152cbbefc61734afe519ef7b16e722aaa4` (PR #114).
**Revalidation at Group A start:** `origin/main` `6b24c37` (PR #117); Group A SHAs unchanged; open PRs only #101 and #102.

## Proposed work-package handoff

- **Triggering evidence:** After DEVICE-001 Close (#114), leftover unmerged local/remote branches remain. Human asked not to delete them blindly, handed Scheme Platform P1 to a grok bot, and asked to record a later-executable hygiene packet. Direct `-D` / `git push --delete` of unmerged tips would hide recoverable work (AGENTS.md GitHub 发布与分支清理).
- **Frozen facts and unknowns:** See inventory tables below, frozen at recording time. Unknown until execution: whether #101/#102 still open; whether any parked tip has been merged; whether the grok bot still owns `codex/scheme-platform-001`; whether unique polish/kaomoji diffs are still wanted. Those values are `UNKNOWN` until the future Assignment re-fetches.
- **Decision to preserve:** Prefer **annotated archive tags**, then optional branch delete. Tags keep the tip reachable. Open PR heads stay. Unmerged unique work is not force-deleted. This plan does not authorize the tag/delete actions.
- **Proposed seam and alternatives rejected:** One future Assignment named `GIT-BRANCH-ARCHIVE-HYGIENE-001` (or successor) executes a written allowlist. Rejected: silent `-D`; folding #101 into #102; deleting Wanxiang P4 / release polish as garbage; doing this on the Scheme Platform checkout.
- **Verification matrix:** Before each delete, `git fetch --prune origin`, `git merge-base --is-ancestor <tip> origin/main` **or** a pushed `archive/…` tag pointing at that tip, and `gh pr view` showing no open PR on that head. After delete, `git ls-remote --heads origin <name>` empty and `git rev-parse archive/…` still resolves. No Swift/CI/device work.
- **Stop conditions and non-goals:** Stop if #102/#101 is still OPEN and the target is that head; if a tip is not tagged and not on `origin/main`; if the working copy is `codex/scheme-platform-001`; if the grok bot session still uses the branch. Non-goals: Product Gate, SUG-08, Scheme Platform P1, merging parked history onto `main`, rewriting unique commits.
- **Required authorization and reviewers:** Future execution needs a Product-selected Assignment, matching Authorization, Accepted Product Decision, Domain Owner (Architecture & Knowledge Steward for git hygiene / Program Manager for inventory), Executor, Environment Executor `Not Applicable` unless `git push` of tags/deletes (then current session + Human-authorized GitHub), Human Dependency for any force-delete of untagged unique tips, independent Architecture/Quality document review of the execution record. **This Proposed plan grants none of that.**

## Inventory at recording time

Do not treat this table as live truth. Re-run the commands in § Execution.

### Leave alone (live)

| Ref | Tip at recording | Why |
|---|---|---|
| `codex/scheme-platform-001` local+`origin` | `a092de8` | Draft PR #102; grok bot follow-up. Do not tag-delete while OPEN. |
| `docs/adr-0034-architecture-accept-checklist` local+`origin` | `889bb4e` | Draft PR #101; Human: leave draft, keep #101 ≠ #102. ADR review blobs differ from Platform copies. |

### Group A — archive tag, then delete local and remote (recommended first execution slice)

| Ref | Tip at recording | Unique vs `main` | Why tag-then-delete is eligible |
|---|---|---|---|
| `codex/kos-v080-upgrade-review` local+`origin` | `7e090bd` | 12 commits | PR #103 CLOSED superseded; clean adopt is #104 on `main`. Tip not ancestor of `main`. |
| `codex/td016-docs-only-fixture` local+`origin` | `bd4b6eb` | 1 commit, `docs/evidence/td-016-docs-only-hosted-fixture.md` | PR #88 CLOSED unmerged. |
| `docs/t9-single-key-mixed-candidates-discussion` local+`origin` | `270f45b` | 1 commit | PR #46 CLOSED. Discussion file already on `main`; leftover is a small diff. |

### Group B — tag only; do not delete until a later Human decision

| Ref | Tip at recording | Unique vs `main` | Why park |
|---|---|---|---|
| `codex/wanxiang-p4-closure-001` local only | `e83e635` | 6 commits | Wanxiang P4 is Paused, not abandoned. Overlaps #101/Platform files; tips differ. |
| `codex/release-2026-0801-kaomoji` local only | `d3680c3` | 3 commits + extra tests/handoffs | PR #80 merged a later kaomoji slice; this tip still has unique evidence/tests. |
| `codex/release-2026-08-01-coordination-next` local only | `3444826` | 12 commits | Unmerged polish (home counts, settings hide, typo exclusion). May be stale or unshipped; needs a diff vs `main` before delete. |

### Already done (do not repeat)

- Stale worktrees `universe-keyboard-kos-v070-pin-sync` and `…-kos-v080-upgrade-review` pruned.
- Local `codex/kos-v070-pin-sync` deleted (`39ee3ea` reachable from Scheme Platform).
- Remote `codex/kos-astra-adoption` deleted (PR #99 on `main`).
- Local `main` fast-forwarded to `fe26551` / #114.

## Execution

Work from a **new** worktree of `origin/main`. Never from `codex/scheme-platform-001`.

Current Active slice is **Group A only**, under
[`GIT-BRANCH-ARCHIVE-HYGIENE-001`](../assignments/git-branch-archive-hygiene-001.md).
Do not treat the rest of this section as a command to run now.

### 0. Revalidate (done for Group A, `2026-09-11`)

Open PRs were only #101 and #102. Group A tips still `7e090bd` / `bd4b6eb` /
`270f45b`, none an ancestor of `origin/main` `6b24c37`.

### 1. Annotated tags — Group A (executed)

Tag pattern: `archive/<sanitized-branch-name>/<YYYYMMDD>`.

Group A tags are on `origin` and must not be recreated:

```text
archive/codex-kos-v080-upgrade-review/20260911 -> 7e090bd
archive/codex-td016-docs-only-fixture/20260911 -> bd4b6eb
archive/docs-t9-single-key-mixed-candidates-discussion/20260911 -> 270f45b
```

> **S-03 / out of this Active slice:** The original Proposed packet also listed
> Group B tag names (`wanxiang-p4-closure-001`, `release-2026-0801-kaomoji`,
> `release-2026-08-01-coordination-next`). Those commands are **not** current
> development guidance. Do **not** `git tag` or `git push` them in this
> Assignment. A later bounded Assignment + Authorization is required.

### 2. Delete Group A branches (executed)

After the three Group A tags were on `origin` and peeled to the recorded tips,
the three branch names were deleted on `origin` and locally. See
[`evidence`](../evidence/git-branch-archive-hygiene-001-group-a-2026-09-11.md).

### 3. Group B

Stop. Do not tag. Do not delete. Human later chooses a new Assignment.

### 4. Evidence

Group A evidence is recorded. Remaining for this Assignment: independent
reviews and a docs-only PR. Merge of that PR is separately gated.

## Recovering a parked tip

```bash
git fetch origin tag archive/codex-kos-v080-upgrade-review/20260911
git checkout -b restore/kos-v080-upgrade-review archive/codex-kos-v080-upgrade-review/20260911
```

## Handoff target

Group A execution is owned by [`GIT-BRANCH-ARCHIVE-HYGIENE-001`](../assignments/git-branch-archive-hygiene-001.md). Next Human decisions: merge of that docs-only PR; any later Group B Assignment. Scheme Platform remains out of scope.

This Group A slice is obsolete only if a later accepted hygiene Assignment supersedes it.
