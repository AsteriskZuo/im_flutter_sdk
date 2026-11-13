#!/usr/bin/env bash
# Cleans the data the ohos integration suites leave on the CI app.
#
# The suites create groups (SDK createGroup) and chat rooms (REST) and delete
# them in tear-down; a group whose ownership was transferred to the peer in
# FL-GROUP-027/041 can only be deleted by its new owner, so those groups stay in
# the app as `flutter_ci_group_*` orphans. They are invisible to the
# single-device CI run but accumulate between runs, so this script removes them
# through the REST API (app token, /chatgroups - NOT /groups, which is invalid).
#
# It is local maintenance only: no CI entry, no device needed.
#
# Usage:
#   E2E_APP_TOKEN=<app token> bash tool/ci/ohos_cleanup.sh
#
# Environment:
#   E2E_APP_TOKEN  app token (required; the same one the suites use)
#   E2E_REST_API   REST base (default: http://ngi-a1.easemob.com)
#   E2E_APP_KEY    app key (default: easemob-demo#zuoyu)
#   OHOS_CI_PREFIXES  comma separated group-name prefixes to delete
#                     (default: flutter_ci_group_,ci_)
#   OHOS_CI_PEER_IDS  comma separated accounts whose joined groups are scanned
#                     (default: the current E2E account is not known here, so
#                     pass it explicitly, e.g. zuoyu01_ci_peer)
#
# Notes:
# - Only groups whose name starts with one of OHOS_CI_PREFIXES are deleted.
# - The script never deletes accounts.
set -euo pipefail

APP_TOKEN="${E2E_APP_TOKEN:-}"
if [ -z "$APP_TOKEN" ]; then
  echo "error: E2E_APP_TOKEN is required" >&2
  exit 2
fi

REST_API="${E2E_REST_API:-http://ngi-a1.easemob.com}"
APP_KEY="${E2E_APP_KEY:-easemob-demo#zuoyu}"
ORG_APP="${APP_KEY//#//}"
BASE="$REST_API/$ORG_APP"
PREFIXES="${OHOS_CI_PREFIXES:-flutter_ci_group_,ci_}"
PEER_IDS="${OHOS_CI_PEER_IDS:-}"

if [ -z "$PEER_IDS" ]; then
  echo "error: OHOS_CI_PEER_IDS is required, e.g. zuoyu01_ci_peer" >&2
  exit 2
fi

command -v curl >/dev/null 2>&1 || {
  echo "error: curl is required" >&2
  exit 2
}
command -v python3 >/dev/null 2>&1 || {
  echo "error: python3 is required" >&2
  exit 2
}

IFS=',' read -r -a PREFIX_LIST <<<"$PREFIXES"
IFS=',' read -r -a PEER_LIST <<<"$PEER_IDS"

python3 - "$BASE" "$APP_TOKEN" "$PEER_IDS" "$PREFIXES" <<'PY'
import json
import sys
import urllib.error
import urllib.request

base, token, peer_ids, prefixes = sys.argv[1:5]
user_ids = [item for item in peer_ids.split(',') if item]
prefix_list = tuple(item for item in prefixes.split(',') if item)


def request(method, path):
    url = base + path
    req = urllib.request.Request(url, method=method,
                                 headers={'Authorization': 'Bearer ' + token})
    try:
        with urllib.request.urlopen(req, timeout=20) as response:
            return response.status, json.loads(response.read().decode() or '{}')
    except urllib.error.HTTPError as error:
        return error.code, {}


leftovers = []
for user in user_ids:
    status, body = request('GET', '/users/%s/joined_chatgroups?limit=100' % user)
    if status != 200:
        print('warning: %s: cannot list joined groups (HTTP %s)' % (user, status))
        continue
    for item in body.get('data', []):
        group_id = item.get('groupid', '')
        name = item.get('groupname', '')
        if name.startswith(prefix_list):
            leftovers.append((user, group_id, name))

if not leftovers:
    print('no leftover test groups for: %s' % ', '.join(user_ids))
    sys.exit(0)

print('found %d leftover test group(s):' % len(leftovers))
for user, group_id, name in leftovers:
    print('  %s  %s  %s' % (group_id, name, user))

failed = 0
for _, group_id, name in leftovers:
    status, _ = request('DELETE', '/chatgroups/%s' % group_id)
    if status in (200, 204, 404):
        print('deleted %s (%s)' % (group_id, name))
    else:
        failed += 1
        print('error: %s (%s) HTTP %s' % (group_id, name, status))

sys.exit(1 if failed else 0)
PY
