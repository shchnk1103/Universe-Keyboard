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
keychain_result=${8:-}
release_result=${9:-}

heavy_names=(
  format-swift
  test-keyboardcore
  test-rimebridge
  test-app-keyboard
  test-rime-sync-keychain
  build-release
)
heavy_results=(
  "$format_result"
  "$keyboardcore_result"
  "$rimebridge_result"
  "$app_keyboard_result"
  "$keychain_result"
  "$release_result"
)

if [[ "$classify_result" != "success" || "$lightweight_result" != "success" ]]; then
  echo "Classification and lightweight checks must both succeed." >&2
  exit 1
fi

case "$requires_full" in
  full|true) expected=(success success success success success success) ;;
  docs_only|kos_tools_only|false) expected=(skipped skipped skipped skipped skipped skipped) ;;
  keyboard_ui_only|app_only) expected=(success skipped skipped success skipped success) ;;
  app_sync_only) expected=(success skipped skipped success success success) ;;
  rimebridge_only) expected=(success skipped success success skipped success) ;;
  rimebridge_sync_only) expected=(success skipped success success success success) ;;
  *) echo "Missing or unknown classification." >&2; exit 1 ;;
esac

for index in "${!heavy_names[@]}"; do
  result="${heavy_results[$index]}"
  if [[ "$result" != "${expected[$index]}" ]]; then
    echo "${heavy_names[$index]} expected ${expected[$index]}; got: $result" >&2
    exit 1
  fi
done

echo "Final quality gate passed for requires_full=$requires_full."
