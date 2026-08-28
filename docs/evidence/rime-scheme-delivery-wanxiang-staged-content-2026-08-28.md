# Evidence: Wanxiang staged-content mismatch — 2026-08-28

**Assignments:** [`SCHEME-DELIVERY-JOURNAL-001`](../assignments/scheme-delivery-journal-001.md) · [`RIME-SCHEME-DELIVERY-INTEGRITY-001`](../assignments/rime-scheme-delivery-integrity-001.md)
**Evidence grade:** `Device-attested` (Human log paste) + `Executor-recorded` (archive re-hash and Unzip comparison)
**Collection date / timezone:** `2026-08-28 Asia/Shanghai`

## Human v1 journal (TD-015)

Logging + DEPLOY on, high-fidelity off, PR #83 build. Search found `scheme_delivery.*` rows. Journal path is usable.

Operation `11831eec-455f-478d-817d-449f394ec17b`, artifact `wanxiang_17_5_9_cnb9bfc_github73f8`, source `cnb` / `asset.cnb.cool`, attempt 1.

## Classified failure (ADR 0032)

| Phase | Result |
|---|---|
| selecting | succeeded (`cnb`) |
| downloading | succeeded |
| verifying_archive_size | succeeded |
| verifying_archive_digest | succeeded |
| extracting | succeeded |
| post_processing | succeeded |
| verifying_staged_content | **failed** `integrity=staged_content expected=5b18280129815223 actual=24227ffcf54c1d58` |
| terminal | `failed` `installed=false deployed=false failure=staged_content` |

No fallback. That is required: staged-content mismatch must not try GitHub.

Expected prefix matches the Lua-on pin
`5b182801298152236c790e29fd190d41b509c7da373babb0c02e65fa4eaf07cf`.
Actual prefix is not the Lua-off pin.

## Executor reproduction

Fresh CNB `v17.5.9` archive still matches the manifest
(`35,027,247` bytes, SHA-256 `9bfcf60e…67732`).

Python `zipfile` + current allowlist hashes to the **pin** `5b182801…`.
Production `Unzip.extract` + the same allowlist hashes to **`24227ffcf54c1d58…`**,
the Human actual.

`lua/data/chaifen.txt` is an empty stored zip entry (`compress_size=0`,
`file_size=0`). `ZipArchiveReader` skipped `compressedSize == 0` entries, so
the empty file never reached staged hashing. Pin provenance used an extractor
that kept the empty file.

This is not archive corruption and not a reason to weaken checksums.

## Non-claims

- Not Product Gate, merge, or Release.
- Not proof that GitHub would fail the same way (fallback is forbidden here).
- Network/region for this Human attempt was not stated.
