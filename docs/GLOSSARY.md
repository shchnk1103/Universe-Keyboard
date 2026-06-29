# Project Glossary

## Purpose

Terms are defined only enough to route readers to authoritative sources. Implementation details remain in linked documents.

| Term | Short definition | Related sources / ADRs | Common misunderstanding |
|---|---|---|---|
| App Group | Apple shared-container identity used by the main App and Extension | `shared-container-and-rime-lifecycle`; ADR 0003 | It does not make every file safe for unrestricted concurrent writes |
| Shared Container | App Group filesystem/preferences used for RIME data and settings | ADR 0003; lifecycle architecture | It is not `Packages/RimeBridge/Vendor` |
| Composition | Unfinished input owned by the current controller/RIME interaction | input-pipeline architecture; ADR 0002 | It is not durable across visibility or process death |
| Raw Input | Unformatted key sequence used for RIME replay/semantics | input-pipeline architecture | It is not necessarily equal to display preedit |
| Preedit | RIME display representation of unfinished input | input-pipeline architecture | Segmentation spaces/confirmed segments may make it unsuitable for replay |
| Inline Preedit | Preedit displayed in the host text field as marked text | input-pipeline architecture | It is not already committed host text |
| Marked Text | Host text range representing active composition | input-pipeline architecture; ADR 0002 | `unmarkText` alone is not reliable for every equal-content finalization path |
| Commit | Finalize text into the host document and clear composing ownership | input-pipeline architecture | Candidate display and commit are separate operations |
| Candidate | Selectable result from RIME, fallback or correction layers | PROJECT_CONTEXT; input-pipeline architecture | Not every candidate kind has a RIME selection reference |
| Candidate Reference | Page/global metadata used to select the intended RIME item | PROJECT_CONTEXT | Candidate title text alone is not a stable identity |
| Partial Commit | Candidate selection that confirms part while retaining remaining composition | `architecture/partial-commit.md` | It is not multiple arbitrary undo levels |
| Session | Process-local librime input state | ADR 0004 | It is not deployment and is not shared across processes |
| Session Recovery | Recreate/reselect/replay within an active presentation | ADR 0004; lifecycle architecture | It must not run full deployment |
| Deployment | Main-App maintenance that prepares compiled RIME runtime data | ADR 0001 | Opening the keyboard is not deployment |
| Schema | RIME input scheme/configuration selected for candidate generation | `RIME_SCHEME_MANAGEMENT.md` | Installed source files do not prove successful deployment |
| Fallback | Safe degraded non-equivalent path used when prepared RIME runtime is unavailable | ADR 0008 | It must not be advertised as the selected real RIME scheme |
| RIME | Input-method engine and configuration ecosystem used for Chinese candidates | PROJECT_CONTEXT; ADR 0001/0004 | RIME ranking is not typo-correction ranking |
| RimeBridge | Production package bridging Swift through ObjC/ObjC++ to librime | PROJECT_CONTEXT; Swift 6 architecture | It is not an app/extension-local duplicate bridge |
| Lua | Optional RIME module/scripts enabling advanced schema behavior | scheme management; Lua archived plan; ADR 0004 | Compiled linkage alone does not prove runtime capability |
| OpenCC | Conversion assets/filter used by deployed RIME schemas | [`architecture/opencc-integration.md`](architecture/opencc-integration.md) | It is not an application-layer post-commit text rewrite |
| Smoke Test | Narrow runtime proof that a packaged capability works in a prepared environment | release checklist; manual acceptance | A skipped fixture or compile success is not a passed runtime smoke test |
| Full Access | iOS keyboard permission required for shared capabilities in this project | ADR 0007 | The main App cannot always know the Extension's live state before it runs |
| User Dictionary | Per-schema librime learning data under `Rime/user` | `RIME_USER_DICTIONARY.md`; ADR 0005 | It is not safely mergeable across unrelated schemas |
| Safety Backup | Verified snapshot required before a destructive dictionary restore | ADR 0005 | Current implementation does not yet enforce it |
| Technical Debt | Accepted unresolved risk with mitigation, owner and resolution trigger | `TECH_DEBT.md` | It is not a feature wishlist |
| ADR | Durable record of context, selected decision, alternatives and consequences | governance; ADR directory | It must explain why, not just what changed |
| Plan | Temporary staged intent with explicit lifecycle status | governance; `plans/` | Archived plans are not current truth |
| Source of Truth | Single document category that owns the complete version of a fact | governance | Multiple matching copies do not increase reliability |
| Playbook | Agent operating procedure linking to authoritative domain sources | governance; AI workflow | It must not duplicate architecture content |
