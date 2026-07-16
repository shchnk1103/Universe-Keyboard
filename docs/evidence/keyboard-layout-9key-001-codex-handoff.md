# KEYBOARD-LAYOUT-9KEY-001 — Codex Handoff (Re-review Exit Package)

Prepared by: Grok (Executor)
Handoff target: Codex (Architecture + Quality review)
Date: 2026-07-16 Asia/Shanghai
Branch: `feature/keyboard-layout-9key-spike`
Assignment lifecycle: **`Ready`** (not Active; product steps 3–10 not started)

## Authority (KOS 2.0)

| Item | Source |
|---|---|
| Product Decision Source | [`PD-KEYBOARD-LAYOUT-9KEY-001`](../product-decisions/KEYBOARD-LAYOUT-9KEY-001-authorization.md) |
| Assignment | [`../assignments/keyboard-layout-9key-001.md`](../assignments/keyboard-layout-9key-001.md) |
| ADR (architecture accepted) | [`../architecture/decisions/0018-keyboard-layout-nine-key-and-t9-runtime.md`](../architecture/decisions/0018-keyboard-layout-nine-key-and-t9-runtime.md) |
| First Codex review (immutable) | [`keyboard-layout-9key-001-codex-review.md`](keyboard-layout-9key-001-codex-review.md) |
| Codex amendment re-review | [`keyboard-layout-9key-001-codex-rereview.md`](keyboard-layout-9key-001-codex-rereview.md) |

Conversation is not repository truth. Product authority is the Product Decision record above.

## Re-review blocking findings — closure map

| ID | Finding | Resolution |
|---|---|---|
| P1 | Decision Source lacked stable identifier | Added `docs/product-decisions/KEYBOARD-LAYOUT-9KEY-001-authorization.md` (`PD-KEYBOARD-LAYOUT-9KEY-001`); Assignment Decision Source points only to that record |
| P1 | Executor modified Codex historical review | Restored `keyboard-layout-9key-001-codex-review.md` to the exact Codex-authored content from commit `ad5da19` (no Executor banner) |
| P1 | Full raw xcodebuild log not transferable | Added `docs/evidence/keyboard-layout-9key-001/xcodebuild-t9-spike.log.gz`; recorded raw and `.gz` SHA-256 in `archive-hashes.md` |
| P2 | Harness cleanliness too narrow | Spike runner now requires entire tracked worktree clean vs HEAD (`git diff-index`), rejects untracked package/app/test sources, records porcelain status digest |

## Spike transferable archive

Directory: `docs/evidence/keyboard-layout-9key-001/`

| Artifact | Role |
|---|---|
| `xcodebuild-t9-spike.log.gz` | Complete raw xcodebuild log (compressed) |
| `xcodebuild-t9-spike-excerpt.log` | Concise excerpt for quick review |
| `rime-vendor-verify.log` | Vendor verify log |
| `archive-hashes.md` | Raw + compressed + vendor + schema digests |
| `provenance.md` / `spike-result.md` | Run provenance and result |
| `upstream-t9.schema.yaml` / `patched-t9.schema.yaml` | Schema fixtures |

### Hashes

- Decompressed raw log SHA-256: `784ac88f775d414cc7f181f55e9c7cdb0127b00c8d9d68a79eb59097c7ebe651`
- Compressed `.gz` SHA-256: `724303a0b3d22783766bcd9e1b1bc76290dc81d79f1c5c5afe7e363ddca8e181`
- Vendor verify log SHA-256: `03fd59b207427813f241bb2217f226ac161e682885d370421269bff6e51b17e4`
- Harness commit: `337dd30ab443ad2d2af497648910946d6beb1a35`

Verify without local `evidence/`:

```bash
gunzip -c docs/evidence/keyboard-layout-9key-001/xcodebuild-t9-spike.log.gz | shasum -a 256
# expect 784ac88f775d414cc7f181f55e9c7cdb0127b00c8d9d68a79eb59097c7ebe651
```

## Explicit non-goals of this package

- No product implementation steps 3–10
- No Assignment transition to `Active`
- No KeyboardCore / Extension / main-App product code
- No rewrite of Codex re-review conclusions

## Requested Codex next decision

1. Confirm the three P1s and one P2 are closed.
2. Confirm transferable evidence archive is accepted.
3. If accepted, authorize Assignment `Ready -> Active` for plan steps 3–10 under ADR 0018 (still no librime upgrade).
