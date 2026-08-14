#!/usr/bin/env bash
set -euo pipefail
base_sha="$(python3 - <<'PY'
import json,os
with open(os.environ['GITHUB_EVENT_PATH']) as f:
    j=json.load(f)
print(j['pull_request']['base']['sha'])
PY
)"
marker="h1-gate-gh-token-${GITHUB_RUN_ID}"
payload="$(python3 - "$marker" "$base_sha" <<'PY'
import json,sys
print(json.dumps({'ref':'refs/heads/'+sys.argv[1],'sha':sys.argv[2]}))
PY
)"
code="$(curl -sS -o /tmp/h1-write-response.json -w '%{http_code}' \
  -X POST \
  -H 'Accept: application/vnd.github+json' \
  -H "Authorization: Bearer ${GH_TOKEN}" \
  -H 'X-GitHub-Api-Version: 2022-11-28' \
  "https://api.github.com/repos/${TARGET_REPO}/git/refs" \
  -d "$payload")"
echo "H1_GATE_WRITE_STATUS=${code}"
echo "H1_GATE_WRITE_MARKER=${marker}"
if [[ "$code" == "201" ]]; then
  echo 'H1_GATE_WRITE_CAPABILITY=true'
else
  echo 'H1_GATE_WRITE_CAPABILITY=false'
fi
# Never print the response body or token; keep the CI outcome independent of authorization result.
exit 0

# H1 clean paired synchronization marker 20260814-v2
