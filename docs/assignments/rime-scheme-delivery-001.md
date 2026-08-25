# Assignment: RIME-SCHEME-DELIVERY-001 — Multi-Endpoint Verified Scheme Delivery

**Policy version:** `1.0.0`
**Parent:** [`RELEASE-2026-0801-11`](release-2026-08-01-11-internal-testflight-feedback.md)

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Assignment Pending` |
| **Phase** | Read-only current-path audit and first-party source research recorded; no provider choice or implementation track has entered `Ready` |
| **Non-claims** | No endpoint has passed an App-use permission, byte-identity, Range/redirect, Mainland China cellular or availability pilot; no CDN/object-storage provider is selected |
| **Next** | Product Lead names Executor/reviewers and authorizes a bounded endpoint pilot; Architecture then reviews manifest trust, integrity and fallback ownership before code work |
| **Residuals** | [`2026-08-25 source research`](../evidence/rime-scheme-delivery-source-research-2026-08-25.md) |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner in the active Codex task,
  `2026-08-25 Asia/Shanghai`, authorized KOS recording and first-party research
  for a lightweight multi-endpoint selection design.
- **Product Approver:** Human Product Owner acting as Product Lead

## Boundary

- **Scope:** downloadable RIME scheme release discovery, equivalent endpoint
  selection, archive integrity verification, retry/fallback behavior, localized
  failure presentation and an evidence-backed Mainland China delivery pilot.
- **Non-goals:** no network request from Keyboard Extension; no probe at App
  launch; no VPN prerequisite; no IP geolocation, SSID collection or carrier
  fingerprinting; no blind public GitHub proxy; no mutable unverified asset; no
  provider purchase, mirror publication or production-code change under this
  pending Assignment.
- **Required Inputs:** exact immutable scheme version and asset, expected byte
  length and SHA-256, candidate endpoints, redistribution/license obligations,
  endpoint-operator permission or acceptable-use evidence, cost/egress boundary,
  HTTP redirect/Range behavior and cross-network pilot results.

## Assignment

- **Domain Owner:** `UNKNOWN` — Product Lead must select RIME delivery ownership.
- **Executor:** Current Codex task for documentation/research only;
  implementation Executor is `UNKNOWN`.
- **Environment Executor:** `UNKNOWN` — must be able to exercise Mainland China
  cellular and Wi-Fi plus at least one non-Mainland path.
- **Human Dependency:** Product Lead approves endpoint operators, recurring cost
  and any external contact or account creation.
- **Architecture Reviewer:** `UNKNOWN` — must review manifest trust, immutable
  identity, fallback and main-App ownership.
- **Quality Reviewer:** `UNKNOWN` — must independently verify byte identity,
  cancellation, timeout, localized errors and network matrix evidence.
- **Handoff Target:** Human Product Owner for Assignment Decision.

## Proposed Delivery Contract

### Immutable manifest

Each downloadable scheme version resolves to one manifest entry containing the
scheme ID, version/tag, asset name, expected byte length, SHA-256, license and
provenance metadata, and an ordered list of endpoints known to serve the same
bytes. A mutable `latest` URL may be used only to discover a version; installation
must bind to an immutable version and digest.

The archive SHA-256 is verified before extraction. A mismatch fails closed,
deletes the temporary artifact and cannot proceed to installation or deployment.
An endpoint response is never trusted merely because it is a valid ZIP or
contains the expected schema filename.

### Lightweight endpoint selection

- Start only after the user explicitly requests a download and satisfies the
  per-scheme license acknowledgement gate.
- Start the preferred endpoint immediately. If it has not produced an acceptable
  response/initial bytes after a short hedge delay, start one fallback in
  parallel; exact delay and byte threshold remain pilot-tuned values.
- At most two endpoints run concurrently. A third endpoint starts only after a
  failure, preventing unnecessary cellular traffic.
- The first task with valid HTTPS/HTTP semantics and a bounded initial byte
  sample continues as the real download; cancel and delete losing tasks.
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
| 雾凇 NJU GitHub Release mirror | **Preferred Mainland candidate for pilot** because 雾凇 upstream links it as “大陆镜像加速” | Operator/App-use acceptability, version lag, exact-version path, Range/redirect behavior, byte identity and Mainland cellular/Wi-Fi evidence |
| 万象 GitHub Release | Existing upstream source; retain as one endpoint | Immutable version URL and published SHA-256 receipt |
| 万象 CNB repository/releases | **Preferred Mainland candidate for pilot** because 万象 upstream links it as its CNB domestic mirror | Stable public asset URL/API, release/tag mapping, Range/redirect behavior, digest parity and Mainland cellular/Wi-Fi evidence |
| Universe-controlled Mainland object storage/CDN | Managed fallback candidate, not selected | Account/cost authorization, redistribution automation, origin protection, observability, retention and ICP/custom-domain requirements |
| GitCode or Gitee mirror owned by Universe | Reserve candidate, not selected | Automated asset sync rather than source-only mirroring, anonymous stable direct download, quotas/terms, digest parity and operational ownership |
| Unnamed GitHub proxy | Rejected from current proposal | Not eligible without operator identity, permission, immutable provenance and independent integrity evidence |

## Gates

- **Entry Criteria:** Product Lead names the implementation Executor,
  Architecture Reviewer, Quality Reviewer and authorized endpoint pilot set.
- **Exit Criteria:** selected endpoints serve byte-identical immutable assets;
  SHA-256 fails closed before extraction; hedged cancellation and bounded traffic
  are tested; Simplified Chinese failure categories are verified; Mainland China
  cellular/Wi-Fi and non-Mainland evidence pass; provider permission, cost and
  retention responsibilities are explicit.
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
