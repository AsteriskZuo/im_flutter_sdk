import {
  ChatClient,
  ChatError,
  Conversation,
  PushListener,
  PushManager,
  PushRemindType,
  SilentModeResult,
} from '@easemob/chatsdk';
import { FlutterPluginBinding, MethodCall, MethodResult } from '@ohos/flutter_ohos';
import MethodKey from './MethodKeys';
import Wrapper from './Wrapper';
import SafetyMapTool from './SafetyMapTool';
import ChannelValue from './models/ChannelValue';
import EnumTool from './models/EnumTool';
import PushDisplayStyleHelper from './models/PushDisplayStyleHelper';
import { SilentModeParamHelper, SilentModeResultHelper } from './models/SilentModeHelper';

/**
 * Wrapper for the `com.chat.im/chat_push_manager` channel.
 *
 * Implements the 12 method keys that survived the ohos-branch Dart removal
 * (gap-ledger section 17). The removed keys (updateHMSPushToken /
 * updateFCMPushToken / updateAPNsPushToken / getImPushConfig(FromServer) /
 * reportPushAction / setPreferredNotificationLanguage /
 * fetchPreferredNotificationLanguage / bindPushKitToken / unbindPushKitToken)
 * are intentionally not routed: they no longer exist in the Dart constants,
 * so they fall through to notImplemented.
 *
 * Adaptation points (gap-ledger section 15-5 / 16.1-A#15):
 * - setConversationSilentMode is downgraded to PushRemindType only: chatsdk
 *   conversation-level silent mode accepts no interval/duration param. Any
 *   param SilentModeParamHelper cannot map to a PushRemindType is answered
 *   with an OPERATION_UNSUPPORTED error without calling the SDK.
 * - The chatsdk PushListener (onBindTokenSuccess / onError, both mandatory)
 *   has no Flutter-side push event; it is digested internally into the
 *   bindDeviceToken method-call result. The listener is registered lazily on
 *   the first bindDeviceToken call (the SDK is guaranteed initialized by
 *   then), mirroring ClientWrapper's register-after-init timing.
 */
export default class PushManagerWrapper extends Wrapper {
  private pushListener: PushListener | undefined;
  private pendingBindResult: MethodResult | undefined;
  private pendingBindMethod: string = '';

  constructor(binding: FlutterPluginBinding, channelName: string) {
    super(binding, channelName);
  }

  override onMethodCall(call: MethodCall, result: MethodResult): void {
    if (MethodKey.updateImPushStyle === call.method) {
      this.updateImPushStyle(call, result);
    } else if (MethodKey.updatePushNickname === call.method) {
      this.updatePushNickname(call, result);
    } else if (MethodKey.setConversationSilentMode === call.method) {
      this.setConversationSilentMode(call, result);
    } else if (MethodKey.removeConversationSilentMode === call.method) {
      this.removeConversationSilentMode(call, result);
    } else if (MethodKey.fetchConversationSilentMode === call.method) {
      this.fetchConversationSilentMode(call, result);
    } else if (MethodKey.setSilentModeForAll === call.method) {
      this.setSilentModeForAll(call, result);
    } else if (MethodKey.fetchSilentModeForAll === call.method) {
      this.fetchSilentModeForAll(call, result);
    } else if (MethodKey.fetchSilentModeForConversations === call.method) {
      this.fetchSilentModeForConversations(call, result);
    } else if (MethodKey.setPushTemplate === call.method) {
      this.setPushTemplate(call, result);
    } else if (MethodKey.getPushTemplate === call.method) {
      this.getPushTemplate(call, result);
    } else if (MethodKey.syncSilentModels === call.method) {
      this.syncSilentModels(call, result);
    } else if (MethodKey.bindDeviceToken === call.method) {
      this.bindDeviceToken(call, result);
    } else {
      super.onMethodCall(call, result);
    }
  }

  private updateImPushStyle(call: MethodCall, result: MethodResult): void {
    let manager = this.pushManagerOrError(result);
    if (manager === undefined) {
      return;
    }
    let pushStyle = SafetyMapTool.getNumber(call.args, 'pushStyle') ?? 0;
    let style = PushDisplayStyleHelper.displayStyleFromInt(pushStyle);
    this.handlePromise(result, call.method, manager.updatePushDisplayStyle(style));
  }

  private updatePushNickname(call: MethodCall, result: MethodResult): void {
    let manager = this.pushManagerOrError(result);
    if (manager === undefined) {
      return;
    }
    // Mirrors android: updating the push nickname requires a logged-in user.
    let currentUser = ChatClient.getInstance().getCurrentUser();
    if (currentUser.length === 0) {
      this.onErrorInfo(result, ChatError.USER_NOT_LOGIN, 'User not login');
      return;
    }
    let nickname = SafetyMapTool.getString(call.args, 'nickname', '') ?? '';
    this.handlePromise(result, call.method, manager.updatePushNickname(nickname));
  }

