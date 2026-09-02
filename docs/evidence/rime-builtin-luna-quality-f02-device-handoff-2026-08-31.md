# RIME-BUILTIN-LUNA-QUALITY-001 — Physical-device handoff packet

> **Packet state:** `Replacement signed candidate re-frozen from b1d81fd — HOLD before install/run`
> **Prepared:** `2026-08-31 Asia/Shanghai` · **Re-frozen:** `2026-09-02 Asia/Shanghai` (supersedes `c5f3004` freeze)
> **Assignment:** [`RIME-BUILTIN-LUNA-QUALITY-001`](../assignments/rime-builtin-luna-quality-001.md)
> **Run ID reserved:** `RIME-BUILTIN-LUNA-QUALITY-001-PHYSICAL-20260831-001`
> **Evidence grade:** exact signed-build identity plus plan; no installation or
> device observation is created by this packet

## Authority and boundary

Independent Architecture and Quality re-review of evidence HEAD `bb43c5f`
both returned `Pass with conditions`, with no P0/P1. They closed the engineering
provenance and Q-09 inventory residuals and permit preparation of a clean
replacement signed candidate. Nothing here authorizes installation, device
execution, Assignment Exit, merge, TestFlight or Release.

The main checkout and PR #91 are outside this packet. The candidate must be
built from the isolated F-02 branch after its final governance-only commit. A
source SHA, simulator build or successful local test is not an installable-build
identity.

## Current replacement candidate freeze

| Field | Frozen value |
|---|---|
| Runtime implementation ancestry | `7260ca292fb8226face92781cb1c335ad0f31d1b` is an ancestor |
| Candidate source commit | clean `b1d81fd2f61522001bc1d15490563097bd581016` before and after build (source tree byte-identical at HEAD `f8c51f3`; docs-only commits on top) |
| Product / build / deployment | `1.0 (1)`; Debug; generic iOS arm64; minimum iOS 18.0 |
| Toolchain | Xcode `27.0 (27A5252f)`; iPhoneOS SDK `27.0 (24A5422a)`; Apple Swift `6.4 (swiftlang-6.4.0.33.1 clang-2100.3.33.1)` |
| Signing | Apple Development `SVGPGQXU8W`; Team `C33N6HTS9N`; App CDHash `ed46a655e08d615fbc2d576837ae05fc3f37c579`; Extension CDHash `a3814d38e5d36c4ebb0bc4cb1f8eab9333083d60` |
| Provisioning profile | `iOS Team Provisioning Profile: com.DoubleShy0N.Universe-Keyboard` (`06df90be-84d7-4d3a-987a-aceeb1fa8222`) |
| App bundle | `com.DoubleShy0N.Universe-Keyboard` |
| App executable | stub UUID `9A320701-2840-35A3-895F-4CAE62A7E7EC`, SHA-256 `72cc786de76c77561ffea94cae9a0f66f3efcc234cfa41b294925a7b69a2073f`, 92,128 bytes; code dylib UUID `473A0471-3176-3BD0-AE61-A86BC534F7F6`, SHA-256 `6d2ad897500b35af3d525b46ee6734a205b9696d32a0528b951415ee1ce071e1`, 28,570,160 bytes |
| Keyboard executable | stub UUID `ED410A4F-7D73-3518-9B89-32B8012836A0`, SHA-256 `b8121a09316765eccb7d4c828bc9df26fc8de6c2e579e4388bd60175f805f10d`, 89,504 bytes; code dylib UUID `706C66FD-A0BB-3E61-AE04-F0C95A1B2F31`, SHA-256 `45d469796c0f25384115ea306f6a69f0cbe0ef0ec6f297c79880e6fa279830fe`, 16,004,768 bytes |
| Built-in manifest | SHA-256 `6aa2d28918b9146cdf417ddb369ba57907e5bbcc3e2ce2c9bc1280f1a6e7b233`, 13,582 bytes; Extension runtime-resource duplicate count `0` |
| OpenCC AUTHORS in App | SHA-256 `cb34e252fa994679bcbfc8355581e821ceda44bd857875e2cfe15b7ec4eec006`, 277 bytes |
| Candidate artifact | `/tmp/f02-device-candidate-b1d81fd/Build/Products/Debug-iphoneos/Universe Keyboard.app`; `codesign --verify --deep --strict` passed |
| Installation receipt | `UNKNOWN` — cannot exist before installation |

