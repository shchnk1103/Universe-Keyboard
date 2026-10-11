# RIME-SYNC-001 — current App + Keyboard suite — fresh Quality review — 2026-09-25

## Verdict

**Pass with conditions** for engineering test evidence in the exact snapshot
below. This is not the overall Assignment Quality Gate or lifecycle closure.
`RIME-SYNC-001` remains `Active`.

## Exact candidate and review method

| Item | Value |
|---|---|
| HEAD | `4a51228fc8e435d538e9a5f7342ae325502e1e66` |
| Candidate paths | 53 |
| Manifest SHA-256 | `c3a6ccfce8ab3803d414b6289b830ef98d47b63d8814817766f485e3d4ed8f5a` |
| Excluded post-review receipts | This Quality receipt and `rime-sync-v1-current-app-keyboard-architecture-review-2026-09-25.md` |

The reviewer independently recomputed all 53 file hashes and the manifest.
This was a fresh read-only Quality review. It inspected the current
`.xcresult`, Xcode enumeration, raw skip messages, current source/tests and
Assignment; it did not run tests, operate the Simulator or modify files. The
reviewer could not independently verify the runtime model identity.

## Evidence matrix

- Current App + Keyboard `.xcresult`: 401 total, 391 passed, 10 skipped,
  0 failed on iPhone 18 Pro / iOS 27.0 build `24A434`.
- Native Xcode enumeration: 401 unique enabled IDs. The normalized ID set
  exactly matches all 401 `.xcresult` test IDs; missing 0, extra 0. The
  reviewer recomputed the normalized set hash as
  `396a31a93c82d38c4d6013fbde71172c088e0aab7e9b0dd84653aaf94fd614cf`.
- XcodeBuildMCP reported 402 preflight discoveries. The `.xcresult` and native
  enumeration support reporting 401 actual IDs, but do not explain the extra
  MCP discovery. The earlier `QR-CURRENT-01` Product decision is scoped to
  named earlier runs and is not extended to this run.
- All ten skips have explicit prerequisites: one pinned archive-source case,
  one unsigned-host Keychain entitlement case, five Ice/Wanxiang fixture
  cases, and three physical-device-only TD-012 cases. None counts as passed.
- `RimeSyncModelTests` had 15 cases: 14 passed and the production Keychain CRUD
  case skipped because the broad host was unsigned. Earlier signed Keychain
  evidence remains historical; it was not rerun here.
- The separate full UI run remains 36 total, 29 passed, 7 skipped, 0 failed;
  it is not merged with this App + Keyboard result.

The current suite evidence is Executor-recorded. Independent inspection of
the `.xcresult`, native enumeration, skip reasons and source is
Quality-reverified for this bounded run only.

## Findings and conditions

| ID | Severity / disposition | Finding |
|---|---|---|
| `Q-COUNT-01` | P2, unaccepted exact-run residual | Report 401 actual result IDs; do not report 402 executions or infer the MCP cause. The previous Product acceptance does not cover this run. Resolution requires scoped Quality/CI owner analysis or explicit Product acceptance by the authorized owner. |
| `Q-DOC-01` | P2, fix before parent close | Assignment Current Status and parts of Exit Criteria still describe the old 397/387 run and old Architecture snapshot as current, conflicting with the newer evidence recorded in ACTIVE_WORK and this receipt. Synchronize current state and preserve old results as history under KOS 2.1 M-01. |
| `Q-DEL-01` | P2, open evidence condition | Neither the full UI first-sync test nor this broad suite proves real Files/File Provider deletion metadata or durable deletion propagation. Keep it open and do not claim provider deletion success. |

All ten skips remain unverified. The new 402/401 residual remains distinct
from the prior Product-accepted exact-run residual. `TD-002` remains open.

## Non-claims

No complete CI heavy-job matrix, hosted CI, signed Keychain rerun, provider
deletion propagation, live WebDAV, CloudKit, current-snapshot physical-device
run, natural BGTask guarantee, cross-platform closure, debt resolution,
Product/lifecycle closure, merge, TestFlight or Release is claimed.
