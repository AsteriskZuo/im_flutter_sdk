import {
  ChatClient,
  ChatError,
  Chatroom,
  ChatroomAttributesResult,
  ChatroomListener,
  ChatroomManager,
  LEAVE_REASON,
  RemoveChatroomAttributeParams,
  SetChatroomAttributeParams,
} from '@easemob/chatsdk';
import { Any, FlutterPluginBinding, MethodCall, MethodResult } from '@ohos/flutter_ohos';
import MethodKey, { ChatRoomEvent } from './MethodKeys';
import Wrapper from './Wrapper';
import SafetyMapTool from './SafetyMapTool';
import ChannelValue from './models/ChannelValue';
import ChatRoomHelper from './models/ChatRoomHelper';
import CursorResultHelper from './models/CursorResultHelper';

/**
 * Wrapper for the `com.chat.im/chat_room_manager` channel.
 *
 * Implements the 28 chat_room_manager method keys kept in the ohos-branch
 * Dart constants. `createChatRoom` / `destroyChatRoom` /
 * `fetchChatRoomInfoFromServer` / `getChatRoom` / `getAllChatRooms` were
 * removed from Dart (gap ledger §17): chatsdk has no room create/destroy, no
 * single-room detail fetch and no local room cache, so there are no branches
 * for them here.
 *
 * Adaptations (gap ledger §16.1):
 *   - joinChatRoom: the resolved Chatroom is the only room-info source on
 *     HarmonyOS, so it is serialized with ChatRoomHelper and returned (same
 *     payload as android).
 *   - fetchPublicChatRoomsFromServer: chatsdk returns a bare Array<Chatroom>
 *     without page metadata; the ChatPageResult wire shape ({count, list},
 *     same keys as PageResultHelper) is preserved and "count" is degraded to
 *     the current page's item count, matching the Dart pageCount semantics
 *     ("data count of the current page").
 *   - onRemovedFromChatroom(reason) is dispatched by LEAVE_REASON:
 *     ROOM_DESTROYED -> onRoomDestroyed, BE_KICK -> onRoomRemoved;
 *     BE_KICKED_FOR_OFFLINE has no Dart event and is not emitted.
 *
 * Listener timing: unlike android (registers in the constructor), the chatsdk
 * ChatroomManager only exists after ChatClient.init, and this channel has no
 * init call. Registration therefore happens lazily on the first method call
 * (any chat room call implies init already happened), mirroring the
 * ClientWrapper "register after init" semantics.
 */
export default class ChatRoomManagerWrapper extends Wrapper {
  private chatroomListener: ChatroomListener | undefined;
  private listenerAttached: boolean = false;

  constructor(binding: FlutterPluginBinding, channelName: string) {
    super(binding, channelName);
  }

