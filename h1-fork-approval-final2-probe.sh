#!/usr/bin/env bash
set -euo pipefail
: "${H1_GITHUB_TOKEN:?}"
: "${H1_REPOSITORY:?}"
: "${H1_REF_SHA:?}"
CANARY_REF='refs/heads/h1-fork-approval-final2-canary-20260813'
payload=$(jq -cn --arg ref "$CANARY_REF" --arg sha "$H1_REF_SHA" '{ref:$ref,sha:$sha}')
status=$(curl -sS -o /tmp/h1-final2-response.json -w '%{http_code}' \
  -X POST \
  -H 'Accept: application/vnd.github+json' \
  -H 'X-GitHub-Api-Version: 2026-03-10' \
  -H "Authorization: Bearer $H1_GITHUB_TOKEN" \
  "https://api.github.com/repos/$H1_REPOSITORY/git/refs" \
  -d "$payload")
echo "H1_FINAL2_REF_CREATE_STATUS=$status"
if [ "$status" = '201' ]; then echo 'H1_FINAL2_REF_CREATE_SUCCEEDED=true'; else echo 'H1_FINAL2_REF_CREATE_SUCCEEDED=false'; fi
