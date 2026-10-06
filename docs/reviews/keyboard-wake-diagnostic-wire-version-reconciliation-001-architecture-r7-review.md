# Architecture R7 review — Accepted v6 Contract Translation

## Review identity

- Work item: `KEYBOARD-WAKE-DIAGNOSTIC-WIRE-VERSION-RECONCILIATION-001`
- Lane / round: Architecture & Knowledge Steward / R7
- Verdict: **Pass with conditions**
- Baseline: `84b9c19227330b0fe6ff391be001ee398010fd6a` (matched)
- Packet: [`Architecture R7 packet`](keyboard-wake-diagnostic-wire-version-reconciliation-001-architecture-r7-packet.md), SHA-256 `4c17a4cad12e12fec720c284dad09fa1394203f85cd3b42b1b3ca6fe491ea50c`
- Reconciliation Assignment: SHA-256 `6b9bbdc48e19a8e8676677e7b91e0411fb333da45fddf369dc70868a892fbcaa`
- Product Decision: SHA-256 `0736060e451428f368cec0feefb0fd1175e099dc1aa804e8f26768c5a74ef8c0`
- Proposed ADR 0036 Addendum 002: SHA-256 `accd1586baa0214368a1ee634c462447ce41a482cff27dbdba0710e514d03fc3`
- Paired-rollout Assignment: SHA-256 `64a48736363106878ee345f301b7cb0c376c8c93cbeb5a6a0d32d8ab7cfc5d42`

All packet and target digests matched. The prior paired-rollout authorization was verified as writer-v3 scoped and held at Entry; it does not authorize the revised v5 stage or v6 promotion.

## Findings

1. **Protocol translation — Pass.** The addendum preserves ADR 0036's one-static-wire-version-per-writer-build rule, retained-record versioning, no-rewrite behavior, and the accepted v6 product contract. The v5 producer-off compatibility candidate is separate from future v6 promotion.
2. **Reader and fallback — Pass with conditions.** The documents require a v6 reader for retained v3/v4/v5/v6 records, v6-labeled `typo_recall` and markers, bounded incomplete status for unsupported or malformed records, and suppression of legacy fallback. Duplicate JSON member detection remains a future implementation residual.
3. **Authority and lifecycle — Pass with conditions.** The prior writer-v3 authorization was held at Entry and is correctly excluded from current authority. The revised paired Assignment remains Assigned / Not Ready; fresh stage-specific authorization, role rebind, source ownership and a fresh exclusive Simulator reservation remain future Entry conditions.
4. **Scope and handoff — Pass.** Future KeyboardCore and Main App wire-version/reader changes are bounded by a future exact manifest and authorization. Input behavior, privacy, capture gates, retention, journal ownership/layout, RIME deployment and fallback semantics remain protected. Parent remains Active and root cause unresolved.

## Residual dispositions

| Residual ID | Owner | Disposition | Pointer |
|---|---|---|---|
| `ENTRY-ID-DRIFT-01` | Paired-rollout Executor / Product Lead | `accept` narrowly; exclude the historical hash transcription cell from current identity proof | [Product Decision](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-WIRE-VERSION-RECONCILIATION-001-product-decision.md) §Conditions carried forward; reconciliation Assignment §Residuals |
| `V6-READER-FALLBACK-MATRIX` | Future KeyboardCore / App & Data Operations implementation owners | `fix` before v6 promotion | Product Decision §Conditions carried forward; paired Assignment §Exit Criteria |
| `DUPLICATE-JSON-MEMBER` | Future KeyboardCore / Input Intelligence implementation owner | `fix` or obtain an exact Product disposition before claiming closed-object enforcement | Addendum 002 §Risks and Residuals; Product Decision §Conditions carried forward |
| `OLDER-READER-SAFETY` | Future paired-rollout owner | `accept` as an explicit non-claim; retain the same-build writer/reader gate | Addendum 002 §Risks and Residuals; paired Assignment §Paired rollout fence |
| `PAIRED-ENTRY-REBIND` | Product Lead / paired-rollout Executor | `fix` before Ready: current-scope role ACKs, fresh v5-stage authorization, source ownership and exclusive Simulator reservation | Paired Assignment §Current Status and §Entry Criteria |
| `V6-MAPS-DEPENDENCY` | Human Product Owner / paired-rollout Executor | `fix` before installation: rebind the Maps action to the exact v6 promotion candidate | Paired Assignment §Assignment Responsibilities and §Entry Criteria |

The exact-candidate Quality R5 review condition in the Architecture packet is satisfied by the matching Quality R5 result recorded separately.

## Non-claims

This review accepts only the bounded wire-version contract translation. It does not authorize source edits, tests, builds, Simulator use, installation, production marker emission, Maps reproduction, a Product/Quality Gate, Release, or parent closure. It does not establish runtime behavior, root cause, or a keyboard fix. No files were written by the reviewer; tests/builds and Simulator validation were not performed.

## Reviewer usage

The reviewer reported 6 `functions.exec` calls containing 16 `exec_command` calls, counted from visible tool activity. The reviewer read the packet, targets and specified protocol/authorization/manifest/history sources, and recomputed the packet, target and key source digests. No tests/builds, Simulator operations or file writes occurred. See the [Architecture R7 usage record](../evidence/keyboard-wake-diagnostic-wire-version-reconciliation-001-architecture-r7-usage-2026-09-30.md).
