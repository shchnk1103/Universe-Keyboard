# RIME User Dictionary Learning

This document records the product and implementation boundary for RIME candidate learning, user dictionary backups, and the main-app UI.

## Scope

Candidate learning uses RIME's per-schema user dictionary behavior. In Universe Keyboard, the settings entry is named “RIME 用户词典” and is managed only for the current built-in/default RIME schema and the downloaded Wusong Pinyin schema:

- `luna_pinyin`
- `rime_ice`

Do not hard-share learned candidate order across unrelated schemas. Different schemas can encode the same visible text differently, so shared learned weights would be ambiguous.

## Runtime Boundary

Candidate learning settings and backup/restore operations belong to the main App.

- The main App writes candidate-learning settings and schedules the normal RIME apply flow.
- The main App may scan, copy, back up, restore, or remove `{schema}.userdb*` files.
- The Keyboard Extension must not run backup, restore, file scans, manifest hashing, schema repair, or RIME deployment while typing.
- The Keyboard Extension continues to use the last prepared RIME runtime data until the main App finishes applying changes.

This keeps input hot paths free of filesystem scans, hashing, copying, and deployment work. Cross-device learned-dictionary exchange is not performed by the local backup feature; it must use librime's standard `sync_user_data` snapshot-merge path.

## User-Facing Model

The settings copy should describe behavior in plain language:

- "已开启：键盘会记住你常选的词。"
- "已关闭：键盘不会调整这个方案的候选顺序。"
- "暂无学习记录，暂时不用备份。"
- "已有学习记录，可以先备份一份。"
- "已备份，暂无新的学习记录。"
- "有新的学习记录，可以更新备份。"

Avoid exposing RIME terms such as "userdb", "manifest", or "translator/enable_user_dict" in user-facing text.

## UI Design

The candidate learning settings screen is organized by scheme, not by feature.

Top-level screen:

- Shows the global automatic backup switch.
- Shows a list of schemes.
- Each scheme row contains the scheme name, short combined status, and a compact status icon.
- Tapping a scheme opens the scheme detail page.

Scheme detail page:

- Candidate learning switch for that scheme.
- Backup and restore controls for that scheme.
- Reset learning-record action for that scheme. Restore and reset both create and verify a local recovery backup before replacing or removing current files.
- Short explanatory footers for each section.

This structure is intentional and should stay aligned with the main RIME scheme-management pattern in `docs/RIME_SCHEME_MANAGEMENT.md`. As more open-source schemes are added, the top-level page should grow as a list of schemes instead of repeating every scheme under separate "learning", "backup", and "reset" sections.

## Status Icons

Use compact icons on scheme rows and keep long explanations inside the detail page.

- Green circle with white check: latest backup matches current learning data.
- Orange status: there is learning data that can be backed up, or the app cannot confirm whether a new backup is needed.
- Gray status: no learning data, disabled, or unavailable.

Do not show operation-result sentences as permanent rows in the form. Operation results are transient feedback.

## Toast Feedback

Candidate learning operation results use the shared global bottom toast pattern, matching the RIME deployment UX.

Examples:

- "已备份雾凇拼音的学习记录。"
- "已恢复雾凇拼音最近一次备份。"
- "已清空雾凇拼音的学习记录。"
- "备份失败，请稍后再试。"

The settings page itself should only show stable state, not transient operation messages.

## Backup Storage

Backups are local App Group files under the RIME user area:

```text
Rime/user_dictionary_backups/{schemaID}/{yyyyMMdd-HHmmss}/
```

Each backup copies matching current learning data:

```text
Rime/user/{schemaID}.userdb*
```

Each backup also writes a `manifest.json`. The manifest records file paths, sizes, modification times, and content hashes. UI state uses the manifest to decide whether the latest backup already matches current learning data.

The UI disables the Backup button when:

- There is no current learning data.
- The latest backup already matches current learning data.

If manifest comparison fails, the UI should allow manual backup instead of blocking the user.

## Restore Safety Decision

Before replacing current `{schema}.userdb*` data, the main App creates a distinct recovery backup, writes its manifest, and verifies the manifest against the source before continuing. If that preparation fails, restore and reset stop without replacing or deleting current files. If replacement fails after a recovery backup exists, the service attempts to restore that protected copy and reports the result through the shared toast.

This is a local safety mechanism, not a cross-device merge algorithm. Cross-process coordination with an active Keyboard Extension/librime writer remains tracked in `docs/TECH_DEBT.md`; restore and reset must remain manual main-App operations.

## Automatic Backup

Automatic backup is off by default.

When enabled:

- It runs only in the main App.
- It checks when the candidate learning screen appears.
- It checks when the main App moves to inactive/background.
- It skips schemes without new learning data.
- It skips duplicate backups when the manifest matches.
- It throttles automatic backups per scheme.
- It keeps a small fixed number of recent backups per scheme.

Manual backup is always a direct user action and should not be blocked by automatic-backup throttling.
