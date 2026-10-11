# Execution evidence: TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-001

Recorded: `2026-09-22T09:19:12+08:00 Asia/Shanghai`

## Authorization consumption and input copy

Current Codex task consumed
[`AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-CODEX-EXECUTION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-CODEX-EXECUTION-001.md)
after creating the isolated worktree:

`/Users/doubleshy0n/.codex/worktrees/typo-correction-002-runtime-integration-hardening-001/Universe Keyboard`

The worktree branch is
`codex/typo-correction-002-runtime-integration-hardening-001`.

Before source edits, both the preserved implementation worktree and the copied
worktree matched all authorized source bindings:

| Binding | Verified value |
|---|---|
| HEAD | `4d1050f4b677494e06448cb40a83ef2da46d7b27` |
| Tree | `5f864a6f6f139810ed59c7e00ab6c33caad7e500` |
| Tracked `git diff` SHA-256 | `d1366181e0436242211aa496934792e90a6ab1b0454608f0e1c3dd5a17ef4c1b` |
| 15 changed-file byte-concatenation SHA-256 | `4b701835f070e2c337fd2d3b76b67813e7e5722bdaa7db1b82faa7e00d2c891e` |
| Preserved pure-Core checkpoint diff SHA-256 | `8bb105c5381feb43fc41ec168fd239fd7c864cc0efa739cae3976beb685ebbab` |

The original implementation worktree and original pure-Core checkpoint were
read-only during this copy. This record is an execution-start receipt, not a
test result or product claim; verification results and residual disposition are
added only after the authorized hardening work completes.

## F-01 entrypoint scope supplement

Before any source edit, source inspection established that the Assignment's
named page-toggle and input-mode entry points live in
`Keyboard/Controllers/KeyboardViewController+ModeActions.swift`, a path absent
from the consumed execution receipt's allowlist. The current Product direction
already authorized this exact F-01 behavior, but KOS requires the discovered
path to be explicit. Current Codex task therefore recorded and consumed the
narrow, single-path
[`AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-F01-ENTRYPOINT-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-F01-ENTRYPOINT-001.md)
before editing that file.

This supplement does not expand the implementation behavior, authorize a
capture or Run ID, or create any QA-001, INT-003, performance, publication or
Gate claim.

## Local test dependency environment

The new isolated worktree intentionally lacked the ignored
`Packages/RimeBridge/Vendor` directory. Consequently, the first local
`RimeBridgeTests` attempt could not resolve binary targets. The preserved
implementation worktree was then checked without modification:

| Check | Result |
|---|---|
| Preserved tracked-diff SHA-256 | `d1366181e0436242211aa496934792e90a6ab1b0454608f0e1c3dd5a17ef4c1b` |
| `scripts/ensure_rime_vendor.sh verify` | 12 structural framework artifacts verified |
| Pure-Core preservation diff SHA-256 | `8bb105c5381feb43fc41ec168fd239fd7c864cc0efa739cae3976beb685ebbab` |

No vendor contents are fetched, copied, changed or deployed. The consumed
[`local test dependency receipt`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-LOCAL-TEST-ENVIRONMENT-001.md)
permits only an ignored symbolic link in the hardening worktree to resolve
local build dependencies. It creates no real-RIME, simulator/device, candidate,
QA-001, INT-003, performance, publication or Gate evidence.

## Bounded hardening result and local verification

The exact hardening delta against the preserved implementation worktree is
SHA-256 `003c2e004764f96a83fa437262ac49e1b34952a13e523aa2ee9d7fe6d595a319`.
Only the following authorized source files received new hardening changes:

- `Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift`
- `Keyboard/Controllers/KeyboardViewController+TypoCorrection.swift`
- `Keyboard/Controllers/KeyboardViewController+ModeActions.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionSidecarOwner.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+TypoCorrection.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionRuntimeIntegrationTests.swift`

The changes are deliberately narrow:

1. The yielded RunLoop continuation re-enters `MainActor` through `Task` rather
   than calling an actor-isolated method directly.
2. Empty recall material returns without changing correction display state, and
   a candidate-bar refresh occurs only when material actually changed display
   state under a still-current fence.
3. Recall invalidates before sidecar owner reinstallation, page toggles and
   input-mode toggles (including no-composition mode toggles).
4. The installed sidecar owner tracks the controller-owned recall lifetime;
   the legacy hot path returns before any `state.typoCorrection` write while
   that lifetime is active.

| Verification | Result |
|---|---|
| `swift-format format` + strict lint on all six changed Swift files | Pass |
| `swift test --package-path Packages/KeyboardCore` | Pass — 1152 tests, 0 failures |
| `RimeBridgeTests`, iPhone 17 Pro / iOS 26, Swift 6 strict / warnings-as-errors | Pass — 102 tests, 20 pre-existing environment-conditioned skips, 0 failures |
| App + Keyboard, same simulator and strict configuration | Pass — UniverseKeyboardTests 373 / 9 skipped; KeyboardTests 15 / 0 skipped; 0 failures |
| `git diff --check` | Pass |
| Preserved implementation tracked diff / pure-Core checkpoint | Still `d1366181…` / `8bb105c…` respectively |

The first RimeBridge command named `iPhone 17 Pro` without an installed OS
version and returned destination-not-found. It was retried only with the exact
available simulator UDID `8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2` (iOS 26); no
app installation, keyboard selection, text entry, capture or Run ID occurred.
After the tests, the temporary ignored `Packages/RimeBridge/Vendor` symbolic
link was removed. The hardening worktree retains no Vendor directory or vendor
byte copy.

### Residual and non-claims

- Independent [`Architecture review`](../reviews/typo-correction-002-runtime-integration-hardening-architecture-review-2026-09-22.md) independently reproduced the hardening-delta recipe and returned `Blocker`. It found incomplete canary/P3D1 invalidate-first ordering, yielded-callback stale ownership, fallback unique-writer proof, and three-route adapter/no-bypass proof. This execution evidence is therefore not eligible for Quality review or publication.
- The ignored `Vendor` symlink is a local build dependency only and is not a
  source artifact, vendor update, deployment or real-RIME fixture.
- This local test result proves compilation and specified unit contracts, not
  a real-RIME candidate, QA-001, INT-003, paired performance, 180 ms behavior,
  product Gate, publication, release or Assignment closure.
- Independent Architecture review must examine the exact delta before
  independent Quality review or any publication request.
