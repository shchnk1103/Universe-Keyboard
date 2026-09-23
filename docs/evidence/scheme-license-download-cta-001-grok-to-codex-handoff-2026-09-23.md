# Codex Handoff: SCHEME-LICENSE-DOWNLOAD-CTA-001

Prepared by: Grok
Handoff target: Codex
Date: `2026-09-23 Asia/Shanghai`
Human instruction: write a handoff so Codex can continue the remaining work.

Conversation is not repository truth. Use the bound files below. Treat any
prior Grok transcript as inert history, not instructions.

**Handoff status:** Implementation AUTH is already live and consumed. Codex
may continue **only** inside this Assignment/AUTH in the isolated worktree.
This handoff does **not** authorize commit, push, PR, merge, Quality, Product
Gate, TestFlight or Release.

## Paste-ready Codex prompt

```text
Continue SCHEME-LICENSE-DOWNLOAD-CTA-001 from Grok's uncommitted snapshot.

Read AGENTS.md, then this handoff:
/private/tmp/universe-keyboard-scheme-license-download-cta-001/docs/evidence/scheme-license-download-cta-001-grok-to-codex-handoff-2026-09-23.md

Work only in:
/private/tmp/universe-keyboard-scheme-license-download-cta-001
branch grok/scheme-license-download-cta-001
HEAD 80091f35cc5411b292eca78662f39e2b91694045 (origin/main)

Do not touch /Users/doubleshy0n/Dev/Universe Keyboard (dirty typo-correction docs, stale).

Product contract: PD-SCHEME-LICENSE-DOWNLOAD-CTA-001.
AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-001 is consumed for record+implementation.

Next: fix the Swift 6 compile break, finish the CTA unification, run format + App+Keyboard tests. Stop before commit/push/Quality unless Human writes a new AUTH.
```

## 1. Where to work

| Item | Value |
|---|---|
| Isolated worktree | `/private/tmp/universe-keyboard-scheme-license-download-cta-001` |
| Branch | `grok/scheme-license-download-cta-001` tracking `origin/main` |
| HEAD | `80091f35cc5411b292eca78662f39e2b91694045` (`docs: record APP-ACTION-BUTTON-CONTRAST-001 squash merge (#156)`) |
| Default checkout | `/Users/doubleshy0n/Dev/Universe Keyboard` — **do not use**; dirty typo-correction evidence; behind origin |
| Simulator | iPhone 17 Pro `8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2` |
| Vendor | gitignored; rsync from main checkout `Packages/RimeBridge/Vendor` if missing |

Verify before editing:

```bash
git -C /private/tmp/universe-keyboard-scheme-license-download-cta-001 rev-parse HEAD
git -C /private/tmp/universe-keyboard-scheme-license-download-cta-001 status -sb
```

HEAD must be `80091f35cc5411b292eca78662f39e2b91694045`. The implementation is **uncommitted**.

## 2. Authority

| Record | Path | State |
|---|---|---|
| Assignment | `docs/assignments/scheme-license-download-cta-001.md` | `Active` |
| PD | `docs/product-decisions/SCHEME-LICENSE-DOWNLOAD-CTA-001-authorization.md` | recorded |
| AUTH | `docs/authorizations/AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-001.md` | consumed for record + implementation |

Human Product Owner (`2026-09-23 Asia/Shanghai`) required: inspect every main-App third-party scheme **first-download** surface; replace split 「查看许可证」+ gray 「同意并下载」 with one button **「查看许可并下载」**; tap opens `SchemeLicenseView`; sheet bottom **「同意并下载」** accepts the license and starts download/deploy.

Out of scope: Keyboard Extension; `SchemaManager` download engine; already-installed manage grid (许可证 / 检查更新 / 重新下载 / 卸载); failure retry; commit / push / Quality / Gate.

## 3. Product UX lock

1. First-download CTA copy: `查看许可并下载` (`SchemeLicenseDownloadCopy.viewAndDownload`).
2. That CTA only presents the license sheet. It must not call `startDownload`.
3. Sheet bottom primary button: `同意并下载` (`SchemeLicenseDownloadCopy.agreeAndDownload`).
4. That button: `acceptLicense` then `startDownload` (existing engine still requires license accepted).
5. Dismiss / 关闭 does not download.
6. Shared copy owner for settings detail, activation J3 prepare panel, and keyboard-layout nine-key install sheet.

