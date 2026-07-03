# ENV-TOOLING-001 Quality Rework R1 Evidence

> Collection date: 2026-07-03 Asia/Shanghai
>
> Baseline: `74c8ff3b578b4b28d831bf63df914ee6c3093165`
>
> Branch: `codex/env-tooling-001`
>
> Scope: Capability and shipping-boundary verification only. This is not 004C-R1, Benchmark or Task 7 evidence.

## Capability Verification

| Check | Result | Evidence |
|---|---|---|
| Focused tests | Passed | `swift test` in `Packages/EnvironmentDigestTool`; all executed tests passed |
| Tool Release build | Passed | `swift build -c release` in `Packages/EnvironmentDigestTool` |
| Swift format lint | Passed | `swift format lint --recursive Sources Tests Package.swift` |
| Static shipping target membership | Passed | No `EnvironmentDigestTool` or `EnvironmentDigest` reference in the Xcode project, `Packages/RimeBridge/Package.swift` or `Packages/KeyboardCore/Package.swift` |

The focused suite covers the frozen exclusion patterns, unsupported nested lookalikes, excluded-item metadata
privacy, canonical JSON escaping, LF/BOM, Unicode normalization collision, case preservation, provenance artifacts,
failure artifacts, complete inventory mutation detection and `custom_phrase.txt` approval provenance.

## Dynamic Main App / Extension / RimeBridge Release Graph

**Result: Blocked — not passed.**

Command attempted:

```sh
xcodebuild -list -project "Universe Keyboard.xcodeproj"
```

Package graph resolution stopped before schemes or Release products could be evaluated because the frozen worktree's
`Packages/RimeBridge/Vendor` entries do not contain usable binary artifacts. Xcode reported this for all required
librime vendor XCFrameworks, including `librimeRIME`, Boost, glog, leveldb, marisa, OpenCC, yaml-cpp, Lua and
librime-lua targets.

Consequences:

- Main App Release graph: **Blocked**.
- Keyboard Extension Release graph: **Blocked**.
- RimeBridge Release graph: **Blocked**.
- Dynamic symbol/dependency exclusion: **Not executed**.

The static target-membership result does not replace these blocked dynamic checks. Quality must retain them as
blocked until the frozen vendor artifacts are restored and the Release graph can be resolved.
