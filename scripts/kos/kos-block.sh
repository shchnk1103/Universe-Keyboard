#!/bin/bash
# kos-block.sh —— 生成"参数文件 + 3 行派发块"，哈希一律由本脚本实测，不手抄。
# 用法：
#   kos-block.sh <名字（角色）> <步骤说明> <包路径> <参数文件路径> <块文件路径> [--next "<下一步首行>"] [键=值 ...]
# 键名以 _path 结尾的值按文件路径处理：参数文件里写成  键: 路径（SHA-256 实测）；其余键原样写成  键: 值。
# 例：kos-block.sh "Quinn（Quality·原独立质量会话）" "A3 质量复核 M2" /…/task-package-quality.md /…/params-q1.txt /…/next-block-q1.txt \
#       --next "下一步：贴给 Quinn（Quality·原独立质量会话）" executor_report_path=/…/executor-report-impl.md commit=3513… N=1 K=1
set -eu
who="$1"; step="$2"; pkg="$3"; params="$4"; block="$5"; shift 5
next=""; kv=()
while [ $# -gt 0 ]; do
  if [ "$1" = "--next" ]; then next="$2"; shift 2; else kv+=("$1"); shift; fi
done
if [ -z "${KOS_BLOCK_FORCE:-}" ]; then
  for f in "$params" "$block"; do [ ! -e "$f" ] || { echo "输出文件已存在，拒绝覆盖（冻结输入可能同名）：${f}；换名，或明知故犯时设 KOS_BLOCK_FORCE=1" >&2; exit 3; }; done
fi
h() { shasum -a 256 "$1" | cut -d' ' -f1; }
[ -f "$pkg" ] || { echo "包文件不存在：$pkg" >&2; exit 2; }
{
  echo "参数文件（由 kos-block.sh 生成；SHA-256 均为生成时对文件实测）"
  echo "- package_path: ${pkg}（SHA-256 $(h "$pkg")）"
  for p in "${kv[@]+"${kv[@]}"}"; do
    k="${p%%=*}"; v="${p#*=}"
    case "$k" in
      *_path) [ -f "$v" ] || { echo "文件不存在：$k=$v" >&2; exit 2; }; echo "- $k: ${v}（SHA-256 $(h "$v")）";;
      *) echo "- $k: $v";;
    esac
  done
} > "$params"
{
  if [ -n "$next" ]; then echo "${next} · ${step}"; else echo "派给：${who} · ${step}"; fi
  echo "参数文件：${params}（SHA-256 $(h "$params")）；内含任务包路径与 SHA-256 及全部参数"
  echo "授权，直接执行"
} > "$block"
echo "已写 $params 和 $block"
