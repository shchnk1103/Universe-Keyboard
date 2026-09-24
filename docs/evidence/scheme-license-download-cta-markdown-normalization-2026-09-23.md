# SCHEME-LICENSE-DOWNLOAD-CTA-001 — Markdown normalization receipt

**Date:** `2026-09-23 Asia/Shanghai`\
**Authority:** Human Product Owner's current-session instruction to normalize the relevant Markdown formatting.\
**Purpose:** Remove the staged `git diff --check` findings before publication.

## Scope and method

Only Markdown presentation whitespace was normalized in the six hash-bound artifacts below: intentional hard line breaks now use a trailing backslash instead of trailing spaces, and redundant blank lines at EOF were removed. No words, links, code, JSON values, product behavior, test code, evidence grade, or decision disposition changed.

This receipt records a byte-level transition for traceability. The Product Gate decision, its accepted conditions, and the independent Quality conclusion remain the historical conclusions for the same code/test package. This receipt is not a new Quality review, Product Gate, Simulator observation, or claim of behavioral revalidation.

## Exact hash transition

| Artifact | Bound hash before normalization | Current SHA-256 |
|---|---|---|
| Product Gate Assignment | `c4e1aa0af7a93e125242811cd89dfa9e09cb18878e7a1951505644758c1cb81f` | `dd9677e4bf509a0579d3ff9ac54ffb0e6b8a173fb774c4928140a81c754314c4` |
| Consumed Product Gate decision Authorization | `45e49cf94b453aa3d903a892cf66b78df5b54d5d7ad539700150e77e716d8ff5` | `86015bab148d34224b307d2d6436af52c33231b5f724179b1a91bb259cf28e35` |
| Product Gate packet | `ae13ad59fe9032fa626ef1b9d1aaa9b5238fa565850191701743d8d1a6b5c0eb` | `c267c21fc5ad526f5d1a43ad7584331efe4c7648d9c0f308ae30d9d2a28cd758` |
| Human-attested Simulator observation | `3f0da5b886222673807fd8fb6f382834a250893bb1b01525434028a521b1cbc0` | `cc3271fbea9ec76a7b68c26ec219bd4fc3328fc40c7f29f4756f7b352d53a5b9` |
| Product Gate decision | `bff4b8cf8dd0435fb46fef55d78cd773a4ec5b04d60346093d5f015585cec7bd` | `ec80a4dad63d66f22d1ad2b7a996717a37671b1596d74157ab25ec12248dcdb4` |
| Independent Quality revalidation receipt | `04f7a8cd731096513fb0f9b8cd06a0432a79489cce8f204563aef01597445937` | `1dde9b3bf058442be7c686494d2d4891da53ed1c7812b8b7d71874f5d97621c3` |

The consumed Gate Authorization's original packet, observation, and Quality hashes remain evidence of what the Human decision consumed at that time. This receipt maps those exact files to their presentation-normalized bytes without changing that historical attribution.

## Validation boundary

- `git diff --check`: passed on the normalized worktree; staged-tree check will be rerun after staging.
- Changed-Markdown local-link check: passed for 29 changed Markdown files; no missing links.
- `kos-record` and `.kos/project.json` JSON parse: passed for 10 record fences and the project profile.
- CI helper unit tests: `python3 -m unittest discover -s scripts/ci/tests -p 'test_*.py'` — 12 passed.
- App, Keyboard, RimeBridge, KeyboardCore, and Release build suites: not rerun; this change contains no source, test, project, workflow, or CI-rule edits. Existing results remain tied to unchanged code/test bytes and their recorded Simulator/toolchain.
