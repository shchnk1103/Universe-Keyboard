# ADR 0031: Verified Scheme Source Recovery And Integrity Classification

## Status

Accepted

**Accepted:** `2026-08-26 Asia/Shanghai` after independent Architecture
re-review found no P0 and confirmed the archive-only recovery, cleanup,
staged-identity, typed-diagnostics, actor and receipt boundaries. Acceptance
does not claim implementation, tests, Mainland evidence or Product Gate.

**Implementation status:** completed locally on `2026-08-27` within
`RIME-SCHEME-DELIVERY-INTEGRITY-001`; final Architecture review returned
`Pass`, P0=0/P1=0. Stable-toolchain, exact-candidate Mainland physical-device
and Human Product gates remain open, so this status is not a Release claim.

## Context

Universe Keyboard supports upstream-maintained source variants that can have
different archive bytes while converging on one guarded installed-content
identity. PR #83 implemented source-specific byte-count/SHA-256 receipts and a
deterministic staged-content receipt. A later Human physical-device Wanxiang
attempt stopped with one generic integrity error. The UI and diagnostics could
not determine whether the failure was archive size, archive digest or staged
content, and the current archive-integrity branch immediately terminates rather
than considering another independently pinned source.

The system must recover from a damaged transport artifact without weakening the
manifest trust root, hiding a client-side staging discrepancy, retaining failed
temporary content or introducing free-form diagnostic data.

## Decision

1. **Classify integrity phases.** Internal failures distinguish
   `archiveSize`, `archiveDigest` and `stagedContent`. Non-regular files, unsafe
   extraction, deterministic post-processing, allowlist and deployment failures
   retain their own non-recoverable classifications.
2. **Bind source variants explicitly.** Each eligible source references an
   immutable staged identity descriptor. The descriptor binds scheme/version,
   the complete Lua-enabled and Lua-disabled staged SHA-256 values, installation
   plan revision and deterministic post-processing revision. Equivalence is not
   inferred from source-array membership or visible version text.
3. **Recover only archive-level integrity failures.** After archive-size or
   archive-digest mismatch, the exact failed temporary artifact must cross a
   throwing or explicit-result cleanup barrier and be verified absent. Only then
   may the MainActor operation owner attempt another independently pinned source
   bound to the same staged identity. The new source repeats full byte-count,
   archive SHA-256 and staged-content verification.
4. **Fail closed when cleanup is unproven.** Cleanup failure stops fallback.
   No failed or unverified archive proceeds to extraction, installation or
   deployment.
5. **Never recover staged-content mismatch by source substitution.** A staged
   mismatch indicates manifest, allowlist, deterministic processing or extracted
   content drift. It terminates the operation regardless of cleanup outcome.
6. **Preserve transport fallback.** Existing bounded fallback for ordinary
   network/HTTP/timeout failure remains separate from integrity recovery and is
   not prohibited by this ADR.
7. **Keep operation ownership explicit.** `SchemaManager` remains the sole
   MainActor owner of phase, UI state, operation generation, fallback decisions
   and receipt commit. Background workers receive immutable `Sendable` snapshots
   and return immutable results; detached work does not capture MainActor-owned
   `self`. Cancellation and generation are revalidated after suspension before
   every state transition or side effect.
8. **Use typed local diagnostics.** Integrity transitions use reviewed
   `DiagnosticEvent.Code` and finite value-type fields through ADR 0027's bounded
   asynchronous journal. No legacy free-form `Logger` string is introduced.
   Allowed fields are operation correlation ID, immutable scheme/version, source
   ID, normalized final host, phase/result/fallback reason, bounded byte counts,
   fixed lowercase digest prefixes, HTTP status/error domain/code, bounded
   duration, Lua availability and success flags. Diagnostics respect the user
   switch and never include typed content, candidates, credentials, tokens,
   sensitive URL components, IP, carrier, SSID, location or complete local path.
9. **Make diagnostics non-authoritative.** Complete SHA-256 values remain the
   integrity decision. Digest prefixes are only correlation hints. Diagnostics
   failure, disabled state or overload can reduce evidence but cannot change
   download, fallback, install or deploy behavior.
10. **Commit receipts only after deployment success.** Failed attempts and
    intermediate fallback sources never overwrite the last successful installed
    version/source/checksum receipt.
11. **Do not expand the installation transaction claim.** This decision adds a
    pre-install verification/recovery boundary only. ADR 0006 and TD-001 remain
    authoritative for the unresolved file-by-file installation risk.

## Alternatives Considered

- **Stop after every integrity mismatch:** secure but rejected as the permanent
  behavior because a damaged archive from one independently pinned source can be
  recovered without trusting unverified bytes.
- **Retry another source without proving cleanup:** rejected because failed
  content can survive across operation boundaries and cleanup errors would be
  silently ignored.
- **Try another source after staged-content mismatch:** rejected because it can
  hide manifest, allowlist or client-processing drift.
- **Infer equivalent sources from scheme/version or array membership:** rejected
  because source variants may differ materially despite sharing visible labels.
- **Log a free-form diagnostic string:** rejected by ADR 0027 privacy and
  schema-governance requirements.
- **Solve atomic installation in the same task:** rejected as unrelated scope;
  ADR 0006 / TD-001 remain open.

## Consequences

- The manifest gains an explicit staged identity and revision boundary.
- Temporary-item cleanup becomes a correctness barrier with injectable failure
  tests rather than best-effort housekeeping.
- Main-App state can present restrained progress while diagnostics retain exact
  content-free failure classification.
- A transiently corrupted source can recover automatically, while staged drift
  remains fail closed.
- New typed diagnostic codes/fields require ADR 0027 allowlist and privacy
  review.

## Risks

- A cleanup existence check without operation/source isolation could inspect or
  delete the wrong temporary item; unique operation paths and exact ownership
  remain mandatory.
- A stale or underspecified staged identity could incorrectly authorize source
  substitution; revisions and full hashes must change when admitted content or
  deterministic processing changes.
- Excess transition logging could create unnecessary I/O; events remain bounded
  and progress callbacks are not journaled individually.
- Diagnostics may be disabled or dropped; business correctness cannot depend on
  their presence.
- This recovery does not eliminate partial file-by-file installation risk.

## Follow-up Work

1. Record the exact implementation base and changed-file allowlist.
2. The accepted Entry design now binds the actor/state transition table, commit
   lease and ADR 0027 typed-event privacy allowlist; preserve those boundaries
   during implementation and reopen review if they expand.
3. Implement explicit staged identity, cleanup barrier, classified states and
   typed diagnostic events with failure injection.
4. Run affected and full stable-toolchain tests, then independent Architecture
   and Quality review.
5. Obtain exact-build Mainland physical-device evidence and Product Gate.

## Related Documents

- [`RIME-SCHEME-DELIVERY-INTEGRITY-001`](../../assignments/rime-scheme-delivery-integrity-001.md)
- [`Architecture pre-review`](../../assignments/rime-scheme-delivery-integrity-001-architecture-review.md)
- [`RIME-SCHEME-DELIVERY-001`](../../assignments/rime-scheme-delivery-001.md)
- [`Source-variant Product Decision`](../../product-decisions/RIME-SCHEME-DELIVERY-001-source-variants.md)
- [`ADR 0006`](0006-schema-install-transaction-model.md)
- [`ADR 0027`](0027-enterprise-local-diagnostic-observability.md)
- [`TD-001`](../../TECH_DEBT.md#td-001-atomic-schema-installation)
- [`2026-08-26 failure evidence`](../../evidence/rime-scheme-delivery-wanxiang-integrity-failure-2026-08-26.md)
