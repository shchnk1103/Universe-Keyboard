# Evidence: KOS-SUG-PUB-HANDOFF-001 — local docs-only checks

## Current Status

| Field | Value |
|---|---|
| Status | Recorded |
| Assignment | [KOS-SUG-PUB-HANDOFF-001](../assignments/kos-sug-pub-handoff-001.md) |
| Grade | Executor-recorded |
| Outcome | pass for the named local commands only |
| Non-claims | Not a D-01 publication receipt; not hosted CI; not Product/Quality/merge/Release |

---

| Claim | Outcome | Evidence grade | Conflict / supersession |
|---|---|---|---|
| Changed Markdown links resolve against `origin/main` at `baab8c2` | pass | Executor-recorded | Superseded for later tips by the `f997a54` rows |
| `scripts/ci` unit tests pass at `baab8c2` | pass | Executor-recorded | Superseded for later tips by the `f997a54` rows |
| Changed Markdown links resolve at `f997a54` | pass | Quality-reverified | None known |
| `scripts/ci` unit tests pass at `f997a54` | pass | Quality-reverified | None known |

## Commands

Baseline: `77e5658d7fa0b7b868517238cb2cf24aeb7e024f` (`origin/main`, PR #104 merge)
Head at check: `baab8c26218ad59e8f93632cceb2f60c00a6d3fd`
Tree: `38bef322e0faaacc7b74636581ca4793fab65fe5`
Environment: local executor workstation, Python 3, worktree `/private/tmp/universe-keyboard-kos-sug-pub-handoff`

```text
python3 scripts/ci/check_markdown_links.py --base 77e5658d7fa0b7b868517238cb2cf24aeb7e024f --head HEAD
# PASS changed Markdown links (14 files)

python3 -m unittest discover -s scripts/ci/tests -p 'test_*.py'
# Ran 12 tests, OK
```

If later documentation edits land, these results do not cover them.

## Re-run on repaired tip `f997a54`

Head: `f997a5452964c16bd4efc2805ddab7e3b7abf490`
Tree: `49120c271ccc4fc1a6c142c265ead72c9a35404b`
Grade: Quality-reverified by the independent Quality addendum; Executor independently observed the same commands on this SHA before requesting addenda.

```text
python3 scripts/ci/check_markdown_links.py --base 77e5658d7fa0b7b868517238cb2cf24aeb7e024f --head HEAD
# PASS changed Markdown links (19 files)

python3 -m unittest discover -s scripts/ci/tests -p 'test_*.py'
# Ran 12 tests, OK
```

Pointer: [Quality addendum](../reviews/KOS-SUG-PUB-HANDOFF-001-quality-review.md).
Not a D-01 publication receipt; not hosted CI; not merge/Release.
Committing this evidence and the review addenda creates a newer HEAD that must
be re-checked before any publication receipt.
