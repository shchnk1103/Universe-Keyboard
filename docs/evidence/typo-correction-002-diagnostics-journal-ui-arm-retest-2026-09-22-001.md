# Evidence: TYPO-CORRECTION-002 Diagnostics Journal UI-arm retest — 2026-09-22-001

## Identity

| Field | Value |
|---|---|
| **Assignment** | TYPO-CORRECTION-002-DIAGNOSTICS-JOURNAL-UI-ARM-RETEST-001 |
| **Authorization** | AUTH-TYPO-CORRECTION-002-DIAGNOSTICS-JOURNAL-UI-ARM-RETEST-001 |
| **Run ID** | TC2-SIM-20260922-222702-DIAG-JOURNAL-UI-ARM-RETEST-001 |
| **Source tip** | e1b28aebe8f6b2f2a8587db1e525e332aa9bfe00 |
| **Worktree** | `/Users/doubleshy0n/.codex/worktrees/typo-correction-002-int003-controlled-capture-001/Universe Keyboard` |
| **Simulator** | iPhone 17 Pro Max / iOS 27 / `06C5BC3E-7599-4761-A1A2-71DAEA991474` |
| **App Group** | `group.com.DoubleShy0N.Universe-Keyboard` |
| **Diagnostics root** | `…/AppGroup/0469C0D3-0C89-4988-BD85-314F03EC34B3/Diagnostics` |
| **Executor** | Grok Bot iOS开发大师 |
| **Human arm / one-key** | Attested before AUTH live (~22:25 Asia/Shanghai) |
| **Verified at** | 2026-09-22T22:27:02+08:00 Asia/Shanghai |

## Verdict for this Run

**Pass (bounded):** After Human enabled diagnostics logging in the **Main App UI**, an independent Keyboard Extension Diagnostics JSONL segment was present under the dynamic filename pattern. This corrects the earlier arm-preflight Run’s false confidence from host `defaults` / device-level plist alone.

## Dual-prefs discrepancy (content-free)

| Store | Path (abbreviated) | `logging_enabled` after UI arm | Notes |
|---|---|---|---|
| Device-level | `Devices/…/data/Library/Preferences/group.com….plist` | `true` | Also used by prior host-side arm; can diverge from UI |
| App Group container | `…/AppGroup/0469C0D3-…/Library/Preferences/group.com….plist` | `true` | Now matches Main App UI; this is the store that mattered for journal production in this retest |
| App Group container | `log_category_disp` | absent | Defaults to enabled per product code |
| App Group container | `diagnostics_high_fidelity_expiration` | present (`2026-09-22T14:54:47.861335` wall as stored) | Human / Main App high-fidelity window |

**Lesson recorded:** Writing or reading only the device-level / `simctl defaults` view is **not** sufficient to claim Main App diagnostics arm. Prefer confirming the App Group **container** prefs and/or the Main App Diagnostics UI.

## Prior Run contrast

| Run | Arm method | JSONL |
|---|---|---|
| `TC2-SIM-20260922-221630-DIAG-JOURNAL-ARM-001` (preflight) | Host prefs / device-level emphasis; Main App UI showed OFF | **Absent** |
| `TC2-SIM-20260922-222702-DIAG-JOURNAL-UI-ARM-RETEST-001` (this retest) | Human Main App UI ON + one visible key | **Present** |

## Dynamic JSONL binding

Relative path:

`Diagnostics/v1/g1/open/keyboard_extension-D1E2DBB9-F098-4EEA-8964-3D30576D51DB-20260922T14-0.jsonl`

| Field | Value |
|---|---|
| **origin** | `keyboard_extension` |
| **processInstanceID** | `D1E2DBB9-F098-4EEA-8964-3D30576D51DB` |
| **hour / part** | `20260922T14` / `0` |
| **generation** | `1` (path `g1`; lease `generation\":1`) |
| **event lines** | 11 |
| **SHA-256** | `4ec1ff7a730f0aa8de1c68ab169275fc900350b262e24c45c6ef10c28a9bb123` |
| **Size** | 6491 bytes (mtime ~22:25 local) |

Lease (content-free summary): origin `keyboard_extension`, same processInstanceID, generation 1; SHA-256 `8cc37d61575b6e282777334cbdfd63121feb610c397afb087cde42ced38088d0`.

`control.json` still `{"schemaVersion":1,"currentGeneration":1}` — SHA-256 `baaa646c583ad8bb4c3d983f0069460e8afc8cbe0b3eb9212397eadc4a71fea4`.

### Content-free event codes observed (no user phrase / candidate text)

`presentation.appeared`, `candidate.visibility_changed` (multiple), `touch.terminal` (×2), `rime.owner.published`, `ui.applied`. Categories seen: `DISP`, `ENGINE`.

## One-key

Human attested one visible-key UI tap after enabling Main App diagnostics. No typeText / clipboard / host injection / candidate select by Executor.

## Non-claims

- No formal INT-003 pass/fail or rapid-trace timeline proof
- No global &lt;180 ms claim
- No candidate-selection / QA-001 / paired performance
- No Product / Quality / Release Gate; no parent Close
- No commit / push / PR / merge under this AUTH
- No production code change; no `RimeRuntimeProvenance` restoration

## Checkout hygiene

Docs-only on clean tip `e1b28ae`. Home main and reval-08-docs worktrees untouched this Run.

## Recommended next

Independent INT-003 controlled capture may be re-attempted only under a **new** Capture AUTH that binds: Main App UI arm confirmed (container prefs + UI), dynamic JSONL path pattern, and a fresh Run ID. Do not reuse consumed INT-003 Capture / Architecture / Quality AUTHs.
