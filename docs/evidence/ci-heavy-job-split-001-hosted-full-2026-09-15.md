# Evidence: CI-HEAVY-JOB-SPLIT-001 hosted full path

- Assignment: [`CI-HEAVY-JOB-SPLIT-001`](../assignments/ci-heavy-job-split-001.md)
- Date: `2026-09-15 Asia/Shanghai`
- Authority: [`AUTH-CI-HEAVY-JOB-SPLIT-001-PUBLISH`](../authorizations/AUTH-CI-HEAVY-JOB-SPLIT-001-PUBLISH.md) plus Human instruction that hosted CI was green
- Grade: `Executor-recorded` (jobs API + classify log). Not Quality-reverified until independent Quality re-review. Not merge. Not Product Gate.

## Identity

| Fact | Value |
|---|---|
| PR | [#130](https://github.com/shchnk1103/Universe-Keyboard/pull/130) (draft) |
| Branch | `feature/ci-heavy-job-split-001` |
| PR head | `39a25bd691dcf8ff18819741b29ea7a439849d09` |
| Hosted merge ref (`GITHUB_SHA`) | `9c64b5ae4058b55c19fabbfa1a7f1584ae01a62e` |
| Base | `1a405143229eff151f61d1c7fc789bc4368802d7` (`origin/main`) |
| Run | [`34923523955`](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/34923523955) |
| Event | `pull_request` |
| Run conclusion | `success` |

## Classifier JSON

```json
{"classification": "full", "requires_full": "true", "reason": "sensitive_or_unknown_path", "changed_count": "20", "base_sha": "1a405143229eff151f61d1c7fc789bc4368802d7", "head_sha": "9c64b5ae4058b55c19fabbfa1a7f1584ae01a62e", "full_required_paths": [".github/workflows/swift6-quality.yml", "scripts/ci/tests/test_verify_final_gate.sh", "scripts/ci/verify_final_gate.sh"]}
```

`full_required_paths` includes the workflow and Gate scripts, so the path is `full` as required. The PR head and GitHub synthetic merge ref remain distinct identities.

## Jobs

| Job | Conclusion |
|---|---|
| classify-change | success |
| lightweight-checks | success |
| format-swift | success |
| test-keyboardcore | success |
| test-rimebridge | success |
| test-app-keyboard | success |
| build-release | success |
| final-quality-gate | success |
| GitGuardian Security Checks | success |

No heavy job was `skipped`. Wall-clock of the run is from classify start `2026-09-15T03:03:31Z` to Gate complete `2026-09-15T03:08:42Z`.

## Not claimed

- Quality Pass / Product Gate / merge / Release
- Hosted `docs_only` skip matrix (CHS-Q-02)
- Required-check trust root (TD-016 A-P2-02)