This re-freeze supersedes the `c5f3004` freeze (S-03): `b1d81fd` landed a source
change to `RimeConfigManager` overlay generation after the `c5f3004` freeze, so the
prior identity table no longer represents current HEAD. The manifest and OpenCC
AUTHORS hashes are unchanged from `c5f3004` (committed resources the fix does not
touch); the executable stub/code-dylib UUIDs and hashes reflect the rebuilt source.
The replacement remains on HOLD. Any source rebuild, artifact disappearance,
signature/hash mismatch or unexpected install identity invalidates this freeze.
Human authorization is required before installation or the reserved run.

## Historical candidate — superseded by `b1d81fd` re-freeze (2026-09-02)

> **S-03 supersession:** the `c5f3004` freeze was invalidated by `b1d81fd` (a source
> change after the freeze). Do not install. Identity retained only to prevent
> accidental reuse.

| Field | Frozen value |
|---|---|
| Runtime implementation ancestry | `7260ca292fb8226face92781cb1c335ad0f31d1b` is an ancestor |
| Candidate source commit | clean `c5f30048b139bcbc2d8ea5552c5f8d053e09efe9` before and after build |
| Product / build / deployment | `1.0 (1)`; Debug; generic iOS arm64; minimum iOS 18.0 |
| Toolchain | Xcode `27.0 (27A5252f)`; iPhoneOS SDK `27.0`; Apple Swift `6.4 (swiftlang-6.4.0.33.1 clang-2100.3.33.1)` |
| Signing | Apple Development `SVGPGQXU8W`; Team `C33N6HTS9N`; App CDHash `2d879f70c1631c3a22add4826291c77046956512`; Extension CDHash `9e96c88307d8dbe348ea6cbbaada52b9adbde820` |
| App bundle | `com.DoubleShy0N.Universe-Keyboard` |
| App executable | stub UUID `C76D2B1A-37E6-36D3-8870-DE36272E7830`, SHA-256 `8f9594b9da614f91e23f5acf5ebd39a0df660821879f93f5a5afc094daf2d3d2`, 92,128 bytes; code dylib UUID `8EAABEA2-15B4-35A1-B909-67C595791F4B`, SHA-256 `08f7d338a89d2e33da9bef98c0cb04b0847e268a022c1afd0fdf9b966be005ca`, 28,567,344 bytes |
| Keyboard executable | stub UUID `B9A34CEA-7F77-36DD-96BB-77D876781871`, SHA-256 `3afb3b2e87bac27c71100d4194f97a71851e89fcd5a93cf09170b4b00b465ac9`, 89,504 bytes; code dylib UUID `5F19B994-DE42-333E-BC22-9D877D87ADA1`, SHA-256 `2cb7d56daee5a679339a104c8553a9376e0450da22ae2374a37caeacb33378ce`, 16,001,952 bytes |
| Built-in manifest | SHA-256 `6aa2d28918b9146cdf417ddb369ba57907e5bbcc3e2ce2c9bc1280f1a6e7b233`, 13,582 bytes; Extension runtime-resource duplicate count `0` |
| OpenCC AUTHORS in App | SHA-256 `cb34e252fa994679bcbfc8355581e821ceda44bd857875e2cfe15b7ec4eec006`, 277 bytes |
| Candidate artifact | `/tmp/f02-device-candidate-c5f3004/Build/Products/Debug-iphoneos/Universe Keyboard.app`; `codesign --verify --deep --strict` passed |
| Installation receipt | `UNKNOWN` — cannot exist before installation |

The `c5f3004` replacement remains on HOLD and cannot be installed. This identity is
retained only to prevent accidental reuse.

## Historical candidate — superseded, never install

