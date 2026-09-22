# Evidence: TYPO-CORRECTION-002 INT-003 controlled capture — 2026-09-22-002

## Identity

| Field | Value |
|---|---|
| **Assignment** | TYPO-CORRECTION-002-INT003-CONTROLLED-CAPTURE-002 |
| **Authorization** | AUTH-TYPO-CORRECTION-002-INT003-CONTROLLED-CAPTURE-002 |
| **Run ID** | TC2-SIM-20260922-223301-INT003-CONTROLLED-002 |
| **Source tip** | e1b28aebe8f6b2f2a8587db1e525e332aa9bfe00 |
| **Worktree** | `/Users/doubleshy0n/.codex/worktrees/typo-correction-002-int003-controlled-capture-001/Universe Keyboard` |
| **Simulator** | iPhone 17 Pro Max / iOS 27 / `06C5BC3E-7599-4761-A1A2-71DAEA991474` |
| **App Group** | `group.com.DoubleShy0N.Universe-Keyboard` |
| **Diagnostics root** | `…/AppGroup/0469C0D3-0C89-4988-BD85-314F03EC34B3/Diagnostics` |
| **Executor** | Grok Bot iOS开发大师 |
| **Human input** | One-key smoke then rapid visible-key taps (no phrase / typeText / clipboard / candidate select) |

## Verdict for this Run

| Phase | Result |
|---|---|
| **Arm** | Pass — App Group **container** prefs `logging_enabled=true`; high-fidelity expiration refreshed for this Run before capture |
| **One-key smoke** | **Pass** — independent Keyboard Extension JSONL grew; fresh `touch.terminal` product events bound |
| **Conditional rapid trace** | **Ran** — ordered `touch.terminal` timeline with `monotonicNanoseconds` recorded |
| **&lt;180 ms cadence bar** | **Not met / inconclusive for that bar** — inter-key start gaps include values ≥180 ms (see below). Measured timestamps are authoritative; no global less-than-180-ms product claim |

Overall: **bounded capture evidence suitable for independent review** — not an INT-003 Product Gate, not parent Close, not Release.

This Run **supersedes** the JSONL-absent inconclusive Capture-001 for the journal-availability lesson, but does **not** reuse Capture-001’s Authorization.

## Arm binding (lesson applied)

| Check | Result |
|---|---|
| Prefer App Group container prefs over host-only `defaults` | Applied |
| `logging_enabled` | `true` on container suite |
| High-fidelity window | Refreshed on container prefs immediately before this Run (prior UI-arm window had expired) |
| Dynamic JSONL search | Used (`keyboard_extension-<uuid>-<hour>-<part>.jsonl`); not fixed `keyboard_extension.jsonl` only |

## Smoke phase

Baseline before smoke (prior UI-arm segment):

`v1/g1/open/keyboard_extension-D1E2DBB9-F098-4EEA-8964-3D30576D51DB-20260922T14-0.jsonl` — 11 lines / 6491 bytes / SHA-256 `4ec1ff7a730f0aa8de1c68ab169275fc900350b262e24c45c6ef10c28a9bb123`

After Human smoke attestation, same file grew to **18 lines / 9847 bytes** / SHA-256 `f614cec7e4c6ffaaba86ce2284eb78978761fc9ccb87271e9307ba02d80aaa8b`.

New events (content-free), processInstanceID `D1E2DBB9-F098-4EEA-8964-3D30576D51DB`, appearance `5ED53E43-A3D5-40FE-A0B3-4BC6B40700AC`:

| seq | code | utcTimestamp | monotonicNanoseconds |
|---|---|---|---|
| 12 | touch.terminal | 2026-09-22T14:36:14Z | 475854934100583 |
| 13 | touch.terminal | 2026-09-22T14:36:14Z | 475855205566500 |
| 14 | rime.owner.published | 2026-09-22T14:36:14Z | 475855341926083 |
| 15 | ui.applied | 2026-09-22T14:36:14Z | 475855342402416 |
| 16 | candidate.visibility_changed | 2026-09-22T14:36:14Z | 475855388409500 |
| 17 | touch.terminal | 2026-09-22T14:36:14Z | 475855459492916 |
| 18 | touch.terminal | 2026-09-22T14:36:14Z | 475855517873416 |

