import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:integration_test/integration_test.dart';

import 'modules/client_cases.negative.dart';
import 'modules/event_registration_cases.dart';
import 'modules/presence_cases.negative.dart';
import 'support/env.dart';
import 'support/session.dart';

/// Stable entry: no login. Covers SDK initialization, the client facade, the
/// logged-out rejection contract, and the local event handler registry.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  requireCiEnvironment();

  final client = ChatClient.getInstance;

  setUpAll(() async {
    await initCiClient();
    await ensureLoggedOutForCi(client);
  });

  tearDownAll(() async {
    await disposeCiClient(client);
  });

  registerLoggedOutClientCases(client);
  registerLoggedOutPresenceCases(client);
  registerLoggedOutEventCases(client);
}
