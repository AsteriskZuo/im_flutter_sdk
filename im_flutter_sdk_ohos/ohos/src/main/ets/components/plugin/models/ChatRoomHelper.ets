import { Chatroom } from '@easemob/chatsdk';

/**
 * Serializes chatsdk Chatroom (mirrors android ChatRoomHelper; keys match the
 * Dart ChatRoom.fromJson). Chat rooms are only converted native -> Dart, no
 * fromJson is needed.
 *
 * Known gap against android: chatsdk Chatroom has no maxUsers on HarmonyOS,
 * so the key is omitted (the Dart field is nullable).
 *
 * permissionType comes from Chatroom.currentUserRole(), which already uses
 * the android wire values (member=0, admin=1, owner=2).
 */
export default class ChatRoomHelper {
  static toJson(chatRoom: Chatroom): Map<string, Object> {
    let data = new Map<string, Object>();
    data.set('roomId', chatRoom.chatroomId());
    data.set('name', chatRoom.chatroomName());
    data.set('desc', chatRoom.chatroomDescription());
    data.set('owner', chatRoom.owner());
    data.set('memberCount', chatRoom.memberCount());
    data.set('adminList', chatRoom.admins());
    data.set('memberList', chatRoom.members());
    data.set('blockList', chatRoom.blocklist());
    data.set('muteList', chatRoom.mutes());
    data.set('isAllMemberMuted', chatRoom.isAllMemberMuted());
    data.set('announcement', chatRoom.chatroomAnnouncement());
    data.set('permissionType', chatRoom.currentUserRole());
    data.set('createTimestamp', chatRoom.createTimestamp());
    data.set('muteExpireTimestamp', chatRoom.muteExpireTimestamp());
    data.set('isInWhitelist', chatRoom.isInWhitelist());
    return data;
  }

  static listToJson(chatRooms: Array<Chatroom>): Array<Map<string, Object>> {
    let list = new Array<Map<string, Object>>();
    for (let chatRoom of chatRooms) {
      list.push(ChatRoomHelper.toJson(chatRoom));
    }
    return list;
  }
}
