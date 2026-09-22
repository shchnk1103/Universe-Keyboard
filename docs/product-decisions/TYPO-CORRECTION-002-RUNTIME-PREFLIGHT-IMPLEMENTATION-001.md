# Product Decision: TYPO-CORRECTION-002 runtime-preflight implementation

> **Decision ID:** `PD-TYPO-CORRECTION-002-RUNTIME-PREFLIGHT-IMPLEMENTATION-001`
>
> **Decision:** `Accepted — bounded pure-Core preflight implementation`
>
> **Date:** `2026-09-21 Asia/Shanghai`

## Decision

Product accepts a narrowly scoped implementation-preflight to turn AR-01 through
AR-04 into testable **pure Core contracts**. It may select and test a
deterministic structural selector and provisional preflight caps, model
operation/group/fence decisions, and document the residuals that remain before
controller wiring.

The decision intentionally does **not** authorize production runtime behavior.
In particular, a provisional preflight cap is not an approval to change
production `12/8`, query real RIME, or claim that rank `55` is reachable under
the future runtime schedule.

## Authorized boundary

The matching Assignment may modify only:

- `Packages/KeyboardCore/Sources/KeyboardCore/ContextualTypoCorrection.swift`;
- `Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallPreflight.swift`;
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionRecallPreflightTests.swift`; and
- the Assignment/Authorization/evidence/review records owned by this slice.

It must preserve existing production controller behavior, the live/sidecar
session boundary, privacy boundary, and display-only correction policy. It may
not modify `Keyboard/`, `Packages/RimeBridge`, schema/vendor artifacts,
candidate UI, host-text paths or diagnostic retention.

## Required conditions

1. The selector must be deterministic, substitution-only, structurally
   explainable and separately bounded from generated hypotheses and sidecar
   query attempts.
2. Any cap chosen by this slice is explicitly `preflight-only`; tests must not
   imply a selected production cap or a real-RIME query schedule.
3. Operation/group contracts must ensure a stale or cancelled result is not
   accepted for accounting or publication; production async delivery remains a
   later integration requirement.
4. Opaque GroupID mapping must be operation-scoped and never require routine
   logging/persistence of corrected pinyin or candidate content.
5. The changed exact snapshot requires independent Architecture and Quality
   review before any later controller/RIME request.

## Explicit non-claims

This decision does not authorize controller or runtime wiring, RimeBridge,
real-RIME queries, Simulator/device capture, QA-001, INT-003, paired
performance, `180 ms`, publication, commit/push/PR/merge, any Gate or parent
close.
