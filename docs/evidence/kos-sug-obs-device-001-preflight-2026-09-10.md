# Evidence: KOS-SUG-OBS-DEVICE-001 — SUG-07 preflight

## Current Status

| Field | Value |
|---|---|
| Status | Recorded |
| Assignment | [KOS-SUG-OBS-DEVICE-001](../assignments/kos-sug-obs-device-001.md) |
| Baseline | `origin/main` `0fbb3e994ee8382e6a8e37d85fc2157feb081469` |
| Grade | Executor-recorded (source audit of privacy-safe diagnostics formatter) |
| Non-claims | Not Device-attested; not Quality-reverified; not an uninstall run; not SUG-08 |

---

## SUG-07 preflight table (opt-in)

| Claim | Kind | Required content-free fields | Visible location | Readable now? | Preflight readability |
|---|---|---|---|---|---|
| After Ice→Luna or Wanxiang→Luna active-uninstall, the keyboard can show Chinese candidates for a probe syllable | `functional` | None from diagnostics. Observation is binary present/absent by operator eyes; no text is recorded | Keyboard candidate bar (during a run) | `yes` if a run were started | `readable` |
| Same uninstall operation’s `operation UUID` is visible in the privacy-safe diagnostics UI or copy/export | `trace` | `operation` / operation UUID | Main App Diagnostics list/copy via `DiagnosticsEventDisplayFormatter.line` | `no` | `unreadable` |
| Same event’s `phase` / `result` | `trace` | `phase`, `result` | same | `no` | `unreadable` |
| Same event’s monotonic `elapsed_ms` | `trace` | `elapsed_ms` | same | `no` | `unreadable` |

Mapping: `Readable now?` `no` → `unreadable` (fail-closed). No row is `not-checked`.

These values are **pre-operation readability only**. They are not E-01 device outcomes, M-04 Device-attested results, or a SUG-04 trigger.

## E-01 visibility claims

| Claim | Outcome | Evidence grade | Conflict / supersession |
|---|---|---|---|
| `DiagnosticsEventDisplayFormatter.line` includes `schemeDeliveryPayload` and `rimeSyncPayload` but does not include `runtimeRoutePayload` | `pass` | Executor-recorded | None known. Aligns with DEVICE-001 residual `RTRD-01`. |
| Therefore a privacy-safe diagnostics list/copy cannot show runtime-route UUID / phase / elapsed | `pass` | Executor-recorded | Event code `runtime_route.phase_changed` in a list does not prove those fields. |
| An uninstall operator round is **not** started for trace collection | `pass` | Executor-recorded | SUG-07 stop rule. |

## Source

`Universe Keyboard/Views/Diagnostics/DiagnosticsLogSource.swift#L385-L398`:

- Builds the visible line from timestamp, level, category, `event.code`.
- Optional details: `actionSequence`, `schemeDeliveryPayload`, `rimeSyncPayload`, generic `fields`.
- No `runtimeRoutePayload` map.

No Diagnostics detail sheet on this path renders runtime-route keys either (formatter is the list/copy surface).

## Operator instructions

**None in this slice.** Trace rows are `unreadable`; SUG-07 forbids asking the operator to uninstall to chase those fields, and forbids opening a raw diagnostics directory.

## Next independently gated slices (not authorized here)

> **S-03:** Item 1 below is historical. RTRD-01 later Closed via PR [#110](https://github.com/shchnk1103/Universe-Keyboard/pull/110). This preflight table remains a source-audit of the **pre-#110** formatter.

1. **RTRD-01** — Main App UI: show finite `runtimeRoutePayload` keys in the privacy-safe list or a tap-detail sheet. **Completed** on `main` (`4e4164f` / head `8a3f05c`).
2. Optional **on-device glance** — still not authorized. Human would confirm the post-#110 list/detail shows the allowlisted keys (one round).
3. **SUG-08** — only if UI remains insufficient and a named-file read is separately authorized.
