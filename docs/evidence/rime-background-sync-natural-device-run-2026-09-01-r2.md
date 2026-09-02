# RIME-SYNC-001 Natural Background Device Run 02 — Freeze Manifest

## Run State

| Field | Value |
|---|---|
| Run ID | `RIME-SYNC-001-NATURAL-BG-20260901-02` |
| State | `INVALID (FORMAL) — ENGINEERING RESULT ACCEPTED; NO RETEST PLANNED` |
| Manifest frozen at | `2026-09-01T22:53:08+0800` |
| Human-round budget | `1`; used `1` |
| Formal claim boundary | One iOS-selected BGProcessingTask opportunity, one coherent automatic-sync operation, Diagnostics/v1 sequence, truthful phone notification and post-run crash/Jetsam receipts |
| Non-claims | No forced BGTask launch, no manual sync, no Product/merge/TestFlight/Release claim |

The new payload has been built and installed exactly once. It has not been
launched by Xcode, `devicectl` or the Device Operator. At
`2026-09-01T22:53:08+0800`, the Human Device Operator confirmed without changing
settings that notifications, Full Access, network availability and all relevant
sync configuration remain unchanged. The independent readiness delta reviews
subsequently accepted this final manifest.

At final delta review, Architecture returned `Ready` and Quality returned
`Ready`; all prior Hold conditions were closed. This readiness authorizes only
the Human Sequence below and does not pre-judge the run outcome.

The Device Operator completed the single normal App open and returned to the
iPhone Home Screen without pressing Sync or changing settings. The formal
observation window started at `2026-09-01T22:58:38+0800`; local timestamp receipt
SHA-256 is `b245e47ca91292f2ea25e125a56cd02dbc450724f822419d4ba0364dd0edf3b7`.

iOS selected a natural background opportunity at about
`2026-09-02 01:25 +0800`. Notification Center showed one automatic-sync start followed by one
automatic-sync completion at about `01:26`; the completion truthfully named
RIME common words, standard data and Universe App settings. The observation
window closed at `2026-09-02T07:27:50+0800`; its timestamp receipt SHA-256 is
`8e1aa806b22056efa30a43d73671f547891cd01be93388ec01b99fceb9544eeb`.

## Frozen Source And Build

| Boundary | Frozen identity |
|---|---|
| Product source | commit `06e7d1ce5ec111326d1cc1e0832a72e2bcca7f2e`; tree `ddf853edd6342142f99537006f4f86b052d3cab0`; clean before build |
| Diagnostics implementation | commit `d07b607`; Product Review accepted in `06e7d1c` |
| Build operation | One signed `xcodebuild` Debug device build into `/private/tmp/universe-rime-sync-natural-bg-20260901-02`; succeeded |
| Configuration | Debug / Swift `6.0` / strict concurrency `complete` / warnings as errors / `-Onone` |
| SDK and deployment | iPhoneOS SDK `27.0` build `24A5422a`; deployment target iOS `18.0`; arm64 |
| Signing | Automatic Apple Development; Team `C33N6HTS9N`; signed App CDHash `8c0518e3234b4ae5a0c762e7ce192789627492ff` |
| Installation | One `devicectl device install app`; database sequence `2000`; receipt SHA-256 `8f254dead5f98b04c5a2f7a39fe875d393c95ef29dfcdddf5674e1f816467ce1` |

Documentation-only evidence commits after this build do not alter the installed
runtime. Any code, project, dependency, signing or build-setting change,
rebuild, reinstall or Xcode Run invalidates this run.

## Frozen Payload Identity

