import {
  ChatClient,
  ChatError,
  CursorResult,
  Group,
  GroupListener,
  GroupManager,
  GroupMember,
  SharedFile,
} from '@easemob/chatsdk';
import { FlutterPluginBinding, MethodCall, MethodResult } from '@ohos/flutter_ohos';
import MethodKey, { ChatGroupChangeEvent } from './MethodKeys';
import Wrapper from './Wrapper';
import ProgressManagerWrapper from './ProgressManagerWrapper';
import SafetyMapTool from './SafetyMapTool';
import ChannelValue from './models/ChannelValue';
import CursorResultHelper from './models/CursorResultHelper';
import GroupHelper from './models/GroupHelper';
import GroupInfoHelper from './models/GroupInfoHelper';
import GroupMemberInfoHelper from './models/GroupMemberInfoHelper';
import GroupOptionsHelper from './models/GroupOptionsHelper';
import MucSharedFileHelper from './models/MucSharedFileHelper';

/**
 * Wrapper for the `com.chat.im/chat_group_manager` channel.
 *
 * Implements the 54 chat_group_manager method keys kept in the ohos-branch
 * Dart constants. `removeMemberAttributesFromGroup` was removed from Dart
 * (gap ledger 02 §17): chatsdk has no member-attribute removal API, so there
 * is no branch for it here.
 *
 * Adaptations (gap ledger 02 §16.1 / §7.1, mirrored from the android
 * GroupManagerWrapper):
 *   - getJoinedGroupsFromServer: the Flutter `needMemberCount`/`needRole`
 *     parameters have no chatsdk counterpart and are ignored on purpose.
 *   - getPublicGroupsFromServer: chatsdk returns full Group objects; they are
 *     trimmed to the lightweight ChatGroupInfo shape via GroupInfoHelper
 *     (§16.1-A#13).
 *   - accept/declineInvitationFromGroup: the Flutter `inviter`/`userId`
 *     parameters have no chatsdk counterpart and are ignored.
 *   - joinPublicGroup: android pre-checks isMemberOnly and fails locally with
 *     error 603; chatsdk Group has no isMemberOnly, so the check is dropped
 *     and the server enforces the group style.
 *   - downloadGroupSharedFile: matches android — the method result returns
 *     immediately and progress/success/error go through the
 *     file_progress_manager channel via ProgressManagerWrapper.
 *
 * The chatsdk GroupListener callbacks are aggregated into the single
 * `onGroupChanged` channel event with a `type` field, mirroring the android
 * event payloads key by key (including the two literal type strings
 * "onGroupMembersJoined"/"onGroupMembersExited" that the Dart side matches
 * as literals).
 *
 * Listener timing: unlike android (registers in the constructor), the chatsdk
 * GroupManager only exists after ChatClient.init, and this channel has no
 * init call. Registration therefore happens lazily on the first method call
 * (any group call implies init already happened), mirroring the ClientWrapper
 * "register after init" semantics.
 */
export default class GroupManagerWrapper extends Wrapper {
  private groupListener: GroupListener | undefined;
  private listenerAttached: boolean = false;

  constructor(binding: FlutterPluginBinding, channelName: string) {
    super(binding, channelName);
  }

