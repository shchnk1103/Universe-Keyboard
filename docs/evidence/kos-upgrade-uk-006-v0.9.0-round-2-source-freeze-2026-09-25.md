# KOS-UPGRADE-UK-006 — v0.9.0 Round 2 source freeze

## Purpose and boundary

This source map freezes the project authority and immutable KOS Kit inputs used
for the numbered Round 2 remediation review. It preserves the Round 1 packet,
assessment, source map and receipts without rewriting them. This is review
evidence only; it does not adopt KOS Kit v0.9.0, change the current pin,
authorize migration, or make a Product, Quality/Release or Gate decision.

## Universe Keyboard baseline

- Repository: `shchnk1103/Universe-Keyboard`
- Baseline: `main` commit `50cdccc8d07e70cb02987c9fe0a17be55291701d`
- Worktree: isolated detached checkout from freshly verified remote `main`.
- The following project facts are read from immutable blobs at this baseline:

| Path | Git blob | Relevance |
|---|---|---|
| `.kos/project.json` | `4bb9ea0f6a6dd48c02d2c82853fddcf59f49ec94` | Adopted pin and advisory mode |
| `docs/AI_WORKFLOW.md` | `e05152b5693f0300fbd9e3b521f7a26bf264ae4c` | General local delegation rules and explicit statement that the optional Kit orchestration package constrains lanes only after project adoption |
| `docs/ASSIGNMENT_POLICY.md` | `5225f009ce503907373e6cef6b057b23d2f7b3ff` | Assignment/lifecycle authority |
| `docs/kos/UPGRADE_STATUS.md` | `a16e1fcc1f06c06a559369e416087a21cafe4f8a` | Says agent-orchestration was available since v0.6.0 for future explicit use and that no repository-wide plan is instantiated |
| `docs/kos/upgrade-records/KOS-UPGRADE-UK-004-v0.8.0.md` | `68dccd938d341e557398183b1637c482b8aa42eb` | v0.8.0 adopted scope; orchestration is outside its four explicitly adopted contracts |
| `docs/assignments/kos-upgrade-uk-004-v0.8.0.md` | `2831c5429470f90757d0025c2ebb42199bb1d87d` | Prior adoption boundary |
| `docs/product-decisions/KOS-UPGRADE-UK-004-adoption.md` | `9f2f8d2b4cb85cfab1f553e30680560423865a51` | Product decision for the v0.8.0 advisory pin |
| `docs/kos/upgrade-records/KOS-UPGRADE-UK-005-release-evidence-v1.md` | `40d7758df859ef89767b821e05263cd2f9a0a210` | Existing release-evidence adoption |
| `docs/assignments/kos-upgrade-uk-005-release-evidence-v1.md` | `32795f9a5953d25ada6c6dee347d7d4b60fce8af` | UK-005 scope and validation boundary |
| `docs/product-decisions/KOS-UPGRADE-UK-005-release-evidence-adoption.md` | `859c6ed5c286e53a0cb691d88f5382763c96e8ab` | Adopted contract decision |
| `docs/kos/release-evidence-profile.md` | `12b212fa8f2a0c8f805792c5922abeb84f7ccf97` | Current adopter profile |

The current Profile pins KOS Kit `v0.8.0` commit
`2c9907565bf6b6fcd00e698cc539d9e2db573bc5` in `advisory` mode. It selectively
opts in to E-01, A-01/B-01, P-01 and D-01 for new records. It has not adopted
`ops/agent-orchestration.md`; `docs/kos/UPGRADE_STATUS.md` calls that package
available for future explicit use and says no `ORCHESTRATION_PLAN.md` is
instantiated. `docs/AI_WORKFLOW.md` supplies local general delegation guidance
and says the optional Kit contract constrains a lane only after explicit
project adoption. These two statements must not be collapsed into a claim that
the upstream optional contract is already adopted.

## KOS Kit v0.9.0 immutable identity

- Upstream repository: `shchnk1103/kos-agent-kit`
- Release observed in the prior source freeze: `v0.9.0`, URL
  `https://github.com/shchnk1103/kos-agent-kit/releases/tag/v0.9.0`, published
  `2026-09-24T15:42:53Z`.
- This recorded observation is coordinator evidence only. The Round 2 Quality
  reviewer must independently perform exactly one permitted read-only query of
  the current GitHub latest Release endpoint. A failed query is not retried.
- Annotated tag object: `4a386cdc07cc52a3da4d7cf77b429b874169becb`
- Peeled release commit: `c98b2813240e22b2ac7fec44b2445321b03f73e0`
- Release tag and source blobs are read from immutable Git objects, not from
  the KOS Kit working tree.

