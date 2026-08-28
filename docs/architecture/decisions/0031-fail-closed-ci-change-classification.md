# ADR 0031: Fail-Closed CI Change Classification And Stable Final Gate

## Status

Accepted — Human Product Gate [`PD-TD-016-CI-TIERING-001-GATE`](../../product-decisions/TD-016-CI-TIERING-001-product-gate.md); independent Architecture revalidation Pass with conditions. Required-check trust-root migration remains [`TD-016`](../../TECH_DEBT.md#td-016-ci-变更分级与文档提交快速门禁).

## Context

The current workflow runs the complete Swift/RIME/Xcode suite for every documentation change. That preserves safety but spends hosted-runner time and encourages AI polling. Using workflow-level `paths-ignore` would be faster but can remove the check entirely and is unsafe for future required-check configuration.

The adopted KOS Kit repository is private. The current repository token is not assumed to have cross-repository read access, so remote KOS validation cannot depend on a PAT or undocumented private-action setting.

## Decision

1. An always-run classifier compares the exact base/head commits with rename detection disabled.
2. Only root Markdown, `docs/**` and `.kos/**` are light-path eligible.
3. Every other path, an empty diff, an invalid comparison or classifier error requires/fails toward the full path.
4. An always-run lightweight job checks diff whitespace, changed Markdown links and `.kos/project.json` JSON syntax.
5. The existing heavy Swift 6 steps remain together in `build-and-test` and run only when classification requires full validation.
6. An always-run `final-quality-gate` succeeds only when classification/lightweight checks pass and the heavy result is exactly success for full changes or skipped for light changes.
7. Same-PR stale runs are cancelled with workflow concurrency.
8. Full KOS validator remains a pinned local/pre-merge requirement for governance changes until a separately reviewed non-secret distribution path exists.

## Alternatives Considered

- **Workflow `paths-ignore`:** rejected because a future required workflow may remain absent/pending and there is no stable aggregate result.
- **Always run the full suite:** safe but retains TD-016 cost.
- **Allowlist every known source path:** rejected; maintaining a sensitive list can miss new paths. A tiny light allowlist makes unknown paths full by default.
- **Use a PAT to fetch the private Kit:** rejected because CI classification must not introduce long-lived cross-repository credentials.
- **Vendor the private validator:** deferred; it duplicates upstream code and needs provenance/licensing/update governance.

## Consequences

- Documentation-only PRs receive a stable final result without macOS/Xcode work.
- Any new or surprising path automatically runs the full suite.
- Workflow changes validate themselves through the full path.
- KOS governance changes get lightweight repository checks in CI and the pinned full validator locally; this residual is explicit rather than silently skipped.
- If branch protection is enabled later, configure `final-quality-gate` only after observing its name and behavior on both light and full PR fixtures.

## Risks

- A file under `docs/**` could contain tooling rather than documentation. Repository governance must not place executable build inputs there; if that changes, narrow the allowlist.
- GitHub expression/job-result semantics may differ from local script tests; the first hosted run is required evidence.
- Cancelling stale runs changes historical run completion state but not the final commit's required evidence.

## Follow-up Work

- Independent Architecture and Quality review.
- Human decision on stacked PR merge order.
- Separate Product decision if branch protection/required checks are enabled.
- Revisit remote KOS validator only when the Kit has a reviewed distribution mechanism.
