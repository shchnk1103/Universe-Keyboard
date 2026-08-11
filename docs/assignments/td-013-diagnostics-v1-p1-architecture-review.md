# TD-013 Diagnostics v1 P1 — Architecture Review Conclusion

| Field | Value |
|---|---|
| **Date / timezone** | `2026-08-11 Asia/Shanghai` |
| **Reviewer role** | 🏛️ Architecture & Knowledge Steward — independent of the Executor |
| **Object under review** | Uncommitted TD-013 worktree on `d3f415ec7da29f732fd718ae66274c8be375048d` (`codex/td013-diagnostics-v1-p1-planning`) |
| **Authority inputs** | [Assignment](td-013-diagnostics-v1-p1.md) · [P1 plan](../plans/td-013-diagnostics-v1-p1-plan.md) · [ADR 0027](../architecture/decisions/0027-enterprise-local-diagnostic-observability.md) · ADR 0003 · ADR 0007 |

## Verdict

**Fail**

The implementation cannot enter the Architecture Gate, Product Gate, or a
merge-ready handoff. This is a contract and boundary conclusion only; it does
not replace Quality testing, simulator evidence, device evidence, or a Product
decision.

## Blocking findings

| ID | Severity | Finding | Required disposition |
|---|---|---|---|
| `A-P0-01` | P0 | `beginPage` does not retain a `(segment identity, byte watermark)` manifest. It lists files and then reads their current contents, so concurrent writer rotation/append can form no single global cut; reclaim is not an explicit cursor invalidation. | `fix` — define a linearizable bounded snapshot protocol and add multi-writer append/rotate/reclaim tests, or obtain an ADR/Product amendment before weakening the contract. |
| `A-P0-02` | P0 | The 5 MiB and 10,000-event limits are defaults, not Core-enforced limits; an arbitrary caller can request a larger read and retain an unbounded decoded page snapshot. | `fix` — enforce both limits in `KeyboardCore` and return a typed, displayable status when either is exceeded. |

## Conditional findings

| ID | Severity | Finding | Required disposition |
|---|---|---|---|
| `A-P1-01` | P1 | A v1 read error is swallowed by `try?`, then the UI can fall back to legacy text. Legacy fallback must only occur after successful empty v1 completion. | `fix` — surface a typed unavailable/refresh state. |
| `A-P1-02` | P1 | Retention directly deletes sealed segments without the identity lock that ADR 0027 declares to be the deletion fence. | `fix` — acquire/recheck the lock, or formally prove and amend a terminal-sealed exemption. |
| `A-P1-03` | P1 | Diagnostics refresh awaits reclaim completion. This is outside the Extension hot path, but the intended refresh semantics need an explicit decision and concurrent coalescing evidence. | `fix` — make UI query fire-and-forget with testable scheduling, or document an accepted blocking semantic. |

## Confirmed boundaries

- The scheduler is Main-App-only and does not enter the Keyboard Extension hot path.
- Selected RIME/Lua/raw-log paths now persist aggregates rather than samples or free text.
- No `@unchecked Sendable`, `nonisolated(unsafe)`, or equivalent Swift 6 isolation bypass was found.

## Documentation follow-up

Cursor comments, `DEBUGGING.md`, `TECH_DEBT.md`, and execution evidence must be
synchronized after corrective work. In particular, evidence must not describe
the default byte limit as an unbypassable Core safety bound before it is one.

## Re-review gate

Re-request independent Architecture review only after `A-P0-01`, `A-P0-02`, and
the listed P1 fixes have code/test/documentary evidence. No residual is eligible
for `accept` while it contradicts ADR 0027 or the current Assignment.

`SUMMARY_DECISION=Fail`
