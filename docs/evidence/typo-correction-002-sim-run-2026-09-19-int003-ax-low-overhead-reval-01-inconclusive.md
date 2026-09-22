# TYPO-CORRECTION-002 Simulator Run Receipt — INT-003 low-overhead AX attempt 01

> **Run ID:** `TC2-SIM-20260919-184155-INT003-AX-LOW-OVERHEAD-REVAL-01`
>
> **Status:** `inconclusive — current keyboard identity was not proven; external AX actions reached system Simplified Pinyin`
>
> **Authorization:** [`AUTH-TYPO-CORRECTION-002-INT003-AX-LOW-OVERHEAD-REVALIDATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-AX-LOW-OVERHEAD-REVALIDATION-001.md)
>
> **Assignment:** [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md)

## Decision boundary

This receipt preserves the attempted external batch as an evidence-grade
inconclusive run. It is not INT-003 evidence, QA-001 evidence, sidecar
observability evidence, paired-performance evidence, or a Product/Quality/
Release decision.

The run is invalid for the intended lane because the precondition “Universe
Keyboard is the current keyboard” was not established before sending the
batch. The later switcher snapshot exposed `下一个键盘 | Universe Keyboard`;
that means the current keyboard was system Simplified Pinyin and Universe
Keyboard was next. The `wimenjintianquhongyuan` sequence visible during the
attempt therefore came from the system keyboard, not from Universe Keyboard.

## Execution boundary

| Field | Value |
|---|---|
| Simulator | iPhone 17 Pro Max / iOS 27.0 |
| UDID | `06C5BC3E-7599-4761-A1A2-71DAEA991474` |
| Host | Messages, conversation `+1 (888) 555-1212` |
| Intended input path | External AX `batch` taps, no `typeText`, pasteboard, `documentContext` or `setMarkedText` |
| Actions attempted | Delete preparation followed by a 22-step synthetic key batch |
| Identity failure | Current keyboard was not proven; `Universe Keyboard` appeared as the next-keyboard label on the system Pinyin surface |
| Product diagnostics | No new diagnostic journal was produced by this attempt |

The AX element refs used for the batch were obtained from the system Pinyin
surface. They are not valid Universe Keyboard refs and must not be reused.

## Artifact boundary

The copied raw directory for this attempt is retained outside Git for audit
purposes, but it is explicitly non-evidence:

`/private/tmp/typo-correction-002-sim-runs/TC2-SIM-20260919-184155-INT003-AX-LOW-OVERHEAD-REVAL-01/raw/`

Its three JSON artifacts are byte-identical copies of the retry-03 artifacts;
their hashes do not represent a new runtime capture:

| File | SHA-256 | Disposition |
|---|---|---|
| `keyboard_extension.jsonl` | `d57b6bbd4dec610860a96195a3174f798f80a584c6e4e15fa2c375930c414f11` | duplicate of retry 03; non-evidence |
| `main_app.jsonl` | `4d827a30554a3daeb01a81e0e6d30f32b9a57ccc42538c0724f660f3646dfe14` | duplicate of retry 03; non-evidence |
| `rime-runtime-provenance.json` | `b6c9a74a747b35997cc4dc67c651443b7dfd610f50fd290f9076760de7865c54` | duplicate of retry 03; non-evidence |

The previously valid retry-03 receipt remains bound only to
`TC2-SIM-20260919-181538-INT003-AX-REVAL-03`; this attempted batch does not
extend or amend it.

## Non-claims and next boundary

- No candidate visibility, candidate selection, stale-work cancellation,
  sidecar route, latency, QA-001 or paired-performance claim is made.
- No Gate is closed. No code, schema, build, install, commit, push, PR, merge,
  TestFlight or Release action occurred because of this receipt.
- A valid retry needs a new Authorization and Run ID, a fresh current-keyboard
  identity assertion, and a touch-capable harness that can address
  Universe-owned key controls. The phrase “next keyboard | Universe Keyboard”
  alone must be treated as proof of the opposite current state.
