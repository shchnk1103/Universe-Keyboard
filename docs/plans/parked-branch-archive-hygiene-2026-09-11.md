# Plan: parked-branch archive hygiene

**Lifecycle:** `Active`
**Status:** Active for **Group A only** under [`GIT-BRANCH-ARCHIVE-HYGIENE-001`](../assignments/git-branch-archive-hygiene-001.md). Group B remains parked and **not** implementation-authorized.

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

## Execution (for the future Assignment only)

Work from a **new** worktree of `origin/main`. Never from `codex/scheme-platform-001`.

### 0. Revalidate

```bash
git fetch --prune origin
gh pr list --state open --json number,headRefName,isDraft,url
# Abort Group A delete if #101 or #102 head appears in the allowlist.
```

For each candidate tip:

```bash
git merge-base --is-ancestor <tip> origin/main && echo ON_MAIN || echo NOT_ON_MAIN
git log --oneline origin/main..<tip>
```

If `NOT_ON_MAIN` and no archive tag yet, **do not delete**.

### 1. Annotated tags (Group A and Group B)

Tag pattern: `archive/<sanitized-branch-name>/<YYYYMMDD>`.

```bash
git tag -a archive/codex-kos-v080-upgrade-review/20260911 7e090bd \
  -m "Park superseded #103 prefix; clean adopt is #104"
git tag -a archive/codex-td016-docs-only-fixture/20260911 bd4b6eb \
  -m "Park closed PR #88 hosted docs-only fixture"
git tag -a archive/docs-t9-single-key-mixed-candidates-discussion/20260911 270f45b \
  -m "Park closed PR #46 leftover discussion delta"
git tag -a archive/codex-wanxiang-p4-closure-001/20260911 e83e635 \
  -m "Park Paused Wanxiang P4; do not delete until Human says so"
git tag -a archive/codex-release-2026-0801-kaomoji/20260911 d3680c3 \
  -m "Park extra kaomoji handoff/tests after #80"
git tag -a archive/codex-release-2026-08-01-coordination-next/20260911 3444826 \
  -m "Park unmerged polish; review vs main before any delete"
git push origin \
  archive/codex-kos-v080-upgrade-review/20260911 \
  archive/codex-td016-docs-only-fixture/20260911 \
  archive/docs-t9-single-key-mixed-candidates-discussion/20260911 \
  archive/codex-wanxiang-p4-closure-001/20260911 \
  archive/codex-release-2026-0801-kaomoji/20260911 \
  archive/codex-release-2026-08-01-coordination-next/20260911
```

If the tip SHA moved, retag the **current** tip; do not reuse this SHA list blindly. Dates in tag names are recording-time examples.

### 2. Delete Group A branches only (after tags are on `origin`)

```bash
git ls-remote --tags origin 'archive/codex-kos-v080-upgrade-review/*'
# must be non-empty, and git rev-parse the tag must equal the tip being deleted

git push origin --delete \
  codex/kos-v080-upgrade-review \
  codex/td016-docs-only-fixture \
  docs/t9-single-key-mixed-candidates-discussion

git branch -d codex/kos-v080-upgrade-review \
  || git merge-base --is-ancestor <local-tip> archive/codex-kos-v080-upgrade-review/20260911 \
  && git branch -D codex/kos-v080-upgrade-review
# same pattern for the other two local names
```

Use `-D` only after the matching **pushed** archive tag points at that tip. Report each delete.

### 3. Group B after tags

Stop. Do not delete. Report parked tags. Human later chooses delete vs keep.

### 4. Evidence to write in the future Assignment

- Commands, SHAs, tag names, `ls-remote` results.
- Open PR list at execution time.
- Explicit non-claims: no Scheme Platform push, no #101 merge, no Product Gate.

## Recovering a parked tip

```bash
git fetch origin tag archive/codex-kos-v080-upgrade-review/20260911
git checkout -b restore/kos-v080-upgrade-review archive/codex-kos-v080-upgrade-review/20260911
```

## Handoff target

Product Lead, when there is time: create Assignment + Authorization to execute Group A (and optionally Group B tags). The grok bot on Scheme Platform is out of scope.

This plan is obsolete if those branches are already gone or if a later accepted hygiene Assignment supersedes it.
