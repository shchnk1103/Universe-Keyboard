# Onboarding

## Goal

This path teaches enough context to make safe changes without requiring a full repository read. Use the task-specific reading map as soon as assigned work is known.

## Day 1: Repository And Navigation

Read:

1. `AGENTS.md`
2. `KNOWLEDGE_INDEX.md`
3. `KNOWLEDGE_OS.md`
4. `PROJECT_CONTEXT.md`
5. `DOCUMENTATION_GOVERNANCE.md` Source of Truth section

Outcome: identify product/test targets, packages, current architecture owners and where to route questions. Inspect the file tree and build configuration; do not infer current behavior from archived plans.

## Day 2: Extension, RIME And Shared State

Read:

1. `architecture/shared-container-and-rime-lifecycle.md`
2. ADR 0001, 0002, 0003, 0004 and 0008
3. `architecture/swift6-migration.md`

Outcome: explain deployment versus session, visibility cleanup, process death, fallback and App Group ownership without reading historical chats.

## Day 3: Input And Candidates

Read:

1. `architecture/input-pipeline-and-marked-text.md`
2. `architecture/partial-commit.md`
3. relevant CandidateBar sections in `PROJECT_CONTEXT.md` and `UI_STYLE_GUIDE.md`
4. `TYPO_BENCHMARK.md` only if correction behavior is relevant

Outcome: distinguish raw input, display preedit, marked text, commit, candidate reference, Partial Commit and UI candidate caches.

## Day 4: Operations

Read:

1. `DEBUGGING.md`
2. `PERFORMANCE_BASELINE.md`
3. `RELEASE_CHECKLIST.md`
4. `TECH_DEBT.md`

Outcome: collect evidence, classify session/deployment/UI failures, understand the minimum release matrix and avoid claiming unsupported safety/performance.

## Day 5: Decisions And Collaboration

Read:

1. `architecture/decisions/`
2. `ARCHITECTURE_TIMELINE.md`
3. `AI_WORKFLOW.md`
4. `KNOWLEDGE_DEPENDENCIES.md`
5. the matching domain playbook under `playbooks/` for the assigned ownership

Outcome: explain why boundaries exist, how to change them, how to coordinate agents and what documentation impact follows.

## First Safe Contribution

Before editing:

- select a task in `READING_MAPS.md`;
- identify files and tests from current source, not a plan;
- state assumptions and evidence;
- keep changes inside one owner area;
- run the documentation review checklist and pre-push review.

## Safe To Skip Initially

Until the task requires them, a new contributor can skip:

- `CHANGELOG.md` chronological history;
- archived `docs/plans/`;
- detailed typo-correction milestones;
- Swift 6 manual acceptance snapshots;
- vendor build scripts and artifact internals;
- Lua diagnostics details;
- user-dictionary backup internals;
- full UI geometry constants;
- future swipe/iPad planning.

Skipping means “not needed for initial orientation,” not “safe to ignore when changing that subsystem.”

## Stop Conditions

Pause implementation and investigate when:

- source and current documentation conflict;
- an accepted ADR would be violated;
- the task requires a playbook that does not exist and ownership is ambiguous;
- a change touches user data without a recovery model;
- a claimed performance or release requirement has no evidence;
- an archived plan is the only source supporting the proposed behavior.
