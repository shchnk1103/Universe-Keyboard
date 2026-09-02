# RIME-SYNC-001 Natural Background Device Run — Manifest And Execution Evidence

## Run State

| Field | Value |
|---|---|
| Run ID | `RIME-SYNC-001-NATURAL-BG-20260831-01` |
| State | `EXECUTED — FAIL; post-run read-only receipts complete` |
| Freeze time | `2026-08-31T18:37:10+0800` |
| Human-round budget | `1`; used `1`; only Product Lead may authorize another round |
| Treatment | `N/A — observational natural-background run` |
| Formal claim boundary | Natural iOS-selected BGProcessingTask opportunity, truthful terminal notification and phone-local Notification Center presentation only |

The Device Operator confirmed Notifications and Full Access were enabled, opened
the App once, returned to the Home Screen and made no configuration changes or
manual sync before the natural opportunity. iOS then presented the notification
sequence recorded below. A later manual sync is outside this frozen window and
does not alter the natural-run observation.

## Observed Outcome

| Evidence | Observation |
|---|---|
| Formal window | `2026-08-31T18:47:58+0800` through `2026-09-01T07:35:07+0800` |
| Phone-local event time | Notification Center shows two starts at `00:26` and two terminal notifications at `00:27` |
| Combined transaction | Started for RIME standard data plus Universe settings, then reported RIME incomplete and Universe settings not started |
| Private-only transaction | Independently started Universe settings and reported completion in the same minute |
| Screenshot | Human-supplied phone-local Notification Center screenshot; SHA-256 `c4db91c88b0b3913ec28de14087c45a7194c8723f005070591321ce299a02cb5`; not copied into the repository |
| Finding | Two independently owned automatic transactions reached the user surface. This disproves the required single coherent App-process transaction, but does not by itself prove the exact RIME failure code or temporal overlap inside librime. |
| Disposition | `FAIL` for this installed build. Later read-only receipts found the same installed-App receipt and no new in-window App crash, Keyboard crash or matching Jetsam victim. The exact RIME error remains `UNKNOWN`. |

Static tracing after the run found separate foreground and background
`RimeSyncViewModel` instances with instance-local synchronization state. The
current uncommitted remediation adds a main-App process ownership gate across
manual, foreground-automatic and background-automatic entries. It is not part
of the frozen installed payload and requires a new authorized device round.

### Remediation verification (`2026-09-01`)

- Swift format strict lint and `git diff --check`: pass.
- Focused process-gate policy tests: `21 passed, 0 failed`.
- Full App + Keyboard XCTest: `271 passed, 0 failed, 3 skipped`.
- RimeBridgeTests: `48 passed, 0 failed, 20 skipped`.
- KeyboardCore: `1068 passed, 0 failed`.
- Strict Swift 6 Debug and Release simulator builds: pass.
- Architecture and Quality independent reviews: `Pass with conditions`.

The simulator used for App/RimeBridge evidence was an equivalent iPhone 16 Pro
on iOS 18.0 because the locally available CI-named iPhone 17 Pro belongs to a
different runtime. These results do not replace the pending physical-device
evidence.

### Post-run read-only receipts (`2026-09-01`)

After the device reconnected, the frozen allowlisted read-only queries were
completed. The installed-App receipt still matches the frozen receipt. No new
App crash, Keyboard crash or Jetsam victim attributable to the frozen payload
appeared inside `windowStart...windowEnd`. The phone had updated from iOS build
`24A5424a` to `24A5430a` by the later device-details read, so that later read is
not an exact current-OS match; it does not invalidate the device/OS observation
recorded during the formal window.

The current Diagnostics/v1 viewer contained no `rimeSync` records even though
the user confirmed recording and all categories, including CONFIG, were enabled.
Static tracing shows this old installed build emitted those messages only to the
legacy `rime_diag_log` store. The whole App Group preferences plist was not
copied because it can contain unrelated sensitive data. Consequently this run
does not claim a precise RIME failure code.

## Frozen Source And Build

| Boundary | Frozen identity |
|---|---|
| Product source | commit `b1972267e807e9a41a9f2165c7c3805c11358888`; tree `38f12512a83eb581ea989686386f260c9cd71e48`; clean at build |
| Reviewed implementation | `3f9407387393b1a2c5fb63fba0a10f86af62bf18`; code tree `f7c24bf6e939bd20f53a857b27ce61207b7b62d9` |
| Build operation | One `xcodebuild ... -configuration Debug -destination id=00008110-000A08440198801E ... build`; `BUILD SUCCEEDED` |
| Build settings | Debug / `-Onone`; iphoneos 27.0; deployment target iOS 18.0; Swift 6 strict concurrency; warnings as errors |
| Signing | Apple Development; Team `C33N6HTS9N`; App provisioning profile `06df90be-84d7-4d3a-987a-aceeb1fa8222` |
| Installation | One `devicectl device install app`; database sequence `2468`; receipt SHA-256 `64c30961411fd19fdebda00c5d469c2c82ce03c5d7020a097027fea5d6b43b60` |

