# KOS local gate — 2026-09-06

Grade: Executor-recorded command evidence, not independent Quality or App Release approval.
Input commit: `cc75ab76019fcfc98e21207cac12f5e7a9862edb`; base `281600903d04c08b1af70eee47ad1196e88fe8f7`. Subsequent adoption changes are limited to Profile pins and documentation; product/CI contents are unchanged.

## Environment and results

Host macOS 27.0 beta `26A5425a`; Xcode 27 beta `27A5252f`; iOS 26.5 runtime `23F73`; dedicated iPhone 17 Pro device `36BAABED-6846-4F9A-A672-6884B54CF50E`.

- KeyboardCore: reuse prior 1072-test passing result on the same beta toolchain and unchanged sources (see prior evidence).
- RimeBridgeTests: 95 total, 75 passed, 20 conditional skips, zero failures.
- Universe Keyboard scheme: 289 total, 286 passed, 3 conditional skips, zero failures; includes KeyboardTests.
- Debug and Release builds: both exit 0.
- No Swift, project, test, workflow or classifier changes; no test weakening or global Xcode selection change.

Command for each of Bridge Debug test, App Debug test, App Debug build and App Release build:

```sh
DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer xcodebuild \
  -project 'Universe Keyboard.xcodeproj' -scheme '<RimeBridgeTests or Universe Keyboard>' \
  -configuration '<Debug or Release>' \
  -destination 'platform=iOS Simulator,id=36BAABED-6846-4F9A-A672-6884B54CF50E' \
  -derivedDataPath /private/tmp/uk-kos-astra-beta265-derived \
  CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete \
  SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES '<test or build>'
```

## Earlier failures and limits

Xcode 27 beta/iOS 26.0 had 19 App test-host crashes, also reproduced on unchanged baseline. None recur in this run; changing runtime/environment does not alone establish crash root cause. Those runs remain historical failures, not rewritten passes.

Xcode 26.6 continued returning exit 70 after successful iOS 26.5 installation. LaunchServices rejects its GUI with `kLSIncompatibleApplicationVersionErr`; [Apple requirements](https://developer.apple.com/xcode/system-requirements/) list macOS 26.2–26.x support, while this host runs macOS 27 beta. Stable CI environment is therefore not locally identical. The applicable suites/flags passed on the local beta toolchain; this does not claim physical-device, App Release or performance acceptance.

Hosted full pass for prior instruction candidate `31bfbed1a5214b1519558501cbe19ea4672d6036`: [run 33975144350](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/33975144350). Later PR HEAD requires its own hosted checks. Kit release used for structural validation: `f7f4dad6750b59dc827c1366fcd276447b2820b2`.

## Local retained artifacts

Logs: `/private/tmp/uk-kos-parity-beta265/`. Result bundles: `/private/tmp/uk-kos-astra-beta265-derived/Logs/Test/`. These are local retention, not permanent hosted artifacts. Full commands and results above are the portable record.

| Log | SHA-256 |
|---|---|
| RimeBridgeTests-Debug-test.log | `162c5ca1e692e5562ffe143f51be29b6a3208d335128c954c82cc5a307bcd480` |
| Universe_Keyboard-Debug-build.log | `c0a240313a28e20768644520f0ca2572608bbd88a848767f0a2f58531cbfa52b` |
| Universe_Keyboard-Debug-test.log | `279443550f0d9219898e98d687425d4984d9ca9022554c7c7284be43cddbe785` |
| Universe_Keyboard-Release-build.log | `66c7865a4ba967631376d50f034d1ba46b509ce3c1b7d78962eb830c8a46d070` |

## Adoption verification binding

- 31bfbed: commit `31bfbed1a5214b1519558501cbe19ea4672d6036`, tree `2477a7abca7f04ca5713f4f9e284d748e0b3ab10`.
- cc75ab7: commit `cc75ab76019fcfc98e21207cac12f5e7a9862edb`, tree `6cb1c7be31393a090ae86ac17bf8958b66183a5d`.
- 11d8a18: commit `11d8a188889cc7325f3297c6ed56636d4fbf5352`, tree `8556a6e317527ea5064a06d77efe52863c8dede7`.

SHA-256 of `git diff --binary 31bfbed 11d8a18`: `c717e832b9307c95c2f46e57dd7684f2db73060a05f78e8b8324c0b70bc5d3d6`.

`31bfbed → cc75ab7` changes preparation records only; `cc75ab7 → 11d8a18` changes `.kos/project.json` (only adopted version/commit), AGENTS pin and documentation only. All production, test, project, scripts and workflow paths have empty diffs for `31bfbed → 11d8a18` and from `281600903d04c08b1af70eee47ad1196e88fe8f7`. Local product tests executed at cc75ab7 therefore cover the unchanged product contents of 11d8a18. This does not claim unit tests validate policy text.

At 11d8a18, `KOS_AGENT_KIT_ROOT=/private/tmp/kos-agent-kit-release-v070 KOS_AS_OF=2026-09-05T10:30:00+08:00 bash scripts/ci/run_lightweight_checks.sh origin/main HEAD` passed against base 281600903d04c08b1af70eee47ad1196e88fe8f7. Independently, `git diff --check 31bfbed 11d8a18` and Markdown links for that exact pair pass. The fixed as-of retains the previous advisory comparison; it is not a freshness or current authorization pass. Nine existing unique warnings remain, with no newly introduced warning code/path/message.

Later commits contain only review/evidence/status corrections; they require links/diff checks. A subsequent policy, Profile, source or environment change requires a new frozen review or applicable test run. Publication HEAD is recorded in the PR, avoiding an evidence-file self-reference.
