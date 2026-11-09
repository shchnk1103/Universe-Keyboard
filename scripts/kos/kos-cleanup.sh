#!/bin/bash
# kos-cleanup.sh —— KOS 任务收尾释放存储空间（默认只演示，--apply 才执行）
# 用法：
#   kos-cleanup.sh report                     # 各任务占用概览（只读）
#   kos-cleanup.sh r   TASK-ID [TASK-ID...]   # 甲类：可再生构建产物（保留 Logs/，不碰 reports/、worktree）
#   kos-cleanup.sh e   TASK-ID [TASK-ID...]   # 乙类：证据运行目录与 xcresult → 压缩进 archive/<TASK>/，校验后删原件
#   加 --apply 才真的执行；执行前后各写一行到 manifests/。
# 受保护的任务（活跃任务）写在 protected.txt，每行一个任务号，脚本拒绝处理。
set -u
ROOT="${KOS_HOME:-$HOME/.kos-work}/${KOS_PROJECT:-Universe-Keyboard}"
HOME_DIR="$ROOT/KOS-CLEANUP-001"; mkdir -p "$HOME_DIR/manifests"
PROT="$HOME_DIR/protected.txt"; touch "$PROT"
APPLY=0; ARGS=()
for a in "$@"; do [ "$a" = "--apply" ] && APPLY=1 || ARGS+=("$a"); done
MODE="${ARGS[0]:-}"; TASKS=("${ARGS[@]:1}")
free() { df -g /System/Volumes/Data | awk 'NR==2{print $4}'; }
mb() { du -sk "$1" 2>/dev/null | awk '{printf "%d", $1/1024}'; }
log() { echo "$(date +%Y-%m-%dT%H:%M:%S%z) $*" >> "$HOME_DIR/manifests/cleanup-$(date +%Y%m%d).log"; }
case "$MODE" in
report)
  du -sk "$ROOT"/*/ 2>/dev/null | sort -rn | head -30 | awk '{printf "%8.1f GB  %s\n",$1/1048576,$2}'
  echo "可用空间：$(free) GiB";;
r|e)
  [ ${#TASKS[@]} -eq 0 ] && { echo "需要至少一个任务号"; exit 2; }
  before=$(free); total=0
  for t in "${TASKS[@]}"; do
    d="$ROOT/$t"; [ -d "$d" ] || { echo "SKIP 无此任务：$t"; continue; }
    grep -qx "$t" "$PROT" && { echo "SKIP 受保护（活跃）：$t"; continue; }
    if [ "$MODE" = "r" ]; then
      while IFS= read -r p; do
        case "$p" in */reports/*|*/worktree*|*/.git/*) continue;; esac
        for c in "$p"/* "$p"/.[!.]*; do
          [ -e "$c" ] || continue; [ "$(basename "$c")" = "Logs" ] && continue
          kb=$(du -sk "$c" 2>/dev/null | cut -f1); total=$((total+kb))
          [ $APPLY -eq 1 ] && { rm -rf -- "$c"; log "R $t delete $c ${kb}KB"; }
        done
      done < <(find "$d" -maxdepth 4 -type d \( -name DerivedData -o -name 'derived*' -o -name dd -o -name 'dd-*' -o -name modules -o -name modulecache -o -name clang-module-cache -o -name .build -o -name tmp -o -name keyboardcore -o -name swift \) -not -path '*/worktree*' -not -path '*/.git/*' -prune -print)
    else
      mkdir -p "$ROOT/archive/$t"
      while IFS= read -r p; do
        case "$p" in */reports/*|*/worktree*|*/.git/*) continue;; esac
        kb=$(du -sk "$p" 2>/dev/null | cut -f1); total=$((total+kb))
        if [ $APPLY -eq 1 ]; then
          out="$ROOT/archive/$t/$(echo "${p#$d/}" | tr '/' '_').tgz"
          if tar -czf "$out" -C "$(dirname "$p")" "$(basename "$p")" && tar -tzf "$out" >/dev/null 2>&1; then
            sha=$(shasum -a 256 "$out" | cut -d' ' -f1); echo "$sha  $out" >> "$ROOT/archive/$t/SHA256SUMS.txt"
            rm -rf -- "$p"; log "E $t archived+deleted $p -> $out sha=$sha ${kb}KB"
          else echo "FAIL 压缩失败，保留原件：$p"; rm -f "$out"; fi
        fi
      done < <(find "$d" -maxdepth 4 -type d \( -name '*.xcresult' -o -name 'evidence*' -o -name 'runtime*' -o -name 'engine-exp*' -o -name 'negative-*' -o -name 'matrix-*' \) -not -path '*/worktree*' -not -path '*/.git/*' -prune -print)
    fi
  done
  printf '%s：约 %.1f GB（%s模式 %s）\n' "$([ $APPLY -eq 1 ] && echo 已处理 || echo 将处理)" "$(echo "$total/1048576" | bc -l)" "$MODE" "${TASKS[*]}"
  [ $APPLY -eq 1 ] && echo "可用空间：$before → $(free) GiB";;
*) sed -n 2,9p "$0"; exit 2;;
esac
exit 0
