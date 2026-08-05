# Assignment: T9-RESPONSIVE-PIPELINE-001 / CANARY-001 / DEVICE-001
# iPhone 13 Pro production-shaped canary evidence

Policy version: 1.0.0

Lifecycle status: **pair-002 four-arm (A/B/K/O) device execution COMPLETE 2026-08-05; device evidence closed; independent review pending**

Date: 2026-08-04 Asia/Shanghai

## Authority

- Assignment Authority: **Product Lead**
- Decision Source / Date: Human Product Owner instruction in the active Codex
  task, `我授权你，接下来就在我的iPhone 13 Pro上进行测试吧！`, 2026-08-04
  Asia/Shanghai.
- Product Approver: Human Product Owner / Product Lead.
- Parent Assignment:
  [`CANARY-001`](t9-responsive-pipeline-001-production-shaped-canary-001.md).
- Architecture boundary: ADR 0025 remains **Proposed**; ADR 0004 remains the
  ordinary production path.

## Boundary

### Scope

1. Add the smallest internal-only, fail-closed Main-App launch entry needed to
   prepare the four existing canary App Group values (`enable`, `kill`,
   `expiresAt`, `runID`) and assert kill. The writer exists only when both
   `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT` and `T9_RESPONSIVE_CANARY_INTERNAL` are
   injected; it is absent from ordinary Release. The Main App records a
   content-free post-write/readback receipt, and the Keyboard Extension records
   the independently parsed snapshot and startup/kill decision.
2. Build three signed Release variants from one frozen source identity:
   content-free diagnostic baseline A, internal canary B, and ordinary
   gate-off restore O. Install only by replacement on the named iPhone 13 Pro.
3. Freeze one immutable device envelope before input: signed executable hashes,
   compile conditions, opaque device identity, iOS, host, Full Access, schema,
   orientation, appearance, thermal/power state, fixture identity, time window,
   archive and restore identity.
4. Run one bounded A/B diagnostic pair with the same synthetic 39-event fixture
   and Human cadence explicitly treated as a confound; then assert the explicit
   kill-switch and restore O.
5. Retain only content-free markers, aggregates, hashes, status and the Human
   integrity/subjective report. Raw input, candidates, host text, screenshots,
   UI hierarchy and userdb never enter repository evidence.

### Non-goals

- No default gate change, user-facing canary setting, production rollout,
  Product Gate, Release approval or ADR 0025 acceptance.
- No uninstall, App Group cleanup, userdb reset/inspection, RIME deployment,
  schema/Lua change, host-data deletion or device erase.
- No coordinate-driven XCTest, Computer Use typing or guessed tap positions.
- No fixed latency/memory SLO and no claim that one manual A/B pair is a
  benchmark.
- No unrelated source refactor, commit or push.

### Frozen implementation allowlist

- `Packages/KeyboardCore/Sources/KeyboardCore/ResponsiveRimePreflight.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/ResponsiveRimeCanaryContractTests.swift`
- `Universe Keyboard/Views/Diagnostics/T9DevicePreflightEvidenceView.swift`
- `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift`, limited to
  content-free receipts at the existing canary startup evaluation and active
  kill transition boundaries
- this Assignment, its Architecture/Quality reviews and its exact evidence
  manifest/header/result records.

No project default, entitlement, schema, Lua, RimeBridge, App Group file or
other Keyboard Extension controller file is in the implementation allowlist.
The sole controller exception is the two bounded Bootstrap receipt points named
above; they may not change startup/kill behavior. Runtime writes
are limited to the four existing canary preference keys; kill is written first
during prepare and enablement becomes effective only after the complete valid
snapshot is synchronized and read back. The exact prepare transaction is:

1. write `kill=true`, synchronize and require typed-boolean readback `true`;
2. while kill remains true, write canonical `runID`, finite numeric `expiry`
   and typed-boolean `enable=true`, synchronize and require a complete typed
   readback match;
