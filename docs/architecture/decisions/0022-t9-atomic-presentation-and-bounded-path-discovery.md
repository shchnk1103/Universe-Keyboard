# ADR 0022: T9 原子展示与固定前台成本路径发现

- **Status:** Accepted — Option A; Stage A passed on pinned fixture, device Product Gate pending
- **Date:** 2026-07-22
- **Decision owners:** 🏛️ Architecture & Knowledge Steward
- **Product authority:** [`PD-KEYBOARD-LAYOUT-9KEY-PINYIN-003`](../../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-003-authorization.md)
- **Assignment:** [`KEYBOARD-LAYOUT-9KEY-PINYIN-003`](../../assignments/keyboard-layout-9key-pinyin-003.md)
- **Extends:** ADR 0004, ADR 0020 and ADR 0021

## Context

ADR 0021 Amendments C/F added synchronous live-RIME probes so sparse candidate comments would not collapse the Path Bar. The merged implementation can execute one initial refinement, multiple candidate-window reads, up to 48 complete-spelling probes, per-letter probes and a restore before returning from one Path Bar tap. Each probe mutates the live session and restores it synchronously on the main input path.

The same implementation installs a new candidate-selection output, hard-refreshes paths, then may reapply the preceding segmented snapshot twice. This permits new marked text/candidates to coexist with old Path Bar choices. Host-facing marked text also remains a plain `String`, so recovery and fallback branches can bypass scattered T9 digit filters.

The physical-device Product Gate for `002` therefore failed on latency, coherent refresh and internal-digit safety.

## Decision Boundary

This ADR may change Path discovery execution, Core revision ownership, RimeEngine transaction shape and the host-preedit boundary. It does not authorize a static pronunciation source, second Chinese engine, schema/vendor change, parallel RIME session or arbitrary background librime access.

## Decision

### 1. Coherent composition revision

KeyboardCore owns a monotonically changing composition revision. A published T9 presentation is coherent only when raw identity, safe host preedit, candidates, Path choices, focus, selection, issued keys and segmented provenance belong to that revision.

- New RIME output, candidate selection, Delete, recovery and fail-closed reset advance the composition revision.
- Current discovery is synchronous and publishes no delayed work, so no separate action epoch is required. Any future asynchronous discovery must add an epoch/token before it can publish.
- `provenanceRevision` remains Path-discovery provenance within a composition revision; it does not replace the composition revision.
- A preceding segmented snapshot is transition input only. It must never be copied back after a new output/path snapshot has been installed.

### 2. Read-only discovery first

One fixed-limit, read-only `candidateWindow` per composition revision is the discovery mechanism. Core derives compatible, live-comment-authorized paths from the immediate output plus that window.

The accepted production limit is `48`. The pinned Stage A fixture covered all three frozen cases at `16`, `24`, `32` and `48`; `48` is retained because the existing deterministic lower-ranked test places a required alternative at global index 16. This is one fixed read, not the former 48-spelling mutation loop.

- Discovery never loops through candidate windows until a desired Path count is reached.
- Path tapping consumes an already issued snapshot; it does not enumerate spelling candidates.
- If Stage A proves that one window cannot cover required paths, Stage B may evaluate a single RimeBridge probe transaction as a supplementary mechanism. Stage B is not accepted by this Proposed ADR.

### 3. Structural foreground budget

No millisecond budget is accepted without comparable device evidence. The following structural budget is accepted:

| Action | Core-to-RimeEngine session operations |
|---|---|
| Ordinary T9 key | `1 processKey` + at most `1 candidateWindow` |
| Successful Path tap | `1 replaceInput` + at most `1 candidateWindow` |
| Failed Path tap | successful-path budget + at most `1 restore replaceInput` |
| Candidate selection | `1 selectCandidate` + at most `1 candidateWindow` |

The operation count must not scale with input length, candidate spelling count or the predecessor 48-probe limit.

### 4. Transaction and rollback

A T9 action consumes one coherent old snapshot and may publish only one coherent new snapshot.

Success requires exact requested raw identity, no unexpected commit, usable composition and current-revision provenance. Failure restores the previous raw at most once. Exact usable restore republishes the complete old snapshot; failed restore resets/fails closed to an empty safe snapshot. Intermediate candidates, Path choices or marked text never publish.

### 5. Host-visible preedit provenance

All marked-text writes use a validated value with one of these sources:

- projected T9 pinyin;
- explicit Path spelling;
- confirmed Chinese plus safe remainder;
- explicit number-page numeric input.

The first three reject internal ASCII digits at construction. Explicit numeric input can only originate from an explicit number-page action, never from `RimeOutput.rawInput` or T9 recovery identity.

## Options

### A. One read-only candidate window

Accepted. It preserves the live session and current RIME authority with one bridge read. Stage A evidence is recorded in [`keyboard-layout-9key-pinyin-003-stage-a-evidence.md`](../../assignments/keyboard-layout-9key-pinyin-003-stage-a-evidence.md).

### B. One bounded RimeBridge probe transaction

Conditional Stage B. It could cross the bridge once and restore the session once, but internal librime work must still be counted. Wrapping the existing 48-probe loop is not fixed cost. Any accepted API must return bounded evidence and mandatory restore status while Core retains parsing/ranking ownership.

### C. Canonical pronunciation source with selection-time validation

Rejected for this Assignment. It changes pronunciation authority and resource/version policy. If A and B fail, the task stops for a new Product Decision and superseding ADR.

## Prohibited Implementations

- Per-spelling `replaceInput -> candidateWindow -> restore` on Path tap
- Repeated candidate-window paging until five choices are found
- Hiding linear librime work behind one bridge method
- Reapplying an old Path snapshot after a new RIME output
- UIKit path generation, comment parsing or revision repair
- Static pronunciation graph, second session/engine or arbitrary background librime access
- Global digit removal that breaks explicit user numeric input
- Raw, candidate, Path or host text in diagnostics

## Stage A Spike Result

Against the pinned T9 fixture, record one-window coverage and session invariance for the synthetic long-input, post-candidate and `qiu -> le` shapes. The Spike must record window limit, result counts, Core/bridge operation counts, raw/session identity before and after via a read-only snapshot, and missing required choices without logging private text. A write such as `replaceInput` cannot serve as the after-read because it could repair the session under test.

The pinned fixture passed all three frozen cases at every evaluated limit (`16`, `24`, `32`, `48`) and preserved exact raw identity around the read. Option A is therefore accepted. Stage B was not started and no production batch/probe API was added.

## Consequences

- Path Bar responsiveness becomes an architecture invariant based on operation count, while device latency remains a separate Quality/Product Gate.
- Candidate selection and Partial Commit transitions must be expressed as one state transition instead of install-then-restore patches.
- Tests must inspect every marked-text write, not only final text.
- Existing 48-spelling generation may remain as a pure test/reference utility but cannot execute on the foreground Path action.
