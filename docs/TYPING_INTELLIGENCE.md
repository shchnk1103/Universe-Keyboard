# Typing Intelligence Product Contract

> **Version:** `1.0.0`
>
> **Status:** Accepted; implementation pending
>
> **Product authority:** Product Lead authorization, 2026-07-11 Asia/Shanghai
>
> **Assignment:** [`TYPING-INTELLIGENCE-001`](assignments/typing-intelligence-001.md)
>
> **Architecture decision:** [ADR 0011](architecture/decisions/0011-local-typing-intelligence-data-boundary.md)

## Purpose

Typing Intelligence gives users useful, polished insight into their keyboard usage without creating an input history or a behavioral profile. It is a local product capability, not telemetry.

The first release establishes a trustworthy foundation that can support richer on-device insights later without changing the privacy boundary.

## Product Principles

1. **Local by construction.** Typing Intelligence data never leaves the device.
2. **No input history.** The product never persists text, words, pinyin, candidates, host context or per-commit records.
3. **Explicit control.** Statistics are disabled by default. The main App explains the feature before the user enables it.
4. **Reversible participation.** Users can pause collection and permanently clear all statistics.
5. **Typing remains primary.** Collection failure, unavailable App Group access or disabled statistics must never block or materially delay input.
6. **Honest capability.** Without Full Access, the keyboard remains usable while shared statistics are reported as unavailable or paused.
7. **Extensible aggregates.** Future insights may derive from approved aggregate fields, but may not reconstruct or approximate user content.

## V1 User Experience

The main App provides a dedicated Typing Intelligence destination with:

- clear disabled, empty, active and unavailable states;
- an explicit enable/disable control;
- today, recent seven-day, recent thirty-day and all-time summaries;
- daily trend presentation;
- character-category composition;
- active-day and streak insights;
- last-updated status;
- a destructive clear action with confirmation;
- concise privacy disclosure stating that typed content is not saved or uploaded.

The visual design follows the native Settings-oriented rules in `UI_STYLE_GUIDE.md`. It must support light/dark mode, Dynamic Type, VoiceOver, reduced motion and compact devices.

The Keyboard Extension does not add a statistics dashboard or promotional surface. Its responsibility is bounded collection and truthful capability state only.

## Approved Data Contract

### Ephemeral Input

The final committed `String` may exist only long enough to classify its Swift extended grapheme clusters. It must then be discarded.

Ephemeral input must not be:

- persisted;
- logged;
- included in diagnostics or crash metadata;
- copied into an analytics event;
- uploaded or synchronized;
- retained in an unbounded queue;
- exposed to the main App.

### Persisted Aggregates

V1 may persist only:

- schema version and reset epoch;
- creation and last-update timestamps;
- total committed grapheme count;
- CJK, Latin letter, digit, punctuation, whitespace, newline, emoji and other aggregate counts;
- bounded daily aggregates for the most recent 365 calendar days;
- bounded aggregate commit-source counts;
- active-day and streak derivations;
- collection-enabled and capability-state metadata.

Emoji, spaces and newlines count toward the committed total and retain separate categories. Classification uses Swift `Character` semantics so one user-perceived grapheme is not split into multiple counts.

### Prohibited Data

Typing Intelligence must not persist or derive:

- raw or normalized committed text;
- unfinished composition, raw pinyin or marked text;
- words, phrases, sentences, n-grams or per-token frequency;
- candidate text, candidate lists, ranking or selection identity;
- surrounding text, cursor context, clipboard content or host application identity;
- user-dictionary contents;
- timestamps precise enough to reconstruct individual typing sessions;
- device, advertising, account or cross-app identifiers;
- health, financial, credential, contact or other sensitive-content classification;
- any record designed to identify, profile or infer the user.

## Retention And Deletion

- Daily aggregates are retained for at most 365 calendar days.
- Older daily buckets are removed during bounded compaction.
- All-time totals remain until the user clears statistics.
- Clear removes all aggregate payloads and advances a reset epoch so stale asynchronous work cannot restore deleted data.
- Disabling collection stops new aggregation but does not silently delete existing data.
- Re-enabling starts from the existing aggregates unless the user previously cleared them.

## Full Access And Failure Behavior

Typing Intelligence depends on writable App Group access. When that capability is unavailable:

- basic keyboard input continues;
- no in-memory backlog is retained across the unavailable period;
- the Extension does not repeatedly perform failing persistence work on each key;
- the main App and Extension must not claim collection is active;
- the user receives actionable, plain-language status where a reliable capability observation exists.

The main App must not pretend it knows the Extension's live Full Access state before the Extension has observed the capability.

## App Store And Privacy Position

- Keyboard activity is used only to provide the on-device Typing Intelligence capability.
- No Typing Intelligence data is transmitted off device.
- No third-party analytics, advertising or tracking SDK receives keyboard data.
- App privacy disclosures and the in-app privacy policy must match the implemented behavior.
- Required Reason API usage, including App Group `UserDefaults` if retained, must be accurately represented in valid privacy manifests before submission.
- App Review approval is an external decision and cannot be guaranteed; release readiness requires current guideline review and complete submission metadata.

## Acceptance Contract

V1 is acceptable only when evidence proves:

- every approved final commit path is counted exactly once;
- unfinished or abandoned composition is never counted;
- no prohibited payload reaches persistence or logs;
- enabling, disabling, clearing and reset-epoch races behave deterministically;
- collection adds no synchronous storage work to the key path;
- process termination and App Group failure do not break typing;
- main-App summaries match controlled synthetic fixtures;
- accessibility and visual states pass Simulator inspection;
- Full Access on/off and lifecycle behavior pass physical-device acceptance;
- performance is compared against a pre-feature baseline using the repository measurement procedure;
- NE1 files and evidence remain unchanged and independently traceable.

## Future Capability Boundary

Future versions may add new aggregate dimensions only after Product, privacy and ADR review. Any proposal involving raw text, token frequency, language modeling, cloud sync, cross-device identity, host-app identity or server-side processing is outside this contract and requires a new Product Decision.
