import "dart:async";

import 'package:flutter/services.dart';
import 'em_channel.dart';
import 'em_test.dart';
import 'internal/em_event_keys.dart';
import 'tools/em_extension.dart';
import 'internal/chat_method_keys.dart';
import '../im_flutter_sdk.dart';

///
/// The chat room manager, which manages users joining and existing the chat room and getting the chat room list, and manages member privileges.
///  For example, joining a chat room:
///   ```dart
///     try {
///         await EMClient.getInstance.chatRoomManager.joinChatRoom(chatRoomId);
///     } on EMError catch (e) {
///         debugPrint(e.toString());
///     }
///   ```
class EMChatRoomManager {
    static MethodChannel _channel = EMChannel.getInstance.getChannel(EMTest.TEST_TYPE == 1 ? 'chat_room_manager' : 'dart_to_native');
  static MethodChannel _recvChannel = EMChannel.getInstance.getChannel(EMTest.TEST_TYPE == 1 ? 'chat_room_manager' : 'native_to_dart');

  /// @nodoc
  EMChatRoomManager() {
    _recvChannel.setMethodCallHandler((MethodCall call) async {
      Map? argMap = call.arguments;
      if (call.method == ChatMethodKeys.chatRoomChange) {
        return _chatRoomChange(argMap!);
      }
      return null;
    });
  }

  final List<EMChatRoomEventListener> _chatRoomEventListeners = [];

  ///
  /// Registers a chat room event listener.
  /// Chat room destruction, member entry and exit, mute, and allowlist entry addition among other operations can be listened by setting
  /// {@link EMChatRoomEventListener}.
  ///
  /// Chat room event listeners registered with this method can be removed by calling {@link #removeChatRoomListener(EMChatRoomEventListener)}.
  ///
  /// Param [listener] A chat room listener. See {@link EMChatRoomEventListener}.
  ///
  void addChatRoomChangeListener(EMChatRoomEventListener listener) {
    _chatRoomEventListeners.add(listener);
  }

  ///
  /// Removes a chat room event listener.
  /// This method removes the chat room event listener registered with {@link #addChatRoomChangeListener(EMChatRoomEventListener)}.
  ///
  /// Param [listener] The chat room event listener to be removed.
  ///
  void removeChatRoomListener(EMChatRoomEventListener listener) {
    if (_chatRoomEventListeners.contains(listener)) {
      _chatRoomEventListeners.remove(listener);
    }
  }

