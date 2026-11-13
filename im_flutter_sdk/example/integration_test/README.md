# ohos integration test suites

Device verification for the ohos line of `im_flutter_sdk`. The suites are
modelled after the 5.1.0 `example/integration_test` architecture: a small set of
stable entries, per-domain case modules, and shared support helpers. They run on
a HarmonyOS device or emulator (local gate, see decision D14 in
`docs/decisions/im-flutter-sdk-ohos-merge/2026-11-11-ohos-merge-key-decisions.md`).

## Layout

```text
integration_test/
  logged_out_test.dart            no login: initialization, logged-out guards
  logged_in_base_test.dart        login + message + conversation + local DB
  logged_in_contact_test.dart     contacts (enableAutoSyncContacts)
  logged_in_group_test.dart       groups
  logged_in_user_info_test.dart   user info (enableUserInfo)
  logged_in_special_test.dart     chat rooms + push + 505-classified APIs
  modules/                        case registrars, one file per domain
  support/                        ci_test, env, session, login, rest helpers
```

Case IDs follow the 4.25 coverage draft
(`docs/porting/ohos-4.25.0/2026-11-12-test-coverage-draft.md`) and are recorded,
with the current pass/deviation state, in
`docs/porting/ohos-4.25.0/2026-11-12-test-coverage.md` (status snapshot) and
`docs/porting/ohos-4.25.0/2026-11-12-test-failure-ledger.md` (failure analysis).
The final run record for this rewrite is
`docs/porting/ohos-4.25.0/2026-11-12-test-verification.md`.

Each case carries `// Test:` / `// Expected:` comments. Cases that document a
known SDK difference are marked `NOTE(deviation FL-XXX-YYY)` next to the
assertion they describe; the matching analysis lives in the failure ledger.
Environment-limited rows (505 value-added services, 100 search service) go
through the `expectCiSuccessOr505` helper and print the observed limitation.

## Environment

The entries read six dart-defines (see `support/env.dart`):

```text
E2E_APP_KEY  E2E_USER_ID  E2E_USER_TOKEN  E2E_PEER_ID  E2E_REST_API  E2E_APP_TOKEN
```

The token file can be produced with the 5.1.0 helper (the ohos branch does not
vendor the token tool):

```bash
cd im_flutter_sdk/.worktree/5.1.0
E2E_REST_API=http://ngi-a1.easemob.com \
E2E_APP_KEY='easemob-demo#zuoyu' \
E2E_CLIENT_ID='...' E2E_CLIENT_SECRET='...' \
E2E_USER_ID=zuoyu01 \
  bash tool/ci/fetch_e2e_user_token.sh --json > /tmp/ohos_e2e_zuoyu01.json
chmod 600 /tmp/ohos_e2e_zuoyu01.json
```

Run the peer account (`zuoyu02`) the same way when a second identity is needed;
the suites only use the single `E2E_USER_*` account plus the REST-prepared peer.

`logged_in_contact`, `logged_in_group`, `logged_in_special` and (for the
destructive message cases that delete server data) `logged_in_base` also need
`E2E_REST_API` + `E2E_APP_TOKEN`; those cases prepare throw-away users and
restore relations through `support/rest.dart`.

## Running

Use the HarmonyOS Flutter fork (3.41.9+ohos) and an online device/emulator:

```bash
cd im_flutter_sdk/.worktree/ohos/im_flutter_sdk/example
export PATH="$HOME/fvm/versions/custom_ohos/bin:$PATH"
OHOS_SKIP_CODESIGN=1 flutter test integration_test/logged_in_base_test.dart \
  -d 127.0.0.1:5555 --no-pub \
  --dart-define-from-file=/tmp/ohos_e2e_zuoyu01.json
```

`OHOS_SKIP_CODESIGN=1` is needed while the emulator build has no signing
configuration: it lets the fork use the unsigned hap and is documented in the
verification record. Without the fork patch, the same command fails with
"请通过DevEco Studio打开ohos工程后配置调试签名".

All six suites can be run in one go with the local wrapper (this is the only
ohos-specific entry; the Android/iOS CI scripts and workflows are unchanged):

```bash
E2E_CONFIG_PATH=/tmp/ohos_e2e_zuoyu01.json \
  bash tool/ci/ohos_local.sh
```

Pass suite names (`logged_out logged_in_base ...`) to run a subset, and set
`FLUTTER_BIN` / `OHOS_DEVICE` when the defaults do not apply.

## Notes

- The legacy `no_login_presence_test.dart` and `single_account_local_test.dart`
  remain as the Android/iOS CI entries; the new suites are the ohos rewrite and
  are additive.
- The room cases create their chat room through REST in `setUpAll`; the group
  cases create groups through the SDK because the REST group routes answer 404
  on this app key.
- Cleanup: entries log in and out through `support/login.dart`; fixtures either
  destroy their own resources or explicitly leave peer-owned groups orphaned
  and print a `CI cleanup:` line, which the failure ledger collects.
