# TYPO-CORRECTION-002 Simulator QA-001 Run Receipt — Revalidation 08 (fresh package)

> **Run ID:** `TC2-SIM-20260922-183859-QA001-REVAL-08`
>
> **Status:** `target observed — Human-attested visible and selectable (candidate bar position 2)`
>
> **Evidence grade:** `Executor-recorded` plus Human Product Owner candidate observation; independent Architecture/Quality review **not** requested under this Authorization

## Binding

- Authorization: [`AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-08-FRESH-PACKAGE-001`](../authorizations/AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-08-FRESH-PACKAGE-001.md) — live/consumed `2026-09-22T18:40:00+08:00`
- Assignment: [`TYPO-CORRECTION-002-QA001-REVALIDATION-08-FRESH-PACKAGE-001`](../assignments/typo-correction-002-qa001-revalidation-08-fresh-package-001.md)
- Parent: [`TYPO-CORRECTION-002`](../assignments/typo-correction-002.md) — Lifecycle **Active** (this child does not close it)
- Related lane: [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md)
- Case: `TC2-CASE-QA-001` / `TC2-CTR-QA-001` (observation slice only)
- Install source tip: `e1b28aebe8f6b2f2a8587db1e525e332aa9bfe00` (PR #144 squash merge onto `main`)
- Hosted CI binding **A**: push run [`35715351145`](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/35715351145) · headSha `e1b28ae…` · conclusion `success` (includes `final-quality-gate`)
- Simulator: iPhone 17 Pro Max / iOS 27 / `06C5BC3E-7599-4761-A1A2-71DAEA991474`
- Host: Messages · `+1 (888) 555-1212`; message not sent
- Phrase: `wimenjintianquhongyuan`
- Target candidate: 「我们今天去公园」
- Forbidden reuse avoided: not reval-07 package `3f9f2652…` / not Run `TC2-SIM-20260920-224421-QA001-REVAL-07`

## Fresh package identity

Built and freshly installed from tip `e1b28ae…` in isolated worktree
`/Users/doubleshy0n/.codex/worktrees/typo-correction-002-qa001-reval-08-docs/Universe Keyboard`
into derived data `/private/tmp/universe-keyboard-qa001-reval-08-e1b28ae`
(Debug-iphonesimulator, destination-bound, local ad-hoc “Sign to Run Locally”).

Prior app on the same UDID was uninstalled before install (`simctl uninstall` then `simctl install`). Installed at `2026-09-22T18:39:17+08:00`.

| Package member | SHA-256 |
|---|---|
| App executable | `927bfcbbb7e75a55dc045c6863e0cd1e6a4a9f55348464740ee0d0a709ca4273` |
| App debug dylib | `5229565e7fd6757149bdf009d277c7f07b499cfaae0096b20c4ed54e9b90ec37` |
| Keyboard executable | `22539e904e18f2d91b17b575fe1eb96b90022f40c0c8afb9360660a55298d41a` |
| Keyboard debug dylib | `f35d92acb06a4b36c5886071b89bbe5005640e23bca7f78c86b120a08093fd5a` |

These hashes differ from the reval-07 App executable hash `9f1c360d…`.

## RIME / schema environment

Post-install App Group (new container after fresh install):

`group.com.DoubleShy0N.Universe-Keyboard` →
`…/AppGroup/0469C0D3-0C89-4988-BD85-314F03EC34B3`

Human reported UI「已部署 / 配置已生效」. App Group preferences corroborate a successful Main-App deploy of pinned Ice on this tip:

| Preference / signal | Observed |
|---|---|
| `rime_deployed` | `true` |
| `rime_ice_installed` | `true` |
| `rime_active_schema` / `keyboard_layout_scheme_26` | `rime_ice` |
| `rime_ice_version` | `2026.06.30` |
| `rime_ice_source_variant` | `nju` |
| `rime_ice_checksum` (archive) | `675d23b070be00e1b800f9a6db033ef98f4493cd5b568ed8aa3b3541769c46ac` |
| `rime_ice_staged_content_checksum` | `781f61ce95526bf117cc3316dde014b1ab8cd941be9ecbf0c975b2e7a9a57701` |
| `rime_ice_lua_smoke_passed` | `true` |
| `user.yaml` `previously_selected_schema` | `rime_ice` |
| `rime_ice.userdb/` | Present |
| `Rime/user/rime-runtime-provenance.json` | **Absent** |

### Why the json file is absent (not a failed Human deploy)

On install tip `e1b28ae…`, `Packages/RimeBridge/Sources/RimeBridge/RimeRuntimeProvenance.swift` (writer of `rime-runtime-provenance.json`) is **not present**. Main-App `deployRimeConfig` success sets UserDefaults (`rime_deployed`, Ice checksum keys) and does not write that file. The writer **did** exist on older package tip `3f9f2652…` (reval-07 / Ice smoke). Absence of the json on this Run is therefore a **tip capability gap on `e1b28ae`**, not evidence that Human failed to deploy. Environment binding for this Run uses the App Group Ice preference keys above (same archive/staged checksums as prior smoke).

## Human observation

Human Product Owner (chat `2026-09-22 Asia/Shanghai`) attested after real-keyboard entry of `wimenjintianquhongyuan` (no Space / deletion / candidate selection / Send required by protocol):

- Target 「我们今天去公园」 **was visible**
- Target was **selectable**
- Target was in **candidate bar position 2**

Executor did not use FakeCandidateProvider, `typeText`, clipboard, or host text injection. Exact keystroke journal / sidecar content-free reconciliation was **not** captured under this Run (no `keyboard_extension.jsonl` retained for reval-08).

A post-observation Simulator screenshot was retained outside Git for UI corroboration only; it is **not** used to override Human attestation of the named target text or position:

`/private/tmp/typo-correction-002-sim-runs/TC2-SIM-20260922-183859-QA001-REVAL-08/raw/qa001-post-observation.png`
SHA-256 `d15e2e90d284313882719dbb2abee9b1a58845f6275ba7d73e2a5ced8aeffaac`

## Preserved raw artifacts (outside Git)

`/private/tmp/typo-correction-002-sim-runs/TC2-SIM-20260922-183859-QA001-REVAL-08/raw/`

| File | SHA-256 |
|---|---|
| `package-identity.txt` | `0ac8c9ab0ed88c6d31bd6968c1886524b4099707a698189bfbaaa68248e9cae2` |
| `installation.yaml` | `95c0908dac2a5490852ff596b4723f6c295f24a64e544ecee6e5f2b7ce90efde` |
| `user.yaml` | `e5f7d102fc83c9154bd2ce7c929e300e993a21c15d6d832142e8ceec817d6bee` |
| `default.custom.yaml` | `ceb22b785193c17363613407ccfe80f30b1b0605501259690fd8603b88aff9fa` |
| `rime_ice.custom.yaml` | `b65ed4cf369cc34bae32aecc016337ad90fe29de4c6048b3c085d1ac814a53e7` |
| `builtin-overlay-receipt.json` | `322692ea578bafe90f86fde7ced9b60e8a0c9eec69f525e1d9218ec492a76a4c` |
| `builtin-resource-receipt.json` | `bb880191c8309228b8892d27803d360ff385d9b935c8035ff57acada030f5701` |
| `qa001-post-observation.png` | `d15e2e90d284313882719dbb2abee9b1a58845f6275ba7d73e2a5ced8aeffaac` |

## Claim disposition

| Claim | Outcome |
|---|---|
| Fresh install from tip `e1b28ae…` / CI binding A | pass |
| New Run ID and new package hashes (≠ reval-07) | pass |
| Formal `rime-runtime-provenance.json` | **absent — tip `e1b28ae` lacks `RimeRuntimeProvenance` writer**; App Group Ice preference keys bind environment instead |
| Exact registered phrase entered via real keyboard | Human-attested pass (Executor did not independently journal taps) |
| Target 「我们今天去公园」 visible | **pass** (Human-attested) |
| Target selectable | **pass** (Human-attested) |
| Target position 2 | **pass** (Human-attested; not independently OCR-verified by Executor) |
| Target selected / post-selection interaction | **not-run** (AUTH observation stopped at visibility/selectability) |
| INT-003 / paired performance / 180 ms | **not-run / non-claim** |
| Product / Quality / Release Gate / parent Close | **non-claim** |

## Non-claims

This receipt does **not**:

- Close parent `TYPO-CORRECTION-002` or open any Product / Quality / Release Gate
- Establish INT-003, paired performance, or 180 ms
- Claim that a on-disk `rime-runtime-provenance.json` receipt was minted by tip `e1b28ae` (writer not in tree); App Group Ice preference keys are the environment binding used here
- Authorize commit, push, PR, merge, TestFlight, or Release

## Residuals / next frontier

1. Tip `e1b28ae…` does not ship `RimeRuntimeProvenance` write/load — on-disk `rime-runtime-provenance.json` cannot appear after deploy on this package; Product may later restore the writer or accept App Group Ice preference binding as sufficient for QA-001 environment claims.
2. Independent Architecture / Quality review of this evidence requires a **new** Authorization.
3. Assignment Close / parent Close / Gates require separate Authorization.