3. only after step 2 succeeds, write `kill=false`, synchronize and require
   typed-boolean readback `false`;
4. any failure writes or preserves `kill=true`; a failed prepare never reports
   success. K writes only `kill=true` and reports success only after readback.

Restore leaves the four keys inert rather than deleting other App Group state.

## Assignment

- Domain Owner: **RIME Platform Maintainer**.
- Executor: **Current Codex primary agent `/root`** — scoped implementation,
  freeze, evidence orchestration and final handoff.
- Environment Executor: **Current Codex primary agent `/root`** — signed build,
  replacement install, internal Main-App launch controls, content-free export
  and ordinary restore only.
- Human Dependency: **Human Product Owner** — keep the named device connected
  and unlocked when requested; confirm Full Access and selected schema/host;
  manually type the frozen synthetic sequence in an otherwise-empty Reminders
  field; report only 0-4 visible-stall score plus missing/duplicate input,
  candidate disappearance, digit leak or keyboard exit. Acknowledgement is
  requested immediately before the first input arm.
- Architecture Reviewer: independent `/root/canary_arch_review`.
- Quality Reviewer: independent `/root/canary_quality_review`.

## Required inputs

- Frozen run004 automated/Simulator result and post-run reviews.
- Connected physical iPhone 13 Pro (`iPhone14,2`), opaque discovery SHA-256
  `f5d2508e95eff580f683c9669f1f89e606978159019735c4b77fcd6624c4dc9b`.
- Observed preflight state: iOS 27.0 (`24A5390f`), wired, paired, Developer Mode
  enabled. These discovery facts do not become run facts until frozen again in
  the final device header.
- Host fixed to Reminders, otherwise-empty item field, portrait orientation.
- Full Access fixed to ON for this canary phase; OFF behavior remains NotRun.
- Active schema intended as `rime_ice`; the current-run runtime observation must
  confirm it or stop.

## Staged gates

Independent pre-implementation reviews: Architecture and Quality both
**Approve**, each with `P0/P1/P2/P3 = 0/0/0/0`. This activates only the bounded
implementation allowlist; it does not activate device installation or input.

Independent post-implementation reviews initially rejected device freeze after
finding fail-closed/readback, typed snapshot and receipt-schema defects. The
bounded correction now asserts and verifies kill on every defaults-backed
failure path, reflects failed readback honestly, validates ASCII run IDs and
integer-safe Unix expiry, and emits the frozen schema through the existing
content-free export filter. Focused internal contracts pass `15/0`; ordinary
and internal strict unsigned Release builds succeed; binary isolation confirms
the ordinary App/Extension contain no canary marker, environment key or
preference key while the internal targets contain the expected symbols.
Architecture and Quality re-review both **Approve** with
`P0/P1/P2/P3 = 0/0/0/0`. This authorizes signed A/B/O and immutable header/
manifest freeze only; installation and Human input remain gated by the final
pre-run reviews and acknowledgement.

### Implementation entry

1. This Assignment has no `UNKNOWN` responsibility.
2. Architecture and Quality independently approve the expanded allowlist with
   P0/P1 = 0.
3. The internal writer is provably absent from ordinary Release and fails
   closed on invalid token/expiry/defaults.

### Device-run entry

1. Focused contract tests and ordinary/internal strict Release builds pass.
2. A, B and O signed artifact identities and exact commands are frozen before
   the first install; O exists before B is installed.
3. Device/OS/host/Full Access/schema/run token/time/geometry/archive/restore
   fields are observed or explicitly block the run.
4. Architecture and Quality approve the immutable device header/manifest with
   P0/P1 = 0.
5. Human Dependency acknowledges the manual-input instructions.
6. A local quarantined operator sheet freezes the ordered 39-event fixture,
   canonical serialization and SHA-256 before A. Repository evidence retains
   only its fixture ID, count and digest; B must bind the identical digest.

### Exit criteria

- A and B each produce a complete content-free run header and terminal record.
- For B, every ACCEPT has one terminal and every PUBLISH has one visibility
  disposition and PAINT terminal; missing reasons remain blocking.