| Payload | UUID | SHA-256 | Size |
|---|---|---|---:|
| Main App stub `Universe Keyboard` | `414EEF9C-742A-343B-BE97-10FEB9F7E579` | `c9b9e1e95f012ddb247cf7d8a3185653a35278e1fa8e7d407df4309544e36ddb` | `92128` |
| Main App business payload `Universe Keyboard.debug.dylib` | `5FC623CC-B773-3C90-B845-2AA009EC2E02` | `7369693ad4c0f1d8fc968d0e8b752e4264054faf9035a8e4d31eebfcf93a852e` | `28533968` |
| Keyboard Extension stub `Keyboard` | `64848EE8-DA1A-356E-94C1-398AC6433932` | `5eb5f8adf3b6e16a3403dd25666c99a28cedb0d212fcfda6ccee50183a0e6b03` | `89504` |
| Keyboard business payload `Keyboard.debug.dylib` | `B3413D18-012C-398E-A692-8DD04A74D5CB` | `0890de0cddb549aa91f2ebecf8d787960be4476362bd663115a7353cabf892bb` | `15721360` |

RIME is statically linked into the business payloads. The repository's 12
vendor framework artifacts passed structural verification in the final local
gate. CoreDevice exposes an installed receipt and bundle URL, not installed
executable byte readback; payload matching therefore means this single install
receipt bound to the frozen local signed identities, not direct byte equality.

## Device And Configuration Boundary

| Boundary | Frozen / expected value |
|---|---|
| Device | Physical iPhone 13 Pro (`iPhone14,2`), `DoubleShy0N`, UDID `00008110-000A08440198801E` |
| OS | iOS `27.0` Beta, build `24A5430a` |
| Connection at freeze | Wired, paired, Developer Mode enabled |
| Installed App | `com.DoubleShy0N.Universe-Keyboard` version `1.0 (1)`, developer build |
| Sync provider | Human-confirmed unchanged local folder selection/bookmark configuration |
| Automatic sync | Human-confirmed unchanged master `true`, standard `true`, private `true`, cadence `daily` |
| Notification / Full Access / network | Human-confirmed enabled and available at `2026-09-01T22:53:08+0800`; no setting changed during confirmation |
| Selected-config digest | Human-confirmed unchanged SHA-256 `bdca771de98b59dd438b0ceaf4cd23ec567653d9c7ae78aab3d0073f70215abf`; excludes runtime timestamps |
| Earliest estimate | Previous automatic opportunity was about `2026-09-01 00:26 +0800`; daily eligibility is therefore estimated no earlier than about `2026-09-02 00:26 +0800`, but iOS may delay it |

No raw App Group preferences, bookmark bytes, paths, credentials, dictionary or
input content are copied. Final configuration matching uses the prior
content-free digest plus Human confirmation that no relevant setting changed.

## Baseline Receipts

Raw receipts are git-ignored under
`evidence/rime-sync-001-natural-bg-20260901-02/raw/`.
The Executor rechecked that all eight files listed below are present locally at
final freeze; git ignore does not remove or relocate them.

| Artifact | Receipt |
|---|---|
| Device before build | SHA-256 `c58b26e1800f2c3f04e1a3543110c7f832f54db785b4b981359612d2fffa37b9` |
| Device after install | SHA-256 `9486751fa82321ca84f2899023b64660f5d28092ccad63c1daeec7242b7c18de` |
| Installed App after install | SHA-256 `41c92e8995c6bccdba5d32ffe039a17527898d06be878c3d31b9a62038d4fe66` |
| App crash baseline | `6` historical retired reports, latest `2026-08-28 22:12`; SHA-256 `bf6e267cc485e9313206d61a2d9a549736a2f83c98b6cd368ae4923768f11f85` |
| Keyboard search baseline | `8` entries, including the same 6 retired App reports and 2 old sysdiagnose directories; SHA-256 `d710cf8a44d012298aba9400182ba62757a982866b243d64d415c010a6cbc385` |
| Jetsam baseline | `49` historical reports, latest `2026-09-01 17:40`, before this build/install; SHA-256 `9673f9324cf0b446e4b855037bce07ded2ae5a7510eb1a07044eaf31d34e77df` |

Only new reports inside the future formal window and matching the frozen
process/binary identities may be attributed to this run.

## Human Sequence After Readiness Approval

1. Confirm without changing anything that notifications and Full Access remain
   enabled and that no RIME sync setting changed since the prior run.
2. Open Universe Keyboard normally once, wait for its home screen to stabilize,
   then return to the iPhone Home Screen. Do not press Sync and do not force-quit.
