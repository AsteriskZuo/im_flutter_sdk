import 'package:flutter/foundation.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import 'env.dart';

/// The [ChatOptions] shared by every stable CI entry.
///
/// Every switch that can change behavior is explicit here. The native SDK
/// persists state in the app sandbox, so a different option set needs a fresh
/// test process; each entry file is executed as its own process by the runner.
///
/// [requireUserToken] must stay false for the logged-out smoke entry, which is
/// runnable without any local data preparation.
ChatOptions ciChatOptions({
  bool enableUserInfo = false,
  bool enableAutoSyncContacts = false,
  bool enableChatroomConversation = false,
  bool autoLoadConversations = true,
  bool requireUserToken = true,
}) {
  requireCiEnvironment(requireUserToken: requireUserToken);
  return ChatOptions.withAppKey(
    ciAppKey,
    autoLogin: false,
    debugMode: false,
    enableUserInfo: enableUserInfo,
    enableAutoSyncContacts: enableAutoSyncContacts,
    enableChatroomConversation: enableChatroomConversation,
    autoLoadConversations: autoLoadConversations,
  );
}

/// Initializes the singleton client for a CI entry.
Future<void> initCiClient({
  bool enableUserInfo = false,
  bool enableAutoSyncContacts = false,
  bool enableChatroomConversation = false,
  bool autoLoadConversations = true,
  bool requireUserToken = true,
}) async {
  await ChatClient.getInstance.init(
    ciChatOptions(
      enableUserInfo: enableUserInfo,
      enableAutoSyncContacts: enableAutoSyncContacts,
      enableChatroomConversation: enableChatroomConversation,
      autoLoadConversations: autoLoadConversations,
      requireUserToken: requireUserToken,
    ),
  );
}

/// Clears a session persisted by an earlier run so the entry starts logged out.
Future<void> ensureLoggedOutForCi(ChatClient client) async {
  if (await client.isConnected() || client.currentUserId != null) {
    try {
      await client.logout(false);
      await client.getCurrentUserId();
    } on ChatError catch (error) {
      // A persisted session that the native SDK no longer recognizes must not
      // abort the entry; the cached user id is refreshed below.
      debugPrint('CI logout while idling returned code=${error.code}');
      await client.getCurrentUserId();
    }
  }
}

/// Clears pinned conversations left behind by earlier runs of the shared CI
/// account so pin/unpin cases start from a known server state.
Future<void> clearPinnedConversationsForCi(ChatClient client) async {
  try {
    final pinned = await client.chatManager.fetchConversationsByOptions(
      options: ConversationFetchOptions.pinned(pageSize: 50),
    );
    for (final conversation in pinned.data) {
      try {
        await client.chatManager.pinConversation(
          conversationId: conversation.id,
          isPinned: false,
        );
      } on ChatError catch (error) {
        debugPrint(
          'CI unpin cleanup skipped for ${conversation.id}: code=${error.code}',
        );
      }
    }
    if (pinned.data.isNotEmpty) {
      debugPrint(
          'CI cleared ${pinned.data.length} leftover pinned conversation(s)');
    }
  } on ChatError catch (error) {
    debugPrint('CI pinned conversation cleanup failed: code=${error.code}');
  }
}

/// Best-effort logout used by [tearDownAll].
Future<void> disposeCiClient(ChatClient client) async {
  try {
    if (await client.isConnected() || client.currentUserId != null) {
      await client.logout(false);
    }
  } on ChatError catch (error) {
    debugPrint('CI dispose logout returned code=${error.code}');
  }
}
