# Assignment: RELEASE-2026-0801-11 — Internal TestFlight First-Run And Scheme Delivery Feedback

**Policy version:** `1.0.0`
**Parent:** [`RELEASE-2026-0801`](release-2026-08-01.md)

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Assignment Pending` |
| **Phase** | Build 7 internal TestFlight Human feedback captured as three separate findings; no implementation track has entered `Ready` |
| **Non-claims** | No root cause is established; builtin multi-character failure is not yet proven to be an intentional Luna limitation; no CDN, mirror or regional delivery architecture is selected |
| **Next** | Capture exact reproduction data, then Product Lead names the domain Executor/reviewers or authorizes separate fix Assignments; F-03 is explicitly advanced as urgent before broader external testing |
| **Residuals** | [`2026-08-25 internal TestFlight feedback`](../evidence/release-2026-08-01-11-internal-testflight-feedback-2026-08-25.md) |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner in the active Codex task,
  `2026-08-25 Asia/Shanghai`, requested KOS recording of three Build 7 feedback
  findings and explicitly advanced cross-region scheme-download availability.
- **Product Approver:** Human Product Owner acting as Product Lead

## Boundary

- **Scope:** preserve the three findings without losing provenance; obtain the
  missing device/runtime/reproduction facts; classify user-journey, builtin
  scheme and scheme-delivery ownership; produce bounded fix Assignments and an
  external-TestFlight disposition.
- **Non-goals:** no production-code change; no automatic scheme download; no
  claim that VPN is a supported prerequisite; no provider/CDN/mirror selection;
  no weakening of archive checksum, license acknowledgement, provenance,
  privacy or main-App-owned deployment boundaries; no external Beta Review.
- **Required Inputs:**
  [`ONBOARDING_ACTIVATION.md`](../ONBOARDING_ACTIVATION.md),
  [`RIME_SCHEME_MANAGEMENT.md`](../RIME_SCHEME_MANAGEMENT.md),
  [`RELEASE_CHECKLIST.md`](../RELEASE_CHECKLIST.md), the exact TestFlight build,
  tester device/OS, keyboard layout, active scheme, Full Access state, host App,
  reproducible input sequence, download URL/error class and network/region facts.

## Assignment

- **Domain Owner:** `UNKNOWN` — the findings cross onboarding presentation,
  RIME scheme/runtime behavior and distribution operations; Product Lead must
  select the primary owner or split them.
- **Executor:** Current Codex task for documentation intake only; implementation
  Executor is `UNKNOWN`.
- **Environment Executor:** `UNKNOWN` — tester/device/network reproduction has
  not been assigned.
- **Human Dependency:** Human Product Owner and internal tester provide the
  missing non-private reproduction facts and Product priority/acceptance.
- **Architecture Reviewer:** `UNKNOWN` — required for any download-source,
  integrity, storage, privacy or deployment-boundary change.
- **Quality Reviewer:** `UNKNOWN` — required for fresh-install, builtin-scheme
  and cross-network verification.
- **Handoff Target:** Human Product Owner for Assignment Decision; then the named
  domain Executor(s).

## Findings

| ID | Human observation | Current release impact | Required next evidence |
|---|---|---|---|
| `F-01` | A first-time user unfamiliar with RIME found scheme selection and deployment confusing on first launch | Activation/product-language gap candidate; severity pending | Fresh-install journey, exact screen/step, expected plain-language outcome and whether the user could complete without coaching |
| `F-02` | Before using 雾凇 or 万象, the reported builtin scheme could commit one Chinese character but failed when composing two or more characters at once | `P1` candidate because usable out-of-box sentence input may be broken; root cause remains unknown | Confirm active schema, layout, raw input, candidates/marked text, host App, Full Access, reproducibility and whether this is config/resource/runtime rather than intended vocabulary depth |
| `F-03` | Scheme download repeatedly failed without VPN | Product Lead marked **urgent / plan advanced**; blocker for broader external testing where recommended schemes must be obtainable without private network workarounds | Exact asset URL, error/domain/status, carrier/Wi-Fi/region, retry behavior and a region/network matrix; then design a resilient verified-delivery contract |

## Gates

- **Entry Criteria:** intake evidence exists; Product priority for `F-03` is
  explicit. Remaining Assignment roles and reproduction facts are `UNKNOWN`, so
  implementation may not enter `Ready`.
- **Exit Criteria:** every finding has reproducible evidence, severity, owner,
  disposition (`fix`, explicit Product acceptance, or tracked debt), regression
  coverage and an exact Build 8-or-later handoff when code changes are required;
  broader external TestFlight has an explicit Gate decision.
- **Stop Conditions:** a proposed shortcut requires users to use VPN; changing
  the active/default scheme contract without Product approval; silently bundling
  mutable/unverified assets; bypassing per-scheme license acknowledgement;
  downloading/deploying from the Keyboard Extension; recording private input;
  or treating Build 7 feedback as proof of root cause.

## Handoff

- **Required Handoff Content:** exact reproduction header, expected/actual,
  screenshots or non-private diagnostics, network/error classification, selected
  owner and reviewers, solution boundary, tests, release impact and revalidation
  triggers.
- **Revalidation Trigger:** build, first-run journey, builtin resources, scheme
  catalog/source URL, checksum/license contract, region/network path, iOS/RIME
  runtime or release-channel change.
