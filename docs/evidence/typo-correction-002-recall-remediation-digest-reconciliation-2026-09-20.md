# Recall remediation: publication digest reconciliation

## Authority and scope

- Authority: Human Product Owner in this Codex task, 2026-09-20:
  “OK，授权这一轮docs-only 修复及 commit/push，保持 PR 为草稿”。
- Owning Assignment: [publication preflight](../assignments/typo-correction-002-recall-remediation-publication-preflight-001.md).
- Executor: current Codex task; this is publication bookkeeping, not a new independent review.
- Base: `a7b660d50a45348fa0262dd5c5f0e35abbc2fddf`; branch
  `codex/typo-correction-002-recall-publication-staging-001`; [draft PR #141](https://github.com/shchnk1103/Universe-Keyboard/pull/141).
- Allowed: correct digest references and the contradictory consumed-status mirror, record
  byte-equivalence and validation, commit/push these four docs. Keep PR draft.
- No merge, source edits, device capture, Release, new Product/Quality verdict or Assignment close.

## Reproducible cause

The two committed documents each lack one trailing LF compared with their recorded hashes.
For each document, SHA-256 of the bytes at `a7b660d` plus exactly one `0a` byte equals
the old recorded hash. This proves the byte difference; the tool or action that removed the
trailing LF is not established. No review prose or Product disposition changed.

| Document | Recorded SHA-256 | SHA-256 at a7b660d |
|---|---|---|
| Final Quality review | `a7070f9ff8c5e26312eed45cc9a6207de187acd99f086caa58036b95ac0a5692` | `9e498f60b7bb7477f994089137f797424c90d4e308ae580ca2bf4e73116fb6ae` |
| Final Product decision | `e731018f51ac58950276821aca19ada703ed53f95c3e4927e89b2dcfdf8ef8d1` | `8fca253a9881e0ad45030b1d0a757acd87b4d6f1ff9be73c6b6ab53489de9ee0` |

## Correction

The Quality review is unchanged. The Product decision now references its actual hash
`9e498f60…`; this single hash-reference edit makes the Product decision hash
`f5f65777ee1584ed63fd87a04ea0244813442fbd13b7142d86f9cd0793481d24`.
Both current Authorization bindings follow this dependency order. The historical Product
consumption receipt retains the old hash with an explicit correction pointer; its top-level
Status now agrees with its existing consumed receipt.

The source manifest remains `e2b4373c0797a0959b0b0da10c1db01cf4fa81cfe25903c7d9726942edab465c`.
The independent Architecture review remains `25dba823b50d12c3090346f408ae681719c852e998b3044a6751f525b9d4412b`.
No independent verdict is upgraded.

## Verification and handoff

- Run the pinned KOS v0.8.0 validator from commit
  `2c9907565bf6b6fcd00e698cc539d9e2db573bc5`, with deterministic
  `KOS_AS_OF=2026-09-20T20:00:00+08:00`.
- Pre-fix validator: exit 0 with 79 advisory warnings, including recall Authorization
  envelope/schema warnings as well as unrelated existing records. These are not zero-warning
  evidence or a Gate pass. Preserve and compare the exact warning set after the final edit.
- Final checks: digest dependency chain, source manifest, four-file docs-only allowlist,
  whitespace, Markdown links and lightweight governance checks; compare against `a7b660d`.
- Observed reconciliation checks: source manifest, current digest chain and historical
  one-byte equivalence PASS; pinned validator exit 0, exactly the same 79 warnings as before
  this fix (no added or removed warnings). Final commit-range Markdown checks are run after
  commit so they include these edits; pre-commit HEAD-to-HEAD checks do not cover them.
- Reuse unchanged source evidence from Quality Run 002 and hosted full CI
  [35504384201](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/35504384201)
  on `a7b660d`; that hosted result does not certify the new docs commit.
- Docs-only: no xcodebuild rerun. Keep skipped tests, warnings, unsigned Simulator scope,
  production wiring / real-RIME / INT-003 / QA-001 / performance non-claims unchanged.
- Next: verify the pushed docs commit and hosted checks before requesting separate merge authority.
  Parent/child stay Active; the two excluded parent residual files remain untouched.