  override onMethodCall(call: MethodCall, result: MethodResult): void {
    if (!this.listenerAttached) {
      this.registerEaseListener();
    }
    if (MethodKey.joinChatRoom === call.method) {
      this.joinChatRoom(call, result);
    } else if (MethodKey.leaveChatRoom === call.method) {
      this.leaveChatRoom(call, result);
    } else if (MethodKey.fetchPublicChatRoomsFromServer === call.method) {
      this.fetchPublicChatRoomsFromServer(call, result);
    } else if (MethodKey.changeChatRoomSubject === call.method) {
      this.changeChatRoomSubject(call, result);
    } else if (MethodKey.changeChatRoomDescription === call.method) {
      this.changeChatRoomDescription(call, result);
    } else if (MethodKey.fetchChatRoomMembers === call.method) {
      this.fetchChatRoomMembers(call, result);
    } else if (MethodKey.muteChatRoomMembers === call.method) {
      this.muteChatRoomMembers(call, result);
    } else if (MethodKey.unMuteChatRoomMembers === call.method) {
      this.unMuteChatRoomMembers(call, result);
    } else if (MethodKey.changeChatRoomOwner === call.method) {
      this.changeChatRoomOwner(call, result);
    } else if (MethodKey.addChatRoomAdmin === call.method) {
      this.addChatRoomAdmin(call, result);
    } else if (MethodKey.removeChatRoomAdmin === call.method) {
      this.removeChatRoomAdmin(call, result);
    } else if (MethodKey.fetchChatRoomMuteList === call.method) {
      this.fetchChatRoomMuteList(call, result);
    } else if (MethodKey.removeChatRoomMembers === call.method) {
      this.removeChatRoomMembers(call, result);
    } else if (MethodKey.blockChatRoomMembers === call.method) {
      this.blockChatRoomMembers(call, result);
    } else if (MethodKey.unBlockChatRoomMembers === call.method) {
      this.unBlockChatRoomMembers(call, result);
    } else if (MethodKey.fetchChatRoomBlockList === call.method) {
      this.fetchChatRoomBlockList(call, result);
    } else if (MethodKey.updateChatRoomAnnouncement === call.method) {
      this.updateChatRoomAnnouncement(call, result);
    } else if (MethodKey.fetchChatRoomAnnouncement === call.method) {
      this.fetchChatRoomAnnouncement(call, result);
    } else if (MethodKey.addMembersToChatRoomWhiteList === call.method) {
      this.addMembersToChatRoomWhiteList(call, result);
    } else if (MethodKey.removeMembersFromChatRoomWhiteList === call.method) {
      this.removeMembersFromChatRoomWhiteList(call, result);
    } else if (MethodKey.fetchChatRoomWhiteListFromServer === call.method) {
      this.fetchChatRoomWhiteListFromServer(call, result);
    } else if (MethodKey.isMemberInChatRoomWhiteListFromServer === call.method) {
      this.isMemberInChatRoomWhiteListFromServer(call, result);
    } else if (MethodKey.muteAllChatRoomMembers === call.method) {
      this.muteAllChatRoomMembers(call, result);
    } else if (MethodKey.unMuteAllChatRoomMembers === call.method) {
      this.unMuteAllChatRoomMembers(call, result);
    } else if (MethodKey.fetchChatRoomAttributes === call.method) {
      this.fetchChatRoomAttributes(call, result);
    } else if (MethodKey.setChatRoomAttributes === call.method) {
      this.setChatRoomAttributes(call, result);
    } else if (MethodKey.removeChatRoomAttributes === call.method) {
      this.removeChatRoomAttributes(call, result);
    } else if (MethodKey.isMemberInChatRoomMuteList === call.method) {
      this.isMemberInChatRoomMuteList(call, result);
    } else {
      super.onMethodCall(call, result);
    }
  }

  private joinChatRoom(call: MethodCall, result: MethodResult): void {
    let manager = this.roomManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let roomId = SafetyMapTool.getString(call.args, 'roomId', '') ?? '';
    let leaveOtherRooms = SafetyMapTool.getBoolean(call.args, 'leaveOtherRooms', false) ?? false;
    let ext = SafetyMapTool.getString(call.args, 'ext');
    let promise: Promise<Chatroom>;
    if (ext !== undefined) {
      promise = manager.joinChatroom(roomId, leaveOtherRooms, ext);
    } else {
      promise = manager.joinChatroom(roomId, leaveOtherRooms);
    }
    this.handlePromise(result, call.method, promise, (room: Chatroom) => ChatRoomHelper.toJson(room));
  }

  private leaveChatRoom(call: MethodCall, result: MethodResult): void {
    let manager = this.roomManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let roomId = SafetyMapTool.getString(call.args, 'roomId', '') ?? '';
    this.handlePromise(result, call.method, manager.leaveChatroom(roomId), () => true);
  }

  private fetchPublicChatRoomsFromServer(call: MethodCall, result: MethodResult): void {
    let manager = this.roomManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let pageNum = SafetyMapTool.getNumber(call.args, 'pageNum', 1) ?? 1;
    let pageSize = SafetyMapTool.getNumber(call.args, 'pageSize', 200) ?? 200;
    this.handlePromise(result, call.method, manager.fetchPublicChatroomsFromServer(pageNum, pageSize),
      (rooms: Array<Chatroom>) => {
        let data = new Map<string, Object>();
        data.set('count', rooms.length);
        data.set('list', ChatRoomHelper.listToJson(rooms));
        return data;
      });
  }

