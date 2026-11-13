#!/usr/bin/env bash
# HarmonyOS (ohos) local nightly entry.
#
# This is the harmony platform counterpart of tool/ci/nightly_local.sh
# (android|ios). The original script is intentionally left untouched; this
# wrapper supports the harmony platform only and runs all six integration
# suites on a HarmonyOS device/emulator through tool/ci/ohos_local.sh.
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
# Note: run `flutter pub get` with the fork after any official-Flutter
# run_quality/smoke run (the official pub get drops `plugins.ohos` from
# example/.flutter-plugins-dependencies, which breaks the ohos hvigor build).
#
# Usage:
#   E2E_CONFIG_PATH=/tmp/ohos_e2e_zuoyu01.json \
#     bash tool/ci/nightly_local.harmony.sh
#
# Pass suite names to run a subset (forwarded to ohos_local.sh), e.g.:
#   bash tool/ci/nightly_local.harmony.sh logged_in_base logged_in_group
#
# Logs: artifacts/ohos-<suite>.log (written by ohos_local.sh).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

PLATFORM="${1:-harmony}"
case "$PLATFORM" in
  harmony)
    shift || true
    ;;
  *)
    echo "usage: bash tool/ci/nightly_local.harmony.sh [harmony] [suite...]" >&2
    exit 2
    ;;
esac

exec bash "$REPO_ROOT/tool/ci/ohos_local.sh" "$@"
