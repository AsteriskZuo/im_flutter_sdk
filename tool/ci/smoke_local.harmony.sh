#!/usr/bin/env bash
# One-command local run of the HarmonyOS device smoke suite. Mirrors
# tool/ci/smoke_local.sh (android|ios) with the harmony platform added; the
# android/ios entry is intentionally left untouched.
#
# As with the android/ios smoke entry, callers do not pass credentials. The six
# E2E_* dart-defines are generated from the gitignored local data file
# im_flutter_sdk/example/config.local.json through example/tool/env_tool.dart
# (command `e2e-config`, which also refreshes user tokens), then the logged_out
# suite runs through tool/ci/ohos_local.sh on the HarmonyOS device/emulator.
#
# One-time local data preparation:
#   make config        # creates example/config.local.json from the template
#   $EDITOR im_flutter_sdk/example/config.local.json   # fill in your environment
#   make env-gettoken  # optional: tokens for the manual API pages (env.dart)
#
# Optional environment:
#   E2E_CONFIG_PATH      reuse an existing dart-defines JSON instead of
#                        generating one from config.local.json
#   FLUTTER_BIN          HarmonyOS flutter fork (default: the project .fvm SDK
#                        when present, otherwise flutter on PATH)
#   OHOS_DEVICE          hdc target (default 127.0.0.1:5555)
#   OHOS_SKIP_CODESIGN   default 1 (requires the fork OHOS_SKIP_CODESIGN patch)
#
# Usage:
#   bash tool/ci/smoke_local.harmony.sh
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

CLEANUP_CONFIG=0
if [ -z "${E2E_CONFIG_PATH:-}" ]; then
  CONFIG_LOCAL="$REPO_ROOT/im_flutter_sdk/example/config.local.json"
  if [ ! -f "$CONFIG_LOCAL" ]; then
    echo "error: $CONFIG_LOCAL not found" >&2
    echo "hint: run 'make config', fill in your environment, or export E2E_CONFIG_PATH." >&2
    exit 2
  fi
  command -v dart >/dev/null 2>&1 || {
    echo "error: dart not found in PATH" >&2
    exit 2
  }
  E2E_CONFIG_PATH="$(dart run "$REPO_ROOT/im_flutter_sdk/example/tool/env_tool.dart" e2e-config)"
  CLEANUP_CONFIG=1
fi
export E2E_CONFIG_PATH
if [ "$CLEANUP_CONFIG" = "1" ]; then
  trap 'rm -f "$E2E_CONFIG_PATH"' EXIT
fi

exec bash "$REPO_ROOT/tool/ci/ohos_local.sh" logged_out
