# TYPO-CORRECTION-002 recall remediation final publication scope

- Scope ID: `TC2-RECALL-FINAL-PUBLICATION-SCOPE-20260920-001`
- Authorization: `AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-FINAL-PUBLICATION-001`
- Worktree: `/private/tmp/universe-keyboard-typo-correction-002-recall-publication-staging-001`
- Branch: `codex/typo-correction-002-recall-publication-staging-001`
- Pre-publication HEAD: `162b09fd58ba60538a944026b1902efa405c75aa`
- Pre-publication tree: `92c5047c5d1a6dd6a751eb5344117f8138c14ef2`
- Source manifest: `e2b4373c0797a0959b0b0da10c1db01cf4fa81cfe25903c7d9726942edab465c`

## Scope decision

本 scope 只包含 recall remediation 的四个 source/test 变更、直接 provenance 输入、recall 命名空间治理记录，以及三处最小共享镜像。它不吸收旧 mixed worktree、PR #140、sidecar observability、AX/testability 或 parent revalidation 的整套差异。

Quality Run 002、独立 Architecture/Quality review 和 Product decision 已绑定同一 source manifest。App + Keyboard 的权威结果为 `387 = 378 passed + 9 skipped`；`388` 仅保留为 wrapper/discovery observation。当前 warnings、skipped、`CODE_SIGNING_ALLOWED=NO` 和 runtime/device/performance non-claims 继续保留。

## Explicit allowlist

本次 commit 的显式 allowlist（共 88 项，另加本 scope report 本身）：

- `Packages/KeyboardCore/Sources/KeyboardCore/ContextualTypoCorrection.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallPreflight.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionRecallPreflightTests.swift`
- `UniverseKeyboardTests/RimeSettingsStoreTests.swift`
- `docs/ACTIVE_WORK.md`
- `docs/KNOWLEDGE_INDEX.md`
- `docs/assignments/typo-correction-002-recall-remediation-001.md`
- `docs/assignments/typo-correction-002-recall-remediation-core-contract-001.md`
- `docs/assignments/typo-correction-002-recall-remediation-implementation-preflight-001.md`
- `docs/assignments/typo-correction-002-recall-remediation-publication-preflight-001.md`
- `docs/assignments/typo-correction-002-recall-remediation-rime-vendor-materialization-001.md`
- `docs/assignments/typo-correction-002-recall-remediation-test-contract-environment-001.md`
- `docs/assignments/typo-correction-002.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-ARCHITECTURE-001.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-BASE-RECONCILIATION-PUBLICATION-STAGING-001.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-CONDITIONS-001.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-CONDITIONS-ARCHITECTURE-001.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-001.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-ARCHITECTURE-001.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-PRODUCT-DECISION-001.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-QUALITY-001.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-DEPENDENCY-CONTRACT-ALIGNMENT-CODE-FIX-001.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-DEPENDENCY-RECONCILIATION-001.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-DESIGN-001.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-FINAL-ARCHITECTURE-001.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-FINAL-PRODUCT-DECISION-001.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-FINAL-PUBLICATION-001.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-FINAL-QUALITY-001.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-IMPLEMENTATION-PREFLIGHT-001.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-IMPLEMENTATION-PREFLIGHT-ARCHITECTURE-001.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-IMPLEMENTATION-PREFLIGHT-PRODUCT-DECISION-001.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-IMPLEMENTATION-PREFLIGHT-QUALITY-001.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-PARENT-MIRROR-002.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-PRODUCT-DECISION-001.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-001.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-002.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-ARCHITECTURE-001.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-MANIFEST-ARCHITECTURE-002.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-MANIFEST-QUALITY-001.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-MANIFEST-RECONCILIATION-001.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-PRODUCT-DECISION-001.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-SCOPE-RECONCILIATION-001.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-QUALITY-RUN-001.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-RIME-VENDOR-MATERIALIZATION-001.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-RIME-VENDOR-MATERIALIZATION-002.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-TEST-CONTRACT-ENVIRONMENT-001.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-TEST-CONTRACT-ENVIRONMENT-MIRROR-001.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-TEST-CONTRACT-ENVIRONMENT-RECONCILIATION-001.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-TEST-CONTRACT-ENVIRONMENT-REVIEW-001.md`
- `docs/evidence/typo-correction-002-file-provenance-audit-2026-09-19.md`
- `docs/evidence/typo-correction-002-recall-coverage-matrix-2026-09-19.md`
- `docs/evidence/typo-correction-002-recall-remediation-publication-preflight-source-manifest-2026-09-20-002.txt`
- `docs/evidence/typo-correction-002-recall-remediation-core-contract-001.md`
- `docs/evidence/typo-correction-002-recall-remediation-dependency-contract-alignment-2026-09-20-001.md`
- `docs/evidence/typo-correction-002-recall-remediation-dependency-reconciliation-2026-09-20-001.md`
- `docs/evidence/typo-correction-002-recall-remediation-implementation-preflight-001.md`
- `docs/evidence/typo-correction-002-recall-remediation-publication-preflight-2026-09-20-002.md`
- `docs/evidence/typo-correction-002-recall-remediation-publication-preflight-2026-09-20.md`
- `docs/evidence/typo-correction-002-recall-remediation-publication-preflight-manifest-reconciliation-2026-09-20.md`
- `docs/evidence/typo-correction-002-recall-remediation-publication-scope-reconciliation-2026-09-20.md`
- `docs/evidence/typo-correction-002-recall-remediation-publication-staging-source-manifest-2026-09-20-001.txt`
- `docs/evidence/typo-correction-002-recall-remediation-publication-staging-source-manifest-2026-09-20-002.txt`
- `docs/evidence/typo-correction-002-recall-remediation-publication-staging-2026-09-20-001.md`
- `docs/evidence/typo-correction-002-recall-remediation-quality-run-2026-09-20-001.md`
- `docs/evidence/typo-correction-002-recall-remediation-quality-run-2026-09-20-002.md`
- `docs/evidence/typo-correction-002-recall-remediation-rime-vendor-materialization-2026-09-20-002.md`
- `docs/evidence/typo-correction-002-recall-remediation-rime-vendor-materialization-2026-09-20.md`
- `docs/evidence/typo-correction-002-recall-remediation-test-contract-environment-001.md`
- `docs/evidence/typo-correction-002-recall-remediation-test-contract-environment-reconciliation-2026-09-20.md`
- `docs/plans/typo-correction-002-recall-remediation-design-2026-09-19.md`
- `docs/product-decisions/TYPO-CORRECTION-002-RECALL-REMEDIATION-001-bounded-product-decision.md`
- `docs/product-decisions/TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-BOUNDED-DECISION-2026-09-20.md`
- `docs/product-decisions/TYPO-CORRECTION-002-RECALL-REMEDIATION-FINAL-BOUNDED-PUBLICATION-PREPARATION-DECISION-2026-09-20.md`
- `docs/product-decisions/TYPO-CORRECTION-002-RECALL-REMEDIATION-IMPLEMENTATION-PREFLIGHT-BOUNDED-DECISION-2026-09-20.md`
- `docs/product-decisions/TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-BOUNDED-DECISION-2026-09-20.md`
- `docs/reviews/typo-correction-002-recall-remediation-architecture-review-2026-09-20.md`
- `docs/reviews/typo-correction-002-recall-remediation-conditions-architecture-review-2026-09-20.md`
- `docs/reviews/typo-correction-002-recall-remediation-core-contract-architecture-review-2026-09-20.md`
- `docs/reviews/typo-correction-002-recall-remediation-core-contract-quality-review-2026-09-20.md`
- `docs/reviews/typo-correction-002-recall-remediation-final-architecture-review-2026-09-20.md`
- `docs/reviews/typo-correction-002-recall-remediation-final-quality-review-2026-09-20.md`
- `docs/reviews/typo-correction-002-recall-remediation-implementation-preflight-architecture-review-2026-09-20.md`
- `docs/reviews/typo-correction-002-recall-remediation-implementation-preflight-quality-review-2026-09-20.md`
- `docs/reviews/typo-correction-002-recall-remediation-publication-preflight-architecture-review-2026-09-20.md`
- `docs/reviews/typo-correction-002-recall-remediation-publication-preflight-manifest-architecture-review-2026-09-20.md`
- `docs/reviews/typo-correction-002-recall-remediation-publication-preflight-manifest-quality-review-2026-09-20.md`
- `docs/reviews/typo-correction-002-recall-remediation-test-contract-environment-architecture-review-2026-09-20.md`
- `docs/reviews/typo-correction-002-recall-remediation-test-contract-environment-quality-review-2026-09-20.md`

