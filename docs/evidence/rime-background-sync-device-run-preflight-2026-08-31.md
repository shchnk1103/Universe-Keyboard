# RIME Background Sync — Physical-Device Run Preflight

## Status

`HOLD — template prepared; immutable installed-payload manifest not frozen`

This packet prepares the single human-operated run required by `RIME-SYNC-001`.
It does not authorize device work and must not be completed retrospectively.
The Device Operator should receive no action until every required identity below
has been read from the installed payload and the Architecture/Quality readiness
review has passed.

## Prepared Source Boundary

| Field | Prepared value |
|---|---|
| Assignment | `RIME-SYNC-001` |
| Implementation commit | `3f9407387393b1a2c5fb63fba0a10f86af62bf18` |
| Implementation tree | `f7c24bf6e939bd20f53a857b27ce61207b7b62d9` |
| Local technical gate | `Executor-recorded`: KeyboardCore `1068/0`; RimeBridge `68/0` with `20` fixture skips; App `255/0` with `3` device-only skips; Keyboard `11/0`; Debug/Release strict builds passed |
| Toolchain | Xcode `27.0 (27A5252f)`, Swift 6 strict concurrency, warnings as errors |
| Human-round budget | `1`; only Product Lead may authorize another round |

Documentation commits after the implementation commit are allowed before the
run, but the source commit/tree actually used to build and install must be
recorded below. Any code, project, dependency or build-setting change requires
technical-gate revalidation.

Automation artifact pointers:

- focused lifecycle/model xcresult:
  `/tmp/universe-keyboard-rime-bg-direct-model-focused/Logs/Test/Test-Universe Keyboard-2026.08.31_07-39-33-+0800.xcresult`;
- RimeBridge xcresult:
  `/tmp/universe-keyboard-rime-bg-direct-model-rimebridge/Logs/Test/Test-RimeBridgeTests-2026.08.31_07-40-35-+0800.xcresult`;
- App + Keyboard xcresult:
  `/tmp/universe-keyboard-rime-bg-direct-model-app/Logs/Test/Test-Universe Keyboard-2026.08.31_07-41-15-+0800.xcresult`.

These local `/tmp` pointers support the current handoff only; they are not
durable hosted evidence and do not substitute for the future device artifacts.

## Immutable Installed-Payload Manifest

All `UNKNOWN` fields are blocking. Fill them from the installed device after one
build and one install, then freeze this section before the first human action.

| Boundary | Frozen identity |
|---|---|
| Run ID and freeze time | `UNKNOWN` |
| Source commit / tree / dirty disposition | `UNKNOWN` |
| Main App executable UUID / SHA-256 / size | `UNKNOWN` |
| Keyboard Extension executable UUID / SHA-256 / size | `UNKNOWN` |
| Main App debug dynamic payload UUID / SHA-256 / size, if present | `UNKNOWN` |
| Keyboard debug dynamic payload UUID / SHA-256 / size, if present | `UNKNOWN` |
| Embedded RIME runtime identity / digest | `UNKNOWN` |
| Configuration / SDK / deployment target / optimization / signing | `UNKNOWN` |
| Device model / UDID-safe alias / iOS build | `UNKNOWN` |
| Schema and content-free configuration fingerprint | `UNKNOWN` |
| Full Access / notification authorization | `UNKNOWN` |
| Host app and non-sensitive input-field class | `UNKNOWN` |
| Treatment / fixture identity | `N/A — observational natural-background run` |

## Allowed Sequence And Side Effects

1. **Before freeze — `build`:** build the selected source once.
2. **Before freeze — `install`:** install the App and embedded Keyboard once.
3. **Read-only:** collect installed executable, dynamic-payload and runtime
   UUID/SHA-256/size; freeze the manifest.
4. **Independent readiness review:** verify manifest coverage, privacy boundary,
   invalidation rules and the one-round budget.
5. **Human observation:** leave the App unused and wait for one iOS-selected
   natural background opportunity. Do not use `_simulateLaunchForTaskWithIdentifier:`
   as formal evidence.
6. **Read-only:** inspect the phone's own Notification Center and collect the
   content-free lifecycle receipt and any crash/Jetsam metadata.
7. **Read-only:** re-read installed-payload identities and compare with the
   frozen manifest.

After freeze, `build`, `install`, physical-device `xcodebuild test`, App Group
mutation, manual background-task simulation, schema/config changes and any
unlisted command invalidate the run. Opening the App to press manual sync is a
separate diagnostic action and must occur only after the formal observation is
closed or invalidated.

### Frozen command allowlist

Replace `<DEVICE>`, `<EVIDENCE_DIR>` and local product paths before readiness
review. The instantiated commands must be copied into the frozen manifest; no
other command is allowed after freeze.

