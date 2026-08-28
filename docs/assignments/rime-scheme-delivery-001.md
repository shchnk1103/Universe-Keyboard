# Assignment: RIME-SCHEME-DELIVERY-001 — Multi-Endpoint Verified Scheme Delivery

**Policy version:** `1.0.0`
**Parent:** [`RELEASE-2026-0801-11`](release-2026-08-01-11-internal-testflight-feedback.md)

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Closed` |
| **Phase** | Human Product Gate Passed；PR #83 merged `e9aea57` |
| **Non-claims** | Not TestFlight upload; not external Beta Review; not App Store; not GitHub-source proof |
| **Next** | New TestFlight Build 8 requires a separate Human upload authorization |
| **Residuals** | GitHub source untested (`accept`) · endpoint acceptable-use (`accept`) · unzip independent review skipped by merge AUTH (`accept`) · [`integrity Assignment`](rime-scheme-delivery-integrity-001.md) · [`Gate`](../product-decisions/RIME-SCHEME-DELIVERY-001-product-gate.md) · [`success evidence`](../evidence/rime-scheme-delivery-wanxiang-success-2026-08-28.md) |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner in the active Codex task,
  `2026-08-25 Asia/Shanghai`, authorized KOS recording and first-party research
  for a lightweight multi-endpoint selection design; later accepted
  [`PD-RIME-SCHEME-DELIVERY-001-SOURCE-VARIANTS`](../product-decisions/RIME-SCHEME-DELIVERY-001-source-variants.md),
  with no Universe-operated server or CDN.
- **Product Approver:** Human Product Owner acting as Product Lead

## Boundary

- **Scope:** downloadable RIME scheme release discovery, equivalent endpoint
  selection, archive integrity verification, retry/fallback behavior, localized
  failure presentation and an evidence-backed Mainland China delivery pilot.
- **Non-goals:** no network request from Keyboard Extension; no probe at App
  launch; no VPN prerequisite; no IP geolocation, SSID collection or carrier
  fingerprinting; no blind public GitHub proxy; no mutable unverified asset; no
  provider purchase or Universe-operated mirror/CDN; no push, merge, release
  distribution or Beta Review submission under this execution authorization.
- **Required Inputs:** exact immutable scheme version and asset, expected byte
  length and SHA-256, candidate endpoints, redistribution/license obligations,
  endpoint-operator permission or acceptable-use evidence, cost/egress boundary,
  HTTP redirect/Range behavior and cross-network pilot results.

## Assignment

- **Domain Owner:** Main App UI — download/install/deploy orchestration under the
  permanent ownership route in `READING_MAPS.md`.
- **Executor:** Current Codex task — production implementation, automated tests
  and KOS evidence within the authorized scope.
- **Environment Executor:** Current Codex task — local build, Simulator and
  current-Mac public-endpoint evidence only.
- **Human Dependency:** Human Product Owner — Mainland China cellular/Wi-Fi
  evidence, any required device action and final Product Gate.
- **Architecture Reviewer:** Independent AI subagent `architecture_review` —
  manifest trust, installed-content identity, fallback, concurrency and main-App
  ownership review; no implementation edits.
- **Quality Reviewer:** Independent AI subagent `quality_review` — cancellation,
  timeout, integrity, localized errors, tests and evidence review; no
  implementation edits.
- **Handoff Target:** Human Product Owner for Mainland evidence and Product Gate.

## Proposed Delivery Contract

### Architecture pre-review disposition

The independent `architecture_review` subagent returned **Pass with
conditions** before implementation. P0 conditions are binding for this slice:
an in-App immutable manifest; source-specific archive size/SHA-256 and redirect
host policy; unique temporary downloads with real URLSession cancellation;
variant-isolated identity (this implementation may omit ETag/cache reuse rather
than share it); safe ZIP paths; deterministic post-processed installed-content
allowlist identity; operation-generation checks; and success/source receipts
persisted only after deployment succeeds.

This Assignment does **not** expand into TD-001 atomic installation. Existing
file-by-file install/rollback risk remains open and must not be described as
resolved. The slice adds verification before the existing install commit and
retains the current explicit recovery path.

### Immutable manifest

Each downloadable scheme version resolves to one manifest entry containing the
scheme ID, version/tag, asset name, expected byte length, SHA-256, license and
provenance metadata, and an ordered list of endpoints known to serve the same
bytes. A mutable `latest` URL may be used only to discover a version; installation
must bind to an immutable version and digest.

If upstream-operated sources publish non-identical archives that have been
validated to stage the same selected runtime content, they are separate source
variants rather than equivalent endpoints. Each variant must carry its own
source label, tag, source commit/revision, byte length and archive SHA-256. A
separate installed-content identity must enumerate or hash the exact files that
are allowed to reach the shared RIME staging area. A shared visible tag alone is
not sufficient identity.

The archive SHA-256 is verified before extraction. A mismatch fails closed,
deletes the temporary artifact and cannot proceed to installation or deployment.
An endpoint response is never trusted merely because it is a valid ZIP or
contains the expected schema filename.

### Lightweight endpoint selection

- Start only after the user explicitly requests a download and satisfies the
  per-scheme license acknowledgement gate.
- Start the preferred endpoint with a bounded header-only reachability request.
  If it has not produced an acceptable response after a 250 ms hedge delay,
  start one fallback in parallel. No response body is sampled during selection.
- At most two endpoints run concurrently. A third endpoint starts only after a
  failure, preventing unnecessary cellular traffic.
- The first task with valid HTTPS/HTTP semantics, an allowed final host and a
  compatible declared size becomes the real download source; cancel the losing
  probe before starting the archive download.
- Cache the successful endpoint only for the same scheme/version and broad path
  class (cellular or Wi-Fi), with bounded expiry. Do not store SSID, precise
  location, IP-derived region or carrier identity.
- A mid-transfer failure may retry another endpoint, but every completed archive
  must pass the same SHA-256 gate.

This is reachability selection, not a synthetic bandwidth benchmark. It should
not add a separate full-size test download or block the UI before the user has
asked to download.

### Error presentation

Map transport and local failures into stable Simplified Chinese categories with
the relevant recovery action: offline/unreachable, timeout or temporary server
failure, all endpoints unavailable, integrity failure, storage/extraction and
deployment. Raw system descriptions are diagnostic detail, not primary UI copy.
Sanitized local diagnostics may retain endpoint ID/host, operation phase and
error domain/code; credentials, private input and sensitive query values remain
forbidden.

## Candidate Source Disposition

| Scheme / candidate | Current disposition | Required pilot before selection |
|---|---|---|
| 雾凇 GitHub Release | Existing upstream source; retain as one endpoint | Immutable version URL, SHA-256 receipt and failure classification |
| 雾凇 NJU GitHub Release mirror | **Technical pilot passed only for exact `nightly build` path**; current bytes matched GitHub SHA-256 and Range worked. `LatestRelease` returned different bytes and is ineligible | Operator/App-use acceptability, mutation/lag monitoring and Mainland cellular/Wi-Fi evidence |
| 万象 GitHub Release | Existing upstream source; retain as one endpoint | Immutable version URL and published SHA-256 receipt |
| 万象 CNB repository/releases | Public fixed-tag asset, redirect, Range and its own digest passed. Same-tag ZIP differs from GitHub, but all shared ordinary-Wanxiang runtime files are byte-identical; CNB adds three separate `wanxiang_pure` files and has a different README | Product/Architecture must decide explicit source-variant semantics, bind both archive receipts plus one guarded installed-content identity, decide handling of Pure extras, and then run Mainland cellular/Wi-Fi evidence |
| Universe-controlled Mainland object storage/CDN | **Rejected from this Assignment by Product Owner**; no additional server purchase or operation | Re-entry requires a new explicit Product Decision |
| GitCode or Gitee mirror owned by Universe | Reserve candidate, not selected | Automated asset sync rather than source-only mirroring, anonymous stable direct download, quotas/terms, digest parity and operational ownership |
| Unnamed GitHub proxy | Rejected from current proposal | Not eligible without operator identity, permission, immutable provenance and independent integrity evidence |

## Gates

- **Entry Criteria:** Product Lead names the implementation Executor,
  Architecture Reviewer, Quality Reviewer and authorized endpoint pilot set.
- **Exit Criteria:** each selected archive has immutable source-specific
  identity and SHA-256; equivalent endpoints serve the same archive bytes, while
  any accepted source variants also converge on one explicitly verified guarded
  installed-content identity; SHA-256 fails closed before extraction; hedged
  cancellation and bounded traffic are tested; Simplified Chinese failure
  categories are verified; Mainland China cellular/Wi-Fi and non-Mainland
  evidence pass; endpoint permission and operational ownership are explicit.
- **Stop Conditions:** missing digest; a mirror returns different bytes; a probe
  runs from Keyboard Extension or before user download intent; user/network
  fingerprinting expands beyond path class; provider terms/permission remain
  unresolved; or a fallback silently changes scheme version.

## Handoff

- **Required Handoff Content:** manifest sample, endpoint/operator evidence,
  version/digest receipts, pilot commands/results, traffic and timeout bounds,
  localized error mapping, privacy review, tests, rollback and release impact.
- **Revalidation Trigger:** scheme version/asset, endpoint/operator, manifest
  origin/signing, license/provenance, redirect/Range behavior, iOS networking or
  release-channel change.

## Execution Evidence

The implementation, immutable artifact receipts, post-processed content
digests, Pure-file exclusion, automated results and Xcode 27 beta Environment
Gate are recorded in
[`rime-scheme-delivery-implementation-2026-08-25.md`](../evidence/rime-scheme-delivery-implementation-2026-08-25.md).

Architecture P0 conditions are implemented: source-specific immutable
identity, bounded hedged selection with cancellation, unique temporary paths,
redirect allowlists, archive size/SHA validation before extraction, safe ZIP
paths, deterministic post-processed allowlist identity, operation-generation
checks, and post-deployment receipts. This does not close TD-001.

The independent `quality_review` subagent returned **Pass with conditions; no
new P0 blocker**. Its P1 findings were handled before handoff: selection is
explicitly capped at two probes, the details UI shows the complete URL,
revision, archive size and SHA-256 receipt, and installed-source display now
reads only the persisted post-deployment receipt rather than an active failed
attempt. Stable full-App CI and the Human Mainland matrix remain Exit Gates.

## 2026-08-26 Physical-Device Integrity Residual

A subsequent Human physical-device attempt showed Wanxiang stopping with the
generic integrity-failure message. Current endpoint artifacts still match their
source-specific archive receipts and converge on the guarded staged-content
receipt, so the CNB-only Pure files are not established as the cause. The
selected source, exact build and failing integrity phase were not captured.

The earlier reviews remain historical conclusions over their reviewed diff;
they do not close this newly observed Product/Release residual. PR #83 must not
pass the scheme-delivery Product Gate until
[`RIME-SCHEME-DELIVERY-INTEGRITY-001`](rime-scheme-delivery-integrity-001.md)
is reviewed and dispositioned. See the
[`failure evidence`](../evidence/rime-scheme-delivery-wanxiang-integrity-failure-2026-08-26.md).

## History

- `2026-08-28 Asia/Shanghai` — Human Product Owner authorized merge of PR #83
  after hosted full-path `33174305736` on `388bfd2` and CNB device success
  `38b5a8d3-…`. PR merged `e9aea57`. GitHub-source and endpoint acceptable-use
  accepted as residuals. TestFlight upload remains unauthorized. Assignment
  Closed.