  private setConversationSilentMode(call: MethodCall, result: MethodResult): void {
    let manager = this.pushManagerOrError(result);
    if (manager === undefined) {
      return;
    }
    let conversationId = SafetyMapTool.getString(call.args, 'convId', '') ?? '';
    let conversationType =
      EnumTool.conversationTypeFromInt(SafetyMapTool.getNumber(call.args, 'conversationType') ?? 0);
    let paramValue = ChannelValue.read(call.args, 'param');
    if (paramValue === null) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR, 'missing silent mode param');
      return;
    }
    let param = SilentModeParamHelper.fromJson(paramValue);
    // Conversation-level silent mode accepts PushRemindType only; the helper
    // returns a number for REMIND_TYPE params, an object for interval params
    // and undefined for unsupported ones. Anything that is not a
    // PushRemindType must fail here instead of reaching the SDK.
    if (param === undefined || typeof param !== 'number') {
      this.onErrorInfo(result, ChatError.OPERATION_UNSUPPORTED,
        'conversation silent mode supports REMIND_TYPE param only');
      return;
    }
    this.handlePromise(result, call.method,
      manager.setSilentModeForConversation(conversationId, conversationType, param as PushRemindType));
  }

  private removeConversationSilentMode(call: MethodCall, result: MethodResult): void {
    let manager = this.pushManagerOrError(result);
    if (manager === undefined) {
      return;
    }
    let conversationId = SafetyMapTool.getString(call.args, 'convId', '') ?? '';
    let conversationType =
      EnumTool.conversationTypeFromInt(SafetyMapTool.getNumber(call.args, 'conversationType') ?? 0);
    this.handlePromise(result, call.method,
      manager.clearRemindTypeForConversation(conversationId, conversationType));
  }

  private fetchConversationSilentMode(call: MethodCall, result: MethodResult): void {
    let manager = this.pushManagerOrError(result);
    if (manager === undefined) {
      return;
    }
    let conversationId = SafetyMapTool.getString(call.args, 'convId', '') ?? '';
    let conversationType =
      EnumTool.conversationTypeFromInt(SafetyMapTool.getNumber(call.args, 'conversationType') ?? 0);
    this.handlePromise(result, call.method,
      manager.getSilentModeForConversation(conversationId, conversationType),
      (modeResult: SilentModeResult) => SilentModeResultHelper.toJson(modeResult));
  }

  private setSilentModeForAll(call: MethodCall, result: MethodResult): void {
    let manager = this.pushManagerOrError(result);
    if (manager === undefined) {
      return;
    }
    let paramValue = ChannelValue.read(call.args, 'param');
    if (paramValue === null) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR, 'missing silent mode param');
      return;
    }
    let param = SilentModeParamHelper.fromJson(paramValue);
    if (param === undefined) {
      this.onErrorInfo(result, ChatError.OPERATION_UNSUPPORTED, 'unsupported silent mode paramType');
      return;
    }
    // android answers with a null payload on success; handlePromise does the
    // same for non-primitive resolved values when no transform is given.
    this.handlePromise(result, call.method, manager.setSilentModeForAll(param));
  }

  private fetchSilentModeForAll(call: MethodCall, result: MethodResult): void {
    let manager = this.pushManagerOrError(result);
    if (manager === undefined) {
      return;
    }
    this.handlePromise(result, call.method, manager.getSilentModeForAll(),
      (modeResult: SilentModeResult) => SilentModeResultHelper.toJson(modeResult));
  }

  private fetchSilentModeForConversations(call: MethodCall, result: MethodResult): void {
    let manager = this.pushManagerOrError(result);
    if (manager === undefined) {
      return;
    }
    let chatManager = ChatClient.getInstance().chatManager();
    if (chatManager === undefined) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR, 'ChatManager unavailable: SDK not initialized');
      return;
    }
    // The Dart payload is a flat map of conversationId -> conversationType
    // (mirrors android PushManagerWrapper.fetchSilentModeForConversations).
    let conversations = new Array<Conversation>();
    if (call.args instanceof Map) {
      let entries = call.args as Map<string, Object>;
      for (let conversationId of entries.keys()) {
        let typeValue: Object | undefined = entries.get(conversationId);
        if (typeof typeValue === 'number') {
          let conversation = chatManager.getConversation(conversationId,
            EnumTool.conversationTypeFromInt(typeValue as number), true);
          if (conversation !== undefined) {
            conversations.push(conversation);
          }
        }
      }
    }
    this.handlePromise(result, call.method, manager.getSilentModeForConversations(conversations),
      (resultMap: Map<string, SilentModeResult>) => {
        let ret = new Map<string, Object>();
        for (let conversationId of resultMap.keys()) {
          let modeResult = resultMap.get(conversationId);
          if (modeResult !== undefined) {
            ret.set(conversationId, SilentModeResultHelper.toJson(modeResult));
          }
        }
        return ret;
      });
  }

  private setPushTemplate(call: MethodCall, result: MethodResult): void {
    let manager = this.pushManagerOrError(result);
    if (manager === undefined) {
      return;
    }
    let templateName = SafetyMapTool.getString(call.args, 'pushTemplateName', '') ?? '';
    this.handlePromise(result, call.method, manager.setPushTemplate(templateName));
  }

  private getPushTemplate(call: MethodCall, result: MethodResult): void {
    let manager = this.pushManagerOrError(result);
    if (manager === undefined) {
      return;
    }
    this.handlePromise(result, call.method, manager.getPushTemplate());
  }

  private syncSilentModels(call: MethodCall, result: MethodResult): void {
    let manager = this.pushManagerOrError(result);
    if (manager === undefined) {
      return;
    }
    this.handlePromise(result, call.method, manager.syncConversationsSilentModeFromServer());
  }

  private bindDeviceToken(call: MethodCall, result: MethodResult): void {
    let manager = this.pushManagerOrError(result);
    if (manager === undefined) {
      return;
    }
    if (this.pendingBindResult !== undefined) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR, 'bindDeviceToken already in progress');
      return;
    }
    // Dart notifierName -> chatsdk certName, deviceToken -> token.
    let deviceToken = SafetyMapTool.getString(call.args, 'deviceToken', '') ?? '';
    let notifierName = SafetyMapTool.getString(call.args, 'notifierName', '') ?? '';
    this.pendingBindResult = result;
    this.pendingBindMethod = call.method;
    this.registerEaseListener();
    manager.uploadPushToken(deviceToken, notifierName)
      .then((_token: string) => {
        this.completeBindSuccess();
      })
      .catch((e: ESObject) => {
        this.completeBindError(e);
      });
  }

  /**
   * Answers the pending bindDeviceToken call with an empty success payload
   * (mirrors android's null object). First completion wins: whichever of the
   * uploadPushToken promise and the PushListener fires first consumes the
   * pending result, the other is ignored.
   */
  private completeBindSuccess(): void {
    let pending = this.pendingBindResult;
    if (pending === undefined) {
      return;
    }
    this.pendingBindResult = undefined;
    this.onSuccess(pending, this.pendingBindMethod);
  }

  private completeBindError(e: ESObject): void {
    let pending = this.pendingBindResult;
    if (pending === undefined) {
      return;
    }
    this.pendingBindResult = undefined;
    if (e instanceof ChatError) {
      this.onError(pending, e);
      return;
    }
    // Fallback for unexpected rejection shapes (e.g. BusinessError), same as
    // Wrapper.handlePromise.
    let code = -1;
    let desc = '';
    if (e !== null && e !== undefined && typeof e === 'object') {
      let record = e as Record<string, ESObject>;
      if (typeof record['errorCode'] === 'number') {
        code = record['errorCode'] as number;
      }
      if (typeof record['description'] === 'string') {
        desc = record['description'] as string;
      }
    }
    if (desc.length === 0) {
      desc = `rejected: ${typeof e}`;
    }
    this.onErrorInfo(pending, code, desc);
  }

  override registerEaseListener(): void {
    let manager = ChatClient.getInstance().pushManager();
    if (manager === undefined) {
      return;
    }
    if (this.pushListener !== undefined) {
      manager.removeListener(this.pushListener);
    }
    this.pushListener = {
      onBindTokenSuccess: (_token: string): void => {
        this.completeBindSuccess();
      },
      onError: (error: ChatError): void => {
        this.completeBindError(error);
      },
    };
    manager.addListener(this.pushListener);
  }

  override unRegisterEaseListener(): void {
    if (this.pushListener !== undefined) {
      let manager = ChatClient.getInstance().pushManager();
      if (manager !== undefined) {
        manager.removeListener(this.pushListener);
      }
      this.pushListener = undefined;
    }
    this.pendingBindResult = undefined;
  }

  private pushManagerOrError(result: MethodResult): PushManager | undefined {
    let manager = ChatClient.getInstance().pushManager();
    if (manager === undefined) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR, 'PushManager unavailable: SDK not initialized');
    }
    return manager;
  }
}
