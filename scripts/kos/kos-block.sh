#!/bin/bash
# kos-block.sh —— 生成"参数文件 + 3 行派发块"，哈希一律由本脚本实测，不手抄。
# 用法：
#   kos-block.sh <名字（角色）> <步骤说明> <包路径> <参数文件路径> <块文件路径> [--next "<下一步首行>"] [键=值 ...]
# 键名以 _path 结尾的值按文件路径处理：参数文件里写成  键: 路径（SHA-256 实测）；其余键原样写成  键: 值。
# 例：kos-block.sh "Quinn（Quality·原独立质量会话）" "A3 质量复核 M2" /…/task-package-quality.md /…/params-q1.txt /…/next-block-q1.txt \
#       --next "下一步：贴给 Quinn（Quality·原独立质量会话）" executor_report_path=/…/executor-report-impl.md commit=3513… N=1 K=1
set -eu
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
who="$1"; step="$2"; pkg="$3"; params="$4"; block="$5"; shift 5
next=""; kv=()
task_dir=""; task_id=""; active_step=""; role=""; auth_path=""; expect_rev="0"; claim_id=""; updated_by=""
queue_id=""; queue_why=""; session=""
resources=()
while [ $# -gt 0 ]; do
  case "$1" in
    --next) next="$2"; shift 2;;
    --queue-id) queue_id="$2"; shift 2;;
    --queue-why) queue_why="$2"; shift 2;;
    --resource) resources+=("$2"); shift 2;;
    --session) session="$2"; shift 2;;
    --task-dir) task_dir="$2"; shift 2;;
    --task-id) task_id="$2"; shift 2;;
    --active-step) active_step="$2"; shift 2;;
    --role) role="$2"; shift 2;;
    --auth-path) auth_path="$2"; shift 2;;
    --expect-rev) expect_rev="$2"; shift 2;;
    --claim-id) claim_id="$2"; shift 2;;
    --updated-by) updated_by="$2"; shift 2;;
    *) kv+=("$1"); shift;;
  esac
done
if [ -z "${KOS_BLOCK_FORCE:-}" ]; then
  for f in "$params" "$block"; do [ ! -e "$f" ] || { echo "输出文件已存在，拒绝覆盖（冻结输入可能同名）：${f}；换名，或明知故犯时设 KOS_BLOCK_FORCE=1" >&2; exit 3; }; done
fi
if [ -n "$task_dir" ] && [ -n "$auth_path" ] && [ ! -f "$auth_path" ]; then
  echo "授权文件不存在，禁止越权生成下一站入口：$auth_path" >&2
  exit 2
fi
if [ -z "$queue_id" ] && [ "${KOS_Q_GATE:-}" = "1" ] && [ -n "$task_id" ]; then
  queue_id="$task_id"
fi
if [ -n "$queue_id" ]; then
  gate_args=(gate "$queue_id")
  [ -n "$queue_why" ] && gate_args+=(--why "$queue_why")
  python3 -I -B "${SCRIPT_DIR}/kos-q.py" "${gate_args[@]}"
fi
if [ "${#resources[@]}" -gt 0 ]; then
  [ -f "$pkg" ] || { echo "包文件不存在：$pkg" >&2; exit 2; }
  for p in "${kv[@]+"${kv[@]}"}"; do
    k="${p%%=*}"; v="${p#*=}"
    case "$k" in
      *_path) [ -z "$v" ] || [ -f "$v" ] || { echo "文件不存在：$k=$v" >&2; exit 2; };;
    esac
  done
  if [ -z "$task_id" ]; then
    echo "传入 --resource 时必须提供 --task-id" >&2
    exit 2
  fi
  if [ -n "$session" ]; then
    session_val="$session"
  elif [ -n "$role" ]; then
    session_val="$role"
  else
    session_val="block"
  fi
  python3 -I -B "${SCRIPT_DIR}/kos-lock.py" acquire --task "$task_id" --session "$session_val" "${resources[@]+"${resources[@]}"}"
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
if [ -n "$task_dir" ]; then
  [ -n "$task_id" ] && [ -n "$active_step" ] && [ -n "$role" ] && [ -n "$auth_path" ] && [ -n "$updated_by" ] || {
    echo "O41 CURRENT.json 更新缺少必要参数（--task-id/--active-step/--role/--auth-path/--updated-by）" >&2
    exit 2
  }
  claim_args=()
  [ -n "$claim_id" ] && claim_args+=(--claim-id "$claim_id")
  python3 -I -B "${SCRIPT_DIR}/kos_current.py" dispatch \
    --task-dir "$task_dir" \
    --task-id "$task_id" \
    --active-step "$active_step" \
    --role "$role" \
    --package-path "$pkg" \
    --params-path "$params" \
    --authorization-path "$auth_path" \
    --updated-by "$updated_by" \
    --expect-rev "$expect_rev" \
    "${claim_args[@]+"${claim_args[@]}"}" >/dev/null
fi
echo "已写 $params 和 $block"
