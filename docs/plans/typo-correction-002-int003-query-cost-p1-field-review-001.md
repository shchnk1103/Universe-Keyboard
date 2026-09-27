# INT-003 P1 diagnostic field review packet

Status: **rounds 1 and 2 withheld P1 approval; the scoped field representation and schema matrix below are frozen for independent Architecture round 3**. This remains design only, not implementation evidence. P1 source baseline is current GitHub `main` `1160ac6fd8696c3036391cdf59bc9fe096d0b219`; its 28-file source manifest is SHA-256 `a98a722b03e2c66de61ab41ae30f59791ccb53a3b365f55a18e96d373732b395`. PR #182 added the finite `keychain_access_denied` failure code and test without changing schema version 4. PR #183 then advanced main with documentation-only changes outside the 28 frozen paths; the manifest is nevertheless rebound to the current tip. The source paths in the current P1 allowlist are unchanged from round 2. [P1 AUTH](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P1-INSTRUMENTATION-001.md) remains Active/unconsumed. [P2 AUTH](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-SIM-CAPTURE-001.md) remains Active/unconsumed pending exact payload and Run-manifest freeze.

Round 1 [Architecture review](../reviews/typo-correction-002-int003-query-cost-p1-architecture-review-r1.md) withheld implementation approval because schema compatibility and query-event cardinality/pairing were not frozen. Round 2 [Architecture review](../reviews/typo-correction-002-int003-query-cost-p1-architecture-review-r2.md) confirmed the event semantics but blocked the typed writer shape because it would require an out-of-scope `DiagnosticsJournalRuntime.swift` API change, and marked observer-cost coverage dependent on that path as uncovered. This round-3 revision carries the same closed typed payload as exactly one `DiagnosticEvent.Field` case through the existing `record(code:fields:)` API; it does not add an allowed source path. It also freezes the v4/v5 code-payload matrix and the PR #182 v4 enum compatibility boundary. It still requires independent round 3 approval before P1 consumption or source implementation.

## Proposed P1 protocol contract for round 2

### 1. Event cardinality and identity

- Emit one typed `typo_recall.query_measured` terminal event for each invocation of the installed `TypoCorrectionCandidateQuerying.correctionCandidates` facade by the coordinator. The event is created and enqueued after the facade returns and the coordinator determines whether its fence still holds.
- Do not emit the existing `typo_recall.query_begin` / `typo_recall.query_outcome` pair from the P1 query path. Keep those `Code` cases and their v4 decode behavior for historical journal lines. Their historical presence is not a pairing requirement for new measurements.
- `localSequence` identifies each event before bounded-ingress admission; `operationOrdinal` in the typed payload associates it with the existing content-free operation, while `stage` labels the driver event. Multiple facade calls in one operation/stage are separate query-measured events. No adjacent-line pairing, new attempt UUID, stable fingerprint, or journal-order inference is used.
- The P1 event count means coordinator-to-installed-facade invocations. `resultState` separately states whether the input was rejected before RIME, sidecar setup failed, a RIME context was obtained, or a non-RIME/test provider returned. Do not relabel the facade count as a count of all librime engine calls.
- Keep separate existing lifecycle events only when they represent a distinct non-query event. A query result discarded by its post-call fence is represented by the query-measured event's finite disposition; do not emit a second query-fence event for that same discard.

### 2. Finite payload

`DiagnosticEvent.TypoRecallQueryPayload` is a closed value carried by exactly one `DiagnosticEvent.Field.typoRecallQuery(payload)` member in the existing `fields` array. `DiagnosticsJournalRuntime.record(code:fields:)` remains unchanged; the P1 writer uses that existing entry point. `DiagnosticEvent.swift` validates that schema v5 `typo_recall.query_measured` contains exactly this one typed member, with no other `Field` case, and that no other code carries this member. This preserves the typed payload without requiring an out-of-scope writer API or permitting arbitrary strings.