  override onMethodCall(call: MethodCall, result: MethodResult): void {
    if (!this.listenerAttached) {
      this.registerEaseListener();
    }
    if (MethodKey.getGroupWithId === call.method) {
      this.getGroupWithId(call, result);
    } else if (MethodKey.getJoinedGroups === call.method) {
      this.getJoinedGroups(call, result);
    } else if (MethodKey.getJoinedGroupsFromServer === call.method) {
      this.getJoinedGroupsFromServer(call, result);
    } else if (MethodKey.getPublicGroupsFromServer === call.method) {
      this.getPublicGroupsFromServer(call, result);
    } else if (MethodKey.createGroup === call.method) {
      this.createGroup(call, result);
    } else if (MethodKey.getGroupSpecificationFromServer === call.method) {
      this.getGroupSpecificationFromServer(call, result);
    } else if (MethodKey.getGroupMemberListFromServer === call.method) {
      this.getGroupMemberListFromServer(call, result);
    } else if (MethodKey.getGroupBlockListFromServer === call.method) {
      this.getGroupBlockListFromServer(call, result);
    } else if (MethodKey.getGroupMuteListFromServer === call.method) {
      this.getGroupMuteListFromServer(call, result);
    } else if (MethodKey.getGroupWhiteListFromServer === call.method) {
      this.getGroupWhiteListFromServer(call, result);
    } else if (MethodKey.isMemberInWhiteListFromServer === call.method) {
      this.isMemberInWhiteListFromServer(call, result);
    } else if (MethodKey.getGroupFileListFromServer === call.method) {
      this.getGroupFileListFromServer(call, result);
    } else if (MethodKey.getGroupAnnouncementFromServer === call.method) {
      this.getGroupAnnouncementFromServer(call, result);
    } else if (MethodKey.addMembers === call.method) {
      this.addMembers(call, result);
    } else if (MethodKey.inviterUser === call.method) {
      this.inviterUser(call, result);
    } else if (MethodKey.removeMembers === call.method) {
      this.removeMembers(call, result);
    } else if (MethodKey.blockMembers === call.method) {
      this.blockMembers(call, result);
    } else if (MethodKey.unblockMembers === call.method) {
      this.unblockMembers(call, result);
    } else if (MethodKey.updateGroupSubject === call.method) {
      this.updateGroupSubject(call, result);
    } else if (MethodKey.updateDescription === call.method) {
      this.updateDescription(call, result);
    } else if (MethodKey.leaveGroup === call.method) {
      this.leaveGroup(call, result);
    } else if (MethodKey.destroyGroup === call.method) {
      this.destroyGroup(call, result);
    } else if (MethodKey.blockGroup === call.method) {
      this.blockGroup(call, result);
    } else if (MethodKey.unblockGroup === call.method) {
      this.unblockGroup(call, result);
    } else if (MethodKey.updateGroupOwner === call.method) {
      this.updateGroupOwner(call, result);
    } else if (MethodKey.addAdmin === call.method) {
      this.addAdmin(call, result);
    } else if (MethodKey.removeAdmin === call.method) {
      this.removeAdmin(call, result);
    } else if (MethodKey.muteMembers === call.method) {
      this.muteMembers(call, result);
    } else if (MethodKey.unMuteMembers === call.method) {
      this.unMuteMembers(call, result);
    } else if (MethodKey.muteAllMembers === call.method) {
      this.muteAllMembers(call, result);
    } else if (MethodKey.unMuteAllMembers === call.method) {
      this.unMuteAllMembers(call, result);
    } else if (MethodKey.addWhiteList === call.method) {
      this.addWhiteList(call, result);
    } else if (MethodKey.removeWhiteList === call.method) {
      this.removeWhiteList(call, result);
    } else if (MethodKey.uploadGroupSharedFile === call.method) {
      this.uploadGroupSharedFile(call, result);
    } else if (MethodKey.downloadGroupSharedFile === call.method) {
      this.downloadGroupSharedFile(call, result);
    } else if (MethodKey.removeGroupSharedFile === call.method) {
      this.removeGroupSharedFile(call, result);
    } else if (MethodKey.updateGroupAnnouncement === call.method) {
      this.updateGroupAnnouncement(call, result);
    } else if (MethodKey.updateGroupExt === call.method) {
      this.updateGroupExt(call, result);
    } else if (MethodKey.joinPublicGroup === call.method) {
      this.joinPublicGroup(call, result);
    } else if (MethodKey.requestToJoinPublicGroup === call.method) {
      this.requestToJoinPublicGroup(call, result);
    } else if (MethodKey.acceptJoinApplication === call.method) {
      this.acceptJoinApplication(call, result);
    } else if (MethodKey.declineJoinApplication === call.method) {
      this.declineJoinApplication(call, result);
    } else if (MethodKey.acceptInvitationFromGroup === call.method) {
      this.acceptInvitationFromGroup(call, result);
    } else if (MethodKey.declineInvitationFromGroup === call.method) {
      this.declineInvitationFromGroup(call, result);
    } else if (MethodKey.setMemberAttributesFromGroup === call.method) {
      this.setMemberAttributes(call, result);
    } else if (MethodKey.fetchMemberAttributesFromGroup === call.method) {
      this.fetchMemberAttributes(call, result);
    } else if (MethodKey.fetchMembersAttributesFromGroup === call.method) {
      this.fetchMembersAttributes(call, result);
    } else if (MethodKey.fetchJoinedGroupCount === call.method) {
      this.fetchJoinedGroupCount(call, result);
    } else if (MethodKey.clearAllGroupsFromDB === call.method) {
      this.clearAllGroupsFromDB(call, result);
    } else if (MethodKey.isMemberInGroupMuteList === call.method) {
      this.isMemberInGroupMuteList(call, result);
    } else if (MethodKey.fetchGroupMembersInfo === call.method) {
      this.fetchGroupMembersInfo(call, result);
    } else if (MethodKey.updateGroupAvatar === call.method) {
      this.updateGroupAvatar(call, result);
    } else if (MethodKey.updateGroupNamecard === call.method) {
      this.updateGroupNamecard(call, result);
    } else if (MethodKey.getGroupNamecard === call.method) {
      this.getGroupNamecard(call, result);
    } else {
      super.onMethodCall(call, result);
    }
  }

