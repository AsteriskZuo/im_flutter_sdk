import {
  ChatMessage,
  ChatMessageBody,
  ChatMessagePinInfo,
  ChatMessageReaction,
  ChatMessageReactionChange,
  ChatMessageReactionOperation,
  ChatSenderInfo,
  ChatStreamChunk,
  MessageDirection,
  MessageExtType,
  MessageStatus,
} from '@easemob/chatsdk';
import { Any } from '@ohos/flutter_ohos';
import SafetyMapTool from '../SafetyMapTool';
import ChannelValue from './ChannelValue';
import EnumTool from './EnumTool';
import MessageBodyHelper from './MessageBodyHelper';

/**
 * Converts chatsdk ChatMessage to/from the wire format the Dart side expects
 * (mirrors android MessageHelper; field keys must stay identical, the Dart
 * ChatMessage.fromJson deserializes by these keys).
 *
 * Known gaps against android (chatsdk limitations, not hard-coded on purpose;
 * the Dart side defaults them to false):
 *   - isThread: ChatMessage has no chat-thread flag on HarmonyOS.
 *   - isContentReplaced: not exposed by chatsdk on HarmonyOS.
 *   - groupAckCount / hasDeliverAck are server-driven on HarmonyOS and are
 *     not applied in fromJson, same as android (android comments them out).
 */
export default class MessageHelper {
  static fromJson(args: Any): ChatMessage | undefined {
    let bodyMap: Object | null = ChannelValue.read(args, 'body');
    if (bodyMap === null) {
      return undefined;
    }
    let body: ChatMessageBody | undefined = MessageBodyHelper.fromJson(bodyMap);
    if (body === undefined) {
      return undefined;
    }

    let to = SafetyMapTool.getString(args, 'to') ?? '';
    let from = SafetyMapTool.getString(args, 'from') ?? '';
    let msgId = SafetyMapTool.getString(args, 'msgId') ?? '';
    let chatType = EnumTool.chatTypeFromInt(SafetyMapTool.getNumber(args, 'chatType') ?? 0);
    let direction = EnumTool.messageDirectFromInt(SafetyMapTool.getNumber(args, 'direction') ?? 0);

    let message: ChatMessage;
    if (direction === MessageDirection.SEND) {
      message = ChatMessage.createSendMessage(to, body, chatType);
    } else {
      message = ChatMessage.createReceiveMessage(from, body, chatType, msgId);
    }
    message.setTo(to);
    // Never push an empty sender: native send validation rejects the whole
    // message ("Message is invalid") when from is set to an empty string.
    // The SDK fills the current user on send, same as the android wrapper.
    if (from.length > 0) {
      message.setFrom(from);
    }
    message.setReceiverRead(SafetyMapTool.getBoolean(args, 'hasReadAck') ?? false);

    let status = EnumTool.messageStatusFromInt(SafetyMapTool.getNumber(args, 'status') ?? 0);
    if (status === MessageStatus.SUCCESS) {
      message.setUnread(!(SafetyMapTool.getBoolean(args, 'hasRead') ?? false));
    }
    message.setIsNeedGroupAck(SafetyMapTool.getBoolean(args, 'needGroupAck') ?? false);

    let groupAckCount = SafetyMapTool.getNumber(args, 'groupAckCount');
    if (groupAckCount !== undefined) {
      message.setGroupAckCount(groupAckCount);
    }

    message.deliverOnlineOnly(SafetyMapTool.getBoolean(args, 'deliverOnlineOnly') ?? false);
    // Only stamp timestamps when the payload carries real values: native send
    // validation rejects messages whose local timestamp is 0.
    let localTime = SafetyMapTool.getNumber(args, 'localTime');
    if (localTime !== undefined && localTime > 0) {
      message.setLocalTimestamp(localTime);
    }
    let serverTime = SafetyMapTool.getNumber(args, 'serverTime');
    if (serverTime !== undefined) {
      message.setServerTimestamp(serverTime);
    }
    message.setStatus(status);

    let priority = SafetyMapTool.getNumber(args, 'chatroomMessagePriority');
    if (priority !== undefined) {
      message.setPriority(EnumTool.chatRoomMessagePriorityFromInt(priority));
    }

    message.setChatType(chatType);
    if (msgId.length > 0) {
      message.setMsgId(msgId);
    }

    MessageHelper.applyAttributes(message, args);

    let receiverList = SafetyMapTool.getStringArray(args, 'receiverList');
    if (receiverList !== undefined) {
      message.setReceiverList(receiverList);
    }

    let webhookEnv = SafetyMapTool.getString(args, 'webhookEnv');
    if (webhookEnv !== undefined) {
      message.setWebhookEnv(webhookEnv);
    }

    return message;
  }

  static toJson(msg: ChatMessage): Map<string, Object> {
    let data = new Map<string, Object>();
    let body = msg.getBody();
    if (body !== undefined) {
      let bodyData = MessageBodyHelper.toJson(body);
      if (bodyData !== undefined) {
        data.set('body', bodyData);
      }
    }

    let attributes = msg.ext();
    if (attributes.size > 0) {
      data.set('attributes', attributes);
    }
    data.set('from', msg.getFrom());
    data.set('to', msg.getTo());
    data.set('hasReadAck', msg.isReceiverRead());
    data.set('hasDeliverAck', msg.isDelivered());
    data.set('localTime', msg.getLocalTimestamp());
    data.set('serverTime', msg.getServerTimestamp());
    data.set('status', EnumTool.messageStatusToInt(msg.getStatus()));
    data.set('chatType', EnumTool.chatTypeToInt(msg.getChatType()));
    data.set('direction', EnumTool.messageDirectToInt(msg.getDirection()));
    data.set('convId', msg.getConversationId());
    data.set('msgId', msg.getMsgId());
    data.set('hasRead', !msg.isUnread());
    data.set('needGroupAck', msg.isNeedGroupAck());
    data.set('onlineState', msg.isOnlineState());
    data.set('broadcast', msg.isBroadcast());

    let webhookEnv = msg.getWebhookEnv();
    if (webhookEnv !== undefined) {
      data.set('webhookEnv', webhookEnv);
    }

    let senderInfo = msg.getSenderInfo();
    if (senderInfo !== undefined) {
      data.set('senderInfo', MessageHelper.senderInfoToJson(senderInfo));
    }

    let streamChunk = msg.getStreamChunk();
    if (streamChunk !== null) {
      data.set('streamChunk', MessageHelper.streamChunkToJson(streamChunk));
    }

    return data;
  }