3. Record `windowStart` immediately after step 2. Thereafter the phone may be
   used normally; it need not stay locked or connected to the Mac. Do not reopen
   Universe Keyboard, change its settings, manually sync, reinstall, or run it
   from Xcode before the observation closes.
4. Wait for an iOS-selected natural opportunity. When a notification appears,
   inspect Notification Center and provide a content-free screenshot. Do not
   open the App until post-run read-only receipts are complete.
5. If no opportunity arrives, the result is `INCONCLUSIVE`, not permission to
   simulate or manually trigger the background task.

Expected Diagnostics/v1 evidence for a claimed operation uses schema version
`3`, exact `source=background_automatic`, requested phases
`standard_rime_data` plus `private_settings`, one opaque operation ID,
ordered phase transitions and exactly one terminal; alternatively it records
`invoked` plus one finite `skipped` reason. No accompanying
`source=foreground_automatic` transaction may appear in the same natural
opportunity. A duplicate transaction, contradictory terminal, missing payload
due to a crash, unexpected phase set or config drift fails or invalidates the
run according to the observed boundary.

## Frozen Post-freeze Allowlist

After final freeze, the exact machine allowlist is:

| Operation | Instantiated target / output | Side effect |
|---|---|---|
| `xcrun devicectl device info details --device 00008110-000A08440198801E --timeout 10 --json-output …/raw/device-post.json` | Frozen iPhone; local JSON receipt | Device read-only |
| `xcrun devicectl device info apps --device 00008110-000A08440198801E --bundle-id com.DoubleShy0N.Universe-Keyboard --timeout 10 --json-output …/raw/installed-app-post.json` | Frozen bundle ID; local JSON receipt | Device read-only |
| `xcrun devicectl device info files --device 00008110-000A08440198801E --domain-type systemCrashLogs --search 'Universe Keyboard' --timeout 10 --json-output …/raw/app-crashes-post.json` | Frozen device crash index | Device read-only |
| Same command with `--search Keyboard` and output `…/raw/keyboard-crashes-post.json` | Frozen device crash index | Device read-only |
| Same command with `--search JetsamEvent` and output `…/raw/jetsam-post.json` | Frozen device Jetsam index | Device read-only |
| `date '+%Y-%m-%dT%H:%M:%S%z'` written to `…/raw/window-start.txt` immediately after the Human returns Home | Local timestamp | Local receipt only |
| Same date command written to `…/raw/window-end.txt` immediately after the notification observation | Local timestamp | Local receipt only |
| `xcrun dwarfdump --uuid`, `shasum -a 256`, `stat -f %z` on the four exact local product paths already frozen above | Frozen local artifacts | Local read-only |
| Phone-local Notification Center inspection and one content-free screenshot | Phone UI | Human observation only |
| In-App Diagnostics/v1 inspection | Only after `windowEnd` and post-run machine receipts | Read-only product UI |

The ellipsis in output paths expands only to
`evidence/rime-sync-001-natural-bg-20260901-02`. Build, test, install, uninstall,
CLI launch, Xcode Run, manual BGTask simulation, manual sync and App Group/RIME
mutation are forbidden.

The run is `INVALID` if any of the following changes or occurs after freeze:
source/project/dependency/build/signing identity; installed receipt or
entitlements; device or OS build; App Group/RIME runtime ownership; provider,
folder/bookmark, automatic switches or cadence; notification/Full Access/network
requirements; device reboot or material clock change; unexpected App/Extension
launch before the allowed Human open; rebuild/reinstall; manual sync; or any
unlisted device/App Group mutation. Do not repair a mismatch inside this run.

## Observed Natural Opportunity

The Device Operator supplied a content-free Notification Center screenshot.
Its SHA-256 is
`25b180ed0e7173dc365855b4aea8641dbda761a21138b587dec146df3026095c`.
It shows only the following coherent notification pair for this opportunity:

- `01:25`: automatic sync started for RIME common words, standard data and
  Universe App settings.
- `01:26`: automatic sync completed for the same three user-facing scopes.

