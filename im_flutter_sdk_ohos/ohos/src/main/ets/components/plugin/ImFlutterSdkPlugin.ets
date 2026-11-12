import {
  FlutterPlugin,
  FlutterPluginBinding,
} from '@ohos/flutter_ohos';
import Wrapper from './Wrapper';
import ClientWrapper from './ClientWrapper';
import ChatManagerWrapper from './ChatManagerWrapper';
import ChatRoomManagerWrapper from './ChatRoomManagerWrapper';
import ContactManagerWrapper from './ContactManagerWrapper';
import GroupManagerWrapper from './GroupManagerWrapper';
import PresenceManagerWrapper from './PresenceManagerWrapper';
import ProgressManagerWrapper from './ProgressManagerWrapper';
import PushManagerWrapper from './PushManagerWrapper';
import UserInfoManagerWrapper from './UserInfoManagerWrapper';
import ConversationWrapper from './ConversationWrapper';
import MessageWrapper from './MessageWrapper';

/**
 * ImFlutterSdkPlugin: one Wrapper per channel.
 * chat_thread_manager is gone entirely: the thread capability was removed
 * from the ohos-branch Dart code (chatsdk has no ChatThread module).
 * Keep in sync with im_flutter_sdk_interface/lib/src/event_handler/channel_manager.dart.
 */
export default class ImFlutterSdkPlugin implements FlutterPlugin {
  private wrappers: Wrapper[] = [];

  constructor() {
  }

  getUniqueClassName(): string {
    return 'ImFlutterSdkPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.wrappers = [
      new ClientWrapper(binding, 'chat_client'),
      new ChatManagerWrapper(binding, 'chat_manager'),
      new ChatRoomManagerWrapper(binding, 'chat_room_manager'),
      new ContactManagerWrapper(binding, 'chat_contact_manager'),
      new GroupManagerWrapper(binding, 'chat_group_manager'),
      new PresenceManagerWrapper(binding, 'chat_presence_manager'),
      new ProgressManagerWrapper(binding, 'file_progress_manager'),
      new PushManagerWrapper(binding, 'chat_push_manager'),
      new UserInfoManagerWrapper(binding, 'chat_userInfo_manager'),
      new ConversationWrapper(binding, 'chat_conversation'),
      new MessageWrapper(binding, 'chat_message'),
    ];
  }

  onDetachedFromEngine(_binding: FlutterPluginBinding): void {
    for (const wrapper of this.wrappers) {
      wrapper.unRegisterEaseListener();
    }
    this.wrappers = [];
  }
}
