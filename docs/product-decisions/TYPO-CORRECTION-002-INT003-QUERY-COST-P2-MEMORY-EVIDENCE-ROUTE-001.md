# TYPO-CORRECTION-002-INT003-QUERY-COST-P2-MEMORY-EVIDENCE-ROUTE-001

2026-10-10：Human 已[批准收窄 P2 合同](TYPO-CORRECTION-002-INT003-QUERY-COST-P2-LOCAL-EVIDENCE-REQUIREMENTS-001.md)。本轮复用 memory probe/freeze/LLDB；大型 trace/外部 anchors 不再是限定 query P2 必需条件。存储协议、目录所有权、配额、保留策略及 UI 延期，不作完成前置；[最小验证准备](../plans/typo-correction-002-int003-query-cost-p2-minimal-route-preparation-001.md)已记录，运行 AUTH 尚未释放，父 Active。

Status: Human-approved scoped evidence-route decision

Decision source: Human “授权你按照建议继续吧”, 2026-10-08 Asia/Shanghai, in reply to the explicit recommendation to change P2 query-cost evidence to dedicated one-shot memory snapshots and separately design the interface.

## Effective boundary

For the next INT003 P2 candidate/run only, select dedicated query-cost memory evidence in place of journal acquisition for query-count/result/readiness/facade-time analysis. The questions and privacy/completeness/observer-overhead requirements remain; journal writer sealing is replaced by probe-specific admission closure, immutable freeze, complete invocation accounting and exact-byte validation. This is not evidence that a journal writer has drained. Do not open logging/HF or change diagnostic category preferences; before/after finite preference presence/value must prove no change. If unexpected settings mutation occurs, stop and obtain supported restoration authority; UI false does not restore absence.

The prior journal design and Capture003 proposal remain historical and unexecuted. Their source package, readiness receipts and AUTH do not authorize the new route or automatically transfer to a future package. The current stored configuration/UI receipts can inform planning but cannot prove future live Extension access/schema or settings state. Old consumed AUTHs remain consumed. No relaxed lower-bound result may be accepted as an exact total.

This decision authorizes the separate interface-design Assignment/AUTH above only. Its design document remains Proposed; implementation, source candidate selection, build/test, installation, debugger transport verification and official Capture require bounded authority later. Parent TYPO-CORRECTION-002 remains Active. No Product Gate, ADR Accept, merge, TestFlight or Release; no new latency threshold or return to the removed 180 ms hard bar. Physical-device evidence profiles are unaffected; this selected route concerns Debug Simulator P2 only.

## Revalidation

Compare old and selected evidence units, freeze semantics, missing/loss accounting, preference and transport boundaries in the interface plan and independent review. Keep same diagnostic questions; no claim of RIME CPU time, full key/UI performance or Release-like acceptability. Main movement does not trigger automatic retries. No accepted production ADR is changed by this experimental transport choice.

Implementation handoff: [TYPO-CORRECTION-002-INT003-QUERY-COST-P2-MEMORY-INTERFACE-DESIGN-001](../assignments/typo-correction-002-int003-query-cost-p2-memory-interface-design-001.md). Static feasibility residuals remain future validation requirements, not already-passed runtime gates.