After `windowEnd` and the post-run machine receipts, the Device Operator opened
Diagnostics/v1 and copied all `rime_sync` matches around the opportunity. The
records contain no input text, paths, bookmark bytes or other private content.
In chronological order they are:

```text
[01:25:52.000] rime_sync.invoked operation=4a265c87-401a-4757-92ff-8e0241d2b311 source=background_automatic phases=standard_rime_data,private_settings
[01:25:52.000] rime_sync.phase_changed operation=4a265c87-401a-4757-92ff-8e0241d2b311 source=background_automatic phase=standard_rime_data result=started
[01:26:23.000] rime_sync.phase_changed operation=4a265c87-401a-4757-92ff-8e0241d2b311 source=background_automatic phase=standard_rime_data result=completed
[01:26:23.000] rime_sync.phase_changed operation=4a265c87-401a-4757-92ff-8e0241d2b311 source=background_automatic phase=private_settings result=started
[01:26:23.000] rime_sync.phase_changed operation=4a265c87-401a-4757-92ff-8e0241d2b311 source=background_automatic phase=private_settings result=completed
[01:26:23.000] rime_sync.terminal operation=4a265c87-401a-4757-92ff-8e0241d2b311 source=background_automatic result=completed
```

This is one opaque operation ID, the exact frozen source and phase set, ordered
phase transitions and exactly one successful terminal. There is no copied
`skipped`, `failed`, contradictory terminal, duplicate operation or
`foreground_automatic` record in the supplied match set.

## Post-run Machine Receipts

| Artifact | Result |
|---|---|
| Device | Same frozen UDID, model and iOS build; SHA-256 `c54f4eedb44d30d1da643744df21935baab62ca2c0b3b5e55eaf648baeff00d4` |
| Installed App | Same bundle ID, version and bundle URL; SHA-256 `3fd3fca3b5037aad7cf8e7da7a34b654eda312e807962e7eb43c67a963d52181` |
| App crash search | No new matching App crash inside the formal window; SHA-256 `6830b7f5c4ec1431491952dc13ea0f48923ebed90af8bc73f7bbfdd28f84495e` |
| Keyboard crash search | No new matching Keyboard crash inside the formal window; SHA-256 `5b4304b9fd1d10beb480d330814a48c1d911be14c27113841574212baeb39cce` |
| Jetsam index | Four new reports inside the formal window; SHA-256 `c5ecf22f357fd16fb0b7f3f6271befe056a191080d2a88e8580002524fc4e295` |

The four in-window Jetsam reports were downloaded read-only after explicit
Human authorization and classified by exact frozen UUID, not process name
alone. Their SHA-256 values are:

- `23:28:48`: `fa082bab664098650b08bd900c1aa1f65d045ae75fd6c0a0896d36619d7be71e`
- `23:34:48`: `6c9c2941eb212eb7bde448d06f3b55f1f7d3b13609ed81e6f7d9e77b8dcfd444`
- `23:38:13`: `28363d5657bacaffb1b52d7cd5e0a0128c76cf8c919250ec0cb2519805604a9d`
- `23:40:57`: `f8b1c77872acdecb9b18908aa1624e1079fe3262ed95ba87641224ee7bae0666`

The main App's frozen UUID appears suspended without a termination reason in
all four reports. The Keyboard Extension's frozen stub UUID was reclaimed at
`23:38:13` with `reason=long-idle-exit` while suspended, approximately 107
minutes before the natural sync invocation. It then disappears from the next
snapshot, as expected. This is a real in-window Jetsam victim and is recorded as
such, but its reason, state and timing classify it as routine idle-extension
lifecycle cleanup rather than a sync crash or interruption. Neither product
process has a Jetsam termination at the `01:25–01:26` sync opportunity.

## Final Independent Reviews

Architecture returned `HOLD` for the formal run. The technical observation is
coherent and supports only the scoped statement that the `long-idle-exit` did
not cause or interrupt the later sync. However, the governing preflight requires
no Keyboard Jetsam victim anywhere in the run window. This run truthfully has
one such victim, and no Product/Assignment owner exception was frozen before
execution.

