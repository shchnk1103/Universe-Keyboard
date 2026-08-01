# T9 responsive pipeline R5-Rem-3-Polish — chrome flicker — 2026-08-01

**Status:** `Executor complete — Polish-2 installed for device re-pair`  
**Product:** option **1** after Rem-3-Device residual P1 (candidate/Path flicker)  
**Parent evidence:** [`t9-responsive-pipeline-r5-rem-3-device-2026-08-01.md`](t9-responsive-pipeline-r5-rem-3-device-2026-08-01.md)  
**Non-claims:** Product Gate / ADR Accept / default-on not claimed

## Problem

Device Arm B double-painted every key (empty candidate/Path → full).

## Fix trail

### Polish-1 (`d056d26`)

- Deferred L1 visual ~48 ms; fast L2 cancels L1.
- Device retest: more responsive; flicker **less** but still present; Human wants
  **zero** abrupt chrome flash — only change when pinyin updates.

### Polish-2 (this knife)

- L1 visual **only** updates host preedit (`·`×N) + metrics.
- **No** `lastRimeOutput = nil`, **no** Path clear, **no**
  `onResponsivePresentationNeeded` on L1 (avoids Extension `refreshCandidateBar`
  / Path rebuild).
- Candidate/Path change only on engine L2 presentation.
- Selection still fail-closed while provisionalAhead.

## Validation

| Suite | Result |
|---|---|
| focused ResponsiveProvisional | **12/0** |
| full KeyboardCore | **854/0** |

## Device re-pair

Install dual-gate Debug after Polish-2; Human re-type fixture; confirm candidate/Path
no empty-flash on L1; key-follow retained.
