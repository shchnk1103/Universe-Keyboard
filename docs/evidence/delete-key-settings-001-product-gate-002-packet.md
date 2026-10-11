# DELETE-KEY-SETTINGS-001 Product Gate 002 packet

Packet digest: bb87845bfee9dc78950200843eb9c5ed4e2d3e637159efaa44c318b030d299bf

Digest method: SHA-256 of this file's UTF-8 bytes after the Packet digest hex is replaced by sixty-four ASCII zero digits. Any other digest is a mismatch.

| Field | Value |
|---|---|
| Work item | `DELETE-KEY-SETTINGS-001` |
| Base commit | `141bc8ebcee456cfac8f8c826da9d6ce4e9e5b4f` |
| Worktree | `/private/tmp/universe-keyboard-delete-key-settings-001` |
| Branch | `grok/delete-key-settings-001` |
| Authorization | `AUTH-DELETE-KEY-SETTINGS-001-PRODUCT-GATE-002` |
| Prior gate | Consumed `AUTH-DELETE-KEY-SETTINGS-001-PRODUCT-GATE`. Verdict Partial / incomplete. Digest `f1458883619b20b2aa2970d6b812ae2a33b27ed394b7ac8a4dddf5c4d5883b1a`. Do not rewrite it |
| Reviewer | Independent Grok 4.7 subagent. Not the Executor. Not a resume of the first gate |
| Budget | One pass. At most 40 tool calls. No second pass |
| Exhaustion | Stop and record Partial / incomplete. Not Pass and not Pass with conditions |
| Output | `docs/reviews/delete-key-settings-001-product-gate-002.md` only |
| Device | No install. Do not claim a Human device observation |

## Scope

Judge the current uncommitted bytes against [`PD-DELETE-KEY-SETTINGS-001`](../product-decisions/DELETE-KEY-SETTINGS-001-product-contract.md). The first gate's reading notes are not this verdict. Quality Pass digest `69b35d41d078a79cabdc46e4c65202a571c2098dd6b7984b80d5d67e15d9b610` is prior evidence. Do not re-run `swift test` or `xcodebuild`. A skipped re-run is not a Fail.

The eleven product rows below still match the Quality freeze. Navigation and assignment hashes differ from both the Quality packet and the first Product Gate packet, because status was mirrored after those freezes. Do not Fail only because those docs hashes differ from an older packet. Do Fail if a hash mismatches this packet.

Architecture digest `517c13ebb83545f62d8ddc976c61ea70f4feeaa0ec03c44a35381f85857d3068` does not cover the return-to-key edit. Do not rewrite that review, the Quality review, the first Product Gate review, or any earlier packet.

Hash the table with one `shasum` command. Do not hash files one tool call at a time.

## Questions

Answer each from the current bytes. A miss is Pass with conditions only when the residual is named, owned, and dispositioned `fix`, `accept`, or `tech_debt:<ID>`. A contract break that the page would ship wrong is Fail. If every question matches, the verdict is Pass.

1. Placement is 设置 → 输入体验 → 删除键, after 键盘反馈. Not App 设置, not 键盘布局, not 键盘反馈. Search can open the same page.
2. Exactly three switches. Copy matches the contract table. No long-press switch and no lecture that long-press exists.
3. Missing UserDefaults key means on. `bool(forKey:)` alone is not the load path. Keyboard reads flags once at delete-key touchDown.
4. Tap delete and long-press repeat stay available. Timing 0.5s / 0.08s / 0.15s is unchanged.
5. Scrub on keeps V1, including the about 6 pt gap and about 10 pt horizontal lock already on origin/main.
6. Scrub off and trash off: leaving the key stops this press. Already-deleted graphemes stay. Lift does not add a tap delete. Re-entering without lift does not resume.
7. Scrub off and trash on: the gap is still a corridor. Entering the bubble and lifting clears. Stopping in the gap, moving elsewhere, or sliding back onto the key ends the press: keep deletes, no more repeat, no clear. Return-to-key cannot arm a second clear on the same press.
8. Composing never shows the bubble. Abandon on drops remaining preedit only. Abandon off and scrub off is stop-this-press. Abandon off and scrub on does not abandon and does not scrub committed text.
9. Horizontal movement that stays on the key while scrub is off does not stop long-press.
10. Sound and haptics stay on 键盘反馈. Cancel or stop adds no extra sound. The 256 grapheme cap and unreadable-context hide stay out of the settings copy and stay in the behavior.
11. 26-key, 9-key, English, number, and symbol share the three flags.
12. CHANGELOG for this behavior is in the same uncommitted slice.
13. This slice does not rewrite the frozen DELETE-KEY-SCRUB-001 contract. Closed residuals DKS-CLOSE-01, DKS-CLOSE-02, DKS-GATE-HOST-01, and DKS-GATE-BLUR-01 stay disclosed. This Gate does not newly claim WeChat, Safari, password fields, or pre-iOS 26 blur on a device.
14. Non-claims stay explicit: not Close, commit, push, PR, merge, TestFlight, or Release. The first gate's Partial is not a Pass, and this page must not rewrite that review into one.

## Stop

Stop as Fail if the page or gesture contradicts the locked contract. Do not edit the product to make it pass. Do not consume this AUTH. Assignment Authority and Product Approver remain the Human Product Owner. The reviewer records the Gate. The reviewer is not a device observer.

