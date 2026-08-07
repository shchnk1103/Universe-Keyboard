# Assignment: RESPONSIVE-CANDIDATE-ANOMALY-001 — Dual-gate candidate double-commit + paging stall

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Completed` — A1+B landed; Executor-recorded tests green |
| **Phase** | Fix in Core; optional Human device smoke residual |
| **Parent** | [`T9-RESPONSIVE-PIPELINE-001`](t9-responsive-rime-pipeline-001.md) / [`RESPONSIVE-DEFAULT-ON-001`](responsive-default-on-001.md) |
| **Non-claims** | Not performance SLO; not device Product Gate; not Quality-reverified |
| **Next** | Optional Human smoke on device; Product Lead may Close residual as `accept` |
| **Residuals** | R-01 device smoke — disposition `accept` (optional; automated Exit met) |

### Root cause (proven in-session)

1. **Double host commit on candidate tap:** Under responsive gate, `selectCandidate` still
   returns into Core `applyNormalCandidateSelection` / `finishNormalCandidateSelection`
   (host commit once) **and** the bridge publish path runs `applyResponsivePublishedSnapshot`
   → `applyRimeOutput` with `committedText` (second `insertText` when preedit already
   cleared). Space path does **not** call `selectCandidate`, so it commits once.
2. **Paging stall at page size (~12):** Production dual-gate installs
   `ThreadAffineRimeEngineBridge` without `chromeEngineHint`.
   `candidateWindow` falls back to slicing `lastPublished.output.candidates` (first page
   only). `loadMoreCandidates` at `startIndex == page_size` gets empty + `hasMore=false`.

### Fix contract (landed)

| ID | Change | Ownership |
|---|---|---|
| A1 | Suppress UI publish during bridge `selectCandidate` / `selectCandidateGlobal` after backlog flush; Core select path owns host apply | KeyboardCore bridges |
| B | Owner control-lane read: live `candidateWindow` after `flushPending`; no first-page-only slice | Thread-affine owner + bridge |

### Evidence

| Check | Grade | Result |
|---|---|---|
| `ResponsiveCandidateAnomalyTests` (4) | Executor-recorded | **4/0** |
| Related: Delete + R2 + ThreadAffineWire | Executor-recorded | **38/0** (filtered suite) |

---

**Task ID:** `RESPONSIVE-CANDIDATE-ANOMALY-001`  
**Date / timezone:** `2026-08-07 Asia/Shanghai`  
**Repository Change Type:** `Implementation` + `Tests` + `Evidence`  
**Product Decision source:** Human Product Lead in-session authorization after proven RC under dual-gate default-on parent; investigation under KOS 2.1  
**Architecture:** ADR 0025 Accepted; no ADR amendment required for A1/B (restores single host-apply + real session read)

## Authority

- **Assignment Authority:** Product Lead (Human in-session)
- **Decision Source / Date:** User message 2026-08-07 Asia/Shanghai authorizing A1+B+tests under KOS 2.1
- **Product Approver:** Product Lead (Human)

## Boundary

### Scope

1. Responsive / dual-gate bridges: select publish ownership (A1).
2. Thread-affine owner read path for `candidateWindow` (B).
3. Unit/regression tests with Fake engine (no private host text).
4. DEBUGGING + CHANGELOG + Active Work / Assignment Current Status sync (M-02).

### Non-goals

- Broad dual-gate redesign or pageUp/pageDown ownership refactor unless required by tests
- ChromeEngineHint dual-session hacks
- Device Product Gate / App Store claims
- Logging real user text

### Required Inputs

- ADR 0025; input-pipeline marked-text contract
- Diagnosis in-session (double apply + first-page window)
- Parent dual-gate default-on Assignments

## Assignment

- **Domain Owner:** 🧠 Input Intelligence / 🔧 RIME Platform (responsive candidate path)
- **Executor:** Current agent (this session)
- **Environment Executor:** Not Applicable — Fake-engine unit tests only for Exit automated bar
- **Human Dependency:** Optional device smoke after install (not blocking automated Complete)
- **Architecture Reviewer:** Not Applicable for this knife — restores existing ADR 0025 single-owner / MainActor apply contract; escalate if design expands
- **Quality Reviewer:** Required before formal Close if device claims; automated Exit may Complete as Executor-recorded with residual `accept` for optional Human smoke

## Gates

### Entry Criteria

- [x] RC proven with file/line evidence (not chat-only)
- [x] Product Lead authorized A1+B+tests under KOS 2.1
- [x] Active Work capacity ≤10 after add/remove

### Exit Criteria

- [x] A1: responsive select commits host text exactly once (test)
- [x] B: ThreadAffine `candidateWindow(from: ≥ pageSize)` returns further candidates / correct hasMore (test)
- [x] No privacy-violating logs
- [x] Assignment Current Status + ACTIVE_WORK + DEBUGGING + CHANGELOG synced (M-02)
- [x] Evidence grades labeled Executor-recorded

### Stop Conditions

- Speculative redesign beyond A1/B
- Dual concurrent librime sessions for paging
- Treating Executor-recorded as Quality-reverified
- Privacy-violating diagnostics

## Handoff

- **Handoff Target:** Quality Reviewer (optional device smoke) or Product Lead for Close
- **Required Handoff Content:** commit SHA, test table with grades, residual dispositions
- **Revalidation Trigger:** Any change to select publish policy or owner read path; dual-gate install shape change

### Residual disposition (M-03)

| Residual ID | Owner | Disposition | Pointer |
|---|---|---|---|
| R-01 | Human / Quality | `accept` | Optional device smoke after install; automated Exit complete |

## History

- 2026-08-07: Opened Active after in-session diagnosis; implementation authorized.
- 2026-08-07: A1+B implemented; `ResponsiveCandidateAnomalyTests` 4/0 Executor-recorded; Completed with R-01 accept.
