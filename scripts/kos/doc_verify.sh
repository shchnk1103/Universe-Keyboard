#!/usr/bin/env bash
# One-shot local verification after a commit: identity, diff hygiene,
# change classification and lightweight checks. Any failure is fatal.
set -euo pipefail

base_ref="${1:-main}"
expect_identity="${EXPECT_IDENTITY:-Cowork 3P <cowork-3p@localhost>}"

base_sha=$(git rev-parse "${base_ref}^{commit}")
head_sha=$(git rev-parse HEAD)

echo "HEAD $(git rev-parse HEAD)"
echo "branch $(git rev-parse --abbrev-ref HEAD)"
echo "== git status --short"
git status --short
if [ -n "$(git status --porcelain)" ]; then
  echo "DOC_VERIFY_FAIL: worktree is dirty" >&2
  exit 1
fi

echo "== files changed ${base_sha}..${head_sha}"
git diff --name-only "${base_sha}..${head_sha}"
git diff --check "${base_sha}..${head_sha}"

echo "== classify_changes"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "${script_dir}/../ci/classify_changes.py" --base "${base_sha}" --head "${head_sha}"

echo "== run_lightweight_checks"
bash "${script_dir}/../ci/run_lightweight_checks.sh" "${base_sha}" "${head_sha}"

echo "== check_identity"
python3 "${script_dir}/check_identity.py" --repo "$(pwd)" --expect "${expect_identity}" --rev "${head_sha}"

echo "DOC_VERIFY_PASS head=${head_sha}"