| Value | Allowed values and exact meaning |
|---|---|
| `operation_ordinal` | Existing `UInt64` content-free ordinal copied from the current recall fence snapshot; it joins query events to an operation without text or a new identity. |
| `stage` | `stage_one` / `stage_two`, assigned in the driver at the existing stage dequeue point and carried unchanged across yield |
| `readiness` | `ready` only after this invocation's `ensureCorrectionSession` succeeds; `unavailable` only when that setup fails; `unknown` for non-RIME/test adapters or when RIME setup is not attempted |
| `result_state` | `candidates_returned`, `sidecar_unavailable`, `context_unavailable`, `empty_input`, or `zero_limit` |
| `returned_candidate_bucket` | `zero`, `one_to_three`, or `not_applicable`; bucket the typed candidates the coordinator actually receives after existing parser and limit behavior, then its existing `prefix(3)`; use `not_applicable` when there is no returned candidate array |
| `disposition` | `applied` or `discarded_after_facade` according to the existing post-call fence; a pre-call cancellation has no facade invocation and therefore no query-measured event |
| `facade_elapsed_microseconds` | Unsigned 32-bit monotonic elapsed time around only the complete installed facade invocation, including its bridge/parsing work, not coordinator bookkeeping; floor to microseconds, valid zero means under 1 μs, saturate at `UInt32.max` |
| `duration_state` | `measured` for a monotonic interval whose floored microseconds fit in `UInt32` (including a true sub-microsecond zero); `saturated` when elapsed microseconds exceed `UInt32.max` and the recorded duration is clamped to that maximum; `clock_regression` if the end tick is less than the start tick, with duration value `0` treated as invalid/censored rather than a fast call |

`result_state` disambiguates the readiness and candidate bucket:

- `candidates_returned`: readiness is `ready` for RIME or `unknown` for a non-RIME/test provider; the candidate bucket is `zero` or `one_to_three`, including an empty typed array returned by a test adapter.
- `sidecar_unavailable`: readiness is `unavailable`; the bucket is `not_applicable`. It must originate from `ensureCorrectionSession` failure in this same bridge invocation.
- `context_unavailable`: readiness is `ready` because sidecar setup succeeded, but `get_context` returned false; the bucket is `not_applicable`. This is not ready-empty.
- `empty_input`: the facade receives an empty input string; this state takes precedence if the input is empty and the safe limit is also zero. Readiness is `unknown`, bucket is `not_applicable`, and no `ensureCorrectionSession` or RIME context query runs.
- `zero_limit`: the input is nonempty but the facade's safe limit is zero; readiness is `unknown`, bucket is `not_applicable`, and no `ensureCorrectionSession` or RIME context query runs. A nonempty but unrecognized spelling is not rejected as invalid input; it follows the ordinary query path and may return `ready + candidates_returned + zero`.
- For `empty_input` and `zero_limit`, duration covers the facade's bounded validation return. These invocations remain facade calls, but the result state prevents them from being described as RIME candidate queries.

No payload contains composition, hypothesis, input, candidate, host, path, error text, candidate identity, or `compositionFingerprint`. Stage is added to the finite driver query value at the existing dequeue point. Scheduling, selection, debounce, yields, fences, sidecar ownership, and query budgets remain unchanged.

### 3. Schema and old-record compatibility decision proposed for P1

- New `DiagnosticEvent` instances use schema version 5. `typo_recall.query_measured` is valid only with schema version 5 and requires exactly one matching `Field.typoRecallQuery` value. It is invalid under schema version 4. Missing, duplicate, extra, or mismatched typed fields fail event validation.
- The version-5 decoder explicitly continues to decode schema-version-4 lines using the existing keys and finite values known to baseline `1160ac6fd8696c3036391cdf59bc9fe096d0b219`. No migration or rewrite of historical JSONL lines is performed; old line bytes and their original `schemaVersion` remain intact under existing retention rules.
- Schema version 4 is not treated as a guarantee that all historical binaries decode every value ever added under that number. PR #182 added `RimeSyncFailure.keychainAccessDenied` while retaining schema version 4. This baseline's decoder accepts that known v4 value; a pre-#182 v4 binary can reject a line containing it. This compatibility boundary is accepted for the current P1 schema decision, with raw JSONL remaining canonical for later inspection; P1 does not rewrite or backport old binaries.
- The new decoder accepts only schema versions 4 and 5. Unsupported versions, unknown event `Code`, unknown finite enum values, schema-4 query-measured events, and query-field/code mismatches fail decoding of that record; no value is coerced to `zero`, `ready`, success, or arbitrary text. Unknown JSON object keys follow existing `Codable` keyed-container behavior and are ignored; known finite enum values remain allowlisted.
- The existing journal reader's per-line decode failure behavior may omit an undecodable line from its in-memory event list, but it does not rewrite the source segment. P2 evidence uses the preserved raw segment/hash and treats unsupported or undecodable lines, sequence gaps, queue drops, suspended drops, or an unsealed/truncated capture as missing/censored evidence. No absent line is filled as zero or success. There is no promise that an older binary decodes version-5 events; App and Extension ship as one app build, while this compatibility decision protects the current version-4 journal data on upgrade.
- P2 evidence must count/validate directly from the preserved raw JSONL using the frozen schema, not from the in-app reader's decoded event list, because that reader may omit decode failures. No change to `DiagnosticsJournal.swift` or its reader is proposed; surfacing decode failures through that reader would be outside the P1 allowed source paths and requires a new scope decision.
- This is a scoped proposed field/schema compatibility decision for P1 under accepted ADR 0027. It does not change ADR 0027's status, accept another ADR, or close TD-013 beyond this exact INT-003 event.

