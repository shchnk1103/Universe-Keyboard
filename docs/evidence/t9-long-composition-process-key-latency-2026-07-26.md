# T9 long-composition `process_key` latency — iOS 27 Simulator A/B evidence

| Field | Value |
|---|---|
| Status | **Diagnostic evidence — V0–V9, call-stack, mitigation, real-UI interaction and S1 shadow sampling complete** |
| Collected | 2026-07-26–27, Asia/Shanghai |
| Plan | [`../plans/t9-long-composition-process-key-latency-plan.md`](../plans/t9-long-composition-process-key-latency-plan.md) |
| Commit | `2ec7421dd29211906a577a272e0895f72a6ae128` |
| Build | Debug, Xcode 27.0 (`27A5228h`) |
| Environment | iPhone 17 Pro Max Simulator, iOS 27.0, UDID `06C5BC3E-7599-4761-A1A2-71DAEA991474` |
| Schema/runtime | Deployed `t9`; each variant used a private copy of the same App Group shared/user runtime |
| Synthetic input | `jintiandetianqihenbucuowomenchuquwanba` |
| Internal T9 payload | `54684263384267443628286966362487892622` (38 keys) |

## Evidence boundary

This record preserves a repeatable simulator diagnostic and hypothesis
elimination matrix. It is not physical-device, Release, numeric SLO, candidate
quality, Product Gate or release-acceptance evidence.

The keyboard surface was verified as visible `ABC` / `DEF` / … / `WXYZ` keys.
Digits were used only as the stable T9 engine/accessibility identity; this run
does not claim that digit labels should be shown to users.

## Method

1. A Reminders-hosted UI run selected Universe Keyboard and entered the frozen
   38-key sequence through the visible nine-key surface.
2. A bridge-level diagnostic used the same deployed runtime and split each key
   into librime `process_key` (`api`) and bridge output collection (`collect`).
3. The bridge run discarded one warm-up composition, then recorded 10 complete
   runs with a 200 ms interval after every key.
4. Every completed run asserted 38 raw-input slots, non-empty candidates and no
   unexpected committed text.
5. V1–V4 copied the same shared/user runtime, removed compiled output, applied
   exactly one configuration change and performed a full deployment in the
   private directory. The production App Group runtime was not mutated.
6. V7 reused the same frozen sequence and deployed runtime for three
   five-round, 200-ms-cadence arms: uninterrupted ambiguity, cumulative exact
   Path confirmation without host commit, and natural-phrase candidate commit.
7. V8 drove the same sequence through Reminders and the real nine-key UI. It
   tapped only the visible `ABC` / `DEF` / … key surface, then selected actual
   Path chips. The temporary test method was removed after the artifacts were
   retained.

The UI automation framework introduced approximately 1.8 seconds of harness
overhead between observed taps, so that run proves cross-layer reproduction but
is not the controlled cadence baseline. The bridge run is the comparable timing
matrix.

## V0–V6 result

| Variant | Isolated change | Long-input API median | Long-input API P95 | Long-input total P95 | `api > 30 ms` | Maximum API |
|---|---|---:|---:|---:|---:|---:|
| V0 | Current deployed configuration | 2.662 ms | 69.071 ms | 69.205 ms | 30 / 380 | 78.545 ms |
| V1 | Remove date/calculator Lua translators | 2.474 ms | 70.125 ms | 70.238 ms | 30 / 380 | 83.786 ms |
| V2 | `enable_word_completion: false` | 2.378 ms | 70.700 ms | 70.812 ms | 30 / 380 | 77.334 ms |
| V3 | `spelling_hints: 16` | 2.623 ms | 68.625 ms | 68.733 ms | 30 / 380 | 77.320 ms |
| V4 | `spelling_hints: 8` | 2.410 ms | 71.616 ms | 71.726 ms | 30 / 380 | 82.093 ms |
| V5 | Main T9 translator `enable_sentence: false` | 2.237 ms | 69.890 ms | 69.999 ms | 31 / 380 | 83.677 ms |
| V6 | Main T9 translator `max_homophones: 1` | 2.808 ms | 71.778 ms | 71.889 ms | 30 / 380 | 83.911 ms |

“Long-input” means `rawLen 13...38`. Percentiles use linear interpolation
over the retained samples. The threshold is a diagnostic counter inherited
from the investigation, not an accepted product budget.

### Deterministic spike positions

