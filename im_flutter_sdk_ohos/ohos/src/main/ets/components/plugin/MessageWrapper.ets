import { ChatClient, ChatManager, ChatMessage } from '@easemob/chatsdk';
import { MethodCall, MethodResult } from '@ohos/flutter_ohos';
import MethodKey from './MethodKeys';
import Wrapper from './Wrapper';
import SafetyMapTool from './SafetyMapTool';
import { MessagePinInfoHelper, MessageReactionHelper } from './models/MessageHelper';

/**
 * Wrapper for the `com.chat.im/chat_message` channel.
 *
 * Implements the message-instance method keys kept in the ohos-branch Dart
 * constants (getReactionList / groupAckCount / getPinInfo), mirroring the
 * android MessageWrapper. `chatThread` is not implemented: the chat-thread
 * capability was removed from the ohos-branch Dart code (chatsdk has no
 * chat-thread module). The message progress/success/error channel events are
 * emitted from the send/download flows in ChatManagerWrapper, so this wrapper
 * registers no chatsdk listeners.
 */
export default class MessageWrapper extends Wrapper {
  override onMethodCall(call: MethodCall, result: MethodResult): void {
    if (MethodKey.getReactionList === call.method) {
      this.reactionList(call, result);
    } else if (MethodKey.groupAckCount === call.method) {
      this.getAckCount(call, result);
    } else if (MethodKey.getPinInfo === call.method) {
      this.getPinInfo(call, result);
    } else {
      super.onMethodCall(call, result);
    }
  }

  private reactionList(call: MethodCall, result: MethodResult): void {
    let msgId = SafetyMapTool.getString(call.args, 'msgId', '') ?? '';
    let message = this.getMessageWithId(msgId);
    let list = new Array<Map<string, Object>>();
    if (message !== undefined) {
      for (let reaction of message.getReactions()) {
        list.push(MessageReactionHelper.toJson(reaction));
      }
    }
    this.onSuccess(result, call.method, list);
  }

  private getAckCount(call: MethodCall, result: MethodResult): void {
    let msgId = SafetyMapTool.getString(call.args, 'msgId', '') ?? '';
    let message = this.getMessageWithId(msgId);
    this.onSuccess(result, call.method, message !== undefined ? message.groupAckCount() : 0);
  }

  private getPinInfo(call: MethodCall, result: MethodResult): void {
    let msgId = SafetyMapTool.getString(call.args, 'msgId', '') ?? '';
    let message = this.getMessageWithId(msgId);
    if (message !== undefined) {
      let pinInfo = message.getPinnedInfo();
      if (pinInfo !== undefined) {
        this.onSuccess(result, call.method, MessagePinInfoHelper.toJson(pinInfo));
        return;
      }
    }
    // No payload mirrors the android null result; Dart maps it to null.
    this.onSuccess(result, call.method);
  }

  private getMessageWithId(msgId: string): ChatMessage | undefined {
    let chatManager: ChatManager | undefined = ChatClient.getInstance().chatManager();
    if (chatManager === undefined) {
      return undefined;
    }
    return chatManager.getMessage(msgId);
  }
}
