# PR body draft — KEYBOARD-LAYOUT-9KEY-PINYIN-004

**Branch:** `codex/t9-atomic-path-snapshot` → `main`  
**Create URL:** https://github.com/shchnk1103/Universe-Keyboard/pull/new/codex/t9-atomic-path-snapshot  

**CLI (when publish is allowed):**

```bash
gh pr create --base main --head codex/t9-atomic-path-snapshot \
  --title "feat(t9): KEYBOARD-LAYOUT-9KEY-PINYIN-004 Path catalog + Gate 5 residual" \
  --body-file docs/assignments/keyboard-layout-9key-pinyin-004-pr-body.md
```

---

## Summary

- Complete local T9 Path catalog + atomic composition presentation (004 / ADR 0023).
- Fixed-height Path Bar lists full focus choices without depending on expanded candidate discovery.
- Gate 5 β-limited identity (`T9CompositionIdentity`) for shortened remainder and typo Append/Delete; unchanged-raw B **fail-closed** (no invent-slot).
- Post-β residual: Core `sourceDigits` SoT for multi-digit progressive Delete/append, host remaining projection after Path select, short `da→dao` Path bar sync.
- Human H5 residual Pass (device A/B/C) accepted by Product disposition; independent Architecture Accept + Quality Pass-with-findings.

## Authority

- PD-004, ADR 0023
- Gate5 path / β / [post-β residual disposition](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-post-beta-residual-disposition.md)
- Independent review: [post-β independent review](keyboard-layout-9key-pinyin-004-gate5-post-beta-human-residual-independent-review.md)
- Evidence freeze: remediation §21–§27

## Non-claims

- **Not** full 004 Human Product Gate Pass against full exit criteria
- **Not** full B invent-slot coverage
- **Not** Assignment Closed solely by this PR

## Test plan

- [x] Directed matrix: `swift test --filter 'Gate5|HumanStandalone|HumanQingweifanda|UnconfirmedT9Delete|VisibleT9Delete|AppendDelete|WholeUnresolved|InSentenceDa|DeleteToQi|PartialCommit'` → **68 / 1 skip / 0 fail**
- [x] Independent re-run archived under `evidence/keyboard-layout-9key-pinyin-004-gate5-post-beta/logs/`
- [x] Human H5-A / H5-B / H5-C (device) Pass
- [ ] Optional reviewer smoke: Path bar + typo Delete residual before merge

## Commits

- `67ef0ad` feat(t9): complete Path catalog, atomic presentation, Gate 5 residual (004)
- `2112825` docs(gate5): record post-β residual Product disposition on evidence ledger