| Field | Required value | Current state |
|---|---|---|
| Runtime implementation | Historical identity only | `fa5dbaf`; superseded by runtime/manifest changes through `7260ca2` |
| Candidate source commit | Historical clean-worktree HEAD | `d4572d93bb9da269cb68051c941099a1e1dec808`; **SUPERSEDED — DO NOT INSTALL** |
| Product version / project build setting | `1.0 (1)` | Signed artifact reports `1.0 (1)` |
| Configuration | One explicitly recorded signed device configuration | `Debug`, `generic/platform=iOS`, arm64, minimum iOS 18.0 |
| Xcode / iPhoneOS SDK / Swift | Exact output from the build host | Xcode `27.0 (27A5252f)`; iPhoneOS SDK `27.0 (24A5422a)`; Apple Swift `6.4 (swiftlang-6.4.0.33.1 clang-2100.3.33.1)` |
| Signing | Exact development identity and team | Apple Development identity `SVGPGQXU8W`; Team `C33N6HTS9N`; App CDHash `b0ae6624e6bf541e67f2e7ed730f13b2d6cf3843`; Extension CDHash `1e23256b969333e8863008463165dfc56c72059d` |
| App bundle identifier | `com.DoubleShy0N.Universe-Keyboard` | Signed artifact matches; installed receipt pending |
| App executable UUID / SHA-256 / bytes | Signed Debug executable stub plus code dylib | stub `1770F23D-D866-3773-B920-6EF713DB7E3B` / `b9fa5a2622d24a3dd30065f655ce81fc19c9763bc26fa561ec4cd9e2b2ed7877` / `92,128`; code dylib `4A660282-FE40-35FF-9A15-1F0E26FA12B6` / `1d252d58b59aeab1053bb716f01887ed43acdef43b332cbf03c5d83e646d8fec` / `28,417,616` |
| Keyboard executable UUID / SHA-256 / bytes | Signed Debug executable stub plus code dylib | stub `36EBF8E3-5B05-3798-A5AC-BB6B201E1640` / `982d982270f60e08fdeff49d3ed50d113d30d0d1f9ab79d9269b0b5799119c29` / `89,504`; code dylib `6756A501-DCBD-3FC8-A4CD-A74A36CE1504` / `a55013d15ce39cef9647793deba8792959ca63f3fc22ffca17eae39e002b6ca3` / `15,852,032` |
| Built-in manifest SHA-256 | Derived from the exact signed `.app` | `1715dc212b2f5190ac71563523ce93e953cb7bdb2ff8704a65b9956d2c47b8cf`, `6,140` bytes; Extension duplicate scan returned zero matches |
| Candidate artifact | Historical local product | `/tmp/f02-device-candidate-d4572d9/Build/Products/Debug-iphoneos/Universe Keyboard.app`; **SUPERSEDED — DO NOT INSTALL** |
| Installation receipt | Device reports matching app/version/build | `UNKNOWN` |
| Device | iPhone 13 Pro / iOS `27.0 (24A5424a)` | Human-reported target; must be reconfirmed at run start |
| Full Access baseline | Off | Pending Human observation |
| Network baseline | Airplane mode before first App launch/deployment | Pending Human observation |

The historical hashes remain only to prevent accidental reuse. The replacement
identity table above supersedes them, but the packet remains on HOLD and the
replacement cannot be installed without explicit Human authorization.

## Privacy and observation contract

- Use only the synthetic strings listed below in a new, otherwise empty local
  Reminders field. Do not save or share the reminder.
- Repository evidence may record the frozen expected candidate pages, PASS/FAIL,
  timings and content-free lifecycle markers. It must not copy unrelated host
  text, surrounding content, learned user candidates or device identifiers.
- Screenshots are optional and must be cropped to the keyboard/candidate region
  after checking that no personal content is visible.
- A crash, fallback keyboard, missing built-in scheme, candidate-page mismatch,
  deployment requiring network, or inability to prove the installed candidate
  immediately stops the run. Do not “repair and continue” under the same Run ID.

## One authorized physical run — execution matrix

Execution begins only after the Human Product Owner explicitly authorizes the
device run and the candidate-freeze table has no `UNKNOWN` identity fields.
Each Human instruction should contain one action.

### A. Fresh App Group and offline first deployment

1. Record the installed receipt, then remove Universe Keyboard from the iOS
   keyboard list and delete the existing development App. Confirm no other
   installed target from this project retains the same App Group.
2. Install the frozen candidate over the wired Xcode device connection without
   launching it. Enable airplane mode before the first launch.
3. Launch the main App and perform only the normal built-in-resource deployment.
   Do not download a scheme or resource. A network prompt/dependency is FAIL.
4. Record the content-free deployment result and built-in generation/receipt
   identity. Select the built-in Luna scheme if the UI requires an explicit
   selection.
5. Add Universe Keyboard with Full Access off and open a new empty Reminders
   field. A fallback adapter, missing candidate bar or missing Luna scheme is
   FAIL.

Deleting and reinstalling is an operational fresh-container treatment, not by
itself proof that App Group bytes were empty. The run must additionally show a
first-generation deployment receipt with no prior-generation recovery path.

### B. Candidate quality with Full Access off

