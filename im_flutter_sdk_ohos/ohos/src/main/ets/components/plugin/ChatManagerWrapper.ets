import {
  ChatAudioParams,
  ChatCallback,
  ChatClient,
  ChatError,
  ChatManager,
  ChatMessage,
  ChatMessageListener,
  ChatMessagePinInfo,
  ChatMessageReaction,
  ChatMessageReactionChange,
  ContentType,
  Conversation,
  ConversationListener,
  ConversationType,
  CustomMessageBody,
  DownloadStatus,
  FetchMessageOption,
  FetchReactionDetailParams,
  FileMessageBody,
  GroupReadAck,
  ImageMessageBody,
  KeywordListMatchType,
  MarkType,
  MessageExtType,
  MessageSearchOption,
  MessageSearchScope,
  MessageStatus,
  PinOperation,
  RecallMessageInfo,
  SearchDirection,
  SearchServerMessageResult,
  TextMessageBody,
  VideoMessageBody,
} from '@easemob/chatsdk';
import {
  FlutterPluginBinding,
  JSONMethodCodec,
  MethodCall,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import MethodKey from './MethodKeys';
import Wrapper from './Wrapper';
import SafetyMapTool from './SafetyMapTool';
import ChannelValue from './models/ChannelValue';
import EnumTool from './models/EnumTool';
import MessageHelper, {
  MessagePinInfoHelper,
  MessageReactionChangeHelper,
  MessageReactionHelper,
} from './models/MessageHelper';
import MessageBodyHelper from './models/MessageBodyHelper';
import ConversationHelper from './models/ConversationHelper';
import CursorResultHelper from './models/CursorResultHelper';
import PageResultHelper from './models/PageResultHelper';
import FetchHistoryOptionsHelper from './models/FetchHistoryOptionsHelper';
import ConversationFilterHelper from './models/ConversationFilterHelper';
import RecallMessageInfoHelper from './models/RecallMessageInfoHelper';
import GroupAckHelper from './models/GroupAckHelper';
import LanguageHelper from './models/LanguageHelper';
import ChatAudioParamsHelper from './models/ChatAudioParamsHelper';
import SearchServerMessageResultHelper from './models/SearchServerMessageResultHelper';

/**
 * Wrapper for the `com.chat.im/chat_manager` channel.
 *
 * Implements every chat_manager method key kept in the ohos-branch Dart
 * constants (the set after the T2.0a removal: getThreadConversation,
 * fetchConversationsFromServerWithPage, deleteMessagesBeforeTimestamp and
 * reportMessage are gone and have no branch here), plus the ChatMessageListener
 * / ConversationListener event forwarding.
 *
 * Adaptation notes (gap-ledger 16.1):
 *  - sendMessage / resendMessage follow the android two-step contract: the
 *    channel call returns the message JSON immediately, send success /
 *    progress / error are delivered later as chat_message channel events
 *    (onMessageSuccess / onMessageProgressUpdate / onMessageError) through the
 *    message-level ChatCallback. resendMessage reuses the same path with the
 *    message reset to CREATE status first.
 *  - getUnreadMessageCount is a sum over every conversation's unread count
 *    (chatsdk has no aggregate API).
 *  - downloadMessageAttachmentInCombine / downloadMessageThumbnailInCombine
 *    locate the sub message (local DB hit, otherwise parse the conversation's
 *    combine messages and match by message id) before downloading.
 *  - Download results/progress travel through the message-level ChatCallback
 *    exactly like send results; the Promise returned by the chatsdk download
 *    methods is consumed silently to avoid unhandled rejections.
 *  - chatsdk merges android's onMessageRecalled and onMessageRecalledWithExt
 *    into one callback; both channel events (onMessagesRecalled and
 *    onMessagesRecalledInfo) are emitted from it.
 *  - The removed chat_message ack events (onMessageReadAck /
 *    onMessageDeliveryAck) are intentionally not emitted; onMessageChanged is
 *    a backlog orphan constant and is not wired either.
 *
 * Listener registration cannot run in the constructor (android/ios register
 * there) because ChatClient.chatManager() is undefined before ChatClient.init;
 * it runs on the first onMethodCall and eagerly right after a successful init
 * (see ImFlutterSdkPlugin.onAttachedToEngine). registeredManager guards
 * re-registration when the listener set moves to a new manager instance.
 */
export default class ChatManagerWrapper extends Wrapper {
  private messageChannel: MethodChannel;
  private messageListener: ChatMessageListener | undefined;
  private conversationListener: ConversationListener | undefined;
  private registeredManager: ChatManager | undefined;

  constructor(binding: FlutterPluginBinding, channelName: string) {
    super(binding, channelName);
    // Invoke-only channel for message send/download events, mirroring the
    // android ChatManagerWrapper.messageChannel. MessageWrapper owns the
    // handler side of this channel.
    this.messageChannel = new MethodChannel(
      binding.getBinaryMessenger(),
      'com.chat.im/chat_message',
      JSONMethodCodec.INSTANCE,
    );
  }

  override onMethodCall(call: MethodCall, result: MethodResult): void {
    this.registerEaseListener();
    if (MethodKey.sendMessage === call.method) {
      this.sendMessage(call, result);
    } else if (MethodKey.resendMessage === call.method) {
      this.resendMessage(call, result);
    } else if (MethodKey.ackMessageRead === call.method) {
      this.ackMessageRead(call, result);
    } else if (MethodKey.ackGroupMessageRead === call.method) {
      this.ackGroupMessageRead(call, result);
    } else if (MethodKey.ackConversationRead === call.method) {
      this.ackConversationRead(call, result);
    } else if (MethodKey.recallMessage === call.method) {
      this.recallMessage(call, result);
    } else if (MethodKey.getConversation === call.method) {
      this.getConversation(call, result);
    } else if (MethodKey.markAllChatMsgAsRead === call.method) {
      this.markAllChatMsgAsRead(call, result);
    } else if (MethodKey.getUnreadMessageCount === call.method) {
      this.getUnreadMessageCount(call, result);
    } else if (MethodKey.updateChatMessage === call.method) {
      this.updateChatMessage(call, result);
    } else if (MethodKey.downloadAttachment === call.method) {
      this.downloadAttachment(call, result);
    } else if (MethodKey.downloadThumbnail === call.method) {
      this.downloadThumbnail(call, result);
    } else if (MethodKey.downloadMessageAttachmentInCombine === call.method) {
      this.downloadMessageAttachmentInCombine(call, result);
    } else if (MethodKey.downloadMessageThumbnailInCombine === call.method) {
      this.downloadMessageThumbnailInCombine(call, result);
    } else if (MethodKey.importMessages === call.method) {
      this.importMessages(call, result);
    } else if (MethodKey.loadAllConversations === call.method) {
      this.loadAllConversations(call, result);
    } else if (MethodKey.getConversationsFromServer === call.method) {
      this.getConversationsFromServer(call, result);
    } else if (MethodKey.deleteConversation === call.method) {
      this.deleteConversation(call, result);
    } else if (MethodKey.fetchHistoryMessages === call.method) {
      this.fetchHistoryMessages(call, result);
    } else if (MethodKey.fetchHistoryMessagesByOptions === call.method) {
      this.fetchHistoryMessagesByOptions(call, result);
    } else if (MethodKey.searchChatMsgFromDB === call.method) {
      this.searchChatMsgFromDB(call, result);
    } else if (MethodKey.getMessage === call.method) {
      this.getMessage(call, result);
    } else if (MethodKey.asyncFetchGroupAcks === call.method) {
      this.asyncFetchGroupAcks(call, result);
    } else if (MethodKey.deleteRemoteConversation === call.method) {
      this.deleteRemoteConversation(call, result);
    } else if (MethodKey.translateMessage === call.method) {
      this.translateMessage(call, result);
    } else if (MethodKey.fetchSupportLanguages === call.method) {
      this.fetchSupportLanguages(call, result);
    } else if (MethodKey.addReaction === call.method) {
      this.addReaction(call, result);
    } else if (MethodKey.removeReaction === call.method) {
      this.removeReaction(call, result);
    } else if (MethodKey.fetchReactionList === call.method) {
      this.fetchReactionList(call, result);
    } else if (MethodKey.fetchReactionDetail === call.method) {
      this.fetchReactionDetail(call, result);
    } else if (MethodKey.removeMessagesFromServerWithMsgIds === call.method) {
      this.removeMessagesFromServerWithMsgIds(call, result);
    } else if (MethodKey.removeMessagesFromServerWithTs === call.method) {
      this.removeMessagesFromServerWithTs(call, result);
    } else if (MethodKey.getConversationsFromServerWithCursor === call.method) {
      this.getConversationsFromServerWithCursor(call, result);
    } else if (MethodKey.getPinnedConversationsFromServerWithCursor === call.method) {
      this.getPinnedConversationsFromServerWithCursor(call, result);
    } else if (MethodKey.getConversationsFromDBWithCursor === call.method) {
      this.getConversationsFromDBWithCursor(call, result);
    } else if (MethodKey.pinConversation === call.method) {
      this.pinConversation(call, result);
    } else if (MethodKey.modifyMessage === call.method) {
      this.modifyMessage(call, result);
    } else if (MethodKey.downloadAndParseCombineMessage === call.method) {
      this.downloadAndParseCombineMessage(call, result);
    } else if (MethodKey.addRemoteAndLocalConversationsMark === call.method) {
      this.addRemoteAndLocalConversationsMark(call, result);
    } else if (MethodKey.deleteRemoteAndLocalConversationsMark === call.method) {
      this.deleteRemoteAndLocalConversationsMark(call, result);
    } else if (MethodKey.fetchConversationsByOptions === call.method) {
      this.fetchConversationsByOptions(call, result);
    } else if (MethodKey.deleteAllMessageAndConversation === call.method) {
      this.deleteAllMessageAndConversation(call, result);
    } else if (MethodKey.pinMessage === call.method) {
      this.pinMessage(call, result);
    } else if (MethodKey.unpinMessage === call.method) {
      this.unpinMessage(call, result);
    } else if (MethodKey.fetchPinnedMessages === call.method) {
      this.fetchPinnedMessages(call, result);
    } else if (MethodKey.searchMsgsByOptions === call.method) {
      this.searchMsgsByOptions(call, result);
    } else if (MethodKey.getMessageCount === call.method) {
      this.getMessageCount(call, result);
    } else if (MethodKey.loadConversationMessagesWithKeyword === call.method) {
      this.loadConversationMessagesWithKeyword(call, result);
    } else if (MethodKey.loadMessagesWithIds === call.method) {
      this.loadMessagesWithIds(call, result);
    } else if (MethodKey.searchMessagesFromServer === call.method) {
      this.searchMessagesFromServer(call, result);
    } else if (MethodKey.downloadBigImage === call.method) {
      this.downloadBigImage(call, result);
    } else if (MethodKey.voiceMessageToText === call.method) {
      this.voiceMessageToText(call, result);
    } else if (MethodKey.voiceFileToText === call.method) {
      this.voiceFileToText(call, result);
    } else {
      super.onMethodCall(call, result);
    }
  }

  private requireManager(result: MethodResult): ChatManager | undefined {
    let manager = ChatClient.getInstance().chatManager();
    if (manager === undefined) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR, 'ChatManager unavailable: SDK not initialized');
    }
    return manager;
  }

  private sendMessage(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let msg = MessageHelper.fromJson(call.args);
    if (msg === undefined) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR, 'The message is invalid.');
      return;
    }
    this.sendWithCallback(result, call.method, manager, msg);
  }

  private resendMessage(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let tempMsg = MessageHelper.fromJson(call.args);
    if (tempMsg === undefined) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR, 'The message is invalid.');
      return;
    }
    // Re-send the database copy when it exists, same as android.
    let msg = manager.getMessage(tempMsg.getMsgId()) ?? tempMsg;
    msg.setStatus(MessageStatus.CREATE);
    this.sendWithCallback(result, call.method, manager, msg);
  }

  /**
   * Shared send path (android sendMessage / resendMessage): register the
   * status callback, kick off the send, then answer the channel call at once
   * with the current message JSON. The outcome arrives later as chat_message
   * channel events.
   */
  private sendWithCallback(result: MethodResult, method: string, manager: ChatManager, msg: ChatMessage): void {
    let localId = msg.getMsgId();
    msg.setMessageStatusCallback(this.messageEventCallback(msg, localId, undefined));
    try {
      manager.sendMessage(msg);
    } catch (e) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR, `sendMessage failed: ${JSON.stringify(e)}`);
      return;
    }
    this.onSuccess(result, method, MessageHelper.toJson(msg));
  }

  /**
   * Builds the ChatCallback forwarding send/download progress and outcomes to
   * the chat_message channel (mirrors the android EMWrapperCallBack usage).
   * isThumbnail is undefined for sends (no download-status patching), true for
   * thumbnail downloads and false for attachment / big-image downloads.
   */
  private messageEventCallback(msg: ChatMessage, localId: string, isThumbnail: boolean | undefined): ChatCallback {
    let callback: ChatCallback = {
      onSuccess: (): void => {
        let data = new Map<string, Object>();
        data.set('message', isThumbnail === undefined
          ? MessageHelper.toJson(msg)
          : this.updateDownloadStatus(DownloadStatus.SUCCESS, msg, isThumbnail));
        data.set('localId', localId);
        this.messageChannel.invokeMethod(MethodKey.onMessageSuccess, data);
      },
      onProgress: (progress: number): void => {
        let data = new Map<string, Object>();
        data.set('progress', progress);
        data.set('localId', localId);
        this.messageChannel.invokeMethod(MethodKey.onMessageProgressUpdate, data);
      },
      onError: (code: number, error: string): void => {
        let errorData = new Map<string, Object>();
        errorData.set('code', code);
        errorData.set('description', error);
        let data = new Map<string, Object>();
        data.set('message', isThumbnail === undefined
          ? MessageHelper.toJson(msg)
          : this.updateDownloadStatus(DownloadStatus.FAILED, msg, isThumbnail));
        data.set('localId', localId);
        data.set('error', errorData);
        this.messageChannel.invokeMethod(MethodKey.onMessageError, data);
      },
    };
    return callback;
  }

  /**
   * Patches the body's (thumbnail) download status before serializing,
   * mirroring android updateDownloadStatus: FILE/VOICE bodies ignore thumbnail
   * updates; IMAGE/VIDEO bodies route to the thumbnail status when requested.
   */
  private updateDownloadStatus(status: DownloadStatus, msg: ChatMessage, isThumbnail: boolean): Map<string, Object> {
    let body = msg.getBody();
    if (body !== undefined) {
      let type = body.type();
      if (type === ContentType.FILE || type === ContentType.VOICE) {
        if (!isThumbnail) {
          (body as FileMessageBody).setDownloadStatus(status);
        }
      } else if (type === ContentType.IMAGE) {
        let imageBody = body as ImageMessageBody;
        if (isThumbnail) {
          imageBody.setThumbnailDownloadStatus(status);
        } else {
          imageBody.setDownloadStatus(status);
        }
      } else if (type === ContentType.VIDEO) {
        let videoBody = body as VideoMessageBody;
        if (isThumbnail) {
          videoBody.setThumbnailDownloadStatus(status);
        } else {
          videoBody.setDownloadStatus(status);
        }
      }
    }
    return MessageHelper.toJson(msg);
  }

  /**
   * Shared download path: register the status callback, start the download,
   * then answer the channel call at once with a DOWNLOADING-status message.
   * Events (progress/success/error) flow through the ChatCallback; the chatsdk
   * Promise carries the same outcome, so it is consumed silently.
   */
  private startDownload(
    result: MethodResult,
    method: string,
    manager: ChatManager,
    msg: ChatMessage,
    isThumbnail: boolean,
    bigImage: boolean,
  ): void {
    msg.setMessageStatusCallback(this.messageEventCallback(msg, msg.getMsgId(), isThumbnail));
    let promise: Promise<void>;
    if (bigImage) {
      promise = manager.downloadBigImage(msg);
    } else if (isThumbnail) {
      promise = manager.downloadThumbnail(msg);
    } else {
      promise = manager.downloadAttachment(msg);
    }
    promise.then(() => {}).catch(() => {});
    this.onSuccess(result, method, this.updateDownloadStatus(DownloadStatus.DOWNLOADING, msg, isThumbnail));
  }

  /**
   * Resolves the database copy of the message carried in the "message"
   * argument (downloads operate on the DB message, same as android).
   */
  private dbMessageFromArgs(result: MethodResult, manager: ChatManager, args: Object | null): ChatMessage | undefined {
    let tempMsg = MessageHelper.fromJson(args);
    if (tempMsg === undefined) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR, 'The message is invalid.');
      return undefined;
    }
    let msg = manager.getMessage(tempMsg.getMsgId());
    if (msg === undefined) {
      this.onErrorInfo(result, 500, 'The message was not found');
    }
    return msg;
  }

  private downloadAttachment(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let msg = this.dbMessageFromArgs(result, manager, ChannelValue.read(call.args, 'message'));
    if (msg === undefined) {
      return;
    }
    this.startDownload(result, call.method, manager, msg, false, false);
  }

  private downloadThumbnail(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let msg = this.dbMessageFromArgs(result, manager, ChannelValue.read(call.args, 'message'));
    if (msg === undefined) {
      return;
    }
    this.startDownload(result, call.method, manager, msg, true, false);
  }

  private downloadBigImage(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let msg = this.dbMessageFromArgs(result, manager, ChannelValue.read(call.args, 'message'));
    if (msg === undefined) {
      return;
    }
    this.startDownload(result, call.method, manager, msg, false, true);
  }

  private downloadMessageAttachmentInCombine(call: MethodCall, result: MethodResult): void {
    this.downloadInCombine(call, result, false);
  }

  private downloadMessageThumbnailInCombine(call: MethodCall, result: MethodResult): void {
    this.downloadInCombine(call, result, true);
  }

  private downloadInCombine(call: MethodCall, result: MethodResult, isThumbnail: boolean): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let msgJson = ChannelValue.read(call.args, 'message');
    let msg = MessageHelper.fromJson(msgJson);
    if (msg === undefined) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR, 'The message is invalid.');
      return;
    }
    let subMsgId = msg.getMsgId();
    // Fast path: the sub message is a regular local message.
    let dbMsg = manager.getMessage(subMsgId);
    if (dbMsg !== undefined) {
      this.startDownload(result, call.method, manager, dbMsg, isThumbnail, false);
      return;
    }
    this.downloadInCombineAsync(result, call.method, manager, msg, msgJson, isThumbnail)
      .catch(() => {});
  }

  /**
   * Confirmed two-step (gap-ledger 16.1 #7): parse the conversation's combine
   * messages, locate the sub message by message id, then download it. Scans
   * at most 400 recent combine messages; falls back to downloading the
   * message rebuilt from the channel payload (the android/iOS behavior).
   */
  private async downloadInCombineAsync(
    result: MethodResult,
    method: string,
    manager: ChatManager,
    msg: ChatMessage,
    msgJson: Object | null,
    isThumbnail: boolean,
  ): Promise<void> {
    let subMsgId = msg.getMsgId();
    try {
      let convId = SafetyMapTool.getString(msgJson, 'convId');
      if (convId !== undefined && convId.length > 0) {
        let convType = EnumTool.conversationTypeFromInt(EnumTool.chatTypeToInt(msg.getChatType()));
        let conversation = manager.getConversation(convId, convType, false);
        if (conversation !== undefined) {
          let combineMessages = await conversation.searchMessagesByType(ContentType.COMBINE, -1, 400);
          for (let combineMsg of combineMessages) {
            let subMessages = await manager.downloadAndParseCombineMessage(combineMsg);
            for (let sub of subMessages) {
              if (sub.getMsgId() === subMsgId) {
                this.startDownload(result, method, manager, sub, isThumbnail, false);
                return;
              }
            }
          }
        }
      }
    } catch (e) {
      // Fall through to the JSON-built message below.
    }
    this.startDownload(result, method, manager, msg, isThumbnail, false);
  }

  private ackMessageRead(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let msgId = SafetyMapTool.getString(call.args, 'msgId') ?? '';
    let to = SafetyMapTool.getString(call.args, 'to') ?? '';
    try {
      manager.ackMessageRead(to, msgId);
      this.onSuccess(result, call.method, true);
    } catch (e) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR, `ackMessageRead failed: ${JSON.stringify(e)}`);
    }
  }

  private ackGroupMessageRead(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let msgId = SafetyMapTool.getString(call.args, 'msgId') ?? '';
    let content = SafetyMapTool.getString(call.args, 'content') ?? '';
    let msg = manager.getMessage(msgId);
    if (msg === undefined) {
      this.onErrorInfo(result, 500, 'The message was not found');
      return;
    }
    try {
      manager.ackGroupMessageRead(msg, content);
      this.onSuccess(result, call.method, true);
    } catch (e) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR, `ackGroupMessageRead failed: ${JSON.stringify(e)}`);
    }
  }

  private ackConversationRead(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let conversationId = SafetyMapTool.getString(call.args, 'convId') ?? '';
    try {
      manager.ackConversationRead(conversationId);
      this.onSuccess(result, call.method, true);
    } catch (e) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR, `ackConversationRead failed: ${JSON.stringify(e)}`);
    }
  }

  private recallMessage(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let msgId = SafetyMapTool.getString(call.args, 'msgId') ?? '';
    let ext = SafetyMapTool.getString(call.args, 'ext');
    let msg = manager.getMessage(msgId);
    if (msg === undefined) {
      this.onErrorInfo(result, 500, 'The message was not found');
      return;
    }
    this.handlePromise(result, call.method, manager.recallMessage(msg, ext), () => true);
  }

  private getMessage(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let msgId = SafetyMapTool.getString(call.args, 'msgId') ?? '';
    let msg = manager.getMessage(msgId);
    this.onSuccess(result, call.method, msg !== undefined ? MessageHelper.toJson(msg) : null);
  }

  private getConversation(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let convId = SafetyMapTool.getString(call.args, 'convId') ?? '';
    let type = EnumTool.conversationTypeFromInt(SafetyMapTool.getNumber(call.args, 'type') ?? 0);
    let createIfNeed = SafetyMapTool.getBoolean(call.args, 'createIfNeed') ?? true;
    let conversation = manager.getConversation(convId, type, createIfNeed);
    this.onSuccess(result, call.method,
      conversation !== undefined ? ConversationHelper.toJson(conversation) : null);
  }

  private markAllChatMsgAsRead(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    try {
      manager.markAllConversationsAsRead();
      this.onSuccess(result, call.method, true);
    } catch (e) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR, `markAllConversationsAsRead failed: ${JSON.stringify(e)}`);
    }
  }

  private getUnreadMessageCount(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    // chatsdk has no aggregate unread-count API; sum every conversation.
    let count = 0;
    let conversations = manager.getConversations();
    for (let conversation of conversations) {
      count += conversation.getUnreadMsgCount();
    }
    this.onSuccess(result, call.method, count);
  }

  private updateChatMessage(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let tempMsg = MessageHelper.fromJson(ChannelValue.read(call.args, 'message'));
    if (tempMsg === undefined) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR, 'The message is invalid.');
      return;
    }
    let dbMsg = manager.getMessage(tempMsg.getMsgId());
    if (dbMsg === undefined) {
      this.onErrorInfo(result, 500, 'The message is invalid.');
      return;
    }
    // Mirrors android HelpTool.mergeMessage (minus thread / listened / deliver
    // flags, which chatsdk does not expose publicly).
    dbMsg.setServerTimestamp(tempMsg.getServerTimestamp());
    dbMsg.setLocalTimestamp(tempMsg.getLocalTimestamp());
    dbMsg.setStatus(tempMsg.getStatus());
    dbMsg.setReceiverRead(tempMsg.isReceiverRead());
    dbMsg.setIsNeedGroupAck(tempMsg.isNeedGroupAck());
    dbMsg.setUnread(tempMsg.isUnread());
    dbMsg.deliverOnlineOnly(tempMsg.isDeliverOnlineOnly());
    dbMsg.setReceiverList(tempMsg.receiverList());
    let attributes = tempMsg.ext();
    if (attributes.size > 0) {
      dbMsg.setExt(attributes);
    }
    let body = tempMsg.getBody();
    if (body !== undefined) {
      dbMsg.setBody(body);
    }
    manager.updateMessage(dbMsg);
    this.onSuccess(result, call.method, MessageHelper.toJson(dbMsg));
  }

  private importMessages(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let messages = new Array<ChatMessage>();
    let raw = ChannelValue.read(call.args, 'messages');
    if (raw instanceof Array) {
      let items = raw as Array<Object>;
      for (let item of items) {
        let msg = MessageHelper.fromJson(item);
        if (msg !== undefined) {
          messages.push(msg);
        }
      }
    }
    this.handlePromise(result, call.method, manager.importMessages(messages));
  }

  private loadAllConversations(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    if (ChatClient.getInstance().getCurrentUser().length === 0) {
      this.onSuccess(result, call.method, new Array<Map<string, Object>>());
      return;
    }
    this.onSuccess(result, call.method,
      ConversationHelper.listToJson(manager.getAllConversationsBySort()));
  }

  private getConversationsFromServer(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    // The deprecated Flutter API expects the full conversation list, so page
    // through fetchConversationsFromServer until the cursor is exhausted.
    this.handlePromise(result, call.method, this.fetchAllServerConversations(manager),
      (conversations) => ConversationHelper.listToJson(conversations));
  }

  private async fetchAllServerConversations(manager: ChatManager): Promise<Array<Conversation>> {
    let all = new Array<Conversation>();
    let cursor = '';
    for (;;) {
      let page = await manager.fetchConversationsFromServer(50, cursor);
      let items = page.getResult();
      for (let conversation of items) {
        all.push(conversation);
      }
      let next = page.getNextCursor();
      if (next.length === 0 || next === cursor || items.length === 0) {
        break;
      }
      cursor = next;
    }
    return all;
  }

  private deleteConversation(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let convId = SafetyMapTool.getString(call.args, 'convId') ?? '';
    let deleteMessages = SafetyMapTool.getBoolean(call.args, 'deleteMessages') ?? false;
    try {
      let ret = manager.deleteConversation(convId, deleteMessages);
      this.onSuccess(result, call.method, ret);
    } catch (e) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR, `deleteConversation failed: ${JSON.stringify(e)}`);
    }
  }

  private fetchHistoryMessages(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let convId = SafetyMapTool.getString(call.args, 'convId') ?? '';
    let type = EnumTool.conversationTypeFromInt(SafetyMapTool.getNumber(call.args, 'type') ?? 0);
    let pageSize = SafetyMapTool.getNumber(call.args, 'pageSize') ?? 20;
    let startMsgId = SafetyMapTool.getString(call.args, 'startMsgId') ?? '';
    // The chatsdk overload takes the search direction through FetchMessageOption.
    let option = new FetchMessageOption();
    option.setDirection(EnumTool.searchDirectionFromInt(SafetyMapTool.getNumber(call.args, 'direction') ?? 0));
    this.handlePromise(result, call.method,
      manager.fetchHistoryMessages(convId, type, pageSize, startMsgId, option),
      (r) => CursorResultHelper.toJson<ChatMessage>(r, (msg) => MessageHelper.toJson(msg)));
  }

  private fetchHistoryMessagesByOptions(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let convId = SafetyMapTool.getString(call.args, 'convId') ?? '';
    let type = EnumTool.conversationTypeFromInt(SafetyMapTool.getNumber(call.args, 'type') ?? 0);
    let pageSize = SafetyMapTool.getNumber(call.args, 'pageSize') ?? 20;
    let cursor = SafetyMapTool.getString(call.args, 'cursor') ?? '';
    let optionJson = ChannelValue.read(call.args, 'options');
    let option: FetchMessageOption | undefined = undefined;
    if (optionJson !== null) {
      option = FetchHistoryOptionsHelper.fromJson(optionJson);
    }
    this.handlePromise(result, call.method,
      manager.fetchHistoryMessages(convId, type, pageSize, cursor, option),
      (r) => CursorResultHelper.toJson<ChatMessage>(r, (msg) => MessageHelper.toJson(msg)));
  }

  private searchChatMsgFromDB(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let keywords = SafetyMapTool.getString(call.args, 'keywords') ?? '';
    let timestamp = SafetyMapTool.getNumber(call.args, 'timestamp') ?? -1;
    let count = SafetyMapTool.getNumber(call.args, 'count') ?? 20;
    let from = SafetyMapTool.getString(call.args, 'from') ?? '';
    let direction = EnumTool.searchDirectionFromInt(SafetyMapTool.getNumber(call.args, 'direction') ?? 0);
    let scopeValue = SafetyMapTool.getNumber(call.args, 'searchScope');
    let scope = scopeValue !== undefined ? scopeValue as MessageSearchScope : MessageSearchScope.ALL;
    this.handlePromise(result, call.method,
      manager.searchMessagesFromDB(keywords, timestamp, count, from, direction, scope),
      (msgs) => MessageHelper.listToJson(msgs));
  }

  private asyncFetchGroupAcks(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let msgId = SafetyMapTool.getString(call.args, 'msgId') ?? '';
    let ackId = SafetyMapTool.getString(call.args, 'ack_id') ?? '';
    let pageSize = SafetyMapTool.getNumber(call.args, 'pageSize') ?? 20;
    this.handlePromise(result, call.method,
      manager.fetchGroupReadAcks(msgId, pageSize, ackId),
      (r) => CursorResultHelper.toJson<GroupReadAck>(r, (ack) => GroupAckHelper.toJson(ack)));
  }

  private deleteRemoteConversation(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let convId = SafetyMapTool.getString(call.args, 'convId') ?? '';
    let type = EnumTool.conversationTypeFromInt(SafetyMapTool.getNumber(call.args, 'conversationType') ?? 0);
    let isDeleteRemoteMessage = SafetyMapTool.getBoolean(call.args, 'isDeleteRemoteMessage') ?? false;
    this.handlePromise(result, call.method,
      manager.deleteConversationFromServer(convId, type, isDeleteRemoteMessage));
  }

  private translateMessage(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let tempMsg = MessageHelper.fromJson(ChannelValue.read(call.args, 'message'));
    if (tempMsg === undefined) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR, 'The message is invalid.');
      return;
    }
    let languages = SafetyMapTool.getStringArray(call.args, 'languages') ?? [];
    let dbMsg = manager.getMessage(tempMsg.getMsgId());
    if (dbMsg === undefined) {
      this.onErrorInfo(result, 500, 'The message is invalid.');
      return;
    }
    this.handlePromise(result, call.method,
      manager.translateMessage(dbMsg, languages),
      (msg) => MessageHelper.toJson(msg));
  }

  private fetchSupportLanguages(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    this.handlePromise(result, call.method, manager.fetchSupportLanguages(),
      (languages) => LanguageHelper.listToJson(languages));
  }

  private addReaction(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let reaction = SafetyMapTool.getString(call.args, 'reaction') ?? '';
    let msgId = SafetyMapTool.getString(call.args, 'msgId') ?? '';
    this.handlePromise(result, call.method, manager.addReaction(msgId, reaction));
  }

  private removeReaction(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let reaction = SafetyMapTool.getString(call.args, 'reaction') ?? '';
    let msgId = SafetyMapTool.getString(call.args, 'msgId') ?? '';
    this.handlePromise(result, call.method, manager.removeReaction(msgId, reaction));
  }

  private fetchReactionList(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let msgIds = SafetyMapTool.getStringArray(call.args, 'msgIds') ?? [];
    let chatType = EnumTool.chatTypeFromInt(SafetyMapTool.getNumber(call.args, 'chatType') ?? 0);
    let groupId = SafetyMapTool.getString(call.args, 'groupId');
    this.handlePromise(result, call.method,
      manager.fetchReactions(msgIds, chatType, groupId),
      (reactionMap: Map<string, Array<ChatMessageReaction>>) => {
        let data = new Map<string, Object>();
        reactionMap.forEach((reactions: Array<ChatMessageReaction>, msgId: string) => {
          let list = new Array<Map<string, Object>>();
          for (let reaction of reactions) {
            list.push(MessageReactionHelper.toJson(reaction));
          }
          data.set(msgId, list);
        });
        return data;
      });
  }

  private fetchReactionDetail(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let params = new FetchReactionDetailParams();
    params.messageId = SafetyMapTool.getString(call.args, 'msgId') ?? '';
    params.reaction = SafetyMapTool.getString(call.args, 'reaction') ?? '';
    params.pageSize = SafetyMapTool.getNumber(call.args, 'pageSize') ?? 20;
    let cursor = SafetyMapTool.getString(call.args, 'cursor');
    if (cursor !== undefined) {
      params.cursor = cursor;
    }
    this.handlePromise(result, call.method, manager.fetchReactionDetail(params),
      (r) => CursorResultHelper.toJson<ChatMessageReaction>(r, (item) => MessageReactionHelper.toJson(item)));
  }

  private removeMessagesFromServerWithMsgIds(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let convId = SafetyMapTool.getString(call.args, 'convId') ?? '';
    let type = EnumTool.conversationTypeFromInt(SafetyMapTool.getNumber(call.args, 'type') ?? 0);
    let msgIds = SafetyMapTool.getStringArray(call.args, 'msgIds') ?? [];
    this.handlePromise(result, call.method, manager.removeMessagesFromServer(convId, type, msgIds));
  }

  private removeMessagesFromServerWithTs(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let convId = SafetyMapTool.getString(call.args, 'convId') ?? '';
    let type = EnumTool.conversationTypeFromInt(SafetyMapTool.getNumber(call.args, 'type') ?? 0);
    let timestamp = SafetyMapTool.getNumber(call.args, 'timestamp') ?? 0;
    this.handlePromise(result, call.method, manager.removeMessagesFromServer(convId, type, timestamp));
  }

  private getConversationsFromServerWithCursor(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let cursor = SafetyMapTool.getString(call.args, 'cursor') ?? '';
    let pageSize = SafetyMapTool.getNumber(call.args, 'pageSize') ?? 20;
    this.handlePromise(result, call.method,
      manager.fetchConversationsFromServer(pageSize, cursor),
      (r) => CursorResultHelper.toJson<Conversation>(r, (c) => ConversationHelper.toJson(c)));
  }

  private getPinnedConversationsFromServerWithCursor(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let cursor = SafetyMapTool.getString(call.args, 'cursor') ?? '';
    let pageSize = SafetyMapTool.getNumber(call.args, 'pageSize') ?? 20;
    this.handlePromise(result, call.method,
      manager.fetchPinnedConversationsFromServer(pageSize, cursor),
      (r) => CursorResultHelper.toJson<Conversation>(r, (c) => ConversationHelper.toJson(c)));
  }

  private getConversationsFromDBWithCursor(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let cursor = SafetyMapTool.getString(call.args, 'cursor') ?? '';
    let pageSize = SafetyMapTool.getNumber(call.args, 'pageSize') ?? 20;
    this.handlePromise(result, call.method,
      manager.getConversationsFromDB(cursor, pageSize),
      (r) => CursorResultHelper.toJson<Conversation>(r, (c) => ConversationHelper.toJson(c)));
  }

  private pinConversation(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let convId = SafetyMapTool.getString(call.args, 'convId') ?? '';
    let isPinned = SafetyMapTool.getBoolean(call.args, 'isPinned') ?? false;
    this.handlePromise(result, call.method, manager.pinConversation(convId, isPinned));
  }

  private modifyMessage(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let msgId = SafetyMapTool.getString(call.args, 'msgId') ?? '';
    // chatsdk only accepts Text / Custom modified bodies.
    let body: TextMessageBody | CustomMessageBody | null = null;
    let bodyJson = ChannelValue.read(call.args, 'msgBody');
    if (bodyJson !== null) {
      let parsed = MessageBodyHelper.fromJson(bodyJson);
      if (parsed instanceof TextMessageBody || parsed instanceof CustomMessageBody) {
        body = parsed;
      }
    }
    let ext: Map<string, MessageExtType> | null = null;
    let attributes = ChannelValue.read(call.args, 'attributes');
    if (attributes !== null) {
      let map = new Map<string, MessageExtType>();
      if (attributes instanceof Map) {
        let record = attributes as Map<string, Object>;
        record.forEach((value: Object, key: string) => {
          map.set(key, value as MessageExtType);
        });
      } else if (ChannelValue.isPlainObject(attributes)) {
        let record = attributes as Record<string, Object>;
        for (let key of Object.keys(record)) {
          map.set(key, record[key] as MessageExtType);
        }
      }
      if (map.size > 0) {
        ext = map;
      }
    }
    this.handlePromise(result, call.method, manager.modifyMessage(msgId, body, ext),
      (msg) => MessageHelper.toJson(msg));
  }

  private downloadAndParseCombineMessage(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let msg = MessageHelper.fromJson(ChannelValue.read(call.args, 'message'));
    if (msg === undefined) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR, 'The message is invalid.');
      return;
    }
    this.handlePromise(result, call.method, manager.downloadAndParseCombineMessage(msg),
      (msgs) => MessageHelper.listToJson(msgs));
  }

  private addRemoteAndLocalConversationsMark(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let convIds = SafetyMapTool.getStringArray(call.args, 'convIds') ?? [];
    let mark = (SafetyMapTool.getNumber(call.args, 'mark') ?? 0) as MarkType;
    this.handlePromise(result, call.method, manager.addConversationMark(convIds, mark));
  }

  private deleteRemoteAndLocalConversationsMark(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let convIds = SafetyMapTool.getStringArray(call.args, 'convIds') ?? [];
    let mark = (SafetyMapTool.getNumber(call.args, 'mark') ?? 0) as MarkType;
    this.handlePromise(result, call.method, manager.removeConversationMark(convIds, mark));
  }

  private fetchConversationsByOptions(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    // Same dispatch as android: pinned list, mark-filtered list, plain list.
    let cursor = ConversationFilterHelper.cursor(call.args) ?? '';
    let pageSize = ConversationFilterHelper.pageSize(call.args);
    if (ConversationFilterHelper.pinned(call.args)) {
      this.handlePromise(result, call.method,
        manager.fetchPinnedConversationsFromServer(pageSize, cursor),
        (r) => CursorResultHelper.toJson<Conversation>(r, (c) => ConversationHelper.toJson(c)));
      return;
    }
    if (ConversationFilterHelper.hasMark(call.args)) {
      let filter = ConversationFilterHelper.fromJson(call.args);
      this.handlePromise(result, call.method,
        manager.fetchConversationsFromServerWithFilter(filter),
        (r) => CursorResultHelper.toJson<Conversation>(r, (c) => ConversationHelper.toJson(c)));
      return;
    }
    this.handlePromise(result, call.method,
      manager.fetchConversationsFromServer(pageSize, cursor),
      (r) => CursorResultHelper.toJson<Conversation>(r, (c) => ConversationHelper.toJson(c)));
  }

  private deleteAllMessageAndConversation(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let clearServerData = SafetyMapTool.getBoolean(call.args, 'clearServerData') ?? false;
    this.handlePromise(result, call.method, manager.deleteAllConversationsAndMessages(clearServerData));
  }

  private pinMessage(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let msgId = SafetyMapTool.getString(call.args, 'msgId') ?? '';
    this.handlePromise(result, call.method, manager.pinMessage(msgId));
  }

  private unpinMessage(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let msgId = SafetyMapTool.getString(call.args, 'msgId') ?? '';
    this.handlePromise(result, call.method, manager.unpinMessage(msgId));
  }

  private fetchPinnedMessages(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let convId = SafetyMapTool.getString(call.args, 'convId') ?? '';
    this.handlePromise(result, call.method, manager.fetchPinnedMessagesFromServer(convId),
      (msgs) => MessageHelper.listToJson(msgs));
  }

  private searchMsgsByOptions(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let types = new Array<ContentType>();
    let typeValues = ChannelValue.numberArray(call.args, 'types');
    if (typeValues !== undefined) {
      for (let value of typeValues) {
        types.push(EnumTool.messageBodyTypeFromInt(value));
      }
    }
    let ts = SafetyMapTool.getNumber(call.args, 'ts') ?? -1;
    let count = SafetyMapTool.getNumber(call.args, 'count') ?? 20;
    let from = SafetyMapTool.getString(call.args, 'from') ?? '';
    let direction: SearchDirection | undefined = undefined;
    if (SafetyMapTool.has(call.args, 'direction')) {
      direction = EnumTool.searchDirectionFromInt(SafetyMapTool.getNumber(call.args, 'direction') ?? 0);
    }
    this.handlePromise(result, call.method,
      manager.searchMessagesFromDB(types, ts, count, from, direction),
      (msgs) => MessageHelper.listToJson(msgs));
  }

  private getMessageCount(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    this.handlePromise(result, call.method, manager.getDBMsgsCount());
  }

  private loadConversationMessagesWithKeyword(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let keyword = SafetyMapTool.getString(call.args, 'keyword') ?? '';
    let timestamp = SafetyMapTool.getNumber(call.args, 'timestamp') ?? -1;
    let sender = SafetyMapTool.getString(call.args, 'sender') ?? '';
    let direction = EnumTool.searchDirectionFromInt(SafetyMapTool.getNumber(call.args, 'direction') ?? 0);
    let scope = (SafetyMapTool.getNumber(call.args, 'scope') ?? 2) as MessageSearchScope;
    this.handlePromise(result, call.method,
      manager.loadConversationMessagesWithKeyword(keyword, timestamp, sender, direction, scope),
      (map: Map<string, Array<string>>) => map);
  }

  private loadMessagesWithIds(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    // chatsdk only needs the message ids (<= 20); the conversationId argument
    // has no counterpart (gap-ledger 3.1).
    let messageIds = SafetyMapTool.getStringArray(call.args, 'msgIds') ?? [];
    this.handlePromise(result, call.method, manager.loadMessages(messageIds),
      (msgs) => MessageHelper.listToJson(msgs));
  }

  private voiceMessageToText(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let msg = this.dbMessageFromArgs(result, manager, ChannelValue.read(call.args, 'message'));
    if (msg === undefined) {
      return;
    }
    this.handlePromise(result, call.method, manager.voiceMessageToText(msg),
      (text: string) => ChatManagerWrapper.textPayload(text));
  }

  private voiceFileToText(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let filePath = SafetyMapTool.getString(call.args, 'filePath') ?? '';
    let audioParams: ChatAudioParams | null = null;
    let paramsJson = ChannelValue.read(call.args, 'voiceParam');
    if (paramsJson !== null) {
      audioParams = ChatAudioParamsHelper.fromJson(paramsJson);
    }
    this.handlePromise(result, call.method, manager.voiceFileToText(filePath, audioParams),
      (text: string) => ChatManagerWrapper.textPayload(text));
  }

  private static textPayload(text: string): Map<string, Object> {
    let data = new Map<string, Object>();
    data.set('text', text);
    return data;
  }

  private searchMessagesFromServer(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let optionJson = ChannelValue.read(call.args, 'option');
    if (optionJson === null) {
      this.onErrorInfo(result, ChatError.INVALID_PARAM, 'The option is invalid.');
      return;
    }
    let option = new MessageSearchOption();
    option.setKeywordList(SafetyMapTool.getStringArray(optionJson, 'keywordList') ?? []);
    option.setKeywordMatchType(
      (SafetyMapTool.getNumber(optionJson, 'keywordMatchType') ?? 0) as KeywordListMatchType);
    let conversationId = SafetyMapTool.getString(optionJson, 'conversationId');
    if (conversationId !== undefined) {
      option.setConversationId(conversationId);
    }
    let typeValues = ChannelValue.numberArray(optionJson, 'msgTypes');
    if (typeValues !== undefined && typeValues.length > 0) {
      let types = new Array<ContentType>();
      for (let value of typeValues) {
        types.push(EnumTool.messageBodyTypeFromInt(value));
      }
      option.setMsgTypes(types);
    }
    let startTime = SafetyMapTool.getNumber(optionJson, 'startTime');
    let endTime = SafetyMapTool.getNumber(optionJson, 'endTime');
    if (startTime !== undefined && endTime !== undefined) {
      option.setStartTime(startTime);
      option.setEndTime(endTime);
    }
    let scopeValue = SafetyMapTool.getNumber(optionJson, 'searchScope');
    if (scopeValue !== undefined) {
      option.setSearchScope(scopeValue as MessageSearchScope);
    }
    let pageSize = SafetyMapTool.getNumber(call.args, 'pageSize') ?? 20;
    let pageNum = SafetyMapTool.getNumber(call.args, 'pageNum') ?? 1;
    this.handlePromise(result, call.method,
      manager.searchMessagesFromServer(option, pageSize, pageNum),
      (r) => PageResultHelper.toJson<SearchServerMessageResult>(r,
        (item) => SearchServerMessageResultHelper.toJson(item)));
  }

  override registerEaseListener(): void {
    let manager = ChatClient.getInstance().chatManager();
    if (manager === undefined || manager === this.registeredManager) {
      return;
    }
    this.unRegisterEaseListener();

    let messageListener: ChatMessageListener = {
      onMessageReceived: (messages: Array<ChatMessage>): void => {
        this.emitEvent(MethodKey.onMessagesReceived, MessageHelper.listToJson(messages));
      },
      onStreamMessageReceived: (messages: Array<ChatMessage>): void => {
        this.emitEvent(MethodKey.onStreamMessagesReceived, MessageHelper.listToJson(messages));
      },
      onCmdMessageReceived: (messages: Array<ChatMessage>): void => {
        this.emitEvent(MethodKey.onCmdMessagesReceived, MessageHelper.listToJson(messages));
      },
      onMessageRead: (messages: Array<ChatMessage>): void => {
        this.emitEvent(MethodKey.onMessagesRead, MessageHelper.listToJson(messages));
      },
      onMessageDelivered: (messages: Array<ChatMessage>): void => {
        this.emitEvent(MethodKey.onMessagesDelivered, MessageHelper.listToJson(messages));
      },
      onMessageRecalled: (recallInfo: Array<RecallMessageInfo>): void => {
        // chatsdk carries the recalled message inside RecallMessageInfo and
        // merges android's onMessageRecalled / onMessageRecalledWithExt.
        let infoList = new Array<Map<string, Object>>();
        let msgList = new Array<Map<string, Object>>();
        for (let info of recallInfo) {
          infoList.push(RecallMessageInfoHelper.toJson(info));
          let recallMessage = info.getRecallMessage();
          if (recallMessage !== undefined) {
            msgList.push(MessageHelper.toJson(recallMessage));
          }
        }
        this.emitEvent(MethodKey.onMessagesRecalled, msgList);
        this.emitEvent(MethodKey.onMessagesRecalledInfo, infoList);
      },
      onGroupMessageRead: (acks: Array<GroupReadAck>): void => {
        let list = new Array<Map<string, Object>>();
        for (let ack of acks) {
          list.push(GroupAckHelper.toJson(ack));
        }
        this.emitEvent(MethodKey.onGroupMessageRead, list);
      },
      onReadAckForGroupMessageUpdated: (): void => {
        this.emitEvent(MethodKey.onReadAckForGroupMessageUpdated, null);
      },
      onReactionChanged: (changes: Array<ChatMessageReactionChange>): void => {
        let list = new Array<Map<string, Object>>();
        for (let change of changes) {
          list.push(MessageReactionChangeHelper.toJson(change));
        }
        this.emitEvent(MethodKey.onMessageReactionDidChange, list);
      },
      onMessageContentChanged: (modifiedMessage: ChatMessage, operatorId: string,
        operationTime: number): void => {
        let data = new Map<string, Object>();
        data.set('message', MessageHelper.toJson(modifiedMessage));
        data.set('operator', operatorId);
        data.set('operationTime', operationTime);
        this.emitEvent(MethodKey.onMessageContentChanged, data);
      },
      onMessagePinChanged: (messageId: string, conversationId: string, pinOperation: PinOperation,
        pinInfo: ChatMessagePinInfo): void => {
        let data = new Map<string, Object>();
        data.set('msgId', messageId);
        data.set('convId', conversationId);
        data.set('pinOperation', EnumTool.pinOperationToInt(pinOperation));
        data.set('pinInfo', MessagePinInfoHelper.toJson(pinInfo));
        this.emitEvent(MethodKey.onMessagePinChanged, data);
      },
    };
    manager.addMessageListener(messageListener);
    this.messageListener = messageListener;

    let conversationListener: ConversationListener = {
      onConversationUpdate: (): void => {
        this.emitEvent(MethodKey.onConversationUpdate, new Map<string, Object>());
      },
      onConversationRead: (from: string, to: string): void => {
        let data = new Map<string, Object>();
        data.set('from', from);
        data.set('to', to);
        this.emitEvent(MethodKey.onConversationHasRead, data);
      },
    };
    manager.addConversationListener(conversationListener);
    this.conversationListener = conversationListener;

    this.registeredManager = manager;
  }

  override unRegisterEaseListener(): void {
    if (this.registeredManager !== undefined) {
      if (this.messageListener !== undefined) {
        this.registeredManager.removeMessageListener(this.messageListener);
      }
      if (this.conversationListener !== undefined) {
        this.registeredManager.removeConversationListener(this.conversationListener);
      }
      this.registeredManager = undefined;
    }
    this.messageListener = undefined;
    this.conversationListener = undefined;
  }
}
