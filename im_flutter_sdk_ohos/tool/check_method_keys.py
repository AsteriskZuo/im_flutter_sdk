#!/usr/bin/env python3
"""Bidirectional consistency check between ArkTS key constants and Dart sources.

Compares:
  - MethodKeys.ets (class MethodKey)        <-> chat_method_keys.dart (class ChatMethodKeys)
  - MethodKeys.ets (event classes)          <-> chat_event_keys.dart

Usage:
  python3 check_method_keys.py            # check only, exit 1 on any diff
  python3 check_method_keys.py --generate # regenerate MethodKeys.ets from Dart, then check

Paths are resolved relative to the repository root of im_flutter_sdk_ohos
(the parent directory of this script's directory).
"""

import re
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
OHOS_PKG_ROOT = SCRIPT_DIR.parent
WORKTREE_ROOT = OHOS_PKG_ROOT.parent

DART_METHOD_KEYS = WORKTREE_ROOT / "im_flutter_sdk/lib/src/internal/chat_method_keys.dart"
DART_EVENT_KEYS = WORKTREE_ROOT / "im_flutter_sdk/lib/src/internal/chat_event_keys.dart"
ETS_KEYS = OHOS_PKG_ROOT / "ohos/src/main/ets/components/plugin/MethodKeys.ets"

CONST_RE = re.compile(
    r"static\s+const\s+String\s+(\w+)\s*=\s*(?:\"([^\"]*)\"|'([^']*)')"
)
ETS_CONST_RE = re.compile(
    r"static\s+readonly\s+(\w+)\s*:\s*string\s*=\s*\"([^\"]*)\""
)
CLASS_RE = re.compile(r"^class\s+(\w+)\s*\{", re.MULTILINE)

GENERATED_HEADER = """// Generated from im_flutter_sdk Dart sources by tool/check_method_keys.py --generate.
// Keep in sync with:
//   im_flutter_sdk/lib/src/internal/chat_method_keys.dart (class MethodKey below)
//   im_flutter_sdk/lib/src/internal/chat_event_keys.dart  (event classes below)
// Run `python3 im_flutter_sdk_ohos/tool/check_method_keys.py` to verify.

"""


def parse_dart_classes(path: Path):
    """Parse Dart file into {class_name: [(const_name, value), ...]} preserving order."""
    text = path.read_text(encoding="utf-8")
    classes = {}
    class_starts = [(m.start(), m.group(1)) for m in CLASS_RE.finditer(text)]
    for idx, (start, name) in enumerate(class_starts):
        end = class_starts[idx + 1][0] if idx + 1 < len(class_starts) else len(text)
        body = text[start:end]
        classes[name] = [
            (m.group(1), m.group(2) if m.group(2) is not None else m.group(3))
            for m in CONST_RE.finditer(body)
        ]
    return classes


def parse_ets_classes(path: Path):
    """Parse ArkTS file into {class_name: {const_name: value}}."""
    text = path.read_text(encoding="utf-8")
    classes = {}
    class_starts = [
        (m.start(), m.group(1))
        for m in re.finditer(r"(?:export\s+)?(?:default\s+)?class\s+(\w+)\s*\{", text)
    ]
    for idx, (start, name) in enumerate(class_starts):
        end = class_starts[idx + 1][0] if idx + 1 < len(class_starts) else len(text)
        body = text[start:end]
        classes[name] = {m.group(1): m.group(2) for m in ETS_CONST_RE.finditer(body)}
    return classes


def generate():
    """Regenerate MethodKeys.ets from the Dart sources."""
    method_classes = parse_dart_classes(DART_METHOD_KEYS)
    event_classes = parse_dart_classes(DART_EVENT_KEYS)
    if list(method_classes.keys()) != ["ChatMethodKeys"]:
        raise SystemExit(f"unexpected classes in method keys dart: {list(method_classes)}")

    lines = [GENERATED_HEADER]
    lines.append("export default class MethodKey {\n")
    for name, value in method_classes["ChatMethodKeys"]:
        lines.append(f'  static readonly {name}: string = "{value}";\n')
    lines.append("}\n")

    for class_name, consts in event_classes.items():
        lines.append(f"\nexport class {class_name} {{\n")
        for name, value in consts:
            lines.append(f'  static readonly {name}: string = "{value}";\n')
        lines.append("}\n")

    ETS_KEYS.write_text("".join(lines), encoding="utf-8")
    print(f"generated {ETS_KEYS}")


def check():
    ets = parse_ets_classes(ETS_KEYS)
    method_dart = parse_dart_classes(DART_METHOD_KEYS)["ChatMethodKeys"]
    event_dart = parse_dart_classes(DART_EVENT_KEYS)

    diffs = []

    # Method keys: MethodKey <-> ChatMethodKeys
    ets_methods = ets.get("MethodKey", {})
    dart_methods = dict(method_dart)
    for name, value in method_dart:
        if name not in ets_methods:
            diffs.append(f"[method] dart has `{name}` = \"{value}\", ets missing")
        elif ets_methods[name] != value:
            diffs.append(
                f"[method] `{name}` value mismatch: dart \"{value}\" vs ets \"{ets_methods[name]}\""
            )
    for name in ets_methods:
        if name not in dart_methods:
            diffs.append(f"[method] ets has `{name}` = \"{ets_methods[name]}\", dart missing")

    # Event keys: each Dart event class <-> same-named ets class
    for class_name, consts in event_dart.items():
        ets_class = ets.get(class_name, {})
        dart_map = dict(consts)
        for name, value in consts:
            if name not in ets_class:
                diffs.append(f"[event:{class_name}] dart has `{name}` = \"{value}\", ets missing")
            elif ets_class[name] != value:
                diffs.append(
                    f"[event:{class_name}] `{name}` value mismatch: dart \"{value}\" vs ets \"{ets_class[name]}\""
                )
        for name in ets_class:
            if name not in dart_map:
                diffs.append(
                    f"[event:{class_name}] ets has `{name}` = \"{ets_class[name]}\", dart missing"
                )
    for class_name in ets:
        if class_name == "MethodKey":
            continue
        if class_name not in event_dart:
            diffs.append(f"[event] ets class `{class_name}` has no dart counterpart")

    method_count = len(ets_methods)
    event_count = sum(len(v) for k, v in ets.items() if k != "MethodKey")
    print(f"ets method keys: {method_count}, ets event constants: {event_count}")
    if diffs:
        print(f"DIFF ({len(diffs)}):")
        for d in diffs:
            print(f"  {d}")
        return 1
    print("OK: bidirectional diff is empty (0 differences)")
    return 0


if __name__ == "__main__":
    if "--generate" in sys.argv:
        generate()
    sys.exit(check())
