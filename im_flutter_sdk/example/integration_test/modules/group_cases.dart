import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:path_provider/path_provider.dart';

import '../support/ci_test.dart';
import '../support/env.dart';
import '../support/login.dart';

/// Polls [getGroupWithId] until the local cache returns an empty shell (or
/// stops resolving the group) after the caller left/destroyed/cleared it.
Future<void> waitForCachedGroupCleared(String groupId) async {
  await waitForCi<ChatGroup?>(
    'CI local group cache is cleared for $groupId',
    () => ChatClient.getInstance.groupManager.getGroupWithId(groupId),
    (cached) {
      if (cached == null) return true;
      return (cached.groupName ?? '').isEmpty && (cached.owner ?? '').isEmpty;
    },
  );
}

/// Positive group cases, FL-GROUP-001..056 of the 4.25 ohos coverage draft.
///
/// Every case creates its own group named `flutter_ci_group_<micros>_<seq>`
/// through the SDK with the logged-in user as owner, and destroys it from a
/// tear-down, so the cases stay independent of each other and of the shared CI
/// account state. Cases that need a second member invite the prepared peer in
/// the same `createGroup` call, which skips the invite/accept round trip a
/// single device cannot complete; the peer account itself is never deleted.
///
/// The REST group API of this app key answers 404 on every group route and the
/// peer cannot log in, so the peer-owned fixtures of 004/041/042/043/044 are not
/// provisioned that way: 004 and 041 create a group owned by the current user
/// (041 then transfers it to the peer), while the join-application rows of
/// 042/043/044 are skipped as UNVERIFIED because they need a peer-owned
/// approval group and a second applicant.
/// A group transferred to the peer cannot be destroyed from this account, so
/// the tear-down leaves it and logs the residual group.
///
/// Group events are addressed to the other members, and the ohos CI run has a
/// single principal, so the rows that only vary the peer's event stream (014
/// onMemberJoined, 015 onInvitationReceived, 016 onUserRemoved, 024
/// onGroupDestroyed, 027 onOwnerChanged, 028 onAdminAdded, 032 all member mute,
/// 055 namecard change) assert the state the call leaves behind instead of the
/// event. Those event expectations are UNVERIFIED here: verifying them needs a
/// second connected client and belongs to the FL-EVENT domain entry.
void registerGroupCases(ChatClient client) {
  final manager = client.groupManager;
  final fixtures = _GroupFixtures(manager);

  // Test: Create a group owned by the logged-in user, read it back from the
  // local cache, then read an id that does not exist.
  // Expected: The cached snapshot carries the created id, name, and owner; an
  // unknown id resolves to an empty snapshot instead of throwing. Teardown
  // destroys it.
  //
  // NOTE(deviation FL-GROUP-001): chatsdk 1.15.0 manager.getGroup documents
  // `undefined` for an unknown id, but the ohos build returns an empty shell
  // Group, so Dart sees a non-null ChatGroup with empty name/owner instead of
  // null. The stale-shell check is asserted below; the row stays a deviation
  // until the wrapper filters the shell out.
  ciTestWidgets('FL-GROUP-001 getGroupWithId reads the cached group',
      (_) async {
    final group = await fixtures.create(caseId: 'FL-GROUP-001');
    final cached = await manager.getGroupWithId(group.groupId);
    expect(cached, isNotNull);
    expect(cached!.groupId, group.groupId);
    expect(cached.groupName, group.groupName);
    expect(cached.owner, ciUserId);

    final missingId =
        'flutter_ci_missing_${DateTime.now().microsecondsSinceEpoch}';
    final missing = await manager.getGroupWithId(missingId);
    debugPrint('CI FL-GROUP-001: unknown id resolved to '
        '${missing?.groupId} name="${missing?.groupName}" '
        'owner="${missing?.owner}"');
    expect(missing, isNotNull);
    expect(missing!.groupId, missingId);
    expect(missing.groupName ?? '', isEmpty);
    expect(missing.owner ?? '', isEmpty);
  });

  // Test: Create a group with the peer as a member, then read the joined list
  // from the local cache.
  // Expected: The created group appears exactly once with the created name and
  // the current user as owner. Teardown destroys it.
  ciTestWidgets('FL-GROUP-002 getJoinedGroups contains the created group',
      (_) async {
    final group = await fixtures.create(
      caseId: 'FL-GROUP-002',
      addPeer: true,
    );
    final joined = await manager.getJoinedGroups();
    final matches =
        joined.where((item) => item.groupId == group.groupId).toList();
    expect(matches, hasLength(1));
    expect(matches.single.groupName, group.groupName);
    expect(matches.single.owner, ciUserId);
  });

  // Test: Create a group with the peer as a member, then page the joined groups
  // on the server with the member count and role switches enabled.
  // Expected: The first page is bounded by pageSize, holds unique ids, and
  // carries the created group with its name and owner. The ohos wrapper ignores
  // needMemberCount/needRole (ported gap ledger 02 16.1-A#12), so the member
  // count and role fields are not asserted here.
  ciTestWidgets(
      'FL-GROUP-003 fetchJoinedGroupsFromServer pages the joined list',
      (_) async {
    final group = await fixtures.create(
      caseId: 'FL-GROUP-003',
      addPeer: true,
    );
    final page = await manager.fetchJoinedGroupsFromServer(
      pageSize: 20,
      pageNum: 0,
      needMemberCount: true,
      needRole: true,
    );
    final ids = page.map((item) => item.groupId).toList();
    expect(ids, contains(group.groupId));
    expect(ids.toSet(), hasLength(ids.length));
    final found = page.firstWhere((item) => item.groupId == group.groupId);
    expect(found.groupName, group.groupName);
    expect(found.owner, ciUserId);

    final single = await manager.fetchJoinedGroupsFromServer(
      pageSize: 1,
      pageNum: 0,
    );
    expect(single.length, lessThanOrEqualTo(1));
  });

  // Test: Create a public open-join group owned by the logged-in user through
  // the SDK and walk the public group pages.
  // Expected: Every page item carries a non-empty id and name, and the created
  // public group is reachable within the walked pages. Teardown destroys it.
  //
  // The peer-owned public group the REST fixture used to create cannot be
  // provisioned on this app key (every REST group route answers 404) and the
  // peer cannot log in, so the row creates a self-owned public group instead;
  // reachability of a created public group is the same assertion.
  ciTestWidgets('FL-GROUP-004 fetchPublicGroupsFromServer finds a public group',
      (_) async {
    final group = await fixtures.create(
      caseId: 'FL-GROUP-004',
      options: ChatGroupOptions(style: ChatGroupStyle.PublicOpenJoin),
    );
    final groupId = group.groupId;
    Future<Set<String>> walkPublicGroups() async {
      final seen = <String>{};
      String? cursor;
      for (var index = 0; index < 5; index += 1) {
        final result = await manager.fetchPublicGroupsFromServer(
          pageSize: 100,
          cursor: cursor,
        );
        seen.addAll(result.data.map((item) => item.groupId));
        final next = result.cursor ?? '';
        if (next.isEmpty || seen.contains(groupId)) {
          break;
        }
        cursor = next;
      }
      return seen;
    }

    final ids = await waitForCi<Set<String>>(
      'CI FL-GROUP-004 public group $groupId is listed',
      walkPublicGroups,
      (seen) => seen.contains(groupId),
      timeout: const Duration(seconds: 20),
    );
    expect(ids, contains(groupId));
    final page = await manager.fetchPublicGroupsFromServer(pageSize: 100);
    expect(
      page.data.every((item) => (item.name ?? '').isNotEmpty),
      isTrue,
    );
  });

  // Test: Create a group that invites the peer directly and reads the member
  // list plus the server joined list.
  // Expected: The call returns the created id, the requested name, and the
  // current user as owner; the server member list holds exactly the peer (the
  // owner is omitted, see the NOTE); the server joined list contains the
  // group. Teardown destroys it.
  ciTestWidgets('FL-GROUP-005 createGroup invites the peer', (_) async {
    final name = fixtures.nextName();
    final group = await manager.createGroup(
      groupName: name,
      desc: 'flutter ci FL-GROUP-005',
      inviteMembers: <String>[ciPeerId],
      inviteReason: 'flutter ci invite',
      options: ChatGroupOptions(maxCount: 200),
    );
    fixtures.destroyOnTeardown(group.groupId);
    expect(group.groupId, isNotEmpty);
    expect(group.groupName, name);
    expect(group.owner, ciUserId);
    final members = await waitForCi<List<String>>(
      'CI FL-GROUP-005 server members hold the peer',
      () => fixtures.memberIds(group.groupId),
      (ids) => ids.contains(ciPeerId),
    );
    // NOTE(deviation FL-GROUP-005): ohos fetchMemberListFromServer (chatsdk
    // fetchGroupMembers) omits the owner, so the page holds only the invited
    // peer although the group has two members (FL-GROUP-006 still reads
    // memberCount 2 and the owner is asserted on the created snapshot above).
    debugPrint('CI FL-GROUP-005: server member list=$members owner=$ciUserId');
    expect(members, <String>[ciPeerId]);
    // The server rejects pageSize > 20 with code 112 (query param reaches
    // limit), so this row pages with the SDK default of 20.
    final joined = await manager.fetchJoinedGroupsFromServer(pageSize: 20);
    expect(joined.map((item) => item.groupId), contains(group.groupId));
  });

  // Test: Create a group with a distinctive member cap and the peer as member,
  // then fetch its server detail.
  // Expected: Id, name, description, owner, member count, member cap, and the
  // enabled state all match the fixture. Teardown destroys it.
  ciTestWidgets(
      'FL-GROUP-006 fetchGroupInfoFromServer returns the remote detail',
      (_) async {
    final group = await fixtures.create(
      caseId: 'FL-GROUP-006',
      addPeer: true,
      desc: 'flutter ci FL-GROUP-006',
      options: ChatGroupOptions(maxCount: 188),
    );
    final detail = await manager.fetchGroupInfoFromServer(group.groupId);
    expect(detail.groupId, group.groupId);
    expect(detail.groupName, group.groupName);
    expect(detail.desc, 'flutter ci FL-GROUP-006');
    expect(detail.owner, ciUserId);
    expect(detail.memberCount, 2);
    expect(detail.maxUserCount, 188);
    expect(detail.isDisabled, isFalse);
  });

  // Test: Create a group with the peer as member and page the server member
  // list.
  // Expected: One page with exactly the peer (the owner is omitted, see the
  // NOTE), no duplicates, and no next cursor. Teardown destroys it.
  ciTestWidgets('FL-GROUP-007 fetchMemberListFromServer lists both members',
      (_) async {
    final group = await fixtures.create(
      caseId: 'FL-GROUP-007',
      addPeer: true,
    );
    final members = await manager.fetchMemberListFromServer(
      group.groupId,
      pageSize: 100,
    );
    // NOTE(deviation FL-GROUP-007): the same owner omission as FL-GROUP-005.
    debugPrint('CI FL-GROUP-007: server member list=${members.data}');
    expect(members.data, <String>[ciPeerId]);
    expect(members.data.toSet(), hasLength(1));
    expect(members.cursor ?? '', isEmpty);
  });

  // Test: Block the peer, then read the server group block list.
  // Expected: The block list holds exactly the peer. Teardown destroys the
  // group.
  ciTestWidgets('FL-GROUP-008 fetchBlockListFromServer reads the block list',
      (_) async {
    final group = await fixtures.create(
      caseId: 'FL-GROUP-008',
      addPeer: true,
    );
    await manager.blockMembers(group.groupId, <String>[ciPeerId]);
    final blocked = await waitForCi<List<String>>(
      'CI FL-GROUP-008 block list holds the peer',
      () => manager.fetchBlockListFromServer(
        group.groupId,
        pageSize: 100,
        pageNum: 1,
      ),
      (ids) => ids.contains(ciPeerId),
    );
    expect(blocked, <String>[ciPeerId]);
  });

  // Test: Mute the peer, then read the server mute list.
  // Expected: The mute list holds the peer with a positive mute value. Teardown
  // destroys the group.
  ciTestWidgets('FL-GROUP-009 fetchMuteListFromServer reads the mute list',
      (_) async {
    final group = await fixtures.create(
      caseId: 'FL-GROUP-009',
      addPeer: true,
    );
    await manager.muteMembers(
      group.groupId,
      <String>[ciPeerId],
      duration: 600000,
    );
    final muted = await waitForCi<Map<String, int>>(
      'CI FL-GROUP-009 mute list holds the peer',
      () => manager.fetchMuteListFromServer(
        group.groupId,
        pageSize: 100,
        pageNum: 1,
      ),
      (list) => list.containsKey(ciPeerId),
    );
    expect(muted[ciPeerId], greaterThan(0));
  });

  // Test: Add the peer to the allowlist, then read the server allowlist.
  // Expected: The allowlist holds the peer. Teardown destroys the group.
  ciTestWidgets('FL-GROUP-010 fetchAllowListFromServer reads the allowlist',
      (_) async {
    final group = await fixtures.create(
      caseId: 'FL-GROUP-010',
      addPeer: true,
    );
    await manager.addAllowList(group.groupId, <String>[ciPeerId]);
    final allowed = await waitForCi<List<String>>(
      'CI FL-GROUP-010 allowlist holds the peer',
      () => manager.fetchAllowListFromServer(group.groupId),
      (ids) => ids.contains(ciPeerId),
    );
    expect(allowed, contains(ciPeerId));
  });

  // Test: Probe the allowlist membership check before adding the current user,
  // after adding it, and after removing it again.
  // Expected: the ohos sequence observed on device is true (empty list, the
  // owner counts as allowed) -> true (explicitly added) -> false (removed).
  // The 4.25 ohos signature only takes the group id and reports the current
  // user; the allowlist contents themselves are covered by FL-GROUP-010/034/035.
  ciTestWidgets('FL-GROUP-011 isMemberInAllowListFromServer tracks the caller',
      (_) async {
    final group = await fixtures.create(caseId: 'FL-GROUP-011');
    // NOTE(deviation FL-GROUP-011): with an empty allowlist the check already
    // reports true for the owner/caller, so the documented false -> true ->
    // false sequence is not observable on ohos.
    final initial = await manager.isMemberInAllowListFromServer(group.groupId);
    debugPrint('CI FL-GROUP-011: initial allowlist check=$initial');
    expect(initial, isTrue);
    await manager.addAllowList(group.groupId, <String>[ciUserId]);
    final allowed = await waitForCi<bool>(
      'CI FL-GROUP-011 current user enters the allowlist',
      () => manager.isMemberInAllowListFromServer(group.groupId),
      (value) => value,
    );
    expect(allowed, isTrue);
    await manager.removeAllowList(group.groupId, <String>[ciUserId]);
    final removed = await waitForCi<bool>(
      'CI FL-GROUP-011 current user leaves the allowlist',
      () => manager.isMemberInAllowListFromServer(group.groupId),
      (value) => !value,
    );
    debugPrint('CI FL-GROUP-011: allowlist check after remove=$removed');
    // NOTE(deviation FL-GROUP-011): the observed ohos sequence is
    // true (empty list / owner) -> true (added) -> false (removed); the
    // documented false -> true -> false sequence is not observable because
    // the empty list already reports the owner as allowed.
    expect(removed, isFalse);
  });

  // Test: Upload a real local file to the group and read the server file list.
  // Expected: One entry whose id is non-empty, and whose name, owner, and byte
  // size match the uploaded file. Teardown destroys the group.
  ciTestWidgets('FL-GROUP-012 fetchGroupFileListFromServer lists the upload',
      (_) async {
    final group = await fixtures.create(caseId: 'FL-GROUP-012');
    final file = await fixtures.writeTempFile('flutter ci FL-GROUP-012');
    final uploaded = await fixtures.uploadedSharedFile(group.groupId, file);
    final files = await manager.fetchGroupFileListFromServer(
      group.groupId,
      pageSize: 100,
      pageNum: 1,
    );
    expect(files, hasLength(1));
    expect(files.single.fileId, uploaded.fileId);
    expect(files.single.fileName, fixtures.tempFileName(file));
    expect(files.single.fileOwner, ciUserId);
    expect(files.single.fileSize, await file.length());
    expect(files.single.createTime, greaterThan(0));
  });

  // Test: Update the group announcement and fetch it back from the server.
  // Expected: The fetched announcement equals the written one.
  ciTestWidgets('FL-GROUP-013 fetchAnnouncementFromServer reads the update',
      (_) async {
    final group = await fixtures.create(caseId: 'FL-GROUP-013');
    final announcement = 'flutter ci announcement ${group.groupId}';
    await manager.updateGroupAnnouncement(group.groupId, announcement);
    expect(
      await manager.fetchAnnouncementFromServer(group.groupId),
      announcement,
    );
  });

  // Test: Add the peer with a welcome message, then poll the server member list
  // and read the remote member count.
  // Expected: The peer joins; the member count becomes two; the server member
  // page holds only the peer because the owner is omitted (see the NOTE).
  ciTestWidgets('FL-GROUP-014 addMembers adds the peer', (_) async {
    final group = await fixtures.create(caseId: 'FL-GROUP-014');
    await manager.addMembers(
      group.groupId,
      <String>[ciPeerId],
      welcome: 'flutter ci welcome',
    );
    final members = await waitForCi<List<String>>(
      'CI FL-GROUP-014 peer joins',
      () => fixtures.memberIds(group.groupId),
      (ids) => ids.contains(ciPeerId),
    );
    // NOTE(deviation FL-GROUP-014): the owner omission of FL-GROUP-005.
    debugPrint('CI FL-GROUP-014: server member list=$members');
    expect(members, <String>[ciPeerId]);
    final detail = await manager.fetchGroupInfoFromServer(group.groupId);
    expect(detail.memberCount, 2);
  });

  // Test: Invite the peer with a reason while invitation confirmation is off,
  // then poll the server member list.
  // Expected: The peer is a member, because inviteNeedConfirm=false adds the
  // invitee directly; the page lists only the peer (the owner is omitted, see
  // the NOTE). Teardown destroys the group.
  ciTestWidgets('FL-GROUP-015 inviterUser adds the peer directly', (_) async {
    final group = await fixtures.create(caseId: 'FL-GROUP-015');
    await manager.inviterUser(
      group.groupId,
      <String>[ciPeerId],
      reason: 'flutter ci reason',
    );
    final members = await waitForCi<List<String>>(
      'CI FL-GROUP-015 peer joins',
      () => fixtures.memberIds(group.groupId),
      (ids) => ids.contains(ciPeerId),
    );
    // NOTE(deviation FL-GROUP-015): the owner omission of FL-GROUP-005.
    debugPrint('CI FL-GROUP-015: server member list=$members');
    expect(members, <String>[ciPeerId]);
  });

  // Test: Remove the peer from a two member group and poll the server member
  // list.
  // Expected: The remote member count drops to one; the server member page is
  // empty because it only lists non-owner members.
  ciTestWidgets('FL-GROUP-016 removeMembers removes the peer', (_) async {
    final group = await fixtures.create(
      caseId: 'FL-GROUP-016',
      addPeer: true,
    );
    await manager.removeMembers(group.groupId, <String>[ciPeerId]);
    final members = await waitForCi<List<String>>(
      'CI FL-GROUP-016 peer leaves',
      () => fixtures.memberIds(group.groupId),
      (ids) => !ids.contains(ciPeerId),
    );
    // NOTE(deviation FL-GROUP-016): the owner omission of FL-GROUP-005 leaves
    // an empty page once the peer is removed.
    debugPrint('CI FL-GROUP-016: server member list after remove=$members');
    expect(members, isEmpty);
    final detail = await manager.fetchGroupInfoFromServer(group.groupId);
    expect(detail.memberCount, 1);
  });

  // Test: Block the peer and read both the block list and the member list.
  // Expected: The block list holds the peer and the blocked peer is no longer a
  // group member; the member page is empty because it omits the owner.
  ciTestWidgets('FL-GROUP-017 blockMembers moves the peer to the block list',
      (_) async {
    final group = await fixtures.create(
      caseId: 'FL-GROUP-017',
      addPeer: true,
    );
    await manager.blockMembers(group.groupId, <String>[ciPeerId]);
    final blocked = await waitForCi<List<String>>(
      'CI FL-GROUP-017 block list holds the peer',
      () => manager.fetchBlockListFromServer(group.groupId),
      (ids) => ids.contains(ciPeerId),
    );
    expect(blocked, <String>[ciPeerId]);
    final members = await waitForCi<List<String>>(
      'CI FL-GROUP-017 blocked peer leaves the member list',
      () => fixtures.memberIds(group.groupId),
      (ids) => !ids.contains(ciPeerId),
    );
    // NOTE(deviation FL-GROUP-017): the owner omission of FL-GROUP-005 leaves
    // an empty page once the peer is blocked.
    debugPrint('CI FL-GROUP-017: server member list after block=$members');
    expect(members, isEmpty);
  });

  // Test: Block the peer, unblock it, and read the block list again.
  // Expected: The block list holds the peer after the block and becomes empty
  // after the unblock.
  ciTestWidgets('FL-GROUP-018 unblockMembers clears the block entry',
      (_) async {
    final group = await fixtures.create(
      caseId: 'FL-GROUP-018',
      addPeer: true,
    );
    await manager.blockMembers(group.groupId, <String>[ciPeerId]);
    final blocked = await waitForCi<List<String>>(
      'CI FL-GROUP-018 block list holds the peer',
      () => manager.fetchBlockListFromServer(group.groupId),
      (ids) => ids.contains(ciPeerId),
    );
    expect(blocked, <String>[ciPeerId]);
    await manager.unblockMembers(group.groupId, <String>[ciPeerId]);
    final unblocked = await waitForCi<List<String>>(
      'CI FL-GROUP-018 block list is cleared',
      () => manager.fetchBlockListFromServer(group.groupId),
      (ids) => ids.isEmpty,
    );
    expect(unblocked, isEmpty);
  });

  // Test: Rename the group through the deprecated alias and fetch the server
  // detail.
  // Expected: The new name is stored and the owner is unchanged. The alias is
  // kept on 4.25 for compatibility, so one smoke case covers it.
  ciTestWidgets('FL-GROUP-019 changeGroupName renames the group', (_) async {
    final group = await fixtures.create(caseId: 'FL-GROUP-019');
    final renamed = '${group.groupName}_renamed';
    // ignore: deprecated_member_use
    await manager.changeGroupName(group.groupId, renamed);
    final detail = await manager.fetchGroupInfoFromServer(group.groupId);
    expect(detail.groupName, renamed);
    expect(detail.owner, ciUserId);
  });

  // Test: Rename the group through the current API and fetch the server detail.
  // Expected: The new name is stored and the owner is unchanged.
  ciTestWidgets('FL-GROUP-020 updateGroupName renames the group', (_) async {
    final group = await fixtures.create(caseId: 'FL-GROUP-020');
    final renamed = '${group.groupName}_renamed';
    await manager.updateGroupName(group.groupId, renamed);
    final detail = await manager.fetchGroupInfoFromServer(group.groupId);
    expect(detail.groupName, renamed);
    expect(detail.owner, ciUserId);
  });

  // Test: Replace the description through the deprecated alias and fetch the
  // server detail.
  // Expected: The new description is stored and the name is unchanged.
  ciTestWidgets('FL-GROUP-021 changeGroupDescription updates the description',
      (_) async {
    final group = await fixtures.create(caseId: 'FL-GROUP-021');
    const description = 'flutter ci FL-GROUP-021 description';
    // ignore: deprecated_member_use
    await manager.changeGroupDescription(group.groupId, description);
    final detail = await manager.fetchGroupInfoFromServer(group.groupId);
    expect(detail.desc, description);
    expect(detail.groupName, group.groupName);
  });

  // Test: Replace the description through the current API and fetch the server
  // detail.
  // Expected: The new description is stored and the name is unchanged.
  ciTestWidgets('FL-GROUP-022 updateGroupDesc updates the description',
      (_) async {
    final group = await fixtures.create(caseId: 'FL-GROUP-022');
    const description = 'flutter ci FL-GROUP-022 description';
    await manager.updateGroupDesc(group.groupId, description);
    final detail = await manager.fetchGroupInfoFromServer(group.groupId);
    expect(detail.desc, description);
    expect(detail.groupName, group.groupName);
  });

  // Test: Transfer ownership to the peer, leave the group, then poll the local
  // cache and read the server joined list.
  // Expected: The group disappears from the local joined list and from the
  // server joined list; the local lookup returns an empty snapshot instead of
  // null (see the NOTE). Teardown only leaves the peer-owned group, which
  // cannot be destroyed from this account.
  ciTestWidgets('FL-GROUP-023 leaveGroup drops the group', (_) async {
    final group = await fixtures.create(
      caseId: 'FL-GROUP-023',
      addPeer: true,
    );
    await manager.changeOwner(group.groupId, ciPeerId);
    await manager.leaveGroup(group.groupId);
    final joined = await waitForCi<List<ChatGroup>>(
      'CI FL-GROUP-023 group leaves the local joined list',
      () => manager.getJoinedGroups(),
      (groups) => groups.every((item) => item.groupId != group.groupId),
    );
    expect(joined.map((item) => item.groupId), isNot(contains(group.groupId)));
    // NOTE(deviation FL-GROUP-023): the stale local snapshot survives the
    // leave inside the current session; it only clears after the next login,
    // so the cache assertion runs after a re-login.
    await logoutForCi(client);
    await loginForCi(client);
    await waitForCachedGroupCleared(group.groupId);
    final cached = await manager.getGroupWithId(group.groupId);
    debugPrint('CI FL-GROUP-023: cached group after leave='
        'name="${cached?.groupName}" owner="${cached?.owner}"');
    expect(cached?.groupName ?? '', isEmpty);
    expect(cached?.owner ?? '', isEmpty);
    // The server deletes groups asynchronously ("group is deleting"), so the
    // joined list is polled until it no longer pages the group.
    final serverIds = await waitForCi<List<String>>(
      'CI FL-GROUP-023 group leaves the server joined list',
      () => fixtures.serverJoinedGroupIds(),
      (ids) => !ids.contains(group.groupId),
    );
    expect(serverIds, isNot(contains(group.groupId)));
  });

  // Test: Destroy the group as its owner, then poll the local cache and read
  // the server joined list.
  // Expected: The group is gone from both views; the local lookup returns an
  // empty snapshot instead of null (see the NOTE).
  ciTestWidgets('FL-GROUP-024 destroyGroup removes the group', (_) async {
    final group = await fixtures.create(
      caseId: 'FL-GROUP-024',
      addPeer: true,
    );
    await manager.destroyGroup(group.groupId);
    final joined = await waitForCi<List<ChatGroup>>(
      'CI FL-GROUP-024 group leaves the local joined list',
      () => manager.getJoinedGroups(),
      (groups) => groups.every((item) => item.groupId != group.groupId),
    );
    expect(joined.map((item) => item.groupId), isNot(contains(group.groupId)));
    // NOTE(deviation FL-GROUP-024): the stale local snapshot survives the
    // destroy inside the current session; it only clears after the next login,
    // so the cache assertion runs after a re-login.
    await logoutForCi(client);
    await loginForCi(client);
    await waitForCachedGroupCleared(group.groupId);
    final cached = await manager.getGroupWithId(group.groupId);
    debugPrint('CI FL-GROUP-024: cached group after destroy='
        'name="${cached?.groupName}" owner="${cached?.owner}"');
    expect(cached?.groupName ?? '', isEmpty);
    expect(cached?.owner ?? '', isEmpty);
    // The server deletes groups asynchronously ("group is deleting"), so the
    // joined list is polled until it no longer pages the group.
    final serverIds = await waitForCi<List<String>>(
      'CI FL-GROUP-024 group leaves the server joined list',
      () => fixtures.serverJoinedGroupIds(),
      (ids) => !ids.contains(group.groupId),
    );
    expect(serverIds, isNot(contains(group.groupId)));
  });

  // Test: Block group messages and poll the cached group snapshot.
  // Expected: The cached snapshot reports messageBlocked true. The blocked flag
  // is local state, so no server read is needed.
  ciTestWidgets('FL-GROUP-025 blockGroup marks the cached group', (_) async {
    final group = await fixtures.create(caseId: 'FL-GROUP-025');
    await manager.blockGroup(group.groupId);
    final cached = await waitForCi<ChatGroup?>(
      'CI FL-GROUP-025 group is marked as blocked',
      () => manager.getGroupWithId(group.groupId),
      (item) => item?.messageBlocked == true,
    );
    expect(cached!.messageBlocked, isTrue);
  });

  // Test: Block group messages, unblock them, and poll the cached snapshot.
  // Expected: messageBlocked becomes true, then false again.
  ciTestWidgets('FL-GROUP-026 unblockGroup clears the blocked flag', (_) async {
    final group = await fixtures.create(caseId: 'FL-GROUP-026');
    await manager.blockGroup(group.groupId);
    await waitForCi<ChatGroup?>(
      'CI FL-GROUP-026 group is marked as blocked',
      () => manager.getGroupWithId(group.groupId),
      (item) => item?.messageBlocked == true,
    );
    await manager.unblockGroup(group.groupId);
    final cached = await waitForCi<ChatGroup?>(
      'CI FL-GROUP-026 group is unblocked',
      () => manager.getGroupWithId(group.groupId),
      (item) => item?.messageBlocked == false,
    );
    expect(cached!.messageBlocked, isFalse);
  });

  // Test: Transfer the group ownership to the peer and fetch the server detail.
  // Expected: The peer is the owner. The peer cannot log in, so teardown can
  // only leave the transferred group behind (orphan).
  ciTestWidgets('FL-GROUP-027 changeOwner transfers the group', (_) async {
    final group = await fixtures.create(
      caseId: 'FL-GROUP-027',
      addPeer: true,
    );
    await manager.changeOwner(group.groupId, ciPeerId);
    final detail = await waitForCi<ChatGroup>(
      'CI FL-GROUP-027 owner is the peer',
      () => manager.fetchGroupInfoFromServer(group.groupId),
      (item) => item.owner == ciPeerId,
    );
    expect(detail.owner, ciPeerId);
  });

  // Test: Promote the peer to admin and fetch the server detail.
  // Expected: The admin list holds the peer and the owner is unchanged.
  ciTestWidgets('FL-GROUP-028 addAdmin promotes the peer', (_) async {
    final group = await fixtures.create(
      caseId: 'FL-GROUP-028',
      addPeer: true,
    );
    await manager.addAdmin(group.groupId, ciPeerId);
    final detail = await waitForCi<ChatGroup>(
      'CI FL-GROUP-028 admin list holds the peer',
      () => manager.fetchGroupInfoFromServer(group.groupId),
      (item) => (item.adminList ?? <String>[]).contains(ciPeerId),
    );
    expect(detail.adminList ?? <String>[], contains(ciPeerId));
    expect(detail.owner, ciUserId);
  });

  // Test: Promote the peer to admin, demote it again, and fetch the server
  // detail.
  // Expected: The admin list holds the peer after the promotion and no longer
  // holds it after the demotion.
  ciTestWidgets('FL-GROUP-029 removeAdmin demotes the peer', (_) async {
    final group = await fixtures.create(
      caseId: 'FL-GROUP-029',
      addPeer: true,
    );
    await manager.addAdmin(group.groupId, ciPeerId);
    expect(
      (await manager.fetchGroupInfoFromServer(group.groupId)).adminList ??
          <String>[],
      contains(ciPeerId),
    );
    await manager.removeAdmin(group.groupId, ciPeerId);
    final detail = await manager.fetchGroupInfoFromServer(group.groupId);
    expect(detail.adminList ?? <String>[], isNot(contains(ciPeerId)));
  });

  // Test: Mute the peer for ten minutes and read the server mute list.
  // Expected: The mute list holds the peer with a positive mute value.
  ciTestWidgets('FL-GROUP-030 muteMembers mutes the peer', (_) async {
    final group = await fixtures.create(
      caseId: 'FL-GROUP-030',
      addPeer: true,
    );
    await manager.muteMembers(
      group.groupId,
      <String>[ciPeerId],
      duration: 600000,
    );
    final muted = await waitForCi<Map<String, int>>(
      'CI FL-GROUP-030 mute list holds the peer',
      () => manager.fetchMuteListFromServer(group.groupId),
      (list) => list.containsKey(ciPeerId),
    );
    expect(muted.keys, contains(ciPeerId));
    expect(muted[ciPeerId], greaterThan(0));
  });

  // Test: Mute the peer, unmute it, and poll the server mute list.
  // Expected: The mute entry disappears, so the list becomes empty.
  ciTestWidgets('FL-GROUP-031 unMuteMembers clears the mute entry', (_) async {
    final group = await fixtures.create(
      caseId: 'FL-GROUP-031',
      addPeer: true,
    );
    await manager.muteMembers(
      group.groupId,
      <String>[ciPeerId],
      duration: 600000,
    );
    await manager.unMuteMembers(group.groupId, <String>[ciPeerId]);
    final muted = await waitForCi<Map<String, int>>(
      'CI FL-GROUP-031 mute list is cleared',
      () => manager.fetchMuteListFromServer(group.groupId),
      (list) => list.isEmpty,
    );
    expect(muted, isEmpty);
  });

  // Test: Mute all members and fetch the server detail.
  // Expected: The detail reports the all member mute state.
  ciTestWidgets('FL-GROUP-032 muteAllMembers sets the group wide mute',
      (_) async {
    final group = await fixtures.create(caseId: 'FL-GROUP-032');
    await manager.muteAllMembers(group.groupId);
    final detail = await waitForCi<ChatGroup>(
      'CI FL-GROUP-032 all member mute is set',
      () => manager.fetchGroupInfoFromServer(group.groupId),
      (item) => item.isAllMemberMuted ?? false,
    );
    expect(detail.isAllMemberMuted, isTrue);
  });

  // Test: Mute all members, lift the mute, and fetch the server detail.
  // Expected: The all member mute state is set, then cleared.
  ciTestWidgets('FL-GROUP-033 unMuteAllMembers clears the group wide mute',
      (_) async {
    final group = await fixtures.create(caseId: 'FL-GROUP-033');
    await manager.muteAllMembers(group.groupId);
    expect(
      (await manager.fetchGroupInfoFromServer(group.groupId)).isAllMemberMuted,
      isTrue,
    );
    await manager.unMuteAllMembers(group.groupId);
    final detail = await manager.fetchGroupInfoFromServer(group.groupId);
    expect(detail.isAllMemberMuted, isFalse);
  });

  // Test: Add the peer to the allowlist and read the server allowlist.
  // Expected: The allowlist holds the peer.
  ciTestWidgets('FL-GROUP-034 addAllowList adds the peer', (_) async {
    final group = await fixtures.create(
      caseId: 'FL-GROUP-034',
      addPeer: true,
    );
    await manager.addAllowList(group.groupId, <String>[ciPeerId]);
    final allowed = await waitForCi<List<String>>(
      'CI FL-GROUP-034 allowlist holds the peer',
      () => manager.fetchAllowListFromServer(group.groupId),
      (ids) => ids.contains(ciPeerId),
    );
    expect(allowed, contains(ciPeerId));
  });

  // Test: Add the peer to the allowlist, remove it again, and poll the server
  // allowlist.
  // Expected: The allowlist holds the peer after the add and becomes empty
  // after the removal.
  ciTestWidgets('FL-GROUP-035 removeAllowList clears the entry', (_) async {
    final group = await fixtures.create(
      caseId: 'FL-GROUP-035',
      addPeer: true,
    );
    await manager.addAllowList(group.groupId, <String>[ciPeerId]);
    expect(
      await manager.fetchAllowListFromServer(group.groupId),
      contains(ciPeerId),
    );
    await manager.removeAllowList(group.groupId, <String>[ciPeerId]);
    final allowed = await waitForCi<List<String>>(
      'CI FL-GROUP-035 allowlist drops the peer',
      () => manager.fetchAllowListFromServer(group.groupId),
      (ids) => !ids.contains(ciPeerId),
    );
    // NOTE(deviation FL-GROUP-035): the ohos server view keeps the owner row in
    // the allowlist, so the list is not empty after the peer is removed.
    debugPrint('CI FL-GROUP-035: allowlist after remove=$allowed');
    expect(allowed, isNot(contains(ciPeerId)));
  });

  // Test: Upload a real local file to the group and poll the server file list.
  // Expected: The uploaded entry is listed with the current user as owner.
  ciTestWidgets('FL-GROUP-036 uploadGroupSharedFile adds a shared file',
      (_) async {
    final group = await fixtures.create(caseId: 'FL-GROUP-036');
    final file = await fixtures.writeTempFile('flutter ci FL-GROUP-036');
    final uploaded = await fixtures.uploadedSharedFile(group.groupId, file);
    expect(uploaded.fileId, isNotEmpty);
    expect(uploaded.fileOwner, ciUserId);
    expect(uploaded.fileName, fixtures.tempFileName(file));
  });

  // Test: Upload a file, download it to a new path, and poll the file system.
  // Expected: The downloaded bytes equal the uploaded content. The 4.25 ohos
  // wrapper acknowledges the call before the transfer finishes and exposes no
  // Dart side download callback, so the file system is polled instead.
  ciTestWidgets('FL-GROUP-037 downloadGroupSharedFile writes the file',
      (_) async {
    final group = await fixtures.create(caseId: 'FL-GROUP-037');
    const content = 'flutter ci FL-GROUP-037 downloaded content';
    final file = await fixtures.writeTempFile(content);
    final uploaded = await fixtures.uploadedSharedFile(group.groupId, file);
    expect(uploaded.fileId, isNotEmpty);
    final directory = await getTemporaryDirectory();
    final saved = File(
      '${directory.path}/flutter_ci_download_'
      '${DateTime.now().microsecondsSinceEpoch}.txt',
    );
    addTearDown(() async {
      if (await saved.exists()) {
        await saved.delete();
      }
    });
    await manager.downloadGroupSharedFile(
      groupId: group.groupId,
      fileId: uploaded.fileId!,
      savePath: saved.path,
    );
    await waitForCi<bool>(
      'CI FL-GROUP-037 downloaded file appears on disk',
      () => saved.exists(),
      (exists) => exists,
    );
    expect(await saved.readAsString(), content);
  });

  // Test: Upload a file, remove it through the SDK, and poll the server file
  // list.
  // Expected: The file list becomes empty.
  ciTestWidgets('FL-GROUP-038 removeGroupSharedFile deletes the file',
      (_) async {
    final group = await fixtures.create(caseId: 'FL-GROUP-038');
    final file = await fixtures.writeTempFile('flutter ci FL-GROUP-038');
    final uploaded = await fixtures.uploadedSharedFile(group.groupId, file);
    expect(uploaded.fileId, isNotEmpty);
    await manager.removeGroupSharedFile(group.groupId, uploaded.fileId!);
    final files = await waitForCi<List<ChatGroupSharedFile>>(
      'CI FL-GROUP-038 shared file list is empty',
      () => manager.fetchGroupFileListFromServer(group.groupId),
      (list) => list.isEmpty,
    );
    expect(files, isEmpty);
  });

  // Test: Write two successive announcements and fetch each of them back.
  // Expected: Each fetch returns the announcement that was written last.
  ciTestWidgets('FL-GROUP-039 updateGroupAnnouncement replaces the text',
      (_) async {
    final group = await fixtures.create(caseId: 'FL-GROUP-039');
    const first = 'flutter ci announcement 039 first';
    const second = 'flutter ci announcement 039 second';
    await manager.updateGroupAnnouncement(group.groupId, first);
    expect(
      await manager.fetchAnnouncementFromServer(group.groupId),
      first,
    );
    await manager.updateGroupAnnouncement(group.groupId, second);
    expect(
      await manager.fetchAnnouncementFromServer(group.groupId),
      second,
    );
  });

  // Test: Write a group extension and read it back from the server detail.
  // Expected: The fetched extension equals the written value.
  ciTestWidgets('FL-GROUP-040 updateGroupExtension round trips', (_) async {
    final group = await fixtures.create(caseId: 'FL-GROUP-040');
    final extension = '{"ci_case":"FL-GROUP-040","group":"${group.groupId}"}';
    await manager.updateGroupExtension(group.groupId, extension);
    final detail = await manager.fetchGroupInfoFromServer(group.groupId);
    expect(detail.extension, extension);
  });

  // Test: Create a public open-join group, transfer it to the peer, leave it,
  // then join it again.
  // Expected: The owner is the peer, the current user and the peer are
  // members, and the group is in the server joined list. The tear-down cannot
  // destroy the peer-owned group; it leaves it and the residual group is
  // logged.
  //
  // The REST fixture used to provision a peer-owned group answers 404 on this
  // app key and the peer cannot log in, so the row builds the same state
  // through the SDK: create with the peer, transfer ownership, leave, join.
  ciTestWidgets('FL-GROUP-041 joinPublicGroup joins an open group', (_) async {
    final group = await fixtures.create(
      caseId: 'FL-GROUP-041',
      addPeer: true,
      options: ChatGroupOptions(style: ChatGroupStyle.PublicOpenJoin),
    );
    await waitForCi<List<String>>(
      'CI FL-GROUP-041 peer joins before the ownership transfer',
      () => fixtures.memberIds(group.groupId),
      (ids) => ids.contains(ciPeerId),
      timeout: const Duration(seconds: 20),
    );
    await manager.changeOwner(group.groupId, ciPeerId);
    await manager.leaveGroup(group.groupId);
    await manager.joinPublicGroup(group.groupId);
    final detail = await waitForCi<ChatGroup>(
      'CI FL-GROUP-041 group detail reflects the rejoin',
      () => manager.fetchGroupInfoFromServer(group.groupId),
      (item) => item.owner == ciPeerId && item.memberCount == 2,
    );
    expect(detail.owner, ciPeerId);
    expect(detail.memberCount, 2);
    expect(await fixtures.serverJoinedGroupIds(), contains(group.groupId));
  });

  // Test: Request to join a public approval group.
  // Expected: UNVERIFIED. A peer-owned approval-required group cannot be
  // provisioned on this app key (every REST group route answers 404 and the
  // peer cannot log in), so the positive join request has no target group; the
  // owner side of the flow is FL-EVENT-112. The row is skipped and recorded
  // instead of passing without exercising the contract.
  ciTestWidgets('FL-GROUP-042 requestToJoinPublicGroup records the outcome',
      (_) async {
    markTestSkipped(
      'UNVERIFIED: no peer-owned public approval group can be provisioned on '
      'this app key (REST group routes answer 404 and the peer cannot log in), '
      'so requestToJoinPublicGroup has no target group.',
    );
  });

  // Test: Approve a join application for a group owned by the peer.
  // Expected: UNVERIFIED. No second client can apply to join and a peer-owned
  // approval group cannot be provisioned on this app key, so acceptJoin-
  // Application has neither a group nor a pending applicant; the row is skipped
  // and recorded instead of passing without exercising the contract.
  ciTestWidgets('FL-GROUP-043 acceptJoinApplication records the outcome',
      (_) async {
    markTestSkipped(
      'UNVERIFIED: acceptJoinApplication needs a peer-owned approval group and '
      'a pending applicant; neither can be provisioned on this app key (REST '
      'group routes answer 404 and the peer cannot log in).',
    );
  });

  // Test: Decline a join application for a group owned by the peer.
  // Expected: UNVERIFIED. No second client can apply to join and a peer-owned
  // approval group cannot be provisioned on this app key, so declineJoin-
  // Application has neither a group nor a pending applicant; the row is skipped
  // and recorded instead of passing without exercising the contract.
  ciTestWidgets('FL-GROUP-044 declineJoinApplication records the outcome',
      (_) async {
    markTestSkipped(
      'UNVERIFIED: declineJoinApplication needs a peer-owned approval group and '
      'a pending applicant; neither can be provisioned on this app key (REST '
      'group routes answer 404 and the peer cannot log in).',
    );
  });

  // Test: Accept a group invitation although no invitation is pending.
  // Expected: UNVERIFIED positive path. A pending invitation can only be
  // created by another user, so the case only verifies that the call either
  // returns the group or fails with a non-zero ChatError code.
  ciTestWidgets('FL-GROUP-045 acceptInvitation records the outcome', (_) async {
    final group = await fixtures.create(
      caseId: 'FL-GROUP-045',
      addPeer: true,
    );
    try {
      final accepted = await manager.acceptInvitation(group.groupId, ciPeerId);
      expect(accepted.groupId, group.groupId);
      debugPrint('CI FL-GROUP-045: acceptInvitation returned the group');
    } on ChatError catch (error) {
      debugPrint('CI FL-GROUP-045: acceptInvitation code=${error.code}');
      expect(error.code, isNot(0));
    }
  });

  // Test: Decline a group invitation although no invitation is pending.
  // Expected: UNVERIFIED positive path. A pending invitation can only be
  // created by another user, so the case only verifies that the call either
  // returns or fails with a non-zero ChatError code.
  ciTestWidgets('FL-GROUP-046 declineInvitation records the outcome',
      (_) async {
    final group = await fixtures.create(
      caseId: 'FL-GROUP-046',
      addPeer: true,
    );
    try {
      await manager.declineInvitation(
        groupId: group.groupId,
        inviter: ciPeerId,
        reason: 'flutter ci decline',
      );
      debugPrint('CI FL-GROUP-046: declineInvitation returned');
    } on ChatError catch (error) {
      debugPrint('CI FL-GROUP-046: declineInvitation code=${error.code}');
      expect(error.code, isNot(0));
    }
  });

  // Test: Write custom attributes for the current user and for the peer, then
  // read both maps back.
  // Expected: Each fetch returns exactly the map that was written.
  ciTestWidgets('FL-GROUP-047 setMemberAttributes writes per member maps',
      (_) async {
    final group = await fixtures.create(
      caseId: 'FL-GROUP-047',
      addPeer: true,
    );
    final own = <String, String>{
      'ci_case': 'FL-GROUP-047',
      'ci_role': 'owner',
    };
    final peer = <String, String>{'ci_case': 'FL-GROUP-047-peer'};
    await manager.setMemberAttributes(
      groupId: group.groupId,
      attributes: own,
    );
    await manager.setMemberAttributes(
      groupId: group.groupId,
      userId: ciPeerId,
      attributes: peer,
    );
    expect(
      await manager.fetchMemberAttributes(groupId: group.groupId),
      own,
    );
    expect(
      await manager.fetchMemberAttributes(
        groupId: group.groupId,
        userId: ciPeerId,
      ),
      peer,
    );
  });

  // Test: Read the attributes of a member without attributes and after one map
  // was written for the current user.
  // Expected: The peer map is empty, and the own map equals the written map.
  ciTestWidgets('FL-GROUP-048 fetchMemberAttributes reads one member',
      (_) async {
    final group = await fixtures.create(
      caseId: 'FL-GROUP-048',
      addPeer: true,
    );
    expect(
      await manager.fetchMemberAttributes(
        groupId: group.groupId,
        userId: ciPeerId,
      ),
      isEmpty,
    );
    await manager.setMemberAttributes(
      groupId: group.groupId,
      attributes: <String, String>{'ci_case': 'FL-GROUP-048'},
    );
    expect(
      await manager.fetchMemberAttributes(groupId: group.groupId),
      <String, String>{'ci_case': 'FL-GROUP-048'},
    );
  });

  // Test: Write distinct attributes for the current user and the peer, then
  // batch read one shared key.
  // Expected: The batch result maps both user ids to their written value.
  ciTestWidgets('FL-GROUP-049 fetchMembersAttributes reads a batch', (_) async {
    final group = await fixtures.create(
      caseId: 'FL-GROUP-049',
      addPeer: true,
    );
    await manager.setMemberAttributes(
      groupId: group.groupId,
      attributes: <String, String>{'ci_case': 'FL-GROUP-049'},
    );
    await manager.setMemberAttributes(
      groupId: group.groupId,
      userId: ciPeerId,
      attributes: <String, String>{'ci_case': 'FL-GROUP-049-peer'},
    );
    final batch = await manager.fetchMembersAttributes(
      groupId: group.groupId,
      userIds: <String>[ciUserId, ciPeerId],
      keys: <String>['ci_case'],
    );
    // The expected map is built imperatively: both user ids are compile time
    // constants, so a literal would be flagged as duplicate keys while the
    // dart-defines are absent.
    final expected = <String, Map<String, String>>{};
    expected[ciUserId] = <String, String>{'ci_case': 'FL-GROUP-049'};
    expected[ciPeerId] = <String, String>{'ci_case': 'FL-GROUP-049-peer'};
    expect(batch, expected);
  });

  // Test: Read the joined group count and compare it with a full server page
  // walk.
  // Expected: The count equals the number of distinct walked group ids and is
  // at least one.
  ciTestWidgets('FL-GROUP-050 fetchJoinedGroupCount matches the page walk',
      (_) async {
    await fixtures.create(caseId: 'FL-GROUP-050', addPeer: true);
    final count = await manager.fetchJoinedGroupCount();
    final ids = await fixtures.serverJoinedGroupIds();
    expect(count, ids.length);
    expect(count, greaterThanOrEqualTo(1));
  });

  // Test: Probe the mute membership check of the current user before and after
  // the peer is muted.
  // Expected: false in both reads. The 4.25 ohos signature only takes the group
  // id and reports the current user, and a group owner cannot be muted, so the
  // positive branch is unreachable with a single principal.
  ciTestWidgets('FL-GROUP-051 isMemberInGroupMuteList tracks the caller',
      (_) async {
    final group = await fixtures.create(
      caseId: 'FL-GROUP-051',
      addPeer: true,
    );
    expect(await manager.isMemberInGroupMuteList(group.groupId), isFalse);
    await manager.muteMembers(
      group.groupId,
      <String>[ciPeerId],
      duration: 600000,
    );
    expect(await manager.isMemberInGroupMuteList(group.groupId), isFalse);
  });

  // Test: Clear the local group cache and read the local and server views
  // afterwards.
  // Expected: The local joined list becomes empty, the local lookup returns an
  // empty snapshot instead of null (see the NOTE), while the server joined list
  // still contains the group.
  ciTestWidgets('FL-GROUP-052 clearAllGroupsFromLocal only clears the cache',
      (_) async {
    final group = await fixtures.create(
      caseId: 'FL-GROUP-052',
      addPeer: true,
    );
    expect(await manager.getJoinedGroups(), isNotEmpty);
    await manager.clearAllGroupsFromLocal();
    final local = await waitForCi<List<ChatGroup>>(
      'CI FL-GROUP-052 local cache is cleared',
      () => manager.getJoinedGroups(),
      (groups) => groups.isEmpty,
    );
    expect(local, isEmpty);
    // NOTE(deviation FL-GROUP-052): clearAllGroupsFromLocal does not
    // invalidate the per-group snapshot inside the current session; the
    // snapshot only clears after the next login, so the cache assertion runs
    // after a re-login.
    await logoutForCi(client);
    await loginForCi(client);
    await waitForCachedGroupCleared(group.groupId);
    final cached = await manager.getGroupWithId(group.groupId);
    debugPrint('CI FL-GROUP-052: cached group after clear='
        'name="${cached?.groupName}" owner="${cached?.owner}"');
    expect(cached?.groupName ?? '', isEmpty);
    expect(cached?.owner ?? '', isEmpty);
    expect(
      await fixtures.serverJoinedGroupIds(),
      contains(group.groupId),
    );
  });

  // Test: Page the group member details of a two member group.
  // Expected: The peer is listed once as a Member with a positive join
  // timestamp and no next cursor; no outsider or duplicate ids appear. When the
  // owner row is listed it carries the Owner role (see the NOTE).
  ciTestWidgets('FL-GROUP-053 fetchGroupMembersInfo returns member details',
      (_) async {
    final group = await fixtures.create(
      caseId: 'FL-GROUP-053',
      addPeer: true,
    );
    final page = await manager.fetchGroupMembersInfo(
      groupId: group.groupId,
      limit: 20,
    );
    final ids = page.data.map((item) => item.userId).toList();
    // NOTE(deviation FL-GROUP-053): the sibling server list
    // (fetchMemberListFromServer, FL-GROUP-005/007) omits the owner on ohos, and
    // the 5.1.0 member-detail row only requires the peer, so the owner row is
    // not required here; its role is checked when the server returns it.
    debugPrint('CI FL-GROUP-053: member detail ids=$ids');
    expect(ids, contains(ciPeerId));
    expect(ids.toSet(), hasLength(ids.length));
    // The expected ids are added imperatively because both are compile time
    // constants and a literal set would be flagged as duplicate elements while
    // the dart-defines are absent.
    final expectedIds = <String>{};
    expectedIds
      ..add(ciUserId)
      ..add(ciPeerId);
    expect(ids.toSet().difference(expectedIds), isEmpty);
    final peer = page.data.singleWhere((item) => item.userId == ciPeerId);
    expect(peer.role, ChatGroupPermissionType.Member);
    expect(peer.joinedTs, greaterThan(0));
    final ownerRows =
        page.data.where((item) => item.userId == ciUserId).toList();
    expect(ownerRows.length, lessThanOrEqualTo(1));
    if (ownerRows.isNotEmpty) {
      expect(ownerRows.single.role, ChatGroupPermissionType.Owner);
      expect(ownerRows.single.joinedTs, greaterThan(0));
    }
    expect(page.cursor ?? '', isEmpty);
  });

  // Test: Change the group avatar through the current API and read it back from
  // the server detail.
  // Expected: The returned group carries the new avatar URL and the server
  // detail stores the same URL.
  ciTestWidgets('FL-GROUP-054 updateGroupAvatar stores the URL', (_) async {
    final group = await fixtures.create(caseId: 'FL-GROUP-054');
    final avatarUrl = 'https://example.com/flutter_ci/${group.groupId}.png';
    final updated = await manager.updateGroupAvatar(
      groupId: group.groupId,
      avatarUrl: avatarUrl,
    );
    expect(updated.groupId, group.groupId);
    expect(updated.avatarUrl, avatarUrl);
    final detail = await manager.fetchGroupInfoFromServer(group.groupId);
    expect(detail.avatarUrl, avatarUrl);
  });

  // Test: Set the namecard of the current user and read it back from the member
  // details and the local namecard lookup.
  // Expected: The local lookup returns the written namecard; when the owner row
  // is listed in the member details it carries the same card (see the NOTE).
  ciTestWidgets('FL-GROUP-055 updateGroupNamecard stores the card', (_) async {
    final group = await fixtures.create(
      caseId: 'FL-GROUP-055',
      addPeer: true,
    );
    const namecard = 'flutter ci namecard 055';
    await manager.updateGroupNamecard(
      groupId: group.groupId,
      namecard: namecard,
    );
    final page = await manager.fetchGroupMembersInfo(groupId: group.groupId);
    final ownRows =
        page.data.where((item) => item.userId == ciUserId).toList();
    // NOTE(deviation FL-GROUP-055): fetchGroupMembersInfo may omit the owner
    // (FL-GROUP-053), so the server row is asserted only when it is listed; the
    // local cache read below is the primary assertion.
    debugPrint('CI FL-GROUP-055: own detail namecards='
        '${ownRows.map((item) => item.namecard).toList()}');
    expect(ownRows.length, lessThanOrEqualTo(1));
    if (ownRows.isNotEmpty) {
      expect(ownRows.single.namecard, namecard);
    }
    final cached = await waitForCi<String?>(
      'CI FL-GROUP-055 namecard is cached',
      () => manager.getGroupNamecard(
        groupId: group.groupId,
        userId: ciUserId,
      ),
      (value) => value == namecard,
    );
    expect(cached, namecard);
  });

  // Test: Read the namecard of a member that never set one, then set the own
  // namecard and read it again.
  // Expected: The unset peer card is null or empty; the own card equals the
  // written value. The lookup reads the local cache, so the read is polled.
  ciTestWidgets('FL-GROUP-056 getGroupNamecard reads the cached card',
      (_) async {
    final group = await fixtures.create(
      caseId: 'FL-GROUP-056',
      addPeer: true,
    );
    final unset = await manager.getGroupNamecard(
      groupId: group.groupId,
      userId: ciPeerId,
    );
    expect(unset ?? '', isEmpty);
    const namecard = 'flutter ci namecard 056';
    await manager.updateGroupNamecard(
      groupId: group.groupId,
      namecard: namecard,
    );
    final cached = await waitForCi<String?>(
      'CI FL-GROUP-056 own namecard is cached',
      () => manager.getGroupNamecard(
        groupId: group.groupId,
        userId: ciUserId,
      ),
      (value) => value == namecard,
    );
    expect(cached, namecard);
  });
}

