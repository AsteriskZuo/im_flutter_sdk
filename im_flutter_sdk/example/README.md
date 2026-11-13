# IM API Tester (example)

A visual test harness for `im_flutter_sdk`. It lets a human tester — or an AI
agent — call SDK APIs with JSON parameters and inspect the results, for
verifying real data correctness after SDK upgrades.

## Setup

Before first run, from the project root:

```bash
make setup          # config + deps + pods
```

Then configure the local test environment (same model as 5.1.0):

```bash
make config         # create example/config.local.json + placeholder example/lib/env.dart
# edit im_flutter_sdk/example/config.local.json: restApi / appKey / clientId / clientSecret / accounts
make env-gettoken   # fetch user tokens and rewrite example/lib/env.dart
```

`config.local.json` and `lib/env.dart` are gitignored; `env.dart` is generated
with mode 600 and contains the appKey plus one user token per account (tokens
expire after `tokenTtl`, 24h by default). Re-run `make env-gettoken` when the
token expires. `make setup` still creates the legacy `scripts/config.json`
(AutoMode script config) when it is missing.

The generated `env.dart` pre-fills the manual pages: the init page shows the
`ChatOptions` JSON built from the environment, and the login page defaults to
the first account id + token (token mode). This is the "manual API verification"
flow: init → login → search page → API call page.

On a fresh checkout (and in CI) `tool/ci/ensure_example_env.sh` copies the
empty template `templates/env.example.dart` to `lib/env.dart` when it is
missing, so the example compiles without credentials; CI never creates
`config.local.json`.

## Page flow

```
Init page ──init ok──▶ Login page ──login ok──▶ Search page ──tap──▶ API call page
```

- **Init** (one-shot): edit the `EMOptions` JSON template and initialize. The
  template starts from `lib/env.dart` when `make env-gettoken` has generated it.
  Cannot be redone without restarting the app.
- **Login**: password or token (toggle); prefilled with the first account from
  `lib/env.dart` (id + token, token mode). Also hosts logout / re-login; later
  pages can navigate back here.
- **Search**: live, case-insensitive substring matching over API name and group.
- **API call**: pre-filled required-field JSON template → invoke → result JSON
  (copyable). Results are also written to the log.

The full API list is registered in `lib/registry/apis/` — add an `ApiEntry`
there to cover more APIs.

## Logs

Every event (API results, listener callbacks, lifecycle) is emitted as a
single-line JSON record:

```
[APITEST] {"ts":..., "seq":..., "source":"api.EMChatManager.sendMessage", "payload":{...}}
```

- **stdout**: prefixed with `[APITEST]`, easy to grep from `flutter run`.
- **file**: appended to `api_test.log` in the app documents directory; the
  absolute path is printed at startup (`source: "log.path"`). Prefer this
  channel on Android, where logcat may truncate long lines.
- **in-app**: a floating log ball appears after init (drag, open, clear, copy).

## Script mode (AI-friendly)

Run a whole scenario without touching the UI:

```
flutter run --dart-define=API_SCRIPT=/absolute/path/script.json \
            --dart-define=API_CONFIG=/absolute/path/config.json   # optional
```

`API_CONFIG` points to a JSON file with test data (appKey, accounts, group/room
ids). The base config is always the generated `lib/env.dart` environment; when
`API_CONFIG` is given (or a `config.json` sits next to the script), its keys are
merged over the environment. `init` is derived from the merged config's
ChatOptions keys (`appKey`, `autoLogin`, `debugMode`, `enableUserInfo`,
`enableAutoSyncContacts`, `autoLoadConversations`, `enableChatroomConversation`,
… see `chatOptionKeys` in `lib/options_codec.dart`) and `login` from
`loginUser` + `loginToken`/`loginPassword`, falling back to the first account
(id + token) written into `lib/env.dart`. Explicit `init` / `login` blocks in the
script override the derived values.

