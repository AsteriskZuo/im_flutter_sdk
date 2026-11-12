import { Conversation, MarkType } from '@easemob/chatsdk';
import { JSON } from '@kit.ArkTS';
import EnumTool from './EnumTool';

/**
 * Serializes chatsdk Conversation (mirrors android ConversationHelper; keys
 * match the Dart ChatConversation.fromJson).
 *
 * Known gap against android: chatsdk Conversation has no chat-thread flag on
 * HarmonyOS, so "isThread" is omitted (the Dart side defaults it to false).
 */
export default class ConversationHelper {
  static toJson(conversation: Conversation): Map<string, Object> {
    let data = new Map<string, Object>();
    data.set('convId', conversation.conversationId());
    data.set('type', EnumTool.conversationTypeToInt(conversation.getType()));
    data.set('isPinned', conversation.isPinned());
    data.set('pinnedTime', conversation.getPinnedTime());
    let marks = new Array<number>();
    conversation.marks().forEach((mark: MarkType) => {
      marks.push(mark as number);
    });
    data.set('marks', marks);
    let ext = ConversationHelper.jsonStringToMap(conversation.getExtField());
    if (ext !== undefined) {
      data.set('ext', ext);
    }
    return data;
  }

  static listToJson(conversations: Array<Conversation>): Array<Map<string, Object>> {
    let list = new Array<Map<string, Object>>();
    for (let conversation of conversations) {
      list.push(ConversationHelper.toJson(conversation));
    }
    return list;
  }

  /**
   * Parses the conversation ext JSON string into a string-valued map
   * (mirrors android jsonStringToMap): objects become key -> string entries,
   * arrays become "0".."n" -> string entries, nested structures recurse.
   * Returns undefined when the content is empty or not a JSON container.
   */
  private static jsonStringToMap(content: string): Map<string, Object> | undefined {
    if (content.length === 0) {
      return undefined;
    }
    let trimmed = content.trim();
    if (!trimmed.startsWith('{') && !trimmed.startsWith('[')) {
      return undefined;
    }
    let parsed: Object | null = null;
    try {
      parsed = JSON.parse(trimmed) as Object | null;
    } catch (e) {
      return undefined;
    }
    if (parsed === null) {
      return undefined;
    }
    let result = new Map<string, Object>();
    if (parsed instanceof Array) {
      let array = parsed as Array<Object>;
      for (let i = 0; i < array.length; i++) {
        ConversationHelper.putJsonValue(result, `${i}`, array[i]);
      }
      return result;
    }
    if (typeof parsed === 'object') {
      let record = parsed as Record<string, Object>;
      for (let key of Object.keys(record)) {
        ConversationHelper.putJsonValue(result, key, record[key]);
      }
      return result;
    }
    return undefined;
  }

  private static putJsonValue(result: Map<string, Object>, key: string, value: Object): void {
    if (typeof value === 'object') {
      let nested = ConversationHelper.jsonStringToMap(JSON.stringify(value));
      if (nested !== undefined) {
        result.set(key, nested);
      }
      return;
    }
    if (typeof value === 'string') {
      result.set(key, (value as string).trim());
    } else if (typeof value === 'number') {
      result.set(key, `${value as number}`);
    } else if (typeof value === 'boolean') {
      result.set(key, `${value as boolean}`);
    }
  }
}