## File hashes

| Path | SHA-256 |
|---|---|
| `Packages/KeyboardCore/Sources/KeyboardCore/DeleteKeyHoldSettings.swift` | `963e6742816cb49c429d1f2a434ade865fdf592d02c103654f07d06c11f25916` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DeleteKeyHoldSettingsTests.swift` | `988fb98f5d95234abfcb5c772b17acb7caf56bde19c501b49255cb4e2c1a18aa` |
| `Universe Keyboard/Views/Settings/DeleteKeySettingsView.swift` | `327349176516b06c65b1997112be3ace23e99754a78a4e8592e6953abf79609d` |
| `Keyboard/Controllers/DeleteKeyGestureSession.swift` | `faa3227fd489f36ad0800221d60e9f401a0211fa1f3f3b40fbcc84b323c02dfb` |
| `Keyboard/Controllers/KeyboardViewController+DeleteActions.swift` | `c8a3d88f4495508274875f8b59262b1a26b12d21ab4efd232e786aca5d8868e4` |
| `KeyboardTests/DeleteKeyScrubContractTests.swift` | `977e1882cd5a34931449890ddd7be296fd2bcc5250f4ed7e17b8f65b760882de` |
| `Universe Keyboard/Models/SettingsSearchCatalog.swift` | `ea7a3f366d77e088a89822feea7461b28df1c93934a56e90aa4b1579d2461973` |
| `Universe Keyboard/Views/Search/SearchTab.swift` | `df32810907f9fc4fc7cee30e84a00941ae7c8a489dda38c19335a2cf13c4d655` |
| `Universe Keyboard/Views/Settings/SettingsTab.swift` | `19651c5fc32654fa71463c77e01ef7bbf1b72cbf433124c730cb172e18c5f884` |
| `CHANGELOG.md` | `0428337c214c74e5a357821127f51611427f7ec165b11be9c7c018e49ec9d055` |
| `docs/product-decisions/DELETE-KEY-SETTINGS-001-product-contract.md` | `24044947b1243c597b142cc9f3d6542cccab7bb70b48be30b40decc78043315a` |
| `docs/assignments/delete-key-settings-001.md` | `091aeb6c91e5f24703410943f6511e4462b55c06f7176c631d883b8238503414` |
| `docs/ACTIVE_WORK.md` | `cf18981027a7aa9dd86296ff77a9c997f0ed2384f733c8160ee174fff1273498` |
| `docs/ENGINEERING_DASHBOARD.md` | `616875d82536345be331f55061947e5708272a9254d00fdb9e0393cf599764c7` |
| `docs/KNOWLEDGE_INDEX.md` | `b0c431ce678faa9fc3984bdac18f10824823b2d2dea93c8170e4e429efdcd291` |
| `docs/READING_MAPS.md` | `04552452a86992ff0a5c1bf286f8e0902a64f00435217916ca9663d0c6a5705d` |
| `docs/reviews/delete-key-settings-001-architecture-review.md` | `76ae46050e980146bb0b849949a4f500c738655c5a8dcff5f871287f90f03656` |
| `docs/reviews/delete-key-settings-001-quality-review.md` | `877b84e802a9b156a67f00bdef2949aab25cd3a82449bd3f20161cc42161d975` |
| `docs/reviews/delete-key-settings-001-product-gate.md` | `784f9a63c3aad777391071407f0b29425d2443d0b09095655dc6991055e6db6c` |
| `docs/authorizations/AUTH-DELETE-KEY-SETTINGS-001-IMPLEMENT.md` | `cb54d80ec22e1fdd5c0f84715dea5950e08db40393ee63858b2260e113b05b9b` |
| `docs/authorizations/AUTH-DELETE-KEY-SETTINGS-001-ARCHITECTURE.md` | `0f0cd0ead5ec46354484ca31f42b71aced01f8e4b80edcbc1aac62fe3e8356a9` |
| `docs/authorizations/AUTH-DELETE-KEY-SETTINGS-001-QUALITY.md` | `115a933a6c9bbd40a04e8ca11aa1ad9c96e038d1f9d38f38f11d281d29b72063` |
| `docs/authorizations/AUTH-DELETE-KEY-SETTINGS-001-PRODUCT-GATE.md` | `ca0a08024d8eaf5bda8b6a2c2fa738d714754584dd45530cde80fdc610d40187` |
| `docs/evidence/delete-key-settings-001-architecture-packet.md` | `93de4f017eb1c6d6d1ea42ca15dc6a955c65006db203795b4174c726dd7bd3b9` |
| `docs/evidence/delete-key-settings-001-quality-packet.md` | `e13429d60d756673347068860cbcd001ddf36cb89ac20b2cd1869264f266f941` |
| `docs/evidence/delete-key-settings-001-product-gate-packet.md` | `93d480e19bc1a2d1264057a83f8814d773771a5734a4ce4d46f4710b883fc152` |
| `docs/authorizations/AUTH-DELETE-KEY-SETTINGS-001-PRODUCT-GATE-002.md` | `e67e65bbcc4f3ea4829dc5d713549cdd653e736eee7c98b3ba9d65794ed808a6` |
