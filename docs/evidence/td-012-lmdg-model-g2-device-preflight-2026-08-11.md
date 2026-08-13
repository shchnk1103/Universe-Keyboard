# TD-012-LMDG-MODEL-G2 — G2-B Device Preflight

| Field | Value |
|---|---|
| **Date / timezone** | `2026-08-11 Asia/Shanghai` |
| **Assignment** | [`TD-012-LMDG-MODEL-G2`](../assignments/td-012-lmdg-model-g2.md) |
| **Evidence grade** | `Executor-recorded` tooling preflight; no device behavior attestation yet |
| **Status** | **Superseded by completed G2-B A/B evidence** |

## Device Snapshot

| Field | Value |
|---|---|
| Device | Physical iPhone 13 Pro (`iPhone14,2`), 256-GB capacity |
| UDID | `00008110-000A08440198801E` |
| OS | iOS `27.0`, build `24A5408d` |
| Connection | Wired, connected, paired |
| Developer Mode | Enabled |
| App | `com.DoubleShy0N.Universe-Keyboard` `1.0 (1)` |
| App state | Developer App; data container reported accessible |
| Extension preflight | `devicectl ... processes --search Universe` returned no resident process |

`xctrace` reports `Activity Monitor`, `Allocations`, `Leaks`, `System Trace` and `Time Profiler` templates.
The G2-B baseline will use an all-process Activity Monitor trace starting before Universe Keyboard selection,
so a fresh Keyboard Extension PID can be identified without attaching to a stale process.

## Tool Boundary

- The device advertises file-list and transfer capabilities for `appGroupDataContainer`.
- A read-only listing of the Universe App Group returned `CoreDevice.ActionError 3`; this is a tooling failure,
  **not** evidence that the container, 万象 files or model is absent.
- No file was copied to or removed from the device during preflight.
- G2-B model placement remains blocked until the baseline is captured and the App Group transfer path is
  proven without replacing existing directories.

## Human Gate

Before starting the baseline trace, the Human Device Operator must attest only:

1. the iPhone is unlocked and remains cable-connected;
2. Universe Keyboard has Full Access;
3. the active 26-key Chinese scheme is 万象拼音;
4. a new blank Notes note is open with a non-Universe keyboard selected initially.

No sentence content is frozen in this document. The operator will type a disposable, non-sensitive long
pinyin sequence supplied at run time, observe candidates, then delete the draft without saving or sending it.

Execution result: [`td-012-lmdg-model-g2-device-ab-2026-08-11.md`](td-012-lmdg-model-g2-device-ab-2026-08-11.md).
