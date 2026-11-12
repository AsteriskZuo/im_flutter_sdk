import { RecallMessageInfo } from '@easemob/chatsdk';
import MessageHelper from './MessageHelper';

/**
 * Serializes chatsdk RecallMessageInfo (mirrors android
 * RecallMessageInfoHelper; keys match the Dart RecallMessageInfo.fromJson).
 */
export default class RecallMessageInfoHelper {
  static toJson(info: RecallMessageInfo): Map<string, Object> {
    let data = new Map<string, Object>();
    data.set('recallMsgId', info.getRecallMessageId());
    data.set('recallBy', info.getRecallBy());
    let ext = info.getExt();
    if (ext.length > 0) {
      data.set('ext', ext);
    }
    let recallMessage = info.getRecallMessage();
    if (recallMessage !== undefined) {
      data.set('msg', MessageHelper.toJson(recallMessage));
    }
    let conversationId = info.getConversationId();
    if (conversationId.length > 0) {
      data.set('convId', conversationId);
    }
    return data;
  }
}
