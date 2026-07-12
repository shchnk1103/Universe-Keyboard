# Release Checklist

## Scope

This is the minimum release gate for the main App and Keyboard Extension. It does not certify App Store approval or replace release-specific risk review.

Documentation review for a release follows `docs/DOCUMENTATION_GOVERNANCE.md`; this checklist owns release evidence, not architecture rationale or historical status.

## Record Before Starting

- release commit/tag candidate;
- Xcode and Swift versions;
- iOS simulator and physical-device versions;
- pinned RIME artifact version and manifest digest;
- active schemas used for acceptance;
- known skipped checks with owner and reason.

Do not report a historical user/thread statement as current release evidence.

## Minimum Acceptance Matrix

For the current development phase, record results for:

- the current primary physical development device;
- the current development iOS version on that device;
- one available iOS Simulator used consistently for automated tests.

This is intentionally a minimum matrix, not a compatibility claim. Expand it before broader TestFlight distribution or App Store submission.

## TestFlight Debt And Risk Decision

The following unresolved contracts must be classified for the exact TestFlight scope before the release decision. “Accepted risk” is permitted only for a narrowly scoped internal TestFlight build with explicit approval from the human product/release owner; an agent, domain owner or test owner cannot accept the risk. Record the decision, owner, scope, evidence, expiry and follow-up in the release acceptance record, and link the relevant `TECH_DEBT.md` item or ADR. Release-relevant limitations must also be recorded in `CHANGELOG.md`.

| Item | Default decision before TestFlight | Allowed exception | Required record |
|---|---|---|---|
| TD-003 Extension performance baseline | **Blocker** for broader external TestFlight because regressions cannot be evaluated without comparable evidence. | **Accepted risk** only for a limited internal build after collecting current-device cold-start, representative key-path, candidate and memory evidence with no unexplained regression. It is not `not applicable` to an Extension release. | Release acceptance record + TD-003 link + human approval + evidence location/expiry. |
| TD-004 Full Access degradation matrix | **Blocker** for external testing that claims setup/degradation is self-diagnosing or includes Full Access off/on coverage. | **Scoped skip** only when the build is explicitly limited to testers instructed to enable Full Access and no claim is made about degraded behavior; otherwise a limited internal build requires explicit accepted-risk approval. | Release acceptance record + tested access scope + tester constraint + TD-004 link + human approval when risk is accepted. |
| TD-005 crash/jetsam/symbolication handbook | **Blocker** for broader external TestFlight when the exact archive/dSYM cannot be retained or termination reports cannot be mapped back to the build. | **Accepted risk** only for a limited internal build when the exact archive and dSYM are retained and a named owner can collect device/Organizer reports despite the incomplete handbook. It is not `not applicable` to an Extension release. | Release acceptance record + archive/dSYM location + report owner + TD-005 link + human approval/expiry. |
| ADR 0005 user-dictionary restore safety | **Blocker** whenever restore remains exposed or is included in the TestFlight test scope, because the current implementation does not yet enforce the accepted pre-restore safety backup. | **Scoped skip** only if restore is unavailable/disabled and explicitly excluded from the build and test instructions. Exposed destructive restore cannot be converted to accepted risk by agent judgment. | Release acceptance record + ADR 0005/TD-007 link + proof of scope exclusion; record the user-visible limitation in `CHANGELOG.md`. |

An unexplained omission is neither a scoped skip nor an accepted risk and blocks TestFlight. `Not applicable` may be used only when repository evidence proves the affected capability is absent from the release artifact; the reason and evidence must be recorded in the same acceptance record.

## Repository And Artifacts

- [ ] Working tree contains only intended release changes.
- [ ] `git diff --check` passes.
- [ ] No `.bak`, `.DS_Store`, generated archives or credentials are included.
- [ ] `bash scripts/ensure_rime_vendor.sh verify` passes.
- [ ] `config/rime-vendor-manifest.env` matches the documented pinned release.
- [ ] Licenses for project code, librime, OpenCC and downloadable schemes are present and user-facing acceptance remains correct.

## Automated Verification

```bash
swift test --package-path Packages/KeyboardCore

xcodebuild -project "Universe Keyboard.xcodeproj" \
  -scheme "Universe Keyboard" \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO SWIFT_STRICT_CONCURRENCY=complete \
  SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build

xcodebuild -project "Universe Keyboard.xcodeproj" \
  -scheme "Universe Keyboard" \
  -configuration Release \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO SWIFT_STRICT_CONCURRENCY=complete \
  SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build
```

Tests require a concrete installed simulator. Discover one with `xcrun simctl list devices available`, then run both schemes against the same destination:

```bash
xcodebuild -project "Universe Keyboard.xcodeproj" \
  -scheme "RimeBridgeTests" \
  -destination 'platform=iOS Simulator,name=<installed device>' \
  CODE_SIGNING_ALLOWED=NO SWIFT_STRICT_CONCURRENCY=complete \
  SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES test

xcodebuild -project "Universe Keyboard.xcodeproj" \
  -scheme "Universe Keyboard" \
  -destination 'platform=iOS Simulator,name=<installed device>' \
  CODE_SIGNING_ALLOWED=NO SWIFT_STRICT_CONCURRENCY=complete \
  SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES test
```

Do not hardcode or publish test counts. Preserve the command result and failing test names as evidence.

## Main App Acceptance

