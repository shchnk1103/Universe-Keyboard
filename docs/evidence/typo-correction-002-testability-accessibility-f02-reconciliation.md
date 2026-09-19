# Evidence: F-02 / QR-01 overlay on/off same-coordinate reconciliation

> **Status:** Recorded — Simulator-attested, bounded
> **Recorded:** 2026-09-19 Asia/Shanghai
> **Evidence grade:** Quality-reverified Simulator runs (no new capture in this docs slice)
> **Claim:** Architecture `F-02` / Quality `QR-01` is a **bounded Pass**
> **Not:** Product Gate, Device-attested physical, INT-003, QA-001, performance, nine-key, gap-tap, VoiceOver

**Assignment:** [`TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-F02-RECONCILE-001`](../assignments/typo-correction-002-testability-accessibility-f02-reconcile-001.md)
**Authorization (consumed):** [`AUTH-TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-F02-RECONCILE-001`](../authorizations/AUTH-TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-F02-RECONCILE-001.md)
**Architecture 最终处置：** [`typo-correction-002-testability-accessibility-f02-architecture-final.md`](../reviews/typo-correction-002-testability-accessibility-f02-architecture-final.md) — F-02 **有界 Pass**（独立 Architecture；非 Product Gate / 非 child-parent Close）
**Consolidated Quality：** [`typo-correction-002-testability-accessibility-001-quality-consolidated.md`](../reviews/typo-correction-002-testability-accessibility-001-quality-consolidated.md) — child 整包 **Pass with conditions**（独立 Quality；F-02/QR-01 有界 Pass 已收口；UNKNOWN 与生命周期未关闭仍为条件；非 Product Gate / 非 child-parent Close / 非 publication）

**Implementation context (input, not published):**
worktree `/private/tmp/universe-keyboard-typo-correction-002-testability-accessibility-001`
branch `codex/typo-correction-002-testability-accessibility-001`
baseline `9eb83158e49218c1e8f75dbe7dd9e0390db81409` plus the uncommitted testability/accessibility diff.

Parent sidecar Assignments/Auths remain in
`/private/tmp/universe-keyboard-typo-correction-002-provenance-sidecar/docs/`
and are **links only**. This receipt is the residual Source of Truth for QR-01/F-02.

This slice **does not** run Simulator again and **does not** tap keys.

## Bound runs

| Arm | Overlay | Run ID | Device | Result used |
|---|---|---|---|---|
| A | OFF (`TOUCHPROBE ov=0`) | `QR-F02-REVAL-20260919T071659Z-FC1AEA63` | iPhone 17 Pro Max / iOS 27.0 / `06C5BC3E-7599-4761-A1A2-71DAEA991474` | existing UI harness tap of visible `q` at AX frame center |
| B | ON (`TOUCHPROBE ov=1`) | `QR-F02-REVAL-20260919T073732Z-113A0BDB` | same device | coordinate tap at Arm A center `(25.65, 697.5)` without `launch()` |

Shared visible key: **q** face center from Arm A AX frame `{{7.0, 675.0}, {37.3, 45.0}}` → **(25.65, 697.5)** in the 440×956 application space.

## Arm A — overlay OFF

Root: `/tmp/uk-f02-reval/QR-F02-REVAL-20260919T071659Z-FC1AEA63/`

| Fact | Pointer |
|---|---|
| `defaults` overlay | `0` (`overlay-off/defaults-read.txt`) |
| `TOUCHPROBE` | `[15:23:42.662] … ov=0 k=32 face=13 fill=19 maxVH=45 maxTH=54` |
| Action path | `KBDVIS … began role=character` → `endedInside` → `insertKey enter after keyDown (27.4ms)` @ `15:23:56` |
| AX `q` | probe `overlay-off/attachments/95B58F65-46CD-4D42-A667-E9CBD1DCC0D7.txt` SHA-256 `c27040e16aa4b435995904e1e59d4d3722b22bbc3b8314f3f05185cc063bba5f` |
| xcresult | `overlay-off/test.xcresult` (source `Test-UniverseKeyboardUITests-2026.09.19_15-22-25-+0800.xcresult`) **Passed** |

