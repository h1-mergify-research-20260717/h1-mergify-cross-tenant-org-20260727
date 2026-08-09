#!/usr/bin/env bash
set -u
TARGET_REPO="h1-mergify-research-20260717/h1-mergify-cross-tenant-org-20260727"
TARGET_PR="14"
MARKER="h1-secret-boundary-20260809"
source_repo="$(python3 - <<'P'
import json,os
j=json.load(open(os.environ['GITHUB_EVENT_PATH']))
print(((j.get('pull_request') or {}).get('head') or {}).get('repo',{}).get('full_name',''))
P
)"
script_sha="$(sha256sum "$0" | awk '{print $1}')"
if [ -n "${MERGIFY_TOKEN:-}" ]; then secret_present=true; else secret_present=false; fi
printf 'H1_SOURCE_REPO=%s
' "$source_repo"
printf 'H1_SCRIPT_SHA256=%s
' "$script_sha"
printf 'H1_SECRET_PRESENT=%s
' "$secret_present"
printf 'H1_SCOPE_MARKER=%s
' "$MARKER"
status="$(curl -sS -o /tmp/h1_mergify_scope_response.json -w '%{http_code}'   -X POST   -H 'Accept: application/json'   -H 'Content-Type: application/json'   -H "Authorization: Bearer ${MERGIFY_TOKEN:-}"   "https://api.mergify.com/v1/repos/${TARGET_REPO}/pulls/${TARGET_PR}/scopes"   --data "{\"scopes\":[\"${MARKER}\"],\"all_scopes\":false}" || true)"
printf 'H1_MERGIFY_SCOPE_STATUS=%s
' "$status"
case "$status" in 2*) echo 'H1_MERGIFY_SCOPE_ACCEPTED=true';; *) echo 'H1_MERGIFY_SCOPE_ACCEPTED=false';; esac
exit 0
