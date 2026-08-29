# Assignment: RELEASE-2026-0801-11 — Internal TestFlight First-Run And Scheme Delivery Feedback

**Policy version:** `1.0.0`
**Parent:** [`RELEASE-2026-0801`](release-2026-08-01.md)

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Assignment Pending` |
| **Phase** | Build 7 feedback remains historical; F-02 current-development-build candidate-quality reproduction is established and split into `RIME-BUILTIN-LUNA-QUALITY-001`; F-03 engineering slice is Closed |
| **Non-claims** | The original Build 7 / iPhone 16 Pro / iOS 18 multi-character root cause remains unknown; the later local build is not TestFlight acceptance; the F-02 fix has not entered `Ready` |
| **Next** | Product Lead completes the F-02 repair Assignment roles and immutable offline resource pins; a new TestFlight build is still required for F-03 tester use |
| **Residuals** | [`2026-08-25 internal feedback`](../evidence/release-2026-08-01-11-internal-testflight-feedback-2026-08-25.md) · [`F-02 repair Assignment`](rime-builtin-luna-quality-001.md) · [`F-02 2026-08-29 evidence`](../evidence/rime-builtin-luna-quality-f02-2026-08-29.md) |

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
| `F-02` | Before using 雾凇 or 万象, the reported builtin scheme could commit one Chinese character but failed when composing two or more characters at once | `P1` candidate. A later local build on iPhone 13 Pro / iOS 27 can compose `三角形`, but stable reproduction proves the built-in full table lacks normal preset weighting and ranks rare characters before `你/你好` | Execute [`RIME-BUILTIN-LUNA-QUALITY-001`](rime-builtin-luna-quality-001.md) after roles and immutable offline resource pins are complete; preserve the original Build 7 root cause as `UNKNOWN` until separately reproduced |
| `F-03` | 雾凇 download failed on Mainland China cellular without VPN; the remembered error contained “network”, but the exact text/code was not captured | Product Lead marked **urgent / plan advanced**; blocker for broader external testing where recommended schemes must be obtainable without private network workarounds | Decide and pilot [`RIME-SCHEME-DELIVERY-001`](rime-scheme-delivery-001.md): maintainer-linked Mainland candidates, immutable manifest/SHA-256, bounded endpoint selection, localized error recovery and a region/network matrix. Exact original error remains useful but is no longer a prerequisite for beginning the bounded pilot |

## Gates

- **Entry Criteria:** intake evidence exists; Product priority for `F-03` is
  explicit. Remaining Assignment roles and reproduction facts are `UNKNOWN`, so
  implementation may not enter `Ready`.
- **Exit Criteria:** every finding has reproducible evidence, severity, owner,
  disposition (`fix`, explicit Product acceptance, or tracked debt), regression
  coverage and an exact Build 8-or-later handoff when code changes are required;
  broader external TestFlight has an explicit Gate decision. Download failures
  are presented in Simplified Chinese with an accurate error category and a
  relevant recovery action; sanitized diagnostics preserve enough technical
  classification to distinguish network, server, integrity, storage and
  deployment failures without recording credentials or private input.
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
- **F-03 Delivery Handoff:** [`RIME-SCHEME-DELIVERY-001`](rime-scheme-delivery-001.md)
  and its [`source research`](../evidence/rime-scheme-delivery-source-research-2026-08-25.md).
- **F-02 Repair Handoff:** [`RIME-BUILTIN-LUNA-QUALITY-001`](rime-builtin-luna-quality-001.md)
  and its [`current reproduction/resource audit`](../evidence/rime-builtin-luna-quality-f02-2026-08-29.md).
- **Revalidation Trigger:** build, first-run journey, builtin resources, scheme
  catalog/source URL, checksum/license contract, region/network path, iOS/RIME
  runtime or release-channel change.
