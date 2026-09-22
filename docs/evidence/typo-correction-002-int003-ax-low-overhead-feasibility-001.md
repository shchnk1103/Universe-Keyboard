# INT-003 low-overhead AX feasibility record

## Scope

- Authorization: [`AUTH-TYPO-CORRECTION-002-INT003-AX-LOW-OVERHEAD-FEASIBILITY-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-AX-LOW-OVERHEAD-FEASIBILITY-001.md)
- Predecessor receipt: [`INT-003 AX retry 03`](typo-correction-002-sim-run-2026-09-19-int003-ax-reval-03-inconclusive.md)
- Mode: read-only source and automation-contract analysis; no simulator event,
  build, install or new runtime evidence was produced

## First-principles finding

The product already exposes independent AX key controls and the current retry
proved that `XCUIElement.tap()` reaches those controls. The failure was in the
event producer's overhead, not in AX publication or the product's UIKit action
path: the requested 80 ms sleep was followed by observed 526.6–880.8 ms key
intervals.

## Candidate comparison

| Candidate | Feasibility | Boundary |
|---|---|---|
| `XCUIElement.tap()` loop | Rejected for INT-003 cadence | Proven reachability, but observed intervals are too slow |
| Coordinate-level XCTest tap/press | Inconclusive in the first authorized run | The selected test completed, but the fresh keyboard-extension journal contained no product key event; no timing claim is possible |
| External XcodeBuildMCP `batch` with fresh AX refs | Attempted, invalid for evidence | One same-screen batch could avoid per-call external round trips, but the recorded attempt used the system Simplified Pinyin surface after current-keyboard identity was misread; its refs and artifacts are not reusable |
| Host `typeText`, pasteboard, `documentContext`, `setMarkedText` | Prohibited | Not a keyboard touch event and violates the evidence boundary |
| Fake provider, old Ice directory or synthetic RIME fixture | Prohibited | Does not test the deployed production path |

## External-batch boundary

Use a fresh `snapshot_ui` after Messages is ready and Universe Keyboard is
visibly selected. Resolve the exact current AX refs by both role and label or
identifier; do not reuse refs from a previous snapshot. Verify the product
identity and all required key refs before issuing one `batch` sequence with
real key taps and the requested short `postDelay` values. Preserve the raw
diagnostics and compute actual adjacent key-event intervals from the journal.

This method was attempted under a separate Authorization and is retained only
as an invalid/inconclusive record. It does not establish an INT-003 stimulus
cadence. If a future external-batch experiment is authorized, the snapshot
must prove the current Universe Keyboard identity and all refs must come from
that same fresh snapshot; otherwise stop without claiming INT-003.

## Authorization boundary

The feasibility analysis recommends, but does not itself authorize, the
external-batch runtime experiment. That experiment must use a new bounded
Authorization and a new Run ID. It must bind the exact installed package and
RIME provenance, forbid host-text injection and synthetic fixtures, and retain
the same non-claims for stale-work cancellation, QA-001 and paired performance.

## Harness boundary — two different automation surfaces

The project now has two distinct ways to drive the keyboard. They must not be
described as one interchangeable “AI keyboard harness”.

| Surface | How it finds keys | How it sends input | What it proves | Current boundary |
|---|---|---|---|---|
| **XCTest-internal harness** | `XCUIApplication` queries inside `NativeExperienceKeyboardAutomationFeasibilityTests`, including `activateUniverseKeyboard()` and product-owned key labels/identifiers | `XCUIElement.tap()` from the XCTest runner, reaching the existing UIKit action path | Universe-specific controls can be discovered and tapped; retry 03 observed 22 product key events and retained the real sidecar diagnostics | Valid reachability, but measured adjacent intervals were `526.6–880.8 ms`; it does not meet the INT-003 `<180 ms` stimulus condition |
| **XcodeBuildMCP external batch** | `snapshot_ui` element refs such as `e120`, valid only for the latest external runtime snapshot | One external `batch` of AX taps | Potentially avoids one MCP round trip per external action | The external snapshot currently exposes Messages and the switcher but not the Universe extension's letter-key refs; the last attempt used system Simplified Pinyin refs and is explicitly invalid |

The merged AX work makes the product keys reachable to the XCTest query path;
it does not guarantee that a separate cross-process MCP snapshot will publish
the same extension-owned key tree. In particular, a switcher label of
`下一个键盘 | Universe Keyboard` means that Universe Keyboard is the *next*
keyboard, not the current one.

## XCTest speed-up assessment

The existing XCTest harness may be able to produce a faster stimulus, but this
is unproven and must be measured from the product diagnostics rather than the
requested sleep interval. The current loop already resolves and stores the
keys before the burst; removing those queries alone is therefore unlikely to
explain the `526.6–880.8 ms` intervals. The likely cost is the per-action
XCTest/automation synchronization around each `XCUIElement.tap()` call and the
keyboard-extension process boundary.

The safest experiment was a **test-only coordinate harness**:

1. Keep the existing exact Universe activation and AX key discovery.
2. Resolve each product key once and derive its center `XCUICoordinate` before
   the burst.
3. Send coordinate-level `tap()` or a very short coordinate `press` in the
   same XCTest runner loop.
4. Keep the existing content-free diagnostic timestamps as the authority.

This remains a real touch path and does not use `typeText`, pasteboard,
`documentContext`, `setMarkedText`, host injection or a fake RIME provider. It
also does not promise success: public XCTest has no general “enqueue this whole
keyboard burst as hardware touches” API. If coordinate dispatch still misses
`<180 ms`, INT-003 remains inconclusive rather than justifying a production
hot-path change.

## Coordinate experiment result — 2026-09-19

The separately authorized test-only coordinate experiment used Run ID
`TC2-SIM-20260919-190945-INT003-AX-COORDINATE-FEAS-01`. The selected XCTest
method passed and completed exact Universe activation, product-owned AX key
discovery, and one-time key-center coordinate derivation. It then executed the
coordinate actions without host-text injection.

The result remains **inconclusive**: the fresh keyboard-extension artifact
contained one `presentation.appeared` event and zero `touch.terminal` or
`key_highlighted` events. XCTest's own action log is not sufficient to prove
delivery into the product input path. Therefore no coordinate tap, key event,
adjacent interval, or `<180 ms` stimulus is claimed.

The coordinate Authorization is consumed and cannot be reused. Any follow-up
variant needs a new Authorization and Run ID, and must first make one single
diagnostic key event observable before attempting a multi-key cadence capture.
