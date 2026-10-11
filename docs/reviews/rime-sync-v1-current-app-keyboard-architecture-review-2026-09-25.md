# RIME-SYNC-001 — current App + Keyboard suite — fresh Architecture review — 2026-09-25

## Verdict

**Accept with conditions** for the approved iOS V1 local-folder architecture.
No new code-level architecture blocker was found. Provider deletion evidence
and `TD-002` remain open; the parent Assignment remains `Active`.

## Exact candidate and review method

| Item | Value |
|---|---|
| HEAD | `4a51228fc8e435d538e9a5f7342ae325502e1e66` |
| Candidate paths | 53 |
| Manifest SHA-256 | `c3a6ccfce8ab3803d414b6289b830ef98d47b63d8814817766f485e3d4ed8f5a` |
| Excluded post-review receipts | This Architecture receipt and `rime-sync-v1-current-app-keyboard-quality-review-2026-09-25.md` |

The reviewer independently computed the same 53-path digest. This was a fresh
read-only Architecture review, distinct from the executor and Quality
reviewer. It inspected current source, contracts, tests and scoped evidence;
it ran no tests and made no file or Simulator changes. The reviewer could not
independently verify the runtime model identity.

## Architecture boundaries

- Main-App ViewModel owns sync orchestration. Standard RIME sync goes through
  the production RIME service with security-scoped access and file
  coordination; the Keyboard Extension and typing hot path do not perform sync
  or networking.
- Universe private settings use a separate encrypted package and Keychain
  secret store. The local-folder transport is restricted to the private
  `universe-rime-sync` package path; live WebDAV remains deferred to `TD-019`.
- Deletion is fail-closed for unknown or non-directory package-root metadata.
  Local credentials/configuration are cleared only after transport deletion
  succeeds, so failures preserve retry state.
- UI fixture isolation disables test-run background scheduling while the
  production integration path uses the production ViewModel, Keychain, RIME
  service and local-folder transport.
- The 401-result App + Keyboard run and 401-ID exact native enumeration add
  engineering evidence, not provider-side deletion evidence. MCP's 402
  preflight count remains an unexplained, unaccepted exact-run residual.

## Findings

| ID | Severity / disposition | Finding |
|---|---|---|
| `ARCH-RIME-SYNC-001-CURRENT-2026-09-25-R1` | P2, open; `fix` evidence before close | Real Files/File Provider metadata and durable deletion propagation remain unverified. Existing tests use temporary local storage/injected metadata; the current UI full-sync case does not test deletion. |
| `ARCH-RIME-SYNC-001-CURRENT-2026-09-25-R2` | P1, retain as `tech_debt:TD-002` | The process gate serializes Main-App transactions but does not prove cross-process exclusion from Keyboard Extension/librime access to `Rime/user`. Keep `TD-002` open; no mitigation or safety claim is inferred. |
| `ARCH-RIME-SYNC-001-CURRENT-2026-09-25-R3` | P2, fix before parent close | Assignment Current Status still presents the previous 397/387 run and old 44-path Architecture conclusion as current, despite newer run evidence and state mirrors. Synchronize it under KOS 2.1 M-01 while retaining historical results. |

The reviewer found the stated Main-App/Extension, RIME-standard/private
package and transport ownership boundaries coherent for the scoped candidate.

## Non-claims

This review does not establish provider deletion propagation, live WebDAV,
CloudKit, physical-device behavior for this snapshot, natural BGTask delivery,
cross-platform closure, debt resolution, Product or lifecycle closure, merge,
TestFlight or Release. Ten skipped tests remain skipped.
