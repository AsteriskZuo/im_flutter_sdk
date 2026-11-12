import { Group } from '@easemob/chatsdk';
import EnumTool from './EnumTool';

/**
 * Serializes chatsdk Group (mirrors android GroupHelper; keys match the Dart
 * ChatGroup.fromJson).
 *
 * Known gap against android: chatsdk Group has no isMemberOnly on HarmonyOS,
 * so the key is omitted (the Dart field is nullable).
 *
 * chatsdk has no GroupInfo counterpart; android GroupInfoHelper is dropped on
 * purpose — chatsdk fetchPublicGroupsFromServer returns full Group objects,
 * which go through this helper.
 */
export default class GroupHelper {
  static toJson(group: Group): Map<string, Object> {
    let data = new Map<string, Object>();
    data.set('groupId', group.groupId());
    data.set('name', group.groupName());
    data.set('avatarUrl', group.groupAvatar());
    data.set('desc', group.description());
    data.set('owner', group.owner());
    data.set('announcement', group.announcement());
    data.set('memberCount', group.membersCount());
    data.set('memberList', group.members());
    data.set('adminList', group.adminList());
    data.set('blockList', group.blocklist());
    data.set('muteList', group.mutelist());
    data.set('messageBlocked', group.isMsgBlocked());
    data.set('isDisabled', group.isDisabled());
    data.set('isAllMemberMuted', group.isAllMemberMuted());
    data.set('permissionType', EnumTool.groupPermissionTypeToInt(group.groupPermissionType()));
    data.set('maxUserCount', group.maxUserCount());
    data.set('isMemberAllowToInvite', group.isMemberAllowToInvite());
    data.set('ext', group.extension());
    return data;
  }

  static listToJson(groups: Array<Group>): Array<Map<string, Object>> {
    let list = new Array<Map<string, Object>>();
    for (let group of groups) {
      list.push(GroupHelper.toJson(group));
    }
    return list;
  }
}