  Future<void> _chatRoomChange(Map event) async {
    String? type = event['type'];
    for (EMChatRoomEventListener listener in _chatRoomEventListeners) {
      switch (type) {
        case EMChatRoomEvent.ON_CHAT_ROOM_DESTROYED:
          String roomId = event['roomId'];
          String? roomName = event['roomName'];
          listener.onChatRoomDestroyed(roomId, roomName);
          break;
        case EMChatRoomEvent.ON_MEMBER_JOINED:
          String roomId = event['roomId'];
          String participant = event['participant'];
          listener.onMemberJoinedFromChatRoom(roomId, participant);
          break;
        case EMChatRoomEvent.ON_MEMBER_EXITED:
          String roomId = event['roomId'];
          String? roomName = event['roomName'];
          String participant = event['participant'];
          listener.onMemberExitedFromChatRoom(roomId, roomName, participant);
          break;
        case EMChatRoomEvent.ON_REMOVED_FROM_CHAT_ROOM:
          String roomId = event['roomId'];
          String? roomName = event['roomName'];
          String participant = event['participant'];
          listener.onRemovedFromChatRoom(roomId, roomName, participant);
          break;
        case EMChatRoomEvent.ON_MUTE_LIST_ADDED:
          String roomId = event['roomId'];
          List<String> mutes = List.from(event['mutes']);
          String? expireTime = event['expireTime'];
          listener.onMuteListAddedFromChatRoom(roomId, mutes, expireTime);
          break;
        case EMChatRoomEvent.ON_MUTE_LIST_REMOVED:
          String roomId = event['roomId'];
          List<String> mutes = List.from(event['mutes']);
          listener.onMuteListRemovedFromChatRoom(roomId, mutes);
          break;
        case EMChatRoomEvent.ON_ADMIN_ADDED:
          String roomId = event['roomId'];
          String admin = event['admin'];
          listener.onAdminAddedFromChatRoom(roomId, admin);
          break;
        case EMChatRoomEvent.ON_ADMIN_REMOVED:
          String roomId = event['roomId'];
          String admin = event['admin'];
          listener.onAdminRemovedFromChatRoom(roomId, admin);
          break;
        case EMChatRoomEvent.ON_OWNER_CHANGED:
          String roomId = event['roomId'];
          String newOwner = event['newOwner'];
          String oldOwner = event['oldOwner'];
          listener.onOwnerChangedFromChatRoom(roomId, newOwner, oldOwner);
          break;
        case EMChatRoomEvent.ON_ANNOUNCEMENT_CHANGED:
          String roomId = event['roomId'];
          String announcement = event['announcement'];
          listener.onAnnouncementChangedFromChatRoom(roomId, announcement);
          break;
        case EMChatRoomEvent.ON_WHITE_LIST_ADDED:
          String roomId = event['roomId'];
          List<String> members = List.from(event["whitelist"]);
          listener.onWhiteListAddedFromChatRoom(roomId, members);
          break;
        case EMChatRoomEvent.ON_WHITE_LIST_REMOVED:
          String roomId = event['roomId'];
          List<String> members = List.from(event["whitelist"]);
          listener.onWhiteListRemovedFromChatRoom(roomId, members);
          break;
        case EMChatRoomEvent.ON_ALL_MEMBER_MUTE_STATE_CHANGED:
          String roomId = event['roomId'];
          bool isAllMuted = event['isMuted'];
          listener.onAllChatRoomMemberMuteStateChanged(roomId, isAllMuted);
          break;
      }
    }
  }

