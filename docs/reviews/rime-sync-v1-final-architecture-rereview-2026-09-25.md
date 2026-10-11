# RIME-SYNC-001 bounded iOS V1 — fresh Architecture re-review — 2026-09-25

## Verdict

**Accept with conditions** for the exact candidate and approved iOS V1
local-folder scope. No new code-level architecture blocker was found. Real
provider deletion evidence remains an open condition and `TD-002` remains an
open high-priority risk. The parent Assignment remains `Active`.

## Exact candidate and independence

| Item | Value |
|---|---|
| Worktree HEAD | `4a51228fc8e435d538e9a5f7342ae325502e1e66` |
| Candidate paths | 50 |
| Candidate manifest SHA-256 | `d95489524dba25cba13979f657f22e87cfd757aca3f5d70cae125efc5f4dec9b` |
| Excluded post-review receipts | This receipt and `rime-sync-v1-final-quality-review-2026-09-25.md` |

The reviewer independently recomputed the exact manifest and confirmed all 50
paths and the digest. This was a fresh, read-only reviewer runtime distinct
from the executor and Quality reviewer. It traced current source, contracts,
and tests; it did not modify files or run tests or behavior-changing
operations. The reviewer could not independently attest that its runtime was
using the requested `gpt-6-luna` model.

## Architecture review

- Standard RIME data remains Main-App-owned through the production RIME
  service; the Keyboard Extension does not take on synchronization or network
  work.
- Universe private settings remain on the separate encrypted transport path;
  Keychain secrets and WebDAV credentials retain their actor-owned secret
  store boundary.
- Local-folder selection and access use security-scoped URLs and file
  coordination. Deletion is constrained to the private package root and fails
  closed unless metadata identifies a directory; ViewModel state is preserved
  when deletion fails.
- The DEBUG UI fixture isolates defaults. Its local-folder integration route
  uses the production ViewModel, Keychain, RIME service and transport while
  suppressing test-run background scheduling.
- The full UI receipt provides 29 passes, 7 explicit specialized/opt-in skips
  and 0 failures. It is executor evidence, not provider-deletion evidence.

## Findings

| ID | Severity / disposition | Finding |
|---|---|---|
| `ARCH-RIME-SYNC-001-2026-09-25-R1` | P2, open evidence condition | The current UI suite verifies picker cancellation and first sync, not provider deletion. Existing deletion regressions exercise temporary local storage and injected metadata; actual Files/File Provider metadata and durable deletion propagation remain unknown. Obtain provider-specific evidence before parent closure. |
| `ARCH-RIME-SYNC-001-2026-09-25-R2` | P1, retained as `tech_debt:TD-002` | The process gate serializes Main-App transactions but does not prove cross-process exclusion against Keyboard Extension/librime access to `Rime/user`. Preserve the previously authorized technical-debt disposition; no mitigation or resolution is inferred. |

The deletion-boundary implementation and its failure-preservation tests are
consistent with the stated architecture; no additional code-level blocker was
identified in the bounded scope.

## Conditions and non-claims

This review is limited to the exact candidate's architecture and Simulator
local-folder scope. It does not establish provider-side deletion propagation,
live WebDAV, CloudKit, physical-device behavior for this snapshot, natural
BGTask delivery guarantees, cross-platform closure, debt resolution, Product
or lifecycle closure, merge, TestFlight or Release. `TD-002` remains open.
