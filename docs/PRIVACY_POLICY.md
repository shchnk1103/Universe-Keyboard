# Universe Keyboard Privacy Policy

> **Effective date:** 2026-07-11
>
> **Status:** Current repository privacy-policy source; App Store publication URL required before submission

## Privacy Position

Universe Keyboard is designed to perform keyboard input and personalization on the user's device. It does not sell data, track users, show advertising or upload keyboard input for analytics.

## Keyboard Input

The Keyboard Extension does not transmit typed text, unfinished composition, surrounding text, candidates, clipboard content, host-application identity or user-dictionary contents to the developer or a third party.

Full Access is requested so the Keyboard Extension can use the shared App Group container prepared by the containing App, read shared settings, use managed RIME resources, persist local user-dictionary learning, play configured feedback and, when explicitly enabled, update local Typing Intelligence aggregates. Full Access is not used to send keystrokes to a server.

## Typing Intelligence

Typing Intelligence is disabled by default. When enabled, final committed text is classified in memory into aggregate character categories. The original text is immediately discarded and is not persisted.

Persisted statistics contain only bounded counts, daily totals, source-category totals, schema/reset metadata and update dates. They do not contain words, phrases, per-commit records, host context or identifiers. Statistics remain on device, may be paused and can be permanently cleared from the main App.

## Local Personalization And Diagnostics

- RIME may maintain its local user dictionary inside the shared App Group container.
- Explicit typo-correction selections may maintain bounded local correction-learning metadata used only to improve on-device correction ranking.
- Diagnostic logging is controlled in the main App and remains local unless the user explicitly copies and shares it.
- The product must not log committed text, surrounding host text or Typing Intelligence event payloads.

The main App provides controls for supported reset and deletion operations.

## Network Use

The Keyboard Extension does not use network access for input processing or Typing Intelligence.

The containing App may connect to GitHub only when the user requests information about, downloads or updates an optional RIME input scheme. Keyboard input, Typing Intelligence aggregates, user dictionaries and diagnostics are not included in those requests.

## Tracking, Advertising And Accounts

Universe Keyboard does not include advertising, cross-app tracking or a user-account system. It does not combine keyboard data with third-party data or use keyboard data to identify a person or device.

## Storage, Retention And Deletion

- Typing Intelligence daily aggregates are retained for at most 365 days; all-time totals remain until cleared.
- Typing Intelligence clear advances a reset epoch and removes the aggregate payload so delayed Extension work cannot restore deleted data.
- RIME user-dictionary, correction-learning, settings and diagnostics follow their corresponding in-app controls and repository product contracts.
- Removing the App may remove App-owned containers according to iOS behavior; this is not presented as a substitute for in-app deletion controls.

## App Privacy Disclosure

Data processed only on device and never transmitted off device is not represented as developer collection in App Store privacy details. Required Reason API declarations remain separate and accurately describe APIs used for App Group preferences, container metadata and storage-capacity checks.

The App Store privacy answers, bundled privacy manifests, product behavior and this policy must be reviewed together before every submission.

## Changes

Any future feature that uploads, synchronizes or derives content-level keyboard information requires a new Product Decision, privacy review, architecture decision, updated user consent and an update to this policy before implementation.
