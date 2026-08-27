# RIME-SCHEME-DELIVERY-INTEGRITY-001 — Architecture Pre-Review

**Review date / timezone:** `2026-08-26 Asia/Shanghai`
**Reviewer:** Independent AI subagent `architecture_review`
**Reviewed Assignment:**
[`RIME-SCHEME-DELIVERY-INTEGRITY-001`](rime-scheme-delivery-integrity-001.md)
**Evidence:**
[`2026-08-26 Wanxiang failure`](../evidence/rime-scheme-delivery-wanxiang-integrity-failure-2026-08-26.md)
**Verdict:** `Pass with conditions`

## Summary

- `P0`: none.
- The proposed recovery direction preserves the parent trust contract: only an
  archive-size or archive-digest mismatch may attempt another independently
  pinned source after a verified cleanup barrier.
- A staged-content mismatch always terminates the operation.
- Four P1 conditions block `Ready` / `Active` until their design and ADR
  disposition are recorded.

## Findings

### AR-RSDI-P1-01 — Cleanup must be a verifiable fallback barrier

The current temporary-item removal interface returns `Void` and uses `try?`, so
it cannot prove that a failed archive was removed. Implementation must provide a
throwing or explicit-result cleanup operation and verify that the exact
operation/source temporary artifact no longer exists before attempting another
source. Cleanup failure stops fallback. Tests must inject deletion failure and
prove that the next downloader is not requested.

A staged-content mismatch may best-effort clean its extraction directory, but
cleanup success or failure can never authorize fallback or installation from
that branch.

### AR-RSDI-P1-02 — Source equivalence needs explicit immutable staged identity

Source equivalence must not be inferred from scheme ID, version or membership in
one source array. The manifest should reference an explicit stable
`stagedIdentityID` whose full identity binds at least:

- scheme and immutable version;
- Lua-enabled and Lua-disabled complete staged SHA-256 values;
- installation allowlist/plan revision;
- deterministic post-processing revision.

Every fallback source still undergoes its own complete archive verification and
the common complete staged-content verification. Non-regular archive,
extraction, post-processing, allowlist and staged-content failures are not
archive-integrity recovery cases.

### AR-RSDI-P1-03 — Diagnostics must use ADR 0027 typed journal

The proposed fields are privacy-bounded, but they must be implemented as reviewed
`DiagnosticEvent.Code` and finite value-type fields through
`DiagnosticsJournalRuntime`. The task must not introduce a legacy `Logger`
free-form string or a generic string field that bypasses the allowlist.

Host, error domain and digest-prefix fields require explicit character/length or
enumeration constraints. Ingress remains bounded and asynchronous, respects the
existing diagnostics switch, and performs no synchronous MainActor disk work.
Journal failure may reduce observability but must never change download,
fallback, installation or deployment results.

### AR-RSDI-P1-04 — A dedicated ADR is required

Verified automatic source recovery is a durable RIME trust decision with
multiple viable strategies and security Stop Conditions. A dedicated ADR must
reach `Accepted; implementation pending` before this Assignment enters
`Active`. It must not alter or claim to close ADR 0006 / TD-001.

## MainActor And Worker Boundary

- `SchemaManager` remains the sole MainActor owner of operation phase, UI state,
  operation generation and receipt commit.
- Background workers receive snapshotted `Sendable` manifest/source/URL value
  types and return immutable results. They do not advance fallback or write
  receipts directly.
- Detached tasks must not capture MainActor-isolated `self`.
- After every suspension point, cancellation and operation generation are
  revalidated before publishing UI, switching source, installing, deploying or
  committing receipts.
- Archive/staged/install/deploy failure never overwrites the last successful
  receipt. Intermediate fallback sources never write partial receipts.

## P2 Recommendations

- Fix digest prefixes to a reviewed length and lowercase hexadecimal format;
  they remain non-authoritative diagnostic correlation only.
- Store only a normalized final host, without port, path, query or redirect
  token.
- Record `fromSource -> reason -> toSource` as a typed transition without the
  complete URL.
