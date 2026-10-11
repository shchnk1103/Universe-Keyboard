# M2 基线偏离／提前出口停点交付 — 2026-10-03

状态 **Incomplete / stopped**，不是Maps切换故障取证通过。原固定43d85d候选与原设备，新PID3626/session5c2bdb0d…loaded原UDID路径和两个UUID已核；出口断点1唯一resolved/0hit后continue成功。[原件及摘要](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m2-stop-artifacts/preservation.json)保存初始Entry原字节、Human回报、11debugcall原回执及22行完整request/response账本。

Human首先报告单次观测后显示取证、没有继续点击取证；随后报告基线第一次按键以为卡住、又按几次，候选与Maps输入框都未更新、标题取证。准确次数／键身份／点击UTC未测，不强写成恰好一次n或推反馈已确认。目标AppSwitcher步骤尚未下发，本轮不能绑定切换前后两个受控attempt。

root停止继续操作并仅核断点，机器发现出口hit count=1，早于freeze操作卡。Human“未再次点取证”的报告与机器“出口已命中”分别保留，不反推Human点错、源码重复触发或n导致freeze；真实触发动作、hit时刻及target pause开始均UNKNOWN。当前UI不更新包含调试暂停的可能，不据此认定Maps故障或owner为空。未读frame/borrow参数，未memory read／导出snapshot，未追加输入、切换或retry。

随后本session breakpoint delete1成功、list显示无断点、continue running、detach成功。机器PID3626状态Ss，源1279和installed78无漂移，两诊断原ABSENT/off、部署标志不变。Human视觉Exit“按钮显示取证，界面看起来一切正常”；仅视觉，不声称额外试打／engine/host输入健康已验证。源一次性probe已进入出口，不允许同实例rearm，不以重启清零改写本轮。

本轮无源码／构建测试／安装部署／数据恢复或Git发布，历史备份不变。父子Active、Maps和根因未确认。下一建议先对提前出口触发做有界只读源码／控件绑定分析，核清后另准备新实例／新单轮；本停止交付不授权额外实例、进程信号、试打、重采或新独立审查。
