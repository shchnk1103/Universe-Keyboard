# Authorization: TYPO-CORRECTION-002 recall remediation final publication lane 001

## Status

| Field | Value |
|---|---|
| **Authorization ID** | `AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-FINAL-PUBLICATION-001` |
| **Status** | `Consumed` for commit + push + PR; merge remains separately unauthorized |
| **Issued by** | Human Product Owner / Product Lead via current Codex task |
| **Issued at** | `2026-09-20 Asia/Shanghai` |
| **Lane** | Final publication-scope binding; external Git actions remain separately gated |
| **Parent Assignment** | `TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-001` |

## Exact binding

This Authorization binds any later publication decision to the exact reviewed staging snapshot:

| Item | Value |
|---|---|
| **Worktree** | `/private/tmp/universe-keyboard-typo-correction-002-recall-publication-staging-001` |
| **Branch** | `codex/typo-correction-002-recall-publication-staging-001` |
| **HEAD** | `162b09fd58ba60538a944026b1902efa405c75aa` |
| **HEAD tree** | `92c5047c5d1a6dd6a751eb5344117f8138c14ef2` |
| **Source manifest** | `docs/evidence/typo-correction-002-recall-remediation-publication-staging-source-manifest-2026-09-20-002.txt` |
| **Source manifest SHA-256** | `e2b4373c0797a0959b0b0da10c1db01cf4fa81cfe25903c7d9726942edab465c` |
| **Architecture review SHA-256** | `25dba823b50d12c3090346f408ae681719c852e998b3044a6751f525b9d4412b` |
| **Quality review SHA-256** | `9e498f60b7bb7477f994089137f797424c90d4e308ae580ca2bf4e73116fb6ae` |
| **Product decision SHA-256** | `f5f65777ee1584ed63fd87a04ea0244813442fbd13b7142d86f9cd0793481d24` |
| **Quality Run** | `TC2-RECALL-QUALITY-20260920-002` |

## Allowed scope

The current digest bindings above incorporate the separately Human-authorized
[docs-only reconciliation](../evidence/typo-correction-002-recall-remediation-digest-reconciliation-2026-09-20.md).
The original consumed publication permission is not reused; the historical allowed scope below
remains a record of preparation before the later explicit commit/push/PR authorization.

This Authorization permits only:

1. Preserving and rechecking the exact snapshot, source manifest, Architecture review, Quality
   review, Product decision, and their SHA-256 bindings.
2. Preparing a publication-scope report that lists the exact files, commit identity, branch, and
   required pre-publication checks, without changing those files.
3. Returning to the Product Owner for a separate, explicit choice of external Git actions.

The publication-scope report, if needed, may be written only to:

`docs/evidence/typo-correction-002-recall-remediation-final-publication-scope-2026-09-20.md`

Any later commit, push, PR, merge, TestFlight, Release, or deployment action must name its own
allowed action and be separately authorized. Authorization for one such action does not imply the
others.

## Explicit prohibitions

This Authorization does **not** allow:

- changing Swift, tests, Xcode, RIME, schema, vendor materialization, runtime code, or the five-file
  source allowlist;
- modifying Assignment files, `ACTIVE_WORK.md`, `KNOWLEDGE_INDEX.md`, reviews, or Product decisions;
- running build/test/format/vendor/install/deploy or a new Simulator/device Run;
- commit, push, PR creation, merge, TestFlight, Release, or any other external publication action;
- declaring Product/Quality/Release Gate, runtime/device acceptance, INT-003, QA-001, performance,
  180 ms, or parent/child closure.

## Required residuals

Any scope report must retain the Product decision boundaries: App + Keyboard authoritative
`387 = 378 passed + 9 skipped`, wrapper observation `388` non-authoritative, skipped tests and
current warnings as residuals, `CODE_SIGNING_ALLOWED=NO` as an environment limitation, and no
runtime/device/real-RIME/INT-003/QA-001/paired-performance/180 ms or Gate claims.

## Consumption receipt

- **Consumed at:** `2026-09-20 Asia/Shanghai`
- **Consumer:** current Codex task under explicit Human Product Owner authorization
- **Bound scope:** `docs/evidence/typo-correction-002-recall-remediation-final-publication-scope-2026-09-20.md`
- **Authorized actions:** commit the exact allowlist, push the named branch, and create one PR
- **Not authorized:** merge, TestFlight, Release, deployment, or Assignment close
- **Pre-action identity:** HEAD `162b09fd58ba60538a944026b1902efa405c75aa`; tree `92c5047c5d1a6dd6a751eb5344117f8138c14ef2`; source manifest `e2b4373c0797a0959b0b0da10c1db01cf4fa81cfe25903c7d9726942edab465c`
- **Completion receipt:** authorized actions completed as follows:
  - Commit: `61ad58b981fa97ec399dd7fc0c5fdaec458fe7fc` (`feat: add bounded typo recall remediation`)
  - Remote branch: `origin/codex/typo-correction-002-recall-publication-staging-001`
  - Draft PR: [#141](https://github.com/shchnk1103/Universe-Keyboard/pull/141)
  - The source manifest remains `e2b4373c0797a0959b0b0da10c1db01cf4fa81cfe25903c7d9726942edab465c`; no source drift was observed before publication.
  - Merge, TestFlight, Release, deployment, and Assignment close remain unperformed and separately unauthorized.
