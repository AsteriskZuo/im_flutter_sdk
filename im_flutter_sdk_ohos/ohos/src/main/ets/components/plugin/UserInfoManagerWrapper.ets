import {
  ChatClient,
  ChatError,
  Gender,
  UserInfo,
  UserInfoListener,
  UserInfoManager,
  UserInfoType,
} from '@easemob/chatsdk';
import { FlutterPluginBinding, MethodCall, MethodResult } from '@ohos/flutter_ohos';
import MethodKey, { ChatUserInfoChangeEvent } from './MethodKeys';
import Wrapper from './Wrapper';
import SafetyMapTool from './SafetyMapTool';
import ChannelValue from './models/ChannelValue';
import UserInfoHelper from './models/UserInfoHelper';
import UserInfoTypeHelper from './models/UserInfoTypeHelper';

/**
 * Wrapper for the `com.chat.im/chat_userInfo_manager` channel (the capital I
 * in `userInfo` is intentional, see gap ledger §9).
 *
 * Implements the 8 chat_userInfo_manager method keys kept in the ohos-branch
 * Dart constants (gap ledger §9.1); nothing in this channel is on the §17
 * removal list. Mirrors the android UserInfoManagerWrapper contract.
 *
 * One key serves two Dart methods: `fetchOwnInfo` fans into `fetchUserInfoById`
 * on the Dart side (chat_user_info_manager.dart), so a single branch covers
 * both, same as android.
 *
 * The Flutter `expireTime` parameter has no chatsdk counterpart and is only
 * used by the Dart in-memory cache (never sent over the channel); it is
 * ignored here per gap ledger §16.1-A#16. Do not confuse it with chatsdk's
 * second `fetchUserInfoById` parameter `attribute` (attribute filter), which
 * maps to `fetchUserInfoByIdWithType` instead.
 *
 * `updateOwnUserInfoWithType` / `fetchUserInfoByIdWithType` are orphan
 * constants on the Dart side (gap ledger §16.1-B#40 backlog); the branches
 * are implemented because chatsdk has the capability.
 *
 * Listener timing: the chatsdk UserInfoManager only exists after
 * ChatClient.init, and this channel has no init call. Registration therefore
 * happens lazily on the first method call, mirroring the
 * PresenceManagerWrapper lazy-registration pattern.
 */
export default class UserInfoManagerWrapper extends Wrapper {
  private userInfoListener: UserInfoListener | undefined;
  private listenerAttached: boolean = false;

  constructor(binding: FlutterPluginBinding, channelName: string) {
    super(binding, channelName);
  }

  override onMethodCall(call: MethodCall, result: MethodResult): void {
    if (!this.listenerAttached) {
      this.registerEaseListener();
    }
    if (MethodKey.updateOwnUserInfo === call.method) {
      this.updateOwnUserInfo(call, result);
    } else if (MethodKey.updateOwnUserInfoWithType === call.method) {
      this.updateOwnUserInfoWithType(call, result);
    } else if (MethodKey.fetchUserInfoById === call.method) {
      this.fetchUserInfoById(call, result);
    } else if (MethodKey.fetchUserInfoByIdWithType === call.method) {
      this.fetchUserInfoByIdWithType(call, result);
    } else if (MethodKey.subscribeUsersInfo === call.method) {
      this.subscribeUsersInfo(call, result);
    } else if (MethodKey.unsubscribeUsersInfo === call.method) {
      this.unsubscribeUsersInfo(call, result);
    } else if (MethodKey.fetchSubscribedUsers === call.method) {
      this.fetchSubscribedUsers(call, result);
    } else if (MethodKey.getLocalUserInfoByIds === call.method) {
      this.getLocalUserInfoByIds(call, result);
    } else {
      super.onMethodCall(call, result);
    }
  }

  private updateOwnUserInfo(call: MethodCall, result: MethodResult): void {
    let manager = this.userInfoManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let currentUser = ChatClient.getInstance().getCurrentUser();
    if (currentUser.length === 0) {
      this.onErrorInfo(result, ChatError.USER_NOT_LOGIN, 'User not login');
      return;
    }
    let userInfo = UserInfoHelper.fromJson(call.args);
    userInfo.userId = currentUser;
    // android returns the request-side userInfo (with userId filled in), not
    // the callback payload; mirror that so the wire format stays identical.
    this.handlePromise(result, call.method, manager.updateUserInfo(userInfo),
      () => UserInfoHelper.toJson(userInfo));
  }

  private updateOwnUserInfoWithType(call: MethodCall, result: MethodResult): void {
    let manager = this.userInfoManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let typeInt = SafetyMapTool.getNumber(call.args, 'userInfoType');
    let userInfoValue = SafetyMapTool.getString(call.args, 'userInfoValue') ?? '';
    let userInfoType = typeInt !== undefined ? UserInfoTypeHelper.userInfoTypeFromInt(typeInt) : undefined;
    if (userInfoType === undefined) {
      this.onErrorInfo(result, ChatError.USER_ILLEGAL_ARGUMENT,
        `updateOwnUserInfoWithType failed: unexpected userInfoType ${typeInt ?? -1}`);
      return;
    }
    let currentUser = ChatClient.getInstance().getCurrentUser();
    // chatsdk expects a Gender (int) for the gender attribute while android
    // passes the raw string to the native SDK; convert for the signature.
    let value: string | Gender = userInfoValue;
    if (userInfoType === UserInfoType.GENDER) {
      value = Number(userInfoValue) as Gender;
    }
    this.handlePromise(result, call.method, manager.updateUserInfo(userInfoType, value),
      (updated: UserInfo) => {
        updated.userId = currentUser;
        return UserInfoHelper.toJson(updated);
      });
  }

