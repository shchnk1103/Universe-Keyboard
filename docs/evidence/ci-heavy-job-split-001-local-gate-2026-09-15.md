# Evidence: CI-HEAVY-JOB-SPLIT-001 local gate scripts

- Assignment: [`CI-HEAVY-JOB-SPLIT-001`](../assignments/ci-heavy-job-split-001.md)
- Date: `2026-09-15 Asia/Shanghai`
- Environment: local executor workstation
- Authority: [`AUTH-CI-HEAVY-JOB-SPLIT-001-IMPLEMENT`](../authorizations/AUTH-CI-HEAVY-JOB-SPLIT-001-IMPLEMENT.md)
- Grade: Executor-recorded local script results. Not hosted CI. Not Quality Pass. Not merge evidence.

## Commands

```bash
python3 -m unittest discover -s scripts/ci/tests -p 'test_*.py'
bash scripts/ci/tests/test_verify_final_gate.sh
bash scripts/ci/tests/test_kos_trigger_paths.sh
```

## Results

| Check | Result |
|---|---|
| Python classifier / markdown-link tests | 12 tests, OK |
| `test_verify_final_gate.sh` | PASS final gate result matrix |
| `test_kos_trigger_paths.sh` | PASS KOS governance trigger paths |

Covered Gate combinations include: `full` all-success, `docs_only` all-skipped, classify/lightweight failure, missing `requires_full`, any heavy skip/failure/cancel/missing on `full`, any heavy success/failure/missing on `docs_only`, and rejection of the legacy four-argument calling convention.

## Not run

- Hosted `full` and `docs_only` workflow fixtures
- KeyboardCore / RimeBridge / App+Keyboard `xcodebuild` / `swift test`
- Release `build`
- commit / push
