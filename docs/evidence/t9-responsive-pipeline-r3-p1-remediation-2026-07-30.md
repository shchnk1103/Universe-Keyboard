# T9-RESPONSIVE-PIPELINE-001 R3 P1 remediation

| Field | Value |
|---|---|
| Date | 2026-07-30 Asia/Shanghai |
| Fixes | Arch R3 P1-1 context/epoch; Arch/Quality P1-2 publish reentrancy |
| Open | Arch P1-3 off-main |

## Fixes

1. **Context lifecycle:** tag with `sessionEpoch`; clear on abandon / visibility reset; drop mismatched epochs on apply; only `pk-*` actionIDs consume FIFO.
2. **Reentrancy:** post-process uses `underlyingRimeEngine` + temporary rimeEngine swap; `withPublishHandlerSuppressed` during apply.

## Tests

- `testAbandonClearsResponsiveKeyApplyContexts`
- `testMultiKeyDrainDoesNotStealContextsViaNestedReplace`
- `testOrdPublishDoesNotConsumeProcessKeyContext`

## Verification

```bash
cd Packages/KeyboardCore && swift test --filter ResponsiveRime
# 38 tests, 0 failures

cd Packages/KeyboardCore && swift test
# (full suite)
```

Gate remains default off. Not Product Gate / ADR Accept.
