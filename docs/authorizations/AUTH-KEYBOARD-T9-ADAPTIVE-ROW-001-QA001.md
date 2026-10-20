# QA-001 local remediation authorization

Human Product Lead, current request and supplemental real-iPhone evidence, tested011d3fa, 2026-10-20 Asia/Shanghai. Active bounded local diagnosis, deterministic regression, minimal UIKit fix, L1/L2, local commits and KOS evidence only. Same task KEYBOARD-T9-ADAPTIVE-ROW-001, W=codex-t9-adaptive-row/P=none; no HANDOFF/ACCEPT.

Entry verified branch codex/keyboard-t9-adaptive-row-001, HEAD011d3fa592a938fb1f7eff83f125f96bbecaad18, clean named task worktree. Human reports8 pass/1 fail; first key retained in second-key complete path, not proof of input loss. Independently re-review and Human targeted retest required.

Allow: trace punctuation/kaomoji→first input→snapshot→Path visibility→panel teardown; deterministic tests at existing engine/UI seams; root-cause minimal fix; directly related F-3/F-5 only with evidence, separate F-2 comment cleanup and honest F-1 provenance. Preserve unknown dirty work.

Forbid: push, PR217 updates, main merge/modification, rebase/squash/reset/clean/stash, UI-1 restoration/access, release/TestFlight, unrelated fixes, Core/RIME/CandidateAuthority semantic changes, weakened/deleted tests, timers/arbitrary repeat refresh, whole-keyboard rebuild or input replay. Stop if authority boundary required.