Smoke criterion (`touch.terminal` in independent journal) **satisfied**. Pair-like double `touch.terminal` per keystroke is observed and recorded without reinterpretation as failure.

## Rapid phase

Growth after post-smoke baseline occurred on a **different** Extension processInstanceID (keyboard process churn between smoke and rapid is recorded, not hidden):

`v1/g1/open/keyboard_extension-92E7E0EA-DF4B-4FA5-96CA-AF8877C0A65A-20260922T14-0.jsonl`

| Field | Value |
|---|---|
| Final size / lines | 20514 bytes / 39 lines |
| SHA-256 | `0746d550bd5886dde96cd55da3ef123666b28fa70a9812e05a1bfae6361bd819` |
| New events after smoke baseline | 28 lines |
| New `touch.terminal` count | 10 |
| appearanceID | `ED8A4FC0-8E1B-4C2B-A455-6B301F464534` |

### Ordered new `touch.terminal` (monotonic)

| # | seq | utc | mono_ns | gap from previous touch (ms) |
|---|---|---|---|---|
| 0 | 12 | 2026-09-22T14:37:33Z | 475934396684458 | — |
| 1 | 16 | 2026-09-22T14:37:33Z | 475934489065041 | 92.381 |
| 2 | 17 | 2026-09-22T14:37:34Z | 475935307677625 | 818.613 |
| 3 | 18 | 2026-09-22T14:37:34Z | 475935308027250 | 0.350 |
| 4 | 23 | 2026-09-22T14:37:34Z | 475935484805458 | 176.778 |
| 5 | 24 | 2026-09-22T14:37:34Z | 475935485231333 | 0.426 |
| 6 | 28 | 2026-09-22T14:37:34Z | 475935624893916 | 139.663 |
| 7 | 29 | 2026-09-22T14:37:34Z | 475935625149458 | 0.256 |
| 8 | 34 | 2026-09-22T14:37:34Z | 475935818204250 | 193.055 |
| 9 | 35 | 2026-09-22T14:37:34Z | 475935818472125 | 0.268 |

### Inter-key start gaps (even indices 0,2,4,6,8 as pair starts)

`[910.993, 177.128, 140.088, 193.310]` ms

- Gaps &lt; 180 ms: **2 / 4**
- Gaps ≥ 180 ms: **2 / 4** (including first ~911 ms)

Also present in the same rapid window (content-free codes): `rime.owner.published`, `ui.applied`, `candidate.visibility_changed` interleaved with touches — useful lifecycle ordering for Architecture/Quality, not a cadence pass.

## Other artifacts (hashes)

| Artifact | SHA-256 |
|---|---|
| `…D1E2DBB9-…jsonl` (smoke growth) | `f614cec7e4c6ffaaba86ce2284eb78978761fc9ccb87271e9307ba02d80aaa8b` |
| `…92E7E0EA-…jsonl` (rapid growth) | `0746d550bd5886dde96cd55da3ef123666b28fa70a9812e05a1bfae6361bd819` |
| `…0161B4E9-…jsonl` (appear-only; no rapid delta) | `d1a9452b4e6a7c26a9232d2707ed74b7fe42ac3bc989bcbf02a4fe409ab5025f` |
| `main_app-B57F6BB5-…jsonl` | `076c186e928b675d6a3d8b73af8062b494932bb3d191d008794f2c6cbe2287e9` |
| `v1/control.json` (`currentGeneration`: 1) | `baaa646c583ad8bb4c3d983f0069460e8afc8cbe0b3eb9212397eadc4a71fea4` |

## Non-claims

- No formal INT-003 Product pass/fail beyond this bounded Run receipt
- No global less-than-180-ms engineering or product claim
- No candidate selection / QA-001 / paired performance
- No Product / Quality / Release Gate; no parent Close
- No commit / push / merge under this AUTH
- No production code change; no `RimeRuntimeProvenance` restoration

## Checkout hygiene

Docs-only on clean tip `e1b28ae`. Home main and reval-08-docs worktrees not modified for this capture.

## Recommended next

1. Independent **Architecture** review AUTH on this evidence package.
2. Independent **Quality** review AUTH (cadence bar residual explicit).
3. Optional: docs-only commit/push of diagnostics + INT-003-002 package (ask before push).