```json
{
  "steps": [
    { "api": "ChatManager.sendMessage", "params": { "to": "$config.userId01", "chatType": 0, "direction": 0, "status": 0, "body": {"type": 0, "content": "hi"} } },
    { "api": "ChatManager.downloadBigImage", "params": { "message": "$prev" }, "delayAfterMs": 1000 }
  ]
}
```

- `login` accepts `password` or `token`. A failed login is retried up to 5
  times (1s apart, each attempt logged) — native init can report success
  before the SDK is actually ready.
- Reference syntax (a param string that matches exactly is replaced, keeping
  the original value type):
  - `"$config.key"` / `"$config.key.sub"` — value from the config file;
  - `"$prev"` / `"$prev.a.b"` — previous step's `data` (dot path digs deeper,
    list indexes allowed);
  - `"$step.id"` / `"$step.id.a.b"` — `data` of any step that declared an
    `"id"`, for references spanning multiple steps.
- `TestUtil.writeBase64File` (script mode only, not in the registry) writes a
  base64 blob into the documents directory — use it to create local files for
  image/voice messages: `{ "api": "TestUtil.writeBase64File", "id": "f",
  "params": {"fileName": "a.png", "base64": "..."} }`, then
  `"$step.f.path"`.
- Each step is guarded by a timeout (default 30s, override per step with
  `"timeoutMs"`): a timed-out step logs `{"code": -2}` and the run continues —
  native calls sometimes never call back (e.g. some APIs while logged out).
- Steps run sequentially; a failed step is counted and does not abort the run.
- Ends with `{"source":"script.done","payload":{"total":N,"failed":M}}`; the app
  keeps running so listeners keep logging.
- Without `API_SCRIPT`, the app behaves as the manual tester above.

**Android note**: the emulator/device has its own filesystem — host paths do not
exist there (the iOS simulator shares the host fs, Android does not). Push the
files into the app-specific external dir first and reference the device paths:

```
adb push scripts/script_422_apis.json /sdcard/Android/data/com.example.example/files/
adb push scripts/config.json          /sdcard/Android/data/com.example.example/files/
flutter run --dart-define=API_SCRIPT=/sdcard/Android/data/com.example.example/files/script_422_apis.json \
            --dart-define=API_CONFIG=/sdcard/Android/data/com.example.example/files/config.json
```

A full example covering the 4.22 additions lives at `scripts/script_422_apis.json`
(expects the keys of `scripts/config.json`).

**HarmonyOS note**: the HarmonyOS emulator/device app sandbox cannot read host
paths or `/data/local/tmp`, so for script mode the script/config must be readable
from inside the app sandbox (or use the manual pages, which are prefilled from
`lib/env.dart`). Manual verification needs no files:
`make env-gettoken` → `flutter run` → init (prefilled) → login (first account
token prefilled) → search page → pick an API.

## Verification entry points

- `example/test/env_tool_test.dart` — unit tests for the env.dart data prep tool
  (placeholder copy, atomic write/600, config validation, literal rendering).
- `example/integration_test/` — six HarmonyOS integration suites (no-login,
  logged-in base/contact/group/user-info/special). They take six `E2E_*`
  dart-defines; see `tool/ci/ohos_local.sh`.
- Local HarmonyOS runs: `bash tool/ci/ohos_local.sh` (all suites),
  `bash tool/ci/smoke_local.harmony.sh`, `bash tool/ci/nightly_local.harmony.sh`
  (Android/iOS entries stay unchanged).
- Quality gate (official Flutter 3.47): `FORMAT_BASE_SHA=HEAD bash tool/ci/run_quality.sh`.

Note: the ohos fork build requires the fork `flutter pub get` after any official
Flutter `pub get` touched `.flutter-plugins-dependencies` (otherwise the ohos
plugin section is missing and hvigor fails); see the verification doc.

## Coverage scope

Phase 1 covers the 4.22 additions plus prerequisites (init / login / logout /
sendMessage) — see `lib/registry/apis/`. Model-level additions (senderInfo, big
image fields, voice text, contact/group fields) are verified through API outputs
and event callbacks.
