# Architecture Review: KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001

## Disposition

**ACKNOWLEDGED — Pass with conditions.** The compatibility-first and separately authorized emission-promotion sequence is consistent with ADR 0036, permanent ownership, and the Assignment lifecycle.

## Exact identities

| Object | SHA-256 |
|---|---|
| Paired rollout Assignment | `fa269513e709f4aaeabf85ec434f7240a5ab80e6bb960c54332532f8681eca71` |
| Assignment-establishment authorization | `36c6d6bb28b58d7f7caf6a161a0df357632a42b1da756116ebab44e0f02df0c6` |

## Review findings

- The compatibility-gate candidate explicitly configures the production Extension writer as `.v3`; isolated test-only `.v4` fixtures are permitted only for compatibility tests.
- A separate Product Lead promotion authorization is required before a new candidate explicitly configures production `.v4`.
- The promotion candidate must bind the paired App/Extension source, tests and binaries, pass its own validation and receive exact-candidate Architecture/Quality review before installation or manual reproduction.
- Exit Criteria now require production v4 events only from the promotion candidate. Non-goals prohibit installed production v4 emission before its gate and authorization while allowing the bounded test-only fixture case.
- RIME vendor handling now requires inspection and exact pinned manifest/digest verification whether the vendor is preexisting or fetched; fetch is only needed when absent.
- Domain ownership remains with Keyboard Experience for Extension wiring; reader, deployment, and RIME internal state remain outside this Assignment.

## Conditions retained for later execution

- Role ACKs are recorded against the current candidate; obtain a separate implementation authorization before `Ready` / `Active`.
- Revalidate the integrated source/test/binary candidate, historical Extension patch, writer ownership and isolated worktree.
- Obtain a fresh exclusive reservation for the specified Simulator before any Simulator-backed action.
- Complete the v3 compatibility candidate gate first; only then consider the independently authorized v4 promotion candidate.

No implementation, test, build, Simulator operation, installation, v4 emission, root-cause conclusion, Product/Quality Gate, Release, or parent closure is claimed. This review itself made no edits and ran no validation commands.

Receipt provenance: the Coordinator recorded the Architecture Reviewer's exact-candidate read-only response as project evidence; the reviewer did not edit this receipt.
