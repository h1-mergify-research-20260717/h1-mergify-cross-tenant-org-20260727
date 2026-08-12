#!/usr/bin/env bash
set -u
ref="refs/heads/h1-fork-prov-ref-canary-20260812"
payload="$(printf '{"ref":"%s","sha":"%s"}' "$ref" "$H1_REF_SHA")"
status="$(
  curl --silent --show-error     --output /tmp/h1-fork-prov-ref-response.json     --write-out '%{http_code}'     --request POST     --header "Accept: application/vnd.github+json"     --header "Authorization: Bearer ${H1_GITHUB_TOKEN}"     --header "X-GitHub-Api-Version: 2022-11-28"     "https://api.github.com/repos/${H1_REPOSITORY}/git/refs"     --data "${payload}"
)"
rm -f /tmp/h1-fork-prov-ref-response.json
echo "H1_FORK_PROV_REF_CREATE_STATUS=${status}"
if [[ "${status}" == "201" ]]; then
  echo "H1_FORK_PROV_REF_CREATE_SUCCEEDED=true"
else
  echo "H1_FORK_PROV_REF_CREATE_SUCCEEDED=false"
fi
exit 0
