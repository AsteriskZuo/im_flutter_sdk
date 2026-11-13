import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import 'ci_test.dart';
import 'env.dart';
import 'session.dart';

Duration _remaining(Stopwatch watch, Duration timeout) {
  final remaining = timeout - watch.elapsed;
  if (remaining <= Duration.zero) {
    throw TimeoutException('CI step exceeded $timeout', timeout);
  }
  return remaining;
}

/// Logs in with a CI token and waits until the client is connected.
///
/// The 4.25 line has no explicit `dataSyncType` mask: the enabled sync
/// switches are decided by the entry's [ChatOptions], so the login helper only
/// waits for the connection and the token user.
Future<void> loginForCi(
  ChatClient client, {
  String? userId,
  String? token,
  Duration timeout = const Duration(seconds: 45),
}) async {
  final expectedUser = userId ?? ciUserId;
  final loginToken = token ?? ciUserToken;
  if (expectedUser.isEmpty || loginToken.isEmpty) {
    throw StateError('CI login requires E2E_USER_ID and E2E_USER_TOKEN');
  }

  final watch = Stopwatch()..start();
  await ensureLoggedOutForCi(client);

  final handlerId = 'ci_login_${DateTime.now().microsecondsSinceEpoch}';
  var connectedEvents = 0;
  var disconnectedEvents = 0;
  client.addConnectionEventHandler(
    handlerId,
    ConnectionEventHandler(
      onConnected: () => connectedEvents += 1,
      onDisconnected: () => disconnectedEvents += 1,
    ),
  );
  try {
    await client
        .loginWithToken(expectedUser, loginToken)
        .timeout(_remaining(watch, timeout));
    await client.startCallback().timeout(_remaining(watch, timeout));
    await waitForCi(
      'CI token login connects',
      () => client.isConnected(),
      (connected) => connected,
      timeout: _remaining(watch, timeout),
    );
    if (client.currentUserId != expectedUser) {
      throw StateError(
        'CI login user mismatch: expected $expectedUser, '
        'actual ${client.currentUserId}',
      );
    }
    debugPrint(
      'CI login ready: connectedEvents=$connectedEvents '
      'disconnectedEvents=$disconnectedEvents',
    );
  } finally {
    client.removeConnectionEventHandler(handlerId);
  }
}

/// Logs out after an entry and waits until the client reports disconnected.
Future<void> logoutForCi(
  ChatClient client, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final watch = Stopwatch()..start();
  try {
    if (await client.isConnected() || client.currentUserId != null) {
      await client.logout(false).timeout(_remaining(watch, timeout));
    }
  } on ChatError catch (error) {
    debugPrint('CI logout returned code=${error.code}');
  }
  await waitForCi(
    'CI logout disconnects',
    () => client.isConnected(),
    (connected) => !connected,
    timeout: _remaining(watch, timeout),
  );
}
