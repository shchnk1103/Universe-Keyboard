# AP-CHECK-001 点击前主机检查修正与预检

Human“可以按照你的建议继续”授权只修正主机检查并预检，不操作Simulator。root唯一私有脚本writer，无生产源码权。新上限16calls／15分钟；不续AP-META-003。原失败子断言仍缺原ps，保持未独立证明，不事后拼补原轮。

私有preclick_checkpoint.py将原合并assert换成先落盘全部原值，再逐项具名判定。PID、启动时间、精确binary路径仍严格核对；ps stat原文保留作辅助，不要求它必须包含Ss。运行条件改核当前LLDB SBProcess.GetState()==eStateRunning（本机枚举6），不读取frame、参数或内存。配置成功、绑定PID、唯一location、两处hit0、同步模式、无callback分别判定。异常解析／缺字段明确STOP，输出失败项；不覆盖已有checkpoint。

10项合成fixture：普通Ss及附加样本Ssx通过；PID复用、start漂移、路径漂移、非running、意外callback、hit1、ps失败、坏PID全部STOP且原值留存。额外模拟第二次判定写失败，第一次原值文件仍存在。样本Ssx仅验证检查逻辑，不补充原R3的缺失真实ps或证明历史失败原因。

实际无target LLDB批会话导入成功、API存在／running枚举6、exit0、stderr空；未调用live capture。capture支持pre-arm及pre-freeze独立快照，禁止用初始attach帧或旧快照判断下一次点击；native continue已返回prompt后才发短capture命令，不在Python等待或提前排队命中后命令。

五源码SHA、branch/HEAD/staged0保持，写文档前full dirty逐字一致。设备查询0、attach0、生产修改0、build/test/install/deploy/Maps/Git/备份删除0；不改CHANGELOG或架构合同。主机预检不等于appex运行核验。

原件：/private/tmp/ukey-appex-meta-preclick-preflight-20261006，entry、脚本、逐项fixture原值、fixture-results、interrupted-write、lldb-import、completion。最终12calls账本及最终脚本复算在收尾原生读回。

下一AP-META-004 Prepared仍仅空框一arm一freeze，metadata-only；新执行与fresh独占待授权。
