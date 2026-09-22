# TYPO-CORRECTION-002 Simulator QA-001 Run Receipt — Revalidation 03

> **Run ID:** `TC2-SIM-20260919-192740-QA001-REVAL-03`
>
> **Status:** `inconclusive — fresh UI capture completed, but the keyboard
> extension produced no input or sidecar events in the fresh diagnostic window`
>
> **Evidence grade:** `Executor-recorded`

This is a fresh formal QA-001 attempt on the designated Simulator. It does not
establish candidate recovery, explicit selection, a Product/Quality Gate or an
Assignment close. The current result is not converted into a code-failure claim
because the direct product diagnostic route was not observable in this capture.

## Authority and identity

- Assignment: [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md)
- Authorization: [`AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-002`](../authorizations/AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-002.md)
- Case: `TC2-CASE-QA-001` / `TC2-CTR-QA-001`
- Worktree: `/private/tmp/universe-keyboard-typo-correction-002-provenance-sidecar`
- Branch / HEAD: `codex/typo-correction-002-provenance-sidecar` /
  `9eb83158e49218c1e8f75dbe7dd9e0390db81409`
- Simulator: iPhone 17 Pro Max / iOS `27.0`
- Simulator UDID: `06C5BC3E-7599-4761-A1A2-71DAEA991474`
- Host: Messages, conversation `+1 (888) 555-1212`
- Build configuration: Debug, signed Simulator package
- Build/install source: current parent worktree snapshot after the test-only
  coordinate-harness change; no production code was changed by this lane
- Tracked Swift diff SHA-256: `f1e4e17637bf6aaaaf314f882b229d50751792cfafc488f0d2cd8197863c7862`
- Untracked Swift manifest SHA-256: `f0ad8759e22deedaa3d5424280c481b2625c550c29609cc70258e3590861ec9d`

## Package identity

| Package member | SHA-256 |
|---|---|
| Main executable | `6f3ad3ea8e0dccb85af0ddc00c1885f6bb0d4101beee5c71283f976ec882cbba` |
| Main debug dylib | `ce2c05a3e665c3fb3d5eaec15a8a7f4d1b157f7108b39f7cfcd7c7732c25d58a` |
| Keyboard executable | `0ec6b1e8467de8edca3603e3e4db226e1094343f0a70497e4e87ed5d87a07f91` |
| Keyboard debug dylib | `6c7c2d26727a63102987faf07477fae0167271bc98e21093d0ed0473bcdef6d2` |

Build product path:
`/tmp/universe-keyboard-typo-correction-002-qa-perf-reval-20260919-derived/Build/Products/Debug-iphonesimulator/Universe Keyboard.app`

## RIME provenance

The live Simulator App Group provenance file was read before classification and
copied to the raw artifact directory. No FakeCandidateProvider, old Ice
directory or synthetic RIME fixture was used.

| Field | Observed value |
|---|---|
| Active schema | `rime_ice` |
| Artifact identity | `rime-ice-20260630-675d23b0` |
| Artifact version | `2026.06.30` |
| Source variant | `nju` |
| Upstream revision | `6810e8916d160498620a16fef2135956fecbd485` |
| Archive SHA-256 | `675d23b070be00e1b800f9a6db033ef98f4493cd5b568ed8aa3b3541769c46ac` |
| Installed content SHA-256 | `2e906d14853255cd0eba534e2b40791008c2cee65fa5a6e50b40bbd159cb6c26` |
| Provenance receipt ID | `078F7EA2-F9CA-4033-B7DD-48BE636BEB38` |
| Provenance raw SHA-256 | `b6c9a74a747b35997cc4dc67c651443b7dfd610f50fd290f9076760de7865c54` |
| librime | `1.16.1` |
| Runtime smoke / Lua smoke | `true / true` |

## Capture observations

- The operator reported the QA input as entered and paused.
- The current runtime snapshot was Messages with the draft containing the
  declared synthetic composition. The host message was not sent.
- The snapshot reported `下一个键盘 = English (Australia)`. This is compatible
  with Universe Keyboard being current, but it is not by itself sufficient to
  prove the current keyboard's input delivery.
- The screenshot showed the Apple-style keyboard surface and the project debug
  touch overlay. Appearance is not used as the sole identity proof.
