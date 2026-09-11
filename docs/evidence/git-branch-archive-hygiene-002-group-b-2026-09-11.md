# Evidence: GIT-BRANCH-ARCHIVE-HYGIENE-002 Group B tags

**Run date / timezone:** `2026-09-11 Asia/Shanghai`
**Executor:** Current Grok session
**Working copy:** `/private/tmp/universe-keyboard-group-b-hygiene` (`docs/git-branch-archive-hygiene-002`)
**Baseline:** `origin/main` `bb15b272a32e8eeecb140d0539289e5438846964` (PR #118)
**Authority:** [`Assignment`](../assignments/git-branch-archive-hygiene-002.md) · [`AUTH`](../authorizations/AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-002.md) · [`PD`](../product-decisions/GIT-BRANCH-ARCHIVE-HYGIENE-002-authorization.md)

Git-ref operations only. Unique commits were not merged to `main`. Branch names were **not** deleted.

## Environment

| Field | Value | Grade |
|---|---|---|
| Worktree | `/private/tmp/universe-keyboard-group-b-hygiene` | `Executor-recorded` |
| Branch | `docs/git-branch-archive-hygiene-002` | `Executor-recorded` |
| HEAD at tag time | `47bba9c` | `Executor-recorded` |
| `origin/main` | `bb15b272a32e8eeecb140d0539289e5438846964` | `Executor-recorded` |
| Scheme Platform checkout | not used | `Executor-recorded` |

## Open PRs at execution

| Number | Head | Draft | Group B name? |
|---|---|---|---|
| [#102](https://github.com/shchnk1103/Universe-Keyboard/pull/102) | `codex/scheme-platform-001` | yes | no |
| [#101](https://github.com/shchnk1103/Universe-Keyboard/pull/101) | `docs/adr-0034-architecture-accept-checklist` | yes | no |

## Group B tags (pushed; branches kept)

| Local branch (kept) | Tip commit | Archive tag | Annotated tag object on origin | Peeled commit | Grade |
|---|---|---|---|---|---|
| `codex/wanxiang-p4-closure-001` | `e83e6358de8621e24522294542539d029c91b080` | `archive/codex-wanxiang-p4-closure-001/20260911` | `6d8f0cace6747b6cea85c10eb6f8bbe7f310b1af` | `e83e6358…` (`^{}`) | `Executor-recorded` |
| `codex/release-2026-0801-kaomoji` | `d3680c347181d65703327b324951b6d931d637aa` | `archive/codex-release-2026-0801-kaomoji/20260911` | `796c1450451b220a39ad16d6b810d51096aa1815` | `d3680c34…` (`^{}`) | `Executor-recorded` |
| `codex/release-2026-08-01-coordination-next` | `3444826983bb7b4e49ef96f9eb165964880ca8b9` | `archive/codex-release-2026-08-01-coordination-next/20260911` | `bf84aaffcf9e41f593bf6d3a58878eacae7fc103` | `34448269…` (`^{}`) | `Executor-recorded` |

Each peeled commit equals the local branch tip. `git merge-base --is-ancestor <tip> origin/main` is `NOT_ON_MAIN` for all three.

## Branch names after tagging

| Name | Local | `origin` heads | Grade |
|---|---|---|---|
| `codex/wanxiang-p4-closure-001` | still `e83e635` | empty | `Executor-recorded` |
| `codex/release-2026-0801-kaomoji` | still `d3680c3` | empty | `Executor-recorded` |
| `codex/release-2026-08-01-coordination-next` | still `3444826` | empty | `Executor-recorded` |

No `git push origin --delete` and no `git branch -D` for Group B.

## Left alone

| Ref | After Group B tags | Grade |
|---|---|---|
| `origin/codex/scheme-platform-001` | still `d8e8299dcb608cdb8e976604add7b6d744012757` | `Executor-recorded` |
| `origin/docs/adr-0034-architecture-accept-checklist` | still `889bb4e7e4b6be4e784ecf7c10f53ead41ddcb43` | `Executor-recorded` |
| Group A archive tags | unchanged | `Executor-recorded` |

## Recover

```bash
git fetch origin tag archive/codex-wanxiang-p4-closure-001/20260911
git checkout -b restore/wanxiang-p4 archive/codex-wanxiang-p4-closure-001/20260911
```

Local branch names also still point at the same tips.

## Non-claims

- Unique Group B diffs were not cherry-picked or merged to `main`.
- Group B branches were not deleted.
- Scheme Platform and ADR #101 were not modified.
- This evidence is `Executor-recorded` until independent Quality review.
- No Product Gate / TestFlight / Release / SUG-08 / Swift.

## Commands (order)

1. `git fetch --prune origin` (after #118 merge)
2. `gh pr list --state open`
3. `git tag -a archive/…/20260911 <tip>` (three tags)
4. `git push origin` those three tags
5. `git ls-remote --tags origin` (object + `^{}` peel)
6. Confirm local branches still resolve; `ls-remote --heads` empty for the three names