| Raw length | Newly entered letter | V0 median API | Reproduction |
|---:|---|---:|---:|
| 24 | `w` after `...bucuo` | 53.147 ms | 10 / 10 |
| 32 | `q` after `...menchu` | 68.838 ms | 10 / 10 |
| 34 | `w` after `...chuqu` | 73.726 ms | 10 / 10 |

All six variants retained the same three spike positions at 10 / 10. V1–V4 and
V6 had no other `api > 30 ms` position; V5 had one additional isolated sample
at raw length 20. The UI-hosted run independently observed the same three
stable positions, with approximately 115.6 / 81.8 / 71.1 ms API samples.

## V7 controlled segmentation matrix

V7 separates two mechanisms that must not be conflated:

- **A — continuous ambiguity:** keep all 38 internal T9 slots in one
  unconfirmed composition.
- **B — Path-confirmed:** at the natural phrase boundaries
  `jintian / de / tianqi / henbucuo / women / chuqu / wanba`, replace the
  cumulative raw input with the exact apostrophe-separated pinyin Path. This
  retains the whole composition and does not commit host text.
- **C — phrase-committed:** select the expected Chinese candidate at each same
  boundary, then continue in a fresh composition. Every selected candidate was
  present and committed the expected synthetic phrase.

Each retained arm discarded one warm-up pass and measured five complete
38-slot passes at 200 ms per key.

| Arm | Long API median | Long API P95 | Long total P95 | `api > 30 ms` | Maximum API | Position 24 / 32 / 34 median |
|---|---:|---:|---:|---:|---:|---:|
| A — continuous ambiguity | 2.483 ms | 72.745 ms | 72.854 ms | 15 / 190 | 77.945 ms | 57.235 / 74.813 / 74.641 ms |
| B — cumulative exact Path | 1.122 ms | 7.558 ms | 7.691 ms | 0 / 190 | 12.652 ms | 2.994 / 9.575 / 3.115 ms |
| C — phrase commit/reset | 0.526 ms | 4.575 ms | 4.927 ms | 0 / 190 | 10.000 ms | 0.584 / 5.950 / 0.458 ms |

All three A spike positions reproduced at 5 / 5. Neither B nor C produced any
`api > 30 ms` sample. B's 35 exact-Path replacement operations had P95
5.330 ms and maximum 9.354 ms. C's 35 candidate-selection operations had P95
1.431 ms and maximum 3.367 ms.

The first B attempt is excluded from performance conclusions because the test
harness incorrectly counted apostrophe separators as input slots. It completed
the workload but failed its slot-count assertion. The corrected run explicitly
excludes separators and whitespace from slot identity.

## V8 real-UI Path validation

The first real-UI attempt exposed a state-machine constraint rather than a
harness failure:

- Tapping a Path while it is at the then-end of the composition selects it, but
  there is no remaining segment to advance into.
- After the next syllable's keys are entered, the previously selected Path must
  be tapped again to confirm that segment and move focus forward.
- Therefore the current UI interaction is not equivalent to “one Path tap per
  syllable”. The successful V8 run used 38 visible group-key taps, 14 current
  Path selections and 13 re-taps of the previously selected Path.

With that interaction represented accurately, the full UI test passed in
Reminders. The final marked text was
`jintiandetianqihenbucuowomenchuquwanba`, the selected Path was `ba`, the first
candidate was `今天的天气很不错我们出去玩吧`, no internal `[2-9]` identity leaked
into host text, and the Keyboard Extension remained alive.

The retained 500-line diagnostic ring contains only the final ten key events,
so it cannot prove all 38 UI-key latencies. It does include two previously
deterministic spike positions:

| Global position | Continuous A API median | V8 UI API | V8 UI total key |
|---:|---:|---:|---:|
| 32 | 74.813 ms | 16.9 ms | 19.9 ms |
| 34 | 74.641 ms | 2.9 ms | 5.9 ms |

No `SLOW RIME` entry appears in the retained tail. Position 24 had already
rolled out of the ring and is intentionally not claimed. XCUITest tap cadence
was approximately 0.5–4 seconds and the complete test took 88.964 seconds, so
V8 is functional/interaction evidence, not a comparable performance baseline.

## V9 S1 shadow real-UI five-run sampling

V9 sampled the Debug-only `T9SHADOW` observer through the visible Universe
Keyboard nine-key surface in Reminders. The same frozen 38-key sequence was
entered five times without selecting a candidate or Path. Between rounds, the
active composition was cleared with 38 visible Delete taps while the same
empty-title reminder remained focused.

