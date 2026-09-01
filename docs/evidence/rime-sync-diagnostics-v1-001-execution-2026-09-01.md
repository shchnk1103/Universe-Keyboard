# RIME-SYNC-DIAGNOSTICS-V1-001 — Execution Evidence

## Scope and claim boundary

This evidence covers only the typed Diagnostics/v1 protocol and its automatic
RIME sync producer wiring. It does not recover the old natural run's legacy
message, prove physical-device scheduling or success, or authorize Product
Gate, merge, TestFlight or Release.

Reviewed implementation commit: `d07b607` (`feat: add typed rime sync diagnostics`).

## Implementation receipt

- `DiagnosticEvent` schema version 3 defines finite `rime_sync` invocation,
  phase, skip and terminal payloads; arbitrary context strings are rejected.
- `DiagnosticsJournalRuntime.recordRimeSync` writes CONFIG-category v1 events.
- Foreground and background automatic sync share an opaque operation ID and a
  process-local terminal arbiter. Expiration can claim the sole terminal before
  asynchronous cancellation completes.
- Error mapping stores only a finite failure class. Paths, bookmark data,
  filenames, raw errors, NSError domain/text, synchronized content, dictionary
  data and input text are outside the payload.
- Journal normalization preserves `rimeSyncPayload`; a real temporary-root
  Runtime → Ingress → Writer → Reader test guards this persistence seam.
- Diagnostics remain non-blocking ingress and do not determine sync result,
  notification delivery, gate ownership or BGTask completion.

## Automated evidence

| Gate | Result |
|---|---|
| `swift-format lint --strict` on all changed Swift files | Pass |
| `git diff --check` | Pass |
| RIME vendor structural verification | 12 artifacts verified |
| Focused scheduler/session/viewer diagnostics tests | 7 passed, 0 failed |
| KeyboardCore | 1071 passed, 0 failed |
| RimeBridgeTests | 48 passed, 0 failed, 20 skipped |
| App + Keyboard tests | 278 passed, 0 failed, 3 skipped |
| Strict Swift 6 Debug simulator build | Pass |
| Strict Swift 6 Release simulator build | Pass |

The App and RimeBridge gates used the available iPhone 16 Pro iOS 18.0
Simulator (`E30F30AB-3422-49C8-B2F3-E5377047EAF4`) because the CI-named device
was not the applicable local runtime. Each Xcode gate used isolated DerivedData.

Result bundles for this local run:

- Focused: `/private/tmp/universe-rime-sync-diagnostics-focused-r2/Logs/Test/Test-Universe Keyboard-2026.09.01_18-19-53-+0800.xcresult`
- RimeBridge: `/private/tmp/universe-rime-sync-diagnostics-rimebridge-r2/Logs/Test/Test-RimeBridgeTests-2026.09.01_18-21-29-+0800.xcresult`
- App + Keyboard: `/private/tmp/universe-rime-sync-diagnostics-app-r2/Logs/Test/Test-Universe Keyboard-2026.09.01_18-22-12-+0800.xcresult`

The first independent Architecture pass found that journal normalization did
not copy `rimeSyncPayload`, which would have triggered a precondition on the
first write. It also found that expiration was not linearized with BGTask
completion. The final diff copies the payload, tests the real journal round
trip, records expiration after the lifecycle claim but before cancellation,
defers normal terminal persistence until the operation lifecycle claim, and
rejects unrequested or out-of-order phases. Final independent re-reviews were
performed against commit `d07b607`; the original findings are retained as
evidence rather than erased.

## Independent review disposition

- Architecture: [`Pass with conditions`](../assignments/rime-sync-diagnostics-v1-001-architecture-review.md). P0 writer preservation and P1 lifecycle linearization are closed. The remaining P2 condition applies if phases become dynamic or new phases are added.
- Quality: [`Pass`](../assignments/rime-sync-diagnostics-v1-001-quality-review.md). Runtime persistence, viewer formatting, scheduler ordering and final gate receipts were independently checked.

## Explicit residuals

- A new signed physical-device build has not been frozen or run.
- The old installed build's exact RIME error remains `UNKNOWN`; v1 events are
  prospective and do not migrate or reconstruct legacy logs.
- Broader legacy producer migration and diagnostics query lifecycle remain
  tracked by TD-013.
- Product Review and any newly frozen signed physical-device run remain pending.
