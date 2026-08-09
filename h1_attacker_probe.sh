#!/usr/bin/env bash
set -u
marker="h1-mergify-trust-marker-${GITHUB_RUN_ID}"
sha="${GITHUB_SHA}"
repo="${GITHUB_REPOSITORY}"
source_repo="$(python3 - <<'P'
import json,os
j=json.load(open(os.environ['GITHUB_EVENT_PATH']))
print(((j.get('pull_request') or {}).get('head') or {}).get('repo',{}).get('full_name',''))
P
)"
script_sha="$(sha256sum "$0" | awk '{print $1}')"
printf 'H1_SOURCE_REPO=%s
' "$source_repo"
printf 'H1_SCRIPT_SHA256=%s
' "$script_sha"
printf 'H1_MARKER_REF=%s
' "$marker"
body="$(python3 - <<P
import json
print(json.dumps({'ref':'refs/heads/${marker}','sha':'${sha}'}))
P
)"
status="$(curl -sS -o /tmp/h1_ref_response.json -w '%{http_code}'   -X POST   -H 'Accept: application/vnd.github+json'   -H "Authorization: Bearer ${GH_TOKEN}"   -H 'X-GitHub-Api-Version: 2022-11-28'   "https://api.github.com/repos/${repo}/git/refs"   -d "$body" || true)"
printf 'H1_WRITE_PROBE_STATUS=%s
' "$status"
if [ "$status" = "201" ]; then
  echo 'H1_WRITE_PROBE_CREATED=true'
else
  echo 'H1_WRITE_PROBE_CREATED=false'
fi
exit 0
