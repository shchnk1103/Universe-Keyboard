# KOS Upgrade Record: KOS-UPGRADE-UK-003-v0.6.0

- Upstream repository: `shchnk1103/kos-agent-kit`
- From version: `v0.5.0` (advisory; historical pin `e11cbfb`)
- To version: `v0.6.0`
- Release class: minor (compatible)
- Checked at: `2026-09-02T18:53:00+08:00` (UK-002)
- Adopted at: `2026-09-03T20:30:00+08:00`
- Upgrade owner: Human Product Owner

> **S-03:** This record supersedes [`KOS-UPGRADE-UK-002-v0.6.0`](KOS-UPGRADE-UK-002-v0.6.0.md) **only** for the Adopted pin. UK-002 remains the historical Deferred-check evidence.

## Impact assessment

- Affected contracts: Adopted pin and Profile `extensions.universe_keyboard.kos_kit`; documentation SoT. Optional orchestration package (`ops/agent-orchestration.md`) becomes the default *available* contract for **new** Assignments that need multi-agent / multi-provider routing.
- Does not change frozen `core/`, Envelope schema, or `record_envelopes.mode`.
- Does not instantiate `templates/docs/ORCHESTRATION_PLAN.md` in this repository.
- Existing Active Assignments stay on their current contracts; no retroactive migration.

## Decision

- Disposition: **Adopted** (advisory)
- Decision source and date: Human Product Owner in-session `2026-09-03 Asia/Shanghai`
- Rationale: pin the current Kit Latest after the Deferred check; keep validator advisory; do not enable `required`.
- Deferred-until: not applicable for this pin. `required` and orchestration instantiation remain separately unauthorized.

## Evidence

- Release notes: https://github.com/shchnk1103/kos-agent-kit/releases/tag/v0.6.0
- Peeled commit: `a16c93281718f97cb580935c5043562c39f3a1d1`
- Validator: [`kos-upgrade-uk-003-advisory-validate-2026-09-03.md`](../../evidence/kos-upgrade-uk-003-advisory-validate-2026-09-03.md)
- Residual: [`TD-014`](../../TECH_DEBT.md#td-014-kos-22-auth-consumption_state-卫生); `required` still unauthorized