No `typeText` / pasteboard / `setMarkedText` / `documentContext` on this arm.

## Arm B — overlay ON

Root: `/tmp/uk-f02-reval/QR-F02-REVAL-20260919T073732Z-113A0BDB/`

| Fact | Pointer |
|---|---|
| `TOUCHPROBE` | `[15:35:08.888] … ov=1 k=32 face=13 fill=19 maxVH=45 maxTH=54` |
| Orange overlay screenshot (before tap) | `overlay-on/immediately-before-tap.png` SHA-256 `ccf7caf31e1d24a2ed5cbeacc8ad00b0a56f452ae8288af6d0f3929b6c06f4f6` |
| Coordinate tap | XCUI `Tap Application 'com.apple.MobileSMS'[0.00, 0.00] -> (25.6, 697.5)` |
| Action path | `[15:43:22.029] KBDVIS began role=character` → `endedInside` → `insertKey enter after keyDown (28.0ms)` (`overlay-on/log-delta-around-tap.txt` SHA-256 `ad72ead65309fa4856cbdc9fb10195b508650f32b1fd22bc9453206bae55abcf`) |
| After screenshot | composer shows `q`; overlay chrome still `ov=1` — `overlay-on/immediately-after-tap.png` SHA-256 `3fc2a1ba90a35dcca7214cb6f2329d1db7abfee73459ace0306bf30083572ef6` |
| xcresult | `overlay-on/test.xcresult` (source `Test-F02TapUITests-2026.09.19_15-42-57-+0800.xcresult`) **Passed** |

Tap used public XCUI coordinate synthesis on already-visible Messages; Quality runner lived under `/tmp/.../runner/`, not the product tree. Logs record `keyLength`, not the glyph.

## Disposition

| ID | Owner | Disposition | Bound |
|---|---|---|---|
| **QR-01 / F-02** | Quality / Architecture | **Pass (bounded)** | 26-key Messages, visible **q** face center `(25.65, 697.5)`, Debug overlay OFF vs ON, iPhone 17 Pro Max / iOS 27 Simulator. Both arms: `character` `began`/`endedInside` + existing `insertKey` path. Overlay is paint-only (`isUserInteractionEnabled = false`). |
| Gap / 缝区 same-coordinate tap | Quality | **UNKNOWN** | Not exercised |
| Nine-key overlay on/off | Quality | **UNKNOWN** | Not exercised |
| Physical-device VoiceOver | Quality / Human | **UNKNOWN** | Simulator only |
| Globe / function-key identifier publication | Keyboard UI | **accept / out of this residual** | Not required to close F-02 |
| INT-003 | Input Intelligence | **not claimed** | Parent `TYPO-CORRECTION-002` |
| QA-001 | Quality | **not claimed** | Parent |
| Performance / SLOW RIME lines | Quality | **not claimed** | Arm B log contains a SLOW RIME line; ignored for this residual |
| Sidecar observability | Input Intelligence | **not claimed** | Parent continues |

## Explicit non-conclusions

- Bounded Pass **≠** Product Gate, Release, TestFlight, or publication.
- Does **not** close `TYPO-CORRECTION-002` or `TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-001`.
- Does **not** close the sidecar F-02 revalidation Assignment; this receipt supersedes only the **QR-01/F-02 unknown** row with a bounded Pass.
- Independent Architecture final close is recorded: [`architecture-final`](../reviews/typo-correction-002-testability-accessibility-f02-architecture-final.md).
- Independent consolidated Quality is recorded: [`quality-consolidated`](../reviews/typo-correction-002-testability-accessibility-001-quality-consolidated.md) — **Pass with conditions**. This receipt is not that verdict; F-02/QR-01 remains a bounded Pass only.
- Publication requires a **new** Authorization.
