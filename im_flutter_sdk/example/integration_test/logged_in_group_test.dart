import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:integration_test/integration_test.dart';

import 'modules/group_cases.dart';
import 'modules/group_cases.negative.dart';
import 'support/env.dart';
import 'support/login.dart';
import 'support/session.dart';

/// Stable entry: token login with the group case modules.
///
/// Covers the 4.25 ohos group API surface (FL-GROUP-001..060), including the
/// negative and boundary rows. Every group fixture is created through the SDK
/// (the REST group API of this app key answers 404 on every route), so the
/// entry only needs the prepared peer id.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  requireCiEnvironment(requirePeer: true);

  final client = ChatClient.getInstance;

  setUpAll(() async {
    await initCiClient();
    await loginForCi(client);
  });

  tearDownAll(() async {
    await logoutForCi(client);
    await disposeCiClient(client);
  });

  group('logged in group', () {
    registerGroupCases(client);
    registerGroupNegativeCases(client);
  });
}
