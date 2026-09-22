# TYPO-CORRECTION-002 Physical Device Run Receipt — Direct Sidecar Observed

> **Run ID:** `TC2-PHYS-20260917-232938-INT003-02`
>
> **Status:** Recorded as supplemental physical-device evidence; formal
> INT-003 remains inconclusive; no gate closed
>
> **Evidence grade:** `Executor-recorded`
>
> **Scope:** Authorized physical-device supplemental arm for
> `TC2-CASE-INT-003` only. This receipt does not replace the designated iOS 27
> iPhone 17 Pro Max simulator and cannot close QA-001, paired performance,
> Product, Quality, TestFlight, Release or merge gates.

This receipt records a manually operated physical-device capture after a new
signed build was installed. It establishes that the running physical keyboard
performed provenance-bound direct sidecar queries and that the query events are
observable without user-input or candidate text. It does not promote the
operator's raw composition as an independently retained UI snapshot.

## Authority and Identity

- Assignment: [`TYPO-CORRECTION-002`](../assignments/typo-correction-002.md)
- Device evidence owner: [`TYPO-CORRECTION-002 Device Hub Validation Record`](typo-correction-002-device-hub-validation.md)
- Case registry: [`TYPO Benchmark Registry V2`](../TYPO_BENCHMARK_REGISTRY_V2.md)
- Source baseline: `9eb83158e49218c1e8f75dbe7dd9e0390db81409`
- Collection date: 2026-09-17, Asia/Shanghai
- Implementation source was the uncommitted isolated worktree; the main
  checkout was not modified by this capture.

## Run Header

| Field | Observed value | Provenance / boundary |
|---|---|---|
| Device | iPhone 13 Pro (`iPhone14,2`) | `xcrun devicectl device info details` |
| Device UDID | `00008110-000A08440198801E` | `xcrun xctrace list devices` / `devicectl` |
| OS | iOS `27.0`, build `24A437` | `devicectl` |
| Device reality | Physical, wired, paired, Developer Mode enabled | `devicectl` |
| Host application | Messages | Operator capture context |
| Host conversation | `+1 (888) 555-1212` | Deterministic repository test conversation |
| Universe Keyboard active | Human operator confirmed | AX label is not treated as keyboard identity |
| Full Access | Human operator confirmed | Not inferred from AX |
| High-fidelity diagnostics | Enabled by operator; content-free route events exported | Operator confirmation and device export |
| Signed build run | `TC2-PHYS-20260917-232938-SIGN-03` | Signed Debug build / automatic provisioning |
| Main executable SHA-256 | `ee9ea36026c2b11ec7b0b56f184637bc9c81a49e600b576243194060b1d4ccd0` | Derived physical product |
| Keyboard executable SHA-256 | `e57b62b8472607944dca3908d096919ddbdd4f3f24f5b71c216acda5c03db290` | Derived physical product |
| Team identifier | `C33N6HTS9N` | Signed main app and extension |
| App Group entitlement | `group.com.DoubleShy0N.Universe-Keyboard` | Signed main app and extension |
| Installation | Succeeded; database UUID `7F969E4A-E1A9-4AEF-BC90-81CAC125F237` | `devicectl device install app` |

## RIME Provenance Boundary

Before input, the operator opened the signed main App on this same physical
device and confirmed `rime_ice` / 雾凇拼音 showed `已部署`. The diagnostic
export then independently reported the following runtime identity on direct
sidecar events:

| Field | Observed value | Boundary |
|---|---|---|
| Active schema on sidecar events | `rime_ice` | Runtime diagnostic payload |
| Runtime provenance receipt ID | `d33f42e6-1f2b-46fe-8a71-f7f5b8d8f30f` | Same on all 11 sidecar events |
| Direct route | `real_rime_sidecar` | Same on all 11 sidecar events |
| Main-App deployment status | `已部署` | Human operator confirmation |
| Artifact identity ID | `rime-ice-20260630-675d23b0` | Catalog identity for the displayed version/archive |
| Artifact version | `2026.06.30` | Physical provenance screen |
| Download source | 南京大学开源镜像 | Physical provenance screen |
| Upstream revision | `6810e8916d160498620a16fef2135956fecbd485` | Physical provenance screen |
| Archive size | `16.1 MB` | Physical provenance screen |
| Archive SHA-256 | `675d23b070be00e1b800f9a6db033ef98f4493cd5b568ed8aa3b3541769c46ac` | Physical provenance screen; `SHA-256 已验证` |
| Runtime smoke fields | `UNKNOWN` in this receipt | Not present in formatted export or screenshot |

The Simulator receipt is not reused for this physical device. The runtime
receipt ID proves that the physical sidecar was bound to a non-nil provenance
receipt, while the physical provenance screen supplies the displayed version,
upstream revision and archive digest. The raw physical receipt JSON and its
own file digest were not independently copied, so this receipt does not claim
the receipt's full manifest or runtime-smoke fields.

## Observed Scenario

The operator manually entered the repository-declared synthetic composition
`wimenjintianquhongyuan` through the visible Universe Keyboard and paused. No
candidate selection or send action was performed. The operator's composition
claim is retained as an execution note only; this export contains no
content-bearing snapshot from which to independently promote the raw
composition.

## Content-Free Diagnostic Segment

