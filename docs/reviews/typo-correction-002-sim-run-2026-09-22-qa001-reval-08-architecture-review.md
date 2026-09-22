# Architecture Review: TC2-SIM-20260922-183859-QA001-REVAL-08

**Reviewer:** Architecture & Knowledge Steward role (read-only). Executed by Grok (iOS开发大师) under Human Authorization after CI green on draft PR #145. **Dual-role residual:** the same agent was the capture Executor for this Run; this review is limited to independent artifact re-verification and does not invent new observation facts.
**Date / timezone:** `2026-09-22 Asia/Shanghai`
**Mode:** Read-only. No Simulator re-run, no code change, no Gate close, no Assignment Close.

| Bound | Identity |
|---|---|
| Run ID | `TC2-SIM-20260922-183859-QA001-REVAL-08` |
| Run Receipt | [`typo-correction-002-sim-run-2026-09-22-qa001-reval-08-target-observed.md`](../evidence/typo-correction-002-sim-run-2026-09-22-qa001-reval-08-target-observed.md) |
| Capture Authorization | [`AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-08-FRESH-PACKAGE-001`](../authorizations/AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-08-FRESH-PACKAGE-001.md) |
| Architecture Authorization | [`AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-08-ARCHITECTURE-001`](../authorizations/AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-08-ARCHITECTURE-001.md) |
| Child Assignment | [`TYPO-CORRECTION-002-QA001-REVALIDATION-08-FRESH-PACKAGE-001`](../assignments/typo-correction-002-qa001-revalidation-08-fresh-package-001.md) |
| Parent Assignment | [`TYPO-CORRECTION-002`](../assignments/typo-correction-002.md) — Active |
| Related lane | [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md) |
| Install tip | `e1b28aebe8f6b2f2a8587db1e525e332aa9bfe00` |
| Docs tip / PR | `dc1820a70a0c58db58c8c8d891184220158425d7` · draft [#145](https://github.com/shchnk1103/Universe-Keyboard/pull/145) |
| Raw artifacts | `/private/tmp/typo-correction-002-sim-runs/TC2-SIM-20260922-183859-QA001-REVAL-08/raw/` |

This review consumes the Architecture Authorization for **evidence-boundary disposition only**. It does not consume Quality, Product Close, Gate, INT-003, or performance authority.

## Verdict

**Pass with conditions** for the QA-001 revalidation 08 **observation evidence boundary**.

Independent re-hash of retained package binaries and raw artifacts matches the Run Receipt. Install tip `e1b28ae…` is a fresh package relative to reval-07 (`3f9f2652…` / App exec `9f1c360d…`). Environment binding on this tip correctly uses App Group Ice preference keys rather than on-disk `rime-runtime-provenance.json`, because `RimeRuntimeProvenance.swift` is absent from `e1b28ae` (present on `3f9f2652`). Human Product Owner attestation that「我们今天去公园」was visible and selectable at candidate-bar position 2 is accepted as the sole named-target identity authority for this slice.

Conditions / residuals below do **not** overturn the observation claim, and do **not** authorize Assignment Close, parent Close, or any Gate.

## Independent checks (this review)

### 1. Package identity — Pass

Retained Debug-iphonesimulator binaries were re-hashed:

| Member | SHA-256 (this review) |
|---|---|
| App executable | `927bfcbbb7e75a55dc045c6863e0cd1e6a4a9f55348464740ee0d0a709ca4273` |
| App debug dylib | `5229565e7fd6757149bdf009d277c7f07b499cfaae0096b20c4ed54e9b90ec37` |
| Keyboard executable | `22539e904e18f2d91b17b575fe1eb96b90022f40c0c8afb9360660a55298d41a` |
| Keyboard debug dylib | `f35d92acb06a4b36c5886071b89bbe5005640e23bca7f78c86b120a08093fd5a` |

These match the receipt and differ from reval-07 App executable `9f1c360d…`. Forbidden same-package reuse was avoided.

### 2. Docs tip / CI hygiene — Pass (bounded)

Draft PR #145 head `dc1820a…` was observed with Swift 6 Quality `classify-change`, `lightweight-checks`, and `final-quality-gate` **SUCCESS** (docs-only path; test/build jobs SKIPPED as expected). This supports docs publication hygiene for the evidence tip. It is not a product Gate and not a re-validation of the install tip’s hosted CI binding A (`35715351145` on `e1b28ae`).

### 3. Ice environment binding without on-disk provenance file — Pass with conditions

`git cat-file` confirms `Packages/RimeBridge/Sources/RimeBridge/RimeRuntimeProvenance.swift` **does not exist** on `e1b28ae` and **does exist** on `3f9f2652…`. Therefore absence of `Rime/user/rime-runtime-provenance.json` after a successful Main-App deploy on this package is a **tip capability gap**, not a Human “未部署” failure.

Live App Group preferences (container `0469C0D3-…`) were re-read in this review and still show:

| Key | Value |
|---|---|
| `rime_deployed` | `true` |
| `rime_ice_installed` | `true` |
| `rime_active_schema` | `rime_ice` |
| `rime_ice_version` | `2026.06.30` |
| `rime_ice_source_variant` | `nju` |
| `rime_ice_checksum` | `675d23b070be00e1b800f9a6db033ef98f4493cd5b568ed8aa3b3541769c46ac` |
| `rime_ice_staged_content_checksum` | `781f61ce95526bf117cc3316dde014b1ab8cd941be9ecbf0c975b2e7a9a57701` |
| `rime_ice_lua_smoke_passed` | `true` |

These archive/staged checksums match the identity historically recorded in reval-07 / Ice-smoke on-disk provenance. Retained `user.yaml` still records `previously_selected_schema: rime_ice`.

**Condition:** Architecture accepts App Group Ice preference binding as the environment identity for tip `e1b28ae` observation evidence. It does **not** claim an on-disk `rime-runtime-provenance.json` receipt ID equivalent to `67A0C52E-…`.

### 4. Raw artifact integrity — Pass

Retained raw SHA-256 values were recomputed and match the receipt table (`package-identity.txt`, yaml/json receipts, `qa001-post-observation.png`). No `keyboard_extension.jsonl` is present for this Run.

### 5. Named target candidate — Pass (Human-attested; Architecture non-inferring)

Architecture does **not** OCR or otherwise extract candidate text from `qa001-post-observation.png`. The screenshot is hashed only. Named-target visibility, selectability, and position 2 remain **Human Product Owner attestation** as recorded in the Run Receipt and chat. Architecture accepts that attestation for the observation-boundary claim and cannot independently prove the string identity.

### 6. Content-free input/route journal — Residual (not-run)

Unlike reval-07, this Run did not retain a content-free `keyboard_extension.jsonl`. Architecture therefore **cannot** independently corroborate touch counts, sidecar route=`real_rime_sidecar`, or input-length progression. Exact phrase entry and real-keyboard path remain Executor-protocol + Human-attested, not journal-reverified.

## Residuals

| ID | Residual |
|---|---|
| AR-QA08-01 | Dual-role: capture Executor and Architecture executor are the same agent under Human Authorization |
| AR-QA08-02 | No `keyboard_extension.jsonl` — no independent touch/sidecar route reconciliation |
| AR-QA08-03 | Tip `e1b28ae` lacks `RimeRuntimeProvenance` writer; environment bound via App Group Ice prefs only |
| AR-QA08-04 | Screenshot not used for candidate-text identity; position/selectability not machine-verified |

## Non-claims

This review does **not**:

- Close child Assignment reval-08 or parent `TYPO-CORRECTION-002`
- Open Product / Quality / Release Gate conclusions
- Substitute for an independent Quality review
- Establish INT-003, paired performance, or 180 ms
- Claim on-disk provenance receipt parity with reval-07
- Authorize undraft/merge of PR #145, commit of this review, or restore of `RimeRuntimeProvenance` on main

## Next frontier

1. Independent **Quality** review under a new Authorization (evidence completeness, including AR-QA08-02/03 disposition).
2. Product **Close** of child reval-08 under a new Authorization after Quality (recommended) or with explicit acceptance of residuals.
3. Optional product work (separate Assignment): restore `RimeRuntimeProvenance` write path on main if on-disk receipts remain required policy.
