# RIME-BUILTIN-LUNA-QUALITY-001 — Physical-device handoff packet

> **Packet state:** `Prepared — HOLD before build/install`
> **Prepared:** `2026-08-31 Asia/Shanghai`
> **Assignment:** [`RIME-BUILTIN-LUNA-QUALITY-001`](../assignments/rime-builtin-luna-quality-001.md)
> **Run ID reserved:** `RIME-BUILTIN-LUNA-QUALITY-001-PHYSICAL-20260831-001`
> **Evidence grade:** plan only; no build, install or device observation is
> created by this packet

## Authority and boundary

Independent Architecture and Quality re-reviews both returned
`Pass with conditions`, with no P0/P1 findings, for implementation
`fa5dbaf1fded3e25ac39a6c0c675cddc786f01bb` and evidence
`786f4c720949784f4f66515228778bf6a012b952`. Both permit preparation of an
exact installable build and this physical-device matrix. They do not authorize
device execution, Assignment Exit, merge, TestFlight or Release.

The main checkout and PR #91 are outside this packet. The candidate must be
built from the isolated F-02 branch after its final governance-only commit. A
source SHA, simulator build or successful local test is not an installable-build
identity.

## Candidate freeze — required before leaving HOLD

| Field | Required value | Current state |
|---|---|---|
| Runtime implementation | `fa5dbaf1fded3e25ac39a6c0c675cddc786f01bb` is an ancestor of the candidate | Known source boundary; not yet bound to an installed payload |
| Candidate source commit | Exact clean-worktree HEAD after final handoff documentation | `UNKNOWN` until the documentation commit is created |
| Product version / project build setting | `1.0 (1)` | Repository setting only; installed receipt pending |
| Configuration | One explicitly recorded signed device configuration | `UNKNOWN` |
| Xcode / iPhoneOS SDK / Swift | Exact output from the build host | `UNKNOWN` |
| App bundle identifier | `com.DoubleShy0N.Universe-Keyboard` | Repository value; installed receipt pending |
| App executable UUID / SHA-256 / bytes | Derived from the exact signed `.app` | `UNKNOWN` |
| Keyboard executable UUID / SHA-256 / bytes | Derived from the exact signed `.appex` | `UNKNOWN` |
| Built-in manifest SHA-256 | Derived from the exact signed `.app` | `UNKNOWN` |
| Installation receipt | Device reports matching app/version/build | `UNKNOWN` |
| Device | iPhone 13 Pro / iOS `27.0 (24A5424a)` | Human-reported target; must be reconfirmed at run start |
| Full Access baseline | Off | Pending Human observation |
| Network baseline | Airplane mode before first App launch/deployment | Pending Human observation |

Any `UNKNOWN`, dirty worktree, source mismatch, bundle/receipt mismatch or
unexpected automatic network restoration keeps the run on HOLD. The candidate
freeze must be committed to this table or a content-free run receipt before the
first device action is counted as evidence.

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
| Candidate freeze | `HOLD` | identity fields above contain `UNKNOWN` |
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
- Hosted CI, exact archive provenance, complete machine-readable generator
  provenance, independent license inventory and Human/legal sufficiency remain
  separate gates.
- A passing physical run does not authorize PR creation, merge, TestFlight or
  Release and does not change PR #91.
