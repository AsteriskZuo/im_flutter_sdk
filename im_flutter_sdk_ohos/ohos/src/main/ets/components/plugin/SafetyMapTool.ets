import { Any } from '@ohos/flutter_ohos';

/**
 * Safe parameter readers for channel arguments.
 *
 * Channel arguments arrive as a Map (decoded by JSONMessageCodec) but plain
 * records are tolerated as a fallback. Every reader checks the runtime type
 * and returns undefined when the key is absent or the value has an unexpected
 * type, unless a default value is provided.
 */
export default class SafetyMapTool {
  static has(args: Any, key: string): boolean {
    if (args instanceof Map) {
      return args.has(key);
    }
    if (SafetyMapTool.isRecord(args)) {
      let record = args as Record<string, Object>;
      return Object.keys(record).includes(key);
    }
    return false;
  }

  static getString(args: Any, key: string, defaultValue?: string): string | undefined {
    let value: Object | null = SafetyMapTool.raw(args, key);
    if (typeof value === 'string') {
      return value as string;
    }
    return defaultValue;
  }

  static getBoolean(args: Any, key: string, defaultValue?: boolean): boolean | undefined {
    let value: Object | null = SafetyMapTool.raw(args, key);
    if (typeof value === 'boolean') {
      return value as boolean;
    }
    return defaultValue;
  }

  static getNumber(args: Any, key: string, defaultValue?: number): number | undefined {
    let value: Object | null = SafetyMapTool.raw(args, key);
    if (typeof value === 'number') {
      return value as number;
    }
    return defaultValue;
  }

  static getStringArray(args: Any, key: string): Array<string> | undefined {
    let value: Object | null = SafetyMapTool.raw(args, key);
    if (value instanceof Array) {
      let items: Array<Object> = value as Array<Object>;
      let ret: Array<string> = [];
      for (let item of items) {
        if (typeof item === 'string') {
          ret.push(item as string);
        }
      }
      return ret;
    }
    return undefined;
  }

  private static raw(args: Any, key: string): Object | null {
    if (args instanceof Map) {
      let value: Object | null = args.get(key) as Object | null;
      return value;
    }
    if (SafetyMapTool.isRecord(args)) {
      let record = args as Record<string, Object>;
      if (Object.keys(record).includes(key)) {
        return record[key];
      }
    }
    return null;
  }

  private static isRecord(args: Any): boolean {
    return args !== null && args !== undefined && typeof args === 'object' && !(args instanceof Array);
  }
}
