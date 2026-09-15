#!/usr/bin/env bash
# Verify that job results agree with the fail-closed classification decision.
set -euo pipefail

classify_result=${1:-}
lightweight_result=${2:-}
requires_full=${3:-}
format_result=${4:-}
keyboardcore_result=${5:-}
rimebridge_result=${6:-}
app_keyboard_result=${7:-}
release_result=${8:-}

heavy_names=(
  format-swift
  test-keyboardcore
  test-rimebridge
  test-app-keyboard
  build-release
)
heavy_results=(
  "$format_result"
  "$keyboardcore_result"
  "$rimebridge_result"
  "$app_keyboard_result"
  "$release_result"
)

if [[ "$classify_result" != "success" || "$lightweight_result" != "success" ]]; then
  echo "Classification and lightweight checks must both succeed." >&2
  exit 1
fi

expected=""
case "$requires_full" in
  true)
    expected=success
    ;;
  false)
    expected=skipped
    ;;
  *)
    echo "Missing fail-closed classification output." >&2
    exit 1
    ;;
esac

for index in "${!heavy_names[@]}"; do
  result="${heavy_results[$index]}"
  if [[ "$result" != "$expected" ]]; then
    if [[ "$expected" == "success" ]]; then
      echo "Full changes require ${heavy_names[$index]} to succeed; got: $result" >&2
    else
      echo "Documentation-only changes require ${heavy_names[$index]} to be skipped; got: $result" >&2
    fi
    exit 1
  fi
done

echo "Final quality gate passed for requires_full=$requires_full."
