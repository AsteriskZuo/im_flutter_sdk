/// Dart-define access for the CI device suites.
///
/// The values are written by `tool/ci/write_e2e_dart_defines.sh` (or by the
/// local ohos wrapper script) from a freshly prepared token file, so tests
/// never hardcode account credentials.
const String ciAppKey = String.fromEnvironment('E2E_APP_KEY');
const String ciUserId = String.fromEnvironment('E2E_USER_ID');
const String ciUserToken = String.fromEnvironment('E2E_USER_TOKEN');
const String ciPeerId = String.fromEnvironment('E2E_PEER_ID');
const String ciRestApi = String.fromEnvironment('E2E_REST_API');
const String ciAppToken = String.fromEnvironment('E2E_APP_TOKEN');

/// Throws a descriptive [StateError] when a required dart-define is missing.
void requireCiEnvironment({
  bool requirePeer = false,
  bool requireRest = false,
}) {
  final missing = <String>[
    if (ciAppKey.isEmpty) 'E2E_APP_KEY',
    if (ciUserId.isEmpty) 'E2E_USER_ID',
    if (ciUserToken.isEmpty) 'E2E_USER_TOKEN',
    if (requirePeer && ciPeerId.isEmpty) 'E2E_PEER_ID',
    if (requireRest && ciRestApi.isEmpty) 'E2E_REST_API',
    if (requireRest && ciAppToken.isEmpty) 'E2E_APP_TOKEN',
  ];
  if (missing.isNotEmpty) {
    throw StateError('Missing dart-defines: ${missing.join(', ')}');
  }
}
