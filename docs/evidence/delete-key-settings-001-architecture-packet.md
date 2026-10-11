# DELETE-KEY-SETTINGS-001 Architecture packet

Packet digest: 517c13ebb83545f62d8ddc976c61ea70f4feeaa0ec03c44a35381f85857d3068

Digest method: SHA-256 of this file's UTF-8 bytes after the Packet digest hex is replaced by sixty-four ASCII zero digits. Any other digest is a mismatch.

| Field | Value |
|---|---|
| Work item | `DELETE-KEY-SETTINGS-001` |
| Base commit | `141bc8ebcee456cfac8f8c826da9d6ce4e9e5b4f` |
| Worktree | `/private/tmp/universe-keyboard-delete-key-settings-001` |
| Branch | `grok/delete-key-settings-001` |
| Authorization | `AUTH-DELETE-KEY-SETTINGS-001-ARCHITECTURE` |
| Reviewer | Independent Grok 4.7 subagent. Not the Executor |
| Budget | One pass. At most 40 tool calls. No second pass |
| Exhaustion | Stop and record Partial / incomplete. Not Pass and not Pass with conditions |
| Output | `docs/reviews/delete-key-settings-001-architecture-review.md` only |
| Usage record | A section in that same review |

## Scope

Judge the uncommitted slice against [`PD-DELETE-KEY-SETTINGS-001`](../product-decisions/DELETE-KEY-SETTINGS-001-product-contract.md). Read the files below. Do not treat Executor test counts as architecture fact.

In scope:

- Settings placement, the three switches, default-on when the key is missing, and the absence of a long-press control.
- One read of the three flags at delete touchDown.
- Scrub off, trash on, and composing-abandon combinations, including the gap above the delete key.
- Scrub on still uses the existing V1 hold. `touchDragExit` still does not end that hold.
- No new host write path, no `selectAll`, no upload of host text, no change to 0.5s / 0.08s / 0.15s, no rewrite of the frozen scrub contract.

## Stop

Stop the review as Reject if the slice changes tap or long-press timing, adds a long-press switch, rewrites [`DELETE-KEY-SCRUB-001-product-contract`](../product-decisions/DELETE-KEY-SCRUB-001-product-contract.md), calls `selectAll`, logs or uploads host text, or adds a host write path. Do not expand scope. Assignment Authority is the Human Product Owner.

## File hashes

| Path | SHA-256 |
|---|---|
| `Packages/KeyboardCore/Sources/KeyboardCore/DeleteKeyHoldSettings.swift` | `33304ae6bdfaf8fdcc36223ed376e3fd734e325edacb32dcfac227878eeeb355` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DeleteKeyHoldSettingsTests.swift` | `e1ad5670fcaf0c33cccb7817ad397bd474ec22ea444cfaec15504b6d3b972670` |
| `Universe Keyboard/Views/Settings/DeleteKeySettingsView.swift` | `327349176516b06c65b1997112be3ace23e99754a78a4e8592e6953abf79609d` |
| `Keyboard/Controllers/DeleteKeyGestureSession.swift` | `d7c98faecdb962a464fa0bb6253771d0772f41b1b89aa3dfbcdce02ac618ce37` |
| `Keyboard/Controllers/KeyboardViewController+DeleteActions.swift` | `e7ded6be823a42a3ba7d9389494bcaa946a35fffa00ff6ead818c47fb2979403` |
| `KeyboardTests/DeleteKeyScrubContractTests.swift` | `2a6ab20036b551e536c4de1c080f4d523f556cf928012516a1095090853b00e0` |
| `Universe Keyboard/Models/SettingsSearchCatalog.swift` | `ea7a3f366d77e088a89822feea7461b28df1c93934a56e90aa4b1579d2461973` |
| `Universe Keyboard/Views/Search/SearchTab.swift` | `df32810907f9fc4fc7cee30e84a00941ae7c8a489dda38c19335a2cf13c4d655` |
| `Universe Keyboard/Views/Settings/SettingsTab.swift` | `19651c5fc32654fa71463c77e01ef7bbf1b72cbf433124c730cb172e18c5f884` |
| `CHANGELOG.md` | `0428337c214c74e5a357821127f51611427f7ec165b11be9c7c018e49ec9d055` |
| `docs/product-decisions/DELETE-KEY-SETTINGS-001-product-contract.md` | `24044947b1243c597b142cc9f3d6542cccab7bb70b48be30b40decc78043315a` |
| `docs/assignments/delete-key-settings-001.md` | `e2e812b0f4517f1717f0272efabfaf08a7d02cec88290de1561fed1a710c0f24` |
| `docs/authorizations/AUTH-DELETE-KEY-SETTINGS-001-IMPLEMENT.md` | `cb54d80ec22e1fdd5c0f84715dea5950e08db40393ee63858b2260e113b05b9b` |
| `Keyboard/Controllers/KeyboardViewController+KeyFactory.swift` | `071632c04eb3edb6bd7d93430241ef5ca3c32af447ea5797affd2560bdaa46e2` |
| `docs/product-decisions/DELETE-KEY-SCRUB-001-product-contract.md` | `b9b3ac31cf5a1dd1531bd21e8d223bb9f1791cbd2f61b09b8a004992a03f8ed1` |
