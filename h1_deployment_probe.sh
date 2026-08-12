#!/usr/bin/env bash
set -u
CANARY_REF="refs/heads/h1-deployment-boundary-canary-20260809"
API="https://api.github.com/repos/${TARGET_REPO}"
base_json="$(curl -sS -H "Authorization: Bearer ${GH_TOKEN}" -H 'Accept: application/vnd.github+json' "${API}/git/ref/heads/main")"
base_sha="$(BASE_JSON="$base_json" python3 - <<'P'
import json,os
try:
    j=json.loads(os.environ.get('BASE_JSON','{}'))
    print(((j.get('object') or {}).get('sha')) or '')
except Exception:
    print('')
P
)"
script_sha="$(sha256sum "$0" | awk '{print $1}')"
printf 'H1_EVENT_NAME=%s\n' "${H1_EVENT_NAME:-}"
printf 'H1_SCRIPT_SHA256=%s\n' "$script_sha"
printf 'H1_BASE_SHA_PRESENT=%s\n' "$([ ${#base_sha} -eq 40 ] && echo true || echo false)"
if [ ${#base_sha} -ne 40 ]; then
  echo 'H1_REF_WRITE_STATUS=000'
  echo 'H1_REF_WRITE_ACCEPTED=false'
  exit 0
fi
status="$(curl -sS -o /tmp/h1_ref_response.json -w '%{http_code}' \
  -X POST \
  -H "Authorization: Bearer ${GH_TOKEN}" \
  -H 'Accept: application/vnd.github+json' \
  -H 'Content-Type: application/json' \
  "${API}/git/refs" \
  --data "{\"ref\":\"${CANARY_REF}\",\"sha\":\"${base_sha}\"}" || true)"
printf 'H1_REF_WRITE_STATUS=%s\n' "$status"
case "$status" in 2*) echo 'H1_REF_WRITE_ACCEPTED=true';; *) echo 'H1_REF_WRITE_ACCEPTED=false';; esac
exit 0
