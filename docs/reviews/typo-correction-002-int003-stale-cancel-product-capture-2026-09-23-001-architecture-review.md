# Architecture Review: TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001

## Review identity

| Field | Value |
|---|---|
| Reviewer role | Architecture & Knowledge Steward (read-only) |
| Runtime | Grok Bot iOS开发大师 — same conversation lineage as Capture consume/amend coordinator; **not** a third-party fresh runtime |
| Review date | 2026-09-23T21:22:00+08:00 Asia/Shanghai |
| Review mode | Strictly read-only on frozen evidence + evidence-file hash recompute on main tip after #157; no Simulator recapture, no Swift edit |
| Assignment | `TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001-ARCHITECTURE-REVIEW` |
| Authorization | `AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001-ARCHITECTURE-001` |

## Exact review binding

| Item | Bound value |
|---|---|
| Evidence receipt | `docs/evidence/typo-correction-002-sim-run-2026-09-23-int003-stale-cancel-product-001.md` |
| Evidence SHA-256 (recomputed on tip) | `3dde0362923fb36071c611134c6c0022ce70d20839afa2dd67894260428835b4` |
| Run ID | `TC2-SIM-20260923-201910-INT003-STALE-CANCEL-PRODUCT-001` |
| Main tip after #157 squash-merge | `b9b5f3b565b06845297cd2fdfbb5c4454bd83ba4` |
| Main tree after #157 | `26ae1ab6f2571205de8537f79a044607529d6be1` |
| Capture install tip | `80091f35cc5411b292eca78662f39e2b91694045` |
| Markers impl tip | `c1869cf9dda9f1643495e8ebdcfb67acc788b843` (#152) |
| Capture AUTH | `AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001` (**Consumed**) |
| Markers AUTH | `AUTH-TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001` (**Consumed** — not reopened) |
| Simulator | iPhone 17 Pro Max / iOS 27 / `06C5BC3E-7599-4761-A1A2-71DAEA991474` |
| Journal relative | `v1/g1/open/keyboard_extension-583B3AB8-86FE-4480-BD1D-5EEF9F1BB1E2-20260923T13-0.jsonl` |
| Journal SHA-256 (bound in evidence) | `a9af14932b1a0b78595c26966a6dd16fe4ba2aa654a91ec760f86fa12bda64cc` |
| processInstanceID | `583B3AB8-86FE-4480-BD1D-5EEF9F1BB1E2` |
| appearanceID | `320926C3-3992-473E-A75C-739BF054334B` |

Evidence file hash matched the receipt on main tip `b9b5f3b…`. Raw JSONL was **not** re-hashed on this Architecture review host (designated Simulator App Group path unavailable here); journal identity remains evidence-bound only.

## Verdict

**Pass with conditions — bounded evidence-architecture review only.**

Capture ≠ Product Gate. The observation package correctly binds:

1. App Group **container** arm + HF refresh as Extension-visible arm surface;
2. same-process smoke→rapid (single `processInstanceID` / `appearanceID`);
3. rapid consecutive inter-touch gaps against the &lt;180 ms bar (15/15), with honest even-index partial (6/7);
4. positive `typo_recall.debounce_cancelled` / `debounce_scheduled` journal (26/27 full; 8/8 in rapid window);
5. Human visual both attestations (no contextual candidates while typing; post-pause refresh against final composition);
6. explicit residuals for `fence_discarded=0` and high `query_*` volume — without inventing Gate.

No architecture contradiction was found inside this exact binding. Conditions below must remain visible to Quality and Product.

## Review findings

### 1. Arm / HF / markers tip binding

Install tip `80091f35…` includes markers_impl `c1869cf9…`. Container prefs + HF refresh before Human visible-key Capture match the Cadence-003 / Capture-002 arm lesson. Markers AUTH stays **Consumed** (not reopened). Binary marker-string presence is correctly treated as install hygiene; cancel proof comes from journal codes, not from dylib strings alone.

### 2. Same-process smoke→rapid

All `touch.terminal` events share one Extension process and one appearance. This preserves Cadence-003’s same-process continuity for **this Run**. Phase-boundary gap smoke→rapid (~28567 ms) is correctly excluded from the rapid &lt;180 bar.

### 3. Cadence measurement honesty

Rapid slice touches 62–77: consecutive gaps 15/15 &lt;180 ms; even-index starts 6/7 &lt;180 (one ~200.27 ms); odd-index 7/7 &lt;180. The receipt does not collapse the single even-index miss into a global engineering guarantee, and does not treat the intentional smoke→rapid pause as a rapid-bar failure. That separation is architecturally sound and consistent with Cadence-003 methodology.

### 4. Stale-cancel observability (`typo_recall.*`)

| Marker | Full journal | Rapid window | Architecture reading |
|---|---:|---:|---|
| `debounce_scheduled` | 27 | 8 | Positive reschedule path observed |
| `debounce_cancelled` | 26 | 8 | Positive cancel path observed |
| `fence_discarded` | **0** | — | Cancel observed via debounce, **not** fence discard |
| `epoch_bumped` | 2 | — | Appearance-only (~13:02:23Z); no invalidate-path epoch during typing |
| `query_begin` / `query_outcome` | 574 / 574 | 16 / 16 | Dense query markers; **do not alone** prove “lookup only after pause” |

Positive debounce cancel/reschedule is the right primary cancel correlator for this markers tip. `fence_discarded=0` is **not** cancel failure; it is a residual that future correlators must not require fence discard as the sole cancel proof. Post-bump invalidate-path `debounce_cancelled` caveat is **N/A for the typing path this Run** but remains binding for future correlators when epoch bumps occur mid-composition.

### 5. Human visual vs journal residual on “post-pause only”

Human visual both attestations are **Pass** and are required for the Product-facing observation narrative. Architecture accepts them as the UI-layer claim while keeping the honest residual: dense `query_*` volume means **journal alone** does not prove “only post-pause lookup against final composition.” Quality must not silently promote Human visual into a journal-only proof, and must not silently demote the visual attestations either — keep both layers visible.

### 6. Package / install identity depth

Unlike Cadence-003, this evidence **does** freeze main executable / Keyboard.appex / Keyboard.debug.dylib SHA-256 for the install moment. Tip + Simulator + journal hash + package hashes are sufficient for journal-path Architecture review of this observation package.

### 7. Residuals

| Residual | Disposition | Next owner |
|---|---|---|
| `fence_discarded` count 0 this Run | **accept as recorded boundary** — cancel via debounce cancel/reschedule | Quality / future correlators |
| High `query_begin`/`query_outcome` (574/574) | **accept as Architecture residual** — Human visual covers post-pause narrative; journal alone insufficient | Quality / optional Product residual |
| `epoch_bumped` appearance-only; invalidate-path caveat N/A this Run | **accept with caveat retained for future Runs** | Quality / correlators |
| Reviewer independence weaker than a third-runtime Arch (same agent lineage as Capture coordinator) | **accept with condition** — Human authorized continue after #157 CI green; residual remains visible | Product may require third-runtime re-review |
| Raw JSONL not re-hashed on this Architecture review host | **accept with condition** — evidence file hash + evidence-bound journal SHA used | Environment / Quality if disk recheck demanded |
| INT-003 Product Gate / QA-001 Gate / parent Close | **not claimed** — Capture ≠ Gate | Product (separate Gate AUTH) |
| Independent Quality review | **Required next** under a **new** Quality AUTH | Quality |
| Markers AUTH | Remains **Consumed** | Do not reopen |

## Non-claims

This Architecture review does not claim:

- formal INT-003 Product pass/fail or Product Gate;
- QA-001 Gate, candidate selection, paired performance, physical-device results;
- that dense `query_*` journal alone proves post-pause-only lookup;
- that `fence_discarded=0` is a cancel failure (it is not);
- Quality verdict; parent Close; Release / TestFlight;
- diagnostics repair or `RimeRuntimeProvenance` restoration;
- reuse of Cadence-003 / Controlled-Capture-002 Architecture AUTHs as Live authority;
- auto-merge of this Architecture docs PR.

## Next legal action

Open a **new** independent Quality Authorization bound to evidence SHA-256 `3dde0362923fb36071c611134c6c0022ce70d20839afa2dd67894260428835b4` and this Architecture receipt. Do **not** reuse Cadence-003 / Capture-002 Quality AUTHs. Do **not** treat Capture disposition or this Architecture Pass-with-conditions as Product Gate. Do **not** Close parent `TYPO-CORRECTION-002` from this review alone. Leave this Architecture docs PR **unmerged** until Human/parent asks.
