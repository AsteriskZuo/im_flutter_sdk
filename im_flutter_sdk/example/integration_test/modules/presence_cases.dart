import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../support/ci_test.dart';
import '../support/env.dart';

/// Logged-in presence cases (FL-PRESENCE-006..010).
void registerPresenceCases(ChatClient client) {
  ciTestWidgets('FL-PRESENCE-006 publishes a presence description',
      (tester) async {
    final description = 'flutter-ci-${DateTime.now().microsecondsSinceEpoch}';
    await client.presenceManager.publishPresence(description);
  });

  ciTestWidgets('FL-PRESENCE-007 subscribes to a peer presence',
      (tester) async {
    final presences = await client.presenceManager.subscribe(
      members: <String>[ciPeerId],
      expiry: 3600,
    );
    addTearDown(
      () => client.presenceManager.unsubscribe(members: <String>[ciPeerId]),
    );
    expect(presences, isA<List<ChatPresence>>());
    for (final presence in presences) {
      expect(presence.publisher, isNotEmpty);
    }
  });

  ciTestWidgets('FL-PRESENCE-008 unsubscribes from a peer presence',
      (tester) async {
    await client.presenceManager
        .subscribe(members: <String>[ciPeerId], expiry: 3600);
    await client.presenceManager.unsubscribe(members: <String>[ciPeerId]);
  });

  ciTestWidgets('FL-PRESENCE-009 fetches subscribed members', (tester) async {
    final members = await client.presenceManager.fetchSubscribedMembers(
      pageNum: 1,
      pageSize: 20,
    );
    expect(members, isA<List<String>>());
  });

  ciTestWidgets('FL-PRESENCE-010 fetches presence status of peers',
      (tester) async {
    final statuses = await client.presenceManager.fetchPresenceStatus(
      members: <String>[ciPeerId],
    );
    expect(statuses, isA<List<ChatPresence>>());
    for (final status in statuses) {
      expect(status.publisher, isNotEmpty);
    }
  });
}
