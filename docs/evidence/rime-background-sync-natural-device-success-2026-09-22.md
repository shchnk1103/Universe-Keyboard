# Evidence: RIME-SYNC-001 supplemental natural background success — 2026-09-22

## Current Status

| Field | Value |
|---|---|
| Status | Supplemental device observation recorded; not a new frozen formal run |
| Assignment | [`RIME-SYNC-001`](../assignments/rime-sync-001.md) |
| Evidence grade | `Device-attested` |
| Observation date | `2026-09-22 Asia/Shanghai` |
| Source | Human-supplied content-free Diagnostics/v1 log excerpt and Notification Center screenshot |

This record supplements, but does not rewrite, the formal `Run 02` result in
[`rime-background-sync-natural-device-run-2026-09-01-r2.md`](rime-background-sync-natural-device-run-2026-09-01-r2.md).
It records a later natural background opportunity observed by the Device
Operator; it does not have a new pre-frozen manifest, exact build/source digest,
installed-payload receipt or post-run crash/Jetsam receipt.

## Device and provenance boundary

| Boundary | Observation |
|---|---|
| Device context | Operator-reported iPhone 13 Pro (`iPhone14,2`), iOS `27.0` |
| Build/source identity | `UNKNOWN` for this supplemental observation; no exact build number or source digest was supplied |
| Execution mode | Natural `background_automatic`; no manual sync or Debug background-task trigger is claimed |
| Screenshot | Human-supplied Notification Center screenshot; not copied into the repository; SHA-256 `a4ef864cb006602b13ccd8297cfb5d191056850196d1c313d7cf87669f98146d` |

The device and OS context is carried from the operator's supplied test context,
not re-read from a new device receipt in this record. The branch's uncommitted
source changes are not treated as the installed payload identity.

## Observed operation

The supplied content-free log excerpt contains one operation ID and the
following ordered events:

```text
[00:22:42.000] [INFO] [CONFIG] rime_sync.invoked operation=dd2ad2ae-884e-45d7-8a50-9f80db18c595 source=background_automatic phases=standard_rime_data,private_settings
[00:22:42.000] [INFO] [CONFIG] rime_sync.phase_changed operation=dd2ad2ae-884e-45d7-8a50-9f80db18c595 source=background_automatic phase=standard_rime_data result=started
[00:23:32.000] [INFO] [CONFIG] rime_sync.phase_changed operation=dd2ad2ae-884e-45d7-8a50-9f80db18c595 source=background_automatic phase=standard_rime_data result=completed
[00:23:32.000] [INFO] [CONFIG] rime_sync.phase_changed operation=dd2ad2ae-884e-45d7-8a50-9f80db18c595 source=background_automatic phase=private_settings result=started
[00:23:33.000] [INFO] [CONFIG] rime_sync.phase_changed operation=dd2ad2ae-884e-45d7-8a50-9f80db18c595 source=background_automatic phase=private_settings result=completed
[00:23:33.000] [INFO] [CONFIG] rime_sync.terminal operation=dd2ad2ae-884e-45d7-8a50-9f80db18c595 source=background_automatic result=completed
```

| Result | Evidence grade | Interpretation |
|---|---|---|
| One natural background operation completed both requested phases and published one completed terminal | `Device-attested` | The supplied log supports a coherent successful operation for this observation |
| Notification Center showed start at about `00:22` and completion at about `00:23` | `Device-attested` | The screenshot's user-facing result agrees with the terminal event: RIME common words, standard data and Universe App settings were updated |
| `07:31:27` foreground private-settings entry was skipped with `reason=cooling_down` | `Device-attested` | A later foreground cooldown is a separate expected skip; it does not invalidate the completed background operation |

## Engineering conclusion

This is sufficient supplemental evidence that the current observed path can
complete a natural iOS background automatic-sync operation on the supplied
device context. It supports closing the automatic-sync investigation for daily
observation; it does not establish a deterministic schedule, real-time
execution, universal device coverage or a new formal acceptance run.

The earlier expired operation on `2026-09-20` and the formal `Run 02`
`INVALID` disposition remain historical evidence. This record neither removes
those findings nor recovers the old exact RIME error code.

## Non-claims and revalidation trigger

- Not a new frozen formal run and not a replacement for the formal manifest.
- Not `Quality-reverified`, Product Gate, merge-ready, TestFlight-ready or Release evidence.
- Does not close `TD-002`, `TD-013` or `TD-017`, and does not claim the broader portable-sync Assignment is complete.
- No code change, reinstall, setting change, manual sync or background-task simulation was performed for this record.
- Reopen a new pre-frozen device round only if the failure recurs or the sync path materially changes; otherwise no repeat automatic-sync run is planned.