### 4. Bounded cost and censoring

- Take `DispatchTime.now().uptimeNanoseconds` start/end ticks immediately before/after the installed facade. If end is less than start, preserve the query result but record `duration_state=clock_regression`, elapsed `0`, and censor timing; do not subtract with wrapping arithmetic. Otherwise floor nanoseconds to microseconds, use `measured` through exactly `UInt32.max`, and use `saturated` above it with the value clamped to `UInt32.max`. Do not include event construction, fence bookkeeping, formatting, persistence, JSON encoding, or queue submission in the recorded duration.
- Construct the single typed `Field.typoRecallQuery(payload)` after the measured interval and pass it through the existing high-fidelity, bounded `DiagnosticsJournalRuntime.record(code:fields:)` ingress. Do not change `DiagnosticsJournalRuntime.swift`; no new lock, synchronous storage, formatter, or second persistence route is permitted.
- `discarded_after_facade` retains the measured duration and returned-candidate bucket, but is censored from successful/applied results. A pre-call cancellation has no measured facade event. Setup failure and context failure remain distinct. A ready empty array is the only RIME `ready + candidates_returned + zero` case.
- The bounded queue can drop a query-measured event. Queue-full/suspend counters and unexplained local-sequence gaps are missing-data signals, not zero results; the aggregate drop count cannot identify which event codes were lost. P2 may report an exact total only for a complete, sealed process segment with no unexplained gaps, undecodable lines, queue/suspend drops, or capture truncation. Otherwise report the observed query count as a lower bound, leave the number of missing query events unknown, and censor the affected interval.
- P1 correctness tests establish event schema/meaning and bounded admission only. A runtime overhead comparison uses the separate P2 AUTH's frozen Simulator environment; no local unit timing is presented as a Product latency claim.

## Required round-3 review questions and tests to be specified

The independent Architecture reviewer must cover all seven claims and the round-2 blocker/conditionals again, and explicitly decide:

1. Whether stage attribution at the driver dequeue point preserves yields and operation state.
2. Whether the candidate bucket has the exact post-parser/post-limit/coordinator-prefix meaning above.
3. Whether same-call readiness, `get_context` failure, invalid-input and non-RIME semantics are unambiguous.
4. Whether the monotonic facade boundary, microsecond floor, saturation, sub-microsecond zero and clock-regression rules are accurate and bounded.
5. Whether the single typed `Field` member can use the existing runtime writer without modifying `DiagnosticsJournalRuntime.swift`, and whether v5/v4, schema/code/typed-field, PR #182 enum and raw-retention behavior are precise.
6. Whether the installed correction route, sidecar session, thread serialization and Swift 6 ownership remain unchanged.
7. Whether event construction/admission stays bounded and censored outcomes cannot be interpreted as successful nonempty queries.

Focused tests after Architecture approval must cover: stage one and stage two after yield; 0/1/3/>3 candidates and parser filtering; ready-empty, setup failure, `get_context == false`, non-RIME unknown, empty input/zero-limit precedence, zero limit, and unrecognized nonempty input; v4 pre-#182 and post-#182 fixture decode; v5 typed-field round trip; schema-4 query event rejection; missing/duplicate/extra/mismatched typed-field rejection; unknown schema/code/enum rejection; queue-full/suspend drop; post-call fence discard; monotonic zero/saturation/clock regression; and a no-text/no-fingerprint serialization assertion.

## Privacy and authority boundary

The blockers are recorded in [round 1](../reviews/typo-correction-002-int003-query-cost-p1-architecture-review-r1.md) and [round 2](../reviews/typo-correction-002-int003-query-cost-p1-architecture-review-r2.md), with their respective usage records. Round 3 must bind this exact design, current source baseline/manifest, Assignment, both AUTH records, measurement plan, and prior review outputs by hash before dispatch. Reviewer may write only the round-3 result and usage artifacts.

P1 AUTH remains **Active/unconsumed** until independent Architecture round 3 approves the exact finite semantics, existing-writer field representation, schema matrix and overhead protocol. Do not edit Swift/Objective-C or consume P1 before that decision. P2 remains separate and cannot run before its own exact installed-payload/Run freeze and consumption. No query budget, Product cost verdict, Quality claim, Gate, parent Close, TestFlight, Release, ADR acceptance, or `RimeRuntimeProvenance` restoration is authorized here.
