# CANDIDATE-TOUCH-HITBOX-001 Execution Evidence — 2026-08-13

## Fixed input

- Base: `f480dac` (`main`, PR #71 merged)
- Branch: `codex/candidate-touch-hitbox-followup`
- Device evidence: iPhone 13 Pro / iOS 27.0 build `24A5408d`, Debug `⌘R`
- Fixed round: upper/middle/lower `0/5 · 5/5 · 5/5`
- Non-goals: no RIME, model, candidate ordering/text/width, input state-machine or App Group root change

## Root cause

Legacy geometry from the fixed device run showed the compact candidate collection at 48 pt high,
while every selectable cell was 32 pt high and centered at approximately `y=8...40`. Successful
bar points around y 28–31 converted to cell points around y 20–23. The visible upper third was
therefore mostly inside the collection but outside every selectable cell; middle and lower taps
remained selectable.

The structured probe produced no touch events because it required UIKit to expose `.began` during
`hitTest`, which the physical extension did not do. The diagnostic page independently showed two
presentation issues: the one-second follower drove the toolbar spinner, and per-cell visibility
events saturated the recent 500-record window.

## Implemented boundaries

- Compact candidate cell height now equals the existing 48 pt collection container. The 32 pt
  content remains visually centered; horizontal width, expanded-panel height and selection order
  are unchanged.
- Structured routing accepts exactly one direct touch and deduplicates by identity without relying
  on `.began`; it remains Debug/high-fidelity-only and content-free.
- Candidate visibility callbacks coalesce into one stable aggregate event per 40 ms layout burst
  and cancel on suspension, high-fidelity close/expiry and deinit.
- Automatic log following stays silent in the toolbar. Search freezes root refresh and owns paging
  serially, waiting for manual pagination and validating token/revision after every await.
- Search admits complete records incrementally up to 5 MiB / 10,000 records. The first record that
  does not fit stops the cursor; it is never skipped to expose older records.

## Automated evidence

| Gate | Result |
|---|---|
| RIME vendor verify | Passed, 12 expected artifacts |
| Swift format strict + `git diff --check` | Passed |
| KeyboardCore | Passed, `990/990` |
| RimeBridgeTests | Passed |
| DiagnosticsStore focused | Passed, `21/21` |
| App + Keyboard tests | Passed, App `189` passed / `3` skipped; Keyboard `6/6` |
| Debug strict simulator build | Passed |
| Release strict simulator build | Passed |

Focused tests cover manual/search cursor ownership, cancellation and late results, search-time date
selection, byte/record admission, cross-page continuity and live-refresh pause. UIKit geometry and
physical touch delivery remain a post-merge human residual.

## Independent review

- Architecture final: `Blocker 0 / Major 0 / Minor 0`.
- Quality final: `Blocker 0 / Major 0`; remaining UIKit geometry automation gap is the explicit
  post-merge physical-device residual, not a simulator substitute.

## Residual Human Product Gate

After merge and one authorized Debug installation, repeat exactly one sequential single-finger
upper/middle/lower round on a fixed visible candidate. Expected behavior is `5/5 · 5/5 · 5/5`,
with no change to candidate visual alignment. Then open diagnostics, confirm search remains visible,
the refresh icon does not flash once per second, relevant structured events are searchable, and five
manual refreshes do not stall, blank or crash. This gate is not yet executed and no device-pass claim
is made here.