Evidence-document edits made after this build do not alter the installed
payload. Any code, project, dependency, signing or build-setting change
invalidates the run.

## Frozen Payload Identity

| Payload | UUID | SHA-256 | Size |
|---|---|---|---:|
| Main App stub `Universe Keyboard` | `AB2FC06A-CC2A-37FF-B3AE-6E9FD5879961` | `7f2174500def4fb6fae70378f100a29507102be56d9340a27a0eb77bcee4f8cb` | `92128` |
| Main App business payload `Universe Keyboard.debug.dylib` | `13ECF9B2-0A8E-3ED2-A291-B3C7601CE5A8` | `8df092bd6fbcd987242ab580fce5766f9a962f6a1e923d1b00507a2ebb5ed461` | `28022112` |
| Keyboard Extension stub `Keyboard` | `42F92338-1CA3-3CE2-83C7-8B357690BBB4` | `c83963e302480773338bbf050142b99e2d975416467aa456928196dc913bdc39` | `89504` |
| Keyboard business payload `Keyboard.debug.dylib` | `111CFB2E-25F0-3289-A51D-5EDB652771AE` | `b6f91a62cfcfd99acb7b83e151ea2d0cbc43e58a92e6a49f8f766c31468db609` | `15364352` |

RIME is statically linked into the Debug business payloads; there is no
standalone embedded RIME framework to read back. The dylib hashes above bind the
actual linked runtime. The repository's 12 vendor artifacts passed structural
verification before this build.

CoreDevice exposes the installed bundle receipt/path but not installed bundle
byte readback. Therefore `installedPayloadMatch` may be accepted only as the
explicit combination of the single install receipt and the frozen local signed
product identities above. It must not be described as direct installed-byte
equality.

## Frozen Runtime And Configuration

| Boundary | Frozen identity |
|---|---|
| Device | Physical iPhone 13 Pro (`iPhone14,2`), device alias `DoubleShy0N` |
| OS | iOS `27.0`, build `24A5424a` |
| Connection | Wired, paired, Developer Mode enabled |
| Installed App | `com.DoubleShy0N.Universe-Keyboard`, version `1.0 (1)`, developer build, install database sequence `2468` |
| App Group | `group.com.DoubleShy0N.Universe-Keyboard` |
| Sync provider | Local folder; security-scoped bookmark present; repair flag `false` |
| Automatic sync | Master `true`; standard scope `true` by migration default; private scope `true` by migration default; cadence `daily` by default |
| Last automatic attempt | `2026-08-30T19:19:58+0800`; calculated earliest eligible date `2026-08-31T19:19:58+0800` |
| Notification gates | App master, RIME category, standard-data and private-settings stored gates are `true`; prior phone-origin notification evidence exists; first human step must confirm current system authorization without changing it |
| Keyboard access | Stored activation/full-access affirmation is `true`; first human step must confirm current system Full Access without changing it |
| Host / input-field class | `N/A — this observational run performs no keyboard input` |
| Content-free selected-config digest | SHA-256 `bdca771de98b59dd438b0ceaf4cd23ec567653d9c7ae78aab3d0073f70215abf` |
| Preference privacy | The pre-freeze local copy was used once to derive the allowlisted selected-config digest, then deleted before readiness review; no raw preference bytes are retained as evidence |

If either system authorization or Full Access differs from the frozen expected
state, stop and mark the run `INVALID`; do not change the setting inside this
run. The selected-config digest excludes runtime timestamps so the background
attempt itself does not create false configuration drift.

## Baseline And Raw Artifacts

Raw artifacts are git-ignored under
`evidence/rime-sync-001-natural-bg-20260831-01/raw/`.

| Artifact | Baseline / digest |
|---|---|
| Frozen device details | `5392eb2afb3f31ae4487ebda34e7b708d1b37dc8063bbab9365fee330a29ab1a` |
| Frozen installed-App receipt | `1ca64112d2a944d5e5050b37d92fc733639462123781314eb02d1127ed40432f` |
| App crash list | `8` historical retired reports; latest `2026-08-28 22:12`, before run; digest `06acc54f0be4e32ec0cf19000cc5362385ee24eac5e3de60e38a2f3020c2fd85` |
| Keyboard search list | `10` historical entries; digest `b07436205a896d19e916b774814f11cc5db83238f4755f8f82ddf43523414799` |
| Jetsam list | `56` historical reports; latest `2026-08-31 16:10`, before install/freeze; digest `d673532fd521fafc7a87be2fa4d789cd4f60777f1b94415ccbc85cad3058d353` |

Only reports newer than the formal run-window start may be attributed to this
run, and only after process/victim/UUID classification.

### Frozen crash/Jetsam window and classification

- `windowStart` was recorded as `2026-08-31T18:47:58+0800` immediately before
  the first Device Operator action.
