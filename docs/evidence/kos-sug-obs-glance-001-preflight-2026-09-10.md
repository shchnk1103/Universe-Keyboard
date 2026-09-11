# Evidence: KOS-SUG-OBS-GLANCE-001 — SUG-07 preflight

## Current Status

| Field | Value |
|---|---|
| Status | Recorded |
| Assignment | [KOS-SUG-OBS-GLANCE-001](../assignments/kos-sug-obs-glance-001.md) |
| Baseline | `origin/main` `36b63c729bb5f6625e45923f1b0a03fd61c7565e` (contains RTRD-01 UI `8a3f05c`) |
| Grade | Executor-recorded (source audit of post-#110 privacy-safe diagnostics formatter) |
| Non-claims | Not Device-attested; not the glance result; not an uninstall run; not SUG-08 |

---

## SUG-07 preflight table (opt-in)

| Claim | Kind | Required content-free fields | Visible location | Readable now? | Preflight readability |
|---|---|---|---|---|---|
| A `runtime_route.phase_changed` list/copy line can show `operation` UUID | `trace` | `operation` | Main App 设置 → 诊断 → 查看记录, via `DiagnosticsEventDisplayFormatter.line` | `yes` | `readable` |
| Same line can show `phase` and `result` | `trace` | `phase`, `result` | same | `yes` | `readable` |
| Same line can show monotonic `elapsed_ms` | `trace` | `elapsed_ms` | same | `yes` | `readable` |
| Tap sheet can show the same allowlist | `trace` | `operation`, `phase`, `result`, `schema`, `layout`, `state`, `elapsed_ms` | bottom sheet `DiagnosticsRuntimeRouteDetailSheet` | `yes` | `readable` |

Mapping: `Readable now?` `yes` → `readable`. No row is `not-checked`. No functional uninstall claim is adopted in this glance.

These values are **pre-operation readability only** from the #110 source on `main`. They are not E-01 device outcomes, M-04 Device-attested results, or a SUG-04 trigger.

## E-01 visibility claims

| Claim | Outcome | Evidence grade | Conflict / supersession |
|---|---|---|---|
| `DiagnosticsEventDisplayFormatter.line` appends `runtimeRouteDescription` when `runtimeRoutePayload` is present | `pass` | Executor-recorded | Supersedes the pre-#110 source-audit on [KOS-SUG-OBS-DEVICE-001 preflight](kos-sug-obs-device-001-preflight-2026-09-10.md) for **formatter source only** |
| `runtimeRouteDetailItems` parses only the allowlisted keys from lines that contain `runtime_route.phase_changed` | `pass` | Executor-recorded | Non-route lines stay plain `Text` |
| An uninstall operator round is **not** started | `pass` | Executor-recorded | First glance used existing logs only. Human later authorized a separate uninstall; see [device glance](kos-sug-obs-glance-001-device-2026-09-11.md) |

## Source

`Universe Keyboard/Views/Diagnostics/DiagnosticsLogSource.swift#L394` and `#L459-L491`:

- `line` maps `runtimeRoutePayload` through `runtimeRouteDescription`.
- Description emits `operation`, `phase`, `result`, `schema`, `layout`, `state`, `elapsed_ms`.
- `runtimeRouteDetailItems` allowlist is those seven keys; requires the event code in the line.

`Universe Keyboard/Views/Diagnostics/DiagnosticsLogContentView.swift`: a matching line is a button that presents `DiagnosticsRuntimeRouteDetailSheet`.

## Operator log

| Step | Result | Notes |
|---|---|---|
| 1. Open 设置 → 诊断 → 查看记录 | `已打开诊断日志` | Currently installed Main App. Reinstall **not** started. |
| 2. Look for `runtime_route.phase_changed` | `没有这条` | On the previously installed app. |
| 3. Debug install | `BUILD SUCCEEDED` + `devicectl install` sequence `2104` | Source `36b63c7`; device `00008110-000A08440198801E`. Executor launched Main App only. |

Post-install Human uninstall observation is recorded in [`kos-sug-obs-glance-001-device-2026-09-11.md`](kos-sug-obs-glance-001-device-2026-09-11.md). This preflight file stays the **pre-operation** source-audit.