- [ ] Fresh launch and keyboard-enablement guide are usable.
- [ ] Full Access explanation remains accurate.
- [ ] Built-in schema can be prepared and deployed.
- [ ] `rime_ice` download/install/license/deploy path succeeds when included in the release scope.
- [ ] Scheme switch, redownload/update and uninstall states are coherent.
- [ ] Candidate count, simplification, fuzzy pinyin and advanced-input changes mark/apply deployment correctly.
- [ ] User-dictionary learning switch, backup, restore and reset behave correctly for supported schemas.
- [ ] Diagnostics can filter, refresh, copy and clear without exposing private host text.
- [ ] Global operation toast survives navigation and duplicate actions are guarded.
- [ ] Typing Intelligence covers disabled, empty, active and safe-error states.
- [ ] Today/7-day/30-day/all-time totals, trend, composition and streak match controlled fixtures.
- [ ] Typing Intelligence enable/disable is explicit and clear permanently removes local aggregates.
- [ ] Privacy & Data copy matches current behavior, bundled manifests and App Store privacy answers.

## Keyboard Acceptance On A Physical Device

- [ ] Enable the extension and Full Access; record device and OS.
- [ ] First presentation creates a working session without deploying.
- [ ] Chinese and English basic input, page/mode switching, Shift/Caps Lock and Return labels work.
- [ ] Inline preedit underline appears and clears after candidate, Space and Return commits.
- [ ] Return commits raw input for segmented preedit; no duplicate text remains.
- [ ] Delete edits composition first and Partial Commit restore matches its documented contract.
- [ ] Candidate horizontal paging, near-edge fetch and expanded panel remain stable.
- [ ] Switching host apps discards unfinished composition and starts clean on return.
- [ ] Killing/relaunching the Extension creates a fresh session from deployed data.
- [ ] Session recovery does not invoke deployment or block a key event with file work.
- [ ] Light/dark mode, VoiceOver, Dynamic Type and compact keyboard height remain usable.
- [ ] Key sound/haptic settings refresh and do not double-fire.
- [ ] Typing Intelligence counts candidate, Space, Return, direct key, direct text and Emoji commits exactly once.
- [ ] Marked-text updates, Delete and visibility abandonment do not increment statistics.
- [ ] Full Access off keeps basic typing usable and does not claim shared statistics are active.
- [ ] Extension process death loses at most a bounded pending batch and resumes from a valid snapshot.

## RIME, Lua And OpenCC

OpenCC current integration ownership is defined in
[`architecture/opencc-integration.md`](architecture/opencc-integration.md); this checklist owns release evidence only.

- [ ] `luna_pinyin` and `rime_ice` (when shipped) produce representative candidates.
- [ ] Active schema survives fresh keyboard process creation.
- [ ] Simplified/traditional switching is verified through deployed OpenCC data.
- [ ] Fuzzy-pinyin enabled/disabled examples match `docs/RIME_FUZZY_PINYIN.md`.
- [ ] Lua runtime smoke test is executed with a real prepared fixture for release claims.
- [ ] Lua failures identify whether capability, schema, files, deployment or runtime output failed.
- [ ] Extension remains usable when Lua capability is unavailable or a scheme is incomplete.

## Lifecycle, Performance And Failure Recovery

- [ ] No synchronous download, file scan, hash, backup or deployment occurs in key handling.
- [ ] Engine initialization and representative key/UI performance logs show no unexplained regression against the previous accepted build.
- [ ] No sustained memory growth is observed during typing, candidate paging and repeated app switching.
- [ ] Missing runtime directories produce fallback plus actionable main-App recovery.
- [ ] Failed deployment remains pending and succeeds after retry.
- [ ] Interrupted/incomplete scheme installation is recoverable by main-App reinstall/redownload.
- [ ] Typing Intelligence classification/enqueue adds no unexplained key-path regression against the disabled baseline.
- [ ] Typing Intelligence persistence is coalesced, bounded and absent from synchronous key handling.
- [ ] Reset epoch prevents delayed writes from restoring cleared statistics.

The project does not yet have numeric Extension latency or memory budgets. Follow `docs/PERFORMANCE_BASELINE.md`, record real measurements and regressions, and do not mark this section passed solely because no crash was observed.

## Privacy And App Store Metadata

- [ ] Main App and Keyboard Extension bundles contain valid `PrivacyInfo.xcprivacy` files.
- [ ] Required Reason API declarations match the final binary API inventory and approved reasons.
- [ ] `NSPrivacyCollectedDataTypes` and App Store privacy answers reflect off-device collection, not merely local processing.
- [ ] No keyboard text, surrounding text, candidates, user dictionary, diagnostics or Typing Intelligence aggregates leave the device.
- [ ] No analytics, advertising or tracking SDK receives keyboard-derived data.
- [ ] The in-app privacy page and externally hosted privacy-policy URL match `docs/PRIVACY_POLICY.md`.
- [ ] App Review notes explain Full Access, local RIME resources and on-device Typing Intelligence in plain language.
- [ ] Current App Review Guidelines are rechecked at submission time; prior review behavior is not treated as a guarantee.

## Documentation And Release Record

- [ ] README feature status matches current behavior and contains no hardcoded test count.
- [ ] `CHANGELOG.md` records the release-relevant behavior and known limitations.
- [ ] Architecture docs are updated when an invariant or ownership boundary changed.
- [ ] Completed plans remain marked archived and are not presented as current truth.
- [ ] Manual acceptance evidence is written into the repository with commit/device/OS/schema details.
- [ ] Every skipped gate is explicit; an unexplained skip blocks release.
