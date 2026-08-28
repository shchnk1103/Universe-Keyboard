#!/usr/bin/env bash
# Always-run checks shared by documentation-only and full CI paths.
set -euo pipefail

base_sha=${1:-}
head_sha=${2:-}

if [[ -z "$base_sha" || -z "$head_sha" ]]; then
  echo "usage: bash scripts/ci/run_lightweight_checks.sh <base-sha> <head-sha>" >&2
  exit 2
fi

git cat-file -e "${base_sha}^{commit}"
git cat-file -e "${head_sha}^{commit}"
git diff --check "$base_sha" "$head_sha"
python3 scripts/ci/check_markdown_links.py --base "$base_sha" --head "$head_sha"
python3 -m json.tool .kos/project.json >/dev/null
python3 -m unittest discover -s scripts/ci/tests -p 'test_*.py'
bash scripts/ci/tests/test_verify_final_gate.sh

if git diff --quiet "$base_sha" "$head_sha" -- .kos docs/assignments docs/authorizations docs/evidence docs/gates docs/product-decisions; then
  echo "PASS no changed KOS governance records require the pinned local validator"
elif [[ -n "${KOS_AGENT_KIT_ROOT:-}" && -x "${KOS_AGENT_KIT_ROOT}/scripts/validate-kos.sh" ]]; then
  KOS_AS_OF=${KOS_AS_OF:-$(date -u +%Y-%m-%dT%H:%M:%SZ)} \
    bash "${KOS_AGENT_KIT_ROOT}/scripts/validate-kos.sh" "$(pwd)"
else
  echo "NOTE changed KOS governance records require the pinned local validator before merge; remote private-Kit distribution is not configured"
fi