- Main-App configuration receipts include the opaque `runID`, boolean
  `enable`/`kill`, numeric `expiry`, write result and readback match. Extension
  receipts include the same four parsed values, validity/expiry state and the
  resulting `startCanary`/`baseline`/`kill` decision. A writer-only receipt
  cannot prove activation.
- The machine-checkable receipt schema is `T9RESP-CANARY-CONFIG-v1`. `runID`
  is canonical ASCII `[A-Za-z0-9_-]`, length 1...64; enable/kill serialize as
  typed `0|1`; expiry is finite integer Unix seconds inside the frozen window.
  Required fields are `schema actor phase run enable kill expiry valid
  expiryState decision status`. Allowed actors are `app|extension`; allowed
  decisions are `prepared|startCanary|baseline|kill|failClosed`; allowed status
  values are `success|failure|readbackMismatch`. No additional free-text field
  is publishable.
- The Human report and aggregate timing/count evidence remain separately
  labelled, with cadence as a confound.
- Kill assertion is observed, no later canary ACCEPT occurs, and safe baseline
  recovery is classified.
- O is replacement-installed; installed App/Extension identities match the
  frozen restore artifact; manual display/switch/basic-input smoke is recorded.
- Independent Architecture and Quality reviews publish residuals and return the
  bounded result to Product Lead.

### Stop conditions

Stop evidence input/capture if any source/artifact/device/OS/host/access/schema/
token identity changes, signing/install fails, Full Access or host cannot be
observed, internal flags appear in O, marker privacy fails, an unexplained
ACCEPT/PUBLISH/PAINT gap appears, the keyboard exits, or progress would require
uninstall, cleanup, deployment, production wiring, default change or automation
of third-party keyboard taps.

The safety-finally lane is mandatory even after an A/B/K failure: stop manual
input, attempt the content-free `kill=true` assertion/readback, then
replacement-install the already-built and frozen O artifact, compare installed
App/Extension identity and request only the bounded keyboard switch/basic-input
restore smoke. A capture failure never authorizes leaving B installed. If the
device becomes unavailable or O replacement itself fails, record `Blocked` and
do not substitute uninstall, cleanup or deletion.

Configuration diagnostics are emitted only at Main-App prepare/readback,
Extension startup evaluation and kill transition boundaries. They must not run
on the key-input hot path and must not contain device IDs, input, candidates,
host text or userdb content.

## Minimal device matrix

| Arm | Signed Release identity | Manual work | Required outcome |
|---|---|---|---|
| A | content-free diagnostics; canary capability absent | one frozen 39-event synthetic sequence | baseline markers and Human report; no canary claim |
| B | diagnostics + `T9_RESPONSIVE_CANARY_INTERNAL`; valid enable and kill=false | same sequence once | real owner active; complete ordered terminal accounting; bounded aggregates |
| K | same B artifact; external internal-only kill assertion | re-present keyboard and bounded basic input | kill/fence/drain terminal or explicit fail-closed result; no concurrent owner |
| O | ordinary Release; no diagnostic/internal flags | keyboard switch and basic input smoke | installed identities match O; ordinary gate-off restored |

## Evidence and handoff

- Canonical device evidence:
  `docs/evidence/t9-responsive-pipeline-canary-001-device-001-2026-08-04.md`
- Machine summary:
  `docs/evidence/t9-responsive-pipeline-canary-001-device-001-summary-2026-08-04.json`
- Immutable run header and command manifest use the same `device-001` stem and
  are created only after implementation validation.
- Raw/device artifacts remain local under `evidence/CANARY-001-DEVICE-001/` and
  are quarantined-not-publishable.
- Handoff Target: independent Architecture review, independent Quality review,
  then Human Product Owner / Product Lead.
- Revalidation Trigger: any allowlist, source, build, signing, device, OS, host,
  Full Access, schema, fixture, run token, marker/privacy schema or restore
  identity change.
