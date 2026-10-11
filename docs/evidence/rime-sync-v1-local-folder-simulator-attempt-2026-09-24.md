# RIME-SYNC-001 local-folder Simulator attempt — 2026-09-24

## Outcome

**Blocked before folder selection. No sync was started; this is not pass evidence.**

## Environment

- Target: `iPhone 18 Pro` Simulator, iOS `27.0`.
- App: `com.DoubleShy0N.Universe-Keyboard`, built from the active isolated
  worktree with the `rime-sync-p1-remediation` XcodeBuildMCP profile.
- Build/run result: succeeded; the app launched.
- Scope: Human Product Owner authorized a simulator-only local-folder test and
  deferred live WebDAV validation to `TD-019` on `2026-09-24 Asia/Shanghai`.

## Observations

- First launch displayed the activation guide. The guide said Full Access had
  not been confirmed and explained that it enables access to shared local data.
- The Home screen reported RIME resources as “需要重试” and stated that the
  previous deployment had not completed.
- UI automation reported successful taps on visible guide controls, but the
  screen hash and content remained unchanged. On a tap labeled “打开设置”, the
  automation-reported point was in the lower guide-button area rather than the
  visible Settings button. This made subsequent interaction unsafe to infer.
- No app-setting assertion was made, no folder picker was opened, no directory
  was created or selected, and neither RIME standard data nor private settings
  sync was triggered.
- No Full Access system permission was changed. No resource download/deploy,
  WebDAV, existing user folder, remote data, disconnect, or deletion was used.

## Evidence boundary

This attempt proves only that the isolated Simulator build launched and exposed
the listed onboarding/resource states. It does not prove local-folder picker
behavior, provider metadata/deletion semantics, successful sync, device
behavior, or WebDAV interoperability. The next attempt requires a reliable UI
interaction path and resolution of the activation/resource prerequisites before
choosing a newly created, isolated Simulator folder.
