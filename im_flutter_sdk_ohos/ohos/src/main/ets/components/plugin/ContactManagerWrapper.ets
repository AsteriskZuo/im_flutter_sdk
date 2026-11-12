import {
  ChatClient,
  ChatError,
  Contact,
  ContactListener,
  ContactManager,
  CursorResult,
} from '@easemob/chatsdk';
import { FlutterPluginBinding, MethodCall, MethodResult } from '@ohos/flutter_ohos';
import MethodKey, { ChatContactChangeEvent } from './MethodKeys';
import Wrapper from './Wrapper';
import SafetyMapTool from './SafetyMapTool';
import ChatErrorHelper from './models/ChatErrorHelper';
import ContactHelper from './models/ContactHelper';
import CursorResultHelper from './models/CursorResultHelper';

/**
 * Wrapper for the `com.chat.im/chat_contact_manager` channel.
 *
 * Implements the 16 chat_contact_manager method keys kept in the ohos-branch
 * Dart constants (gap ledger §2.1; no key of this channel was removed in
 * §17). Key-to-chatsdk mapping:
 *   getAllContactsFromServer -> fetchAllContactsIDFromServer (ids)
 *   getAllContactsFromDB     -> allContacts (cached ids)
 *   getAllContacts           -> getContactsFromLocal (Contact models)
 *   fetchAllContacts         -> fetchAllContactsFromServer (Contact models)
 *   fetchContacts            -> fetchAllContactsFromServerByPage
 *   addUserToBlockList       -> addUsersToBlocklist (single string)
 *   getBlockListFromDB       -> blockList (cached ids)
 *
 * Events: the eight ContactListener callbacks are aggregated into the single
 * `onContactChanged` channel event with a "type" field, mirroring the android
 * ContactManagerWrapper (payload keys "userId" / "reason" / "contact" /
 * "error"). onContactSyncFinish carries "error" only on failure (android puts
 * a null; Dart treats a missing key the same). The chatsdk ContactListener
 * has no blacklist callbacks, matching android.
 *
 * Listener timing: the chatsdk ContactManager only exists after
 * ChatClient.init, and this channel has no init call. Registration therefore
 * happens lazily on the first method call (any contact call implies init
 * already happened), guarded by `listenerAttached` — same approach as
 * ChatRoomManagerWrapper.
 */
export default class ContactManagerWrapper extends Wrapper {
  private contactListener: ContactListener | undefined;
  private listenerAttached: boolean = false;

  constructor(binding: FlutterPluginBinding, channelName: string) {
    super(binding, channelName);
  }

  override onMethodCall(call: MethodCall, result: MethodResult): void {
    if (!this.listenerAttached) {
      this.registerEaseListener();
    }
    if (MethodKey.addContact === call.method) {
      this.addContact(call, result);
    } else if (MethodKey.deleteContact === call.method) {
      this.deleteContact(call, result);
    } else if (MethodKey.getAllContactsFromServer === call.method) {
      this.getAllContactsFromServer(call, result);
    } else if (MethodKey.getAllContactsFromDB === call.method) {
      this.getAllContactsFromDB(call, result);
    } else if (MethodKey.addUserToBlockList === call.method) {
      this.addUserToBlockList(call, result);
    } else if (MethodKey.removeUserFromBlockList === call.method) {
      this.removeUserFromBlockList(call, result);
    } else if (MethodKey.getBlockListFromServer === call.method) {
      this.getBlockListFromServer(call, result);
    } else if (MethodKey.getBlockListFromDB === call.method) {
      this.getBlockListFromDB(call, result);
    } else if (MethodKey.acceptInvitation === call.method) {
      this.acceptInvitation(call, result);
    } else if (MethodKey.declineInvitation === call.method) {
      this.declineInvitation(call, result);
    } else if (MethodKey.getSelfIdsOnOtherPlatform === call.method) {
      this.getSelfIdsOnOtherPlatform(call, result);
    } else if (MethodKey.getAllContacts === call.method) {
      this.getAllContacts(call, result);
    } else if (MethodKey.setContactRemark === call.method) {
      this.setContactRemark(call, result);
    } else if (MethodKey.getContact === call.method) {
      this.getContact(call, result);
    } else if (MethodKey.fetchAllContacts === call.method) {
      this.fetchAllContacts(call, result);
    } else if (MethodKey.fetchContacts === call.method) {
      this.fetchContacts(call, result);
    } else {
      super.onMethodCall(call, result);
    }
  }

