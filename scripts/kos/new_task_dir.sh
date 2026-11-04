#!/usr/bin/env bash
set -euo pipefail
id="${1:?usage: new_task_dir.sh TASK-ID}"
[[ "$id" =~ ^[A-Z0-9][A-Z0-9-]*$ ]] || { echo "invalid task id: $id" >&2; exit 2; }
d="${KOS_HOME:-$HOME/.kos-work}/${KOS_PROJECT:-Universe-Keyboard}/$id"
if [ -e "$d" ]; then echo "EXISTS: $d — use a new id or a revision package; never overwrite" >&2; exit 1; fi
mkdir -p "$d/instructions" "$d/reports" "$d/scratch" "$d/packets"
echo "$d"
