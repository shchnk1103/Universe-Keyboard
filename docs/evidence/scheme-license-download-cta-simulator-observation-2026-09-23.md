# SCHEME-LICENSE-DOWNLOAD-CTA-001 — Human-attested Simulator observation

**Observed / reported:** `2026-09-23 Asia/Shanghai` (exact observation time not stated)\
**Assignment:** [`SCHEME-LICENSE-DOWNLOAD-CTA-SIMULATOR-OBSERVATION-001`](../assignments/scheme-license-download-cta-simulator-observation-001.md)\
**Authorization:** [`AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-SIMULATOR-OBSERVATION-001`](../authorizations/AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-SIMULATOR-OBSERVATION-001.md)\
**Grade:** Human-attested, based on the Human Product Owner's in-session report. **Not** Device-attested.

## Observer and statement

**Observer:** Human Product Owner.\
**Recorder:** Current Codex task.

The user reported: 「三个首次下载入口都没有问题」。This was reported immediately after discussion of manually running the worktree build in Simulator. The three routes in the current product scope are the settings detail, activation guide, and nine-key installation entry points.

This record preserves that bounded report. The user did not itemize the exact taps or resulting sheet/download state for each route, so it does not claim manual verification of every acceptance, dismissal, or completed-download behavior.

## Bound engineering context

| Field | Value |
|---|---|
| Worktree | `/private/tmp/universe-keyboard-scheme-license-download-cta-001` |
| Branch | `grok/scheme-license-download-cta-001` |
| `HEAD` | `80091f35cc5411b292eca78662f39e2b91694045` |
| Reviewed implementation package | 22-file SHA-256 `4f097b709ef993b0c81eb879f8d093c99213ae766c8397582a67ff1ada5f9f3e` |
| Simulator model / OS | Not explicitly confirmed by the user; the previously recommended iPhone 17 Pro / iOS 26.0 is not treated as observed fact |
| Built/installed executable identity | Not captured; no build log, installed-binary hash, or screenshot was supplied |

The source binding is contextual to this task and the specified worktree. It is not cryptographic proof that the observed installed payload exactly matched the 22-file package.

## Claim boundary

This record supports only the Human Product Owner's reported observation that the three first-download entry points had no apparent issue in the Simulator context described above. It does not claim Device-attested behavior, a complete manual test of the license-sheet side effects, successful real network downloads, real RIME deployment, independent Quality beyond the separately linked [Quality revalidation receipt](../reviews/scheme-license-download-cta-quality-revalidation-001.md), Product Gate, commit, push, merge, TestFlight, or Release.
