#!/usr/bin/env bash
# HarmonyOS (ohos) local smoke entry.
#
# This is the harmony platform counterpart of tool/ci/smoke_local.sh
# (android|ios). The original script is intentionally left untouched; this
# wrapper supports the harmony platform only and runs the no-login equivalent
# suite (logged_out) on a HarmonyOS device/emulator through
# tool/ci/ohos_local.sh.
#
# Required (validated by ohos_local.sh):
#   E2E_CONFIG_PATH=/path/to/dart-defines.json  # JSON map of the six E2E_* fields
#   ... or export the six variables directly:
#   E2E_APP_KEY E2E_USER_ID E2E_USER_TOKEN E2E_PEER_ID E2E_REST_API E2E_APP_TOKEN
#
# Optional (forwarded to ohos_local.sh):
#   FLUTTER_BIN          fork flutter binary (default: flutter on PATH)
#   OHOS_DEVICE          hdc target (default: 127.0.0.1:5555)
#   OHOS_SKIP_CODESIGN   default 1 (requires the fork OHOS_SKIP_CODESIGN patch)
#
# Usage:
#   E2E_CONFIG_PATH=/tmp/ohos_e2e_zuoyu01.json \
#     bash tool/ci/smoke_local.harmony.sh
#
# Logs: artifacts/ohos-logged_out.log (written by ohos_local.sh).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

PLATFORM="${1:-harmony}"
case "$PLATFORM" in
  harmony) ;;
  *)
    echo "usage: bash tool/ci/smoke_local.harmony.sh [harmony]" >&2
    exit 2
    ;;
esac

exec bash "$REPO_ROOT/tool/ci/ohos_local.sh" logged_out
