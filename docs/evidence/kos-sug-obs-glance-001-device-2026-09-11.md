# Evidence: KOS-SUG-OBS-GLANCE-001 — on-device key glance

## Current Status

| Field | Value |
|---|---|
| Status | Recorded |
| Assignment | [KOS-SUG-OBS-GLANCE-001](../assignments/kos-sug-obs-glance-001.md) |
| Source / install | `origin/main` `36b63c729bb5f6625e45923f1b0a03fd61c7565e`; signed Debug; `devicectl` sequence `2104` |
| Device | iPhone 13 Pro `00008110-000A08440198801E` |
| Grade | Human-attested UI observation (binary present/absent of allowlisted keys) |
| Non-claims | Not CS09-10-02 rerun; not `ni` candidate observation; not `RTRD-02` elapsed comparison; not SUG-08; not Product Gate / TestFlight / Release |

---

## Operator log

| Step | Result |
|---|---|
| Open 查看记录 (pre-install app) | `已打开诊断日志` |
| `runtime_route.phase_changed` on pre-install app | `没有这条` |
| Debug install + launch | sequence `2104`; Main App launched |
| Human uninstalls one scheme | Human-operated; Executor did not uninstall |
| Post-uninstall list/sheet | `operation=是 phase=是 result=是 schema=是 layout=是 state=是 elapsed_ms=是`；底部详情 `是` |

No UUID, elapsed number, scheme name, candidate text, or screenshot was recorded.

## E-01 claims (device glance)

| Claim | Outcome | Evidence grade | Conflict / supersession |
|---|---|---|---|
| After Human uninstall of one scheme on this Debug, a `runtime_route.phase_changed` line shows the seven allowlisted keys | `pass` | Human-attested | Does not rewrite the 2026-09-09 DEVICE-001 record |
| Tapping that line opens a bottom sheet with the same allowlist | `pass` | Human-attested | Same |
| SUG-08 raw-file read was not used | `pass` | Executor-recorded | Keys were read from the privacy-safe UI |

## Result

RTRD-01 privacy-safe list/copy and tap sheet **showed** `operation`, `phase`, `result`, `schema`, `layout`, `state`, `elapsed_ms` on this installed Debug.

This does **not** close [`SCHEME-DELIVERY-RUNTIME-ROUTE-DEVICE-001`](../assignments/scheme-delivery-runtime-route-device-001.md), does not obtain an ordinary-Luna vs fallback `elapsed_ms` comparison (`RTRD-02`), and does not authorize Product Gate.