- `windowEnd` was recorded as `2026-09-01T07:35:07+0800` after the phone-local
  observation was supplied and before post-run machine receipts could be read.
- An App crash counts only when a new report falls within
  `windowStart...windowEnd`, names `Universe Keyboard`, and its binary image UUID
  matches `AB2FC06A-...` or `13ECF9B2-...`.
- A Keyboard crash counts only when a new report falls within the same window,
  names the Keyboard extension, and its binary image UUID matches
  `42F92338-...` or `111CFB2E-...`.
- A Jetsam counts only when a new in-window Jetsam report contains the App or
  Keyboard process row and explicitly marks that row as victim/jettisoned.
- Process disappearance, background suspension, `RUNNINGBOARD / 0xdead10cc`,
  watchdog/resource reports without a matching process/UUID, and reports from
  other builds are classified separately; they are not silently counted as a
  crash/Jetsam pass or failure.
- A bounded post-run no-match means only that no matching report appeared in
  this frozen window; it does not prove the process never exited.

## Frozen Command And Human-Action Allowlist

After readiness approval, the only human sequence is:

1. Confirm, without changing them, that iOS Notifications for Universe Keyboard
   are allowed and Universe Keyboard Full Access remains enabled.
2. Open Universe Keyboard once, wait until its normal home screen is stable,
   then return to the iPhone Home Screen. Do not press Sync and do not force-quit
   the App from the app switcher.
3. Keep the phone on Wi-Fi; locking it and connecting power are allowed but
   power is not required. Leave the App unused through an iOS-selected natural
   opportunity after `2026-08-31T19:19:58+0800`.
4. When a notification appears, inspect the phone's own Notification Center and
   provide a screenshot containing no typed content. Do not open the App or
   manually sync until the post-run machine receipts are complete.

The Executor may run only the frozen read-only commands already specified in
the preflight packet, instantiated for device `00008110-000A08440198801E` and
this evidence directory: device details, installed-App receipt, App/Keyboard
crash indexes, Jetsam index, local `dwarfdump`/`shasum`/`stat` and receipt
hashing, plus the two exact local `date` reads for
`windowStart` and `windowEnd`. App or App Group preferences metadata queries and
raw preferences copying are forbidden after freeze. Configuration comparison
uses the frozen allowlisted digest plus a post-observation, read-only visual
confirmation of the same non-sensitive settings; bookmark bytes, paths,
credentials and unrelated preferences must never be copied or recorded.

`xcodebuild`, Xcode Run/Test/Profile/Archive, reinstall/uninstall,
Executor/CLI `devicectl ... launch`, manual BGTask simulation, manual sync,
setting changes, App Group/RIME mutation, signals and unlisted device commands
are forbidden after freeze. The single Human normal App open in step 2 is the
only allowed launch and exists solely to register/submit the natural background
request. Any other launch or forbidden action invalidates the run.

## Content-Free Receipt

```json
{
  "runId": "RIME-SYNC-001-NATURAL-BG-20260831-01",
  "manifestFrozenAt": "2026-08-31T18:37:10+0800",
  "naturalOpportunityObserved": true,
  "installedPayloadMatch": true,
  "installedByteEqualityAvailable": false,
  "deviceAndOSMatch": true,
  "schemaAndConfigMatch": true,
  "treatmentPinMatch": null,
  "treatmentDisposition": "N/A — observational natural-background run",
  "humanRoundsUsed": 1,
  "taskTerminalOutcome": "MIXED — combined transaction failed; private-only transaction completed",
  "scopeSummaryTruthful": false,
  "phoneNotificationCenterMatch": true,
  "newAppCrash": false,
  "newKeyboardCrash": false,
  "keyboardJetsamVictim": false,
  "postRunPayloadMatch": true,
  "cleanupZeroResidue": true,
  "result": "FAIL — duplicate main-App automatic transactions reached the user surface",
  "rawArtifactPointers": [
    "human-supplied Notification Center screenshot sha256:c4db91c88b0b3913ec28de14087c45a7194c8723f005070591321ce299a02cb5",
    "device-post-final.json sha256:ffdfee1658f1ffad268300e7083966866103c4e12c3c11573582e011292f9711",
    "installed-app-post-final.json sha256:5f94f79921afea1f470be75025dfb6366b680cc380c828c37247a4aeaa7f9a4e",
    "app-crashes-post-final.json sha256:ee563775f49ff3f10a7aa06996c301d4adcee71d4175aa693cdc6929acf00ff0",
    "keyboard-crashes-post-final.json sha256:645eb0ca741eab6b461e0ffe9eaffd693f0d7315af3df04a22a1f4d7ce584080",
    "jetsam-post-final.json sha256:57432af81236c6317b526ae9adccf1eb1cd35b2d90dcf37931f7456590d7fb95"
  ]
}
```

Natural opportunity absence is `INCONCLUSIVE`, not failure. This run cannot
close `TD-002`, cross-front-end compatibility, Product Gate, push, merge,
TestFlight or Release.
