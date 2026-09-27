# Evidence: RIME-SYNC-001 supplemental natural background success — 2026-09-23

## Current Status

| Field | Value |
|---|---|
| Status | Supplemental device observation recorded; not a new frozen formal run |
| Assignment | [`RIME-SYNC-001`](../assignments/rime-sync-001.md) |
| Evidence grade | `Device-attested` |
| Observation date | `2026-09-23 Asia/Shanghai` |
| Source | Human-supplied content-free Diagnostics/v1 log excerpt and Notification Center screenshot |

This is the second consecutive natural-background success observation after the
2026-09-22 record. It supplements, but does not rewrite, the formal `Run 02`
result in
[`rime-background-sync-natural-device-run-2026-09-01-r2.md`](rime-background-sync-natural-device-run-2026-09-01-r2.md).

## Device and provenance boundary

| Boundary | Observation |
|---|---|
| Device context | Operator-reported iPhone 13 Pro (`iPhone14,2`), iOS `27.0` |
| Build/source identity | `UNKNOWN` for this supplemental observation; no exact build number or source digest was supplied |
| Execution mode | Natural `background_automatic`; no manual sync or Debug background-task trigger is claimed |
| Screenshot | Human-supplied Notification Center screenshot; not copied into the repository; SHA-256 `e16ed1bc0833a70e6d657e2d9a7d1c7b9052e477d52cae6df9fafd1d56e0515f` |

The device and OS context is carried from the operator's supplied test context,
not re-read from a new device receipt in this record. The isolated branch's
uncommitted source changes are not treated as the installed payload identity.

## Observed operation

The supplied content-free log excerpt contains one completed background
operation and one competing foreground attempt. In chronological order:

```text
[01:00:47.000] [INFO] [CONFIG] rime_sync.invoked operation=c5605d67-be69-4619-b8ba-95597a6f145b source=background_automatic phases=standard_rime_data,private_settings
[01:00:47.000] [INFO] [CONFIG] rime_sync.phase_changed operation=c5605d67-be69-4619-b8ba-95597a6f145b source=background_automatic phase=standard_rime_data result=started
[01:00:47.000] [INFO] [CONFIG] rime_sync.invoked operation=e8fcc7aa-ace7-4b61-97c1-d5da584865d2 source=foreground_automatic phases=private_settings
[01:00:47.000] [INFO] [CONFIG] rime_sync.skipped operation=e8fcc7aa-ace7-4b61-97c1-d5da584865d2 source=foreground_automatic reason=process_busy
[01:01:15.000] [INFO] [CONFIG] rime_sync.phase_changed operation=c5605d67-be69-4619-b8ba-95597a6f145b source=background_automatic phase=standard_rime_data result=completed
[01:01:15.000] [INFO] [CONFIG] rime_sync.phase_changed operation=c5605d67-be69-4619-b8ba-95597a6f145b source=background_automatic phase=private_settings result=started
[01:01:15.000] [INFO] [CONFIG] rime_sync.phase_changed operation=c5605d67-be69-4619-b8ba-95597a6f145b source=background_automatic phase=private_settings result=completed
[01:01:15.000] [INFO] [CONFIG] rime_sync.terminal operation=c5605d67-be69-4619-b8ba-95597a6f145b source=background_automatic result=completed
```

| Result | Evidence grade | Interpretation |
|---|---|---|
| Background operation completed both requested phases and published one completed terminal | `Device-attested` | The supplied log supports a coherent successful natural-background operation |
| Competing foreground operation was skipped with `reason=process_busy` | `Device-attested` | The process-ownership gate prevented a duplicate transaction; the skipped operation has no phase start or terminal |
| Notification Center showed start at `01:00` and completion at `01:01` | `Device-attested` | The user-facing notification agrees with the completed background operation: RIME common words, standard data and Universe App settings were updated |

## Engineering conclusion

Together with the 2026-09-22 observation, this is sufficient supplemental
evidence to finish active engineering observation of the automatic-sync path.
No third success run is required. The evidence supports the narrower claim that
the path can complete naturally and that foreground/background contention is
handled by a process-busy skip.

It does not establish a deterministic schedule, real-time execution, universal
device coverage or a new formal acceptance run. The earlier expired operation on
`2026-09-20` and formal `Run 02` `INVALID` disposition remain historical
evidence.

## Non-claims and revalidation trigger

- Not a new frozen formal run and not a replacement for the formal manifest.
- Not `Quality-reverified`, Product Gate, merge-ready, TestFlight-ready or Release evidence.
- Does not close `TD-002`, `TD-013` or `TD-017`, and does not claim the broader portable-sync Assignment is complete.
- No code change, reinstall, setting change, manual sync or background-task simulation was performed for this record.
- Reopen a new pre-frozen device round only if the failure recurs or the sync path materially changes.
