---
name: pre-push-review
description: "Review code changes, run tests, and push clean commits to GitHub. Use when the user says 'push', 'upload to GitHub', 'ship it', 'commit and push', or asks to create a commit for finished work."
argument-hint: "[commit message description]"
---

# Pre-Push Review

Reviews all code changes, runs the test suite, and if everything passes, commits and pushes to GitHub. Tailored for Universe Keyboard (Swift/iOS/SPM/Xcode).

## Workflow

### 1. Scan the workspace (run in parallel)
- `git status` — check for untracked/backup files
- `git diff --stat` + `git diff --cached --stat` — change summary
- `swift test --package-path Packages/KeyboardCore` — full test suite

### 2. Review gate
Check each item before allowing a push:

- `/\.bak$|\.DS_Store|\.env$|credentials/` — block these file patterns
- `try!` in production code (`Sources/` not `Tests/`) — warn if unvalidated input
- Test suite — must have **0 failures**
- Staged files — prefer `git add <specific>` over `git add -A`
- No orphaned `// MARK:` comments or dead code without explanation

### 3. If gate passes
- Craft a commit message matching existing style (brief descriptive title, Co-Authored-By footer)
- Stage files explicitly by name (never `git add -A`)
- `git commit` + `git push origin main`
- Report: commit hash, file count, test count, push URL

### 4. If gate fails
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
Agent scans → [N] tests pass, no .bak/.DS_Store, no issues
       Commits: "Fix zip parsing off-by-2 bug + [X] new tests"
       Pushes → reports success with hash 8a05113
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
