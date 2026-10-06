# Architecture R7 review packet — Accepted v6 Contract Translation

## Review target

- Work item: `KEYBOARD-WAKE-DIAGNOSTIC-WIRE-VERSION-RECONCILIATION-001`
- Lane: Architecture & Knowledge Steward
- Round: 7 — exact ADR and paired-rollout translation review
- Baseline: `84b9c19227330b0fe6ff391be001ee398010fd6a`
- Reconciliation Assignment SHA-256: `6b9bbdc48e19a8e8676677e7b91e0411fb333da45fddf369dc70868a892fbcaa`
- Product Decision SHA-256: `0736060e451428f368cec0feefb0fd1175e099dc1aa804e8f26768c5a74ef8c0`
- Proposed ADR 0036 Addendum 002 SHA-256: `accd1586baa0214368a1ee634c462447ce41a482cff27dbdba0710e514d03fc3`
- Paired-rollout Assignment SHA-256: `64a48736363106878ee345f301b7cb0c376c8c93cbeb5a6a0d32d8ab7cfc5d42`

## Exact governing inputs

| Input | SHA-256 | Use |
|---|---|---|
| Wire-version proposal | `3962a2f9bac051737319666775cd560c2730d776e89a141ae1ee8bcdfc71a9ed` | Product-selected v6 contract and alternatives |
| Accepted ADR 0036 | `f950e4ee62c643efb21308cd7d633844379cb373fcde2e3e5604e5988fe5959c` | Existing static writer and history invariants |
| Prior paired-rollout implementation authorization | `3f6b0e81362063ba586d454593e22415093eba848c178fde7507262dd144a056` | Provenance check; explicitly writer-v3 and held at Entry |
| Entry identity packet | `3a0a27291fe653daf02191622fa1392522d17b648bd5cdf74e5f13155000179b` | Frozen v5 candidate/source identity context |
| v5 compatibility manifest r2 | `c75a75bd8ed180149a7bc8cb6c26a5fa5e4f5cbec122eede980f73a4d8cef835` | Writer-v5, reader-v3/v4/v5, producer-off candidate boundary |
| Prior Architecture protocol review | `20d861d81585c490588676e858725c1851a8183654efc5ed49d18d0dfd611af5` | Conditions carried into the accepted product contract |
| Prior Quality protocol review | `3a64f5084818a1dcc9d7dfedc6caed26851ca4947c1019adc8509674955891fc` | Coverage and residual conditions carried forward |
| Parent diagnostic Assignment | `54e075e651c7129d98eecc5fc9cac34f91e6bcc1d4dfb12b791a9829a83720c0` | Parent stays Active; root cause unresolved |

Recompute the reviewed-target digests before review. Stop if any listed artifact no longer matches. The Product Decision authorizes only bounded document follow-through; the proposed Addendum is not yet an accepted ADR source. The paired Assignment is intended to remain Assigned / Not Ready.

## Review questions

1. Does Addendum 002 preserve the accepted ADR 0036 static writer-version invariant and accurately translate the Human Product Owner's accepted v6 contract without changing its semantics?
2. Are the separate writer-v5 producer-off compatibility candidate and future writer-v6 promotion candidate consistent across the Product Decision, proposed Addendum, and paired-rollout Assignment?
3. Are retained v3/v4/v5 records preserved by their own versions; are new v6-build records uniformly v6, including `typo_recall`; and are unknown/malformed/rejected records required to remain incomplete and suppress legacy fallback?
4. Does the paired Assignment accurately distinguish historical writer-v3 authorization held at Entry from current/future authority? Are Entry, Ready, Active, stage-specific implementation authorization, v6 promotion authorization, same-build identity, and Simulator reservation ordered without granting implementation now?
5. Are KeyboardCore and Main App reader/version changes bounded to the exact future manifest, with input/session behavior, privacy, capture gates, retention, journal ownership/layout, RIME deployment, and fallback semantics protected?
6. Are the current role rebind, future Maps dependency, Architecture/Quality review, parent-active/root-cause non-claims, and handoff sufficient and non-contradictory?
7. Identify any stale historical text that could be mistaken as current authority, and any contract, lifecycle, or source-of-truth defect that blocks accepting Addendum 002.

## Required output

Return `Pass`, `Pass with conditions`, or `Block`, bound to this packet and all four reviewed-target digests. List findings with residual ID, owner, disposition and evidence pointer. State explicitly that the review does not authorize source edits, tests, builds, Simulator use, installation, production marker emission, Maps reproduction, a Product/Quality Gate, Release, or parent closure. Do not modify files or write the review receipt; the coordinator records the result.