| KOS Kit v0.9.0 path | Git blob |
|---|---|
| `CHANGELOG.md` | `61cf5b4e040536b05c7441cce002c9f4a018f0d8` |
| `ops/kos-2.1-operational-maturity.md` | `939b240f64a747df9909752fe01e7f9a65015009` |
| `ops/agent-orchestration.md` | `68e407db265b3be0588dd59b1f86e2bd6b12a8de` |
| `ops/release-evidence.md` | `c547bc52e3d6378059158b05fcf30244c6457175` |
| `schemas/release-evidence-v1.schema.json` | `db8d631217b3ac95853097b750240cf5163b9099` |
| `scripts/validate_release_evidence.py` | `cbd4ea55874a33470185d6b916758b7fd47fff2e` |
| `templates/docs/ORCHESTRATION_PLAN.md` | `2eb798f0e51543e32a46e9e6f352d2e4c93e994a` |
| `docs/product-decisions/KOS-RELEASE-EVIDENCE-PORTABILITY-002-adoption.md` | `7e318b10ae3242813e31343a93cdb2a86c2279f8` |
| `docs/assignments/KOS-OPS-BOUNDARIES-001.md` | `d3f8bb55a8c6b3c9ec1af2dd9853f7140666822f` |

## Round 1 history carried forward

Round 1 is preserved at:

- [Round 1 assessment](../kos/upgrade-records/KOS-UPGRADE-UK-006-v0.9.0.md)
- [Round 1 source freeze](kos-upgrade-uk-006-v0.9.0-source-freeze-2026-09-25.md)
- [Round 1 Architecture receipt](../reviews/KOS-UPGRADE-UK-006-v0.9.0-architecture-review.md)
- [Round 1 Quality receipt](../reviews/KOS-UPGRADE-UK-006-v0.9.0-quality-review.md)

Round 1 Architecture passed A-01 through A-06 with no findings. Round 1 Quality
was `Partial / incomplete`, with four P2 findings:

| Finding | Round 2 disposition |
|---|---|
| `Q-UK006-Q01-01` — Quality's sole permitted latest-Release request failed | One independent read-only latest-Release query is allowed to the Round 2 Quality reviewer. It is not repeated if it fails. |
| `Q-UK006-Q03-01` — prior project adoption claim lacked an in-scope authority | Correct the assessment using the frozen `AI_WORKFLOW.md`, `UPGRADE_STATUS.md` and UK-004 decision/record. State that the upstream optional package is available but not adopted or instantiated. |
| `Q-UK006-Q03-02` — assessment omitted mandatory lane identity fields | Explicitly name Work Item, lane ID, positive review round, exact baseline and packet digest, plus the remaining required scope, boundary, acceptance, budget and stop fields. |
| `Q-UK006-Q06-01` — `HEAD..HEAD` checker invocation covered zero injected Markdown files | Round 2 Quality must directly invoke the repository checker's `missing_links(path, repository_root)` function on the exact frozen source map and assessment, and verify whitespace on those same files. It must report the number and paths actually checked. |

## Exact UK-005 contract comparison

The already-adopted `kos.release-evidence` v1.0 contract, schema and evaluator
have SHA-256 values:

- Contract: `f7ec8d9363cc37e53201e8bf990af80ba77fc9f88b7f78371d2c39f453a78673`
- Schema: `4e48bcf127edb87e67c4d390a3baec93af26ef72aa251e8172cb1044dca893ce`
- Evaluator: `a45145681306c2da581f1054f002b7becd909d1bb4a8329ad14892f17839b9d9`

The three files at the immutable v0.9.0 tag have the same SHA-256 values and a
byte-level `git diff --quiet 8e55551..v0.9.0` comparison succeeded. Round 2
must preserve the UK-005 decision/profile and avoid implying a new contract or
implementation review.

## Scope notes

- Review only the v0.9.0 M-02 trigger/closeout rule, reviewer scope/budget/stop
  clauses, the corrected project-applicability assessment and exact UK-005
  contract identity.
- The optional orchestration contract was not previously adopted. Any future
  adoption remains a separate Product decision and would apply prospectively.
- Simulator/CoreDevice discovery and Accessibility/Device Hub diagnostics are
  unchanged by v0.9.0 and outside this review.
- No code tests, builds, devices, application-release evidence, hosted CI,
  KOS validator, GitHub writes, commit, push, PR, merge, tag or Release action
  is included.
