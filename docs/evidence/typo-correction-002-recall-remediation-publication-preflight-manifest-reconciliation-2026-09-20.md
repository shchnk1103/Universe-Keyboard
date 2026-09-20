# Evidence: TYPO-CORRECTION-002 recall remediation publication preflight manifest reconciliation

## Result

`Docs-only provenance reconciliation passed for the exact five-file snapshot; fresh Architecture and Quality review remain required.`

This receipt repairs the aggregate source-manifest serialization defect identified by the independent Architecture review. It does not rewrite the consumed historical preflight receipt and does not turn the prior `Blocked` Architecture verdict into a pass.

## Identity and authority

| Field | Value |
|---|---|
| Assignment | [`TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-001`](../assignments/typo-correction-002-recall-remediation-publication-preflight-001.md) |
| Authorization | [`AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-MANIFEST-RECONCILIATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-MANIFEST-RECONCILIATION-001.md) |
| Original preflight ID | `TC2-RECALL-PREFLIGHT-20260920-002` |
| Worktree | `/private/tmp/universe-keyboard-typo-correction-002-recall-preflight-001` |
| Branch | `codex/typo-correction-002-recall-preflight-001` |
| HEAD | `d0df9a6342d8209b5aa7f9826541d0b430b9da04` |
| HEAD tree | `27ae44bec1b157e391ef1e0b859db3a068e21ba8` |
| Reconciliation scope | Manifest bytes and docs-only downstream references; no source/test/build/run changes |
| New Run ID | None; this is not a product/device run |

## Root cause and historical boundary

The consumed preflight Authorization and evidence recorded source manifest digest `bcbabcb7c7870b90691422ab7fd65f028f348921e64fc39ebaf5db94038d2e3e` while declaring a sorted `path|sha256` aggregation rule. Independent Architecture review recomputed the five recorded file hashes and found that the declared digest could not be reproduced. The historical value is retained as `superseded_not_reproducible`; it is not silently edited.

The direct byte-level reproduction used for this reconciliation is:

1. Sort the five entries by path.
2. Encode exactly the lines below as UTF-8.
3. Use one LF (`0x0A`) after every line, including the final line.
4. Hash those bytes with SHA-256.

The canonical bytes are stored as [`source manifest 002`](typo-correction-002-recall-remediation-publication-preflight-source-manifest-2026-09-20-002.txt).

### Correction to the historical Architecture receipt's alternate digest

The Architecture receipt listed `ad6da0…698d5` as the terminal-LF variant. A direct byte-level `cmp` against the canonical text file and a fresh `shasum -a 256` calculation show that the actual five-line LF-terminated bytes hash to `709370…9f207`. The `ad6da0…` value is not used by this reconciliation. The Architecture receipt remains immutable historical evidence: its core finding that `bcbabcb7…` is not reproducible is still valid, while this reconciliation records the corrected canonical digest.

## Canonical manifest

| Field | Value |
|---|---|
| Encoding | UTF-8 |
| Line separator | LF (`0x0A`) |
| Final byte | LF (`0x0A`) |
| Extra blank lines / code fence | None |
| Canonical manifest SHA-256 | `709370f83f819a885f95b6224a763d59712eeac93f164939c03ae31627a9f207` |
| File size | `652` bytes |

The five entries and their independently rechecked file hashes are:

| Path | SHA-256 |
|---|---|
| `Packages/KeyboardCore/Package.swift` | `9ebf33313b560b83634a074dd675211aee9cec13b1d879e9cd4f35fbb94aa764` |
| `Packages/KeyboardCore/Sources/KeyboardCore/ContextualTypoCorrection.swift` | `9fb3fdc9c4cb809cf08b098bd882226e74a1a74eef23a043bba261d017216b57` |
| `Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallPreflight.swift` | `e05488596a044e199b30fb3f262f72877ff31b172ba98638091b44ce7b030c9d` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionRecallPreflightTests.swift` | `9147004b425c19f2326292358f13e6db90c4d3969f2e4fb758841119991f3fd6` |
| `UniverseKeyboardTests/RimeSettingsStoreTests.swift` | `788d6fd0fc814a034a61873cda6ba67432e21042f7953c8849212f350e8066f9` |

## Reconciliation checks

| Check | Result |
|---|---|
| Five current file hashes equal the previous preflight evidence | Passed |
| Canonical manifest file byte sequence equals the authorized five-line serialization | Passed; `cmp` matched the direct LF serialization |
| Canonical manifest SHA-256 | Passed; `709370…9f207` |
| Package manifest SHA-256 | Unchanged; `9ebf333…aa764` |
| HEAD / tree | Unchanged; `d0df9a63…` / `27ae44be…` |
| Vendor archive/tree provenance | Unchanged; `d17aab9a…` / `d446b0a4…` |
| Source/test/build/device changes | None |
| `git diff --check` | Passed |

## Review and gate boundary

- The prior Architecture review remains a historical `Blocked` review of the old, non-reproducible `bcbabcb7…` receipt.
- This reconciliation makes a new exact manifest available; it does not itself provide a new Architecture verdict.
- A fresh independent Architecture review must bind to this canonical manifest and this reconciliation receipt.
- Only after Architecture review may a separate Quality review bind to the corrected receipt.
- No Product publication decision, commit, push, PR, merge, TestFlight, Release, runtime/device evidence, INT-003, QA-001, paired-performance or 180 ms conclusion is made here.

## Non-claims

This receipt does not re-run or revalidate KeyboardCore, RimeBridgeTests, App + Keyboard tests or Release build. It does not prove runtime RIME behavior, production scheduler wiring, candidate quality, device acceptance, performance, Product/Quality/Release Gate passage or parent/child closure. The original preflight test results remain bound to their original receipt and are reused only as referenced historical evidence after the manifest identity is reconciled.

## Handoff

Request a new independent Architecture review Authorization bound to canonical manifest `709370f83f819a885f95b6224a763d59712eeac93f164939c03ae31627a9f207`. Do not start Quality review or publication from the superseded `bcbabcb7…` digest.
