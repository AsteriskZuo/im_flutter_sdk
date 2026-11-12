import 'package:im_flutter_sdk_interface/im_flutter_sdk_interface.dart';

class ClientOhos extends Client {
  static void registerWith() {
    Client.instance = ClientOhos();
  }

  ClientOhos() : super();

  final ChatManager _chatManager = ChatManagerOhos();
  final ChatRoomManager _chatRoomManager = ChatRoomManagerOhos();
  final ContactManager _contactManager = ContactManagerOhos();
  final GroupManager _groupManager = GroupManagerOhos();
  final PresenceManager _presenceManager = PresenceManagerOhos();
  final PushManager _pushManager = PushManagerOhos();
  final UserInfoManager _userInfoManager = UserInfoManagerOhos();
  final ConversationManager _conversationManager = ConversationManagerOhos();
  final MessageManager _messageManager = MessageManagerOhos();
  // ignore: unused_field
  ProgressManager? _progressManager;

  @override
  ChatManager get chatManager => _chatManager;

  @override
  ChatRoomManager get chatRoomManager => _chatRoomManager;

  @override
  ContactManager get contactManager => _contactManager;

  @override
  GroupManager get groupManager => _groupManager;

  @override
  PresenceManager get presenceManager => _presenceManager;

  @override
  PushManager get pushManager => _pushManager;

  @override
  UserInfoManager get userInfoManager => _userInfoManager;

  @override
  ConversationManager get conversationManager => _conversationManager;

  @override
  MessageManager get messageManager => _messageManager;

  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) async {
    return ClientChannel.invokeMethod(method, params);
  }
}

class ChatManagerOhos extends ChatManager {
  ChatManagerOhos() : super();
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) async {
    return ChatChannel.invokeMethod(method, params);
  }
}

class ChatRoomManagerOhos extends ChatRoomManager {
  ChatRoomManagerOhos() : super();
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) async {
    return ChatRoomChannel.invokeMethod(method, params);
  }
}

class ContactManagerOhos extends ContactManager {
  ContactManagerOhos() : super();
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) async {
    return ContactChannel.invokeMethod(method, params);
  }
}

class GroupManagerOhos extends GroupManager {
  GroupManagerOhos() : super();
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) async {
    return GroupChannel.invokeMethod(method, params);
  }
}

class PresenceManagerOhos extends PresenceManager {
  PresenceManagerOhos() : super();
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) async {
    return PresenceChannel.invokeMethod(method, params);
  }
}

class PushManagerOhos extends PushManager {
  PushManagerOhos() : super();
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) async {
    return PushChannel.invokeMethod(method, params);
  }
}

class UserInfoManagerOhos extends UserInfoManager {
  UserInfoManagerOhos() : super();
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) async {
    return UserInfoChannel.invokeMethod(method, params);
  }
}

class ConversationManagerOhos extends ConversationManager {
  ConversationManagerOhos() : super();
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) async {
    return ConversationChannel.invokeMethod(method, params);
  }
}

class MessageManagerOhos extends MessageManager {
  MessageManagerOhos() : super();
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) async {
    return MessageChannel.invokeMethod(method, params);
  }
}
