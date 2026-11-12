import { GroupMember } from '@easemob/chatsdk';
import EnumTool from './EnumTool';

/**
 * Serializes chatsdk GroupMember (mirrors android GroupMemberInfoHelper; keys
 * match the Dart GroupMemberInfo.fromJson). The android side calls the model
 * EMGroupMemberInfo while chatsdk calls it GroupMember.
 *
 * Note: chatsdk exposes the fields as getter properties, not methods.
 */
export default class GroupMemberInfoHelper {
  static toJson(member: GroupMember): Map<string, Object> {
    let data = new Map<string, Object>();
    data.set('userId', member.memberId);
    data.set('joinedTs', member.joinTime);
    data.set('role', EnumTool.groupPermissionTypeToInt(member.role));
    data.set('namecard', member.namecard);
    data.set('nickname', member.nickname);
    data.set('avatarUrl', member.avatarUrl);
    return data;
  }
}