The keyboard extension was restarted before round 1 to establish a known
session boundary. Round 1 therefore includes fresh-session cost; rounds 2–5
are the comparable warm-session subset. Only the performance log category was
enabled. Each round's App Group diagnostic snapshot was parsed immediately
before the 500-entry ring could discard it.

This is a real-UI simulator diagnostic. Automation completed each 38-tap round
in 2.903–3.016 seconds, but its per-tap cadence was not controlled; these
numbers are not a product budget or a replacement for the fixed-cadence bridge
matrix.

| Round | Session | Key median | Key P95 | Key max | UI average | UI max | RIME max |
|---:|---|---:|---:|---:|---:|---:|---:|
| 1 | Fresh extension/session | 4.0 ms | 83.7 ms | 141.9 ms | 1.88 ms | 10.6 ms | 139.6 ms |
| 2 | Warm | 3.0 ms | 56.3 ms | 57.9 ms | 1.56 ms | 2.0 ms | 55.6 ms |
| 3 | Warm | 2.9 ms | 55.8 ms | 59.4 ms | 1.49 ms | 1.9 ms | 56.8 ms |
| 4 | Warm | 2.9 ms | 57.0 ms | 61.9 ms | 1.54 ms | 2.0 ms | 59.2 ms |
| 5 | Warm | 3.0 ms | 55.6 ms | 59.2 ms | 1.61 ms | 2.1 ms | 57.1 ms |

Across the four warm rounds, average full-key time was 6.88 ms, median stayed
within 2.9–3.0 ms, and UI time averaged 1.55 ms with a 2.1 ms maximum. The
three long-ambiguity transitions reproduced in every round:

| Raw length | Total samples across five rounds | Total median | RIME median | UI maximum | Reproduction |
|---:|---|---:|---:|---:|---:|
| 24 | 141.9 / 41.6 / 41.0 / 41.6 / 41.3 ms | 41.6 ms | 39.2 ms | 1.7 ms | 5 / 5 |
| 32 | 83.7 / 56.3 / 55.8 / 57.0 / 55.6 ms | 56.3 ms | 54.1 ms | 1.7 ms | 5 / 5 |
| 34 | 70.1 / 57.9 / 59.4 / 61.9 / 59.2 ms | 59.4 ms | 57.1 ms | 2.0 ms | 5 / 5 |

The fresh session also produced a 44.0 ms first key, including 27.5 ms RIME
and 10.6 ms UI. It is classified separately from the long-composition
transitions.

Every round yielded 38 `T9SHADOW` observations and zero `proposalReady`
observations. Each round also had the same count profile: 23 observations with
a positive observed anchor length and 13 with no compatible candidate comment.
The final round's complete status distribution was 38 / 38
`candidateSetIncomplete`.

V9 therefore strengthens two boundaries:

- the long-composition stalls are position-linked RIME work, not a periodic
  UI task; raw lengths 24 / 32 / 34 survived five composition resets;
- the currently returned candidate page is not complete authority for an
  automatic anchor. Observed prefixes remain diagnostic only, even when their
  slot count is positive.

V9 does not measure the observer's incremental overhead against an otherwise
identical no-observer build. It also does not authorize a production mutation,
candidate commit, user-dictionary update, physical-device claim or Release
budget.

## Diagnostic conclusion

- Optional date/calculator Lua translators are not the primary cause on this
  input path.
- Word completion and `spelling_hints` magnitude are not the primary cause.
- Disabling sentence construction on the main T9 translator does not control
  the three expensive transitions.
- Restricting `max_homophones` to one does not reduce the spike. Candidate
  enrollment breadth is not the dominant cost.
- The cost remains inside librime `process_key`; output collection and UIKit
  presentation do not explain the deterministic spike.
- A symbolicated multi-thread trace proves that the new syllable-start
  transition enters script translation, sentence preparation and system-table
  lookup for the long syllable graph.
- Exact user-confirmed Path anchoring eliminates the measured spikes without
  requiring a host commit or shortening the total composition. Therefore the
  dominant amplifier is the unresolved T9 ambiguity graph, not raw character
  count alone.
- Candidate commit/reset is also effective, but V7 does not justify forcing a
  commit: the less invasive Path-confirmed arm already bounded the same cost.

