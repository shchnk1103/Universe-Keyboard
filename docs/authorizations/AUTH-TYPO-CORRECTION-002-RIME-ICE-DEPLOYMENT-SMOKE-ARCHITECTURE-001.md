# Authorization: AUTH-TYPO-CORRECTION-002-RIME-ICE-DEPLOYMENT-SMOKE-ARCHITECTURE-001

## Current Status

| Field | Value |
|---|---|
| Status | `consumed` |
| Assignment | [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md) |
| Issuer | Human Product Owner / Product Lead, current Codex task, `2026-09-20 Asia/Shanghai` |
| Consumer | Independent Architecture reviewer |
| Purpose | 对 RIME Ice deployment smoke receipt 做 docs-only Architecture 只读复核 |
| Run under review | `TC2-SIM-20260920-RIME-ICE-SMOKE-01` |

## Exact review binding

| Field | Value |
|---|---|
| Review worktree | `/private/tmp/universe-keyboard-typo-correction-002-parent-revalidation-003` |
| Code/source snapshot used by package | `3f9f2652b03279a99537639f4382b48bb58548ca` |
| Simulator | iPhone 17 Pro Max / iOS 27.0 / `06C5BC3E-7599-4761-A1A2-71DAEA991474` |
| Package identity | The four executable hashes recorded in the Run Receipt |
| Primary receipt | [`RIME Ice deployment smoke receipt`](../evidence/typo-correction-002-sim-run-2026-09-20-rime-ice-deployment-smoke-01.md) |
| Capture Authorization | [`RIME Ice deployment smoke AUTH`](AUTH-TYPO-CORRECTION-002-RIME-ICE-DEPLOYMENT-SMOKE-001.md) |

## Allowed

1. 只读检查上述 Run Receipt、其绑定的 package/provenance/deployment
   evidence 和 parent Assignment。
2. 独立判断 Main-App-owned RIME deployment、App Group provenance、精确
   `rime_ice` identity、installed-content digest 和 terminal success 的边界。
3. 记录 Architecture verdict、residual 和 non-claims。
4. 写一份 Architecture review receipt，并消费本 Authorization。

## Explicit exclusions

- No rebuild, reinstall, Simulator run, UI click, keyboard input or schema change.
- No source/test/vendor/signing change.
- No sidecar, INT-003, QA-001, paired-performance, 180 ms, physical-device,
  VoiceOver, nine-key, Product/Quality/Release Gate or parent Close conclusion.
- No commit, push, PR, merge, TestFlight or Release.

## Stop conditions

若 receipt 的 Run ID、package hash、App Group provenance、部署终态或
installed-content digest 无法与绑定证据一致，必须保留 `UNKNOWN` 或
`Pass with conditions`，不得把 setup smoke 升级成产品行为结论。

## Consumption receipt

- Evidence: [`RIME Ice deployment smoke Architecture review`](../reviews/typo-correction-002-sim-run-2026-09-20-rime-ice-deployment-smoke-01-architecture-review.md)
- Consumed: `2026-09-20T21:20:00+08:00`
- Result: `Bounded Pass` for the deployment precondition only. The receipt
  binding, Main-App-owned deployment boundary, App Group provenance and
  installed-content identity are coherent.
- Residual: the archive SHA is carried by the fresh runtime receipt, but the
  downloaded archive file was not separately exported and re-hashed in this
  smoke.
- Non-claims: no sidecar, INT-003, QA-001, performance, physical-device or
  Product/Quality/Release Gate conclusion.
- This Authorization cannot authorize later input capture or publication.