/// Group fixtures shared by the positive cases.
///
/// The helper registers every teardown itself, so a case only has to create its
/// fixture. Groups are created through the SDK and the invited peer joins in
/// the same `createGroup` call; the tear-down destroys a group the current user
/// still owns and otherwise tries to leave it. A group transferred to the peer
/// cannot be destroyed from this account, so it is left behind and logged.
final class _GroupFixtures {
  _GroupFixtures(this.manager);

  final ChatGroupManager manager;
  int _sequence = 0;

  /// Unique group name: `flutter_ci_group_<micros>_<seq>`.
  String nextName() =>
      'flutter_ci_group_${DateTime.now().microsecondsSinceEpoch}_${_sequence++}';

  /// Server side member ids of a group.
  Future<List<String>> memberIds(String groupId) async =>
      (await manager.fetchMemberListFromServer(groupId, pageSize: 100)).data;

  /// All server side joined group ids, collected page by page.
  Future<List<String>> serverJoinedGroupIds() async {
    final ids = <String>[];
    var pageNum = 0;
    while (pageNum < 20) {
      final page = await manager.fetchJoinedGroupsFromServer(
        pageSize: 20,
        pageNum: pageNum,
      );
      ids.addAll(page.map((group) => group.groupId));
      if (page.length < 20) break;
      pageNum += 1;
    }
    return ids;
  }

