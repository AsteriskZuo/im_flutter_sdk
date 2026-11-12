import {
  FlutterPluginBinding,
  JSONMethodCodec,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import { common } from '@kit.AbilityKit';
import { ChatError } from '@easemob/chatsdk';
import ChatErrorHelper from './models/ChatErrorHelper';

/**
 * Base class for all channel wrappers.
 *
 * Owns the MethodChannel for one channel and provides the shared result
 * protocol (mirrors the android Wrapper / EMWrapperCallBack contract):
 *   - success: `{ <methodName>: <payload> }`, or `{}` when there is no payload
 *   - error:   `{ "error": { "code": number, "description": string } }`
 * Errors are reported through result.success with an "error" entry on purpose:
 * the Dart side reads them via ChatError.hasErrorFromResult.
 */
export default class Wrapper implements MethodCallHandler {
  public context: common.Context;
  public binding: FlutterPluginBinding;
  public channel: MethodChannel;

  constructor(binding: FlutterPluginBinding, channelName: string) {
    this.context = binding.getApplicationContext();
    this.binding = binding;
    this.channel = new MethodChannel(
      binding.getBinaryMessenger(),
      `com.chat.im/${channelName}`,
      JSONMethodCodec.INSTANCE,
    );
    this.channel.setMethodCallHandler(this);
  }

  public onSuccess(result: MethodResult, method: string, object?: Object | null): void {
    let map = new Map<string, Object>();
    if (object !== null && object !== undefined) {
      map.set(method, object);
    }
    result.success(map);
  }

  public onError(result: MethodResult, e: ChatError): void {
    let map = new Map<string, Object>();
    map.set('error', ChatErrorHelper.toJson(e));
    result.success(map);
  }

  public onErrorInfo(result: MethodResult, code: number, desc: string): void {
    let map = new Map<string, Object>();
    map.set('error', ChatErrorHelper.infoToJson(code, desc));
    result.success(map);
  }

  /**
   * Attaches the result protocol to a chatsdk Promise: a resolved value goes
   * through onSuccess (optionally transformed), a rejection through onError.
   * Primitive resolved values (string/number/boolean) are returned as the
   * payload directly; chatsdk models need an explicit transform.
   */
  public handlePromise<T>(
    result: MethodResult,
    method: string,
    promise: Promise<T>,
    transform?: (value: T) => Object,
  ): void {
    promise
      .then((value: T) => {
        if (transform !== undefined) {
          this.onSuccess(result, method, transform(value));
        } else if (
          typeof value === 'string' || typeof value === 'number' || typeof value === 'boolean'
        ) {
          this.onSuccess(result, method, value as Object);
        } else {
          this.onSuccess(result, method);
        }
      })
      .catch((e: ESObject) => {
        if (e instanceof ChatError) {
          this.onError(result, e);
          return;
        }
        // Fallback for unexpected rejection shapes (e.g. BusinessError).
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
        this.onErrorInfo(result, code, desc);
      });
  }

  /**
   * Shared event sink: pushes a native event to the Dart side over this
   * wrapper's channel (mirrors android `channel.invokeMethod(eventKey, data)`).
   */
  public emitEvent(event: string, data: Object | null): void {
    this.channel.invokeMethod(event, data);
  }

  public registerEaseListener(): void {
  }

  public unRegisterEaseListener(): void {
  }

  onMethodCall(_call: MethodCall, result: MethodResult): void {
    result.notImplemented();
  }
}
