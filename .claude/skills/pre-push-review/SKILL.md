---
name: pre-push-review
description: "Review code changes, verify recent test evidence, and push clean commits to GitHub. Use when the user says 'push', 'upload to GitHub', 'ship it', 'commit and push', or asks to create a commit for finished work."
argument-hint: "[commit message description]"
---

# Pre-Push Review

Reviews all code changes, confirms there is valid test/build evidence, and if the gate passes, commits and pushes to GitHub. Tailored for Universe Keyboard (Swift/iOS/SPM/Xcode).

## Workflow

### 1. Scan the workspace (run in parallel)
- `git status` — check for untracked/backup files
- `git diff --stat` + `git diff --cached --stat` — change summary
- `git diff --check` — whitespace/conflict-marker sanity check
- search changed/staged/untracked files for blocked patterns and obvious hazards

### 2. Test evidence policy
Push requires valid verification evidence, but it does **not** always require rerunning tests at push time.

Reuse recent test/build results when all of these are true:

- The exact final code diff was already tested in the current conversation.
- No code, package, project, or test files changed after that verification.
- The user explicitly asks to avoid extra testing, or the push request immediately follows the verified implementation.
- The prior evidence is reported in the final push summary with command names and results.

Rerun relevant tests/builds when any of these are true:

- Code changed after the last successful verification.
- The branch was rebased, merged, pulled, or otherwise changed since verification.
- The previous verification failed, was incomplete, or did not cover the changed area.
- The request is separated from the prior verification enough that the evidence may be stale.
- The user asks for a full pre-push check.

Default verification commands by change area:

- `Packages/KeyboardCore/**`: `swift test --package-path Packages/KeyboardCore`
- `Keyboard/**`, `Universe Keyboard/**`, project/package wiring, or cross-target changes: also run the iOS Simulator build when practical:
  `xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" -destination 'platform=iOS Simulator,name=iPhone 17' build`

If the user says "不用过多测试", "直接推", or equivalent, reuse valid recent evidence and only run lightweight checks unless the diff changed after verification.

### 3. Review gate
Check each item before allowing a push:

- `/\.bak$|\.DS_Store|\.env$|credentials/` — block newly changed, staged, or untracked files matching these patterns; do not fail solely because old unrelated tracked files already exist
- `try!` in production code (`Sources/` not `Tests/`) — warn if unvalidated input
- Test evidence — must be successful and current under the policy above
- Staged files — prefer `git add <specific>` over `git add -A`
- No orphaned `// MARK:` comments or dead code without explanation

### 4. If gate passes
- Craft a commit message matching existing style (brief descriptive title, Co-Authored-By footer)
- Stage files explicitly by name (never `git add -A`)
- `git commit` + push the current branch to its upstream; if no upstream exists, push to `origin <current-branch>`
- Report: commit hash, file count, verification evidence used, push target

### 5. If gate fails
- Report each issue with `file:line`
- Do NOT commit or push
- Tell user what to fix

## Project Context

- **KeyboardCore**: SPM at `Packages/KeyboardCore/`, tests via `swift test`
- **Main app**: `Universe Keyboard/` — Xcode file-system-sync, all Swift files auto-included
- **Keyboard extension**: `Keyboard/` — UIKit input controller
- **Commit style**: bilingual zh/EN titles, e.g. "Fix zip format off-by-2 + add 63 tests"

## Examples

### Good: work complete, clean push
```
User: "push this"
Agent scans → valid current test evidence, no newly changed .bak/.DS_Store, no issues
       Commits: "Fix zip parsing off-by-2 bug + [X] new tests"
       Pushes → reports success with hash 8a05113
```

### Good: user confirmed, recent tests already passed
```
User: "推送到GitHub上吧，不用过多测试了"
Agent verifies no code changed since the earlier passing `swift test`/build,
       runs only lightweight status/diff checks,
       commits and pushes,
       reports the reused verification evidence.
```

### Bad: .bak file blocks push
```
Agent: "Blocked — Universe Keyboard/Unzip.swift.bak matches exclusion pattern.
        Remove or .gitignore it before retrying."
Agent does NOT proceed to commit or push.
```

### Bad: test failure blocks push
```
Agent: "Blocked — ShiftStateTests.testRapidShiftToggle failed.
        /Tests/ShiftStateTests.swift:122: expected .off, got .capsLock
        Fix the failing test before retrying."
```
