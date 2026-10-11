# Independent Architecture Review: RIME Ice deployment smoke

## Verdict

**Bounded Pass — deployment precondition only.**

本 review 只判断当前 Simulator 包是否有足够证据证明：Main App-owned
RIME deployment 已在 App Group 中完成，且精确的 `rime_ice` runtime
provenance 与 installed-content identity 已绑定。它不扩展为输入法行为、
sidecar、性能或 Product/Quality/Release 结论。

## Review binding

| Field | Value |
|---|---|
| Reviewer | Independent Architecture reviewer |
| Mode | Read-only; no build, install, Simulator action or source edit |
| Review Authorization | [`AUTH-TYPO-CORRECTION-002-RIME-ICE-DEPLOYMENT-SMOKE-ARCHITECTURE-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RIME-ICE-DEPLOYMENT-SMOKE-ARCHITECTURE-001.md) |
| Run ID | `TC2-SIM-20260920-RIME-ICE-SMOKE-01` |
| Capture receipt | [`RIME Ice deployment smoke receipt`](../evidence/typo-correction-002-sim-run-2026-09-20-rime-ice-deployment-smoke-01.md) |
| Capture Authorization | [`AUTH-TYPO-CORRECTION-002-RIME-ICE-DEPLOYMENT-SMOKE-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RIME-ICE-DEPLOYMENT-SMOKE-001.md) |
| Package source snapshot | `3f9f2652b03279a99537639f4382b48bb58548ca` |
| Target | iPhone 17 Pro Max / iOS 27.0 Simulator / `06C5BC3E-7599-4761-A1A2-71DAEA991474` |

## Independent checks

### Exact identity binding

The receipt and Authorization bind the same:

- Run ID and Simulator UDID;
- pre-existing package identity, including all four executable hashes;
- App Group runtime path;
- fresh `rime-runtime-provenance.json` receipt;
- `rime_ice` artifact identity `rime-ice-20260630-675d23b0`;
- pinned archive SHA-256 and upstream revision;
- installed-content SHA-256 and 70-file manifest.

No stale Luna-only or synthetic fixture identity is used as the deployment
proof.

### Deployment boundary

The evidence is consistent with the repository boundary that deployment is
Main-App-owned and the keyboard Extension consumes the resulting runtime
state. The live App Group preference state reports deployed, not deploying,
and no further deployment required. The deployment log records schema
compilation, dictionary readiness and `3 tasks ran: 3 success, 0 failure`.

The independently recorded live-tree check found all 70 admitted files with
matching byte counts and per-file hashes, and recomputed the same aggregate
installed-content digest as the runtime receipt. This supports a bounded
post-deployment content identity, not merely a UI label.

### Architecture disposition

There is no blocking Architecture finding within this setup-smoke scope.
The UI state, runtime receipt, App Group preferences and deployment terminal
evidence form a coherent bounded chain:

`selected scheme → Main-App deployment → App Group receipt → active schema`

That chain does not imply that every subsequent keyboard query or keystroke
uses a particular route.

## Residual

| ID | Disposition |
|---|---|
| AR-01 | The pinned archive SHA is carried by the fresh runtime receipt, but this smoke did not separately export and re-hash the downloaded archive file. Accepted as a provenance-detail residual; it does not block the bounded deployment-precondition Pass. |

## Non-claims

- No sidecar query route, candidate count or candidate text conclusion.
- No INT-003 cancellation or 180 ms cadence conclusion.
- No QA-001 candidate visibility, selection or interaction conclusion.
- No paired baseline/treatment or end-to-end performance conclusion.
- No physical-device signing, VoiceOver or nine-key conclusion.
- No Product Gate, Quality Gate, TestFlight, Release, merge or parent
  Assignment closure.

## Handoff

The receipt is suitable for a separate independent Quality read-only review.
Any later QA-001, INT-003 or paired-performance capture still requires its
own Authorization and fresh Run ID.