  static listToJson(msgs: Array<ChatMessage>): Array<Map<string, Object>> {
    let list = new Array<Map<string, Object>>();
    for (let msg of msgs) {
      list.push(MessageHelper.toJson(msg));
    }
    return list;
  }

  private static senderInfoToJson(info: ChatSenderInfo): Map<string, Object> {
    let data = new Map<string, Object>();
    data.set('userId', info.userId);
    data.set('nickname', info.nickname);
    data.set('avatarUrl', info.avatarUrl);
    data.set('remark', info.remark);
    data.set('groupNameCard', info.namecard);
    return data;
  }

  private static streamChunkToJson(chunk: ChatStreamChunk): Map<string, Object> {
    let data = new Map<string, Object>();
    data.set('status', EnumTool.streamStatusToInt(chunk.status()));
    data.set('errorCode', chunk.errorCode());
    data.set('finishReason', chunk.finishReason());
    data.set('text', chunk.text());
    let customType = chunk.customType();
    if (customType.length > 0) {
      data.set('customType', customType);
    }
    return data;
  }

  /**
   * Applies the "attributes" extension map. Primitive values go through
   * setExt; nested objects/arrays go through setJsonAttribute (mirrors the
   * android JSONObject/JSONArray attribute handling).
   */
  private static applyAttributes(message: ChatMessage, args: Any): void {
    let attributes: Object | null = ChannelValue.read(args, 'attributes');
    if (attributes === null) {
      return;
    }
    let ext = new Map<string, MessageExtType>();
    if (attributes instanceof Map) {
      let map = attributes as Map<string, Object>;
      map.forEach((value: Object, key: string) => {
        MessageHelper.applyAttributeValue(message, ext, key, value);
      });
    } else if (typeof attributes === 'object' && !(attributes instanceof Array)) {
      let record = attributes as Record<string, Object>;
      for (let key of Object.keys(record)) {
        MessageHelper.applyAttributeValue(message, ext, key, record[key]);
      }
    }
    if (ext.size > 0) {
      message.setExt(ext);
    }
  }

  private static applyAttributeValue(
    message: ChatMessage,
    ext: Map<string, MessageExtType>,
    key: string,
    value: Object,
  ): void {
    if (typeof value === 'string') {
      ext.set(key, value as string);
    } else if (typeof value === 'number') {
      ext.set(key, value as number);
    } else if (typeof value === 'boolean') {
      ext.set(key, value as boolean);
    } else if (value instanceof Object) {
      message.setJsonAttribute(key, value as object);
    }
  }
}

/**
 * Serializes chatsdk ChatMessageReaction (mirrors android MessageReactionHelper;
 * keys match the Dart ChatMessageReaction.fromJson).
 */
export class MessageReactionHelper {
  static toJson(reaction: ChatMessageReaction): Map<string, Object> {
    let data = new Map<string, Object>();
    data.set('reaction', reaction.reaction());
    data.set('count', reaction.userCount());
    data.set('isAddedBySelf', reaction.isAddedBySelf());
    data.set('userList', reaction.userIds());
    return data;
  }
}

/**
 * Serializes chatsdk ChatMessageReactionChange (mirrors android
 * MessageReactionChangeHelper; keys match the Dart
 * ChatMessageReactionEvent.fromJson).
 */
export class MessageReactionChangeHelper {
  static toJson(change: ChatMessageReactionChange): Map<string, Object> {
    let data = new Map<string, Object>();
    data.set('convId', change.conversationId());
    data.set('msgId', change.messageId());
    let reactions = new Array<Map<string, Object>>();
    for (let reaction of change.reactions()) {
      reactions.push(MessageReactionHelper.toJson(reaction));
    }
    data.set('reactions', reactions);
    let operations = new Array<Map<string, Object>>();
    for (let operation of change.operations()) {
      operations.push(MessageReactionOperationHelper.toJson(operation));
    }
    data.set('operations', operations);
    return data;
  }
}

/**
 * Serializes chatsdk ChatMessageReactionOperation (mirrors android
 * MessageReactionOperationHelper; keys match the Dart
 * ReactionOperation.fromJson).
 */
export class MessageReactionOperationHelper {
  static toJson(operation: ChatMessageReactionOperation): Map<string, Object> {
    let data = new Map<string, Object>();
    data.set('userId', operation.userId());
    data.set('reaction', operation.reaction());
    data.set('operate', EnumTool.reactionOperationToInt(operation.operation()));
    return data;
  }
}

/**
 * Serializes chatsdk ChatMessagePinInfo (mirrors android MessagePinInfoHelper;
 * keys match the Dart MessagePinInfo.fromJson).
 */
export class MessagePinInfoHelper {
  static toJson(info: ChatMessagePinInfo): Map<string, Object> {
    let data = new Map<string, Object>();
    data.set('pinTime', info.pinTime());
    data.set('operatorId', info.operatorId());
    return data;
  }
}