Use a clean session for each row and do not select candidates before recording
the first visible page.

| Fuzzy setting | Input | Expected complete first page |
|---|---|---|
| Off | `ni` | `你 / 拟 / 尼 / 泥` |
| Off | `nihao` | `你好 / 妳好 / 逆号 / 拟好` |
| Off | `sanjiaoxing` | `三角形 / 三角 / 三教 / 三焦` |
| Off | `jintiantianqihenhao` | `今天天气很好 / 今天天气 / 今天 / 金田` |
| On | `ni` | `你 / 里 / 李 / 离` |
| On | `nihao` | `你好 / 妳好 / 利好 / 立好` |
| On | `sanjiaoxing` | `三角形 / 三角 / 山脚 / 三教` |
| On | `jintiantianqihenhao` | `今天天气很好 / 今天天气 / 今天 / 金田` |

Also verify the frozen conversion/lookup vectors:

| Capability | Input / operation | Expected first page or output |
|---|---|---|
| Traditional candidate | `fanti` | `繁体 / 反踢 / 反提 / 饭` |
| Stroke reverse lookup | `` `pspzzpn `` | `你 / 您` |
| Same-session isolation | clear Stroke composition, then type `ni` | ordinary fuzzy-mode `ni` page, not a retained Stroke page |
| OpenCC s2t | `汉语龙马发型` | `漢語龍馬髮型` |
| OpenCC t2s | `漢語龍馬髮型` | `汉语龙马发型` |
| OpenCC t2hk | `僞兌叄` | `偽兑叁` |
| OpenCC t2tw | `着牀麪條` | `著床麵條` |

One unexpected candidate, order difference or missing page member is FAIL; do
not accept “能打出汉字” or Top-1 alone.

### C. Full Access and lifecycle

1. With Full Access still off, dismiss and reopen the keyboard in a second empty
   host field; repeat `nihao` and record whether the exact page remains stable.
2. Enable Full Access, return to the same host and repeat `nihao`. Access state
   is a treatment; it must not change the built-in candidate page.
3. Dismiss the host App, reopen it and repeat the fuzzy-off `ni` and
   `sanjiaoxing` rows.
4. Reboot the device, keep airplane mode on, reopen the keyboard and repeat
   fuzzy-off `nihao`; verify that no redeployment/download/fallback occurs.
5. If later authorized as a separate destructive treatment, terminate only the
   uniquely identified Keyboard Extension process, then verify one clean
   restart. This does not close TD-001 process-death installation atomicity.

### D. Bounded performance and stability observations

Record at least five cold Extension presentations and five post-reboot
candidate-ready samples using one documented timing method. Preserve individual
samples plus median and worst; do not infer a Product budget without Human
acceptance. Record the exact `.app`/IPA size delta against the agreed baseline.

Query crash and Jetsam reports in a bounded run window. A no-match proves only
that no matching report was found in that window. Any new matching report is a
FAIL/HOLD pending symbolication against the frozen executable UUIDs.

## Result ledger

| Gate | Result | Evidence pointer |
|---|---|---|
| Candidate build freeze | `PASS` | clean `b1d81fd` signed Debug App; deep/strict signature, App/Extension UUID/hash/CDHash, manifest, AUTHORS and zero Extension duplicate evidence recorded above (re-frozen 2026-09-02, supersedes `c5f3004`) |
| Installation receipt | `HOLD` | no install action authorized or performed |
| Q-01 fresh/offline | `NOT RUN` | — |
| Q-02 candidate quality/cold starts | `NOT RUN` | — |
| Q-03 OpenCC physical RC | `NOT RUN` | — |
| Q-04 Stroke/Full Access/lifecycle | `NOT RUN` | — |
| Q-06 Extension consumption | `NOT RUN` | — |
| Q-07 performance/size | `NOT RUN` | — |
| Q-08 install/redeploy/relaunch | `NOT RUN` | — |
| Crash/Jetsam bounded query | `NOT RUN` | — |
| Human Product Gate | `PENDING` | not implied by this packet |

## Separate downstream gates

- iOS 18 physical-device compatibility is not covered by the named iOS 27
  device and remains a separate Environment/Quality gate.
- Hosted CI, exact archive provenance and Human/legal sufficiency remain
  separate gates. Machine-readable generator provenance and engineering license
  inventory are implemented locally but remain subject to the current
  independent re-review.
- A passing physical run does not authorize PR creation, merge, TestFlight or
  Release and does not change PR #91.
