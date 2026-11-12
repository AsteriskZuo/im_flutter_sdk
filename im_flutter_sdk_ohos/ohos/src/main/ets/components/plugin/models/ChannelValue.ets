import { Any } from '@ohos/flutter_ohos';

/**
 * Raw value reader for channel arguments, complementing SafetyMapTool's
 * scalar getters.
 *
 * The JSON codec decodes the top-level method arguments into a Map but keeps
 * nested objects as plain records, so readers must tolerate both shapes.
 * Returns null when the key is absent (a present-but-null value cannot be
 * distinguished, which is fine for the SDK payloads handled here).
 */
export default class ChannelValue {
  static read(args: Any, key: string): Object | null {
    if (args instanceof Map) {
      if (!args.has(key)) {
        return null;
      }
      return args.get(key) as Object | null;
    }
    if (ChannelValue.isPlainObject(args)) {
      let record = args as Record<string, Object>;
      if (Object.keys(record).includes(key)) {
        return record[key];
      }
    }
    return null;
  }

  static numberArray(args: Any, key: string): Array<number> | undefined {
    let value = ChannelValue.read(args, key);
    if (value instanceof Array) {
      let items = value as Array<Object>;
      let ret = new Array<number>();
      for (let item of items) {
        if (typeof item === 'number') {
          ret.push(item as number);
        }
      }
      return ret;
    }
    return undefined;
  }

  static isPlainObject(value: Any): boolean {
    return value !== null && value !== undefined && typeof value === 'object' && !(value instanceof Array);
  }
}
