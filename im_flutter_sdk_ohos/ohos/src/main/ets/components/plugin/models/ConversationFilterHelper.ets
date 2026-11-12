import { ConversationFilter, MarkType } from '@easemob/chatsdk';
import { Any } from '@ohos/flutter_ohos';
import SafetyMapTool from '../SafetyMapTool';

/**
 * Builds chatsdk ConversationFilter from the Dart
 * ConversationFetchOptions.toJson() payload (mirrors android
 * ConversationFilterHelper). The scalar readers are used by the calling
 * wrapper to pick the right fetch API (pinned / mark / plain), same as
 * android.
 */
export default class ConversationFilterHelper {
  static fromJson(args: Any): ConversationFilter {
    let filter = new ConversationFilter();
    filter.markType = (SafetyMapTool.getNumber(args, 'mark') ?? 0) as MarkType;
    filter.pageSize = SafetyMapTool.getNumber(args, 'pageSize') ?? 10;
    let cursor = SafetyMapTool.getString(args, 'cursor');
    if (cursor !== undefined && cursor.length > 0) {
      filter.cursor = cursor;
    }
    return filter;
  }

  static hasMark(args: Any): boolean {
    return SafetyMapTool.has(args, 'mark');
  }

  static pageSize(args: Any): number {
    return SafetyMapTool.getNumber(args, 'pageSize') ?? 0;
  }

  static cursor(args: Any): string | undefined {
    return SafetyMapTool.getString(args, 'cursor');
  }

  static pinned(args: Any): boolean {
    return SafetyMapTool.getBoolean(args, 'pinned') ?? false;
  }
}
