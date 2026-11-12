import { SearchServerMessageResult } from '@easemob/chatsdk';
import EnumTool from './EnumTool';
import MessageBodyHelper from './MessageBodyHelper';

/**
 * Serializes chatsdk SearchServerMessageResult (mirrors android
 * SearchServerMessageResultHelper; keys match the Dart
 * ChatSearchServerMessageResult.fromJson).
 */
export default class SearchServerMessageResultHelper {
  static toJson(result: SearchServerMessageResult): Map<string, Object> {
    let data = new Map<string, Object>();
    data.set('msgId', result.getMessageId());
    let body = result.getBody();
    if (body !== undefined) {
      let bodyData = MessageBodyHelper.toJson(body);
      if (bodyData !== undefined) {
        data.set('body', bodyData);
      }
    }
    let ext = result.getExt();
    if (ext.size > 0) {
      data.set('attributes', ext);
    }
    data.set('from', result.getFrom());
    data.set('to', result.getTo());
    data.set('convId', result.getConversationId());
    data.set('chatType', EnumTool.chatTypeToInt(result.getChatType()));
    data.set('timestamp', result.getTimestamp());
    let highlightTexts = result.getHighlightTexts();
    if (highlightTexts.length > 0) {
      data.set('highlightTexts', highlightTexts);
    }
    return data;
  }
}
