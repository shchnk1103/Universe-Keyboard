# RELEASE-2026-0801-11 — Internal TestFlight Feedback Intake

> **Collected:** `2026-08-25 Asia/Shanghai`
> **Build context:** TestFlight `Universe Keyboard 1.0 (7)` internal group
> `Build 7 Internal Smoke`
> **Source:** Human Product Owner relaying a first-time internal tester's
> observations
> **Evidence grade:** `Device-attested`
> **Privacy boundary:** no private input content, personal contact value or
> credential is recorded

## TestFlight State Attested By Human

- Internal group `Build 7 Internal Smoke` exists with one Build and two invited
  internal testers.
- The tester invitation was received. Exact acceptance/install state and current
  online What to Test value were not independently inspected in this intake.
- This supersedes only the prior current-state claim of groups/testers `0`; it
  does not authorize external testing or Beta Review.

## Findings

### F-01 — First-run RIME concepts are confusing

The tester did not already understand RIME. First launch required choosing an
input scheme and deploying RIME resources, and that sequence felt confusing.

**Known:** this is a real first-user comprehension signal against the current
Build 7 journey.
**Unknown:** exact screen, wording, point of hesitation, whether the user could
finish without coaching, and whether the problem is sequencing, terminology,
default choice, progress feedback or recovery.
**Do not infer:** a specific UI solution or automatic download.

### F-02 — Reported builtin scheme fails multi-character composition

Before using 雾凇 or 万象, the tester reported that the builtin RIME path could
output a single Chinese character, but attempting two or more characters in one
composition did not work.

**Known:** single-character output was available; multi-character use was not.
The tester used an iPhone 16 Pro on iOS 18, 26-key layout, with Full Access off.
**Unknown:** exact iOS minor/build, exact active schema (`luna_pinyin` is
reported context, not independently captured), raw input,
candidate/marked-text state, host App, deployment state, frequency and failure
mode.
**Do not infer:** that the builtin dictionary is merely “too basic.” A resource,
configuration, session, UI commit or fallback defect remains possible.

### F-03 — Scheme downloads fail without VPN

The tester repeatedly encountered 雾凇 scheme-download errors without VPN on a
Mainland China cellular connection. The Human Product Owner explicitly
classified this as urgent and asked to advance the plan for scheme downloads
that work across different regions.

**Known:** device was iPhone 16 Pro on iOS 18; Full Access was off; the requested
scheme was 雾凇; region was Mainland China; network was cellular; and the
remembered failure text contained “network”. The current path was not usable on
the tester's ordinary network.
**Unknown:** exact iOS minor/build, carrier, asset URL/host, exact user-visible
message and underlying error domain/code, DNS/TLS/HTTP layer, retry/resume
behavior, whether VPN was subsequently used successfully in this exact attempt,
and whether every catalog source is affected. The remembered word “network” is
not sufficient to classify the root cause.
**Release impact:** broader external testing must not depend on testers finding
or operating a VPN. A resilient delivery design must retain immutable-byte
verification, checksum fail-closed behavior, per-scheme license acknowledgement,
source attribution and main-App-owned atomic installation/deployment.

**Product requirement:** scheme-download failures must be presented in
Simplified Chinese and identify an actionable category and recovery step. The
primary UI must not expose an untranslated raw `NSError` description. Sanitized
diagnostics may retain error domain/code, URL host and operation phase, but must
not record credentials, private input or sensitive URL query values. Network,
timeout/server, package-integrity, storage/extraction and deployment failures
must not collapse into a misleading single “network” explanation.

## Required Reproduction Header

Capture this before diagnosis or implementation:

| Field | Current value |
|---|---|
| Device / OS full build | iPhone 16 Pro / iOS 18; exact minor/build `UNKNOWN` |
| Universe Keyboard build | `1.0 (7)` per intake context |
| Host App | `UNKNOWN` |
| Layout | 26-key |
| Active scheme | `UNKNOWN` |
| Full Access | Off |
| Exact non-private input | `UNKNOWN` |
| Expected / actual | `UNKNOWN` beyond summaries above |
| Download scheme / URL / error | 雾凇 / URL `UNKNOWN` / remembered “network…”; exact text and domain/code `UNKNOWN` |
| Network / region | Cellular / Mainland China / VPN off |

## Disposition At Intake

| Finding | Disposition | Gate |
|---|---|---|
| `F-01` | Route to fresh-install onboarding triage | External-candidate severity pending reproduction |
| `F-02` | Reproduce before diagnosing or choosing product behavior | `P1` candidate; do not broaden external testing while out-of-box multi-character input remains unexplained |
| `F-03` | Product priority advanced; separate [`RIME-SCHEME-DELIVERY-001`](../assignments/rime-scheme-delivery-001.md) and [`source research`](rime-scheme-delivery-source-research-2026-08-25.md) now bound multi-endpoint selection, integrity and localized recovery as a pending delivery candidate | Block broader external testing until fixed or explicitly decided by Product Lead |

Canonical Assignment:
[`RELEASE-2026-0801-11`](../assignments/release-2026-08-01-11-internal-testflight-feedback.md).
