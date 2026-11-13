/// Dart-define access for the CI device suites.
///
/// The logged-in suites receive freshly fetched tokens from the CI runner;
/// nothing is committed. The credential-free `logged_out` suite (the smoke
/// entry) falls back to the public demo app key and a placeholder user id, so
/// it runs without any local data preparation — the same contract as the
/// 5.1.0 `logged_out_test.dart`.
const String ciAppKey = String.fromEnvironment(
  'E2E_APP_KEY',
  defaultValue: 'easemob#easeim',
);
const String ciUserId = String.fromEnvironment(
  'E2E_USER_ID',
  defaultValue: 'ci_smoke_user',
);
const String ciUserToken = String.fromEnvironment('E2E_USER_TOKEN');
const String ciPeerId = String.fromEnvironment('E2E_PEER_ID');
const String ciRestApi = String.fromEnvironment('E2E_REST_API');
const String ciAppToken = String.fromEnvironment('E2E_APP_TOKEN');

/// Throws a descriptive [StateError] when a required dart-define is missing.
///
/// [requireUserToken] stays false for the logged-out smoke suite: it only
/// checks that a login attempt is rejected, so no real token is needed.
void requireCiEnvironment({
  bool requireUserToken = true,
  bool requirePeer = false,
  bool requireRest = false,
}) {
  final missing = <String>[
    if (ciAppKey.isEmpty) 'E2E_APP_KEY',
    if (ciUserId.isEmpty) 'E2E_USER_ID',
    if (requireUserToken && ciUserToken.isEmpty) 'E2E_USER_TOKEN',
    if (requirePeer && ciPeerId.isEmpty) 'E2E_PEER_ID',
    if (requireRest && ciRestApi.isEmpty) 'E2E_REST_API',
    if (requireRest && ciAppToken.isEmpty) 'E2E_APP_TOKEN',
  ];
  if (missing.isNotEmpty) {
    throw StateError('Missing dart-defines: ${missing.join(', ')}');
  }
}
