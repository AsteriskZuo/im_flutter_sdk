import { Contact } from '@easemob/chatsdk';
import UserInfoHelper from './UserInfoHelper';

/**
 * Serializes chatsdk Contact (mirrors android ContactHelper; keys match the
 * Dart ChatContact.fromJson). Contacts are only converted native -> Dart;
 * the android ContactHelper.fromJson has no caller and is not ported.
 */
export default class ContactHelper {
  static toJson(contact: Contact): Map<string, Object> {
    let data = new Map<string, Object>();
    data.set('userId', contact.userId());
    data.set('remark', contact.remark());
    let userInfo = contact.getUserInfo();
    if (userInfo !== undefined) {
      data.set('userInfo', UserInfoHelper.toJson(userInfo));
    }
    data.set('addTimestamp', contact.getAddTimestamp());
    return data;
  }

  static listToJson(contacts: Array<Contact>): Array<Map<string, Object>> {
    let list = new Array<Map<string, Object>>();
    for (let contact of contacts) {
      list.push(ContactHelper.toJson(contact));
    }
    return list;
  }
}
