# RIME-SYNC-001 P1 remediation fresh Architecture re-review — 2026-09-24

## Verdict

**Blocked.** The previously reported `ARCH-RIME-SYNC-001-FINAL-P1-01`
false-success path is addressed by this candidate: lookup errors propagate,
confirmed absence is distinct, and the ViewModel retains local settings and
secrets when deletion fails. The three targeted simulator tests pass.

This review found a new deletion-boundary issue, `ARCH-RIME-SYNC-001-FINAL-P2-02`:
the lookup asks for `.isDirectoryKey` but discards the returned
`URLResourceValues`, returning `true` whenever the lookup itself does not throw.
The subsequent `removeItem` can therefore remove an object at the reserved
`universe-rime-sync` path without confirming it is a directory. A same-name
ordinary file could be deleted as if it were the managed package.

## Exact snapshot binding

- Worktree: `/Users/doubleshy0n/.codex/worktrees/rime-sync-docs-close-20260923/Universe Keyboard`
- `HEAD`: `4a51228fc8e435d538e9a5f7342ae325502e1e66`
- Changed/untracked paths: `41`
- Manifest algorithm: sorted union of `git diff --name-only --no-renames` and
  `git ls-files --others --exclude-standard`; each entry is SHA-256 of file
  bytes followed by two spaces, path, and newline; SHA-256 of concatenation.
- Manifest SHA-256:
  `d30dfd56937e3c98a8883937468ffe918fb53ee4fe3f232ae2aa1bcb0e5d5f1e`
- The reviewer independently recomputed the manifest and obtained the same
  value. This receipt is excluded from the bound candidate.

## Review method and evidence

- Fresh independent read-only review by a separate GPT-6 Luna Architecture
  reviewer (agent `01a0d386-eb53-7df3-9776-c3273af82cdc`); the reviewer did not
  author the implementation or this receipt and made no file changes.
- Reviewed local-folder deletion behavior, ViewModel failure handling,
  regression tests, RIME synchronization contract and prior final Architecture
  finding. The reviewer verified the supplied `.xcresult` for iPhone 18 Pro / iOS
  27.0 Simulator: 3 passed, 0 failed, 0 skipped.
- Relevant code: `Universe Keyboard/Services/RimeSyncTransport.swift:236-245`
  and `:280-285`; regression coverage:
  `UniverseKeyboardTests/RimeSyncTests.swift:126-185` and `:714-748`.
- Apple's API documents `URLResourceValues.isDirectory` as `Bool?`, and that
  resource properties may be `nil` when unavailable; requesting resource values
  may return an object whose corresponding property is nil. See [isDirectory](https://developer.apple.com/documentation/foundation/urlresourcevalues/isdirectory)
  and [resourceValues(forKeys:)](https://developer.apple.com/documentation/foundation/url/resourcevalues%28forkeys%3A%29?language=_4).

## Findings and required disposition

### `ARCH-RIME-SYNC-001-FINAL-P1-01`

The prior ambiguity between confirmed missing and inaccessible/unknown is
addressed in this candidate. The throwing lookup propagates errors other than
the explicit no-such-file cases; the ViewModel does not clear local settings or
secrets when the transport throws. Regression tests cover injected access
failure, confirmed missing path, and successful scoped removal. This finding is
not sufficient for Architecture Accept while the new P2 below remains open.

### `ARCH-RIME-SYNC-001-FINAL-P2-02` — deletion does not verify package-root type

**Priority: P2 · Open · Architecture remains Blocked.**

The default `packageRootPresence` closure at `RimeSyncTransport.swift:236-239`
ignores the `URLResourceValues` it requested and returns `true` after any
nonthrowing lookup. `URLResourceValues.isDirectory` is optional. Consequently,
an unknown `nil` value or a confirmed `false` is not distinguished from a
confirmed directory before `removeItem` at `:284-285`.

**Required remediation:** only delete after confirming `isDirectory == true`;
unknown metadata must fail closed, and a confirmed non-directory object must
not be deleted. Add regressions proving that (1) a regular file at the reserved
package-root name remains untouched and deletion fails, and (2) unknown
directory metadata fails while preserving the object and ViewModel configuration
and secrets. Then request a fresh Architecture re-review of the new exact
snapshot.

## Non-claims

This simulator review does not prove deletion propagation by a real document
provider or WebDAV server. It is not a full-suite/hosted-CI result, physical
device acceptance, Product Gate, Release decision, or Assignment lifecycle
transition. `RIME-SYNC-001` remains `Active`; no merge or publication is implied.
