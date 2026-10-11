# Frozen Architecture Review Packet — INT-003 Query-Cost P1

| Field | Frozen value |
|---|---|
| Work Item | `TYPO-CORRECTION-002-INT003-QUERY-COST-MEASUREMENT-001` |
| Stable lane ID | `TYPO-CORRECTION-002-INT003-QUERY-COST-P1-ARCH-001` |
| Review round | `2` |
| Reviewer | Fresh, independent Architecture & Knowledge Steward reviewer runtime, distinct from round 1 and from the P1 executor/coordinator. Record the dispatched reviewer identity in the result and usage record. |
| Source baseline | Current GitHub `main` after PR #182: `8e4ea0f1777f1175141731797afeee5ebd964c96` |
| Source manifest | [`source freeze r2`](../evidence/typo-correction-002-int003-query-cost-p1-arch-source-freeze-r2.json), SHA-256 `d8f7aa17906bfc1d6d1e9c1b39135fb71be80a94b210c81916095940a54fff5f` |
| Baseline delta since round 1 | PR #182 changed `DiagnosticEvent.swift` and `DiagnosticEventTests.swift`: added the finite `keychain_access_denied` RIME sync failure code and its round-trip test, without changing schema version 4. These exact files are part of the refreshed 28-file freeze. |
| Mutable review-input snapshots | Assignment `0b949e204ae367a09309ed03f67ed3bd6a8920660357b955fd0f38bd989acc9b`; P1 AUTH `0b8bd214ca356b83677ab7e1a8c1b876b3491b9e53205fcf221a3b1428b0ee63`; P2 AUTH `ed0c6c559ab3ae53e6945ac43ed538d137a2579d13cc64caf1497b799d1944ff`; revised P1 field design `f15fad352cabb623c1f4b0dc1cd3f3b505e345a456de00265cdec1c5a9d4c2e3`; measurement plan `c8f4b2020892f736f29fbb399ad35b019f54a253982f181c609d856742980ac9`; round-1 review `e0d0bc7677fa79b775a329e83b723e50cc088938f9156019164af37a91108ee1`; round-1 usage `6f048595c21fcc9f28690e759fce363e7aa322dee9c1fb71abde2bd5b7b93a61` (all SHA-256 of exact bytes at freeze) |
| Packet digest | `c3a5e9d53009953d48accf11a7e0369d25596bb545f14962c14df022debf5fb0` — replace this value with SHA-256 of the full UTF-8 packet after replacing this row's digest value with 64 ASCII `0` characters. Reviewer must independently reproduce the stored digest. |
| Assignment authority / expansion owner | Human Product Owner acting as Product Lead |
| Decision source | Human 2026-09-27 authorized completion of independent Architecture review, P1 baseline update, then continuation under the separate P1/P2 AUTHs. No merge, Gate, parent Close, TestFlight, Release, ADR acceptance, or `RimeRuntimeProvenance` restoration is included. |
| Required outputs | `docs/reviews/typo-correction-002-int003-query-cost-p1-architecture-review-r2.md` and `docs/evidence/typo-correction-002-int003-query-cost-p1-architecture-review-r2-usage.md` |

## Review question

Does the exact revised P1 proposal close the round-1 schema-compatibility and event-cardinality blockers while preserving the content-free bounded-observation contract, the installed correction-query route, sidecar-only RIME ownership, existing scheduling/fences, and the separate P1/P2 authorization boundary?

Review the revised [P1 field design](../plans/typo-correction-002-int003-query-cost-p1-field-review-001.md), [measurement plan](../plans/typo-correction-002-int003-query-cost-measurement-001.md), exact 28 source files from the manifest at the frozen baseline, Assignment, both AUTH records and the round-1 review/usage artifacts. Read only the paths named below. Treat chat history and mutable working-tree source as non-evidence. For source, use `git show 8e4ea0f1777f1175141731797afeee5ebd964c96:<path>`.

## Claims and complete-coverage criteria

For every claim, report `Pass`, `Pass with conditions`, `Blocker`, or `Uncovered`, with exact file/symbol locators and reasoning. The review is complete only when all seven claims have an explicit result.