  private fetchUserInfoById(call: MethodCall, result: MethodResult): void {
    let manager = this.userInfoManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let userIds = SafetyMapTool.getStringArray(call.args, 'userIds') ?? new Array<string>();
    this.handlePromise(result, call.method, manager.fetchUserInfoById(userIds),
      (map: Map<string, UserInfo>) => UserInfoManagerWrapper.userInfoMapToJson(map));
  }

  private fetchUserInfoByIdWithType(call: MethodCall, result: MethodResult): void {
    let manager = this.userInfoManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let userIds = SafetyMapTool.getStringArray(call.args, 'userIds') ?? new Array<string>();
    let typeInts = ChannelValue.numberArray(call.args, 'userInfoTypes') ?? new Array<number>();
    let infoTypes = new Array<UserInfoType>();
    for (let typeInt of typeInts) {
      let infoType = UserInfoTypeHelper.userInfoTypeFromInt(typeInt);
      if (infoType === undefined) {
        this.onErrorInfo(result, ChatError.USER_ILLEGAL_ARGUMENT,
          `fetchUserInfoByIdWithType failed: unexpected userInfoType ${typeInt}`);
        return;
      }
      infoTypes.push(infoType);
    }
    this.handlePromise(result, call.method, manager.fetchUserInfoById(userIds, infoTypes),
      (map: Map<string, UserInfo>) => UserInfoManagerWrapper.userInfoMapToJson(map));
  }

  // 4.22.0
  private subscribeUsersInfo(call: MethodCall, result: MethodResult): void {
    let manager = this.userInfoManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let userIds = SafetyMapTool.getStringArray(call.args, 'userIds') ?? new Array<string>();
    this.handlePromise(result, call.method, manager.subscribeUsersInfo(userIds));
  }

  // 4.22.0
  private unsubscribeUsersInfo(call: MethodCall, result: MethodResult): void {
    let manager = this.userInfoManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let userIds = SafetyMapTool.getStringArray(call.args, 'userIds') ?? new Array<string>();
    this.handlePromise(result, call.method, manager.unsubscribeUsersInfo(userIds));
  }

  // 4.22.0
  private fetchSubscribedUsers(call: MethodCall, result: MethodResult): void {
    let manager = this.userInfoManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    this.handlePromise(result, call.method, manager.fetchSubscribedUsers(),
      (users: Array<UserInfo>) => {
        let list = new Array<Object>();
        users.forEach((userInfo: UserInfo) => {
          list.push(UserInfoHelper.toJson(userInfo));
        });
        let data = new Map<string, Object>();
        data.set('users', list);
        return data;
      });
  }

  // 4.22.0
  private getLocalUserInfoByIds(call: MethodCall, result: MethodResult): void {
    let manager = this.userInfoManager(result, call.method);
    if (manager === undefined) {
      return;
    }
    let userIds = SafetyMapTool.getStringArray(call.args, 'userIds') ?? new Array<string>();
    this.handlePromise(result, call.method, manager.getUserInfoById(userIds),
      (map: Map<string, UserInfo>) => UserInfoManagerWrapper.userInfoMapToJson(map));
  }

  private userInfoManager(result: MethodResult, method: string): UserInfoManager | undefined {
    let manager = ChatClient.getInstance().userInfoManager();
    if (manager === undefined) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR,
        `${method} failed: UserInfoManager unavailable, SDK not initialized`);
      return undefined;
    }
    return manager;
  }

  private static userInfoMapToJson(map: Map<string, UserInfo>): Map<string, Object> {
    let ret = new Map<string, Object>();
    map.forEach((userInfo: UserInfo, userId: string) => {
      ret.set(userId, UserInfoHelper.toJson(userInfo));
    });
    return ret;
  }

  override registerEaseListener(): void {
    let manager = ChatClient.getInstance().userInfoManager();
    if (manager === undefined) {
      // SDK not initialized yet; retried lazily on the next method call.
      return;
    }
    if (this.userInfoListener !== undefined) {
      manager.removeListener(this.userInfoListener);
    }
    this.userInfoListener = {
      onSelfUserInfoUpdate: (userInfo: UserInfo): void => {
        let data = new Map<string, Object>();
        data.set('type', ChatUserInfoChangeEvent.ON_SELF_USER_INFO_UPDATE);
        data.set('userInfo', UserInfoHelper.toJson(userInfo));
        this.emitEvent(MethodKey.onUserInfoChanged, data);
      },
      onUserInfoUpdate: (userInfoList: Array<UserInfo>): void => {
        let userInfos = new Array<Object>();
        userInfoList.forEach((userInfo: UserInfo) => {
          userInfos.push(UserInfoHelper.toJson(userInfo));
        });
        let data = new Map<string, Object>();
        data.set('type', ChatUserInfoChangeEvent.ON_USER_INFO_UPDATE);
        data.set('userInfos', userInfos);
        this.emitEvent(MethodKey.onUserInfoChanged, data);
      },
    };
    manager.addListener(this.userInfoListener);
    this.listenerAttached = true;
  }

  override unRegisterEaseListener(): void {
    this.listenerAttached = false;
    if (this.userInfoListener === undefined) {
      return;
    }
    let manager = ChatClient.getInstance().userInfoManager();
    if (manager !== undefined) {
      manager.removeListener(this.userInfoListener);
    }
    this.userInfoListener = undefined;
  }
}
