# Frozen Quality Review Packet — CANDIDATE-BAR-IDLE-DISMISS-001 Round 1

| Field | Frozen value |
|---|---|
| Work Item | `CANDIDATE-BAR-IDLE-DISMISS-001` |
| Stable lane ID | `CANDIDATE-BAR-IDLE-DISMISS-001-QUALITY-001` |
| Review round | `1` |
| Reviewer | Fresh, independent Quality, Performance & Release Maintainer runtime. Must not be the Executor who implemented idle dismiss. Record reviewer identity in both outputs. |
| Source baseline | Dirty isolated worktree `/private/tmp/universe-keyboard-candidate-bar-idle-dismiss-001` on branch `grok/candidate-bar-idle-dismiss-001`, `HEAD` `fbb4eb3bbbc2926ff6e248db9dcdfdf6a331f821` = `origin/main`. No implementation commit. Pin working-tree SHA-256 of slice files, not a commit. |
| Packet digest | `5adecb81985d91de0022471e74702181975c332589cac149643285da69718c28` — replace this row's value with SHA-256 of the full UTF-8 packet after replacing that value with 64 ASCII `0` characters. The reviewer must independently reproduce it. |
| Assignment authority / expansion owner | Human Product Owner acting as Product Lead |
| Decision source | Human 2026-09-28 Asia/Shanghai: confirm AUTH live, record and implement; white-plate fix; then “先保持现状，授权独立 Quality。” |
| Required outputs | `docs/reviews/candidate-bar-idle-dismiss-001-quality-review.md` and `docs/evidence/candidate-bar-idle-dismiss-001-quality-review-usage.md` |

## Review question

Does the uncommitted isolated-worktree implementation satisfy `PD-CANDIDATE-BAR-IDLE-DISMISS-001` for the dual-mode trailing candidate-bar control (expand vs dismiss, swipe, AX, template idle icon), without filling system rounded-corner host bleed?

## Claims and complete-coverage criteria

For every claim, report `Pass`, `Pass with conditions`, `Blocker`, or `Uncovered`. Complete review requires an explicit result for all eight claims.

1. **One trailing control.** Existing 56 pt slot stays. Expandable content uses `chevron.down` and expands. Idle uses template `chevron.down.circle` and `dismissKeyboard()`. No second button. No candidate-bar height change.
2. **Expandable content.** `CandidateKind.expandsCandidateBarPanel` is true for candidate, composition, correction, continuation, punctuation, kaomoji; false for placeholder. Continuation keeps expand.
3. **Gestures and panel.** `allowsSwipeToExpand` only in expand mode. Expanded panel still collapses with up-chevron. Swipe does not dismiss.
4. **Idle icon compositing.** Trailing button is `UIButton(type: .custom)` + `.alwaysTemplate`. `updateExpandButtonAppearance` sets `configuration = nil`. No `UIButton.Configuration` on the trailing button.
5. **Accessibility.** Expand / collapse / dismiss labels and hints switch with mode.
6. **Tests.** Independently re-run `xcrun swift-format lint --strict` on the changed Swift files in the identity table; `swift test --package-path Packages/KeyboardCore --filter CandidateKindTests`; then CI-equivalent `Universe Keyboard` Debug test on `platform=iOS Simulator,id=D3C353BE-3AA6-499B-8F87-349073D65BE4` (iPhone 17, iOS 26.0). Do not reuse Executor counts. Do not target iPhone 17 Pro `8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2`.
7. **KeyboardCore boundary.** Only the `expandsCandidateBarPanel` classification is added. Candidate generation, continuation contract, and RimeBridge are unchanged. `git diff -- Packages/RimeBridge/` empty except Vendor if present.
8. **Non-claims and deferred follow-up.** Verdict must not grant Product Gate, Device-attested, commit, push, merge, TestFlight, or Release. Human-attested Simulator glance of dismiss is not this lane. Top-left/right rounded-corner host bleed in light mode is **out of Assignment scope**; Human directed keep-current and follow-up after Close. Classify as residual `accept` (`CBID-CORNER` or similar). Do not implement it.