| Command / operation | Side effect | Allowed after freeze |
|---|---|---|
| `xcrun devicectl device info details --device <DEVICE> --timeout 10 --json-output <EVIDENCE_DIR>/device.json` | Device payload read-only; writes a local receipt | Yes, pre/post |
| `xcrun devicectl device info apps --device <DEVICE> --bundle-id com.DoubleShy0N.Universe-Keyboard --timeout 10 --json-output <EVIDENCE_DIR>/installed-app.json` | Device payload read-only; writes a local receipt | Yes, pre/post |
| `xcrun devicectl device info files --device <DEVICE> --domain-type systemCrashLogs --search 'Universe Keyboard' --timeout 10 --json-output <EVIDENCE_DIR>/app-crashes.json` | Device crash-log index read-only | Yes, pre/post |
| `xcrun devicectl device info files --device <DEVICE> --domain-type systemCrashLogs --search Keyboard --timeout 10 --json-output <EVIDENCE_DIR>/keyboard-crashes.json` | Device crash-log index read-only | Yes, pre/post |
| `xcrun devicectl device info files --device <DEVICE> --domain-type systemCrashLogs --search JetsamEvent --timeout 10 --json-output <EVIDENCE_DIR>/jetsam.json` | Device crash-log index read-only | Yes, pre/post |
| `xcrun dwarfdump --uuid <LOCAL_PRODUCT_OR_DSYM>` | Local artifact read-only | Yes |
| `shasum -a 256 <LOCAL_PRODUCT_PAYLOAD>` and `stat -f %z <LOCAL_PRODUCT_PAYLOAD>` | Local artifact read-only | Yes |
| `date '+%Y-%m-%dT%H:%M:%S%z'` written to the local content-free run receipt | Local clock read-only; writes only a local timestamp | Yes, exactly at `windowStart` and `windowEnd` |
| Phone-local Notification Center inspection and screenshot | Human observation; creates a content-free screenshot | Once, after natural opportunity |
| `xcodebuild`, Xcode Run/Test/Profile/Archive, `devicectl ... install/uninstall`, Executor/CLI `devicectl ... launch`, manual BGTask simulation | Build/install/execute; may replace or perturb the frozen payload | **Forbidden**; an instantiated run may separately allow one listed Human normal App open |
| App Group/RIME copy, move, delete, deploy, download, schema/config edit or manual sync | Runtime mutation | **Forbidden** |

CoreDevice may expose only an installed receipt/path rather than readable
installed bytes. If exact installed executable/dynamic-payload SHA cannot be
read back, readiness remains `HOLD` unless the independent reviewers accept an
explicit receipt + local product UUID/SHA binding for this run. The manifest
must record that limitation; it must not infer byte equality.

This observation has no treatment/staging phase and authorizes no cleanup
command. `cleanupZeroResidue` becomes `true` only when the command ledger proves
that no treatment, App Group mutation or temporary device artifact was created;
otherwise the run is invalid and cleanup requires separate authority.

## Acceptance And Stop Conditions

The receipt may record a pass only when:

- iOS selected the background opportunity without manual launch simulation;
- installed payload, device/OS and schema/config still match the frozen manifest;
- the task has one truthful terminal outcome and no contradictory scope text;
- phone-local Notification Center presentation agrees with that outcome;
- no new App/Keyboard crash or Keyboard Jetsam victim appears in the run window;
- no input, candidate, dictionary entry, file path or other user content enters
  the receipt.

Stop and mark `INVALID` or `HOLD` on any identity mismatch, rebuild/reinstall,
configuration drift, missing raw evidence, privacy-boundary breach, unexpected
App Group mutation, or exhausted human-round budget. A natural opportunity not
arriving is `INCONCLUSIVE`, not a failure and not permission to force-launch it.

## Content-Free Receipt Template

```json
{
  "runId": "UNKNOWN",
  "manifestFrozenAt": "UNKNOWN",
  "naturalOpportunityObserved": false,
  "installedPayloadMatch": false,
  "deviceAndOSMatch": false,
  "schemaAndConfigMatch": false,
  "treatmentPinMatch": null,
  "treatmentDisposition": "N/A — observational natural-background run",
  "humanRoundsUsed": 0,
  "taskTerminalOutcome": "UNKNOWN",
  "scopeSummaryTruthful": false,
  "phoneNotificationCenterMatch": false,
  "newAppCrash": false,
  "newKeyboardCrash": false,
  "keyboardJetsamVictim": false,
  "cleanupZeroResidue": false,
  "postRunPayloadMatch": false,
  "result": "HOLD",
  "rawArtifactPointers": []
}
```

`rawArtifactPointers` may identify controlled crash reports, system logs or
screenshots, but the receipt itself must remain content-free. If invalidated,
record `reason`, `discoveredAt`, `excludedArtifacts`, `cleanup` and
`nextAuthority`; invalid artifacts remain diagnostic-only.

## Remaining Authority

Completing this packet can provide Device-attested evidence for natural
scheduling and phone notification presentation. It cannot close `TD-002`,
cross-front-end compatibility, Product Gate, merge, TestFlight or Release.
