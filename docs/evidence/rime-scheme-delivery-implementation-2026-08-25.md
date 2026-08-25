# RIME Scheme Delivery Implementation Evidence — 2026-08-25

**Assignment:** [`RIME-SCHEME-DELIVERY-001`](../assignments/rime-scheme-delivery-001.md)
**Environment:** macOS 27 beta, Xcode 27 beta, iOS 26.0 `iPhone 17 Pro`
Simulator (`8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2`)
**Authority boundary:** local implementation and verification only; no push,
merge, TestFlight distribution or Beta Review submission.

## Implemented Contract

- The Main App owns all probing, downloading, verification, extraction,
  installation and deployment. The Keyboard Extension does not issue network
  requests.
- Probing starts only after an explicit download action. It uses bounded,
  header-only `HEAD` requests, starts one fallback after a 250 ms hedge,
  explicitly limits selection to two probes and cancels the loser. It samples
  no body bytes; the actual archive download begins only after a source wins.
- The manifest is compiled into the App. Each source variant carries an exact
  URL, source label, upstream revision, expected byte count, archive SHA-256 and
  redirect-host allowlist. There is no mutable GitHub API discovery or shared
  ETag/archive cache.
- The downloaded regular file must match both byte count and streaming SHA-256
  before extraction. ZIP traversal, absolute paths, backslashes, drive-style
  paths, duplicate paths and symlinks are rejected.
- Extraction uses a unique operation directory. Only the installation
  allowlist reaches staging. After T9 compatibility and Lua post-processing, a
  deterministic path/size/content digest must match the manifest before the
  existing installation/deployment path runs.
- The successful source, version and staged-content digest are persisted only
  after deployment succeeds. Settings read only that installed receipt and show
  its version, source label, complete URL, upstream revision, archive size and
  SHA-256. A failed active attempt cannot overwrite this display. User-facing
  failures use stable Simplified Chinese categories rather than raw system
  error text.

## Frozen Artifact Receipts

| Scheme / source | Version / revision | Bytes | Archive SHA-256 |
|---|---|---:|---|
| 雾凇 / NJU exact nightly path | `nightly`; archive digest prefix provenance | `16,041,786` | `f60aa4f3bf5bcae5f49697cd529fa0c990c91f7349acd350073bcae75ff7410f` |
| 雾凇 / GitHub release | `nightly`; same archive bytes | `16,041,786` | `f60aa4f3bf5bcae5f49697cd529fa0c990c91f7349acd350073bcae75ff7410f` |
| 万象 / CNB | `v17.5.9`; `9f0bd587f886132b1b1dabfd81fd0dcf60a5f8be` | `35,027,247` | `9bfcf60e62d85dd168cd2748e5b2d126fcb3355939969eb80455ba71cbf67732` |
| 万象 / GitHub | `v17.5.9`; `7aefc0cc38e744e33cd18e6abd5996c00a8d2c5a` | `35,020,530` | `73f8c9da0f09b982629aae3cbc4a8ca33640e1bdaf7557ded49b71f94b7b2c87` |

The post-processed allowlisted content identities are:

| Scheme | Lua enabled | Lua disabled |
|---|---|---|
| 雾凇 | `1b42482113be8973869efe66f0d95e7b48bfb2d2af7e6b7cd7c94aa988fca17d` | `2d6b9355c0719a60fbabb4c7b061a5b718e5edefc2f778c72799d91e23f9447c` |
| 万象 | `5b182801298152236c790e29fd190d41b509c7da373babb0c02e65fa4eaf07cf` | `289929084bd8ebc751a9ef9e936327331bf14670be5eeae4722221c0bf810682` |

The two Wanxiang archives intentionally have separate archive receipts. They
converge only after the guarded allowlist and post-processing boundary.

## Wanxiang Pure Files

The three files previously referred to as “Pura” are actually the CNB-only
`Pure` alternative-scheme support files:

- `custom/wanxiang_pure.schema.yaml` defines the separate
  `schema_id: wanxiang_pure`, described upstream as an LTS, no-English,
  no-reverse-lookup, no-Lua compatibility scheme for Windows 7 and fcitx4-rime.
- `custom/wanxiang_pure.dict.yaml` is that scheme's dictionary manifest and
  imports the shared `dicts/*.pro` tables.
- `custom/wanxiang_pure.custom.yaml` is a user-root patch template for spelling
  algebra, custom phrases and candidate page size.

Universe currently selects the ordinary `wanxiang` full-pinyin scheme, not
`wanxiang_pure`. The installation plan excludes `custom/`, so these optional
files never reach the RIME staging area. The staged-content test proves that
adding this unadmitted payload does not alter the installed-content identity,
while modifying an admitted runtime file does.

## Verification Results

| Gate | Result |
|---|---|
| Swift format lint for every changed Swift file | Pass |
| `swift test --package-path Packages/KeyboardCore` | Pass: `1058` tests, `0` failures |
| New ZIP extraction safety tests | Pass as part of KeyboardCore |
| `SchemaArtifactSecurityTests` | Pass: `6` tests, `0` failures; final result bundle `Test-Universe Keyboard-2026.08.25_14-07-09-+0800.xcresult` |
| Pinned-version SchemaManager tests reached before host crash | Pass: three new pinned-version tests plus five preceding deployment/license tests |
| `RimeBridgeTests` | Pass: `68` tests, `20` existing conditional skips, `0` failures |
| Main App Debug simulator build | Pass |
| Main App Release simulator build | Pass |
| `git diff --check` | Pass |

## Independent Review

- Architecture review: **Pass with conditions**. All P0 conditions for this
  slice are implemented; TD-001 atomic file installation remains explicitly
  outside scope and open.
- Quality review: **Pass with conditions; no new P0 blocker**. Before handoff,
  the implementation explicitly capped probing at two sources, expanded the UI
  to the complete artifact receipt, separated installed-source display from the
  active attempt and aligned the Pure fixture with the three real filenames.
- Quality residuals remain Gates rather than inferred passes: real downloader
  cancellation/redirect/operation-generation integration coverage, the complete
  stable-Xcode App suite, Human Mainland cellular/Wi-Fi evidence and endpoint
  acceptable-use conclusion.

The complete Main App test action and two App-hosted receipt tests could not
produce a valid assertion result on this environment. Xcode 27 beta repeatedly
terminated the test host with `malloc: pointer being freed was not allocated`
and also reported an incompatible host `IOHIDLib` (`arm64e` available, `arm64`
required). The same crash also affected pre-existing download/store tests; it
occurred before the affected receipt tests reached assertions. The interrupted
full-class result bundle is
`/tmp/UniverseKeyboard-RimeDelivery-SchemaManager-DD/Logs/Test/Test-Universe Keyboard-2026.08.25_13-44-55-+0800.xcresult`.
This is recorded as an Environment Gate, not as a passing test and not as a
product assertion failure. Stable Xcode/CI must rerun the complete App suite.

## Open Gates and Non-Claims

- Mainland China cellular and Wi-Fi download/install/deploy evidence remains a
  Human Dependency. Current-Mac endpoint timings do not close it.
- Endpoint operator/App-use acceptability remains a Product/operational Gate.
- TD-001 atomic installation is still open. This slice verifies content before
  the existing file-by-file install path and does not claim atomic commit or
  rollback has been solved.
- No Release Candidate freeze, upload, TestFlight grouping or distribution is
  authorized by this Assignment.