For each `Pass with conditions`, name residual ID, owner, disposition (`fix` / `accept` / `tech_debt:<ID>`), and pointer. Exhaustion with uncovered required claims is `Partial / incomplete`.

## Frozen working-tree identities (SHA-256 of workspace bytes)

| Path | SHA-256 |
|---|---|
| `Keyboard/Views/CandidateBar/CandidateBarView.swift` | `606b5553c14f86f1963116b977bcb5ccb905e9c64515273a581f98a74fab95de` |
| `Keyboard/Controllers/KeyboardViewController+CandidateBar.swift` | `8f1284ae6329d9c59e27be9866dcdf74717482f3f0c0c5a856df55bd72687c6c` |
| `Keyboard/Controllers/KeyboardViewController+ExpandedCandidatePanel.swift` | `0177c7750f017f978773f6bfd3c739be17f2228936369ee6ba1aef7e9c6d301f` |
| `Packages/KeyboardCore/Sources/KeyboardCore/CandidateItem.swift` | `e08a0d59d7cf6506b1c1344450166c530d852a5279e935eeb5e973693d150200` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/CandidateKindTests.swift` | `316bcbaacb70e630884cb6144ff048a3778c5ae171e675cf6aa6de29532ed394` |
| `KeyboardTests/CandidateBarIdleDismissContractTests.swift` | `bafa0a0bf677adc7188486a8e4b191a115d2588ac161719198d5d666937fa93c` |
| `docs/UI_STYLE_GUIDE.md` | `446012957516d9608184bf0649c6e77c78b1fb7f19d7b58819a10e997eb17558` |
| `docs/assignments/candidate-bar-idle-dismiss-001.md` | `642211a055137f766ceae21e696390474327b0037531e6635d11381823e391be` |
| `docs/product-decisions/CANDIDATE-BAR-IDLE-DISMISS-001-authorization.md` | `b75e9de164801a3130a1f9e6e017fd030c9955494e345172e3759b5f5f9c8c58` |
| `docs/authorizations/AUTH-CANDIDATE-BAR-IDLE-DISMISS-001.md` | `5bbc40d20aad30ff2d1da927c64d26b2d02bffcccc1ef977ea2588c57cba92bf` |
| `docs/authorizations/AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-IMPLEMENT.md` | `41fe0a62ee24a63b73b61251b347a6571f35d7ce190adad41808017716b06a4b` |
| `CHANGELOG.md` | `03bfda10829c3c2ead43e269eb1009028f7db2b024ac43e3e5f8f1755e0776d5` |
| `docs/PROJECT_CONTEXT.md` | `c435ddf7fba05769ec976b703ad8b510e43eeb45e4092bca006872ec4968a263` |

If any of these bytes differ at review start, stop before evaluating claims.

## Frozen read/write boundary

Read: this packet, AUTH-QUALITY, Assignment, PD, implement AUTH, the files in the identity table, `docs/playbooks/test-release.md`, `docs/playbooks/keyboard-ui.md`, `docs/POST_COMMIT_CONTINUATION.md`, and read-only greps of `Keyboard/**/*.swift` plus `Packages/KeyboardCore`. Independently hash the identity-table files.

Write **only** the two required outputs. Do not edit product Swift, tests, Assignment Current Status, AUTH consumption, packet, or status mirrors. No Git commit/push/PR. Simulator boot for the named iPhone 17 `xcodebuild test` is allowed. Do not boot or target iPhone 17 Pro `8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2`. No TestFlight, App Store, or network publication.

## Budget, checkpoints and exhaustion

- Maximum: **40 tool calls or 60 active minutes**, whichever comes first.
- Checkpoint at start and after every **10 tool calls or 15 active minutes**, whichever comes first.
- Record reviewer identity, start/end time, actual tool-call count, elapsed active time, checkpoint notes, claims covered, remaining claims and stop reason. Token usage `unknown` if unavailable.
- On exhaustion, stop with `Partial / incomplete`.

No Product Gate, commit, push, merge, TestFlight, Release, Assignment Close, or corner-bleed implementation is part of this review lane.
