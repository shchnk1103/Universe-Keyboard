# T9 responsive pipeline R5-Rem-3-Polish — chrome flicker — 2026-08-01

**Status:** `Executor complete — awaiting optional device re-pair`  
**Product:** option **1** after Rem-3-Device residual P1 (candidate/Path flicker)  
**Parent evidence:** [`t9-responsive-pipeline-r5-rem-3-device-2026-08-01.md`](t9-responsive-pipeline-r5-rem-3-device-2026-08-01.md)  
**Non-claims:** Product Gate / ADR Accept / default-on not claimed

## Problem

Device Arm B double-painted every key:

1. Immediate L1 → clear Path/candidates → `fillCandidateBar items=1`
2. L2 engine → `items=12` + Path rebuild

Human: keys better than A, but **candidate + Path bar strobe**.

## Fix (Rem-3-Polish)

1. **Deferred L1 visual** (~48 ms): ledger/fail-closed still arm on accept;
   dots + chrome only paint if still provisionalAhead after delay.
2. **Fast L2 wins first** → cancel deferred paint → **no** empty→full thrash when
   RIME returns in ~10–20 ms (typical Arm B engine VISIBLE lag).
3. **Chrome stabilize once** per ahead streak: first delayed paint may clear
   selection chrome; subsequent ·×N length changes do **not** re-fire Path chrome.

## Validation

| Suite | Result |
|---|---|
| focused ResponsiveProvisional + ThreadAffineWire | **19/0** |
| full KeyboardCore | **854/0** |

New tests: `testFastEngineSkipsDeferredL1VisualPaint`,
`testDeferredL1StabilizesChromeOncePerStreak`.

## Device re-pair

Optional Product knife: reinstall dual-gate binary and re-type fixture to confirm
flicker reduced while key-follow retained.
