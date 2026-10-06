# Quality R7 Usage Record — V3 Compatibility Gate 001

- Work Item: `KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001`
- Review round: `7`
- Actual reviewer identity: Codex delegated agent `/root/quality_r7_luna`
- Packet SHA-256: `c1b6e8481f1927d11398e6e45b957ba90731aff24865b0de389a9c74af1cbaef`
- Verdict: `Partial / incomplete`
- Budget: 8 tool calls or 8 active minutes, whichever occurs first
- Calls used: 8 / 8; call limit reached first
- Active time: under 8 minutes; exact active duration was not instrumented
- Checkpoint: after call 4, approximately 0.3 minutes elapsed; packet, Assignment, authorization, and manifest identities matched; raw logs, result metadata, candidate hashes/diff, CI classification, format, and RIME evidence remained to be reviewed

## Calls and outcomes

1. `shasum -a 256` on the frozen packet. Digest matched.
2. Read the frozen packet.
3. Read the Assignment, Product Authorization, and manifest r2.
4. `shasum -a 256` on the Assignment, Product Authorization, and manifest r2. All matched.
5. `git rev-parse HEAD` and `shasum -a 256` on all seven manifest-listed source/test files. Base and all seven file hashes matched.
6. Inspected the base-to-worktree diff for the six tracked source/test paths and read the new validator file. Tool output was truncated; complete candidate-diff/content inspection was not achieved.
7. Hashed and read the Stage A host-validation record, Stage A evidence addendum, Stage B reservation, run-1 failure receipt, and Stage B validation report. Hashes matched the packet.
8. Hashed the named toolchain and Stage B logs, format and RIME logs, CI workflow and classification, pinned RIME manifest and vendor receipt, prior Quality R6 receipt and usage record, and four result-bundle `Info.plist` files. All checked hashes matched their frozen identities. A subsequent `rg` command failed with a regex parse error; commands chained after that search did not execute. No raw log or CI file content was reviewed in this call.

## Read, write, and command scope

- Reads were confined to the frozen packet, packet-allowlisted repository documents, the seven candidate source/test files and their base diff, named Stage B raw logs, named result-bundle `Info.plist` files, and the packet-listed CI/RIME/prior-review inputs.
- No files were written or edited.
- Commands used: `shasum -a 256`, `cat`, `git rev-parse HEAD`, `git diff --no-ext-diff --unified=0` against the packet's exact base, and `rg -n`.
- The last `rg` expression had an unmatched parenthesis and returned a parse error. No subsequent command in that chained invocation ran.
- No tests, formatter, build, `xcresulttool`, Simulator/CoreDevice/UI command, installation, vendor fetch, network request, or other worktree access occurred.

## Checkpoint and remaining coverage

At call 4, approximately 0.3 minutes had elapsed. Verified at that point: packet SHA, Assignment SHA, Product Authorization SHA, and manifest r2 SHA. Remaining: source/test file hashes, candidate diff, Stage B reservation and validation evidence, raw logs and individual skips, result metadata, workflow/classification comparison, format/RIME provenance, and prior-review context.

At call 8, the source/test and document identities and result-bundle plist hashes matched. Remaining coverage at exhaustion: inspect raw log contents and commands; verify all counts, test suites, skips, and signed Keychain correspondence; compare Stage B matrix with current CI workflow/classification; inspect actual format/vendor log contents and diff-check evidence; finish reviewing the candidate diff and new validator; and inspect prior Quality R6 residual context. No inference of Pass is made for these uncovered claims.