  ///
  /// Joins the chat room.
  ///
  /// To exit the chat room, call {@link #leaveChatRoom(String)}.
  ///
  /// Param [roomId] The ID of the chat room to join.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<void> joinChatRoom(String roomId) async {
    Map result = await _channel
        .invokeMethod(ChatMethodKeys.joinChatRoom, {"roomId": roomId});
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Leaves a chat room.
  ///
  /// Param [roomId] The ID of the chat room to leave.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<void> leaveChatRoom(String roomId) async {
    Map result = await _channel
        .invokeMethod(ChatMethodKeys.leaveChatRoom, {"roomId": roomId});
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets chat room data from the server with pagination.
  ///
  /// Param [pageNum] The page number, starting from 1.
  ///
  /// Param [pageSize] The number of records per page.
  ///
  /// **return** Chat room data. See {@link EMPageResult}.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<EMPageResult<EMChatRoom>> fetchPublicChatRoomsFromServer({
    int pageNum = 1,
    int pageSize = 200,
  }) async {
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.fetchPublicChatRoomsFromServer,
        {"pageNum": pageNum, "pageSize": pageSize});
    try {
      EMError.hasErrorFromResult(result);
      return EMPageResult<EMChatRoom>.fromJson(
          result[ChatMethodKeys.fetchPublicChatRoomsFromServer],
          dataItemCallback: (map) {
        return EMChatRoom.fromJson(map);
      });
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets details of a chat room from the server, excluding the member list by default.
  /// The member list, if required, can contain at most 200 members if need. For more members,
  /// call {@link EMChatRoomManager#fetchChatRoomMembers(String, String?, int?)}.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [fetchMembers] Whether to get chat room members, default is false.
  ///
  /// **return** The chat room instance.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<EMChatRoom> fetchChatRoomInfoFromServer(
    String roomId, {
    bool fetchMembers = false,
  }) async {
    Map result = await _channel
        .invokeMethod(ChatMethodKeys.fetchChatRoomInfoFromServer, {
      "roomId": roomId,
      "fetchMembers": fetchMembers,
    });
    try {
      EMError.hasErrorFromResult(result);
      return EMChatRoom.fromJson(
          result[ChatMethodKeys.fetchChatRoomInfoFromServer]);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the chat room in the cache.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// **return** The chat room instance. Returns null if the chat room is not found in the cache.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<EMChatRoom?> getChatRoomWithId(String roomId) async {
    Map result = await _channel
        .invokeMethod(ChatMethodKeys.getChatRoom, {"roomId": roomId});
    try {
      EMError.hasErrorFromResult(result);
      if (result.containsKey(ChatMethodKeys.fetchChatRoomInfoFromServer)) {
        return EMChatRoom.fromJson(
            result[ChatMethodKeys.fetchChatRoomInfoFromServer]);
      } else {
        return null;
      }
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the list of chat rooms in the cache.
  ///
  /// **return** The list of chat rooms maintained by EMChatRoomManager.
  @Deprecated("")
  Future<List<EMChatRoom>> getAllChatRooms() async {
    Map result = await _channel.invokeMethod(ChatMethodKeys.getAllChatRooms);
    try {
      EMError.hasErrorFromResult(result);
      List<EMChatRoom> list = [];
      result[ChatMethodKeys.getAllChatRooms]
          ?.forEach((element) => list.add(EMChatRoom.fromJson(element)));
      return list;
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Creates a chat room.
  ///
  /// Param [subject] The chat room subject.
  ///
  /// Param [desc] The chat room description.
  ///
  /// Param [welcomeMsg] A welcome message inviting members to join the chat room.
  ///
  /// Param [maxUserCount] The maximum number of members allowed to join the chat room.
  ///
  /// Param [members] The list of members invited to join the chat room.
  ///
  /// **return** The chat room instance created successfully.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<EMChatRoom> createChatRoom(
    String subject, {
    String? desc,
    String? welcomeMsg,
    int maxUserCount = 300,
    List<String>? members,
  }) async {
    Map req = Map();
    req['subject'] = subject;
    req['desc'] = desc;
    req['welcomeMsg'] = welcomeMsg;
    req['maxUserCount'] = maxUserCount;
    req['members'] = members;
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.createChatRoom, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMChatRoom.fromJson(result[ChatMethodKeys.createChatRoom]);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Destroys a chat room.
  ///
  /// Only the chat room owner can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<void> destroyChatRoom(
    String roomId,
  ) async {
    Map req = {"roomId": roomId};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.destroyChatRoom, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Changes the chat room subject.
  ///
  /// Only the chat room owner can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [subject] The new subject of the chat room.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<void> changeChatRoomSubject(
    String roomId,
    String subject,
  ) async {
    Map req = {"roomId": roomId, "subject": subject};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.changeChatRoomSubject, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Modifies the chat room description.
  ///
  /// Only the chat room owner can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [description] The new description of the chat room.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<void> changeChatRoomDescription(
    String roomId,
    String description,
  ) async {
    Map req = {"roomId": roomId, "description": description};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.changeChatRoomDescription, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the chat room member list.
  ///
  /// When EMCursorResult.cursor is an empty string ("") amid the result, all data is fetched.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [cursor] The cursor position from which to start getting data.
  ///
  /// Param [pageSize] The number of members per page.
  ///
  /// **return** The list of chat room members. See {@link EMCursorResult}.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<EMCursorResult<String?>> fetchChatRoomMembers(
    String roomId, {
    String? cursor,
    int pageSize = 200,
  }) async {
    Map req = {"roomId": roomId, "pageSize": pageSize};
    req.setValueWithOutNull("cursor", cursor);
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.fetchChatRoomMembers, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMCursorResult<String?>.fromJson(
          result[ChatMethodKeys.fetchChatRoomMembers],
          dataItemCallback: (obj) => obj);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Mutes members in a chat room.
  ///
  /// Only the chat room owner or admin can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [muteMembers] The list of members to be muted.
  ///
  /// Param [duration] The mute duration in milliseconds.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<void> muteChatRoomMembers(
    String roomId,
    List<String> muteMembers, {
    int duration = -1,
  }) async {
    Map req = {
      "roomId": roomId,
      "muteMembers": muteMembers,
      "duration": duration
    };
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.muteChatRoomMembers, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Unmutes members in a chat room.
  ///
  /// Only the chat room owner or admin can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [unMuteMembers] The list of members to be unmuted.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<void> unMuteChatRoomMembers(
    String roomId,
    List<String> unMuteMembers,
  ) async {
    Map req = {"roomId": roomId, "unMuteMembers": unMuteMembers};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.unMuteChatRoomMembers, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Transfers the chat room ownership.
  ///
  /// Only the chat room owner can call this method.
  ///
  /// Param [roomId] A chat room ID.
  ///
  /// Param [newOwner] The ID of the new chat room owner.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<void> changeOwner(
    String roomId,
    String newOwner,
  ) async {
    Map req = {"roomId": roomId, "newOwner": newOwner};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.changeChatRoomOwner, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Adds a chat room admin.
  ///
  /// Only the chat room owner can call this method.
  ///
  /// Param [roomId] A chat room ID.
  ///
  /// Param [admin] The ID of the chat room admin to be added.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<void> addChatRoomAdmin(
    String roomId,
    String admin,
  ) async {
    Map req = {"roomId": roomId, "admin": admin};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.addChatRoomAdmin, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Removes privileges of a chat room admin.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [admin] The ID of admin whose privileges are to be removed.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<void> removeChatRoomAdmin(
    String roomId,
    String admin,
  ) async {
    Map req = {"roomId": roomId, "admin": admin};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.removeChatRoomAdmin, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the list of members who are muted in the chat room from the server.
  ///
  /// Only the chat room owner or admin can call this method.
  ///
  /// Param [roomId] The chat room ID
  ///
  /// Param [pageNum] The page number, starting from 1.
  ///
  /// Param [pageSize] The number of muted members per page.
  ///
  /// **return** The muted member list.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<List<String>?> fetchChatRoomMuteList(
    String roomId, {
    int pageNum = 1,
    int pageSize = 200,
  }) async {
    Map req = {"roomId": roomId, "pageNum": pageNum, "pageSize": pageSize};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.fetchChatRoomMuteList, req);
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.fetchChatRoomMuteList]?.cast<String>();
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Removes members from a chat room.
  ///
  /// Only the chat room owner or admin can call this method.
  ///
  /// Param [roomId] The chat room ID
  ///
  /// Param [members] The members list to be removed.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<void> removeChatRoomMembers(
    String roomId,
    List<String> members,
  ) async {
    Map req = {"roomId": roomId, "members": members};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.removeChatRoomMembers, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Adds members to the chat room's block list.
  ///
  /// Only the chat room owner or admin can call this method.
  ///
  /// For members added to block list, note the following:
  /// 1. A member, once added to the chat room block list, will be removed from the chat room by the server.
  /// 2. The method {@link EMChatRoomEventListener#onRemovedFromChatRoom(String, String?, String?)} occurs.
  /// 3. Members added to the block list are banned from rejoining the chat room.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [members] The list of members to be added to block list.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<void> blockChatRoomMembers(
    String roomId,
    List members,
  ) async {
    Map req = {"roomId": roomId, "members": members};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.blockChatRoomMembers, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Removes members from the chat room's block list.
  ///
  /// Only the chat room owner or admin can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [members] The list of members to be removed from the block list.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<void> unBlockChatRoomMembers(
    String roomId,
    List members,
  ) async {
    Map req = {"roomId": roomId, "members": members};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.unBlockChatRoomMembers, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the chat room block list with pagination.
  ///
  /// Only the chat room owner or admin can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [pageNum] The page number, starting from 1.
  ///
  /// Param [pageSize] The number of users on the block list per page.
  ///
  /// **return** The chat room's block list.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<List<String>?> fetchChatRoomBlockList(
    String roomId, [
    int pageNum = 1,
    int pageSize = 200,
  ]) async {
    Map req = {"roomId": roomId, "pageNum": pageNum, "pageSize": pageSize};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.fetchChatRoomBlockList, req);
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.fetchChatRoomBlockList]?.cast<String>();
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Updates the chat room announcement.
  ///
  /// Only the chat room owner or admin can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [announcement] The announcement content.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<void> updateChatRoomAnnouncement(
    String roomId,
    String announcement,
  ) async {
    Map req = {"roomId": roomId, "announcement": announcement};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.updateChatRoomAnnouncement, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the chat room announcement from the server.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// **return** The chat room announcement.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<String?> fetchChatRoomAnnouncement(
    String roomId,
  ) async {
    Map req = {"roomId": roomId};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.fetchChatRoomAnnouncement, req);
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.fetchChatRoomAnnouncement];
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the while list from the server.
  ///
  /// Only the chat room owner or admin can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// **return** The chat room while list.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<List<String>?> fetchChatRoomWhiteListFromServer(String roomId) async {
    Map req = {"roomId": roomId};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.fetchChatRoomWhiteListFromServer, req);
    EMError.hasErrorFromResult(result);
    List<String> contacts = [];
    result[ChatMethodKeys.fetchChatRoomWhiteListFromServer]?.forEach((element) {
      contacts.add(element);
    });
    return contacts;
  }

  ///
  /// Checks whether the member is on the while list.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// **return** Current member is in while list.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<bool> isMemberInChatRoomWhiteList(String roomId) async {
    Map req = {"roomId": roomId};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.isMemberInChatRoomWhiteListFromServer, req);
    EMError.hasErrorFromResult(result);
    return result
        .boolValue(ChatMethodKeys.isMemberInChatRoomWhiteListFromServer);
  }

  ///
  /// Adds members to the allowlist.
  ///
  /// Only the chat room owner or admin can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [members] The list of members to be added to the while list.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<void> addMembersToChatRoomWhiteList(
    String roomId,
    List<String> members,
  ) async {
    Map req = {
      "roomId": roomId,
      "members": members,
    };
    Map result = await _channel.invokeMethod(
      ChatMethodKeys.addMembersToChatRoomWhiteList,
      req,
    );

    EMError.hasErrorFromResult(result);
  }

  ///
  /// Removes members from the while list.
  ///
  /// Only the chat room owner or admin can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [members] The list of members to be removed from the while list.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<void> removeMembersFromChatRoomWhiteList(
    String roomId,
    List<String> members,
  ) async {
    Map req = {
      "roomId": roomId,
      "members": members,
    };
    Map result = await _channel.invokeMethod(
      ChatMethodKeys.addMembersToChatRoomWhiteList,
      req,
    );
    EMError.hasErrorFromResult(result);
  }

  ///
  /// Mutes all members.
  ///
  /// Only the chat room owner or admin can call this method.
  ///
  /// This method does not work for the chat room owner, admin, and members added to the block list.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<void> muteAllChatRoomMembers(String roomId) async {
    Map req = {"roomId": roomId};
    Map result = await _channel.invokeMethod(
      ChatMethodKeys.muteAllChatRoomMembers,
      req,
    );
    EMError.hasErrorFromResult(result);
  }

  ///
  /// Unmutes all members.
  ///
  /// Only the chat room owner or admin can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<void> unMuteAllChatRoomMembers(String roomId) async {
    Map req = {"roomId": roomId};
    Map result = await _channel.invokeMethod(
      ChatMethodKeys.unMuteAllChatRoomMembers,
      req,
    );
    EMError.hasErrorFromResult(result);
  }
}