  private addContact(call: MethodCall, result: MethodResult): void {
    let manager = this.contactManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let userId = SafetyMapTool.getString(call.args, 'userId', '') ?? '';
    let reason = SafetyMapTool.getString(call.args, 'reason');
    let promise: Promise<void>;
    if (reason !== undefined) {
      promise = manager.addContact(userId, reason);
    } else {
      promise = manager.addContact(userId);
    }
    this.handlePromise(result, call.method, promise, () => userId);
  }

  private deleteContact(call: MethodCall, result: MethodResult): void {
    let manager = this.contactManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let userId = SafetyMapTool.getString(call.args, 'userId', '') ?? '';
    let keepConversation = SafetyMapTool.getBoolean(call.args, 'keepConversation', false) ?? false;
    this.handlePromise(result, call.method, manager.deleteContact(userId, keepConversation),
      () => userId);
  }

  private getAllContactsFromServer(call: MethodCall, result: MethodResult): void {
    let manager = this.contactManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    this.handlePromise(result, call.method, manager.fetchAllContactsIDFromServer(),
      (list: Array<string>) => list as Object);
  }

  private getAllContactsFromDB(call: MethodCall, result: MethodResult): void {
    let manager = this.contactManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    this.handlePromise(result, call.method, manager.allContacts(),
      (list: Array<string>) => list as Object);
  }

  private addUserToBlockList(call: MethodCall, result: MethodResult): void {
    let manager = this.contactManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let userId = SafetyMapTool.getString(call.args, 'userId', '') ?? '';
    // Single user goes in as a plain string (gap ledger §2.1), same effect as
    // android's addUserToBlackList(username, false).
    this.handlePromise(result, call.method, manager.addUsersToBlocklist(userId), () => userId);
  }

  private removeUserFromBlockList(call: MethodCall, result: MethodResult): void {
    let manager = this.contactManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let userId = SafetyMapTool.getString(call.args, 'userId', '') ?? '';
    this.handlePromise(result, call.method, manager.removeUserFromBlockList(userId), () => userId);
  }

  private getBlockListFromServer(call: MethodCall, result: MethodResult): void {
    let manager = this.contactManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    this.handlePromise(result, call.method, manager.getBlockListFromServer(),
      (list: Array<string>) => list as Object);
  }

  private getBlockListFromDB(call: MethodCall, result: MethodResult): void {
    let manager = this.contactManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    this.handlePromise(result, call.method, manager.blockList(),
      (list: Array<string>) => list as Object);
  }

  private acceptInvitation(call: MethodCall, result: MethodResult): void {
    let manager = this.contactManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let userId = SafetyMapTool.getString(call.args, 'userId', '') ?? '';
    this.handlePromise(result, call.method, manager.acceptInvitation(userId), () => userId);
  }

  private declineInvitation(call: MethodCall, result: MethodResult): void {
    let manager = this.contactManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let userId = SafetyMapTool.getString(call.args, 'userId', '') ?? '';
    this.handlePromise(result, call.method, manager.declineInvitation(userId), () => userId);
  }

  private getSelfIdsOnOtherPlatform(call: MethodCall, result: MethodResult): void {
    let manager = this.contactManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    this.handlePromise(result, call.method, manager.getSelfIdsOnOtherPlatform(),
      (list: Array<string>) => list as Object);
  }

  private getAllContacts(call: MethodCall, result: MethodResult): void {
    let manager = this.contactManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    this.handlePromise(result, call.method, manager.getContactsFromLocal(),
      (contacts: Array<Contact>) => ContactHelper.listToJson(contacts) as Object);
  }

  private setContactRemark(call: MethodCall, result: MethodResult): void {
    let manager = this.contactManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let userId = SafetyMapTool.getString(call.args, 'userId', '') ?? '';
    let remark = SafetyMapTool.getString(call.args, 'remark', '') ?? '';
    this.handlePromise(result, call.method, manager.setContactRemark(userId, remark));
  }

  private getContact(call: MethodCall, result: MethodResult): void {
    let manager = this.contactManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let userId = SafetyMapTool.getString(call.args, 'userId', '') ?? '';
    // Not routed through handlePromise: the resolved Contact may be undefined,
    // and android answers with a null payload in that case (Dart maps the
    // missing key to a null ChatContact).
    manager.getContact(userId)
      .then((contact: Contact | undefined) => {
        if (contact !== undefined) {
          this.onSuccess(result, call.method, ContactHelper.toJson(contact));
        } else {
          this.onSuccess(result, call.method);
        }
      })
      .catch((e: ESObject) => {
        if (e instanceof ChatError) {
          this.onError(result, e);
        } else {
          this.onErrorInfo(result, ChatError.GENERAL_ERROR, `rejected: ${typeof e}`);
        }
      });
  }