1. **Stage provenance:** Verify Stage 1/2 can be tagged at the driver event source and remain stable across yielded turns without deriving stage from journal order or changing selection, debounce, yields, fences, or query budgets.
2. **Candidate-count meaning:** Verify `zero` / `one_to_three` counts only the candidates the coordinator receives after the current parser/limit path and existing `prefix(3)`, not the full RIME menu or candidate usefulness.
3. **Readiness and result state:** Verify same-call `ensureCorrectionSession` semantics; distinguish setup failure, `get_context == false`, ready-empty, non-RIME/test adapters, empty input, and zero limit without a probe call or second RIME route.
4. **Timing:** Verify the monotonic boundary around the complete installed facade, microsecond floor, zero, `UInt32.max` saturation, and the rule that this is facade duration rather than librime CPU time.
5. **Diagnostics protocol:** Assess schema v5 writes plus v4 historical decode, strict rejection of unsupported version/code/enum and missing/mismatched typed payload, raw JSONL retention, the one-terminal-event-per-facade-invocation cardinality, and the effects of PR #182 adding a new `RimeSyncFailure` enum case while schema version remained 4. Decide whether the proposed old-record compatibility rule is sufficiently precise under ADR 0027 and whether any required reader change falls outside P1's allowed files.
6. **Runtime ownership:** Verify stage/readiness propagation stays on the installed facade, keeps the correction sidecar session and serial/thread ownership, does not expose raw engine state or add a second query route, and respects ADRs 0004/0025 and Swift 6 isolation.
7. **Observer cost and censoring:** Verify event creation/admission stays outside the measured interval and bounded by existing high-fidelity ingress; post-call discard, pre-call cancel, queue/suspend loss, malformed lines, unknown values, sequence gaps, and incomplete/unsealed captures cannot be misrepresented as zero or successful queries. Confirm the plan reports exact totals only for complete sealed captures and otherwise treats the observed count as a lower bound with unknown missing-query count.

For each `Pass with conditions`, name the residual, owner and evidence needed. A blocker/uncovered claim must identify a repair and owner; it cannot be rounded into implementation approval. Do not authorize a scope expansion: the named Human Assignment Authority must approve any new source path or product boundary before a new packet is prepared.

## Frozen read/write boundary

The packet's source manifest lists the only 28 frozen source/test/governance files. Also read this packet and these exact snapshots:

- `docs/evidence/typo-correction-002-int003-query-cost-p1-arch-source-freeze-r2.json`
- `docs/assignments/typo-correction-002-int003-query-cost-measurement-001.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P1-INSTRUMENTATION-001.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-SIM-CAPTURE-001.md`
- `docs/plans/typo-correction-002-int003-query-cost-p1-field-review-001.md`
- `docs/plans/typo-correction-002-int003-query-cost-measurement-001.md`
- Round-1 Architecture review and usage listed in the snapshot table above.

The reviewer may write **only** the two required outputs named above. Do not edit source, Assignment, AUTH, plan, this packet or source manifest. No Git commit/push/PR operation, Simulator/device discovery or operation, build/test, journal/raw user-data access, network search, or source-branch rebinding is in scope. Read-only `git show`, hashing, `rg`, and file reading are allowed. At review start, record the frozen packet commit and independently verify the packet digest, all seven mutable-input hashes, the manifest digest, and all 28 baseline blob/SHA pairs. If any identity differs, stop before reviewing.

If a claim requires a path beyond the frozen manifest or P1 AUTH allowlist, mark it `Blocker` or `Uncovered`, name the exact missing boundary, and stop that dependent claim. The reviewer and coordinator cannot expand this packet; only the named Assignment Authority may authorize an exact expansion and a new frozen packet.

## Budget, checkpoints, and exhaustion

- Maximum: **20 read-only tool calls or 20 active minutes**, whichever comes first.
- Checkpoint at start and after every **5 tool calls or 5 active minutes**, whichever comes first. Record count/time and claim coverage in usage.
- Record reviewer identity, start/end time, actual tool-call count, elapsed active time, checkpoint notes, claims covered, remaining claims, and stop reason. If token usage is unavailable, record `unknown`; do not estimate.
- On exhaustion, stop with `Partial / incomplete`, list uncovered claims, and do not continue this round. Any further review requires a new numbered round, exact baseline/digest, and Human reauthorization if scope or budget changes.

No P1 AUTH consumption, implementation, P2 capture, Product budget decision, Product/QA-001 Gate, parent Close, TestFlight/Release, or ADR acceptance is part of this review lane.
