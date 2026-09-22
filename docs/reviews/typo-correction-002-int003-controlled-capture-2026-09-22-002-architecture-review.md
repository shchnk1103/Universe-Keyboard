# Architecture Review: TYPO-CORRECTION-002-INT003-CONTROLLED-CAPTURE-002

## Review identity

| Field | Value |
|---|---|
| Reviewer role | Architecture & Knowledge Steward (read-only) |
| Runtime | Grok Bot iOS开发大师 — same conversation lineage as capture coordinator; **not** a third-party fresh runtime |
| Review date | 2026-09-22T22:42:00+08:00 Asia/Shanghai |
| Review mode | Strictly read-only on frozen evidence + hash recompute; no Simulator recapture, no source edit |
| Assignment | `TYPO-CORRECTION-002-INT003-CONTROLLED-CAPTURE-002-ARCHITECTURE-REVIEW` |
| Authorization | `AUTH-TYPO-CORRECTION-002-INT003-CONTROLLED-CAPTURE-002-ARCHITECTURE-001` |

## Exact review binding

| Item | Bound value |
|---|---|
| Evidence receipt | `docs/evidence/typo-correction-002-int003-controlled-capture-2026-09-22-002.md` |
| Evidence SHA-256 (recomputed) | `d2169d4443720d9aa9013c14e02f7b7e24e3482768d23f5655750d0546cfee9d` |
| Run ID | `TC2-SIM-20260922-223301-INT003-CONTROLLED-002` |
| Source commit / tree | `e1b28aebe8f6b2f2a8587db1e525e332aa9bfe00` / `fa7905dc8451e49ff25c1443e4a141d4568804eb` |
| Simulator | iPhone 17 Pro Max / iOS 27 / `06C5BC3E-7599-4761-A1A2-71DAEA991474` |
| Smoke JSONL SHA-256 | `f614cec7e4c6ffaaba86ce2284eb78978761fc9ccb87271e9307ba02d80aaa8b` (rechecked on disk) |
| Rapid JSONL SHA-256 | `0746d550bd5886dde96cd55da3ef123666b28fa70a9812e05a1bfae6361bd819` (rechecked on disk) |

Evidence file hash matched the receipt binding. Raw smoke/rapid JSONL hashes on the designated Simulator App Group path still matched the receipt at review time.

## Verdict

**Pass with conditions — bounded evidence-architecture review only.**

The receipt correctly upgrades Capture-001’s journal-absence stop into a Run where:

1. Main App / App Group **container** arm is treated as the authoritative arm surface;
2. one-key smoke is correlated to independent Extension `touch.terminal` events;
3. conditional rapid trace **runs** once that journal boundary is met;
4. measured cadence gaps are reported without inventing a global &lt;180 ms product pass.

No architecture contradiction was found inside this exact binding. Conditions below must remain visible to Quality and Product.

## Review findings

### 1. Arm surface and dual-prefs lesson

The receipt’s insistence on App Group **container** prefs (and the prior UI-arm retest lesson) is architecturally correct. Host `defaults` / device-level plist alone previously produced a false “armed” reading while Main App UI showed logging off and JSONL stayed absent. Binding arm to the store the Extension actually reads removes that false path from INT-003 entry criteria.

High-fidelity window refresh before this Run is appropriately scoped as arm hygiene, not as a substitute for `logging_enabled`.

### 2. Smoke: UI action vs product-event correlation

Separation remains sound and is now **positively** evidenced:

- Human visible-key attestation is the UI-layer delivery claim;
- Independent Diagnostics JSONL growth plus `touch.terminal` is the product-event correlation claim;
- Candidate text/selection remain out of scope and unclaimed.

Pair-like double `touch.terminal` per keystroke is recorded without being collapsed into a single event or treated as failure. That is the right architectural stance: the schema emits what it emits; correlation uses the code the Assignment named.

### 3. Rapid trace: journal-gated execution and cadence honesty

Because independent JSONL existed, running the rapid trace was required rather than optional. The receipt:

- records an ordered monotonic timeline;
- publishes inter-key start gaps `[910.993, 177.128, 140.088, 193.310]` ms;
- correctly refuses a global &lt;180 ms claim when any authoritative inter-key gap is ≥180 ms.

This matches the capture Assignment’s stop/inconclusive rule for the cadence bar without discarding the timeline as useless.

### 4. ProcessInstanceID churn between smoke and rapid

Smoke growth is on `D1E2DBB9-…`; rapid growth is on `92E7E0EA-…`. The receipt discloses churn instead of forcing a single-process narrative. Architecturally this is acceptable for a Simulator Human-driven Run **as a residual**: same Run ID, same tip/Simulator/arm method, but not a single Extension process lifetime. Quality may weight how much same-process continuity is required for INT-003 cadence interpretation; Architecture does not invent continuity that the journal does not show.

### 5. Package / install identity depth

This evidence package binds tip `e1b28ae…` / tree `fa7905dc8451e49ff25c1443e4a141d4568804eb` and Simulator UDID, and re-checks journal artifact hashes. It does **not** re-list fresh main-app / nested-extension bundle SHA-256 for this exact install moment (unlike Capture-001). Condition: treat tip+Simulator+journal hashes as sufficient for **journal-path Architecture** review; any Quality or Product bar that demands fresh package hashes needs them under a separate binding or a docs amendment AUTH—not inferred here.

### 6. Residuals retained from the parent lane

| Residual | Disposition | Next owner |
|---|---|---|
| Reviewer independence weaker than Capture-001 Arch (same agent lineage as capture coordinator) | **accept with condition** — Human authorized this continuation; residual remains visible | Product may require a third-runtime re-review later |
| Extension process churn smoke→rapid | **accept as recorded boundary** | Quality |
| &lt;180 ms cadence bar not met | **accept as receipt conclusion** — not reframed as pass | Quality / optional new cadence Run |
| Installed bundle hashes not re-frozen this Run | **accept with condition** | Environment / Quality if demanded |
| `RimeRuntimeProvenance.swift` still absent on tip | Retained capability-gap; not in this review’s repair scope | Separate lane |
| Independent Quality review | Open | New Quality AUTH required |

## Non-claims

This Architecture review does not claim:

- formal INT-003 Product pass/fail;
- achieved global &lt;180 ms cadence;
- QA-001, candidate selection, paired performance, physical-device results;
- Product / Quality / Release Gate; parent/child Close;
- commit / push / PR / merge / TestFlight / Release;
- diagnostics repair or `RimeRuntimeProvenance` restoration;
- a Quality verdict.

## Next legal action

Open a **new** independent Quality Authorization bound to evidence SHA-256 `d2169d4443720d9aa9013c14e02f7b7e24e3482768d23f5655750d0546cfee9d` and this Architecture receipt. Do not reuse Capture-001 Quality AUTH. Do not Close parent from this review alone.
