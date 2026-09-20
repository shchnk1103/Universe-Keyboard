# TYPO-CORRECTION-002 recall coverage matrix

## Status and evidence boundary

| Field | Value |
|---|---|
| **Status** | `Read-only coverage inventory; not an implementation or Product result` |
| **Assignment** | [`TYPO-CORRECTION-002-RECALL-REMEDIATION-001`](../assignments/typo-correction-002-recall-remediation-001.md) |
| **Authorization** | [`AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-CONDITIONS-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-CONDITIONS-001.md) |
| **Source baseline** | `fb27b24ff85c48302e85309e834dbbe9a777871e` |
| **Condition reconciliation base tip** | `c38578231baa05cf76821e0db5c4bd7d68b3acfb` |
| **Evidence mode** | Static source, test and existing-record reconciliation; no rebuild, install, device capture or new Run ID |

This matrix records **recall reachability** only. It does not establish
Chinese sentence correctness, candidate ordering, real-RIME behavior, latency,
or Product acceptance. `UNKNOWN` means the current records do not capture the
field; it is not a negative runtime result.

## Case matrix

| Case / input | Edit positions and operations | Production 12-state frontier | Production final 8 | First bounded expansion recorded | Pure generation / RIME query scope | Boundary and interpretation |
|---|---|---|---|---|---|---|
| `TC2-CASE-QA-001` / `TC2-CASE-EXP-002` — `wimenjintianquhongyuan` | Two separated substitutions: index `1` `i→o`; index `14` `h→g`; target `womenjintianqugongyuan` | Exact target frontier rank/order: **UNKNOWN**; no current artifact proves entry into the production 12-state frontier | **UNKNOWN / not proven**; the designated QA runs did not show the target candidate | Default-off preflight `60` first-layer / `64` final hypotheses contains the target; ADR 0016 records local preflight rank `55`; exact minimum expansion threshold is **UNKNOWN** | Pure preflight produces at most `64` hypotheses in `8` batches of at most `8`; it performs `0` RIME queries. `4 × 3 = 12` is only a possible returned-candidate ceiling, not a query-attempt ceiling; contextual plus legacy suggestions may create more attempts | Input length `22` is within the `8…30` contextual range. This row proves bounded recall reachability only; QA-001, real-RIME quality and performance remain open |
| Neighbor baseline — `nihap` | One substitution: index `4` `p→o` | Not applicable to the contextual two-edit frontier | Not applicable | Not a contextual expansion case; the legacy single-edit engine test proves `nihao` is generated | No RIME query in the cited unit test | Length `5` is below the contextual minimum; retain as a short-input guard, not as multi-error evidence |
| Neighbor baseline — `bihao` | One substitution: index `0` `b→n` | Not applicable to the contextual two-edit frontier | Not applicable | Not a contextual expansion case; the legacy single-edit engine test proves `nihao` is generated | No RIME query in the cited unit test | Length `5` is below the contextual minimum; initial-position correction is covered only by the legacy single-edit path |
| Neighbor baseline — `nigao` | One substitution: index `2` `g→h` | Not applicable to the contextual two-edit frontier | Not applicable | Not a contextual expansion case; the legacy single-edit engine test proves `nihao` is generated | No RIME query in the cited unit test | Length `5` is below the contextual minimum; middle-position correction is covered only by the legacy single-edit path |
| Neighbor baseline — `zhonghuo` | One substitution: index `5` `h→g` | Not applicable to the contextual two-edit frontier | Not applicable | Not a contextual expansion case; the legacy single-edit engine test proves `zhongguo` is generated | No RIME query in the cited unit test | Length `8` reaches the contextual lower bound, but the cited evidence is still for the legacy single-edit engine and cannot be promoted to a two-edit recall result |
| Contextual lower boundary — `nihao` | No edit case | Rejected before generation | Rejected before generation | Empty under both production and preflight construction | No RIME query | Length `5 < 8`; confirms the contextual lower bound |
| Contextual upper boundary — `a…a` × `31` | No edit case | Rejected before generation | Rejected before generation | Empty under both production and preflight construction | No RIME query | Length `31 > 30`; confirms the contextual upper bound |
| Registry boundary record — `7` characters | Exact current contextual fixture is not recorded; operation/result unavailable | **UNKNOWN** | **UNKNOWN** | No exact contextual evidence located; generic Registry `TC2-CASE-STB-001` is not promoted here without path reconciliation | No RIME query evidence | Keep the 7-character contextual boundary explicitly open |
| Registry boundary record — `8` characters | Exact current contextual acceptance fixture is not recorded; `zhonghuo` is a legacy single-edit case and does not close this row | **UNKNOWN** | **UNKNOWN** | No exact contextual evidence located | No RIME query evidence | Keep the 8-character contextual boundary explicitly open |

## Static budget reconciliation

| Layer | Current contract | What is known | What is not known |
|---|---|---|---|
| Production generation | `12` first-layer states, `8` final hypotheses | Default initializer selects `productionV2`; source audit confirms the preflight planner is not referenced by the production controller/UI | Exact production frontier rank/order for the canonical target |
| Preflight generation | `60` first-layer states, `64` final hypotheses, batches ≤ `8` | Canonical target is present; ADR 0016 records local rank `55`; pure planner performs no RIME/UI/session work | Smallest expansion size that admits the target; generation CPU/memory timing |
| Production controller query seam | Each corrected input query limit `3`; stop after `4` non-empty resolved groups | `4 × 3 = 12` is a possible returned-candidate ceiling under the stated assumptions; it is not a total query-attempt bound | `N_query_attempts`, cancellation cost and whether future second-stage execution reaches the ceiling |
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
- The recommended first second-stage operation set is substitution-only. The
  contextual transposition, deletion and insertion paths remain out of scope
  until each receives a separate safety rule.
- No candidate is selected, promoted, committed or sent by this artifact.

## Required execution counters and fences for a future implementation

These are required contract fields, not measurements from this matrix:

| Field | Definition | Current status |
|---|---|---|
| `N_generated` | Number of hypotheses produced by the selected stage | Must be recorded per stage |
| `N_query_attempts` | Number of query invocations actually started, including empty/failed responses | **UNKNOWN**; no total cap is currently bound |
| `N_resolved_groups` | Number of non-empty corrected-input groups accepted | Existing controller ceiling is `4` |
| `N_candidates_returned` | Number of candidate texts returned by successful queries | Per corrected input limit is `3`; total future value remains **UNKNOWN** |
| `maxQueryAttempts` | Hard stage-level query-attempt ceiling | **UNKNOWN**; must be selected and bound before implementation |
| cancellation/publish fence | Checks before/after each query and between batches; revision/epoch match required before publishing | **UNKNOWN** for second-stage execution |

The future implementation must discard stale sidecar results and must not
publish `state.typoCorrection` after cancellation or composition revision/epoch
mismatch. `resolved-group = 4` cannot substitute for these fields.

## Decision from this matrix

The evidence supports one narrow conclusion: the canonical target is reachable
inside the existing default-off preflight pool but its production 12/8
reachability is not recorded. The Architecture review accepts the direction
only with B1–B3 conditions; this reconciliation records those conditions and
does not close them by assertion. It is not sufficient to authorize
implementation, a production budget change, a new RIME query schedule, a
performance claim, QA-001 closure or a Product Gate.

The next implementation input must add a reproducible way to capture the
production frontier and the smallest bounded expansion threshold, while keeping
pure generation cost and real-RIME query cost as separate measurements. Before
that, a fresh independent Architecture review must verify B1–B3 at the exact
post-reconciliation tip.
