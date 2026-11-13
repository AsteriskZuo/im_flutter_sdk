import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../support/ci_test.dart';

/// Presence cases that must be rejected while the client is logged out.
void registerLoggedOutPresenceCases(ChatClient client) {
  const peer = 'flutter-ci-peer';

  ciTestWidgets('FL-PRESENCE-001 rejects publish while logged out',
      (tester) async {
    await expectCiError(
      () => client.presenceManager.publishPresence('flutter-ci'),
      201,
    );
  });

  ciTestWidgets('FL-PRESENCE-002 rejects status fetch while logged out',
      (tester) async {
    await expectCiError(
      () => client.presenceManager.fetchPresenceStatus(
        members: const <String>['flutter-ci-peer'],
      ),
      201,
    );
  });

  ciTestWidgets('FL-PRESENCE-003 rejects subscribe while logged out',
      (tester) async {
    await expectCiError(
      () => client.presenceManager.subscribe(
        members: <String>[peer],
        expiry: 60,
      ),
      201,
    );
  });

  ciTestWidgets('FL-PRESENCE-004 rejects unsubscribe while logged out',
      (tester) async {
    await expectCiError(
      () => client.presenceManager.unsubscribe(
        members: <String>[peer],
      ),
      201,
    );
  });

  ciTestWidgets('FL-PRESENCE-005 rejects subscription query while logged out',
      (tester) async {
    await expectCiError(
      () => client.presenceManager.fetchSubscribedMembers(
        pageNum: 1,
        pageSize: 20,
      ),
      201,
    );
  });
}
