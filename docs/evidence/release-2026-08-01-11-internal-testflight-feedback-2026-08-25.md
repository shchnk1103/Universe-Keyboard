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
**Unknown:** exact active schema (`luna_pinyin` is reported context, not
independently captured), keyboard layout, raw input, candidate/marked-text state,
host App, Full Access state, deployment state, frequency and failure mode.
**Do not infer:** that the builtin dictionary is merely “too basic.” A resource,
configuration, session, UI commit or fallback defect remains possible.

### F-03 — Scheme downloads fail without VPN

The tester repeatedly encountered scheme-download errors without VPN. The Human
Product Owner explicitly classified this as urgent and asked to advance the plan
for scheme downloads that work across different regions.

**Known:** the current path was not usable on the tester's ordinary network and
VPN changed the practical reachability boundary.
**Unknown:** scheme/asset, exact URL and error, DNS/TLS/HTTP layer, carrier or
Wi-Fi, country/region, retry/resume behavior and whether every catalog source is
affected.
**Release impact:** broader external testing must not depend on testers finding
or operating a VPN. A resilient delivery design must retain immutable-byte
verification, checksum fail-closed behavior, per-scheme license acknowledgement,
source attribution and main-App-owned atomic installation/deployment.

## Required Reproduction Header

Capture this before diagnosis or implementation:

| Field | Current value |
|---|---|
| Device / OS full build | `UNKNOWN` |
| Universe Keyboard build | `1.0 (7)` per intake context |
| Host App | `UNKNOWN` |
| Layout | `UNKNOWN` |
| Active scheme | `UNKNOWN` |
| Full Access | `UNKNOWN` |
| Exact non-private input | `UNKNOWN` |
| Expected / actual | `UNKNOWN` beyond summaries above |
| Download scheme / URL / error | `UNKNOWN` |
| Network / region | VPN off observed; remaining facts `UNKNOWN` |

## Disposition At Intake

| Finding | Disposition | Gate |
|---|---|---|
| `F-01` | Route to fresh-install onboarding triage | External-candidate severity pending reproduction |
| `F-02` | Reproduce before diagnosing or choosing product behavior | `P1` candidate; do not broaden external testing while out-of-box multi-character input remains unexplained |
| `F-03` | Product priority advanced; prepare a separate delivery Architecture/Assignment proposal | Block broader external testing until fixed or explicitly decided by Product Lead |

Canonical Assignment:
[`RELEASE-2026-0801-11`](../assignments/release-2026-08-01-11-internal-testflight-feedback.md).
