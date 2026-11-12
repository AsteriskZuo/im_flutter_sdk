import { Group } from '@easemob/chatsdk';

/**
 * Serializes a chatsdk Group into the lightweight ChatGroupInfo wire shape
 * (mirrors android GroupInfoHelper; keys match the Dart ChatGroupInfo.fromJson).
 *
 * Added for chat_group_manager getPublicGroupsFromServer: chatsdk
 * fetchPublicGroupsFromServer returns full Group objects while Flutter expects
 * lightweight group infos, so the full objects are trimmed here
 * (gap ledger 02 §16.1-A#13).
 */
export default class GroupInfoHelper {
  static toJson(group: Group): Map<string, Object> {
    let data = new Map<string, Object>();
    data.set('groupId', group.groupId());
    data.set('name', group.groupName());
    return data;
  }
}
