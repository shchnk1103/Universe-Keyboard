# Independent review: Cross-scheme CS09-10-01 production installer inventory

Date: 2026-09-08 Asia/Shanghai
Review type: independent read-only delta review
Reviewed candidate: `078307e` relative to `5e527b7`
Verdict: **Pass with conditions**

## Review result

The prior P1 is closed. Both CS09-10-01 tests explicitly use
`installFullIcePinnedIntoShared` and `installFullWanxiangPinnedIntoShared`; a
missing fixed extract tree causes `XCTSkip` instead of silently falling back to
the selected-file fixture. The recorded focused result is 2/2 passed and the
full App + Keyboard result is 348 passed, 4 skipped.

The tests exercise the production `SharedContainerSchemaArchiveInstaller` with
the full local fixed extract trees. After each target uninstall, they assert
all retained snapshot bytes and a `Rime/user` sentinel remain intact. Wanxiang
dynamic Lua ownership uses the same static-plan plus exact-hash rule as the
production installer, so matching `lua/data/chaifen.txt` is correctly treated
as target-owned.

## Conditions and residuals

- **P2:** the tests build the expected retained inventory from the post-install
  tree; they do not separately assert every source plan-admitted path was
  installed or record an expected path count.
- **P2:** the test-side ownership oracle mirrors, rather than directly reads,
  the production dynamic ownership decision. Existing tests separately cover
  changed bytes, unknown paths, and symlinks.
- **P3:** retained-inventory checks do not reject extra post-uninstall files or
  assert staging-root absence.
- **P3:** skipped tests remain possible where fixed trees are unavailable;
  this is local fixed-tree evidence only.

This review closes the CS09-10-01 automation inventory condition within those
limits. It does not prove archive provenance, real RIME input, App Group or
device behavior; `CS09-10-02` remains open. It does not authorize push,
undraft/merge, TestFlight, App Release, Product Gate, or ADR acceptance.
