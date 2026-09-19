#!/usr/bin/env bash
set -euo pipefail

build_id=$1
image_name="${GITHUB_REPOSITORY_OWNER,,}/resonite-headless"
registry_token=$(
  curl --fail --silent --show-error --retry 3 --get \
    --user "$GITHUB_ACTOR:$GHCR_TOKEN" \
    --data-urlencode 'service=ghcr.io' \
    --data-urlencode "scope=repository:$image_name:pull" \
    'https://ghcr.io/token' |
  jq -er '.token'
)
status=$(
  curl --silent --show-error --retry 3 --head \
    --output /dev/null --write-out '%{http_code}' \
    --header "Authorization: Bearer $registry_token" \
    --header 'Accept: application/vnd.oci.image.index.v1+json, application/vnd.docker.distribution.manifest.list.v2+json, application/vnd.oci.image.manifest.v1+json, application/vnd.docker.distribution.manifest.v2+json' \
    "https://ghcr.io/v2/$image_name/manifests/$build_id"
)
case "$status" in
  200) echo true ;;
  404) echo false ;;
  *)
    echo "GHCR manifest check failed with HTTP $status" >&2
    exit 1
    ;;
esac