  private groupManager(result: MethodResult, method: string): GroupManager | undefined {
    let manager = ChatClient.getInstance().groupManager();
    if (manager === undefined) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR,
        `${method} failed: GroupManager unavailable, SDK not initialized`);
      return undefined;
    }
    return manager;
  }

  private getGroupWithId(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    let group = manager.getGroup(groupId);
    // chatsdk returns an empty shell Group for an unknown id instead of
    // undefined; treat a missing/empty group id or name as "no group" so the
    // Dart getGroupWithId contract (null) is preserved.
    let resolvedId = group === undefined ? '' : (group.groupId() ?? '');
    let resolvedName = group === undefined ? '' : (group.groupName() ?? '');
    if (group === undefined || resolvedId.length === 0 || resolvedName.length === 0) {
      this.onSuccess(result, call.method);
    } else {
      this.onSuccess(result, call.method, GroupHelper.toJson(group));
    }
  }

  private getJoinedGroups(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    this.handlePromise(result, call.method, manager.getAllGroups(),
      (groups: Array<Group>) => GroupHelper.listToJson(groups));
  }

  private getJoinedGroupsFromServer(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let pageNum = SafetyMapTool.getNumber(call.args, 'pageNum', 0) ?? 0;
    let pageSize = SafetyMapTool.getNumber(call.args, 'pageSize', 20) ?? 20;
    // The Flutter needMemberCount/needRole parameters have no chatsdk
    // counterpart and are intentionally not read (gap ledger 02 §16.1-A#12).
    this.handlePromise(result, call.method, manager.fetchJoinedGroupsFromServer(pageNum, pageSize),
      (groups: Array<Group>) => GroupHelper.listToJson(groups));
  }

  private getPublicGroupsFromServer(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let pageSize = SafetyMapTool.getNumber(call.args, 'pageSize', 200) ?? 200;
    let cursor = SafetyMapTool.getString(call.args, 'cursor');
    this.handlePromise(result, call.method, manager.fetchPublicGroupsFromServer(pageSize, cursor),
      (value: CursorResult<Group>) => CursorResultHelper.toJson<Group>(value,
        (group: Group) => GroupInfoHelper.toJson(group)));
  }

  private createGroup(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    // android passes name/avatar/desc/members/reason as separate arguments;
    // chatsdk takes them all inside GroupOptions.
    let options = GroupOptionsHelper.fromJson(ChannelValue.read(call.args, 'options'));
    options.groupName = SafetyMapTool.getString(call.args, 'groupName');
    options.avatar = SafetyMapTool.getString(call.args, 'avatarUrl');
    options.desc = SafetyMapTool.getString(call.args, 'desc');
    options.members = SafetyMapTool.getStringArray(call.args, 'inviteMembers');
    options.reason = SafetyMapTool.getString(call.args, 'inviteReason');
    this.handlePromise(result, call.method, manager.createGroup(options),
      (group: Group) => GroupHelper.toJson(group));
  }

  private getGroupSpecificationFromServer(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    // The Flutter fetchMembers parameter is Deprecated and has no chatsdk
    // counterpart; chatsdk fetchGroupFromServer never returns members.
    this.handlePromise(result, call.method, manager.fetchGroupFromServer(groupId),
      (group: Group) => GroupHelper.toJson(group));
  }

  private getGroupMemberListFromServer(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    let pageSize = SafetyMapTool.getNumber(call.args, 'pageSize', 200) ?? 200;
    let cursor = SafetyMapTool.getString(call.args, 'cursor');
    if (cursor !== undefined && cursor.length > 0) {
      // Only the first page gets the owner prepended (see memberListJson), so
      // later pages keep the chatsdk order and cursor untouched.
      this.handlePromise(result, call.method, manager.fetchGroupMembers(groupId, pageSize, cursor),
        (value: CursorResult<string>) => CursorResultHelper.toJson<string>(value, (s: string) => s));
      return;
    }
    // The page and the owner resolve in parallel; the owner only affects how
    // the resolved page is serialized.
    let page: Promise<CursorResult<string>> = manager.fetchGroupMembers(groupId, pageSize, cursor);
    this.resolveGroupOwner(manager, groupId).then((owner: string) => {
      this.handlePromise(result, call.method, page,
        (value: CursorResult<string>) => this.memberListJson(value, owner));
    });
  }

  /**
   * Resolves the group owner id: the local snapshot first (create/fetch cache
   * it), the server detail as the fallback. An unresolvable owner resolves to ''
   * so the member page is returned unchanged instead of failing the call.
   */
  private resolveGroupOwner(manager: GroupManager, groupId: string): Promise<string> {
    let cached = manager.getGroup(groupId);
    let cachedOwner = cached === undefined ? '' : cached.owner();
    if (cachedOwner.length > 0) {
      return Promise.resolve(cachedOwner);
    }
    return manager.fetchGroupFromServer(groupId)
      .then((group: Group) => group.owner())
      .catch((): string => '');
  }

  /**
   * Serializes one server member page and restores the owner id on the first
   * page.
   *
   * chatsdk `fetchGroupMembers` leaves the group owner out of the page (a two
   * member group only lists the peer while `membersCount()` reports 2), while
   * android/iOS return the owner as a regular member; `fetchMemberListFromServer`
   * is documented to list every member, so the owner is prepended when the page
   * does not hold it yet.
   *
   * The keys match CursorResultHelper.toJson; the list is rebuilt because the
   * owner has to be inserted before the chatsdk items.
   */
  private memberListJson(value: CursorResult<string>, owner: string): Map<string, Object> {
    let ids = value.getResult();
    let list = new Array<string>();
    if (owner.length > 0 && ids.indexOf(owner) < 0) {
      list.push(owner);
    }
    for (let id of ids) {
      list.push(id);
    }
    let data = new Map<string, Object>();
    data.set('cursor', value.getNextCursor());
    data.set('list', list);
    return data;
  }

  private getGroupBlockListFromServer(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    let pageNum = SafetyMapTool.getNumber(call.args, 'pageNum', 1) ?? 1;
    let pageSize = SafetyMapTool.getNumber(call.args, 'pageSize', 200) ?? 200;
    this.handlePromise(result, call.method, manager.fetchGroupBlocklist(groupId, pageNum, pageSize),
      (list: Array<string>) => list as Object);
  }

  private getGroupMuteListFromServer(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    let pageNum = SafetyMapTool.getNumber(call.args, 'pageNum', 1) ?? 1;
    let pageSize = SafetyMapTool.getNumber(call.args, 'pageSize', 200) ?? 200;
    this.handlePromise(result, call.method, manager.fetchGroupMutelist(groupId, pageNum, pageSize),
      (map: Map<string, number>) => map as Object);
  }

  private getGroupWhiteListFromServer(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    this.handlePromise(result, call.method, manager.fetchGroupWhitelist(groupId),
      (list: Array<string>) => list as Object);
  }

  private isMemberInWhiteListFromServer(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    this.handlePromise(result, call.method, manager.checkIfInGroupWhitelist(groupId));
  }

  private getGroupFileListFromServer(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    let pageNum = SafetyMapTool.getNumber(call.args, 'pageNum', 1) ?? 1;
    let pageSize = SafetyMapTool.getNumber(call.args, 'pageSize', 200) ?? 200;
    this.handlePromise(result, call.method, manager.fetchGroupSharedFileList(groupId, pageNum, pageSize),
      (files: Array<SharedFile>) => MucSharedFileHelper.listToJson(files));
  }

  private getGroupAnnouncementFromServer(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    this.handlePromise(result, call.method, manager.fetchGroupAnnouncement(groupId));
  }

  private addMembers(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    let members = SafetyMapTool.getStringArray(call.args, 'members') ?? [];
    let welcome = SafetyMapTool.getString(call.args, 'welcome');
    this.handlePromise(result, call.method, manager.addUsersToGroup(groupId, members, welcome), () => true);
  }

  private inviterUser(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    let members = SafetyMapTool.getStringArray(call.args, 'members') ?? [];
    let reason = SafetyMapTool.getString(call.args, 'reason');
    this.handlePromise(result, call.method, manager.inviteUsers(groupId, members, reason), () => true);
  }

  private removeMembers(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    let members = SafetyMapTool.getStringArray(call.args, 'members') ?? [];
    this.handlePromise(result, call.method, manager.removeUsersFromGroup(groupId, members), () => true);
  }

  private blockMembers(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    let members = SafetyMapTool.getStringArray(call.args, 'members') ?? [];
    this.handlePromise(result, call.method, manager.blockUsers(groupId, members), () => true);
  }

  private unblockMembers(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    let members = SafetyMapTool.getStringArray(call.args, 'members') ?? [];
    this.handlePromise(result, call.method, manager.unblockUsers(groupId, members), () => true);
  }

  private updateGroupSubject(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    let name = SafetyMapTool.getString(call.args, 'name', '') ?? '';
    this.handlePromise(result, call.method, manager.changeGroupName(groupId, name));
  }

  private updateDescription(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    let desc = SafetyMapTool.getString(call.args, 'desc', '') ?? '';
    this.handlePromise(result, call.method, manager.changeGroupDescription(groupId, desc));
  }

  private leaveGroup(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    this.handlePromise(result, call.method, manager.leaveGroup(groupId), () => true);
  }

  private destroyGroup(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    this.handlePromise(result, call.method, manager.destroyGroup(groupId), () => true);
  }

  private blockGroup(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    this.handlePromise(result, call.method, manager.blockGroupMessage(groupId));
  }

  private unblockGroup(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    this.handlePromise(result, call.method, manager.unblockGroupMessage(groupId));
  }

  private updateGroupOwner(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    let owner = SafetyMapTool.getString(call.args, 'owner', '') ?? '';
    this.handlePromise(result, call.method, manager.changeOwner(groupId, owner),
      (group: Group) => GroupHelper.toJson(group));
  }

  private addAdmin(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    let admin = SafetyMapTool.getString(call.args, 'admin', '') ?? '';
    this.handlePromise(result, call.method, manager.addGroupAdmin(groupId, admin),
      (group: Group) => GroupHelper.toJson(group));
  }

  private removeAdmin(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    let admin = SafetyMapTool.getString(call.args, 'admin', '') ?? '';
    this.handlePromise(result, call.method, manager.removeGroupAdmin(groupId, admin),
      (group: Group) => GroupHelper.toJson(group));
  }

  private muteMembers(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    let members = SafetyMapTool.getStringArray(call.args, 'members') ?? [];
    let duration = SafetyMapTool.getNumber(call.args, 'duration', -1) ?? -1;
    this.handlePromise(result, call.method, manager.muteGroupMembers(groupId, members, duration),
      (group: Group) => GroupHelper.toJson(group));
  }

  private unMuteMembers(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    let members = SafetyMapTool.getStringArray(call.args, 'members') ?? [];
    this.handlePromise(result, call.method, manager.unmuteGroupMembers(groupId, members),
      (group: Group) => GroupHelper.toJson(group));
  }

  private muteAllMembers(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    this.handlePromise(result, call.method, manager.muteAllMembers(groupId),
      (group: Group) => GroupHelper.toJson(group));
  }

  private unMuteAllMembers(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    this.handlePromise(result, call.method, manager.unmuteAllMembers(groupId),
      (group: Group) => GroupHelper.toJson(group));
  }

  private addWhiteList(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    let members = SafetyMapTool.getStringArray(call.args, 'members') ?? [];
    this.handlePromise(result, call.method, manager.addToGroupWhitelist(groupId, members), () => true);
  }

  private removeWhiteList(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    let members = SafetyMapTool.getStringArray(call.args, 'members') ?? [];
    this.handlePromise(result, call.method, manager.removeFromGroupWhitelist(groupId, members), () => true);
  }

  private uploadGroupSharedFile(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    let filePath = SafetyMapTool.getString(call.args, 'filePath', '') ?? '';
    this.handlePromise(result, call.method, manager.uploadGroupSharedFile(groupId, filePath), () => true);
  }

  private downloadGroupSharedFile(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    let fileId = SafetyMapTool.getString(call.args, 'fileId', '') ?? '';
    let savePath = SafetyMapTool.getString(call.args, 'savePath', '') ?? '';
    // Same contract as android: the method result returns immediately and the
    // outcome is reported through the file_progress_manager channel events.
    let pm = ProgressManagerWrapper.getInstance();
    manager.downloadGroupSharedFile(groupId, fileId, savePath, {
      onProgress: (progress: number): void => {
        pm?.sendDownloadProgressToFlutter(fileId, progress);
      }
    }).then((): void => {
      pm?.sendDownloadSuccessToFlutter(fileId, savePath);
    }).catch((e: ChatError): void => {
      if (e !== undefined) {
        pm?.sendDownloadErrorToFlutter(fileId, e);
      }
    });
    this.onSuccess(result, call.method, true);
  }

  private removeGroupSharedFile(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    let fileId = SafetyMapTool.getString(call.args, 'fileId', '') ?? '';
    this.handlePromise(result, call.method, manager.deleteGroupSharedFile(groupId, fileId), () => true);
  }

  private updateGroupAnnouncement(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    let announcement = SafetyMapTool.getString(call.args, 'announcement', '') ?? '';
    this.handlePromise(result, call.method, manager.updateGroupAnnouncement(groupId, announcement));
  }

  private updateGroupExt(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    let ext = SafetyMapTool.getString(call.args, 'ext', '') ?? '';
    this.handlePromise(result, call.method, manager.updateGroupExtension(groupId, ext),
      (group: Group) => GroupHelper.toJson(group));
  }

  private joinPublicGroup(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    // android pre-checks isMemberOnly and fails locally with error 603;
    // chatsdk Group has no isMemberOnly, so the server enforces the style.
    this.handlePromise(result, call.method, manager.joinGroup(groupId));
  }

  private requestToJoinPublicGroup(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    let reason = SafetyMapTool.getString(call.args, 'reason');
    this.handlePromise(result, call.method, manager.applyJoinToGroup(groupId, reason));
  }

  private acceptJoinApplication(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    let userId = SafetyMapTool.getString(call.args, 'userId', '') ?? '';
    this.handlePromise(result, call.method, manager.acceptApplication(groupId, userId));
  }

  private declineJoinApplication(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    let userId = SafetyMapTool.getString(call.args, 'userId', '') ?? '';
    let reason = SafetyMapTool.getString(call.args, 'reason');
    this.handlePromise(result, call.method, manager.declineApplication(groupId, userId, reason));
  }

  private acceptInvitationFromGroup(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    // The Flutter inviter parameter has no chatsdk counterpart (gap ledger 02 §7.1).
    this.handlePromise(result, call.method, manager.acceptInvitation(groupId),
      (group: Group) => GroupHelper.toJson(group));
  }

  private declineInvitationFromGroup(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    let reason = SafetyMapTool.getString(call.args, 'reason');
    // The Flutter inviter parameter has no chatsdk counterpart (gap ledger 02 §7.1).
    this.handlePromise(result, call.method, manager.declineInvitation(groupId, reason));
  }

  private setMemberAttributes(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    let userId = SafetyMapTool.getString(call.args, 'userId') ?? ChatClient.getInstance().getCurrentUser();
    let attributes = new Map<string, string>();
    let raw = ChannelValue.read(call.args, 'attributes');
    if (raw instanceof Map) {
      let rawMap = raw as Map<string, Object>;
      rawMap.forEach((value: Object, key: string) => {
        if (typeof value === 'string') {
          attributes.set(key, value as string);
        }
      });
    } else if (ChannelValue.isPlainObject(raw)) {
      let record = raw as Record<string, Object>;
      for (let key of Object.keys(record)) {
        let value = record[key];
        if (typeof value === 'string') {
          attributes.set(key, value as string);
        }
      }
    }
    this.handlePromise(result, call.method, manager.setMemberAttributes(groupId, userId, attributes));
  }

  private fetchMemberAttributes(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    let userId = SafetyMapTool.getString(call.args, 'userId') ?? ChatClient.getInstance().getCurrentUser();
    this.handlePromise(result, call.method, manager.fetchMemberAttributes(groupId, userId),
      (map: Map<string, string>) => map as Object);
  }

  private fetchMembersAttributes(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    let userIds = SafetyMapTool.getStringArray(call.args, 'userIds') ?? [];
    let keys = SafetyMapTool.getStringArray(call.args, 'keys');
    this.handlePromise(result, call.method, manager.fetchMembersAttributes(groupId, userIds, keys),
      (map: Map<string, Map<string, string>>) => map as Object);
  }

  private fetchJoinedGroupCount(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    this.handlePromise(result, call.method, manager.fetchJoinedGroupsCount());
  }

  private clearAllGroupsFromDB(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    manager.clearAllLocalGroups();
    this.onSuccess(result, call.method);
  }

  private isMemberInGroupMuteList(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    this.handlePromise(result, call.method, manager.checkIfInGroupMutelist(groupId));
  }

  private fetchGroupMembersInfo(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    let limit = SafetyMapTool.getNumber(call.args, 'limit', 20) ?? 20;
    let cursor = SafetyMapTool.getString(call.args, 'cursor');
    this.handlePromise(result, call.method, manager.fetchGroupMemberDetails(groupId, limit, cursor),
      (value: CursorResult<GroupMember>) => CursorResultHelper.toJson<GroupMember>(value,
        (member: GroupMember) => GroupMemberInfoHelper.toJson(member)));
  }

  private updateGroupAvatar(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    let avatarUrl = SafetyMapTool.getString(call.args, 'avatarUrl', '') ?? '';
    this.handlePromise(result, call.method, manager.changeGroupAvatar(groupId, avatarUrl),
      (group: Group) => GroupHelper.toJson(group));
  }

  private updateGroupNamecard(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    // Dart passes null to remove the namecard; chatsdk requires a string, so
    // an absent value is sent as an empty string.
    let namecard = SafetyMapTool.getString(call.args, 'namecard') ?? '';
    this.handlePromise(result, call.method, manager.updateGroupNamecard(groupId, namecard));
  }

  private getGroupNamecard(call: MethodCall, result: MethodResult): void {
    let manager = this.groupManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let groupId = SafetyMapTool.getString(call.args, 'groupId', '') ?? '';
    let userId = SafetyMapTool.getString(call.args, 'userId', '') ?? '';
    // chatsdk getGroupNamecard is a synchronous local-cache read.
    let data = new Map<string, Object>();
    data.set('namecard', manager.getGroupNamecard(groupId, userId));
    this.onSuccess(result, call.method, data);
  }

  override registerEaseListener(): void {
    let manager = ChatClient.getInstance().groupManager();
    if (manager === undefined) {
      // SDK not initialized yet; retried lazily on the next method call.
      return;
    }
    if (this.groupListener !== undefined) {
      manager.removeListener(this.groupListener);
    }
    this.groupListener = {
      onInvitationReceived: (groupId: string, groupName: string, inviter: string, reason: string): void => {
        let data = new Map<string, Object>();
        data.set('type', ChatGroupChangeEvent.ON_INVITATION_RECEIVED);
        data.set('groupId', groupId);
        data.set('groupName', groupName);
        data.set('inviter', inviter);
        data.set('reason', reason);
        this.emitEvent(MethodKey.onGroupChanged, data);
      },
      onInvitationAccepted: (groupId: string, invitee: string, reason: string): void => {
        let data = new Map<string, Object>();
        data.set('type', ChatGroupChangeEvent.ON_INVITATION_ACCEPTED);
        data.set('groupId', groupId);
        data.set('invitee', invitee);
        data.set('reason', reason);
        this.emitEvent(MethodKey.onGroupChanged, data);
      },
      onInvitationDeclined: (groupId: string, invitee: string, reason: string): void => {
        let data = new Map<string, Object>();
        data.set('type', ChatGroupChangeEvent.ON_INVITATION_DECLINED);
        data.set('groupId', groupId);
        data.set('invitee', invitee);
        data.set('reason', reason);
        this.emitEvent(MethodKey.onGroupChanged, data);
      },
      onAutoAcceptInvitationFromGroup: (groupId: string, inviter: string, inviteMessage: string): void => {
        let data = new Map<string, Object>();
        data.set('type', ChatGroupChangeEvent.ON_AUTO_ACCEPT_INVITATION);
        data.set('groupId', groupId);
        data.set('inviter', inviter);
        data.set('inviteMessage', inviteMessage);
        this.emitEvent(MethodKey.onGroupChanged, data);
      },
      onUserRemoved: (groupId: string, groupName: string): void => {
        let data = new Map<string, Object>();
        data.set('type', ChatGroupChangeEvent.ON_USER_REMOVED);
        data.set('groupId', groupId);
        data.set('groupName', groupName);
        this.emitEvent(MethodKey.onGroupChanged, data);
      },
      onRequestToJoinReceived: (groupId: string, groupName: string, applicant: string, reason: string): void => {
        let data = new Map<string, Object>();
        data.set('type', ChatGroupChangeEvent.ON_REQUEST_TO_JOIN_RECEIVED);
        data.set('groupId', groupId);
        data.set('groupName', groupName);
        data.set('applicant', applicant);
        data.set('reason', reason);
        this.emitEvent(MethodKey.onGroupChanged, data);
      },
      // chatsdk parameter order is (groupId, groupName, decliner, applicant,
      // reason); the payload keys mirror android, which omits groupName.
      onRequestToJoinDeclined: (groupId: string, groupName: string, decliner: string, applicant: string,
        reason: string): void => {
        let data = new Map<string, Object>();
        data.set('type', ChatGroupChangeEvent.ON_REQUEST_TO_JOIN_DECLINED);
        data.set('groupId', groupId);
        data.set('applicant', applicant);
        data.set('decliner', decliner);
        data.set('reason', reason);
        this.emitEvent(MethodKey.onGroupChanged, data);
      },
      onRequestToJoinAccepted: (groupId: string, groupName: string, accepter: string): void => {
        let data = new Map<string, Object>();
        data.set('type', ChatGroupChangeEvent.ON_REQUEST_TO_JOIN_ACCEPTED);
        data.set('groupId', groupId);
        data.set('groupName', groupName);
        data.set('accepter', accepter);
        this.emitEvent(MethodKey.onGroupChanged, data);
      },
      onGroupDestroyed: (groupId: string, groupName: string): void => {
        let data = new Map<string, Object>();
        data.set('type', ChatGroupChangeEvent.ON_GROUP_DESTROYED);
        data.set('groupId', groupId);
        data.set('groupName', groupName);
        this.emitEvent(MethodKey.onGroupChanged, data);
      },
      onMutelistAdded: (groupId: string, mutes: Array<string>, muteExpire: number): void => {
        let data = new Map<string, Object>();
        data.set('type', ChatGroupChangeEvent.ON_MUTE_LIST_ADDED);
        data.set('groupId', groupId);
        data.set('mutes', mutes);
        data.set('muteExpire', muteExpire);
        this.emitEvent(MethodKey.onGroupChanged, data);
      },
      onMutelistRemoved: (groupId: string, mutes: Array<string>): void => {
        let data = new Map<string, Object>();
        data.set('type', ChatGroupChangeEvent.ON_MUTE_LIST_REMOVED);
        data.set('groupId', groupId);
        data.set('mutes', mutes);
        this.emitEvent(MethodKey.onGroupChanged, data);
      },
      onAdminAdded: (groupId: string, administrator: string): void => {
        let data = new Map<string, Object>();
        data.set('type', ChatGroupChangeEvent.ON_ADMIN_ADDED);
        data.set('groupId', groupId);
        data.set('administrator', administrator);
        this.emitEvent(MethodKey.onGroupChanged, data);
      },
      onAdminRemoved: (groupId: string, administrator: string): void => {
        let data = new Map<string, Object>();
        data.set('type', ChatGroupChangeEvent.ON_ADMIN_REMOVED);
        data.set('groupId', groupId);
        data.set('administrator', administrator);
        this.emitEvent(MethodKey.onGroupChanged, data);
      },
      onOwnerChanged: (groupId: string, newOwner: string, oldOwner: string): void => {
        let data = new Map<string, Object>();
        data.set('type', ChatGroupChangeEvent.ON_OWNER_CHANGED);
        data.set('groupId', groupId);
        data.set('newOwner', newOwner);
        data.set('oldOwner', oldOwner);
        this.emitEvent(MethodKey.onGroupChanged, data);
      },
      onMemberJoined: (groupId: string, member: string): void => {
        let data = new Map<string, Object>();
        data.set('type', ChatGroupChangeEvent.ON_MEMBER_JOINED);
        data.set('groupId', groupId);
        data.set('member', member);
        this.emitEvent(MethodKey.onGroupChanged, data);
      },
      // The multi-member variants use the literal type strings the Dart side
      // matches as literals (same as android).
      onMembersJoined: (groupId: string, members: Array<string>): void => {
        let data = new Map<string, Object>();
        data.set('type', 'onGroupMembersJoined');
        data.set('groupId', groupId);
        data.set('userIds', members);
        this.emitEvent(MethodKey.onGroupChanged, data);
      },
      onMemberExited: (groupId: string, member: string): void => {
        let data = new Map<string, Object>();
        data.set('type', ChatGroupChangeEvent.ON_MEMBER_EXITED);
        data.set('groupId', groupId);
        data.set('member', member);
        this.emitEvent(MethodKey.onGroupChanged, data);
      },
      onMembersExited: (groupId: string, members: Array<string>): void => {
        let data = new Map<string, Object>();
        data.set('type', 'onGroupMembersExited');
        data.set('groupId', groupId);
        data.set('userIds', members);
        this.emitEvent(MethodKey.onGroupChanged, data);
      },
      onAnnouncementChanged: (groupId: string, announcement: string): void => {
        let data = new Map<string, Object>();
        data.set('type', ChatGroupChangeEvent.ON_ANNOUNCEMENT_CHANGED);
        data.set('groupId', groupId);
        data.set('announcement', announcement);
        this.emitEvent(MethodKey.onGroupChanged, data);
      },
      onSharedFileAdded: (groupId: string, sharedFile: SharedFile): void => {
        let data = new Map<string, Object>();
        data.set('type', ChatGroupChangeEvent.ON_SHARED_FILE_ADDED);
        data.set('groupId', groupId);
        data.set('sharedFile', MucSharedFileHelper.toJson(sharedFile));
        this.emitEvent(MethodKey.onGroupChanged, data);
      },
      onSharedFileDeleted: (groupId: string, fileId: string): void => {
        let data = new Map<string, Object>();
        data.set('type', ChatGroupChangeEvent.ON_SHARED_FILE__DELETED);
        data.set('groupId', groupId);
        data.set('fileId', fileId);
        this.emitEvent(MethodKey.onGroupChanged, data);
      },
      onWhitelistAdded: (groupId: string, whitelist: Array<string>): void => {
        let data = new Map<string, Object>();
        data.set('type', ChatGroupChangeEvent.ON_WHITE_LIST_ADDED);
        data.set('groupId', groupId);
        data.set('whitelist', whitelist);
        this.emitEvent(MethodKey.onGroupChanged, data);
      },
      onWhitelistRemoved: (groupId: string, whitelist: Array<string>): void => {
        let data = new Map<string, Object>();
        data.set('type', ChatGroupChangeEvent.ON_WHITE_LIST_REMOVED);
        data.set('groupId', groupId);
        data.set('whitelist', whitelist);
        this.emitEvent(MethodKey.onGroupChanged, data);
      },
      onAllMemberMuteStateChanged: (groupId: string, isMuted: boolean): void => {
        let data = new Map<string, Object>();
        data.set('type', ChatGroupChangeEvent.ON_ALL_MEMBER_MUTE_STATE_CHANGED);
        data.set('groupId', groupId);
        data.set('isMuted', isMuted);
        this.emitEvent(MethodKey.onGroupChanged, data);
      },
      onSpecificationChanged: (group: Group): void => {
        let data = new Map<string, Object>();
        data.set('type', ChatGroupChangeEvent.ON_SPECIFICATION_DID_UPDATE);
        data.set('group', GroupHelper.toJson(group));
        this.emitEvent(MethodKey.onGroupChanged, data);
      },
      onStateChanged: (group: Group, isDisabled: boolean): void => {
        let data = new Map<string, Object>();
        data.set('type', ChatGroupChangeEvent.ON_STATE_CHANGED);
        data.set('groupId', group.groupId());
        data.set('isDisabled', isDisabled);
        this.emitEvent(MethodKey.onGroupChanged, data);
      },
      onGroupMemberAttributeChanged: (groupId: string, member: string, attributes: Map<string, string>,
        from: string): void => {
        let data = new Map<string, Object>();
        data.set('type', ChatGroupChangeEvent.ON_ATTRIBUTES_CHANGED_OF_MEMBER);
        data.set('groupId', groupId);
        data.set('userId', member);
        data.set('operatorId', from);
        data.set('attributes', attributes as Object);
        this.emitEvent(MethodKey.onGroupChanged, data);
      },
      onUserGroupNamecardUpdated: (groupId: string, userId: string, namecard: string): void => {
        let data = new Map<string, Object>();
        data.set('type', ChatGroupChangeEvent.ON_USER_GROUP_NAMECARD_CHANGED);
        data.set('groupId', groupId);
        data.set('userId', userId);
        data.set('namecard', namecard);
        this.emitEvent(MethodKey.onGroupChanged, data);
      },
    };
    manager.addListener(this.groupListener);
    this.listenerAttached = true;
  }

  override unRegisterEaseListener(): void {
    this.listenerAttached = false;
    if (this.groupListener === undefined) {
      return;
    }
    let manager = ChatClient.getInstance().groupManager();
    if (manager !== undefined) {
      manager.removeListener(this.groupListener);
    }
    this.groupListener = undefined;
  }
}
