# Evidence: CI-HEAVY-JOB-SPLIT-001 hosted docs_only path

- Assignment: [`CI-HEAVY-JOB-SPLIT-001`](../assignments/ci-heavy-job-split-001.md) residual CHS-Q-02
- Date: `2026-09-15 Asia/Shanghai`
- Grade: `Executor-recorded` until independent Quality re-review
- Fixture PR: [#131](https://github.com/shchnk1103/Universe-Keyboard/pull/131) (draft; **close without merge**)

## Identity

| Fact | Value |
|---|---|
| Fixture PR | [#131](https://github.com/shchnk1103/Universe-Keyboard/pull/131) |
| Stack | `base=feature/ci-heavy-job-split-001` tip=`docs/ci-heavy-job-split-001-docs-only-fixture` |
| Prefix PR | [#130](https://github.com/shchnk1103/Universe-Keyboard/pull/130) |
| Fixture head | `9c9c2a921c8ad397f097854d025363478bd1b16f` |
| Base SHA used by classifier | `7b0b8fc08d8a1eb9d81b81b4c8cea8decd589b7e` |
| Merge ref (`GITHUB_SHA`) | `e833f5ec36dd39cceb293e519829431f4c3bf796` |
| Run | [`34924821846`](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/34924821846) |
| Event | `pull_request` |
| Run jobs | classify/lightweight/gate success; five named heavies skipped |

## Classifier JSON

```json
{"classification": "docs_only", "requires_full": "false", "reason": "all_paths_in_lightweight_allowlist", "changed_count": "1", "base_sha": "7b0b8fc08d8a1eb9d81b81b4c8cea8decd589b7e", "head_sha": "e833f5ec36dd39cceb293e519829431f4c3bf796", "full_required_paths": []}
```

## Jobs

| Job | Conclusion |
|---|---|
| classify-change | success |
| lightweight-checks | success |
| format-swift | skipped |
| test-keyboardcore | skipped |
| test-rimebridge | skipped |
| test-app-keyboard | skipped |
| build-release | skipped |
| final-quality-gate | success |

## Discarded runs

- First #131 targeting `main` skipped legacy `build-and-test` only; it does not prove the five-job contract.
- Retarget run [`34924431580`](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/34924431580) still used `main` as `base_sha` (queued before base change) and failed `git diff --check` on an extra EOF blank line in the Quality review; Gate fail-closed. Not CHS-Q-02 evidence.

## Not claimed

- Merge of #131 or #130
- Product Gate / Quality Pass / required-check trust root
