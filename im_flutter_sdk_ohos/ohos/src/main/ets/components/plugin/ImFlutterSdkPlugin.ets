import {
  FlutterPlugin,
  FlutterPluginBinding,
  JSONMethodCodec,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import ClientWrapper from './ClientWrapper';

const CHANNEL_PREFIX = 'com.chat.im';

// Channels whose wrappers are not implemented yet (T2.1-T2.10) keep the
// notImplemented fallback. chat_client is served by ClientWrapper.
// chat_thread_manager is gone entirely: the thread capability was removed
// from the ohos-branch Dart code (chatsdk has no ChatThread module).
// Keep in sync with im_flutter_sdk_interface/lib/src/event_handler/channel_manager.dart.
const CHANNEL_NAMES: string[] = [
  'chat_manager',
  'chat_room_manager',
  'chat_contact_manager',
  'chat_group_manager',
  'chat_presence_manager',
  'file_progress_manager',
  'chat_push_manager',
  'chat_userInfo_manager',
  'chat_conversation',
  'chat_message',
];

class NotImplementedHandler implements MethodCallHandler {
  onMethodCall(_call: MethodCall, result: MethodResult): void {
    result.notImplemented();
  }
}

/** ImFlutterSdkPlugin **/
export default class ImFlutterSdkPlugin implements FlutterPlugin {
  private channels: MethodChannel[] = [];
  private clientWrapper: ClientWrapper | null = null;
  private readonly handler: MethodCallHandler = new NotImplementedHandler();

  constructor() {
  }

  getUniqueClassName(): string {
    return 'ImFlutterSdkPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.clientWrapper = new ClientWrapper(binding, 'chat_client');
    for (const name of CHANNEL_NAMES) {
      const channel = new MethodChannel(
        binding.getBinaryMessenger(),
        `${CHANNEL_PREFIX}/${name}`,
        JSONMethodCodec.INSTANCE,
      );
      channel.setMethodCallHandler(this.handler);
      this.channels.push(channel);
    }
  }

  onDetachedFromEngine(_binding: FlutterPluginBinding): void {
    this.clientWrapper?.unRegisterEaseListener();
    this.clientWrapper = null;
    for (const channel of this.channels) {
      channel.setMethodCallHandler(null);
    }
    this.channels = [];
  }
}