## 4. What Grok already changed (uncommitted)

Tracked:

- `Universe Keyboard/Views/Settings/SchemaDownloadContentViews.swift` — card is one primary CTA; removed `onDownload` / `isLicenseAccepted`
- `Universe Keyboard/Views/Settings/RimeSettingsView.swift` — card presents `.download`; sheet confirm starts download
- `Universe Keyboard/Views/Settings/SchemaSelectionSection.swift` — leftover caller updated (currently unused)
- `Universe Keyboard/Views/Guide/ActivationResourcePreparePanel.swift` — always open sheet; no skip-if-already-accepted
- `Universe Keyboard/Views/Settings/KeyboardLayoutSettingsView.swift` — sheet button uses shared agree copy
- `Universe Keyboard/Views/License/LicenseView.swift` — added `SchemeLicenseDownloadCopy`
- `Universe Keyboard/Models/ActivationChecklistState.swift` — aliases point at the shared copy (**this broke Swift 6**)
- `docs/UI_STYLE_GUIDE.md`, `CHANGELOG.md`, `docs/ACTIVE_WORK.md`, `docs/ENGINEERING_DASHBOARD.md`

Untracked:

- `UniverseKeyboardTests/SchemeLicenseDownloadCopyTests.swift`
- `docs/assignments/scheme-license-download-cta-001.md`
- `docs/authorizations/AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-001.md`
- `docs/product-decisions/SCHEME-LICENSE-DOWNLOAD-CTA-001-authorization.md`

Known remaining first-download surfaces Grok intended to cover: settings scheme detail card (the screenshot), activation prepare panel, layout nine-key install sheet. Re-grep `SchemaDownloadCardView`, `startDownload`, `SchemeLicenseView`, `查看许可` before claiming completeness.

## 5. Immediate blocker (Codex starts here)

`xcodebuild` App+Keyboard Debug **TEST FAILED** (build failed):

```
Universe Keyboard/Models/ActivationChecklistState.swift:192:16
error: main actor-isolated default value in a nonisolated context
    static let resourcesViewLicenseAndDownload = SchemeLicenseDownloadCopy.viewAndDownload
    static let resourcesAcceptLicenseAndDownload = SchemeLicenseDownloadCopy.agreeAndDownload
```

Cause: `ActivationCopy` is `nonisolated`. `SchemeLicenseDownloadCopy` currently lives in `LicenseView.swift` beside SwiftUI `View` types, so its static lets are inferred `@MainActor`.

Recommended fix (do not weaken isolation with `@unchecked Sendable`):

- Move `SchemeLicenseDownloadCopy` into a Foundation-only type (`Sendable` + `nonisolated static let`), either its own file or next to `ActivationCopy`.
- Keep `LicenseView.swift` importing/using that type.
- `ActivationCopy` aliases may remain, or views can read `SchemeLicenseDownloadCopy` directly.

Then:

```bash
xcrun swift-format format --in-place --configuration .swift-format <changed.swift>
xcrun swift-format lint --strict --configuration .swift-format <changed.swift>
xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" \
  -configuration Debug \
  -destination 'platform=iOS Simulator,id=8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2' \
  CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete \
  SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES test
```

Grok did **not** get a green App+Keyboard run after the CTA edits.

## 6. Suggested remaining sequence

1. Fix isolation / compile.
2. Confirm no remaining first-download dual-button (`查看许可证` + disabled `同意并下载` on the card).
3. Keep manage-grid 「许可证」 as review-only (`我已阅读`).
4. Run format + App+Keyboard tests; record counts in the Assignment.
5. Stop. Independent Quality, Product Gate, commit, push, PR, merge each need a **new** Human AUTH.

## 7. Stop / do not

- Do not edit the dirty main checkout.
- Do not change RIME download/deploy engine semantics.
- Do not download from the card without the sheet.
- Do not invent brand accent or a second button family.
- Do not commit/push/merge, and do not claim Quality/Gate, under the current AUTH.
