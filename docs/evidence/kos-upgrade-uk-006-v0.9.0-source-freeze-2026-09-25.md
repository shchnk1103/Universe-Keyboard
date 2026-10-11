# KOS-UPGRADE-UK-006 — v0.9.0 source freeze

## Purpose and boundary

This source map freezes the project baseline and the specific KOS Kit v0.9.0
inputs used for the adopter review. It is review evidence only. It does not adopt
v0.9.0, change the current pin, authorize migration, or produce a Product,
Quality/Release or Gate decision.

## Universe Keyboard baseline

- Repository: `shchnk1103/Universe-Keyboard`
- Baseline: `main` commit `50cdccc8d07e70cb02987c9fe0a17be55291701d`
- Worktree: clean detached checkout created from the freshly verified remote `main`.
- Relevant committed source blobs:

| Path | Git blob |
|---|---|
| `.kos/project.json` | `4bb9ea0f6a6dd48c02d2c82853fddcf59f49ec94` |
| `docs/ASSIGNMENT_POLICY.md` | `5225f009ce503907373e6cef6b057b23d2f7b3ff` |
| `docs/AI_WORKFLOW.md` | `e05152b5693f0300fbd9e3b521f7a26bf264ae4c` |
| `docs/kos/knowledge-os-2.0-specification.md` | `38bfb5f7a86e6cf3a16dd2f9ca4b0e49555c41ef` |
| `docs/kos/kos-2.1-operational-maturity.md` | `78b50100c6a0febf22a4a755d55f0f344c536a59` |
| `docs/kos/UPGRADE_STATUS.md` | `a16e1fcc1f06c06a559369e416087a21cafe4f8a` |
| `docs/kos/upgrade-records/KOS-UPGRADE-UK-004-v0.8.0.md` | `68dccd938d341e557398183b1637c482b8aa42eb` |
| `docs/assignments/kos-upgrade-uk-004-v0.8.0.md` | `2831c5429470f90757d0025c2ebb42199bb1d87d` |
| `docs/product-decisions/KOS-UPGRADE-UK-004-adoption.md` | `9f2f8d2b4cb85cfab1f553e30680560423865a51` |
| `docs/kos/upgrade-records/KOS-UPGRADE-UK-005-release-evidence-v1.md` | `40d7758df859ef89767b821e05263cd2f9a0a210` |
| `docs/assignments/kos-upgrade-uk-005-release-evidence-v1.md` | `32795f9a5953d25ada6c6dee347d7d4b60fce8af` |
| `docs/product-decisions/KOS-UPGRADE-UK-005-release-evidence-adoption.md` | `859c6ed5c286e53a0cb691d88f5382763c96e8ab` |
| `docs/kos/release-evidence-profile.md` | `12b212fa8f2a0c8f805792c5922abeb84f7ccf97` |

The current Profile pins KOS Kit `v0.8.0` commit
`2c9907565bf6b6fcd00e698cc539d9e2db573bc5` in advisory mode. E-01, A-01/B-01,
P-01 and D-01 remain explicit opt-ins for new records. `required` and migration
of existing Active Assignments remain unauthorized.

## KOS Kit release identity and hosted check

- Upstream repository: `shchnk1103/kos-agent-kit`
- GitHub `latest` Release API was queried read-only on `2026-09-25`
  (`GET /repos/shchnk1103/kos-agent-kit/releases/latest`). It returned
  `v0.9.0`, URL `https://github.com/shchnk1103/kos-agent-kit/releases/tag/v0.9.0`,
  published at `2026-09-24T15:42:53Z`.
- Annotated tag object: `4a386cdc07cc52a3da4d7cf77b429b874169becb`
- Peeled release commit: `c98b2813240e22b2ac7fec44b2445321b03f73e0`
- Read-only verification command:
  `gh api repos/shchnk1103/kos-agent-kit/releases/latest --jq '[.tag_name, .html_url, .published_at] | @tsv'`

The tag and its files were read by immutable Git object ID. No remote refs or
repository state were changed during this review.

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

## Exact contract comparison

Universe Keyboard's UK-005 adoption pins the `kos.release-evidence` v1.0
contract source digest `f7ec8d9363cc37e53201e8bf990af80ba77fc9f88b7f78371d2c39f453a78673`,
schema digest `4e48bcf127edb87e67c4d390a3baec93af26ef72aa251e8172cb1044dca893ce`,
and evaluator digest `a45145681306c2da581f1054f002b7becd909d1bb4a8329ad14892f17839b9d9`.
Those exact SHA-256 values match the three files at the v0.9.0 tag. A byte-level
`git diff --quiet 8e55551..v0.9.0` over these files returned success. The Kit
release therefore packages the already-adopted contract unchanged; this review
does not repeat UK-005 implementation review or migrate its existing work.

## Scope notes

- v0.9.0 is described upstream as a compatible optional-ops release. The review
  concerns the new M-02 trigger/closeout rule and the reviewer scope/budget/stop
  rules in the existing optional orchestration contract.
- This review explicitly checks that the release-evidence contract is unchanged
  from the UK-005 adopted candidate.
- Simulator/CoreDevice discovery and Accessibility/Device Hub diagnostics are
  not changed by the reviewed v0.9.0 sources and are outside this review.
- No source code, test target, device, app-release evidence candidate, hosted CI
  run, KOS validator, commit, push, PR, merge, tag or Release action is included.
