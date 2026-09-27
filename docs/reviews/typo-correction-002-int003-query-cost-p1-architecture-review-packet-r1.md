# Frozen Architecture Review Packet — INT-003 Query-Cost P1

| Field | Frozen value |
|---|---|
| Work Item | `TYPO-CORRECTION-002-INT003-QUERY-COST-MEASUREMENT-001` |
| Stable lane ID | `TYPO-CORRECTION-002-INT003-QUERY-COST-P1-ARCH-001` |
| Review round | `1` |
| Reviewer | Fresh, independent Architecture & Knowledge Steward reviewer runtime; the P1 executor/coordinator is excluded from review. Record the dispatched reviewer identity in the result and usage record. |
| Source baseline | P1 source baseline `2b9b15ee2d1d903b3a948109b2c2217535bd5248` (PR #181 merge tip recorded for the rebound) |
| Source manifest | [`source freeze r1`](../evidence/typo-correction-002-int003-query-cost-p1-arch-source-freeze-r1.json), SHA-256 `5c19b79be205ba9afe2e50f321283071695c0b2dd9c4bdda9a4723af535b6d8a` |
| Mutable review-input snapshots | Assignment `138e8aa795f4ab9f16cd1fc1fec2206f7455fb5d443598c912d96f986fbbb347`; P1 AUTH `aa8ed1780114a38ec277a92e63eebe47d6c4d5d1a37ef7ef1073922f5fb0b125`; P2 AUTH `ed0c6c559ab3ae53e6945ac43ed538d137a2579d13cc64caf1497b799d1944ff`; P1 field design `9d010f86c132c19179d867d78eff70332f06cfa5ddfbb85abbae7ae1b2a3a4a2`; measurement plan `2381b36e5ce566fc6bb8e2d6af84a8b3437a3a1d75e3aab52a9b36c028900825` (SHA-256, exact current bytes at packet freeze) |
| Packet digest | `ecc05ba189e9115d76e645c0a3d32e7ccae3beb0095efeacce5c23c4535fa986` — SHA-256 of the full UTF-8 file after replacing the value in this row with 64 ASCII `0` characters. The reviewer must independently reproduce the stored value by making that replacement. |
| Assignment authority / expansion owner | Human Product Owner acting as Product Lead |
| Decision source | Human 2026-09-27 expressly authorized completion of the independent Architecture review, P1 baseline update, and subsequent work under the separate P1/P2 AUTHs. |
| Required outputs | `docs/reviews/typo-correction-002-int003-query-cost-p1-architecture-review-r1.md` and `docs/evidence/typo-correction-002-int003-query-cost-p1-architecture-review-r1-usage.md` |

## Review question

Can the proposed P1 instrumentation distinguish Stage 1 from Stage 2, zero from nonzero returned candidates, and sidecar unavailable from ready-but-empty calls while measuring the installed query-facade duration accurately, with content-free bounded diagnostics and without changing scheduling, the user-visible query route, RIME session ownership, or the input hot-path safety contract?

Review the proposal in [`P1 field design`](../plans/typo-correction-002-int003-query-cost-p1-field-review-001.md), the exact source files in the frozen source manifest, the Assignment, both Authorization records, the field design and measurement plan at the frozen SHA-256 values above, ADR 0004, ADR 0025, ADR 0027, and the listed KeyboardCore/RimeBridge playbooks. Treat chat history as non-evidence.

## Claims and complete-coverage criteria

For every claim below, report `Pass`, `Pass with conditions`, `Blocker`, or `Uncovered`, with exact file/symbol locators and reasoning. The round is complete only when all seven claims have an explicit result.

1. **Stage provenance:** Determine whether Stage 1/2 can be tagged at the driver event source without deriving it from journal order or changing selection, debounce, yields, fences, or query budgets.
2. **Candidate-count meaning:** Determine whether the proposed `0` / `1–3` value unambiguously counts candidates returned to the coordinator after the existing limit, rather than claiming the full RIME menu size or usefulness.
3. **Sidecar readiness:** Assess whether `ready` can mean the correction sidecar session passed `ensureCorrectionSession`, `unavailable` can represent its failure, and `unknown` can cover non-RIME/test adapters, while keeping a ready empty result distinct from setup failure and `get_context` behavior explicit.
4. **Timing precision and name:** Assess the monotonic timing boundaries around the installed facade. Existing `elapsed_ms` uses integer milliseconds while prior calls were around `0.010 ms`; decide whether a bounded microsecond field or timing buckets are needed and prevent a facade duration from being described as RIME CPU time.
5. **Diagnostics protocol:** Review finite field types, schema evolution/backward decoding, event volume, bounded queue behavior, drop visibility, and test coverage under ADR 0027. Do not approve free text, candidate/input/host text, a new stable fingerprint, synchronous persistence, or an unreviewed reuse of `compositionFingerprint`.
6. **Runtime ownership:** Confirm the proposal stays on the already-installed correction-query facade, preserves the sidecar-only session and serialized librime access, does not expose a raw engine or add a second RIME route, and is compatible with ADRs 0004/0025 and Swift 6 isolation.
7. **Observer cost and censoring:** Assess whether event generation can avoid material hot-path overhead and whether cancelled, discarded, dropped, incomplete, and unknown outcomes remain explicit rather than being counted as successful nonempty queries.

An approval requires complete coverage of all seven claims and an explicit recommendation for any `Pass with conditions` residual. A blocker or uncovered claim must name the exact repair/owner and cannot be converted into a P1 implementation approval.

## Frozen read/write boundary

Read only the 28 paths enumerated by the source manifest, plus this packet and these exact mutable record snapshots from the frozen packet commit:

- `docs/assignments/typo-correction-002-int003-query-cost-measurement-001.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P1-INSTRUMENTATION-001.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-SIM-CAPTURE-001.md`
- `docs/plans/typo-correction-002-int003-query-cost-p1-field-review-001.md`
- `docs/plans/typo-correction-002-int003-query-cost-measurement-001.md`

The reviewer may write **only** the two required outputs named above. Do not edit source, Assignment, AUTH, plan, this packet or the manifest. No Git commit/push/PR operation, Simulator/device discovery or operation, build/test, journal access, network search, or raw-user-data inspection is in scope. Read-only `git show`, hash verification, `rg`, and file reading are allowed. At review start, record the packet commit and independently verify every mutable-input hash above; if the working tree snapshot does not match, stop before reviewing.

If a file/hash differs, a required claim needs another input, or the reviewer finds a product/session/privacy boundary change, provide one locator and reason, mark the dependent claim `Uncovered` or `Blocker`, and stop that claim. The reviewer and Coordinator cannot expand this packet; only the named Assignment Authority may approve an exact expansion and new frozen packet.

## Budget, checkpoints, and exhaustion

- Maximum: **20 read-only tool calls or 20 active minutes**, whichever comes first.
- Checkpoint at start and after every **5 tool calls or 5 active minutes**, whichever comes first. Record the count/time and coverage state in the usage record.
- Record reviewer identity, start/end time, actual tool-call count, elapsed active time, checkpoint notes, covered claims, remaining claims, and stop reason. If token usage is unavailable, record `unknown` rather than estimating.
- On exhaustion, stop and write `Partial / incomplete`; list uncovered claims and do not continue in this round. Any additional review requires a new numbered round, new exact baseline and digest, and a new authorization decision if scope or budget changes.

No P1 AUTH consumption, implementation, product budget decision, Product/QA-001 Gate, parent Close, TestFlight/Release, or ADR acceptance is part of this review lane.
