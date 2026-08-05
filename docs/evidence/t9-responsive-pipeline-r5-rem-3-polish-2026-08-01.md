# T9 responsive pipeline R5-Rem-3-Polish — chrome flicker — 2026-08-01

**Status:** `Closed — Polish-2 device re-pair PASS (chrome stable; key-follow retained)`  
**Product:** option **1** after Rem-3-Device residual P1 (candidate/Path flicker)  
**Code tip:** `80ef54b` / `b359ea9` (Polish-2)  
**Engineering review:** `Pass with conditions` on current tip; **P1-D2 open**
(stable stale Candidate/Path chrome versus frozen disabled/cleared contract)
**Parent evidence:** [`t9-responsive-pipeline-r5-rem-3-device-2026-08-01.md`](t9-responsive-pipeline-r5-rem-3-device-2026-08-01.md)  
**Non-claims:** Product Gate / ADR Accept / default-on not claimed

## Problem

Device Arm B double-painted every key (empty candidate/Path → full).

## Fix trail

### Polish-1 (`d056d26`)

- Deferred L1 visual ~48 ms; fast L2 cancels L1.
- Device retest: more responsive; flicker **less** but still present.

### Polish-2 (`80ef54b`)

- L1 visual **only** updates host preedit (`·`×N) + metrics.
- **No** chrome clear, **no** Extension `syncUI` on L1.
- Candidate/Path change only on engine L2.

## Device re-pair — Polish-2 PASS

| Field | Value |
|---|---|
| Device | iPhone 13 Pro `DoubleShy0N` |
| Binary | Debug + `T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED` (Polish-2) |
| Fixture | same long T9 sequence |
| KEY END (paste) | n≈25; mean **~1.3 ms**; ≥100 **0** |
| VISIBLE provisional | **4** (lag ~48–55 ms on slow keys) |
| VISIBLE engine | **23**; lag p50 **~8 ms**; SLOW still off KEY END |
| `fillCandidateBar items=1` | **0** in paste |
| provisional near items=1 | **0** |
| Subjective | Human: **肉眼已经很难发现闪烁**；跟手保留 |

## Automated

| Suite | Result |
|---|---|
| focused ResponsiveProvisional | **12/0** |
| full KeyboardCore | **854/0** |

## Teardown

Reinstalled gate-off Arm A Debug after re-pair close.

## Residual / next

- dual-gate still **default-off**
- Product/Architecture must resolve P1-D2 (affordance correction or formal
  host-preedit-only Amendment) and complete the follow-up independent review
- Further UI polish is optional only after that contract decision
- Product Gate / ADR Accept still closed