Do not reopen Lua or force-GC editing as the primary fix without new evidence.
The remaining product/engineering question is how to make explicit Path
confirmation timely and discoverable for long T9 input. V8 narrows a promising
but still unauthorized option: after the user explicitly selects an end Path,
the next digit may be treated as intent to advance that already-selected Path,
avoiding the second tap without inventing a new path. This is a product/state
transition change and still needs an explicit decision plus contract tests.
V7/V8 do not authorize automatic path choice, forced commit or a marked-text
contract change.

## Proposed regression layers

This investigation should not become one timing-sensitive “unit test”:

1. **KeyboardCore unit contracts (normal CI):** use a deterministic fake RIME
   engine to verify segment-ledger transitions, end-Path selection, next-input
   focus retention/advance policy, internal-digit non-leakage and the final
   cumulative raw/provenance state.
2. **RimeBridge simulator integration (normal or opt-in CI):** replay A/B/C
   against the pinned deployed runtime and always gate functional invariants.
   Emit machine-readable latency distributions, but do not use wall-clock
   millisecond assertions as ordinary unit-test truth.
3. **Controlled performance gate (fixed simulator or device runner):** repeat
   the frozen matrix on a declared runtime/cadence and compare B/C against A.
   Absolute and ratio thresholds remain provisional until a multi-run baseline
   is reviewed.
4. **Prepared-host XCUITest (opt-in):** normalize the software-keyboard state,
   drive Reminders, assert visible letter-group labels, actual Path transitions,
   digit non-leakage, extension survival and retain a screenshot. Do not run
   this 89-second system-keyboard test as a default PR unit test.
5. **Physical-device Product Gate:** remains separate from simulator,
   integration and UI automation evidence.

## Multi-thread ETTrace

The first ETTrace capture used the runner's default main-thread-only mode and
did not include the XCTest asynchronous thread that executed RIME. It is
excluded from the conclusion. The retained capture used ETTrace v1.1.0
`--multi-thread`, with UUID-matched `RimeBridgeTests.xctest.dSYM` and
`ETTrace.framework.dSYM`.

The 37.23-second processed capture overlapped retained slow samples and produced
three Swift-concurrency worker traces containing the same first-party stack:

```text
RimeProcessKey
  → rime::ConcreteEngine::Compose
  → rime::ConcreteEngine::TranslateSegments
  → rime::ScriptTranslator::Query
  → rime::ScriptTranslation::Evaluate
  → rime::ScriptTranslation::MakeSentence
  → rime::ScriptTranslation::PrepareForMakingSentence
  → rime::Dictionary::Lookup
  → rime::Table::Query / rime::TableQuery::Access
```

Across those worker outputs, the per-thread inclusive sample totals were:

| Frame | Per-thread inclusive range |
|---|---:|
| `RimeSessionManager processKey` | 0.279–0.492 s |
| `ScriptTranslation::Evaluate` | 0.243–0.456 s |
| `ScriptTranslation::MakeSentence` | 0.199–0.385 s |
| `Dictionary::Lookup` | 0.224–0.395 s |
| `Table::Query` | 0.264–0.532 s |

These are inclusive totals accumulated during the capture, not individual-call
latencies and not a product budget. `LuaTranslator::Query` appeared as only a
small side branch (0.018 s in one worker output); the visible user-dictionary
LevelDB lookup was also small (0.014 s in one worker output).

ETTrace's simulator multi-thread tracer itself generated large
`pthread_qos_max_parallelism → __sysctlbyname` sampling overhead. That overhead
is excluded from the first-party attribution; this trace supports call-path
identification, not comparable latency numbers.

The V5 source and compiled `user/build/t9.schema.yaml` both contained
`translator/enable_sentence: false`, so the result is not a failed deployment.
In librime 1.16.1, `ScriptTranslation::Evaluate()` directly calls
`MakeSentence()` when the syllable graph has at least two syllables and neither
the system nor user dictionary provides a reliable exact phrase. The official
Rime customization guide documents `enable_sentence` as a
`table_translator`-only option; it does not disable pinyin
`script_translator` sentence preparation.

Primary references:

