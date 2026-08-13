# CANDIDATE-TOUCH-OBSERVABILITY-001 Execution Evidence — 2026-08-13

## Fixed context

- Base: `7fdd5efa9cb6ec800c1b9c480664d3ba7e532ac7` (`main`, PR #70 merged)
- Branch: `codex/candidate-touch-observability`
- Local environment: Xcode beta, iPhone 17 Pro Simulator, iOS 26.5
- Device baseline attestation: iPhone 13 Pro, iOS 27 beta 5, Debug `⌘R`
- Scope: diagnostics only; no candidate hit area, gesture, selection, RIME, model or input-state change

## Baseline device observation

Human Device Operator repeated one visible candidate using the same installation:

- upper visible third: `0/5`
- middle visible third: `5/5`
- lower visible third: `5/5`
- diagnostics page refresh: `5/5`, with no stall, blank state or crash

This establishes the symptom and the stable reader baseline. It is not evidence for the new probe because it predates the probe build.

## Implemented observation contract

- `candidate.touch_routed`: coarse `upper / middle / lower` plus candidate-cell hit flag
- `candidate.gesture_terminal`: pan-began and cancelled flags
- `candidate.selection_delivered`: selection delegate delivery
- `appearance` plus local `action`: single-finger, short-lived, best-effort correlation only
- no coordinate, candidate index/text, input, host identity/content or free-text v1 field
- Debug-only wiring; every write additionally requires the existing in-memory 30-minute high-fidelity gate
- candidate hit-test result, recognizer policy and commit ordering remain unchanged

## Automated evidence

| Gate | Result |
|---|---|
| RIME vendor verify | Passed, 12 expected artifacts |
| Swift format strict + `git diff --check` | Passed |
| KeyboardCore | Passed, `990/990` |
| Candidate formatter focused test | Passed |
| RimeBridgeTests | Passed |
| App + Keyboard tests | Passed, `185` passed / `3` skipped / `0` failed |
| Debug strict simulator build | Passed |
| Release strict simulator build | Passed |

The focused tests cover coarse band boundaries, typed event round-trip and displayed action/band/flag fields. The 2-second selection and 5-second gesture correlation lifecycle is supported by independent static review rather than a UIKit touch-identity automation.

## Independent review

- Architecture: `Blocker 0 / Major 0`; confirms zero intended candidate behavior change, Debug/high-fidelity gating, typed privacy allowlist and no new synchronous I/O/file-lock work in the touch path.
- Quality initial review found stale-action reuse as Major. Implementation then added cell-hit eligibility, freshness windows and reset on selection, recognized/cancelled/non-cell terminal, appearance change and high-fidelity close/expiry.
- Quality re-review: `Blocker 0 / Major 0 / Minor 2`. Remaining limitations are multi-touch/accessibility identity ambiguity and lack of automated lifecycle-branch coverage. The Human Gate is therefore explicitly limited to one sequential single-finger round.

## Completed Human Gate

The merged Debug payload (`f480dac`) was installed once on iPhone 13 Pro / iOS 27.0 build
`24A5408d`. One sequential single-finger round returned upper/middle/lower
`0/5 · 5/5 · 5/5`. The copied recent window contained no structured candidate-touch events;
legacy geometry lines showed a 48 pt collection with 32 pt cells beginning near y=8.

This closes the observation Assignment: the result is sufficient to transfer the vertical-cell
geometry, early `hitTest` phase assumption and diagnostics-browser interference to
`CANDIDATE-TOUCH-HITBOX-001`. It does not itself prove the follow-up behavior fix.
