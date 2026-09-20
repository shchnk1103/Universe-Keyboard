# Architecture Review: TYPO-CORRECTION-002 recall remediation publication preflight 002

## Verdict

**Blocked — provenance receipt manifest is not reproducible from its declared rule.**

本 review 只覆盖 `TC2-RECALL-PREFLIGHT-20260920-002` 的精确 source/package/vendor
snapshot、纯 `KeyboardCore` boundary 与本地 CI-equivalent receipt 的架构可审计性。五个
allowlist artifact 各自的当前 bytes 与 evidence 相符，且 production / test-only 的代码边界
保持；但当前 source manifest 的已声明生成规则不能重现授权和 evidence 中的
`bcbabcb7…`。在该矛盾被新的、有界 Authorization 下的更正 receipt 解决前，不能把本
review 解释为允许 Quality review 或 Product publication decision。

这不是 Quality、Product 或 Release verdict，也不授权 publication、commit、push、PR、merge
或任何 runtime 工作。

## Evidence and boundary

| Field | Observed value | Result |
|---|---|---|
| Worktree / branch | `/private/tmp/universe-keyboard-typo-correction-002-recall-preflight-001` / `codex/typo-correction-002-recall-preflight-001` | matches Architecture Authorization and evidence |
| HEAD / tree | `d0df9a6342d8209b5aa7f9826541d0b430b9da04` / `27ae44bec1b157e391ef1e0b859db3a068e21ba8` | matches |
| Package SHA-256 | `9ebf33313b560b83634a074dd675211aee9cec13b1d879e9cd4f35fbb94aa764` | matches |
| Five individual allowlist hashes | `9fb3fdc9…`, `e0548859…`, `9147004b…`, `788d6fd0…`, plus the Package hash above | each matches evidence exactly |
| Declared source manifest | `bcbabcb7c7870b90691422ab7fd65f028f348921e64fc39ebaf5db94038d2e3e` | not reproducible from the declared rule and the five recorded hashes |
| Vendor archive / tree receipt | `d17aab9a8b08b5901ab583c143b0a8a03994e36fe092309fd14c5bee31399dd9` / `d446b0a4cdd40d42f53359ba8a7677d625ac8461c60ecfe92f90ca73e8df14fd` | consistent across Authorization, Assignment, preflight evidence and materialization evidence; this review did not rerun vendor verification |
| Simulator | `iPhone 17 Pro / iOS 26.0 / 8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2` | consistent across Authorization, Assignment and preflight evidence |

The stated source-manifest rule is “sorted `path|sha256` lines for the five listed
source/package artifacts, joined with newlines and hashed with SHA-256.” I recomputed
those five current file hashes in path order. The byte sequence without a terminal newline
hashes to `69414ea30ccd26db05c31f39ed2d46fa189746ccb883c4d24ede99dc873842fa`; adding one
terminal newline hashes to `ad6da0d64e4316b34982f06367c1fa9a6a0d20ad946b72c8eda424b3862698d5`.
Neither is the recorded `bcbabcb7…`. Therefore the five individual bytes establish that
the listed files are unchanged, but they do not establish the declared aggregate receipt.

No build, test, install, deploy, vendor verification, Simulator/device Run, source edit or
test edit was performed by this reviewer.

## Findings

### P0 — source-manifest digest does not bind to its published artifact list

`AUTH-…-PUBLICATION-PREFLIGHT-002`, the Architecture-review Authorization, the Assignment
and the preflight evidence all bind this preflight to `bcbabcb7…` and describe the same
five-path `path|sha256` manifest rule. The independently recomputed input file hashes are
identical to the evidence table, yet the prescribed aggregation yields neither that digest
nor an unambiguous terminal-newline variant.

This is a receipt/provenance defect, not evidence of a source-byte change. Its consequence
is nevertheless fail-closed: an exact-digest review cannot truthfully bind to the claimed
source manifest while the receipt’s declared derivation is false or incomplete.

**Disposition:** `fix` before Quality review or any Product publication decision. A new,
bounded Authorization must name the canonical manifest serialization (including ordering,
separator and terminal-newline behavior), regenerate its digest from the five fixed file
hashes, and rebind the downstream receipt/review inputs. Do not silently substitute either
recomputed digest for the authorized one.

### P2 — pure-Core and fail-closed boundaries remain preserved

The static source review finds no production controller, Keyboard Extension, RimeBridge,
RIME query, marked-text, persistence or network call from the preflight ledger. Production
`ContextualTypoCorrectionSearchBudget.productionV2` remains `12/8`; the preflight plan uses
the separate `60/64` pure in-memory budget and defaults to `.substitutionOnly`. The ledger
keeps distinct generated/query/resolved-group/candidate counters, per-batch and global-query
caps, resolved-group deduplication, cancellation and revision/session-epoch stale-result
fences. It cannot publish while a batch/query is open, after cancellation, or after a
contract violation.

The prior open runtime residual remains: the opaque `GroupID` is intentionally supplied by a
future scheduler, so this review does not prove canonical corrected-input mapping, async
scheduler behavior or real RIME acceptance.

### P2 — test fixture remains test-only and preserves production failure semantics

`StoreDeploymentService` exists in `UniverseKeyboardTests/RimeSettingsStoreTests.swift`.
Its successful fixture path supplies deterministic non-empty provenance fields; failed and
cancelled paths retain `nil`. The change does not alter production deployment code, RIME
bridge code, entitlements or signing configuration. It therefore does not relax production
fail-closed behavior.

### P2 — test-count and warning accounting is correctly retained in the receipt

The authoritative App + Keyboard result is retained as `388 total / 379 passed / 9 skipped /
0 failed`. The `389 discovered` value is explicitly only an outer wrapper observation, not
an xcresult total. The `107` `CODE_SIGNING_ALLOWED=NO` entitlement messages remain a
test-environment residual; they are not evidence for changing checked-in entitlements.

These accounting boundaries are architecturally accurate, but they cannot repair the P0
source-manifest receipt defect.

## Residuals

| Residual | Owner / next boundary | Status |
|---|---|---|
| Canonical five-file source manifest serialization and regenerated exact digest | Product Lead establishes a new bounded remediation Authorization; executor regenerates receipt; Architecture and Quality re-review the new exact binding | open, `fix` |
| Corrected-input to `GroupID` canonical mapping and async scheduler acceptance | future runtime-specific Assignment / Authorization | open; outside this preflight |
| Real RIME, device acceptance, INT-003, QA-001, paired performance and 180 ms | separately authorized environment/Product work | open; outside this preflight |
| Nine skipped tests and 107 signing-disabled warnings | retain as evidence/environment residuals; do not infer runtime or entitlement conclusions | open, non-blocking for the source-level architecture boundary only |

## Non-claims

This review does not claim successful CI execution, hosted CI, actual RIME deployment or
sidecar behavior, production scheduler wiring, candidate ranking/visibility, runtime privacy
behavior, simulator/device acceptance, performance, `contextual 7/8`, Quality/Product/Release
Gate passage, publication, commit, push, PR, merge, TestFlight, Release or parent/child close.
The consistent vendor values above are record-to-record provenance observations, not a new
vendor verification performed by this reviewer.

## Handoff

Do not proceed to Quality review or a publication decision on `bcbabcb7…`. First request a
new narrow Authorization that repairs the manifest serialization/receipt while preserving the
five source bytes and all current non-claims. The regenerated exact digest then requires a
fresh independent Architecture and Quality review bound to that new receipt. This review
created only this record and did not modify Authorization, Assignment, `ACTIVE_WORK`, Swift,
tests, Xcode, vendor or schema files.