- [librime 1.16.1 `script_translator.cc`](https://github.com/rime/librime/blob/1.16.1/src/rime/gear/script_translator.cc)
- [Rime Customization Guide](https://github.com/rime/home/wiki/CustomizationGuide)

## Retained artifacts

Raw XcodeBuildMCP logs are stored under:

`evidence/t9-long-composition-process-key-latency-20260726/raw-logs/`

| File | SHA-256 |
|---|---|
| `ui-reminders-v0.log` | `f52fbb4fdbaac8933032ca97a34017c40f14afb6ee593fed7e9f263c2cd3ee38` |
| `v0-current.log` | `d3f3b02f550d4884625dc04be1dea67a41b85590e28afb6b81da19a79dc82e82` |
| `v1-no-date-calc-lua.log` | `2a1448a5b8a3f9821d5fd3b442982fcaff6b323507980aadf00e2d9213f45c65` |
| `v2-no-word-completion.log` | `7bc861bbdd441618c0df8bd0b827df22a32006c257e62c06708185ad1dda0cb8` |
| `v3-spelling-hints-16.log` | `b17c6a648e0121dad6d8032c85969cc990d4ff381430b1e318c1138191faf963` |
| `v4-spelling-hints-8.log` | `8b4b1aa60bf2f9c4f32aeddf141dc3e8b8930fc9f309a29c23986bdf604057c1` |
| `v5-no-sentence.log` | `f533a73f1982de1180b304154c9c8e570dc9962a1bd99341a57f054f63b61031` |
| `v6-max-homophones-1.log` | `dc29e139e5cd0cad9bf8e6f9beee52c8bd456b9b3310812068c45f382f1c1367` |

Processed multi-thread ETTrace JSON is stored under:

`evidence/t9-long-composition-process-key-latency-20260726/ettrace-v5-multithread/`

| File | SHA-256 |
|---|---|
| `output_15363.json` | `97cce3ef769ea283f41f2606e1d7982ca537b695630fd0260d42da93cbaca543` |
| `output_259.json` | `755b6e363ef9582105b555cdfa28c1c56c73227a9af56ff1c43e1f6040612712` |
| `output_6147.json` | `f45afa8b4c56de1b42cdc301fb234d3e67fc6b817ce1921e3e7e4922723d50c5` |
| `output_8459.json` | `1384ac838dfe493fbc358ab92c115118e96216d2e58da38d2ce7bb53a39cd5dc` |
| `output_8971.json` | `579b294d91ff3fde5caa6dd79dd9ed6e23e22ca2838e5a0854a3eca20004ce5d` |
| `output_9479.json` | `40ec2cb19d61f7f1f6112a884f8e354f2a9208c2be7575f48388ebec8ad17199` |

Controlled segmentation logs are stored under:

`evidence/t9-long-composition-process-key-latency-20260726/segmentation-ab/`

| File | Status | SHA-256 |
|---|---|---|
| `v7-a-continuous.log` | Retained | `28658e281c544f6ccdb86b64c7c3ce8261fd9ab575e935fd3aac48b8436f79fd` |
| `v7-b-path-confirmed.log` | Retained | `40f65169320918a7beb4f4c3e99b3b397eceec8f38916d5c636e82686aee625e` |
| `v7-c-phrase-committed.log` | Retained | `ca677532621fe20eb8e46ace079827a5b84cf5211debaf8f0643210441fa5bcf` |
| `invalid-b-slot-assertion.log` | Excluded harness-error record | `b312693565952e3dfc3866571d3fdc42c58486ec746b113ea7e65d65ea2c5ab1` |

Real-UI Path artifacts are stored under:

`evidence/t9-long-composition-process-key-latency-20260726/ui-path/`

| File | Status | SHA-256 |
|---|---|---|
| `v8-ui-explicit-path-xcuitest.log` | Retained passing XCUITest log | `6d73541ac13d13183ab41f1a4a8ed0d88fe4cf37095f252317ec01b3ab5cc3d5` |
| `v8-ui-end-selected-path-does-not-advance.log` | Retained interaction-discovery failure | `1d3143d440105b7bfd686b2da9369316a278cc1485b352428a871c6cb9f8ebd3` |
| `v8-ui-explicit-path-diagnostic.log` | Retained final 500-line diagnostic ring | `0406909aac86b2d96548b7ca407cba1194f000276f6db8039f2c8bd31ca4ef4a` |
| `v8-ui-explicit-path-final.jpg` | Retained final simulator screenshot | `2bf24da68cd5907735b3453293d8002ee37d1d6f02729f0aa4a0b80fea3daa4b` |

The machine-readable V9 summary is stored at:

`evidence/t9-long-composition-process-key-latency-20260726/v9-s1-shadow-real-ui-five-run-summary.json`

## Revalidation triggers

- commit, pinned librime, schema source or deployment changes;
- simulator/runtime, build configuration or cadence changes;
- physical-device or Release claims;
- any candidate-quality conclusion or productization of a performance knob.
