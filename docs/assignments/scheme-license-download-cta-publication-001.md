# Assignment: SCHEME-LICENSE-DOWNLOAD-CTA-PUBLICATION-001 — 有界 commit、push 与 draft PR

Policy version: 1.0.0\
Repository Change Type: Publication + Documentation

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Active` |
| **Phase** | MAIN-SYNC-001 已完成；post-rebase commit `270273a` 的本地全量门禁通过；等待该候选的新鲜 Quality 与 Human Gate |
| **Non-claims** | 未 push/开 PR；原 Product Gate/Quality 不覆盖新候选；原 publication AUTH 已 superseded；不授权 merge、TestFlight、Release |
| **Next** | 对 post-rebase 候选完成独立 Quality revalidation，再由 Human 作新 Gate 决定并签发匹配 publication AUTH |
| **Residuals** | RimeBridge 20 个 fixture/真实引擎用例、App + Keyboard 9 个 fixture/设备用例跳过；未声称真实下载/RIME 部署成功或 Device-attested |

## Authority

- **Assignment Authority / Product Approver:** Human Product Owner
- **Decision Source / Date:** 当前会话明确授权“commit 以及 push 并开 PR”；`2026-09-23 Asia/Shanghai`
- **Product Contract:** [`PD-SCHEME-LICENSE-DOWNLOAD-CTA-001`](../product-decisions/SCHEME-LICENSE-DOWNLOAD-CTA-001-authorization.md)
- **Product Gate:** [`Pass with conditions`](../product-decisions/SCHEME-LICENSE-DOWNLOAD-CTA-001-product-gate.md)；四项条件均接受
- **Prior Authorization:** [`AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-PUBLICATION-001`](../authorizations/AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-PUBLICATION-001.md) — superseded before push after remote conflict
- **Sync Authorization:** [`AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-MAIN-SYNC-001`](../authorizations/AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-MAIN-SYNC-001.md) — consumed; bounded rebase, named doc conflict resolution, and local validation completed
- **Domain Owner:** App & Data Operations Maintainer
- **Executor:** Current Codex task
- **Environment Executor:** Current Codex task in `/private/tmp/universe-keyboard-scheme-license-download-cta-001`
- **Human Dependency:** Human review of the draft PR and its hosted checks; merge remains separately authorized
- **Architecture Reviewer:** Not Applicable — implementation remains within accepted Product Gate and existing `SchemeLicenseView` + `startDownload` flow
- **Quality Reviewer:** Independent GPT-6 Luna [`Quality revalidation`](../reviews/scheme-license-download-cta-quality-revalidation-001.md) — Pass with conditions on its exact pre-writeback package; this publication slice does not change source/tests

## Bound candidate

| Item | Identity |
|---|---|
| Worktree | `/private/tmp/universe-keyboard-scheme-license-download-cta-001` |
| Branch | `grok/scheme-license-download-cta-001` |
| Starting HEAD | `80091f35cc5411b292eca78662f39e2b91694045` |
| Current `origin/main` observed after fetch | `a9b82a58cac0c28e8a5d8a957d464d803d6d92d1` (`origin/main` is 6 commits ahead of starting HEAD) |
| Post-rebase validated commit | `270273a9ab8d87386e317c691eb3f66734867e88` |
| Product Gate candidate | Pre-rebase candidate accepted by the linked Product Decision; that decision does not automatically cover the post-rebase HEAD |
| Quality package digest | `4f097b709ef993b0c81eb879f8d093c99213ae766c8397582a67ff1ada5f9f3e` (pre-Gate-writeback exact package; source/test bytes unchanged by Gate writeback) |

## Scope

1. Preserve one final local commit for the CTA implementation, tests, Product Gate records, and KOS status records.
2. Complete the authorized MAIN-SYNC child Assignment and its required post-rebase local quality checks.
3. Obtain new exact-candidate Quality and Human Product Gate dispositions, then issue a matching publication Authorization before push or PR.

## Non-goals

- Merge with newer `origin/main`
- Mark the PR ready for review, merge, close, or alter branch protection
- TestFlight, App Store Connect, Release, or further Simulator/device operation
- Any source/test change beyond formatting required by the repository's strict Swift-format gate

## Validation

| Check | Result |
|---|---|
| Strict Swift format | **Pass** — 9 changed Swift files linted with `--strict` |
| KeyboardCore | **Pass** — `swift test --package-path Packages/KeyboardCore`, 1,158 passed / 0 failed |
| RimeBridgeTests | **Pass** — iPhone 17 Pro / iOS 26.0 Simulator UUID `8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2`, 82 passed / 20 skipped / 0 failed (102 total) |
| App + Keyboard Debug | **Pass** — same Simulator, 394 passed / 9 skipped / 0 failed (UniverseKeyboardTests + KeyboardTests); all CTA cases ran |
| Universe Keyboard Release build | **Pass** — same Simulator destination |
| RIME Vendor verification | **Pass** — 12 framework artifacts verified |

The RimeBridge skips require fixture/real-engine environment variables. The 9 App + Keyboard skips are fixture-dependent scheme-resource tests and physical-device TD-012 tests. The Product Gate accepted its separately listed 9 non-CTA skips; skipped tests are not represented as passes.

## Markdown normalization

The Human Product Owner authorized presentation-only whitespace normalization and later authorized a bounded sync to current `origin/main` after a conflict was found. The linked [normalization receipt](../evidence/scheme-license-download-cta-markdown-normalization-2026-09-23.md) records exact old/new hashes for bound artifacts. Content equivalence was checked mechanically; the original Quality and Product Gate conclusions were not reissued. App, Keyboard, RimeBridge, KeyboardCore, and Release build suites were not rerun because no source, test, project, workflow, or CI-rule bytes changed. Required Markdown and record checks are recorded in the receipt.

## Entry / Exit / Stop

- **Entry:** Human commit/push/PR intent was recorded; current-main conflict triggered the authorized MAIN-SYNC child Assignment.
- **Exit:** only after fresh independent Quality, a new Human Product Gate decision, and a matching publication Authorization, followed by the separately authorized push and draft PR.
- **Stop:** any conflict outside the two named Markdown paths, any source/test change, a failed required check, or any publication before fresh candidate evidence and authority.
