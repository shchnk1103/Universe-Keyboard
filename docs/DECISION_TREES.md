# Decision Trees

## Purpose

Use these trees to classify work before planning. They route governance and evidence; they do not prescribe implementation.

## Any Change

```text
Does behavior or knowledge change?
  no -> state documentation impact: none, with reason
  yes -> identify Source of Truth
           -> durable decision or product contract?
                yes -> add/supersede ADR
           -> unresolved risk introduced?
                yes -> update TECH_DEBT
           -> diagnostic path changed?
                yes -> update DEBUGGING
           -> release evidence/gate changed?
                yes -> update RELEASE_CHECKLIST
           -> update CHANGELOG after work occurs
```

## New Feature

```text
Is it important/user-visible?
  -> identify owning domain document
  -> crosses targets, lifecycle, user data, RIME/Lua/OpenCC/Full Access?
       yes -> ADR required
  -> needs staged work?
       yes -> Active plan with exit/archive condition
  -> define tests, diagnostics and release acceptance
  -> update README only if project-entry capability materially changes
```

## Bug Fix

```text
Can the root cause be proven?
  no -> follow DEBUGGING; add evidence, not speculative docs
  yes -> does the fix reveal a durable invariant or recurring failure flow?
       yes -> update architecture or DEBUGGING owner
  -> did a product contract change rather than get restored?
       yes -> ADR required
  -> record completed fix in CHANGELOG
```

## Architecture Change

```text
More than one viable approach or durable boundary change?
  yes -> ADR before treating direction as accepted
  -> update current architecture source
  -> follow KNOWLEDGE_DEPENDENCIES
  -> update TECH_DEBT for migration gaps
  -> update DEBUGGING / PERFORMANCE / RELEASE where operational behavior changes
  -> update playbooks last
```

## Performance Work

```text
Is there a real measured regression or requirement?
  no -> collect baseline; do not invent a target
  yes -> record environment/method/evidence
  -> does optimization alter architecture or lifecycle?
       yes -> ADR and architecture review
  -> update measurement method only if method changed
  -> update release gate only after evidence is reviewable
```

## Testing Or Release Change

```text
Test command/target/acceptance changed?
  -> update RELEASE_CHECKLIST
  -> update test/release playbook and reading map
  -> avoid hardcoded counts or temporary simulator names
  -> architecture ADR only if ownership/strategy changed
```

## Documentation Change

```text
Is a new document necessary?
  -> define responsibility and dependency edges
  -> does an existing owner already answer it?
       yes -> edit/link existing owner
       no -> create source and add navigation route
  -> volatile snapshot?
       yes -> add date/commit/environment/evidence/expiry
  -> plan completed/replaced?
       yes -> archive/supersede header and current-source links
  -> run health/governance checks
```

## Lifecycle Or User-Data Change

```text
Touches Extension visibility, RIME session, App Group, dictionary or restore?
  -> ADR required
  -> review PROJECT_CONTEXT and owning architecture source
  -> review DEBUGGING failure paths
  -> review RELEASE physical-device evidence
  -> review TECH_DEBT and privacy boundary
  -> update applicable playbooks
```
