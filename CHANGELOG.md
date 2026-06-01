# CHANGELOG

Change history for Universe Keyboard. Entries are in reverse chronological order.

> **AI agents**: Load this file only when investigating historical decisions, debugging regressions, or understanding why a specific implementation approach was chosen. Do not load for routine coding tasks.

---

## 2026-06-01 — Keyboard UI V1 freeze

- **Frozen layout baseline**: `candidateBarHeight=44`, `keyHeight=45`, `keySpacing=8`, `keyboardGroupSpacing=10`, `keyHorizontalSpacing=6`, `thirdRowFunctionSpacing=10`, `primaryFunctionKeyWidth=46`, `functionKeySymbolPointSize=18`, horizontal margins `7`, `keyCornerRadius=9`.
- **Input feedback baseline**: standard keys emit visual press state, haptic feedback, and key click together from touch-down. Candidate commits and long-press variant commits use the shared feedback helper at commit time. Key click playback keeps the overlapping rapid-typing behavior.
- **V1 UI freeze rule**: keyboard UI is frozen unless a major usability issue is found. Future UI changes must cite a specific usability reason such as mistouch reduction, clipping, accessibility, or interaction regression.
- **Manual verification checklist captured**: slow typing, rapid typing, repeated function keys, long-press delete, edge keys, candidate commits, and accessibility labels.

---