  private fetchAllContacts(call: MethodCall, result: MethodResult): void {
    let manager = this.contactManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    this.handlePromise(result, call.method, manager.fetchAllContactsFromServer(),
      (contacts: Array<Contact>) => ContactHelper.listToJson(contacts) as Object);
  }

  private fetchContacts(call: MethodCall, result: MethodResult): void {
    let manager = this.contactManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let pageSize = SafetyMapTool.getNumber(call.args, 'pageSize', 20) ?? 20;
    let cursor = SafetyMapTool.getString(call.args, 'cursor');
    let promise: Promise<CursorResult<Contact>>;
    if (cursor !== undefined) {
      promise = manager.fetchAllContactsFromServerByPage(pageSize, cursor);
    } else {
      promise = manager.fetchAllContactsFromServerByPage(pageSize);
    }
    this.handlePromise(result, call.method, promise,
      (ret: CursorResult<Contact>) =>
        CursorResultHelper.toJson<Contact>(ret, (contact: Contact) => ContactHelper.toJson(contact)));
  }

  private contactManager(result: MethodResult, method: string): ContactManager | undefined {
    let manager = ChatClient.getInstance().contactManager();
    if (manager === undefined) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR,
        `${method} failed: ContactManager unavailable, SDK not initialized`);
      return undefined;
    }
    return manager;
  }

  override registerEaseListener(): void {
    let manager = ChatClient.getInstance().contactManager();
    if (manager === undefined) {
      // SDK not initialized yet; retried lazily on the next method call.
      return;
    }
    if (this.contactListener !== undefined) {
      manager.removeContactListener(this.contactListener);
    }
    this.contactListener = {
      onContactAdded: (userId: string): void => {
        let data = new Map<string, Object>();
        data.set('type', ChatContactChangeEvent.CONTACT_ADD);
        data.set('userId', userId);
        this.emitEvent(MethodKey.onContactChanged, data);
      },
      onContactDeleted: (userId: string): void => {
        let data = new Map<string, Object>();
        data.set('type', ChatContactChangeEvent.CONTACT_DELETE);
        data.set('userId', userId);
        this.emitEvent(MethodKey.onContactChanged, data);
      },
      onContactInvited: (userId: string, reason: string): void => {
        let data = new Map<string, Object>();
        data.set('type', ChatContactChangeEvent.INVITED);
        data.set('userId', userId);
        data.set('reason', reason);
        this.emitEvent(MethodKey.onContactChanged, data);
      },
      onFriendRequestAccepted: (userId: string): void => {
        let data = new Map<string, Object>();
        data.set('type', ChatContactChangeEvent.INVITATION_ACCEPTED);
        data.set('userId', userId);
        this.emitEvent(MethodKey.onContactChanged, data);
      },
      onFriendRequestDeclined: (userId: string): void => {
        let data = new Map<string, Object>();
        data.set('type', ChatContactChangeEvent.INVITATION_DECLINED);
        data.set('userId', userId);
        this.emitEvent(MethodKey.onContactChanged, data);
      },
      onContactSyncStart: (): void => {
        let data = new Map<string, Object>();
        data.set('type', ChatContactChangeEvent.CONTACT_SYNC_START);
        this.emitEvent(MethodKey.onContactChanged, data);
      },
      onContactSyncFinishWithError: (errorCode: number, error: string): void => {
        let data = new Map<string, Object>();
        data.set('type', ChatContactChangeEvent.CONTACT_SYNC_FINISH);
        if (errorCode !== ChatError.EM_NO_ERROR) {
          // Android puts a null on success; a missing key reads as null in Dart.
          data.set('error', ChatErrorHelper.infoToJson(errorCode, error));
        }
        this.emitEvent(MethodKey.onContactChanged, data);
      },
      onContactInfoUpdate: (contact: Contact): void => {
        let data = new Map<string, Object>();
        data.set('type', ChatContactChangeEvent.CONTACT_INFO_UPDATE);
        data.set('contact', ContactHelper.toJson(contact));
        this.emitEvent(MethodKey.onContactChanged, data);
      },
    };
    manager.addContactListener(this.contactListener);
    this.listenerAttached = true;
  }

  override unRegisterEaseListener(): void {
    this.listenerAttached = false;
    if (this.contactListener === undefined) {
      return;
    }
    let manager = ChatClient.getInstance().contactManager();
    if (manager !== undefined) {
      manager.removeContactListener(this.contactListener);
    }
    this.contactListener = undefined;
  }
}
