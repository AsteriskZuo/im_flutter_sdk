#!/usr/bin/env bash
# Generate gitignored overrides for local development without changing pubspecs.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ensure_overrides() {
  local package="$1"
  local relative_root="$2"
  shift 2
  local target="$repo_root/$package/pubspec_overrides.yaml"
  local dependency

  if [[ -e "$target" || -L "$target" ]]; then
    echo "Keep: $package/pubspec_overrides.yaml"
    return
  fi

  {
    echo 'dependency_overrides:'
    for dependency in "$@"; do
      printf '  %s:\n    path: %s%s\n' "$dependency" "$relative_root" "$dependency"
    done
  } > "$target"
  echo "Created: $package/pubspec_overrides.yaml"
}

ensure_overrides im_flutter_sdk ../ \
  im_flutter_sdk_interface im_flutter_sdk_android im_flutter_sdk_ios
ensure_overrides im_flutter_sdk_android ../ im_flutter_sdk_interface
ensure_overrides im_flutter_sdk_ios ../ im_flutter_sdk_interface
# The example already depends on the main package through path: ../.
ensure_overrides im_flutter_sdk/example ../../ \
  im_flutter_sdk_interface im_flutter_sdk_android im_flutter_sdk_ios
