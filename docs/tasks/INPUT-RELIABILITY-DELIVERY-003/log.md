# INPUT-RELIABILITY-DELIVERY-003 log

## CP-001 CHECKPOINT

- id: CP-001
- at: 2026-10-19T22:16:07+08:00
- lane: codex-batch3
- kind: CHECKPOINT
- note: Human named Codex initial Writer for this new task. No predecessor HANDOFF, no ACCEPT and no pending P. W=codex-batch3. Assignment/AUTH established; source remains untouched. Docs-only initial carrier sync is authorized; all product commits will remain local.

## CP-002 CHECKPOINT

- id: CP-002
- at: 2026-10-19T22:32:08+08:00
- lane: codex-batch3
- kind: CHECKPOINT
- note: Local product candidate 286d3e91c0cc0e94d1d439c10d799948abcb9a1f; W remains codex-batch3, P=none, no HANDOFF/ACCEPT. Final Core1277/0/0, Bridge97/0/20, App407/0/10, Keyboard49/0/0, hostless Extension35/0/0. R174 normal off and isolated explicit-test on verified; Debug test build/Release/strict lint passed. CI lightweight passed with pinned advisory KOS warnings; raw /private/tmp/ird003-evidence/lightweight.log sha256 cca5a2d60de9db622a3de6bb13ebfb7f91e7c6144d4b7d73e523abc41b3f42de. Preserve prior unchanged log-queue failure and skip/System Extension/native gaps in verification.md. Claude independent review not run; no Gate/Closeout/mergeability claim. Remote contains only CP-001 initialization; this checkpoint is intentionally local to avoid pushing product ancestry. Stop for Human; no message to Claude sent.

## REVIEW-001 REVIEW

- id: REVIEW-001
- at: 2026-10-19T23:40:37+08:00
- lane: codex-batch3
- kind: REVIEW
- by: claude-independent-reviewer
- independence: independent
- note: Human relayed Architecture Pass / Quality Partial / Ready for PR Preparation Yes; no explicit pre-PR blocker. Pointer: docs/evidence/input-reliability-delivery-003/independent-review-received.md. This Writer records receipt only, not a new review or Quality Pass. Human separately authorized product PR publication; no Merge/TestFlight/Closeout.

## CP-003 CHECKPOINT

- id: CP-003
- at: 2026-10-19T23:41:15+08:00
- lane: codex-batch3
- kind: CHECKPOINT
- note: Publication-stage records 8aae8b4409a9338266e21f2d2e7ace540455b045; reviewed source/test hashes unchanged from product 286d3e91c0cc0e94d1d439c10d799948abcb9a1f. W remains codex-batch3, P=none. Human now authorizes normal product push and PR/CI observation; prior local-only boundary superseded only for this slice. Claude Architecture Pass / Quality Partial / PR Preparation Yes received via Human. Current private path strings sanitized in live documents without history rewrite. Real T9 recovery and activated Extension system interaction are mandatory pre-TestFlight evidence items. No product edits, Merge/TestFlight/Closeout or fabricated HANDOFF/ACCEPT.

## CP-004 CHECKPOINT

- id: CP-004
- at: 2026-10-20T07:34:19+08:00
- lane: codex-batch3
- kind: CHECKPOINT
- note: Final bounded closeout. Closed Assignment/AUTH/receipt exist at 8c65edd98bc4ea17807fb67d6e7990ce5d6fce0e; this snapshot uses that actual existing parent as based_on. Verified PR215 MERGED, squash096183ca118cc40ffc16854d1a5336a42cfcbd89 in main, product hashes match; final product CI39279966879 SUCCESS on head2477472396d827ade9f08d88714c426da3f6d5c9. Claude Architecture Pass / Quality Partial / Ready for PR Preparation retained. Release gates A real librime T9 delete/retype and B activated Extension complete system interaction remain open; C R174 normal default off, future enablement requires new verification/AUTH. W=codex-batch3, P=none. No tests/source changes/HANDOFF/ACCEPT/history rewrite or cleanup. Explicit current Human exception preserves separate squash/main versus carrier history; section8.4 ancestry was not claimed. Normal push/remote audit only, then authority ends and session stops.
