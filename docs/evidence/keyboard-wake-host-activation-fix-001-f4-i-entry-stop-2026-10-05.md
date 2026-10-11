# F4-I 现场Entry通过／备份工具首次失败停点 — 2026-10-05

Human同意F4-I新60calls/90分钟并确认原机独占，未打开/安装/部署。root核iPhone18Pro/iOS27.0原UDID405D994F-28CB-4F89-BB22-B64AD81C05A2 Booted、主App与Keyboard扩展进程为空；两诊断键及log_category_display不存在，rime_deployed=true、rime_needs_deploy=false、rime_deploying=false。无需终止进程。[实际Entry](keyboard-wake-host-activation-fix-001-f4-i-artifacts/entry.json)记录精确容器，未沿用旧PID。

备份清单脚本调用Python os.listxattr，但本机该接口不存在，首次失败停下。失败在完整before清单完成及创建新备份根之前，**未复制原容器、未安装、未修改源容器**。旧保护副本保持。调用11处失败；随后只修主机辅助脚本，改为已经证明可用的/usr/bin/xattr读取；旧脚本保全，修正SHA790e0999…；临时文件/目录/内部symlink/合成xattr的host-only ditto及完整inventory比对通过，非provenance差异0、provenance差异0，没有再读/复制模拟器容器。

[故障与主机预检回执](keyboard-wake-host-activation-fix-001-f4-i-artifacts/first-failure-and-host-preflight.json)保留失败和修正。仅清单工具故障，不是已证明的候选/环境内容故障。[root账本](keyboard-wake-host-activation-fix-001-f4-i-artifacts/root-usage.json)15/60actualcalls，保守墙钟锚点早于本轮首调用，不补造实际首调用时间；预算尚未耗尽，但遵守已授权Entry首失败停止，未自动重试备份。

建议Human只批准用已通过主机样本预检的清单工具恢复执行同一F4-I：重新核device/容器/进程，完整新before两次读回，保护合格后才精确pair安装/正常健康。累计calls/原90分钟锚点继续计账，不自动重置；若窗口届满或实测metadata差异，按实际证据停下。静态晋级核验已闭合，不再重审四条；本轮不Maps/LLDB/部署/恢复/Git/Release，技能不会扩展范围。
