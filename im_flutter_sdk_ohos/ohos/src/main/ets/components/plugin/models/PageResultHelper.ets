import { PageResult } from '@easemob/chatsdk';

/**
 * Serializes chatsdk PageResult (mirrors android PageResultHelper; keys match
 * the Dart ChatPageResult.fromJson). "count" carries the page count, same as
 * android.
 *
 * The item converter is passed in by the calling wrapper for the same reason
 * as CursorResultHelper.
 */
export default class PageResultHelper {
  static toJson<T>(result: PageResult<T>, itemToJson: (item: T) => Object): Map<string, Object> {
    let data = new Map<string, Object>();
    data.set('count', result.getPageCount());
    let list = new Array<Object>();
    let items = result.getResult();
    for (let item of items) {
      list.push(itemToJson(item));
    }
    data.set('list', list);
    return data;
  }
}
