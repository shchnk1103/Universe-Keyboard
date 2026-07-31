# T9-RESPONSIVE-PIPELINE-001 R3 evidence

| Field | Value |
|---|---|
| Date | 2026-07-30 Asia/Shanghai |
| Auth | Product: Phase A then R3 implementation authorized |
| Gate default | off |

## Delivered

- Path/auto-anchor post-processing after deferred publish via `ResponsiveKeyApplyContext`
- `underlyingRimeEngine` for Extension chrome under bridge
- Tests: handle key→delete order; path presentation under gate

## Verification

```bash
cd Packages/KeyboardCore && swift test --filter ResponsiveRime
# 35 tests, 0 failures

cd Packages/KeyboardCore && swift test
# 813 tests, 0 failures
```

## Non-claims

Not Arch/Quality Pass for R3; not ADR Accept; not Product Gate; not off-main librime.
