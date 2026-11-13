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
Future<T> waitForCi<T>(
  String description,
  Future<T> Function() read,
  bool Function(T) matches, {
  Duration timeout = const Duration(seconds: 30),
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
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}
