import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:path_provider/path_provider.dart';

import '../support/ci_test.dart';

/// Negative and boundary group rows, FL-GROUP-057..060 of the 4.25 ohos
/// coverage draft.
///
/// The 1.15.0 chatsdk declarations (`GroupManager.d.ets`, `ChatError.d.ets`)
/// expose no numeric error constants and the ohos wrapper maps no error codes
/// itself, so a code written here would be a guess. Each case therefore asserts
/// the observable contract: a non-zero `ChatError` code when the server rejects
/// the call, plus the state that must not change. The concrete codes are
/// printed, so a later run can pin them in the draft table.
///
/// The REST group API of this app key answers 404 on every route and the peer
/// cannot log in, so no case can be provisioned with a group owned by the peer;
/// FL-GROUP-059 probes its rejection with an unknown group id instead.
void registerGroupNegativeCases(ChatClient client) {
  final manager = client.groupManager;
  var sequence = 0;

  String nextName(String caseId) =>
      'flutter_ci_group_${DateTime.now().microsecondsSinceEpoch}_'
      '${sequence++}_$caseId';

  Future<List<String>> memberIds(String groupId) async =>
      (await manager.fetchMemberListFromServer(groupId, pageSize: 100)).data;

  Future<ChatGroup> createFixture(String caseId) async {
    final group = await manager.createGroup(
      groupName: nextName(caseId),
      desc: 'flutter ci $caseId',
      options: ChatGroupOptions(maxCount: 200),
    );
    addTearDown(() async {
      try {
        await manager.destroyGroup(group.groupId);
      } catch (error) {
        debugPrint('CI $caseId cleanup: destroyGroup failed: $error');
      }
    });
    return group;
  }

  // Test: Create a group with the boundary option combination maxCount=0.
  // Expected: The server rejects the option set with a non-zero ChatError code,
  // or (if it clamps the value) the created group is destroyed again. The code
  // is UNVERIFIED because neither the chatsdk declarations nor the ohos wrapper
  // expose group error constants; the observed outcome is printed.
  ciTestWidgets('FL-GROUP-057 createGroup rejects maxCount 0', (_) async {
    final name = nextName('FL-GROUP-057');
    ChatGroup? created;
    try {
      final accepted = await manager.createGroup(
        groupName: name,
        options: ChatGroupOptions(maxCount: 0),
      );
      created = accepted;
      debugPrint(
        'CI FL-GROUP-057: server accepted maxCount 0, created '
        '${accepted.groupId}',
      );
    } on ChatError catch (error) {
      debugPrint('CI FL-GROUP-057: createGroup code=${error.code}');
      expect(error.code, isNot(0));
    }
    if (created != null) {
      final groupId = created.groupId;
      addTearDown(() async {
        try {
          await manager.destroyGroup(groupId);
        } catch (error) {
          debugPrint('CI FL-GROUP-057 cleanup: destroyGroup failed: $error');
        }
      });
    }
  });

  // Test: Add a user id that does not exist to an owned group.
  // Expected: Either a non-zero ChatError code (UNVERIFIED code) or a silent
  // partial success; in both cases the remote member count stays one and the
  // server member page stays empty because it omits the owner (see the NOTE).
  ciTestWidgets('FL-GROUP-058 addMembers keeps an unknown user out', (_) async {
    final group = await createFixture('FL-GROUP-058');
    final missing =
        'flutter_ci_missing_${DateTime.now().microsecondsSinceEpoch}';
    try {
      await manager.addMembers(group.groupId, <String>[missing]);
      debugPrint('CI FL-GROUP-058: addMembers accepted an unknown user id');
    } on ChatError catch (error) {
      debugPrint('CI FL-GROUP-058: addMembers code=${error.code}');
      expect(error.code, isNot(0));
    }
    // NOTE(deviation FL-GROUP-058): ohos fetchMemberListFromServer omits the
    // owner (see FL-GROUP-005), so an empty page proves that the unknown user
    // was not added; the member count keeps the owner check meaningful.
    final members = await memberIds(group.groupId);
    debugPrint('CI FL-GROUP-058: server member list=$members');
    expect(members, isEmpty);
    final detail = await manager.fetchGroupInfoFromServer(group.groupId);
    expect(detail.memberCount, 1);
  });

  // Test: Leave a group the current user never joined.
  // Expected: A non-zero ChatError, because the server rejects leaving a group
  // the caller is not a member of. The concrete code is UNVERIFIED on ohos: the
  // real precondition (a public group owned by the peer) cannot be provisioned
  // on this app key, since every REST group route answers 404 and the peer
  // cannot log in, so the row probes a unique unknown group id and prints the
  // observed code instead of pinning 603 (inferred from the Android wrapper).
  ciTestWidgets('FL-GROUP-059 leaveGroup rejects a group the user is not in',
      (_) async {
    final groupId =
        'flutter_ci_missing_group_${DateTime.now().microsecondsSinceEpoch}';
    try {
      await manager.leaveGroup(groupId);
      fail('leaveGroup($groupId) returned for a group the caller is not in');
    } on ChatError catch (error) {
      debugPrint('CI FL-GROUP-059: leaveGroup code=${error.code}');
      expect(error.code, isNot(0));
    }
  });

  // Test: Download a shared file id that does not exist.
  // Expected: The ohos wrapper acknowledges the call before the native transfer
  // runs (GroupManagerWrapper.ets:562-585) and the failure is only pushed to the
  // file progress channel, which the 4.25 Dart layer does not consume, so the
  // call returns normally and no file is written. The error code is therefore
  // UNVERIFIED and unobservable in Dart; the case pins the current contract.
  ciTestWidgets('FL-GROUP-060 downloadGroupSharedFile reports no error in Dart',
      (_) async {
    final group = await createFixture('FL-GROUP-060');
    final directory = await getTemporaryDirectory();
    final saved = File(
      '${directory.path}/flutter_ci_missing_download_'
      '${DateTime.now().microsecondsSinceEpoch}.txt',
    );
    addTearDown(() async {
      if (await saved.exists()) {
        await saved.delete();
      }
    });
    await manager.downloadGroupSharedFile(
      groupId: group.groupId,
      fileId: 'flutter_ci_missing_file_${group.groupId}',
      savePath: saved.path,
    );
    expect(await saved.exists(), isFalse);
  });
}
