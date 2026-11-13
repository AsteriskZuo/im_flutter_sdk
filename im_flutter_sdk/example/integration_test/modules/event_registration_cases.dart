import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../support/ci_test.dart';

String _unique(String prefix) =>
    '${prefix}_${DateTime.now().microsecondsSinceEpoch}';

/// Connection event handler registration cases (FL-EVENT-001..004).
///
/// These run in the logged-out entry, so they only exercise the local handler
/// registry and never wait for a native event.
void registerLoggedOutEventCases(ChatClient client) {
  ciTestWidgets('FL-EVENT-001 registers a connection event handler',
      (tester) async {
    final id = _unique('ci_conn_add');
    final handler = ConnectionEventHandler();
    client.addConnectionEventHandler(id, handler);
    addTearDown(() => client.removeConnectionEventHandler(id));
    expect(client.getConnectionEventHandler(id), same(handler));
  });

  ciTestWidgets('FL-EVENT-002 replaces a handler with the same identifier',
      (tester) async {
    final id = _unique('ci_conn_cover');
    final first = ConnectionEventHandler();
    final second = ConnectionEventHandler();
    client.addConnectionEventHandler(id, first);
    client.addConnectionEventHandler(id, second);
    addTearDown(() => client.removeConnectionEventHandler(id));
    expect(client.getConnectionEventHandler(id), same(second));
  });

  ciTestWidgets('FL-EVENT-003 removes a connection event handler',
      (tester) async {
    final id = _unique('ci_conn_remove');
    client.addConnectionEventHandler(id, ConnectionEventHandler());
    client.removeConnectionEventHandler(id);
    expect(client.getConnectionEventHandler(id), isNull);
  });

  ciTestWidgets('FL-EVENT-004 clears all connection event handlers',
      (tester) async {
    final first = _unique('ci_conn_clear_a');
    final second = _unique('ci_conn_clear_b');
    client.addConnectionEventHandler(first, ConnectionEventHandler());
    client.addConnectionEventHandler(second, ConnectionEventHandler());
    client.clearConnectionEventHandlers();
    expect(client.getConnectionEventHandler(first), isNull);
    expect(client.getConnectionEventHandler(second), isNull);
  });
}

