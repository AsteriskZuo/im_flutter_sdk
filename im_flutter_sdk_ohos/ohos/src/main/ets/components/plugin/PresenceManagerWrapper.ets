import {
  ChatClient,
  ChatError,
  Presence,
  PresenceListener,
  PresenceManager,
} from '@easemob/chatsdk';
import { FlutterPluginBinding, MethodCall, MethodResult } from '@ohos/flutter_ohos';
import MethodKey from './MethodKeys';
import Wrapper from './Wrapper';
import SafetyMapTool from './SafetyMapTool';
import PresenceHelper from './models/PresenceHelper';

/**
 * Wrapper for the `com.chat.im/chat_presence_manager` channel.
 *
 * Implements the 5 chat_presence_manager method keys kept in the ohos-branch
 * Dart constants (gap ledger §10.1); nothing in this channel is on the §17
 * removal list. Mirrors the android PresenceManagerWrapper contract.
 *
 * Listener timing: unlike android (registers in the constructor), the chatsdk
 * PresenceManager only exists after ChatClient.init, and this channel has no
 * init call. Registration therefore happens lazily on the first method call
 * (any presence call implies init already happened), mirroring the
 * ChatRoomManagerWrapper lazy-registration pattern.
 */
export default class PresenceManagerWrapper extends Wrapper {
  private presenceListener: PresenceListener | undefined;
  private listenerAttached: boolean = false;

  constructor(binding: FlutterPluginBinding, channelName: string) {
    super(binding, channelName);
  }

  override onMethodCall(call: MethodCall, result: MethodResult): void {
    if (!this.listenerAttached) {
      this.registerEaseListener();
    }
    if (MethodKey.presenceWithDescription === call.method) {
      this.publishPresenceWithDescription(call, result);
    } else if (MethodKey.presenceSubscribe === call.method) {
      this.subscribe(call, result);
    } else if (MethodKey.presenceUnsubscribe === call.method) {
      this.unsubscribe(call, result);
    } else if (MethodKey.fetchSubscribedMembersWithPageNum === call.method) {
      this.fetchSubscribedMembersWithPageNum(call, result);
    } else if (MethodKey.fetchPresenceStatus === call.method) {
      this.fetchPresenceStatus(call, result);
    } else {
      super.onMethodCall(call, result);
    }
  }

  private publishPresenceWithDescription(call: MethodCall, result: MethodResult): void {
    let manager = this.presenceManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let desc = SafetyMapTool.getString(call.args, 'desc', '') ?? '';
    this.handlePromise(result, call.method, manager.publishPresence(desc));
  }

  private subscribe(call: MethodCall, result: MethodResult): void {
    let manager = this.presenceManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let members = SafetyMapTool.getStringArray(call.args, 'members') ?? new Array<string>();
    let expiry = SafetyMapTool.getNumber(call.args, 'expiry', 0) ?? 0;
    this.handlePromise(result, call.method, manager.subscribePresences(members, expiry),
      (presences: Array<Presence>) => PresenceHelper.listToJson(presences));
  }

  private unsubscribe(call: MethodCall, result: MethodResult): void {
    let manager = this.presenceManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let members = SafetyMapTool.getStringArray(call.args, 'members') ?? new Array<string>();
    this.handlePromise(result, call.method, manager.unsubscribePresences(members));
  }

  private fetchSubscribedMembersWithPageNum(call: MethodCall, result: MethodResult): void {
    let manager = this.presenceManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let pageNum = SafetyMapTool.getNumber(call.args, 'pageNum', 1) ?? 1;
    let pageSize = SafetyMapTool.getNumber(call.args, 'pageSize', 20) ?? 20;
    this.handlePromise(result, call.method, manager.fetchSubscribedMembers(pageNum, pageSize),
      (members: Array<string>) => members);
  }

  private fetchPresenceStatus(call: MethodCall, result: MethodResult): void {
    let manager = this.presenceManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let members = SafetyMapTool.getStringArray(call.args, 'members') ?? new Array<string>();
    this.handlePromise(result, call.method, manager.fetchPresenceStatus(members),
      (presences: Array<Presence>) => PresenceHelper.listToJson(presences));
  }

  private presenceManager(result: MethodResult, method: string): PresenceManager | undefined {
    let manager = ChatClient.getInstance().presenceManager();
    if (manager === undefined) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR,
        `${method} failed: PresenceManager unavailable, SDK not initialized`);
      return undefined;
    }
    return manager;
  }

  override registerEaseListener(): void {
    let manager = ChatClient.getInstance().presenceManager();
    if (manager === undefined) {
      // SDK not initialized yet; retried lazily on the next method call.
      return;
    }
    if (this.presenceListener !== undefined) {
      manager.removeListener(this.presenceListener);
    }
    this.presenceListener = {
      onPresenceUpdated: (presences: Array<Presence>): void => {
        let data = new Map<string, Object>();
        data.set('presences', PresenceHelper.listToJson(presences));
        this.emitEvent(MethodKey.onPresenceStatusChanged, data);
      },
    };
    manager.addListener(this.presenceListener);
    this.listenerAttached = true;
  }

  override unRegisterEaseListener(): void {
    this.listenerAttached = false;
    if (this.presenceListener === undefined) {
      return;
    }
    let manager = ChatClient.getInstance().presenceManager();
    if (manager !== undefined) {
      manager.removeListener(this.presenceListener);
    }
    this.presenceListener = undefined;
  }
}