  private changeChatRoomSubject(call: MethodCall, result: MethodResult): void {
    let manager = this.roomManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let roomId = SafetyMapTool.getString(call.args, 'roomId', '') ?? '';
    let subject = SafetyMapTool.getString(call.args, 'subject', '') ?? '';
    this.handlePromise(result, call.method, manager.changeChatroomName(roomId, subject),
      (room: Chatroom) => ChatRoomHelper.toJson(room));
  }

  private changeChatRoomDescription(call: MethodCall, result: MethodResult): void {
    let manager = this.roomManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let roomId = SafetyMapTool.getString(call.args, 'roomId', '') ?? '';
    let description = SafetyMapTool.getString(call.args, 'description', '') ?? '';
    this.handlePromise(result, call.method, manager.changeChatroomDescription(roomId, description),
      (room: Chatroom) => ChatRoomHelper.toJson(room));
  }

  private fetchChatRoomMembers(call: MethodCall, result: MethodResult): void {
    let manager = this.roomManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let roomId = SafetyMapTool.getString(call.args, 'roomId', '') ?? '';
    let cursor = SafetyMapTool.getString(call.args, 'cursor', '') ?? '';
    let pageSize = SafetyMapTool.getNumber(call.args, 'pageSize', 200) ?? 200;
    this.handlePromise(result, call.method, manager.fetchChatroomMembers(roomId, cursor, pageSize),
      (ret) => CursorResultHelper.toJson<string>(ret, (s: string) => s as Object));
  }

  private muteChatRoomMembers(call: MethodCall, result: MethodResult): void {
    let manager = this.roomManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let roomId = SafetyMapTool.getString(call.args, 'roomId', '') ?? '';
    let muteMembers = SafetyMapTool.getStringArray(call.args, 'muteMembers') ?? new Array<string>();
    let duration = SafetyMapTool.getNumber(call.args, 'duration', -1) ?? -1;
    this.handlePromise(result, call.method, manager.muteChatroomMembers(roomId, muteMembers, duration),
      (room: Chatroom) => ChatRoomHelper.toJson(room));
  }

  private unMuteChatRoomMembers(call: MethodCall, result: MethodResult): void {
    let manager = this.roomManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let roomId = SafetyMapTool.getString(call.args, 'roomId', '') ?? '';
    let unMuteMembers = SafetyMapTool.getStringArray(call.args, 'unMuteMembers') ?? new Array<string>();
    this.handlePromise(result, call.method, manager.unmuteChatroomMembers(roomId, unMuteMembers),
      (room: Chatroom) => ChatRoomHelper.toJson(room));
  }

  private changeChatRoomOwner(call: MethodCall, result: MethodResult): void {
    let manager = this.roomManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let roomId = SafetyMapTool.getString(call.args, 'roomId', '') ?? '';
    let newOwner = SafetyMapTool.getString(call.args, 'newOwner', '') ?? '';
    this.handlePromise(result, call.method, manager.changeChatroomOwner(roomId, newOwner),
      (room: Chatroom) => ChatRoomHelper.toJson(room));
  }

  private addChatRoomAdmin(call: MethodCall, result: MethodResult): void {
    let manager = this.roomManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let roomId = SafetyMapTool.getString(call.args, 'roomId', '') ?? '';
    let admin = SafetyMapTool.getString(call.args, 'admin', '') ?? '';
    this.handlePromise(result, call.method, manager.addChatroomAdmin(roomId, admin),
      (room: Chatroom) => ChatRoomHelper.toJson(room));
  }

  private removeChatRoomAdmin(call: MethodCall, result: MethodResult): void {
    let manager = this.roomManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let roomId = SafetyMapTool.getString(call.args, 'roomId', '') ?? '';
    let admin = SafetyMapTool.getString(call.args, 'admin', '') ?? '';
    this.handlePromise(result, call.method, manager.removeChatroomAdmin(roomId, admin),
      (room: Chatroom) => ChatRoomHelper.toJson(room));
  }

  private fetchChatRoomMuteList(call: MethodCall, result: MethodResult): void {
    let manager = this.roomManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let roomId = SafetyMapTool.getString(call.args, 'roomId', '') ?? '';
    let pageNum = SafetyMapTool.getNumber(call.args, 'pageNum', 1) ?? 1;
    let pageSize = SafetyMapTool.getNumber(call.args, 'pageSize', 200) ?? 200;
    // chatsdk returns Map<userId, muteExpireMs>; android keeps only the keys.
    this.handlePromise(result, call.method, manager.fetchChatroomMutes(roomId, pageNum, pageSize),
      (mutes: Map<string, number>) => {
        let list = new Array<string>();
        mutes.forEach((expireTime: number, userId: string) => {
          list.push(userId);
        });
        return list;
      });
  }