The bounded capture segment is `23:35:42` through `23:35:49` in the device
export. The raw export is formatted text, but the new formatter preserves the
typed route and sidecar identity fields without input or candidate text.

| Event / marker | Count | Meaning / boundary |
|---|---:|---|
| `touch.terminal` | 44 | Visible key lifecycle activity; no key labels or input text |
| `rime.owner.published` | 22 | Owner/UI publication activity; not provenance proof |
| `ui.applied` | 22 | Candidate/UI application activity |
| `candidate.visibility_changed` | 27 | Candidate-bar visibility/count changes |
| `typo_correction.query_route` | 1 | Route marker reported `unavailable` in this segment; not used as sidecar proof |
| `typo_correction.sidecar_query` | 11 | All 11 were valid direct sidecar observations |
| `candidate.selection_delivered` | 0 | No candidate selection observed |
| `input.action` | 0 | No send/commit action observed |

### Direct sidecar observations

- All 11 events report `route=real_rime_sidecar`.
- All 11 events report `schema=rime_ice` and the same runtime receipt ID
  `d33f42e6-1f2b-46fe-8a71-f7f5b8d8f30f`.
- Content-free input-length markers are `15` and `22`; the raw strings are
  never retained in this evidence.
- Sequence ranges are `171–174` and `287–293`.
- Every event reports `results=3` and `outcome=returned`.
- Reported latency is `1–4 ms`.
- `live_valid_before` and `live_valid_after` are `true`; the live and sidecar
  session markers are unchanged within each event.

This establishes the direct sidecar seam and its content-free observability on
the physical device. It does not establish that the formal rapid-typing
stimulus occurred: the display export has only second-resolution timestamps
for `touch.terminal` events, and no cancellation outcome was recorded.

## Claim Outcomes

| Claim | Outcome | Evidence / boundary |
|---|---|---|
| New signed build installed and launched on the physical device | `pass` for this bounded sub-claim | `devicectl` install and process launch succeeded |
| Universe Keyboard was manually active with Full Access | `pass` for operator precondition | Human confirmation |
| Physical main App showed `rime_ice` / 雾凇拼音 / `已部署` | `pass` for operator deployment attestation | Human confirmation; no screenshot or raw receipt file retained |
| Direct real-RIME sidecar query is observable | `pass` for this bounded sub-claim | 11 valid content-free events with `real_rime_sidecar` route |
| Sidecar query is bound to a physical runtime receipt | `pass` for this bounded sub-claim | Same non-nil receipt ID on all sidecar events |
| Sidecar query preserves the live session within the observed calls | `pass` for this bounded sub-claim | Valid live/sidecar markers and unchanged per-event session markers |
| Physical archive identity and archive digest are independently proven | `pass` for this bounded sub-claim | Physical provenance screen shows version, upstream revision, archive SHA-256 and `SHA-256 已验证`; runtime sidecar carries the same schema-bound receipt ID |
| Full physical runtime receipt manifest is independently captured | `not established` | Raw `rime-runtime-provenance.json` and runtime-smoke fields were not exported |
| Raw composition survives without automatic mutation | `not independently promoted` | Operator paused after entry; no content-bearing snapshot is retained |
| `TC2-CASE-INT-003` rapid-typing stale-work cancellation | `inconclusive; not a formal pass` | No sub-second touch cadence or cancellation outcome in this export |
| `TC2-CASE-QA-001` candidate selection | `not-run` | No candidate was selected and no message was sent |
| Paired candidate-refresh performance case | `not-run` | No paired performance capture |

## Preserved Artifacts

Raw artifacts are retained outside Git:

`/private/tmp/typo-correction-002-phys-runs/TC2-PHYS-20260917-232938-INT003-02/raw/post/`

| File | SHA-256 | Source / note |
|---|---|---|
| `pre/rime-provenance-screen.png` | `d8a00694ecf1d084011f23e2cd3080788f3ed3535e3d4eb21bd6f4c6b5fbd568` | Physical App `版本与下载来源` screen; 1170×2532 PNG |
| `diagnostics-export-device.txt` | `f830222cd54a12aa42d95917a23409b73c8fc8f6e63f6f96b76ccdaa8748d66a` | Pulled from physical-device clipboard with `devicectl` |
| `diagnostics-export.txt` | `f830222cd54a12aa42d95917a23409b73c8fc8f6e63f6f96b76ccdaa8748d66a` | User-provided pasted attachment; byte-identical to device copy |
| `paste-error.log` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | Empty stderr artifact |

The two diagnostic exports are both 402 lines and 39,529 bytes; `cmp` passed.
The raw export contains route, schema, receipt, sequence, result-count and
latency fields only for typo-correction evidence; it does not contain the
synthetic input text or candidate strings.

## Next Required Action

The direct sidecar observability and physical archive identity/digest
sub-claims are now established. If a full provenance-manifest claim is
required, separately export the physical `rime-runtime-provenance.json`
through an authorized app-owned path to capture its receipt contents and
runtime-smoke fields. Do not reuse the Simulator receipt and do not repeat
input solely to obtain that manifest.

This supplemental physical receipt does not close `TC2-CASE-INT-003`,
`TC2-CASE-QA-001` or the paired performance case. No Product, Quality,
TestFlight, Release, merge or Assignment conclusion is made by this receipt.
