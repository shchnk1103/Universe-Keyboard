# Evidence: SCHEME-DELIVERY-RUNTIME-ROUTE-ELAPSED-001 — SUG-07 preflight

## Current Status

| Field | Value |
|---|---|
| Status | Recorded |
| Assignment | [SCHEME-DELIVERY-RUNTIME-ROUTE-ELAPSED-001](../assignments/scheme-delivery-runtime-route-elapsed-001.md) |
| Baseline | `origin/main` `36b63c7` + glance observation 2026-09-11 |
| Grade | Executor-recorded (source audit) |
| Non-claims | Not a performance result; not Device-attested elapsed numbers; not SUG-08 |

---

## SUG-07 preflight table (opt-in)

| Claim | Kind | Required content-free fields | Visible location | Readable now? | Preflight readability |
|---|---|---|---|---|---|
| Fallback Luna path exposes `elapsed_ms` on `runtime_route.phase_changed` | `trace` | `elapsed_ms` | Main App 设置 → 诊断 → 查看记录 (list/sheet) | `yes` (glance 2026-09-11) | `readable` |
| Ordinary Luna deploy exposes the **same** field on the **same** event code | `trace` | `elapsed_ms` on `runtime_route.phase_changed` | same | `no` | `unreadable` |
| The two values share one definition (isolated deploy duration) | `trace` | same elapsed origin | n/a | `no` | `unreadable` |

Mapping: `no` → `unreadable`. No row is `not-checked`.

`runtime_route.elapsed_ms` is monotonic time since the owning **uninstall** began (`DiagnosticEvent.RuntimeRoutePhaseEvent`). `recordActiveUninstallRoutePhase` is only called from `performSchemaUninstall`. Ordinary `activateSchema` / Luna deploy does not write this event.

Scheme-delivery list lines do not emit `elapsed_ms`. Mixing those codes with runtime-route elapsed is forbidden by this Assignment.

SUG-07: do **not** send an operator uninstall/deploy round to chase the ordinary-Luna arm.

## E-01 visibility claims

| Claim | Outcome | Evidence grade | Conflict / supersession |
|---|---|---|---|
| Uninstall-path `elapsed_ms` is shown in the post-#110 UI | `pass` | Human-attested glance + source | [glance device](kos-sug-obs-glance-001-device-2026-09-11.md) |
| Ordinary Luna deploy does not produce `runtime_route.phase_changed` | `pass` | Executor-recorded source | Call sites only in `performSchemaUninstall` |
| Therefore a same-field ordinary vs fallback pair is not readable now | `pass` | Executor-recorded | Fail-closed; not a performance conclusion |

## Operator instructions

**None in this slice.**

## Next independently gated slices

> **S-03:** Item 1 is completed. Human accepted the gap `2026-09-11`. DEVICE-001 residual `RTRD-02` is `accept`.

1. Human accepts `RTRD-02` as unreadable same-field comparison — **Completed** (`accept`).
2. New Assignment to emit ordinary Luna deploy elapsed in the privacy-safe UI (Swift) — still not authorized.
3. SUG-08 remains unauthorized.
