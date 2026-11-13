import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:integration_test/integration_test.dart';

import 'modules/user_info_cases.dart';
import 'support/env.dart';
import 'support/login.dart';
import 'support/session.dart';

/// User info entry: a single token login with user info enabled.
///
/// Runs FL-USERINFO-001..010. The profile writes run on throw-away accounts
/// created through the app-token REST fixture, so the entry requires the REST
/// defines as well; the shared CI account is only read.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  requireCiEnvironment(requirePeer: true, requireRest: true);

  final client = ChatClient.getInstance;

  setUpAll(() async {
    await initCiClient(enableUserInfo: true);
    await loginForCi(client);
  });

  tearDownAll(() async {
    await logoutForCi(client);
    await disposeCiClient(client);
  });

  group('logged in user info', () {
    registerUserInfoCases(client);
  });
}
