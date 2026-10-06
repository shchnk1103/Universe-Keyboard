# Entry and activation record — Wire-Version Reconciliation 001

- Assignment reviewed scope SHA-256: `edf450b3dbfbe621849d0fbf6bc641518cbc22e992fde6239034d05d2e7729c6`.
- Assignment full-file SHA-256 at Entry freeze: `d43baef8e0f06e34b623cf43222ee887b0c05ea6c3cc9931ee657cf57a68660d` (`Acknowledged / Not Ready`).
- Assignment full-file SHA-256 after status/history-only transition to Active: `6e94b19c21157a6b444158728d5cc294debb20b710b8498348eed3ef7bfb7585`.
- Entry identity packet: `docs/evidence/keyboard-wake-diagnostic-wire-version-reconciliation-001-entry-identity-2026-09-30.md`, SHA-256 `3a0a27291fe653daf02191622fa1392522d17b648bd5cdf74e5f13155000179b`.
- Baseline: `84b9c19227330b0fe6ff391be001ee398010fd6a`.

## Entry evidence

- Exact scope responsibilities were acknowledged or reviewed against the reviewed scope SHA; Environment Executor and Human Dependency are justified `Not Applicable` for this document-only Assignment.
- Architecture and Quality scope reviews are recorded in their round-1 receipts. For Entry identity review, Quality R3 returned `Pass with conditions` with `ENTRY-ID-DRIFT-01` dispositioned `accept` narrowly; Architecture completed coverage across R3/R4/R5 and returned `Pass` in R5. The intervening Block results and their corrected packet-locator/coverage gaps remain recorded in their own receipts and are not rewritten as passes.
- Identity verification after the status-only Assignment update found all other 20 Required document identities unchanged; all 17 current source/test identities, statuses and baseline hashes matched the frozen Entry packet; three scope-review prerequisite records matched; and all seven v3 manifest r2 file hashes still matched current bytes.
- `ENTRY-ID-DRIFT-01` accepts only that the erroneous one-character historical cell in the paired-rollout pre-edit receipt is not used as current identity evidence. The actual source and v3 manifest r2 agree. The historical receipt was not modified.
- Parent lifecycle Assignment remains Active and root cause unresolved. The paired-rollout child remains held from source work at its Entry-time `Acknowledged / Not Ready` status. The transcription discrepancy does not change the document-only schema decision slice or introduce a new protocol alternative.

## Lifecycle and authority

With the Entry criteria satisfied, the Assignment advanced **Acknowledged → Ready → Active** on 2026-09-30 Asia/Shanghai under the existing Product authorization. The file-hash change from `d43baef8…a68660d` to `6e94b19c…fb7585` is limited to current-status/history text and a link to this evidence; the objective, decision boundary, Required Inputs, non-goals, Entry/Exit, stop conditions, and assignment authority were not changed.

The Executor may now analyze only the exact document and source/test identities frozen in the Entry packet. Each is to be revalidated immediately before use; any drift stops the dependent analysis and requires rebind. This activation authorizes document-only alternatives, compatibility-matrix, and ADR/Assignment analysis within the existing scope. It does not select/adopt a wire version, authorize source/test edits, builds, test execution, Simulator operations, installation, marker emission, Product/Quality Gate, Release, or parent closure.