/// Handler registration cases for the managers that are available once the
/// client is logged in (FL-EVENT-005..035).
///
/// The cases exercise the registry contract only; they do not wait for native
/// callbacks, so they are stable on a single emulator.
void registerManagerEventCases(ChatClient client) {
  // Multi-device (FL-EVENT-005..008).
  ciTestWidgets('FL-EVENT-005 registers a multi-device event handler',
      (tester) async {
    final id = _unique('ci_multi_add');
    final handler = ChatMultiDeviceEventHandler();
    client.addMultiDeviceEventHandler(id, handler);
    addTearDown(() => client.removeMultiDeviceEventHandler(id));
    expect(client.getMultiDeviceEventHandler(id), same(handler));
  });

  ciTestWidgets('FL-EVENT-006 replaces a multi-device handler', (tester) async {
    final id = _unique('ci_multi_cover');
    final first = ChatMultiDeviceEventHandler();
    final second = ChatMultiDeviceEventHandler();
    client.addMultiDeviceEventHandler(id, first);
    client.addMultiDeviceEventHandler(id, second);
    addTearDown(() => client.removeMultiDeviceEventHandler(id));
    expect(client.getMultiDeviceEventHandler(id), same(second));
  });

  ciTestWidgets('FL-EVENT-007 removes a multi-device event handler',
      (tester) async {
    final id = _unique('ci_multi_remove');
    client.addMultiDeviceEventHandler(id, ChatMultiDeviceEventHandler());
    client.removeMultiDeviceEventHandler(id);
    expect(client.getMultiDeviceEventHandler(id), isNull);
  });

  ciTestWidgets('FL-EVENT-008 clears all multi-device event handlers',
      (tester) async {
    final first = _unique('ci_multi_clear_a');
    final second = _unique('ci_multi_clear_b');
    client.addMultiDeviceEventHandler(first, ChatMultiDeviceEventHandler());
    client.addMultiDeviceEventHandler(second, ChatMultiDeviceEventHandler());
    client.clearMultiDeviceEventHandlers();
    expect(client.getMultiDeviceEventHandler(first), isNull);
    expect(client.getMultiDeviceEventHandler(second), isNull);
  });

  // Contact manager (FL-EVENT-009..012).
  ciTestWidgets('FL-EVENT-009 registers a contact event handler',
      (tester) async {
    final id = _unique('ci_contact_add');
    final handler = ChatContactEventHandler();
    client.contactManager.addEventHandler(id, handler);
    addTearDown(() => client.contactManager.removeEventHandler(id));
    expect(client.contactManager.getEventHandler(id), same(handler));
  });

  ciTestWidgets('FL-EVENT-010 replaces a contact handler', (tester) async {
    final id = _unique('ci_contact_cover');
    final first = ChatContactEventHandler();
    final second = ChatContactEventHandler();
    client.contactManager.addEventHandler(id, first);
    client.contactManager.addEventHandler(id, second);
    addTearDown(() => client.contactManager.removeEventHandler(id));
    expect(client.contactManager.getEventHandler(id), same(second));
  });

  ciTestWidgets('FL-EVENT-011 removes a contact event handler', (tester) async {
    final id = _unique('ci_contact_remove');
    client.contactManager.addEventHandler(id, ChatContactEventHandler());
    client.contactManager.removeEventHandler(id);
    expect(client.contactManager.getEventHandler(id), isNull);
  });

  ciTestWidgets('FL-EVENT-012 clears all contact event handlers',
      (tester) async {
    final first = _unique('ci_contact_clear_a');
    final second = _unique('ci_contact_clear_b');
    client.contactManager.addEventHandler(first, ChatContactEventHandler());
    client.contactManager.addEventHandler(second, ChatContactEventHandler());
    client.contactManager.clearEventHandlers();
    expect(client.contactManager.getEventHandler(first), isNull);
    expect(client.contactManager.getEventHandler(second), isNull);
  });

  // Chat manager (FL-EVENT-013..019).
  ciTestWidgets('FL-EVENT-013 registers a chat event handler', (tester) async {
    final id = _unique('ci_chat_add');
    final handler = ChatEventHandler();
    client.chatManager.addEventHandler(id, handler);
    addTearDown(() => client.chatManager.removeEventHandler(id));
    expect(client.chatManager.getEventHandler(id), same(handler));
  });

  ciTestWidgets('FL-EVENT-014 replaces a chat handler', (tester) async {
    final id = _unique('ci_chat_cover');
    final first = ChatEventHandler();
    final second = ChatEventHandler();
    client.chatManager.addEventHandler(id, first);
    client.chatManager.addEventHandler(id, second);
    addTearDown(() => client.chatManager.removeEventHandler(id));
    expect(client.chatManager.getEventHandler(id), same(second));
  });

  ciTestWidgets('FL-EVENT-015 removes a chat event handler', (tester) async {
    final id = _unique('ci_chat_remove');
    client.chatManager.addEventHandler(id, ChatEventHandler());
    client.chatManager.removeEventHandler(id);
    expect(client.chatManager.getEventHandler(id), isNull);
  });

  ciTestWidgets('FL-EVENT-016 clears all chat event handlers', (tester) async {
    final first = _unique('ci_chat_clear_a');
    final second = _unique('ci_chat_clear_b');
    client.chatManager.addEventHandler(first, ChatEventHandler());
    client.chatManager.addEventHandler(second, ChatEventHandler());
    client.chatManager.clearEventHandlers();
    expect(client.chatManager.getEventHandler(first), isNull);
    expect(client.chatManager.getEventHandler(second), isNull);
  });

  ciTestWidgets('FL-EVENT-017 registers a message event handler',
      (tester) async {
    final id = _unique('ci_message_add');
    client.chatManager.addMessageEvent(id, ChatMessageEvent());
    addTearDown(() => client.chatManager.removeMessageEvent(id));
  });

  ciTestWidgets('FL-EVENT-018 removes a message event handler', (tester) async {
    final id = _unique('ci_message_remove');
    client.chatManager.addMessageEvent(id, ChatMessageEvent());
    client.chatManager.removeMessageEvent(id);
  });

  ciTestWidgets('FL-EVENT-019 clears all message event handlers',
      (tester) async {
    final first = _unique('ci_message_clear_a');
    final second = _unique('ci_message_clear_b');
    client.chatManager.addMessageEvent(first, ChatMessageEvent());
    client.chatManager.addMessageEvent(second, ChatMessageEvent());
    client.chatManager.clearMessageEvent();
  });

  // Group manager (FL-EVENT-020..023).
  ciTestWidgets('FL-EVENT-020 registers a group event handler', (tester) async {
    final id = _unique('ci_group_add');
    final handler = ChatGroupEventHandler();
    client.groupManager.addEventHandler(id, handler);
    addTearDown(() => client.groupManager.removeEventHandler(id));
    expect(client.groupManager.getEventHandler(id), same(handler));
  });

  ciTestWidgets('FL-EVENT-021 replaces a group handler', (tester) async {
    final id = _unique('ci_group_cover');
    final first = ChatGroupEventHandler();
    final second = ChatGroupEventHandler();
    client.groupManager.addEventHandler(id, first);
    client.groupManager.addEventHandler(id, second);
    addTearDown(() => client.groupManager.removeEventHandler(id));
    expect(client.groupManager.getEventHandler(id), same(second));
  });

  ciTestWidgets('FL-EVENT-022 removes a group event handler', (tester) async {
    final id = _unique('ci_group_remove');
    client.groupManager.addEventHandler(id, ChatGroupEventHandler());
    client.groupManager.removeEventHandler(id);
    expect(client.groupManager.getEventHandler(id), isNull);
  });

  ciTestWidgets('FL-EVENT-023 clears all group event handlers', (tester) async {
    final first = _unique('ci_group_clear_a');
    final second = _unique('ci_group_clear_b');
    client.groupManager.addEventHandler(first, ChatGroupEventHandler());
    client.groupManager.addEventHandler(second, ChatGroupEventHandler());
    client.groupManager.clearEventHandlers();
    expect(client.groupManager.getEventHandler(first), isNull);
    expect(client.groupManager.getEventHandler(second), isNull);
  });

  // Room manager (FL-EVENT-024..027).
  ciTestWidgets('FL-EVENT-024 registers a chat room event handler',
      (tester) async {
    final id = _unique('ci_room_add');
    final handler = ChatRoomEventHandler();
    client.chatRoomManager.addEventHandler(id, handler);
    addTearDown(() => client.chatRoomManager.removeEventHandler(id));
    expect(client.chatRoomManager.getEventHandler(id), same(handler));
  });

  ciTestWidgets('FL-EVENT-025 replaces a chat room handler', (tester) async {
    final id = _unique('ci_room_cover');
    final first = ChatRoomEventHandler();
    final second = ChatRoomEventHandler();
    client.chatRoomManager.addEventHandler(id, first);
    client.chatRoomManager.addEventHandler(id, second);
    addTearDown(() => client.chatRoomManager.removeEventHandler(id));
    expect(client.chatRoomManager.getEventHandler(id), same(second));
  });

  ciTestWidgets('FL-EVENT-026 removes a chat room event handler',
      (tester) async {
    final id = _unique('ci_room_remove');
    client.chatRoomManager.addEventHandler(id, ChatRoomEventHandler());
    client.chatRoomManager.removeEventHandler(id);
    expect(client.chatRoomManager.getEventHandler(id), isNull);
  });

  ciTestWidgets('FL-EVENT-027 clears all chat room event handlers',
      (tester) async {
    final first = _unique('ci_room_clear_a');
    final second = _unique('ci_room_clear_b');
    client.chatRoomManager.addEventHandler(first, ChatRoomEventHandler());
    client.chatRoomManager.addEventHandler(second, ChatRoomEventHandler());
    client.chatRoomManager.clearEventHandlers();
    expect(client.chatRoomManager.getEventHandler(first), isNull);
    expect(client.chatRoomManager.getEventHandler(second), isNull);
  });

  // Presence manager (FL-EVENT-028..031).
  ciTestWidgets('FL-EVENT-028 registers a presence event handler',
      (tester) async {
    final id = _unique('ci_presence_add');
    final handler = ChatPresenceEventHandler();
    client.presenceManager.addEventHandler(id, handler);
    addTearDown(() => client.presenceManager.removeEventHandler(id));
    expect(client.presenceManager.getEventHandler(id), same(handler));
  });

  ciTestWidgets('FL-EVENT-029 replaces a presence handler', (tester) async {
    final id = _unique('ci_presence_cover');
    final first = ChatPresenceEventHandler();
    final second = ChatPresenceEventHandler();
    client.presenceManager.addEventHandler(id, first);
    client.presenceManager.addEventHandler(id, second);
    addTearDown(() => client.presenceManager.removeEventHandler(id));
    expect(client.presenceManager.getEventHandler(id), same(second));
  });

  ciTestWidgets('FL-EVENT-030 removes a presence event handler',
      (tester) async {
    final id = _unique('ci_presence_remove');
    client.presenceManager.addEventHandler(id, ChatPresenceEventHandler());
    client.presenceManager.removeEventHandler(id);
    expect(client.presenceManager.getEventHandler(id), isNull);
  });

  ciTestWidgets('FL-EVENT-031 clears all presence event handlers',
      (tester) async {
    final first = _unique('ci_presence_clear_a');
    final second = _unique('ci_presence_clear_b');
    client.presenceManager.addEventHandler(first, ChatPresenceEventHandler());
    client.presenceManager.addEventHandler(second, ChatPresenceEventHandler());
    client.presenceManager.clearEventHandlers();
    expect(client.presenceManager.getEventHandler(first), isNull);
    expect(client.presenceManager.getEventHandler(second), isNull);
  });

  // User-info manager (FL-EVENT-032..035).
  ciTestWidgets('FL-EVENT-032 registers a user info event handler',
      (tester) async {
    final id = _unique('ci_userinfo_add');
    final handler = ChatUserInfoEventHandler();
    client.userInfoManager.addEventHandler(id, handler);
    addTearDown(() => client.userInfoManager.removeEventHandler(id));
    expect(client.userInfoManager.getEventHandler(id), same(handler));
  });

  ciTestWidgets('FL-EVENT-033 replaces a user info handler', (tester) async {
    final id = _unique('ci_userinfo_cover');
    final first = ChatUserInfoEventHandler();
    final second = ChatUserInfoEventHandler();
    client.userInfoManager.addEventHandler(id, first);
    client.userInfoManager.addEventHandler(id, second);
    addTearDown(() => client.userInfoManager.removeEventHandler(id));
    expect(client.userInfoManager.getEventHandler(id), same(second));
  });

  ciTestWidgets('FL-EVENT-034 removes a user info event handler',
      (tester) async {
    final id = _unique('ci_userinfo_remove');
    client.userInfoManager.addEventHandler(id, ChatUserInfoEventHandler());
    client.userInfoManager.removeEventHandler(id);
    expect(client.userInfoManager.getEventHandler(id), isNull);
  });

  ciTestWidgets('FL-EVENT-035 clears all user info event handlers',
      (tester) async {
    final first = _unique('ci_userinfo_clear_a');
    final second = _unique('ci_userinfo_clear_b');
    client.userInfoManager.addEventHandler(first, ChatUserInfoEventHandler());
    client.userInfoManager.addEventHandler(second, ChatUserInfoEventHandler());
    client.userInfoManager.clearEventHandlers();
    expect(client.userInfoManager.getEventHandler(first), isNull);
    expect(client.userInfoManager.getEventHandler(second), isNull);
  });
}
