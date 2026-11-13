import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:integration_test/integration_test.dart';

import 'modules/contact_cases.dart';
import 'modules/contact_cases.negative.dart';
import 'support/env.dart';
import 'support/login.dart';
import 'support/session.dart';

/// Contact entry: a single token login with contact auto sync enabled.
///
/// Runs FL-CONTACT-001..020 (positive) and FL-CONTACT-021..023 (negative). The
/// app-token REST fixture is required even though the cases are single device:
/// a second session is needed to accept or decline an invitation, so each case
/// prepares and deletes its own throw-away accounts. The shared CI account and
/// the prepared peer are never modified destructively.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  requireCiEnvironment(requirePeer: true, requireRest: true);

  final client = ChatClient.getInstance;

  setUpAll(() async {
    await initCiClient(enableAutoSyncContacts: true, enableUserInfo: false);
    await loginForCi(client);
  });

  tearDownAll(() async {
    await logoutForCi(client);
    await disposeCiClient(client);
  });

  group('logged in contact', () {
    registerContactCases(client);
    registerContactNegativeCases(client);
  });
}
