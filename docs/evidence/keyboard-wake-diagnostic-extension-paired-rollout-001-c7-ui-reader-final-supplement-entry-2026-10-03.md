# 最后raw diff/报告一致性补审 Entry

Human在收到精确最小scope/4calls600s预算批准请求后回复“额度已恢复，请继续吧”；root据此继续该已准备补审，不扩到reader/binary/设备。Prepared packet保留未执行历史，新[authorized round2 packet](../reviews/c7-ui-reader-candidate-architecture-r2-packet-2026-10-03.json)在派发前冻结，复用独立arch_reader_candidate Luna，root唯一repo writer。

原branch/HEAD/candidate相同，prepared10输入hash及新Entry均匹配，无必需UNKNOWN；完整before/status私有保全。C1只直接读raw unified patch（---before/+++after同Presentation、3hunks/12新增/无删除）及currentPresentation三处保护；不写diff parser，不要求diff --git。C2明确R0/A1已取得同candidate证据的有效复用、新report/usage覆盖一致、旧R1Partial/header矛盾保留。全部C1/C2Covered且复用条件满足才可当前combined限定artifact完整意见。

新4calls/600s hard、360soft，首实际tool计时持久化，建议call1读取全部11内容输入+timer、call2直接人工结论+短report和真实usage一起写（≤250中文字符，详细identity/hash放usage）。最早限即停、不自动续。没有build/test/simulator/container/install/UI/LLDB/Maps/Git/Release。