  private removeChatRoomMembers(call: MethodCall, result: MethodResult): void {
    let manager = this.roomManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let roomId = SafetyMapTool.getString(call.args, 'roomId', '') ?? '';
    let members = SafetyMapTool.getStringArray(call.args, 'members') ?? new Array<string>();
    this.handlePromise(result, call.method, manager.removeChatroomMembers(roomId, members),
      (room: Chatroom) => ChatRoomHelper.toJson(room));
  }

  private blockChatRoomMembers(call: MethodCall, result: MethodResult): void {
    let manager = this.roomManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let roomId = SafetyMapTool.getString(call.args, 'roomId', '') ?? '';
    let members = SafetyMapTool.getStringArray(call.args, 'members') ?? new Array<string>();
    this.handlePromise(result, call.method, manager.blockChatroomMembers(roomId, members),
      (room: Chatroom) => ChatRoomHelper.toJson(room));
  }

  private unBlockChatRoomMembers(call: MethodCall, result: MethodResult): void {
    let manager = this.roomManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let roomId = SafetyMapTool.getString(call.args, 'roomId', '') ?? '';
    let members = SafetyMapTool.getStringArray(call.args, 'members') ?? new Array<string>();
    this.handlePromise(result, call.method, manager.unblockChatroomMembers(roomId, members),
      (room: Chatroom) => ChatRoomHelper.toJson(room));
  }

  private fetchChatRoomBlockList(call: MethodCall, result: MethodResult): void {
    let manager = this.roomManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let roomId = SafetyMapTool.getString(call.args, 'roomId', '') ?? '';
    let pageNum = SafetyMapTool.getNumber(call.args, 'pageNum', 1) ?? 1;
    let pageSize = SafetyMapTool.getNumber(call.args, 'pageSize', 200) ?? 200;
    this.handlePromise(result, call.method, manager.fetchChatroomBlocklist(roomId, pageNum, pageSize),
      (list: Array<string>) => list);
  }

  private updateChatRoomAnnouncement(call: MethodCall, result: MethodResult): void {
    let manager = this.roomManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let roomId = SafetyMapTool.getString(call.args, 'roomId', '') ?? '';
    let announcement = SafetyMapTool.getString(call.args, 'announcement', '') ?? '';
    // android discards the returned room and reports true.
    this.handlePromise(result, call.method, manager.changeChatroomAnnouncement(roomId, announcement),
      () => true);
  }

  private fetchChatRoomAnnouncement(call: MethodCall, result: MethodResult): void {
    let manager = this.roomManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let roomId = SafetyMapTool.getString(call.args, 'roomId', '') ?? '';
    this.handlePromise(result, call.method, manager.fetchChatroomAnnouncement(roomId));
  }

  private addMembersToChatRoomWhiteList(call: MethodCall, result: MethodResult): void {
    let manager = this.roomManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let roomId = SafetyMapTool.getString(call.args, 'roomId', '') ?? '';
    let members = SafetyMapTool.getStringArray(call.args, 'members') ?? new Array<string>();
    // android reports an empty success (no payload) for the whitelist writes.
    this.handlePromise(result, call.method, manager.addToChatroomWhitelist(roomId, members));
  }

  private removeMembersFromChatRoomWhiteList(call: MethodCall, result: MethodResult): void {
    let manager = this.roomManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let roomId = SafetyMapTool.getString(call.args, 'roomId', '') ?? '';
    let members = SafetyMapTool.getStringArray(call.args, 'members') ?? new Array<string>();
    this.handlePromise(result, call.method, manager.removeFromChatroomWhitelist(roomId, members));
  }

  private fetchChatRoomWhiteListFromServer(call: MethodCall, result: MethodResult): void {
    let manager = this.roomManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let roomId = SafetyMapTool.getString(call.args, 'roomId', '') ?? '';
    this.handlePromise(result, call.method, manager.fetchChatroomWhitelist(roomId),
      (list: Array<string>) => list);
  }

