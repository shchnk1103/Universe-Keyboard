# Universe Keyboard Privacy Policy

> **Effective date:** 2026-11-04
>
> **Status:** Current repository privacy-policy source; App Store publication URL required before submission

## Privacy Position

Universe Keyboard is designed to perform keyboard input and personalization on the user's device. It does not sell data, track users, show advertising or upload keyboard input for analytics.

## Keyboard Input

The Keyboard Extension does not transmit typed text, unfinished composition, surrounding text, candidates, clipboard content, host-application identity or user-dictionary contents to the developer or a third party.

Separately, when the user runs standard RIME synchronization in the containing App, it uses the same local or file-provider folder the user selected for sync and may place user-dictionary snapshots and non-generated YAML/TXT configuration backups in that folder, as described under Optional Standard RIME Sync.

Full Access is requested so the Keyboard Extension can use the shared App Group container prepared by the containing App, read shared settings, use managed RIME resources, persist local user-dictionary learning, play configured feedback and, when explicitly enabled, update local Typing Intelligence aggregates. Full Access is not used to send keystrokes to a server.

## Typing Intelligence

Typing Intelligence is disabled by default. When enabled, final committed text is classified in memory into aggregate character categories. The original text is immediately discarded and is not persisted.

Persisted statistics contain only bounded counts, daily totals, source-category totals, schema/reset metadata and update dates. They do not contain words, phrases, per-commit records, host context or identifiers. Statistics remain on device, may be paused and can be permanently cleared from the main App.

## Local Personalization And Diagnostics

- RIME may maintain its local user dictionary inside the shared App Group container.
- Explicit typo-correction selections may maintain bounded local correction-learning metadata used only to improve on-device correction ranking.
- Post-commit continuation uses at most 32 recently committed `Character` values only inside the current Keyboard Extension process. It reads no surrounding host text and never persists, logs, synchronizes or uploads that context; only its enabled preference is stored.
- Diagnostic logging is controlled in the main App and remains local unless the user explicitly copies and shares it.
- The product must not log committed text, surrounding host text or Typing Intelligence event payloads.

The main App provides controls for supported reset and deletion operations.

## Optional RIME Settings Sync

RIME settings sync is off until the user selects a destination. When enabled, the containing App may synchronize settings such as the active scheme, candidate count, simplification, fuzzy-pinyin preferences, advanced-input preferences and candidate-learning switches.

Before leaving the device, the settings profile is encrypted with a device-held key using authenticated encryption. A WebDAV service or selected file provider receives encrypted settings bytes plus minimal format metadata. The service password and content-encryption key are separate. The user can save a recovery code to use the same encrypted profile on another device.

The Universe private-settings package V1 does not synchronize typed text, surrounding text, candidates, user-dictionary contents or snapshots, Typing Intelligence, Typo learning, diagnostics, logs, downloaded schemes, Lua/OpenCC assets or custom YAML files. Settings fields written by the App on the user's other devices are merged field by field and kept in the package, then re-uploaded in encrypted form. Standard RIME synchronization, described below, is a separate feature that the user starts manually and may later automate, for librime user-dictionary snapshots and YAML/TXT backups. Adding any further category requires a separate consent and privacy review.

The user may disconnect the current device without deleting remote data, or explicitly delete the Universe RIME sync directory and clear the local sync key. Other devices retain their local settings until changed on those devices.

## Optional Standard RIME Sync

Standard RIME sync uses the same local or file-provider folder the user selected for sync. A manual sync asks for confirmation; after the first successful sync the user may turn on automatic sync, which iOS schedules in the background without asking each time. Each run invokes librime's standard user-data synchronization, which can place RIME user-dictionary snapshots and non-generated YAML/TXT configuration backups in that folder. The App does not copy live `*.userdb*` databases; librime performs its own snapshot merge.

After a successful initial sync, automatic standard sync becomes available but remains off until the user explicitly enables it. The user can choose a daily or seven-day cooldown. The containing App only asks iOS for a background opportunity; iOS may delay or skip it. Before an automatic run, the App checks that the selected folder is still authorized and that the keyboard is not active. If the user enables App notifications, selects the RIME sync category and permits system notifications, the App may show sync start, completion and failure notices for the RIME standard data and/or Universe settings categories chosen by the user. Notification choices do not enable, disable or change the actual synchronization work. Those notifications contain no directory, dictionary, recovery code or typed content.

Standard RIME sync is intended to interoperate with compatible RIME frontends configured with the same `sync_dir`. These files are not encrypted by Universe Keyboard, and their protection depends on the chosen file provider, mounted encrypted volume or storage account. Standard synchronization never runs in the Keyboard Extension or at keyboard input time.

Disconnecting or deleting the encrypted Universe settings package does not remove the standard RIME sync directory, because it can contain data owned by other devices.

## Network Use

The Keyboard Extension does not use network access for input processing or Typing Intelligence.

The containing App may connect to GitHub, the Nanjing University open-source mirror, or CNB when the user requests information about, downloads or updates an optional RIME input scheme. Keyboard input, Typing Intelligence aggregates, user dictionaries and diagnostics are not included in these scheme-information and download requests. When the user explicitly configures Universe private-settings synchronization, the containing App may connect to the selected WebDAV or file-provider destination and transfer the encrypted settings package described above. Separately, standard RIME synchronization may write user-dictionary snapshots and non-generated YAML/TXT configuration backups to the folder the user selected for sync. Universe Keyboard does not encrypt those standard RIME files. The About page may open the system mail composer or the linked Xiaohongshu profile only after the user taps those controls; the App does not attach diagnostics or typed content.

## Tracking, Advertising And Accounts

Universe Keyboard does not include advertising, cross-app tracking or a user-account system. It does not combine keyboard data with third-party data or use keyboard data to identify a person or device.

## Storage, Retention And Deletion

- Typing Intelligence daily aggregates are retained for at most 365 days; all-time totals remain until cleared.
- Typing Intelligence clear advances a reset epoch and removes the aggregate payload so delayed Extension work cannot restore deleted data.
- RIME user-dictionary, correction-learning, settings and diagnostics follow their corresponding in-app controls and repository product contracts.
- Encrypted RIME sync data remains at the selected destination until the user deletes it there or uses the in-app remote deletion action.
- The local sync key is stored in the device Keychain. Disconnecting preserves it for recovery; deleting remote sync data also clears the local key.
- Removing the App may remove App-owned containers according to iOS behavior; this is not presented as a substitute for in-app deletion controls.

## App Privacy Disclosure

Data processed only on device and never transmitted off device is not represented as developer collection in App Store privacy details. User-directed transfers to selected storage destinations, including encrypted Universe private-settings packages and standard RIME files that Universe Keyboard does not encrypt, require a separate assessment of their data contents, recipients, purposes and access. A user-selected destination or the presence of encryption does not by itself determine the App Store privacy-disclosure classification. Required Reason API declarations remain separate and accurately describe APIs used for App Group preferences, container metadata and storage-capacity checks.

The App Store privacy answers, bundled privacy manifests, product behavior and this policy must be reviewed together before every submission.

## Changes

Any future feature that synchronizes content-level keyboard information or adds a developer-controlled service requires a new Product Decision, privacy review, architecture decision, updated user consent and an update to this policy before implementation.
