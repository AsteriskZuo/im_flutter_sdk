import { Presence } from '@easemob/chatsdk';

/**
 * Serializes chatsdk Presence (mirrors android PresenceHelper; keys match the
 * Dart ChatPresence.fromJson).
 */
export default class PresenceHelper {
  static toJson(presence: Presence): Map<string, Object> {
    let data = new Map<string, Object>();
    data.set('publisher', presence.getPublisher());
    data.set('statusDescription', presence.getExt());
    data.set('lastTime', presence.getLatestTime());
    data.set('expiryTime', presence.getExpiryTime());
    data.set('statusDetails', presence.getStatusList());
    return data;
  }

  static listToJson(presences: Array<Presence>): Array<Map<string, Object>> {
    let list = new Array<Map<string, Object>>();
    for (let presence of presences) {
      list.push(PresenceHelper.toJson(presence));
    }
    return list;
  }
}
