# Quality R4 review packet — Wire-Version Reconciliation 001

## Review target

- Work item: `KEYBOARD-WAKE-DIAGNOSTIC-WIRE-VERSION-RECONCILIATION-001`
- Lane: Quality, Performance & Release Maintainer
- Round: 4 — substantive protocol-candidate completeness review
- Reviewed Assignment scope SHA-256: `edf450b3dbfbe621849d0fbf6bc641518cbc22e992fde6239034d05d2e7729c6`
- Assignment current full-file SHA-256, after the documented status/history-only Active transition: `6e94b19c21157a6b444158728d5cc294debb20b710b8498348eed3ef7bfb7585`
- Baseline: `84b9c19227330b0fe6ff391be001ee398010fd6a`
- Exact proposal candidate: `docs/plans/keyboard-wake-diagnostic-wire-version-reconciliation-001-proposal.md`
- Proposal candidate SHA-256: `3962a2f9bac051737319666775cd560c2730d776e89a141ae1ee8bcdfc71a9ed`
- Architecture R6 packet: `docs/reviews/keyboard-wake-diagnostic-wire-version-reconciliation-001-architecture-r6-packet.md`, SHA-256 `b5042e18752e6d920c9cf0be09d7f601416e66f827d91b137adaa9dc9953e778`
- Entry identity packet SHA-256: `3a0a27291fe653daf02191622fa1392522d17b648bd5cdf74e5f13155000179b`

The Entry transition explicitly binds the Assignment full-file change from `d43baef8…` to `6e94b19c…` as status/history-only. The reviewed scope and authority are unchanged; the Entry transition and revalidation confirm no other frozen identity mismatch. Treat this as the expected status-only identity, not unexplained drift.

## Frozen inputs

The independent Architecture packet is bound by the digest above. The candidate's identity list and source/test identities are in the Entry identity packet. Also inspect the exact Proposal 0.4, ADR 0036/acceptance, M-06 brief, v3 compatibility manifest r2, paired-rollout Assignment, and these consultation receipts:

- Keyboard Experience consultation SHA-256: `2f13638a50a928f99af923d53b7cca653021e5c06722310466632978b65cc727`.
- App & Data Operations consultation SHA-256: `8e7d788fc362c2ae1cde24a9dea1391415765dcda704119ff0abde93ebb01c0b`.
- Runtime Record API manifest `abbe6154d52b5b4e23fcde32cea455f2de93d9a3a56356ef77e12486217f975c` is historical input only, based on an older commit; it must not be counted as current integrated evidence.

## Review questions

1. Do the options and recommendation preserve the single-version writer invariant and preserve v5 `typo_recall` behavior without relabeling or rewriting retained history?
2. Does the v6 matrix cover retained v3/v4/v5/v6 and mixed versions, marker and typo-recall payloads under their permitted versions, unknown/future version rejection, malformed/unknown keys/codes/payloads, and older-reader non-claims?
3. Does the future reader contract explicitly require v6-labeled `typo_recall` output to be accepted by the v6 reader and retained v5 `typo_recall` to remain readable as v5? Does it require marker shapes to be supported both as v4 historical/fixture input and as v6 newly written data?
4. Is incomplete/unsupported status required to survive all applicable root, preview, and paging paths and suppress Main App legacy fallback, including v6-only empty-after-rejection and mixed v5/v6 records? Are current versus future test evidence claims separated?
5. Are isolated fixtures, producer-off compatibility status, same-build App + Extension identity, fresh source/test validation, new Simulator reservation, Product authorization, human Maps reproduction, and parent-active non-claims explicit?
6. Are there any omissions, contradictions, stale references, or unsupported validation/quality claims in the exact candidate?

## Required output

Return `Pass`, `Pass with conditions`, or `Block`, bind the verdict to the candidate and packet digests, list residual IDs/owners/dispositions, and identify tests/builds as not applicable for this document-only review rather than passed. Do not modify files, select the Product contract, run tests/builds, or operate the Simulator. This review does not constitute a Quality Gate, Product Gate, Release, or implementation authorization.
