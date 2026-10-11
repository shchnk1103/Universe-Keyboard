# TYPO-CORRECTION-002 runtime-integration hardening blocker remediation — publication receipt 001

> **Status:** published as a draft pull request. This receipt records the exact
> local validation, push, and PR facts; it does not authorize merge.

## Bound source snapshot

| Fact | Value |
|---|---|
| Branch | `codex/typo-correction-002-runtime-hardening-blockers` |
| Base HEAD / `origin/main` | `4d1050f4b677494e06448cb40a83ef2da46d7b27` |
| Base tree | `5f864a6f6f139810ed59c7e00ab6c33caad7e500` |
| Reviewed source tracked-diff SHA-256 | `3f3de3aba53820340c25cafc6adaa87977c9ffe58b6a7e61e165c3c64e26db5e` |
| Reviewed source path count | `15` |
| Direct supporting KOS records copied | `63` runtime-integration / second-stage documents; QA, deployment and parent mirrors excluded |

## Local validation

| Check | Result |
|---|---|
| Swift format identity | pass; formatting preserved the reviewed source digest |
| Swift strict lint | pass |
| KeyboardCore | 1153 passed, 0 failed |
| RimeBridgeTests, iPhone 17 Pro `8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2` | 102 executed, 20 skipped, 0 failed; `TEST SUCCEEDED` |
| Universe Keyboard Debug test, same destination | UniverseKeyboardTests 373 executed / 9 skipped / 0 failed; KeyboardTests 15 passed; `TEST SUCCEEDED` |
| Release build, same destination | `BUILD SUCCEEDED` |
| Vendor dependency | pre-existing 12-artifact Vendor directory verified; temporary ignored symbolic link used only for local CI and removed before staging |

## Explicit boundaries

- The first two RimeBridge invocations using `name=iPhone 17 Pro` did not run tests because Xcode resolved `latest` to an unavailable runtime. They are environment diagnostics, not test failures or passing evidence. The exact booted UDID command above is the accepted result.
- This is not real-RIME input evidence, QA-001, INT-003, paired-performance evidence, a Product/Quality/Release Gate, merge, Release, TestFlight or parent Close.
- This receipt makes no hosted-CI green claim. Hosted CI must be checked afresh
  before any separately authorized merge decision.

## Publication facts

| Fact | Value |
|---|---|
| Publication authorization | Consumed at `2026-09-22T16:05:00+08:00` by the Current Codex task |
| Initial pushed tip | `eec461b37733e381b965b40c8fd86da434ed483a` |
| Remote branch | `origin/codex/typo-correction-002-runtime-hardening-blockers` |
| Pull request | [#144](https://github.com/shchnk1103/Universe-Keyboard/pull/144), **draft**, base `main` |
| Implementation commit | `ce5861542629e203370cad031ebd6ec580e826fe` |
| Documentation follow-up commits before this receipt | `f8dcb29770985ea9576db9278ab19feb1dae2c4d`, `4ca325d`, `87cfb66`, `93c91f9`, `24646f0`, `62c43af`, `eec461b` |
| Hosted CI | Not yet accepted or used as merge evidence |

This receipt is committed and pushed after the initial draft-PR creation. That
later docs-only commit advances the PR head, while the initial push fact above
remains historically accurate.