本 scope report 自身路径为：
- `docs/evidence/typo-correction-002-recall-remediation-final-publication-scope-2026-09-20.md`

## Explicit exclusions

以下内容不属于本次 commit：

- `docs/assignments/typo-correction-002-parent-revalidation-002.md`
- `docs/evidence/typo-correction-002-parent-checkpoint-2026-09-19.md`
- 任何未列出的 tracked/untracked 文件；
- 任何 PR #140、sidecar observability、AX/testability、parent revalidation 或其他工作车道差异。

## Action boundary

用户本轮明确授权：commit、push、创建 PR。merge、TestFlight、Release、部署和 parent/child close 仍未授权。Publication Authorization 的消费记录必须绑定本 scope，并记录最终 commit、remote branch 与 PR URL；不得把这些动作相互推导。

## Verification boundary

- source manifest 五项 hash 必须在 staging 前再次匹配；
- `git diff --check`、治理 validators、KOS trigger/final-gate checks 必须通过；
- Quality Run 002 的完整 Xcode/KeyboardCore 结果作为已绑定证据复用；本次 docs-only 镜像更新不改变 source manifest bytes；
- 如发现 source bytes、manifest、Allowlist 或 branch identity 漂移，停止 commit/push/PR。

## Completion receipt

- Commit: `61ad58b981fa97ec399dd7fc0c5fdaec458fe7fc` (`feat: add bounded typo recall remediation`)
- Remote branch: `origin/codex/typo-correction-002-recall-publication-staging-001`
- Draft PR: [#141](https://github.com/shchnk1103/Universe-Keyboard/pull/141)
- The commit contains the explicit allowlist plus this scope report; the two parent-revalidation residual files remain excluded and untracked in the staging worktree.
- Merge, TestFlight, Release, deployment, and parent/child closure were not performed.
