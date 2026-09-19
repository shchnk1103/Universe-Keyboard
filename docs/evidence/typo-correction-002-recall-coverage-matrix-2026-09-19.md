# TYPO-CORRECTION-002 recall coverage matrix

## Status and evidence boundary

| Field | Value |
|---|---|
| **Status** | `Read-only coverage inventory; not an implementation or Product result` |
| **Assignment** | [`TYPO-CORRECTION-002-RECALL-REMEDIATION-001`](../assignments/typo-correction-002-recall-remediation-001.md) |
| **Authorization** | [`AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-DESIGN-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-DESIGN-001.md) |
| **Source baseline** | `fb27b24ff85c48302e85309e834dbbe9a777871e` |
| **Repository tip** | `13b0c4d6df174f77a7765d25edc9845ec9faa011` |
| **Evidence mode** | Static source, test and existing-record reconciliation; no rebuild, install, device capture or new Run ID |

This matrix records **recall reachability** only. It does not establish
Chinese sentence correctness, candidate ordering, real-RIME behavior, latency,
or Product acceptance. `UNKNOWN` means the current records do not capture the
field; it is not a negative runtime result.

## Case matrix

| Case / input | Edit positions and operations | Production 12-state frontier | Production final 8 | First bounded expansion recorded | Pure generation / RIME query scope | Boundary and interpretation |
|---|---|---|---|---|---|---|
| `TC2-CASE-QA-001` / `TC2-CASE-EXP-002` — `wimenjintianquhongyuan` | Two separated substitutions: index `1` `i→o`; index `14` `h→g`; target `womenjintianqugongyuan` | Exact target frontier rank/order: **UNKNOWN**; no current artifact proves entry into the production 12-state frontier | **UNKNOWN / not proven**; the designated QA runs did not show the target candidate | Default-off preflight `60` first-layer / `64` final hypotheses contains the target; ADR 0016 records local preflight rank `55`; exact minimum expansion threshold is **UNKNOWN** | Pure preflight produces at most `64` hypotheses in `8` batches of at most `8`; it performs `0` RIME queries. If a future design reuses the current controller query ceiling, the static ceiling is at most `4` resolved groups × `3` candidates = `12` candidates; this is not a runtime measurement | Input length `22` is within the `8…30` contextual range. This row proves bounded recall reachability only; QA-001, real-RIME quality and performance remain open |
| Neighbor baseline — `nihap` | One substitution: index `4` `p→o` | Not applicable to the contextual two-edit frontier | Not applicable | Not a contextual expansion case; the legacy single-edit engine test proves `nihao` is generated | No RIME query in the cited unit test | Length `5` is below the contextual minimum; retain as a short-input guard, not as multi-error evidence |
| Neighbor baseline — `bihao` | One substitution: index `0` `b→n` | Not applicable to the contextual two-edit frontier | Not applicable | Not a contextual expansion case; the legacy single-edit engine test proves `nihao` is generated | No RIME query in the cited unit test | Length `5` is below the contextual minimum; initial-position correction is covered only by the legacy single-edit path |
| Neighbor baseline — `nigao` | One substitution: index `2` `g→h` | Not applicable to the contextual two-edit frontier | Not applicable | Not a contextual expansion case; the legacy single-edit engine test proves `nihao` is generated | No RIME query in the cited unit test | Length `5` is below the contextual minimum; middle-position correction is covered only by the legacy single-edit path |
| Neighbor baseline — `zhonghuo` | One substitution: index `5` `h→g` | Not applicable to the contextual two-edit frontier | Not applicable | Not a contextual expansion case; the legacy single-edit engine test proves `zhongguo` is generated | No RIME query in the cited unit test | Length `8` reaches the contextual lower bound, but the cited evidence is still for the legacy single-edit engine and cannot be promoted to a two-edit recall result |
| Contextual lower boundary — `nihao` | No edit case | Rejected before generation | Rejected before generation | Empty under both production and preflight construction | No RIME query | Length `5 < 8`; confirms the contextual lower bound |
| Contextual upper boundary — `a…a` × `31` | No edit case | Rejected before generation | Rejected before generation | Empty under both production and preflight construction | No RIME query | Length `31 > 30`; confirms the contextual upper bound |

## Static budget reconciliation

| Layer | Current contract | What is known | What is not known |
|---|---|---|---|
| Production generation | `12` first-layer states, `8` final hypotheses | Default initializer selects `productionV2`; source audit confirms the preflight planner is not referenced by the production controller/UI | Exact production frontier rank/order for the canonical target |
| Preflight generation | `60` first-layer states, `64` final hypotheses, batches ≤ `8` | Canonical target is present; ADR 0016 records local rank `55`; pure planner performs no RIME/UI/session work | Smallest expansion size that admits the target; generation CPU/memory timing |
| Production controller query seam | Each corrected input query limit `3`; stop after `4` non-empty resolved groups | Static derived ceiling is `12` candidate texts if all four groups resolve | Whether a future second-stage schedule would actually reach this ceiling, and its paired latency/memory cost |
| RIME / sidecar | Separate session and provenance-bound route | Existing sidecar receipt proves a bounded real-RIME route for a prior run | No evidence here that the canonical corrected input returns the intended Chinese sentence or that expanded batches meet the 180 ms product budget |

## Safety and privacy checks

- The matrix uses the pure `ContextualTypoCorrectionSearchPlan` contract and
  existing source/test records; it does not use `FakeCandidateProvider` as
  real-RIME evidence.
- No old Ice directory, host text, clipboard, marked text, document context,
  history or network input is used.
- The current 8–30 character bound and two-edit limit remain unchanged in this
  read-only artifact. Unsafe-edit exclusions remain owned by the existing
  `TypoCorrectionKeyboard.isSafeReplacement` path.
- No candidate is selected, promoted, committed or sent by this artifact.

## Decision from this matrix

The evidence supports one narrow conclusion: the canonical target is reachable
inside the existing default-off preflight pool but its production 12/8
reachability is not recorded. That is sufficient to justify a new, independent
Architecture review of the **coverage-aware second-stage design**. It is not
sufficient to authorize implementation, a production budget change, a new
RIME query schedule, a performance claim, QA-001 closure or a Product Gate.

The next implementation input must add a reproducible way to capture the
production frontier and the smallest bounded expansion threshold, while keeping
pure generation cost and real-RIME query cost as separate measurements.