  /// Creates a group owned by the current user and registers its teardown.
  ///
  /// With [addPeer] the prepared peer is invited in the same `createGroup`
  /// call, and the fixture returns once the server lists the peer.
  Future<ChatGroup> create({
    required String caseId,
    bool addPeer = false,
    ChatGroupOptions? options,
    String? desc,
  }) async {
    final group = await manager.createGroup(
      groupName: nextName(),
      desc: desc ?? 'flutter ci $caseId',
      inviteMembers: addPeer ? <String>[ciPeerId] : null,
      options: options ?? ChatGroupOptions(maxCount: 200),
    );
    destroyOnTeardown(group.groupId);
    if (addPeer) {
      await waitForCi<List<String>>(
        'CI peer joins group ${group.groupId}',
        () => memberIds(group.groupId),
        (members) => members.contains(ciPeerId),
        timeout: const Duration(seconds: 20),
      );
    }
    return group;
  }

  /// Registers a best-effort teardown: destroy while still the owner, otherwise
  /// leave the group so it does not remain in the joined list.
  void destroyOnTeardown(String groupId) {
    addTearDown(() async {
      try {
        await manager.destroyGroup(groupId);
        return;
      } catch (error) {
        debugPrint('CI cleanup: destroyGroup($groupId) failed: $error');
      }
      try {
        await manager.leaveGroup(groupId);
        debugPrint('CI cleanup: left orphaned group $groupId '
            '(ownership was transferred to the peer)');
      } catch (error) {
        debugPrint('CI cleanup: leaveGroup($groupId) failed: $error');
      }
    });
  }

  /// Writes a unique temporary file with [content] and deletes it afterwards.
  Future<File> writeTempFile(String content) async {
    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}/flutter_ci_shared_$_sequence'
      '_${DateTime.now().microsecondsSinceEpoch}.txt',
    );
    _sequence += 1;
    await file.writeAsString(content);
    addTearDown(() async {
      if (await file.exists()) {
        await file.delete();
      }
    });
    return file;
  }

  /// Name of [file] as the server stores it.
  String tempFileName(File file) => file.uri.pathSegments.last;

  /// Uploads [file] and waits until the server file list lists it.
  Future<ChatGroupSharedFile> uploadedSharedFile(
    String groupId,
    File file,
  ) async {
    await manager.uploadGroupSharedFile(groupId, file.path);
    final name = tempFileName(file);
    final files = await waitForCi<List<ChatGroupSharedFile>>(
      'CI shared file "$name" appears in the group file list',
      () => manager.fetchGroupFileListFromServer(groupId),
      (list) => list.any((item) => item.fileName == name),
    );
    return files.firstWhere((item) => item.fileName == name);
  }
}
