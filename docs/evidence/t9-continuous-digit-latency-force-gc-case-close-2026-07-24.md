# T9 continuous digit latency — force_gc track case close

| Field | Value |
|---|---|
| Status | **Closed (not primary cause)** |
| Date | 2026-07-24 |
| Scope | Chinese nine-key continuous digits without Path/candidate selection |
| Product impact on 26-key | None intended (T9-only schema hygiene) |

## Symptom

Long unconfirmed nine-key digit runs feel increasingly janky. Debug logs show many `SLOW KEY` / `SLOW T9SEG` lines as composition length grows.

## Investigation tools retained

These remain product-useful even though the force_gc hypothesis is closed:

| Asset | Role |
|---|---|
| `T9SEG` + `HotPathSegmentTiming` | Per-digit split: `rime` / `pathLocal` / `preedit` / `pathUI` / `candUI` |
| `processKey=(api X, collect Y)` | Split librime `process_key` vs `collectOutput` |
| Bar prefetch idle gate | Fewer mid-burst `loadMoreCandidates` (12→27→42) |
| Diagnostics: **检查九键 Schema / force_gc** | In-process App Group check (Device Hub often hides `Rime/`) |
| Deploy: strip T9 force_gc **before** compile; invalidate `build/t9.*` | Avoid “source clean / compiled dirty” |

How to re-run measurement: `docs/DEBUGGING.md` → *T9 continuous digit typing — DEBUG segment timing*.

## Evidence summary (device, Debug keyboard)

- **Hot path structure:** each digit runs main-thread `processKey` + local Path rebuild + Path/candidate UI sync; no Path-side multi-RIME probe on ordinary digits (ADR 0023).
- **Segment dominance on SLOW keys:** almost entirely `rime` → bridge `processKey` → **`api` (librime `process_key`)**; `collect` ≈ 0.1ms.
- **UI / Path local:** not the spike source (`pathLocal` / `pathUI` / `candUI` stay small on SLOW lines).
- **Spike shape:** occasional 150–350ms keys, neighbors often 3–15ms; severity tends to grow with `rawLen`.
- **force_gc hypothesis:** upstream `t9` / ice list `lua_translator@*force_gc` (`collectgarbage("step")` every translation — librime-lua#307 memory workaround).
- **After T9-only strip + deploy hygiene:** main-app diagnostic reported **source + compiled `build/t9.schema.yaml` both free of force_gc list entries**, yet **many SLOW KEY remain**.

## Decision

| Decision | Detail |
|---|---|
| force_gc as **primary** latency fix | **Rejected / closed** — not sufficient; not primary |
| T9-only strip of force_gc list entry | **Keep as hygiene** — does not modify `rime_ice` or shared `lua/force_gc.lua` |
| Full revert of 2026-07-24 latency tooling | **Rejected** — T9SEG, api/collect split, prefetch idle, schema diagnostic still needed |
| Next primary track | **Long unconfirmed T9 composition `process_key` / `script_translator` cost** — see plan below |

## What was *not* proven

- Exact librime internal call stack on spike keys (needs Instruments / engine tracing).
- Numeric product budgets (still forbidden without reviewed Release-like baselines — `PERFORMANCE_BASELINE.md`).
- Whether 26-key full pinyin shows the same spike curve (out of scope for this close).

## Related documents

- Measurement procedure: [`DEBUGGING.md`](../DEBUGGING.md) (T9SEG + force_gc verify)
- Performance rules: [`PERFORMANCE_BASELINE.md`](../PERFORMANCE_BASELINE.md)
- Follow-on plan: [`plans/t9-long-composition-process-key-latency-plan.md`](../plans/t9-long-composition-process-key-latency-plan.md)
- T9 deploy compatibility: `T9SchemaCompatibility` / `T9DeploymentSupport` / diagnostics runner in main App

## Archive note

Do not reopen “strip force_gc again” as the main latency remedy without new evidence that **compiled** T9 still registers force_gc or that `api` spikes disappear when GC is proven present and vanish when absent on the same device build.
