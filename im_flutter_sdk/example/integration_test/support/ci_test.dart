import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

/// Runs a device test with a bounded timeout.
///
/// `integration_test` defaults to no timeout; a hung native bridge would
/// otherwise block the whole suite until the runner is killed.
void ciTestWidgets(
  String description,
  Future<void> Function(WidgetTester) body,
) {
  testWidgets(description, body, timeout: const Timeout(Duration(minutes: 2)));
}

/// Asserts that [operation] fails with a [ChatError] of [code].
Future<void> expectCiError(
  Future<Object?> Function() operation,
  int code,
) =>
    expectLater(
      () => operation().timeout(const Duration(seconds: 30)),
      throwsA(isA<ChatError>().having((error) => error.code, 'code', code)),
    );

/// Runs [operation], recording a value-added-service "not enabled" error as an
/// environment limitation instead of a test failure.
///
/// Code 505 means speech transcription is not enabled and code 100 means the
/// application is not registered in the server search service. In both cases
/// the successful branch cannot be exercised in this environment: the
/// limitation is recorded with [debugPrint] so the verification report carries
/// it. Any other [ChatError], and any failed expectation inside [operation], is
/// still reported; callers keep their success assertions inside [operation]
/// rather than weakening them.
Future<void> expectCiSuccessOr505(
  Future<void> Function() operation, {
  String? label,
  Set<int> codes = const <int>{505, 100},
}) async {
  try {
    await operation();
  } on ChatError catch (error) {
    if (!codes.contains(error.code)) {
      rethrow;
    }
    debugPrint(
      'CI environment limitation${label == null ? '' : ' [$label]'}: '
      'value-added service is not enabled '
      '(code ${error.code}: ${error.description})',
    );
  }
}

/// Polls [read] until [matches] returns true, or throws a [TimeoutException].
///
/// Polling policy: prefer an awaited API result or an event callback; use
/// [waitForCi] only for operations that are documented as native/server
/// asynchronous (for example a value that a server assigns after the method
/// returns). On the passing path a case normally costs one or two reads; the
/// timeout is only a failure cap. The default cap is 20s with a 500ms pause
/// between reads so a slow or flaky environment cannot turn a suite into a
/// long loop; a case with measured evidence of a longer native/server delay
/// passes an explicit `timeout`.
Future<T> waitForCi<T>(
  String description,
  Future<T> Function() read,
  bool Function(T) matches, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final watch = Stopwatch()..start();
  Object? lastObservation;
  while (true) {
    final remaining = timeout - watch.elapsed;
    if (remaining <= Duration.zero) {
      throw TimeoutException(
        '$description; last observation: $lastObservation',
        timeout,
      );
    }
    final observed = await read().timeout(remaining);
    lastObservation = observed;
    if (matches(observed)) return observed;
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }
}

/// Records a CI-environment limitation instead of turning it into a failure.
///
/// Only for server-owned asynchronous effects that are not observable within
/// the test's polling budget on the shared CI app (`easemob-demo#zuoyu`),
/// whose roaming index has shown multi-minute delays. Every local and
/// documented guarantee must already be asserted before this is called; the
/// case is reported as skipped and recorded in the verification report.
void skipCiServerDelay(String detail) {
  markTestSkipped(
    'UNVERIFIED (CI server async): $detail. The shared CI app has shown '
    'multi-minute roaming index delays; rerun on a dedicated app to verify.',
  );
}