  private isMemberInChatRoomWhiteListFromServer(call: MethodCall, result: MethodResult): void {
    let manager = this.roomManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let roomId = SafetyMapTool.getString(call.args, 'roomId', '') ?? '';
    this.handlePromise(result, call.method, manager.checkIfInWhitelist(roomId));
  }

  private muteAllChatRoomMembers(call: MethodCall, result: MethodResult): void {
    let manager = this.roomManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let roomId = SafetyMapTool.getString(call.args, 'roomId', '') ?? '';
    this.handlePromise(result, call.method, manager.muteAllMembers(roomId));
  }

  private unMuteAllChatRoomMembers(call: MethodCall, result: MethodResult): void {
    let manager = this.roomManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let roomId = SafetyMapTool.getString(call.args, 'roomId', '') ?? '';
    this.handlePromise(result, call.method, manager.unmuteAllMembers(roomId));
  }

  private fetchChatRoomAttributes(call: MethodCall, result: MethodResult): void {
    let manager = this.roomManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let roomId = SafetyMapTool.getString(call.args, 'roomId', '') ?? '';
    let keys = SafetyMapTool.getStringArray(call.args, 'keys');
    let promise: Promise<Map<string, string>>;
    if (keys !== undefined && keys.length > 0) {
      promise = manager.fetchChatroomAttributes(roomId, keys);
    } else {
      promise = manager.fetchChatroomAttributes(roomId);
    }
    this.handlePromise(result, call.method, promise, (attrs: Map<string, string>) => attrs);
  }

  private setChatRoomAttributes(call: MethodCall, result: MethodResult): void {
    let manager = this.roomManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let roomId = SafetyMapTool.getString(call.args, 'roomId', '') ?? '';
    let attributes = ChatRoomManagerWrapper.readStringMap(call.args, 'attributes') ??
      new Map<string, string>();
    let autoDelete = SafetyMapTool.getBoolean(call.args, 'autoDelete', false) ?? false;
    let forced = SafetyMapTool.getBoolean(call.args, 'forced', false) ?? false;
    let params: SetChatroomAttributeParams = {
      chatroomId: roomId,
      attributeKeyOrMap: attributes,
      autoDelete: autoDelete,
      isForced: forced,
    };
    this.handleAttributesResult(result, call.method, manager.setChatroomAttributes(params));
  }

  private removeChatRoomAttributes(call: MethodCall, result: MethodResult): void {
    let manager = this.roomManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let roomId = SafetyMapTool.getString(call.args, 'roomId', '') ?? '';
    let keys = SafetyMapTool.getStringArray(call.args, 'keys') ?? new Array<string>();
    let forced = SafetyMapTool.getBoolean(call.args, 'forced', false) ?? false;
    let params: RemoveChatroomAttributeParams = {
      chatroomId: roomId,
      attributeKey: keys,
      isForced: forced,
    };
    this.handleAttributesResult(result, call.method, manager.removeChatroomAttributes(params));
  }

  private isMemberInChatRoomMuteList(call: MethodCall, result: MethodResult): void {
    let manager = this.roomManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let roomId = SafetyMapTool.getString(call.args, 'roomId', '') ?? '';
    this.handlePromise(result, call.method, manager.checkIfInMutelist(roomId));
  }

  /**
   * Mirrors the android failureKeys contract: full success -> empty map,
   * PARTIAL_SUCCESS -> the failed key -> error code map, any other code ->
   * channel error.
   */
  private handleAttributesResult(result: MethodResult, method: string,
    promise: Promise<ChatroomAttributesResult>): void {
    promise
      .then((ret: ChatroomAttributesResult) => {
        if (ret.code === ChatError.EM_NO_ERROR) {
          this.onSuccess(result, method, new Map<string, number>());
        } else if (ret.code === ChatError.PARTIAL_SUCCESS) {
          let failures = ret.errorKeyMap ?? new Map<string, number>();
          this.onSuccess(result, method, failures);
        } else {
          this.onErrorInfo(result, ret.code, 'chatroom attributes operation failed');
        }
      })
      .catch((e: ESObject) => {
        if (e instanceof ChatError) {
          this.onError(result, e);
          return;
        }
        this.onErrorInfo(result, ChatError.GENERAL_ERROR, `rejected: ${typeof e}`);
      });
  }

