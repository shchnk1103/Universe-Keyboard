#!/bin/bash
# ci_watch.sh — 参数化 CI run 监督脚本（O129-KOS-RELAY-DEPT-AND-CIWATCH-001）。
# 通用工具：不写死任何仓库名、PR 号或 run ID；所有目标经 CLI 传入。
# 仅依赖 gh + bash；全部查询走 gh，不触网以外的副作用。
set -u

usage() {
  cat <<'USAGE'
用法: ci_watch.sh --repo <owner/name> --run <run_id> [--pr <pr_number>]
                 [--interval <sec>] [--timeout <sec>] [--queued-limit-min <min>]

轮询 `gh run view` 直到终态；给定 --pr 时一并轮询 `gh pr view`。
  --repo              GitHub 仓库（owner/name），必填
  --run               CI run ID，必填
  --pr                可选 PR 号，同时观察其状态
  --interval          轮询间隔秒数（默认 30）
  --timeout           总超时秒数（默认 1200）
  --queued-limit-min  连续 queued 报警阈值分钟数（默认 10）

退出码: 0 run/PR 到终态（RUN_TERMINAL / PR_TERMINAL）；
        2 总超时（BUDGET_EXHAUSTED）；
        3 连续 queued 超过阈值（WAITING_CI）；
        4 参数或环境错误。
USAGE
}

REPO=""
RUN=""
PR=""
INTERVAL=30
TIMEOUT=1200
QUEUED_LIMIT_MIN=10

while [ $# -gt 0 ]; do
  case "$1" in
    --repo) REPO="${2-}"; shift 2 ;;
    --run) RUN="${2-}"; shift 2 ;;
    --pr) PR="${2-}"; shift 2 ;;
    --interval) INTERVAL="${2-}"; shift 2 ;;
    --timeout) TIMEOUT="${2-}"; shift 2 ;;
    --queued-limit-min) QUEUED_LIMIT_MIN="${2-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "ci_watch: 未知参数: $1" >&2; usage >&2; exit 4 ;;
  esac
done

_require_nonempty() {
  if [ -z "$2" ]; then
    echo "ci_watch: 缺少必填参数 --$1" >&2
    usage >&2
    exit 4
  fi
}

_require_int() {
  case "${2-}" in
    ''|*[!0-9]*)
      echo "ci_watch: --$1 需为非负整数，得到: ${2-}" >&2
      exit 4
      ;;
  esac
}

_require_nonempty repo "$REPO"
_require_nonempty run "$RUN"
_require_int interval "$INTERVAL"
_require_int timeout "$TIMEOUT"
_require_int queued-limit-min "$QUEUED_LIMIT_MIN"
[ "$INTERVAL" -ge 1 ] || { echo "ci_watch: --interval 至少为 1 秒" >&2; exit 4; }
[ "$TIMEOUT" -ge 1 ] || { echo "ci_watch: --timeout 至少为 1 秒" >&2; exit 4; }
command -v gh >/dev/null 2>&1 || { echo "ci_watch: 未找到 gh 命令" >&2; exit 4; }

DEADLINE=$(( $(date +%s) + TIMEOUT ))
QUEUED_START=""
ST=""

run_jobs() {
  gh run view "$RUN" --repo "$REPO" --json jobs -q '.jobs[] | .name+" => "+.status+" "+(.conclusion//"-")' 2>/dev/null
}

while :; do
  NOW=$(date +%s)
  if [ "$NOW" -ge "$DEADLINE" ]; then
    echo "BUDGET_EXHAUSTED: run $RUN status=${ST:-unknown}（超过 ${TIMEOUT}s 预算）"
    run_jobs | head -20
    exit 2
  fi

  S=$(gh run view "$RUN" --repo "$REPO" --json status,conclusion -q '.status+" "+(.conclusion//"-")' 2>/dev/null)
  ST=${S%% *}
  CON=${S#* }

  if [ -z "$ST" ] || [ "$ST" = "$S" ]; then
    echo "ci_watch: gh run view 查询失败（run $RUN），将继续重试" >&2
    ST=""
    QUEUED_START=""
  elif [ "$ST" = "queued" ]; then
    [ -z "$QUEUED_START" ] && QUEUED_START=$NOW
    if [ $(( NOW - QUEUED_START )) -ge $(( QUEUED_LIMIT_MIN * 60 )) ]; then
      echo "WAITING_CI: run $RUN 连续 queued $(( (NOW - QUEUED_START) / 60 )) 分钟，超过阈值 ${QUEUED_LIMIT_MIN} 分钟"
      exit 3
    fi
  else
    QUEUED_START=""
  fi

  if [ "$ST" = "completed" ]; then
    echo "RUN_TERMINAL: run $RUN status=completed conclusion=$CON"
    run_jobs
    exit 0
  fi

  if [ -n "$PR" ]; then
    PRSTATE=$(gh pr view "$PR" --repo "$REPO" --json state -q '.state' 2>/dev/null)
    case "$PRSTATE" in
      OPEN|"") : ;;
      *) echo "PR_TERMINAL: pr $PR state=$PRSTATE"; exit 0 ;;
    esac
  fi

  sleep "$INTERVAL"
done
