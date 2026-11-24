# english_wordlist_v1.json — Sources and Licenses

Generated static English wordlist for English-mode prefix candidates
(EN-CANDIDATE-AUTOSPACE-IMPL-001). Runtime never downloads anything; this
file is a pinned build-time artifact verified by `EnglishWordlistPinnedArtifactTests`.

SHA-256 of `english_wordlist_v1.json`: `593309209616b50325505019a02fa16bb24105214f2e44a322203b4b8608b7c0`
Size: 220164 bytes (215.0 KiB) — inside the 150–250 KiB budget band.
Entry count: 21358. `contentVersion`: "1.0.0".

## Source 1 — SCOWL v1 (sizes 10–95)

- Product: SCOWL (Spell Checker Oriented Word Lists), Version 2020.12.07.
- Download: <http://downloads.sourceforge.net/wordlist/scowl-2020.12.07.tar.gz>
  (official release page: <http://wordlist.aspell.net/other/>).
- License: MIT-class permission. From the distribution `Copyright` file:
  "Permission to use, copy, modify, distribute and sell these word lists,
  the associated scripts, the output created from the scripts, and its
  documentation for any purpose is hereby granted without fee, provided
  that the above copyright notice appears in all copies and that both that
  copyright notice and this permission notice appear in supporting
  documentation." (Copyright 2000-2018 by Kevin Atkinson; full text
  ships in the SCOWL archive and is retained below.)
- Used for: Tier A (very-common core: `english-words.10`, `.20`,
  `american-words.10`, `.20`, `british-words.10`, `.20`) and the validation
  anchor set (`*-words.10` … `*-words.95` with variants).

## Source 2 — Moby Words II (Grady Ward)

- Product: Moby Word Lists by Grady Ward, release 1.0 (1996), file
  `74550com.mon` (common-word list, frequency order) and `354984si.ngl`
  (single words, validation anchor).
- Download: <https://raw.githubusercontent.com/en-wl/wordlist/v1/other/mwords.tar.gz>
  (the Moby archive as distributed with the SCOWL v1 source tree; the
  original Project Gutenberg location is <https://www.gutenberg.org/ebooks/3201>).
- License: Public domain. The SCOWL v1 `Copyright` file records, verbatim:
  "The Moby lexicon project is complete and has been place into the public
  domain. Use, sell, rework, excerpt and use in any way on any platform.
  Placing this material on internal or public servers is also encouraged."
  The mwords archive also carries an older commercial-license section; the
  public-domain declaration above supersedes it for distribution use and is
  the basis relied on here (same reliance as SCOWL itself, which consumes
  Moby as its size-10 frequency basis).


## Generation recipe (deterministic)

1. Tier A: union of SCOWL sizes 10 + 20 across english/american/british
   `-words` lists; keep `^[a-z]{2,12}$`; sort alphabetically.
2. Tier B: walk Moby `74550com.mon` in file order (frequency-ranked);
   lowercase; keep `^[a-z]{2,12}$`; require membership in the SCOWL 10–95
   anchor set or Moby `354984si.ngl`; dedupe against Tier A; stop when the
   serialized JSON reaches ~215 KiB.
3. Serialize `{"version":1,"contentVersion":"1.0.0","words":[...]}` with
   compact separators. Tier A order is alphabetical; Tier B preserves Moby
   frequency order (used as candidate ranking within a shared prefix).

Regeneration requires re-running the offline script against the two pinned
downloads above; the pinned SHA-256 test fails on any content drift.

## SCOWL copyright notice (retained per license terms)

```text
Copyright 2000-2018 by Kevin Atkinson

Permission to use, copy, modify, distribute and sell these word
lists, the associated scripts, the output created from the scripts,
and its documentation for any purpose is hereby granted without fee,
provided that the above copyright notice appears in all copies and
that both that copyright notice and this permission notice appear in
supporting documentation. Kevin Atkinson makes no representations
about the suitability of this array for any purpose. It is provided
"as is" without express or implied warranty.
```