- Test diagnostics-disabled, journal-unavailable and bounded-queue-overload
  paths to prove business behavior is unchanged.
- Preserve the parent transport-error fallback. The archive-only restriction
  applies to recovery from integrity failures, not ordinary transport failures.

## Required Entry Disposition

| Residual | Owner | Disposition | Closure evidence required |
|---|---|---|---|
| `AR-RSDI-P1-01` | Main App UI | `fix` | Cleanup-barrier contract plus injected deletion-failure test plan |
| `AR-RSDI-P1-02` | Main App UI | `fix` | Explicit staged identity descriptor and manifest binding |
| `AR-RSDI-P1-03` | Main App UI with Architecture privacy review | `fix` | ADR 0027 typed event/field allowlist |
| `AR-RSDI-P1-04` | Architecture & Knowledge Steward | `fix` | Dedicated ADR accepted with implementation pending |

## ADR Disposition

**New ADR required.** The first pre-review proposed:
[`ADR 0031 — Verified Scheme Source Recovery And Integrity Classification`](../architecture/decisions/0031-verified-scheme-source-recovery-and-integrity-classification.md).
ADR 0006 and TD-001 remain unchanged and open.

## ADR Re-Review

The independent reviewer subsequently returned **Acceptable for `Accepted;
implementation pending`**, with no new P0. The four P1 findings are now bound at
design/Entry level, but implementation and test closure are not claimed:

- `AR-RSDI-P1-01`: design closed; cleanup implementation and failure injection
  remain required;
- `AR-RSDI-P1-02`: design closed; manifest implementation remains required;
- `AR-RSDI-P1-03`: architecture direction closed; exact typed event/field
  allowlist and privacy review remain an Entry Gate;
- `AR-RSDI-P1-04`: closed when ADR 0031 was formally marked `Accepted;
  implementation pending`.

Actor/state transition material, diagnostic allowlist privacy review, exact
implementation base/changed-file allowlist and implementation authorization
remain open before `Active`.

## Final Entry Re-Review

After the Entry design bound cleanup receipts to operation/attempt/source/artifact
identity, added manifest descriptor uniqueness, defined one composite typed
payload per event and extended the MainActor commit lease across every
install/uninstall/switch/reset/redeploy intent, the independent reviewer returned
**Architecture Entry accepted, `P0=0`**.

- `AR-RSDI-P1-01`: design closed; implementation/evidence pending.
- `AR-RSDI-P1-02`: design closed; implementation/evidence pending.
- `AR-RSDI-P1-03`: design/privacy closed; implementation/evidence pending.
- `AR-RSDI-P1-04`: design closed; ADR 0031 accepted.

No Architecture Entry blocker remains. Expansion of state, payload, privacy or
allowlist reopens review. The frozen base/allowlist and Human Product
implementation authorization remain operational Assignment gates.

## Final Implementation Re-Review — 2026-08-27

After implementation and the three explicitly authorized allowlist expansions,
the independent Architecture Reviewer returned **Pass, `P0=0`, `P1=0`**.

- cleanup receipts distinguish removed and already-absent outcomes and remain
  bound to operation, attempt, source and artifact identity;
- manifest validation and all-source integrity aggregation preserve the
  archive-only fallback boundary and success-only receipt rule;
- typed diagnostics retain the reviewed privacy allowlist and do not affect
  delivery behavior when unavailable or overloaded;
- the shared commit lease now covers T9 prepare through deploy and handles
  waiting, cancellation, generation invalidation and exact-lease rollback;
- deterministic regressions cover T9 blocking deploy, foreign and owned
  cancellation, generation-invalidity rollback and reacquisition.

The earlier `AR-RSDI-P1-01...04` findings are closed for this implementation.
Two non-blocking observations remain: manager deallocation during an awaiting
handoff has only a low-risk weak-reference edge, and the full real delivery
pipeline does not duplicate every commit-lease cancellation scenario already
covered at its owning transaction boundary. Neither observation broadens the
current Assignment or closes the remaining stable-toolchain, physical-device
or Human Product gates.
