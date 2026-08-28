#!/usr/bin/env bash
# Verify that job results agree with the fail-closed classification decision.
set -euo pipefail

classify_result=${1:-}
lightweight_result=${2:-}
heavy_result=${3:-}
requires_full=${4:-}

if [[ "$classify_result" != "success" || "$lightweight_result" != "success" ]]; then
  echo "Classification and lightweight checks must both succeed." >&2
  exit 1
fi

if [[ "$requires_full" == "true" ]]; then
  if [[ "$heavy_result" != "success" ]]; then
    echo "Full changes require a successful build-and-test job; got: $heavy_result" >&2
    exit 1
  fi
elif [[ "$requires_full" == "false" ]]; then
  if [[ "$heavy_result" != "skipped" ]]; then
    echo "Documentation-only changes require build-and-test to be skipped; got: $heavy_result" >&2
    exit 1
  fi
else
  echo "Missing fail-closed classification output." >&2
  exit 1
fi

echo "Final quality gate passed for requires_full=$requires_full."