  private roomManager(result: MethodResult, method: string): ChatroomManager | undefined {
    let manager = ChatClient.getInstance().chatroomManager();
    if (manager === undefined) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR,
        `${method} failed: ChatroomManager unavailable, SDK not initialized`);
      return undefined;
    }
    return manager;
  }

  /** Same nested-map reading as MessageBodyHelper.stringMap, kept local. */
  private static readStringMap(args: Any, key: string): Map<string, string> | undefined {
    let value = ChannelValue.read(args, key);
    let ret = new Map<string, string>();
    if (value instanceof Map) {
      let map = value as Map<string, Object>;
      map.forEach((v: Object, k: string) => {
        if (typeof v === 'string') {
          ret.set(k, v as string);
        }
      });
      return ret;
    }
    if (ChannelValue.isPlainObject(value)) {
      let record = value as Record<string, Object>;
      for (let k of Object.keys(record)) {
        let v = record[k];
        if (typeof v === 'string') {
          ret.set(k, v as string);
        }
      }
      return ret;
    }
    return undefined;
  }

  override registerEaseListener(): void {
    let manager = ChatClient.getInstance().chatroomManager();
    if (manager === undefined) {
      // SDK not initialized yet; retried lazily on the next method call.
      return;
    }
    if (this.chatroomListener !== undefined) {
      manager.removeListener(this.chatroomListener);
    }
    this.chatroomListener = {
      onMemberJoined: (roomId: string, userId: string, ext?: string): void => {
        let data = new Map<string, Object>();
        data.set('roomId', roomId);
        data.set('participant', userId);
        if (ext !== undefined) {
          data.set('ext', ext);
        }
        data.set('type', ChatRoomEvent.ON_MEMBER_JOINED);
        this.emitEvent(MethodKey.chatRoomChange, data);
      },
      onMemberExited: (roomId: string, roomName: string, userId: string): void => {
        let data = new Map<string, Object>();
        data.set('roomId', roomId);
        data.set('roomName', roomName);
        data.set('participant', userId);
        data.set('type', ChatRoomEvent.ON_MEMBER_EXITED);
        this.emitEvent(MethodKey.chatRoomChange, data);
      },
      onRemovedFromChatroom: (reason: LEAVE_REASON, roomId: string, roomName: string): void => {
        if (reason === LEAVE_REASON.ROOM_DESTROYED) {
          let data = new Map<string, Object>();
          data.set('roomId', roomId);
          data.set('roomName', roomName);
          data.set('type', ChatRoomEvent.ON_CHAT_ROOM_DESTROYED);
          this.emitEvent(MethodKey.chatRoomChange, data);
        } else if (reason === LEAVE_REASON.BE_KICK) {
          let data = new Map<string, Object>();
          data.set('roomId', roomId);
          data.set('roomName', roomName);
          // chatsdk carries no participant here; the removed member is the
          // current user (android gets it from the SDK callback).
          data.set('participant', ChatClient.getInstance().getCurrentUser());
          data.set('reason', reason as number);
          data.set('type', ChatRoomEvent.ON_REMOVED_FROM_CHAT_ROOM);
          this.emitEvent(MethodKey.chatRoomChange, data);
        }
        // LEAVE_REASON.BE_KICKED_FOR_OFFLINE has no Dart event: not emitted.
      },
      // The deprecated onMutelistAdded stays unimplemented, same as android;
      // chatsdk delivers mutes through the Map variant below.
      onMuteMapAdded: (roomId: string, mutes: Map<string, number>): void => {
        let data = new Map<string, Object>();
        data.set('roomId', roomId);
        data.set('mutes', mutes);
        data.set('type', ChatRoomEvent.ON_MUTE_LIST_ADDED);
        this.emitEvent(MethodKey.chatRoomChange, data);
      },
      onMutelistRemoved: (roomId: string, mutes: Array<string>): void => {
        let data = new Map<string, Object>();
        data.set('roomId', roomId);
        data.set('mutes', mutes);
        data.set('type', ChatRoomEvent.ON_MUTE_LIST_REMOVED);
        this.emitEvent(MethodKey.chatRoomChange, data);
      },
      onWhitelistAdded: (roomId: string, whitelist: Array<string>): void => {
        let data = new Map<string, Object>();
        data.set('roomId', roomId);
        data.set('whitelist', whitelist);
        data.set('type', ChatRoomEvent.ON_WHITE_LIST_ADDED);
        this.emitEvent(MethodKey.chatRoomChange, data);
      },
      onWhitelistRemoved: (roomId: string, whitelist: Array<string>): void => {
        let data = new Map<string, Object>();
        data.set('roomId', roomId);
        data.set('whitelist', whitelist);
        data.set('type', ChatRoomEvent.ON_WHITE_LIST_REMOVED);
        this.emitEvent(MethodKey.chatRoomChange, data);
      },
      onAllMemberMuteStateChanged: (roomId: string, isMuted: boolean): void => {
        let data = new Map<string, Object>();
        data.set('roomId', roomId);
        data.set('isMuted', isMuted);
        data.set('type', ChatRoomEvent.ON_ALL_MEMBER_MUTE_STATE_CHANGED);
        this.emitEvent(MethodKey.chatRoomChange, data);
      },
      onAdminAdded: (roomId: string, adminId: string): void => {
        let data = new Map<string, Object>();
        data.set('roomId', roomId);
        data.set('admin', adminId);
        data.set('type', ChatRoomEvent.ON_ADMIN_ADDED);
        this.emitEvent(MethodKey.chatRoomChange, data);
      },
      onAdminRemoved: (roomId: string, adminId: string): void => {
        let data = new Map<string, Object>();
        data.set('roomId', roomId);
        data.set('admin', adminId);
        data.set('type', ChatRoomEvent.ON_ADMIN_REMOVED);
        this.emitEvent(MethodKey.chatRoomChange, data);
      },
      onOwnerChanged: (roomId: string, newOwner: string, oldOwner: string): void => {
        let data = new Map<string, Object>();
        data.set('roomId', roomId);
        data.set('newOwner', newOwner);
        data.set('oldOwner', oldOwner);
        data.set('type', ChatRoomEvent.ON_OWNER_CHANGED);
        this.emitEvent(MethodKey.chatRoomChange, data);
      },
      onAnnouncementChanged: (roomId: string, announcement: string): void => {
        let data = new Map<string, Object>();
        data.set('roomId', roomId);
        data.set('announcement', announcement);
        data.set('type', ChatRoomEvent.ON_ANNOUNCEMENT_CHANGED);
        this.emitEvent(MethodKey.chatRoomChange, data);
      },
      onSpecificationChanged: (room: Chatroom): void => {
        let data = new Map<string, Object>();
        data.set('room', ChatRoomHelper.toJson(room));
        data.set('type', ChatRoomEvent.ON_SPECIFICATION_CHANGED);
        this.emitEvent(MethodKey.chatRoomChange, data);
      },
      onAttributesUpdate: (roomId: string, attributeMap: Map<string, string>, from: string): void => {
        let data = new Map<string, Object>();
        data.set('roomId', roomId);
        data.set('attributes', attributeMap);
        data.set('fromId', from);
        data.set('type', ChatRoomEvent.ON_ATTRIBUTES_UPDATED);
        this.emitEvent(MethodKey.chatRoomChange, data);
      },
      onAttributesRemoved: (roomId: string, keys: Array<string>, from: string): void => {
        let data = new Map<string, Object>();
        data.set('roomId', roomId);
        data.set('keys', keys);
        data.set('fromId', from);
        data.set('type', ChatRoomEvent.ON_ATTRIBUTES_REMOVED);
        this.emitEvent(MethodKey.chatRoomChange, data);
      },
    };
    manager.addListener(this.chatroomListener);
    this.listenerAttached = true;
  }

  override unRegisterEaseListener(): void {
    this.listenerAttached = false;
    if (this.chatroomListener === undefined) {
      return;
    }
    let manager = ChatClient.getInstance().chatroomManager();
    if (manager !== undefined) {
      manager.removeListener(this.chatroomListener);
    }
    this.chatroomListener = undefined;
  }
}
