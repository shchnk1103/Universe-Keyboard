# RIME-SYNC-001 Architecture re-review — local conditional publish P1 — 2026-09-23

## Verdict

**Accept** for remediation of `ARCH-RIME-SYNC-001-P1-01` only. The finding is
resolved in the exact source-and-test snapshot below. The original review's
non-blocking `ARCH-RIME-SYNC-001-P2-01` remains open. This is not a Quality
conclusion, Product Gate, merge, TestFlight, or Release approval.

## Exact review binding

- Worktree: isolated detached worktree
- Base `HEAD`: `4a51228fc8e435d538e9a5f7342ae325502e1e66`
- SHA-256 of `git diff --binary` for
  `Universe Keyboard/Services/RimeSyncTransport.swift` and
  `UniverseKeyboardTests/RimeSyncTests.swift`:
  `47e188bc26b65547f4bc4c4df3e49c8e42c923f3d0fc25cd2e6d5c44b4cb6a5a`
- Contract: [`RIME_SYNC.md`](../RIME_SYNC.md), local-folder conditional-write
  and stale-write protection
- Prior finding: [`Architecture review`](rime-sync-v1-architecture-review-2026-09-23.md)

## Finding disposition

### `ARCH-RIME-SYNC-001-P1-01` — resolved

`LocalFolderRimeSyncTransport.publish` now propagates settings-read errors
unless both the error domain and code identify Cocoa's confirmed
`fileReadNoSuchFile`. The digest/ETag comparison occurs before directory
creation or any package write. Thus an unreadable existing settings object
cannot be mistaken for absence when the expected ETag is `nil`, and cannot
cause a partial `format.json` write.

The tests preserve the initial missing-object publish and stale-ETag cases,
and add an existing-but-unreadable settings-path case that asserts failure and
absence of `format.json`.

The reviewer found no new issue in Swift concurrency isolation or the
Foundation error-domain/code check. The reviewer performed independent
read-only source review; test execution is recorded separately in the
Assignment/readiness evidence.

### `ARCH-RIME-SYNC-001-P2-01` — remains open

The prior diagnostic error-code stability concern was not changed or expanded
by this remediation. It remains a non-blocking follow-up as classified in the
original Architecture review.

## Review provenance and limits

Independent reviewer: Einstein (`gpt-6-luna`), distinct fresh reviewer
runtime. The reviewer independently inspected the two target files, contract,
and original review, and verified the exact diff digest. The reviewer did not
run tests or builds. Coordinator verification: focused local-folder tests
`2 passed`; full `Universe Keyboard` Debug Simulator suite on iPhone 18 Pro /
iOS 27.0 `386 passed, 10 skipped, 0 failed`; strict Swift formatting and
`git diff --check` passed.

This re-review closes only the identified P1 Architecture finding for the
bound snapshot. The earlier Quality `Pass with conditions` remains bound to
its previously reviewed candidate; a fresh Quality review is still needed for
the changed package before parent closure.
