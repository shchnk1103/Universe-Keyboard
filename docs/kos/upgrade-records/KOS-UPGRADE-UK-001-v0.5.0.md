# KOS Upgrade Record: KOS-UPGRADE-UK-001-v0.5.0

- Upstream repository: `shchnk1103/kos-agent-kit`
- From version: none in this repo (copied 2.0/2.1 docs; no prior Kit Profile)
- To version: `v0.5.0`
- Release class: minor
- Checked at: `2026-08-27T19:50:00+08:00`
- Upgrade owner: Human Product Owner

## Impact assessment

- Affected contracts: additive `.kos/project.json`, Envelope on one workflow, `docs/kos/UPGRADE_STATUS.md`, AGENTS/KNOWLEDGE_INDEX/READING_MAPS/ACTIVE_WORK pointers.
- Does not rewrite frozen KOS 2.0, does not change ADR 0027 budget, does not merge PR #83.
- Required review: project Product Decision `PD-KOS-UPGRADE-UK-001`; independent Architecture/Quality of this advisory pin remain open.
- Required validation: `KOS_AS_OF` + kit `validate-kos.sh` in advisory mode.

## Decision

- Disposition: Adopted
- Decision source and date: Human Product Owner in-session `2026-08-27 Asia/Shanghai`, after authorizing Kit `v0.5.0` publication and instructing Universe Keyboard to connect to 2.2.
- Rationale: pin an auditable Kit tag and start advisory envelopes on one workflow before any `required` cutover.
- Deferred-until: not applicable.

## Evidence

- Release notes: https://github.com/shchnk1103/kos-agent-kit/releases/tag/v0.5.0
- Applied changes: this branch `docs/kos-2-2-advisory-v0.5.0`
- Residual: historical Markdown without envelopes is out of the include glob; `required` is not authorized.
