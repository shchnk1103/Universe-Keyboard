#!/bin/bash
# kos-run.sh —— 执行命令并把完整命令行、HEAD、状态与退出码写入新日志。
# 用法：bash scripts/kos/kos-run.sh --log <日志> [--cwd <目录>] [--env KEY=VALUE]... -- <命令> [参数...]
who=""
log=""
cwd="$PWD"
envs=()
while [ $# -gt 0 ]; do
  case "$1" in
    --log) log="$2"; shift 2;;
    --cwd) cwd="$2"; shift 2;;
    --env) envs+=("$2"); shift 2;;
    --) shift; break;;
    *) echo "未知参数：$1" >&2; exit 2;;
  esac
done
if [ -z "${log}" ] || [ $# -eq 0 ]; then
  echo "用法：bash scripts/kos/kos-run.sh --log <日志> [--cwd <目录>] [--env KEY=VALUE]... -- <命令>" >&2
  exit 2
fi
if [ -e "${log}" ]; then
  echo "日志已存在，拒绝覆盖：${log}" >&2
  exit 3
fi
mkdir -p "$(dirname "${log}")"
line=""
for item in "${envs[@]+"${envs[@]}"}"; do
  line+="$(printf '%q' "${item}") "
done
for item in "$@"; do
  line+="$(printf '%q' "${item}") "
done
line="${line% }"
head_now="$(git -C "${cwd}" rev-parse HEAD 2>/dev/null || true)"
if [ -z "${head_now}" ]; then head_now="NONE"; fi
{
  printf '%s\n' "${line}"
  printf 'HEAD=%s\n' "${head_now}"
  git -C "${cwd}" status --porcelain
} > "${log}"
(
  cd "${cwd}" || exit 2
  for item in "${envs[@]+"${envs[@]}"}"; do
    export "${item?}"
  done
  "$@"
) 2>&1 | tee -a "${log}"
code="${PIPESTATUS[0]}"
head_after="$(git -C "${cwd}" rev-parse HEAD 2>/dev/null || true)"
if [ -z "${head_after}" ]; then head_after="NONE"; fi
{
  printf 'EXIT:%s\n' "${code}"
  printf 'HEAD=%s\n' "${head_after}"
} >> "${log}"
exit "${code}"
