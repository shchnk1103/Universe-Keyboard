# Evidence: GIT-BRANCH-ARCHIVE-HYGIENE-001 Group A execution

**Run date / timezone:** `2026-09-11 Asia/Shanghai`
**Executor:** Current Grok session
**Working copy:** `/private/tmp/universe-keyboard-group-a-hygiene` (`docs/git-branch-archive-hygiene-001`)
**Baseline:** `origin/main` `6b24c37dcf8b5c7bed0a995739c054ae20fd7c04` (PR #117)
**Authority:** [`Assignment`](../assignments/git-branch-archive-hygiene-001.md) · [`AUTH`](../authorizations/AUTH-GIT-BRANCH-ARCHIVE-HYGIENE-001.md) · [`PD`](../product-decisions/GIT-BRANCH-ARCHIVE-HYGIENE-001-authorization.md)

This packet records git-ref operations only. It does not merge leftover unique
commits onto `main`, and it is not a Product / Quality / Release conclusion.

## Environment

| Field | Value | Grade |
|---|---|---|
| Worktree | `/private/tmp/universe-keyboard-group-a-hygiene` | `Executor-recorded` |
| Branch | `docs/git-branch-archive-hygiene-001` | `Executor-recorded` |
| HEAD at tag time | `234d180` | `Executor-recorded` |
| `origin/main` | `6b24c37dcf8b5c7bed0a995739c054ae20fd7c04` (merge of PR #117) | `Executor-recorded` |
| Scheme Platform checkout | not used | `Executor-recorded` |

## Open PRs at execution (abort check)

`gh pr list --state open` returned only:

| Number | Head | Draft | In Group A allowlist? |
|---|---|---|---|
| [#102](https://github.com/shchnk1103/Universe-Keyboard/pull/102) | `codex/scheme-platform-001` | yes | no |
| [#101](https://github.com/shchnk1103/Universe-Keyboard/pull/101) | `docs/adr-0034-architecture-accept-checklist` | yes | no |

Closed-PR confirmation: #103 CLOSED superseded; #88 CLOSED; #46 CLOSED.

## Group A tags

| Branch name (deleted) | Tip commit | Archive tag | Annotated tag object on origin | Peeled commit on origin | Grade |
|---|---|---|---|---|---|
| `codex/kos-v080-upgrade-review` | `7e090bd4a31d79a19cfa5e8d3b58ccfe60d92f34` | `archive/codex-kos-v080-upgrade-review/20260911` | `6a12c2d6bae019186a45f746700c2dc6430d5e59` | `7e090bd4…` (`^{}`) | `Executor-recorded` |
| `codex/td016-docs-only-fixture` | `bd4b6eb14c6e4b25c60d66807ceb1e0b67cc8ac4` | `archive/codex-td016-docs-only-fixture/20260911` | `19853f87c86b0b51f9d99fb13e95f04cf1c9851d` | `bd4b6eb1…` (`^{}`) | `Executor-recorded` |
| `docs/t9-single-key-mixed-candidates-discussion` | `270f45b954d1a3f49f623059cf9e0b874c640061` | `archive/docs-t9-single-key-mixed-candidates-discussion/20260911` | `64c77be251e796fc859ca1d579e0f0891416fa10` | `270f45b9…` (`^{}`) | `Executor-recorded` |

Tags were created annotated, pushed, then `git ls-remote --tags origin` showed both the tag object and the peeled commit. Local `git rev-parse <tag>^{commit}` equaled the tip before any branch delete.

## Branch deletes

| Name | Remote `ls-remote --heads` after delete | Local | Grade |
|---|---|---|---|
| `codex/kos-v080-upgrade-review` | empty | deleted (`was 7e090bd`) | `Executor-recorded` |
| `codex/td016-docs-only-fixture` | empty | deleted (`was bd4b6eb`) | `Executor-recorded` |
| `docs/t9-single-key-mixed-candidates-discussion` | empty | deleted (`was 270f45b`) | `Executor-recorded` |

`git push origin --delete` reported each name `[deleted]`.

## Left alone (not in this slice)

| Ref | After Group A | Grade |
|---|---|---|
| `origin/codex/scheme-platform-001` | still `d8e8299dcb608cdb8e976604add7b6d744012757` | `Executor-recorded` |
| `origin/docs/adr-0034-architecture-accept-checklist` | still `889bb4e7e4b6be4e784ecf7c10f53ead41ddcb43` | `Executor-recorded` |
| local `codex/wanxiang-p4-closure-001` | still `e83e635` | `Executor-recorded` |
| local `codex/release-2026-0801-kaomoji` | still `d3680c3` | `Executor-recorded` |
| local `codex/release-2026-08-01-coordination-next` | still `3444826` | `Executor-recorded` |
| draft #101 / #102 | still OPEN | `Executor-recorded` |

No Group B tags were created.

## Recover

```bash
git fetch origin tag archive/codex-kos-v080-upgrade-review/20260911
git checkout -b restore/kos-v080-upgrade-review archive/codex-kos-v080-upgrade-review/20260911
```

Equivalent for the other two tag names. Unique commits are **not** ancestors of `origin/main`.

## Non-claims

- Unique Group A diffs were not cherry-picked or merged to `main`.
- Group B was not tagged or deleted.
- Scheme Platform and ADR #101 were not modified.
- This evidence is `Executor-recorded`; it is not Quality-reverified until the independent Quality review says so.
- No Product Gate / TestFlight / Release / SUG-08 / Swift.

## Commands (order)

1. `git fetch --prune origin`
2. `gh pr list --state open`
3. `git tag -a archive/…/20260911 <tip>` (three tags)
4. `git push origin` those three tags
5. `git ls-remote --tags origin` (object + `^{}` peel)
6. `git push origin --delete` the three branch names
7. `git branch -D` the three local names
