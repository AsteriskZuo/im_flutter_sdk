import { CursorResult } from '@easemob/chatsdk';

/**
 * Serializes chatsdk CursorResult (mirrors android CursorResultHelper; keys
 * match the Dart ChatCursorResult.fromJson).
 *
 * Unlike android (which dispatches on the item runtime type), the item
 * converter is passed in by the calling wrapper — ArkTS generics are erased
 * and the wrapper knows the concrete item type, e.g.:
 *   CursorResultHelper.toJson<Group>(result, (g) => GroupHelper.toJson(g))
 * String items can be passed through with (s) => s.
 */
export default class CursorResultHelper {
  static toJson<T>(result: CursorResult<T>, itemToJson: (item: T) => Object): Map<string, Object> {
    let data = new Map<string, Object>();
    data.set('cursor', result.getNextCursor());
    let list = new Array<Object>();
    let items = result.getResult();
    for (let item of items) {
      list.push(itemToJson(item));
    }
    data.set('list', list);
    return data;
  }
}
