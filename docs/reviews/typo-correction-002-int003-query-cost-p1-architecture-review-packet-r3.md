# Frozen Architecture Review Packet — INT-003 Query-Cost P1

| Field | Frozen value |
|---|---|
| Work Item | `TYPO-CORRECTION-002-INT003-QUERY-COST-MEASUREMENT-001` |
| Stable lane ID | `TYPO-CORRECTION-002-INT003-QUERY-COST-P1-ARCH-001` |
| Review round | `3` |
| Reviewer | Fresh, independent Architecture & Knowledge Steward runtime, distinct from rounds 1 and 2 and from the P1 executor/coordinator. Record reviewer identity in both outputs. |
| Source baseline | P1 AUTH-bound snapshot `1160ac6fd8696c3036391cdf59bc9fe096d0b219` (PR #183 merge). The last recorded GitHub-main validation bound P1 to this tip; this environment cannot refresh GitHub state during this review. Do not describe this packet as a newly live-verified main tip. |
| Source manifest | [`source freeze r3`](../evidence/typo-correction-002-int003-query-cost-p1-arch-source-freeze-r3.json), SHA-256 `a98a722b03e2c66de61ab41ae30f59791ccb53a3b365f55a18e96d373732b395`; all 28 entries are bound to the exact baseline above. |
| Baseline delta | PR #182 added `keychain_access_denied` to `DiagnosticEvent.RimeSyncFailure` and a test while retaining schema version 4. PR #183 advanced the documented P1 baseline with documentation-only paths outside the 28-file freeze. Both commits are present in the frozen history. |
| Frozen input snapshots | Assignment `e641d6b6a540cac899cb8fd493cc213cd40a8b5b035c98ff90a6fe0b64a99487`; P1 AUTH `e5ae1cf319262df48752fd423e3db76354b80084e6a14db64db1a49be8966f8b`; P2 AUTH `ed0c6c559ab3ae53e6945ac43ed538d137a2579d13cc64caf1497b799d1944ff`; revised P1 field design `18fc4813cabf8c55a41b4c77541dd5aee1fbab6a0533a6cd608a3e0a44ed2f6a`; measurement plan `82cca40b47e09131c4e82666112ebb73877a076be67e7e37d45ce2ce6b6cc5f8`; round-1 review `e0d0bc7677fa79b775a329e83b723e50cc088938f9156019164af37a91108ee1`; round-1 usage `6f048595c21fcc9f28690e759fce363e7aa322dee9c1fb71abde2bd5b7b93a61`; round-2 review `d91e2a0aa7c62695d56959ddf1d6fe102f8024ccf37c555a8fb895e9732319ee`; round-2 usage `817c7813dcac3ea32e9a4325d544a04074ea847b2ef8348a570b326eb9e4aee9`. Each is SHA-256 of exact file bytes at freeze. |
| Packet digest | `513b26ed593906b20597091e016e1648e6a27c6d231642b92179cbb994d37f9f` — replace this row's value with SHA-256 of the full UTF-8 packet after replacing that value with 64 ASCII `0` characters. The reviewer must independently reproduce it. |
| Assignment authority / expansion owner | Human Product Owner acting as Product Lead |
| Decision source | Human 2026-09-27 Asia/Shanghai authorized the independent Architecture review, P1 baseline update and subsequent progress under the separate P1/P2 AUTHs. This does not authorize merge, Gate, parent Close, TestFlight, Release, ADR acceptance or restoration of `RimeRuntimeProvenance`. |
| Required outputs | `docs/reviews/typo-correction-002-int003-query-cost-p1-architecture-review-r3.md` and `docs/evidence/typo-correction-002-int003-query-cost-p1-architecture-review-r3-usage.md` |

## Review question

Does the exact round-3 P1 proposal resolve the round-2 writer-API blocker and observer-cost coverage gap while keeping every source change within the current P1 AUTH allowlist, preserving the content-free bounded-observation contract, the installed correction-query route, sidecar-only RIME ownership, existing scheduling/fences, and the separate P1/P2 authority boundary?

Review the revised [P1 field design](../plans/typo-correction-002-int003-query-cost-p1-field-review-001.md), [measurement plan](../plans/typo-correction-002-int003-query-cost-measurement-001.md), exact 28 source/test/governance files from the manifest at baseline `1160ac6fd8696c3036391cdf59bc9fe096d0b219`, Assignment, both AUTH records, and round-1/round-2 review plus usage artifacts. Treat chat history and mutable working-tree source as non-evidence. Read source only with `git show 1160ac6fd8696c3036391cdf59bc9fe096d0b219:<path>`.

## Claims and complete-coverage criteria

For every claim, report `Pass`, `Pass with conditions`, `Blocker`, or `Uncovered`, with exact file/symbol locators and reasoning. Complete review requires an explicit result for all seven claims and an explicit disposition of the round-2 Claim 5 Blocker and Claim 7 Uncovered finding.

1. **Stage provenance:** Verify Stage 1/2 are attached at the driver dequeue point, remain stable across yields, and do not derive from journal order or change selection, debounce, yields, fences or query budgets.
2. **Candidate-count meaning:** Verify `zero` / `one_to_three` counts only the candidates the coordinator receives after the current parser/limit path and existing `prefix(3)`, not the full RIME menu or candidate usefulness.
3. **Readiness and result state:** Verify same-call `ensureCorrectionSession` semantics; distinguish setup failure, `get_context == false`, ready-empty, non-RIME/test adapters, empty input and zero limit. Confirm empty-input precedence over zero limit and that nonempty unrecognized input follows the ordinary query path without a new probe or second RIME route.
4. **Timing:** Verify the monotonic boundary around the complete installed facade, microsecond floor, true sub-microsecond zero, `UInt32.max` saturation and explicit clock-regression censoring. Confirm this is facade duration, not librime CPU time.
5. **Diagnostics protocol and writer boundary:** Determine whether exactly one closed `DiagnosticEvent.Field.typoRecallQuery(payload)` can carry the finite payload through the existing `DiagnosticsJournalRuntime.record(code:fields:)` API without changing `DiagnosticsJournalRuntime.swift` or another out-of-scope path. Verify schema-v5 write constraints; v4 historical decoding; schema/code/field cross-validation; rejection of unsupported schema, code and finite enum values; missing, duplicate, extra or mismatched query fields; PR #182's `keychain_access_denied` v4 boundary; raw JSONL retention; and per-line reader omission/censoring behavior. Decide whether the compatibility contract is implementable and precise under ADR 0027.
6. **Runtime ownership:** Verify propagation stays on the installed correction facade, preserves the correction sidecar session and thread/serial ownership, does not expose raw engine state or add a second query route, and respects ADRs 0004/0025 and Swift 6 isolation.
7. **Observer cost and censoring:** Verify event construction/admission is outside the measured interval and bounded by existing high-fidelity ingress. Confirm post-call discard, pre-call cancel, queue/suspend loss, malformed or unsupported lines, sequence gaps and incomplete/unsealed captures cannot be misrepresented as zero or successful queries. Confirm exact totals require a complete sealed segment and otherwise the observed count is only a lower bound with the missing-query count unknown.

For each `Pass with conditions`, name the residual, owner and evidence needed. A blocker/uncovered claim must identify the specific repair and owner; it cannot be rounded into implementation approval. Do not authorize scope expansion. The Product Lead named as Assignment Authority must approve any new path or product boundary before a new packet is prepared.

## Frozen read/write boundary

The R3 source manifest lists the only 28 source/test/governance files. In addition to this packet, read only these exact frozen inputs:

- `docs/evidence/typo-correction-002-int003-query-cost-p1-arch-source-freeze-r3.json`
- `docs/assignments/typo-correction-002-int003-query-cost-measurement-001.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P1-INSTRUMENTATION-001.md`
- `docs/authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-SIM-CAPTURE-001.md`
- `docs/plans/typo-correction-002-int003-query-cost-p1-field-review-001.md`
- `docs/plans/typo-correction-002-int003-query-cost-measurement-001.md`
- `docs/reviews/typo-correction-002-int003-query-cost-p1-architecture-review-r1.md`
- `docs/evidence/typo-correction-002-int003-query-cost-p1-architecture-review-r1-usage.md`
- `docs/reviews/typo-correction-002-int003-query-cost-p1-architecture-review-r2.md`
- `docs/evidence/typo-correction-002-int003-query-cost-p1-architecture-review-r2-usage.md`

The reviewer may write **only** the two required outputs named above. Do not edit source, Assignment, AUTH, plan, packet, source manifest or earlier review artifacts. No Git commit/push/PR operation, Simulator/device discovery or operation, build/test, journal/raw user-data access or network search is in scope. Read-only `git show`, hashing, `rg`, `nl` and file reading are allowed. At review start, record the frozen packet commit and independently verify packet digest, all nine mutable-input hashes, manifest digest and all 28 baseline blob/SHA pairs. If any identity differs, stop before evaluating claims.

If a claim requires a path beyond the frozen manifest or P1 AUTH allowlist, mark it `Blocker` or `Uncovered`, name the exact missing boundary and stop that dependent claim. Reviewer and Coordinator cannot expand the packet; only the named Assignment Authority may approve an exact expansion and a new frozen packet.

## Budget, checkpoints and exhaustion

- Maximum: **20 read-only tool calls or 20 active minutes**, whichever comes first.
- Checkpoint at start and after every **5 tool calls or 5 active minutes**, whichever comes first. Record count/time and claim coverage in the usage output.
- Record reviewer identity, start/end time, actual tool-call count, elapsed active time, checkpoint notes, claims covered, remaining claims and stop reason. If token usage is unavailable, record `unknown`; do not estimate.
- On exhaustion, stop with `Partial / incomplete`, list uncovered claims and do not continue this round. Any further review requires a new numbered round, exact baseline/digest, and Human reauthorization if scope or budget changes.

No P1 AUTH consumption, implementation, P2 capture, Product budget decision, Product/QA-001 Gate, parent Close, TestFlight/Release or ADR acceptance is part of this review lane.
