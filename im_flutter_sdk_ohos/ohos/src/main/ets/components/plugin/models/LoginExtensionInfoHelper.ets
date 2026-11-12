import { LoginExtInfo } from '@easemob/chatsdk';

/**
 * Serializes chatsdk LoginExtInfo to the wire format the Dart side expects:
 * { "deviceName": string, "ext": string? } (see android LoginExtensionInfoHelper
 * and Dart LoginExtensionInfo.fromJson).
 */
export default class LoginExtensionInfoHelper {
  static toJson(info: LoginExtInfo): Map<string, Object> {
    let ret = new Map<string, Object>();
    ret.set('deviceName', info.deviceInfo);
    if (info.deviceExt !== null && info.deviceExt !== undefined && info.deviceExt.length > 0) {
      ret.set('ext', info.deviceExt);
    }
    return ret;
  }
}
