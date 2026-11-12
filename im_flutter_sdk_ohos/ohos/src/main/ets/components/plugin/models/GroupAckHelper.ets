import { GroupReadAck } from '@easemob/chatsdk';

/**
 * Serializes chatsdk GroupReadAck (mirrors android GroupAckHelper; keys match
 * the Dart ChatGroupMessageAck.fromJson — note the "ack_id" snake-case key
 * is intentional, android uses it too).
 */
export default class GroupAckHelper {
  static toJson(ack: GroupReadAck): Map<string, Object> {
    let data = new Map<string, Object>();
    data.set('msgId', ack.getMsgId());
    data.set('ack_id', ack.getAckId());
    data.set('from', ack.getFrom());
    data.set('count', ack.getCount());
    data.set('timestamp', ack.getTimestamp());
    data.set('content', ack.getContent());
    return data;
  }
}