Quality returned `HOLD` and identified a decisive manifest violation. The four
Jetsam report bodies were copied from the device after `windowEnd` with
`devicectl device copy from`. The Human explicitly authorized that read-only
download before it occurred, but the frozen machine allowlist did not contain
that command. The manifest forbids unlisted post-freeze device operations, so
later Human authorization cannot retroactively make those report bodies formal
run evidence.

The formal disposition is therefore `INVALID`, not `PASS` or `HOLD`. The four
downloaded Jetsam bodies are retained only as clearly excluded diagnostic
material; they created no device/App Group mutation and require no device
cleanup. The notification and Diagnostics/v1 sequence remain useful technical
evidence that one natural background transaction completed, but they do not
repair the governance violation or satisfy the original no-victim acceptance
condition.

Any future formal run would require a new pre-frozen manifest that explicitly
lists read-only crash-report copying and resolves whether an unrelated
`long-idle-exit` is accepted before execution. That is a new authority decision,
not a continuation or repair of this run.

## Human Product Disposition

On `2026-09-02 Asia/Shanghai`, the Human Product Owner accepted the scoped
engineering result and decided not to schedule another device run at this time.
The decision treats both disputed actions according to their observed product
meaning:

- The post-window `devicectl device copy from` operations were explicitly
  authorized, read-only diagnostic collection. They did not change the App,
  App Group, RIME state or device configuration.
- The Keyboard `long-idle-exit` was normal iOS lifecycle reclamation while the
  extension was suspended, occurred about 107 minutes before the sync, and did
  not cause or interrupt the successful main-App background transaction.

This Product disposition does not rewrite the frozen manifest or retroactively
turn the formal run into `PASS`; the audit result remains `INVALID`. It accepts
the narrower engineering conclusion that the reported double-transaction
background-sync failure was not reproduced by the fixed payload and that the
observed automatic transaction completed successfully. No repeat run is
planned. Reopen device validation only if the failure recurs or a later change
materially affects this path.

## Content-Free Receipt

```json
{
  "runId": "RIME-SYNC-001-NATURAL-BG-20260901-02",
  "manifestFrozenAt": "2026-09-01T22:53:08+0800",
  "windowStart": "2026-09-01T22:58:38+0800",
  "windowEnd": "2026-09-02T07:27:50+0800",
  "naturalOpportunityObserved": true,
  "installedPayloadMatch": true,
  "installedByteEqualityAvailable": false,
  "deviceAndOSMatch": true,
  "schemaAndConfigMatch": true,
  "humanRoundsUsed": 1,
  "taskTerminalOutcome": "COMPLETED",
  "diagnosticsV1SequenceMatch": true,
  "scopeSummaryTruthful": true,
  "phoneNotificationCenterMatch": true,
  "newAppCrash": false,
  "newKeyboardCrash": false,
  "keyboardJetsamVictim": true,
  "keyboardJetsamReason": "long-idle-exit",
  "keyboardJetsamAttributableToSync": false,
  "keyboardJetsamEvidenceScope": "diagnostic_only_excluded_from_formal_run",
  "postRunPayloadMatch": true,
  "cleanupZeroResidue": true,
  "invalidReason": [
    "unlisted_post_freeze_device_copy_command",
    "keyboard_jetsam_victim_conflicts_with_frozen_acceptance"
  ],
  "excludedArtifacts": [
    "JetsamEvent-2026-09-01-232848.ips",
    "JetsamEvent-2026-09-01-233448.ips",
    "JetsamEvent-2026-09-01-234023.ips",
    "JetsamEvent-2026-09-01-234057.ips"
  ],
  "humanProductDisposition": "engineering_result_accepted",
  "retestPlanned": false,
  "reopenCondition": "failure recurrence or material path change",
  "nextAuthority": "new pre-frozen run only if reopened",
  "result": "INVALID — post-freeze allowlist breach"
}
```

This run cannot close `TD-002`, authorize merge/TestFlight/Release or recover
the exact failure from run 01.
