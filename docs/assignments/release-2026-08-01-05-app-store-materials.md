# Assignment: RELEASE-2026-0801-05 — 隐私、支持与 App Store 上架材料

**Policy version:** `1.0.0`
**Lifecycle status:** `Active — contacts/privacy/export/age/content-rights/category complete; screenshots/copy/What to Test pending`
**Parent:** [`RELEASE-2026-0801`](release-2026-08-01.md)

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Active` |
| **Phase** | 联系信息、隐私、出口、年龄、内容版权与主要类别已完成；按方案许可证披露/确认已实现并通过 Human UI Gate |
| **Non-claims** | 内容版权与主要类别为 Human-reported 在线保存，执行方未打开 App Store Connect 复核；Phase A 派生收据已接受，但不是精确来源声明；模拟器 test runner 受 Xcode 27 beta 环境阻塞；未上传 build、创建测试组、提交 Beta Review 或冻结 RC |
| **Next** | 其余 App Store 材料（截图、文案、What to Test）仍待 RC/上传后补齐；颜表情对外句子对照 [`08→05 卡`](../evidence/release-2026-08-01-08-handoff-to-05-copy-constraints.md)。08 Human Product Gate 已过，商店主文案可以使用卡上 §3，仍须带 §6 |
| **Residuals** | [`2026-08-22 TestFlight metadata audit`](../evidence/release-2026-08-01-05-testflight-metadata-audit-2026-08-22.md) § Human Input Gate; [`2026-08-23 third-party notice provenance`](../evidence/release-2026-08-01-05-third-party-notice-provenance-2026-08-23.md) § Residuals；08 颜表情卖点在 Product Gate 前禁止 |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner, acting as Product Lead, authorized the current Codex task to select and perform KOS-compatible remaining release execution roles in the active Codex task, `2026-07-20 Asia/Shanghai`; on `2026-08-22 Asia/Shanghai`, explicitly authorized the current task to audit and fill fact-supported external TestFlight information and update KOS handoff documents
- **Product Approver:** Human Product Owner acting as Product Lead

## Assignment

- **Domain Owner:** 📱 App & Data Operations Maintainer
- **Executor:** Current Codex task acting as 📱 App & Data Operations materials thread
- **Environment Executor:** Current Codex task for local copy/material and final-binary consistency preparation; the Human Product Owner remains the required App Store Connect account operator for account-bound actions
- **Human Dependency:** Human Product Owner — provides legal/support/contact answers, account access, metadata approval and separate submission authorization
- **Architecture Reviewer:** 🏛️ Architecture & Knowledge Steward for privacy/data/export-compliance consistency
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer for final-binary and metadata consistency
- **Handoff Target:** Product Lead for submission authorization; umbrella release coordinator

## Boundary

- **Scope:** First prepare the external TestFlight Beta App Description, Feedback Email, What to Test, review contact/instructions and export-compliance inputs; then publish and link the privacy policy and prepare support/contact/about/license surfaces, App Privacy, privacy manifests, screenshots, descriptions, age rating, availability and remaining App Store Connect fields against final behavior.
- **Non-goals:** No legal guarantees by an AI, no unsupported marketing claim, no account action or submission without explicit authorization, and no collection of credentials in repository evidence.
- **Required Inputs:** [`PD-RELEASE-2026-0801-EXTERNAL-TESTFLIGHT-CANDIDATE`](../product-decisions/RELEASE-2026-0801-external-testflight-candidate.md); final scope; final archive for binary consistency; privacy policy; Privacy manifests; dependency/license inventory; supported-device decision; App Store Connect access for online verification; current Apple submission requirements.

## Gates

- **Entry Criteria:** Executors named; external TestFlight metadata preparation may start from owner-approved copy/contact inputs; final online verification requires frozen scope/archive, public URLs/contacts and account access; no required field needed by the active phase is `UNKNOWN`.
- **Exit Criteria:** Public privacy/support URLs work; in-app links and final behavior agree; screenshots cover every supported family; metadata/review notes are accurate; privacy/export/license answers are reviewed; submission-readiness checklist has no unexplained omission.
- **Stop Conditions:** Policy and behavior conflict; unsupported claim; required legal/contact answer missing; credentials would enter logs/repo; iPad remains supported without required material; submission requested without explicit approval.

## Handoff

- **Required Handoff Content:** approved copy, public URLs, screenshot inventory, privacy/export/license assessment, App Store field status, review instructions, unresolved legal/product questions and submission authorization state
- **Revalidation Trigger:** release scope/binary, privacy behavior, dependency inventory, supported devices, public URL, App Store metadata or Apple requirement changes

## Execution Record — 2026-08-22

- App Store Connect App identity verified: `Universe Keyboard`, Apple ID `6804236252`, Bundle ID `com.DoubleShy0N.Universe-Keyboard`, primary language Simplified Chinese.
- No-distribution Xcode Cloud Build 3 archived and signed `main` commit `4fd3ce7` successfully with Xcode 26.6 / macOS 26.6.2. This is a pilot, not final RC evidence.
- TestFlight Beta App Description and Beta Review Notes were saved; login remains not required.
- Feedback email, Beta Review contacts and public privacy URL remain `UNKNOWN`/blocked. Build-specific What to Test remains a prepared template because no TestFlight build exists.
- App Privacy is not started; export compliance, content rights, primary category and age rating remain human/legal/product gates.
- Canonical evidence and next-thread handoff: [`release-2026-08-01-05-testflight-metadata-audit-2026-08-22.md`](../evidence/release-2026-08-01-05-testflight-metadata-audit-2026-08-22.md).

## Execution Record — 2026-08-23

- Human Product Owner confirmed TestFlight feedback/review contacts were saved; repository evidence intentionally omits personal values.
- Human Product Owner confirmed the public privacy URL and `No data collected` App Privacy response were published. UniverseWeb page-copy cleanup is independent and not reverified here.
- Current App Information shows no encryption-document record, no primary category and no content-rights answer. It displays a global `4+` age rating, but the underlying answers remain unreviewed.
- Bounded implementation audit found Apple CryptoKit `ChaChaPoly`, URLSession/TLS, Keychain and SHA-256 use; no proprietary/non-standard or separately linked vendor encryption implementation was found.
- Human Product Owner explicitly authorized the recommended declaration. `config/Info.plist` now sets `ITSAppUsesNonExemptEncryption = NO`; `plutil` validation and an Xcode 27 beta Release Simulator build both passed, and the built App plist contains `false`.
- No encryption documentation, build or review submission was uploaded. Human retains responsibility for the possible year-end self-classification obligation and future revalidation; the beta-toolchain build is local integration evidence, not final stable RC evidence.
- Human Product Owner confirmed the age-rating questionnaire was completed; App Store Connect displays global `4+`, with regional equivalents including Brazil `AL`, Korea `全部` and Vietnam `00+`.
- On `2026-08-23 Asia/Shanghai`, Human Product Owner reported saving primary category `工具` and secondary category `效率` in App Store Connect. The executor did not reopen App Store Connect to verify the saved values.
- Content-rights audit confirmed bundled/downloadable third-party RIME content. The main App now reads per-scheme license descriptors for download/update/redownload, persists acknowledgement by scheme and disclosure revision, and exposes a durable “开源软件与内容” page. Rime-ice is `GPL-3.0-only`; Wanxiang is `CC BY 4.0`.
- Xcode 27 beta generic Simulator Debug/Release builds and Swift 6 `build-for-testing` passed. The focused offline-resource XCTest passed on iPhone 17 Pro / iOS 26.0. A later complete `SchemaManagerTests` run passed eight tests, then hit a native hosted-process `malloc` invalid-free crash and repeated after restart; the run was interrupted and is not claimed as a suite pass.
- The repository-supported App Store Connect content-rights answer is “Yes, the app contains or accesses third-party content and has the necessary rights.” Human Product Owner accepted the two remaining exact-source residuals as an external-candidate residual under [`PD-RELEASE-2026-0801-05-PROVENANCE-A-ACCEPT`](../product-decisions/RELEASE-2026-0801-05-provenance-a-accept.md), then reported saving that content-rights answer, primary category `工具` and secondary category `效率`. The executor did not reopen App Store Connect to verify the fields.
- Human Product Owner subsequently verified all three UI surfaces: rime-ice shows `GPL-3.0-only`, Wanxiang shows `CC BY 4.0`, and “开源软件与内容” opens every expected list/detail path. The license-disclosure UI Product Gate is `Pass`.
- Offline notice/full-text resources are implemented. Retained clean build trees and byte-identical device archives recovered exact inputs for librime, glog, LevelDB, yaml-cpp, OpenCC, MARISA and Boost; Lua 5.4.8 is fixed by shipped headers and the official source-package checksum. Phase A further bound `librime-lua` to upstream `ec52e48…` plus a local empty OpenCC stub with 9/10 exact object matches across all shipped architectures. The remaining `types.o` object uses `re_detail_500`; official Boost.Regex 1.88.0 (500) and 1.89.0 (600) were tested against the fixed compile receipt and did not match SHA-256. Luna is exactly derived from official `rime/brise` blob `728f883…` by one Chewing attribution-URL update. Product Lead accepted those receipts; see [`PD-RELEASE-2026-0801-05-PROVENANCE-A-ACCEPT`](../product-decisions/RELEASE-2026-0801-05-provenance-a-accept.md).
- The built Debug App contains all 15 catalogued offline notice files. The focused catalog-to-bundle XCTest passed; Luna directly exposes LGPL-3.0, the referenced GPLv3 and its separate composite-dictionary attribution record.

## Execution Record — 2026-08-24

- 08 Executor drafted a first-party kaomoji copy-constraint card for 05: [`release-2026-08-01-08-handoff-to-05-copy-constraints.md`](../evidence/release-2026-08-01-08-handoff-to-05-copy-constraints.md). Human Product Owner accepted the card the same day. Store/TestFlight sentences about 颜表情 must follow that card. What to Test may use §3 with §6 limits; App Store marketing/screenshot hero copy still waits on 08 Human Product Gate. Content-rights Yes remains RIME/scheme-based and must not be rewritten because of the kaomoji table. The card is not filled-in App Store Connect copy.