- The target candidate `我们今天去公园` was not visible in the captured
  candidate area. No candidate was selected.
- Delete, Space, Return, paging, Partial Commit and switch-away were not run.

## Fresh diagnostic window

Fresh App Group files were captured from:
`/Users/doubleshy0n/Library/Developer/CoreSimulator/Devices/06C5BC3E-7599-4761-A1A2-71DAEA991474/data/Containers/Shared/AppGroup/97142D9B-ED12-4FFE-8C3A-58F175731B4F/Diagnostics/v1/g1/open/`

| Measure | Observed value |
|---|---:|
| Keyboard-extension JSONL lines / bytes | `1 / 334` |
| Keyboard-extension only event | `presentation.appeared` at `2026-09-19T11:31:34Z` |
| `touch.terminal` events | `0` |
| `key_highlighted` events | `0` |
| `typo_correction.sidecar_query` events | `0` |
| Main-app JSONL lines / bytes | `4 / 1742` |
| Main-app events | `2 rime_sync.invoked`, `2 rime_sync.skipped` |
| Candidate selection events | `0 observed` |
| Host send/commit | `0 observed` |

Because the fresh keyboard journal contains no key or sidecar event, the
diagnostic route cannot independently establish that the paused composition was
produced by Universe Keyboard in this capture. The absence of a sidecar event
is therefore not interpreted as a sidecar query failure.

### Post-capture diagnostic-mode audit

A read-only App Group preference audit after capture found
`diagnostics_high_fidelity_expiration = 2026-09-19T10:29:24Z`, earlier than the
fresh keyboard journal timestamp (`2026-09-19T11:31:34Z`). The visible debug
touch overlay was enabled separately, but its presence does not prove that the
high-fidelity journal was active. The persistent `rime_diag_log` preference
contained other diagnostic text, but it has no fresh process/journal boundary
for this Run and was not promoted into current-run evidence.

This explains the observability gap at the evidence-channel level; it does not
prove a product input failure or a missing-candidate failure.

## Preserved artifacts

Raw artifacts are retained outside Git:
`/private/tmp/typo-correction-002-sim-runs/TC2-SIM-20260919-192740-QA001-REVAL-03/raw/`

| File | SHA-256 |
|---|---|
| `keyboard_extension.jsonl` | `6090ddd55322e000a19e1bc9c06e4cb412f6a0c5d38879fe06b84ebc4a528777` |
| `main_app.jsonl` | `28e827151c3d104fd9fd23b1abe574835f679f138bf7f3c45b7c20416c143221` |
| `rime-runtime-provenance.json` | `b6c9a74a747b35997cc4dc67c651443b7dfd610f50fd290f9076760de7865c54` |
| `qa001-03-screenshot.jpg` | `4e4220431b6cf73b4e7b958f74da805e6f58341a1927f2c5841ec3c35ce0fd60` |

## Claim outcomes

| Claim | Outcome | Boundary |
|---|---|---|
| Designated Simulator identity | `pass for environment sub-claim` | Exact iPhone 17 Pro Max / iOS 27 / UDID |
| Exact `rime_ice` provenance | `pass for provenance sub-claim` | Live App Group receipt and installed-content digest |
| Universe Keyboard produced the observed input | `unproven in this capture` | No fresh keyboard-extension input event |
| Target candidate visible | `not established` | Screenshot did not show it; no direct candidate event was emitted |
| Target candidate selected | `not-run` | No candidate selection was performed |
| Interaction regression checks | `not-run` | No candidate was selected and the lane stopped |
| `TC2-CASE-QA-001` | `inconclusive; no pass` | Candidate recovery and keyboard input route were not independently established |
| Paired performance | `not-run` | Separate Authorization and Run ID |

## Non-claims and next boundary

- This receipt does not close QA-001, INT-003, paired performance or any
  Product/Quality/Release Gate.
- It does not claim a product regression or a missing-candidate failure;
  direct input and sidecar observability were absent from the fresh window.
- The QA Authorization is consumed and must not be reused. A retry requires a
  new Authorization and Run ID, and should first restore/verify high-fidelity
  diagnostic emission before asking for another manual input.
