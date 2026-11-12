# Flutter 侧公开 API 表面盘点（基线 4.25.0）

- 盘点对象：git worktree `.worktree/ohos`（分支 `ohos`，`im_flutter_sdk/pubspec.yaml` version = 4.25.0）
- 用途：鸿蒙 ArkTS 重写（P2）逐方法映射环信 HarmonyOS chatsdk API 的对照基线
- 盘点日期：2026-11-12
- 来源文件（均在 worktree 内）：
  - `im_flutter_sdk/lib/src/internal/chat_method_keys.dart`（MethodChannel 方法/事件 key）
  - `im_flutter_sdk/lib/src/internal/chat_event_keys.dart`（原生回调事件 type）
  - `im_flutter_sdk_interface/lib/src/event_handler/channel_manager.dart`（MethodChannel 定义）
  - `im_flutter_sdk/lib/src/managers/*.dart`、`im_flutter_sdk/lib/src/models/chat_conversation.dart`、`im_flutter_sdk/lib/src/models/chat_message.dart`（公开方法）

## 统计汇总

| 指标 | 数量 | 说明 |
|---|---|---|
| Method key 常量总数 | **319** | `ChatMethodKeys` 全部 `static const String` |
| 其中：方法（请求）key | 271 | Dart 主动调用原生 |
| 其中：事件/监听 key | 48 | 原生回调 Dart（字符串值以 `on` 开头） |
| 事件常量（`chat_event_keys.dart`） | **52** | 按 `type` 字段二次分发的子事件：Contact 8 / Room 16 / Group 26 / UserInfo 2 |
| MethodChannel 数 | **12** | 前缀 `com.chat.im`，全部 `JSONMethodCodec` |
| Manager 数 | **9** | `ChatClient` + 8 个业务 Manager |
| 有公开实例方法的 Model | 2 | `ChatConversation`（23 个）、`ChatMessage`（4 个异步方法） |
| Model 文件数 | **40** | `lib/src/models/` |
| Model 类数 | **51** | 含抽象类 `ChatMessageBody` 及 9 个消息体子类 |
| 枚举数 | **24** | `chat_enums.dart` 22 + `chat_message_stream_chunk.dart` 1 + `chat_voice_param.dart` 1 |

## 1. MethodChannel 清单（12 个）

来源：`im_flutter_sdk_interface/lib/src/event_handler/channel_manager.dart`，前缀常量 `channelPrefix = 'com.chat.im'`。

| Dart 常量 | Channel 名 |
|---|---|
| ChatChannel | com.chat.im/chat_manager |
| ChatRoomChannel | com.chat.im/chat_room_manager |
| ThreadChannel | com.chat.im/chat_thread_manager |
| ContactChannel | com.chat.im/chat_contact_manager |
| GroupChannel | com.chat.im/chat_group_manager |
| PresenceChannel | com.chat.im/chat_presence_manager |
| ProgressChannel | com.chat.im/file_progress_manager |
| ClientChannel | com.chat.im/chat_client |
| PushChannel | com.chat.im/chat_push_manager |
| UserInfoChannel | com.chat.im/chat_userInfo_manager |
| ConversationChannel | com.chat.im/chat_conversation |
| MessageChannel | com.chat.im/chat_message |

注意：`chat_userInfo_manager` 中 `userInfo` 为大写 I（与原生侧保持一致，移植时不要“修正”为小写）。另外 `MessageCallBackManager`（位于 `chat_manager.dart` 文件尾部）内部自行创建了同名 `com.chat.im/chat_message` channel。

## 2. Method key 总表（319 个）

按 `chat_method_keys.dart` 源文件顺序与注释分组。「对应公开方法」列为 Dart 公开 API；`—` 表示无对应公开方法（事件 key 为原生→Dart 回调，「对应」列给出接收的事件处理器）；**加粗** 为盘点发现的异常（常量无任何引用，详见第 6 节）。

### 2.1 ChatClient 方法（17）— channel: chat_client

| 常量名 | 字符串值 | 对应公开方法 |
|---|---|---|
| init | `init` | `ChatClient.init` |
| createAccount | `createAccount` | `ChatClient.createAccount` |
| login | `login` | `ChatClient.login`（Deprecated）；`loginWithToken`/`loginWithPassword`/`loginWithAgoraToken`（Deprecated）内部均走此方法 |
| **loginWithAgoraToken** | `loginWithAgoraToken` | **无引用**（同名 Deprecated 方法内部调用 `login`） |
| renewToken | `renewToken` | `ChatClient.renewAgoraToken` |
| logout | `logout` | `ChatClient.logout` |
| changeAppKey | `changeAppKey` | `ChatClient.changeAppKey`（`changeAppId` 复用该 key 读取返回值，见异常） |
| **uploadLog** | `uploadLog` | **无引用** |
| compressLogs | `compressLogs` | `ChatClient.compressLogs` |
| kickDevice | `kickDevice` | `ChatClient.kickDevice` |
| kickAllDevices | `kickAllDevices` | `ChatClient.kickAllDevices` |
| getLoggedInDevicesFromServer | `getLoggedInDevicesFromServer` | `ChatClient.fetchLoggedInDevices`；`getLoggedInDevicesFromServer`（Deprecated） |
| getToken | `getToken` | `ChatClient.getAccessToken` |
| getCurrentUser | `getCurrentUser` | `ChatClient.getCurrentUserId` |
| getCurrentDeviceId | `getCurrentDeviceId` | `ChatClient.getCurrentDeviceId` |
| isLoggedInBefore | `isLoggedInBefore` | `ChatClient.isLoginBefore` |
| isConnected | `isConnected` | `ChatClient.isConnected` |

### 2.2 ChatClient listener（18）— channel: chat_client

| 常量名 | 字符串值 | 对应事件处理器 |
|---|---|---|
| onMultiDeviceGroupEvent | `onMultiDeviceGroupEvent` | `ChatMultiDeviceEventHandler.onGroupEvent` |
| onMultiDeviceContactEvent | `onMultiDeviceContactEvent` | `ChatMultiDeviceEventHandler.onContactEvent` |
| onMultiDeviceThreadEvent | `onMultiDeviceThreadEvent` | `ChatMultiDeviceEventHandler.onChatThreadEvent` |
| onMultiDeviceRemoveMessagesEvent | `onMultiDeviceRemoveMessagesEvent` | `ChatMultiDeviceEventHandler.onRemoteMessagesRemoved` |
| onMultiDevicesConversationEvent | `onMultiDevicesConversationEvent` | `ChatMultiDeviceEventHandler.onConversationEvent` |
| onConnected | `onConnected` | `ConnectionEventHandler.onConnected` |
| onDisconnected | `onDisconnected` | `ConnectionEventHandler.onDisconnected`（`onUserAuthenticationFailed` 也分发到此回调） |
| onUserDidLoginFromOtherDevice | `onUserDidLoginFromOtherDevice` | `ConnectionEventHandler.onUserDidLoginFromOtherDevice` |
| onUserDidRemoveFromServer | `onUserDidRemoveFromServer` | `ConnectionEventHandler.onUserDidRemoveFromServer` |
| onUserDidForbidByServer | `onUserDidForbidByServer` | `ConnectionEventHandler.onUserDidForbidByServer` |
| onUserDidChangePassword | `onUserDidChangePassword` | `ConnectionEventHandler.onUserDidChangePassword` |
| onUserDidLoginTooManyDevice | `onUserDidLoginTooManyDevice` | `ConnectionEventHandler.onUserDidLoginTooManyDevice` |
| onUserKickedByOtherDevice | `onUserKickedByOtherDevice` | `ConnectionEventHandler.onUserKickedByOtherDevice` |
| onUserAuthenticationFailed | `onUserAuthenticationFailed` | 分发到 `ConnectionEventHandler.onDisconnected`（无独立回调） |
| onSendDataToFlutter | `onSendDataToFlutter` | `ChatClient.customEventHandler` |
| onTokenWillExpire | `onTokenWillExpire` | `ConnectionEventHandler.onTokenWillExpire` |
| onTokenDidExpire | `onTokenDidExpire` | `ConnectionEventHandler.onTokenDidExpire` |
| onAppActiveNumberReachLimit | `onAppActiveNumberReachLimit` | `ConnectionEventHandler.onAppActiveNumberReachLimit` |

### 2.3 ChatContactManager（17 = 16 方法 + 1 事件）— channel: chat_contact_manager

| 常量名 | 字符串值 | 对应公开方法 |
|---|---|---|
| addContact | `addContact` | `ChatContactManager.addContact` |
| deleteContact | `deleteContact` | `ChatContactManager.deleteContact` |
| getAllContactsFromServer | `getAllContactsFromServer` | `ChatContactManager.fetchAllContactIds`；`getAllContactsFromServer`（Deprecated） |
| getAllContactsFromDB | `getAllContactsFromDB` | `ChatContactManager.getAllContactIds`；`getAllContactsFromDB`（Deprecated） |
| addUserToBlockList | `addUserToBlockList` | `ChatContactManager.addUserToBlockList` |
| removeUserFromBlockList | `removeUserFromBlockList` | `ChatContactManager.removeUserFromBlockList` |
| getBlockListFromServer | `getBlockListFromServer` | `ChatContactManager.fetchBlockIds`；`getBlockListFromServer`（Deprecated） |
| getBlockListFromDB | `getBlockListFromDB` | `ChatContactManager.getBlockIds`；`getBlockListFromDB`（Deprecated） |
| acceptInvitation | `acceptInvitation` | `ChatContactManager.acceptInvitation` |
| declineInvitation | `declineInvitation` | `ChatContactManager.declineInvitation` |
| getSelfIdsOnOtherPlatform | `getSelfIdsOnOtherPlatform` | `ChatContactManager.getSelfIdsOnOtherPlatform` |
| getAllContacts | `getAllContacts` | `ChatContactManager.getAllContacts` |
| setContactRemark | `setContactRemark` | `ChatContactManager.setContactRemark` |
| getContact | `getContact` | `ChatContactManager.getContact` |
| fetchAllContacts | `fetchAllContacts` | `ChatContactManager.fetchAllContacts` |
| fetchContacts | `fetchContacts` | `ChatContactManager.fetchContacts` |
| onContactChanged | `onContactChanged` | 事件：按 `type` 分发到 `ChatContactChangeEvent`（见第 3 节）→ `ChatContactEventHandler` |

### 2.4 ChatManager 方法（38 + 4.25.0 新增 4 = 42）— channel: chat_manager

| 常量名 | 字符串值 | 对应公开方法 |
|---|---|---|
| sendMessage | `sendMessage` | `ChatManager.sendMessage` |
| resendMessage | `resendMessage` | `ChatManager.resendMessage` |
| ackMessageRead | `ackMessageRead` | `ChatManager.sendMessageReadAck` |
| ackGroupMessageRead | `ackGroupMessageRead` | `ChatManager.sendGroupMessageReadAck` |
| ackConversationRead | `ackConversationRead` | `ChatManager.sendConversationReadAck` |
| recallMessage | `recallMessage` | `ChatManager.recallMessage` |
| getConversation | `getConversation` | `ChatManager.getConversation` |
| getThreadConversation | `getThreadConversation` | `ChatManager.getThreadConversation` |
| markAllChatMsgAsRead | `markAllChatMsgAsRead` | `ChatManager.markAllConversationsAsRead` |
| getUnreadMessageCount | `getUnreadMessageCount` | `ChatManager.getUnreadMessageCount` |
| updateChatMessage | `updateChatMessage` | `ChatManager.updateMessage` |
| downloadAttachment | `downloadAttachment` | `ChatManager.downloadAttachment` |
| downloadThumbnail | `downloadThumbnail` | `ChatManager.downloadThumbnail` |
| downloadMessageAttachmentInCombine | `downloadMessageAttachmentInCombine` | `ChatManager.downloadMessageAttachmentInCombine` |
| downloadMessageThumbnailInCombine | `downloadMessageThumbnailInCombine` | `ChatManager.downloadMessageThumbnailInCombine` |
| importMessages | `importMessages` | `ChatManager.importMessages` |
| loadAllConversations | `loadAllConversations` | `ChatManager.loadAllConversations` |
| getConversationsFromServer | `getConversationsFromServer` | `ChatManager.getConversationsFromServer`（Deprecated） |
| deleteConversation | `deleteConversation` | `ChatManager.deleteConversation` |
| fetchHistoryMessages | `fetchHistoryMessages` | `ChatManager.fetchHistoryMessages`（Deprecated） |
| fetchHistoryMessagesByOptions | `fetchHistoryMessagesByOptions` | `ChatManager.fetchHistoryMessagesByOption` |
| searchChatMsgFromDB | `searchChatMsgFromDB` | `ChatManager.loadMessagesWithKeyword`、`ChatManager.searchMsgFromDB`（Deprecated）共用此 key |
| getMessage | `getMessage` | `ChatManager.loadMessage` |
| asyncFetchGroupAcks | `asyncFetchGroupAcks` | `ChatManager.fetchGroupAcks` |
| deleteRemoteConversation | `deleteRemoteConversation` | `ChatManager.deleteRemoteConversation` |
| deleteMessagesBeforeTimestamp | `deleteMessagesBeforeTimestamp` | `ChatManager.deleteMessagesBefore` |
| translateMessage | `translateMessage` | `ChatManager.translateMessage` |
| fetchSupportLanguages | `fetchSupportLanguages` | `ChatManager.fetchSupportedLanguages` |
| addReaction | `addReaction` | `ChatManager.addReaction` |
| removeReaction | `removeReaction` | `ChatManager.removeReaction` |
| fetchReactionList | `fetchReactionList` | `ChatManager.fetchReactionList` |
| fetchReactionDetail | `fetchReactionDetail` | `ChatManager.fetchReactionDetail` |
| reportMessage | `reportMessage` | `ChatManager.reportMessage` |
| fetchConversationsFromServerWithPage | `fetchConversationsFromServerWithPage` | `ChatManager.fetchConversationListFromServer`（Deprecated） |
| removeMessagesFromServerWithMsgIds | `removeMessagesFromServerWithMsgIds` | `ChatManager.deleteRemoteMessagesWithIds` |
| removeMessagesFromServerWithTs | `removeMessagesFromServerWithTs` | `ChatManager.deleteRemoteMessagesBefore` |
| getConversationsFromServerWithCursor | `getConversationsFromServerWithCursor` | `ChatManager.fetchConversation`（Deprecated） |
| getPinnedConversationsFromServerWithCursor | `getPinnedConversationsFromServerWithCursor` | `ChatManager.fetchPinnedConversations`（Deprecated） |
| getConversationsFromDBWithCursor（4.25.0） | `getConversationsFromDBWithCursor` | `ChatManager.fetchConversationsFromDB` |
| pinConversation（4.25.0） | `pinConversation` | `ChatManager.pinConversation` |
| modifyMessage（4.25.0） | `modifyMessage` | `ChatManager.modifyMessage` |
| downloadAndParseCombineMessage（4.25.0） | `downloadAndParseCombineMessage` | `ChatManager.fetchCombineMessageDetail` |

### 2.5 ChatManager listener（13）+ ChatMessage listener（5）+ Presence delegate（1）

| 常量名 | 字符串值 | 对应事件处理器 |
|---|---|---|
| onMessagesReceived | `onMessagesReceived` | `ChatEventHandler.onMessagesReceived` |
| onStreamMessagesReceived | `onStreamMessagesReceived` | `ChatEventHandler.onStreamMessagesReceived` |
| onCmdMessagesReceived | `onCmdMessagesReceived` | `ChatEventHandler.onCmdMessagesReceived` |
| onMessagesRead | `onMessagesRead` | `ChatEventHandler.onMessagesRead` |
| onReadAckForGroupMessageUpdated | `onReadAckForGroupMessageUpdated` | `ChatEventHandler.onReadAckForGroupMessageUpdated` |
| onGroupMessageRead | `onGroupMessageRead` | `ChatEventHandler.onGroupMessageRead` |
| onMessagesDelivered | `onMessagesDelivered` | `ChatEventHandler.onMessagesDelivered` |
| onMessagesRecalled | `onMessagesRecalled` | `ChatEventHandler.onMessagesRecalled` |
| **onMessageChanged** | `onMessageChanged` | **无引用**（Dart 侧无任何分发，见异常） |
| onConversationUpdate | `onConversationUpdate` | `ChatEventHandler.onConversationsUpdate` |
| onConversationHasRead | `onConversationHasRead` | `ChatEventHandler.onConversationRead` |
| onMessageReactionDidChange | `messageReactionDidChange` ⚠值与常量名不同 | `ChatEventHandler.onMessageReactionDidChange` |
| onMessageContentChanged | `onMessageContentChanged` | `ChatEventHandler.onMessageContentChanged` |
| onMessageProgressUpdate | `onMessageProgressUpdate` | `ChatMessageEvent.onProgress`（经 `MessageCallBackManager`，channel: chat_message） |
| onMessageError | `onMessageError` | `ChatMessageEvent.onError` |
| onMessageSuccess | `onMessageSuccess` | `ChatMessageEvent.onSuccess` |
| **onMessageReadAck** | `onMessageReadAck` | **无引用** |
| **onMessageDeliveryAck** | `onMessageDeliveryAck` | **无引用** |
| onPresenceStatusChanged | `onPresenceStatusChanged` | `ChatPresenceEventHandler.onPresenceStatusChanged`（channel: chat_presence_manager） |

### 2.6 ChatConversation 方法（20）— channel: chat_conversation

| 常量名 | 字符串值 | 对应公开方法 |
|---|---|---|
| getUnreadMsgCount | `getUnreadMsgCount` | `ChatConversation.unreadCount` |
| markAllMessagesAsRead | `markAllMessagesAsRead` | `ChatConversation.markAllMessagesAsRead` |
| markMessageAsRead | `markMessageAsRead` | `ChatConversation.markMessageAsRead` |
| syncConversationExt | `syncConversationExt` | `ChatConversation.setExt` |
| removeMessage | `removeMessage` | `ChatConversation.deleteMessage` |
| deleteMessageByIds | `deleteMessageByIds` | `ChatConversation.deleteMessageByIds` |
| getLatestMessage | `getLatestMessage` | `ChatConversation.latestMessage` |
| getLatestMessageFromOthers | `getLatestMessageFromOthers` | `ChatConversation.lastReceivedMessage` |
| clearAllMessages | `clearAllMessages` | `ChatConversation.deleteAllMessages` |
| deleteMessagesWithTs | `deleteMessagesWithTs` | `ChatConversation.deleteMessagesWithTs` |
| insertMessage | `insertMessage` | `ChatConversation.insertMessage` |
| appendMessage | `appendMessage` | `ChatConversation.appendMessage` |
| updateConversationMessage | `updateConversationMessage` | `ChatConversation.updateMessage` |
| loadMsgWithId | `loadMsgWithId` | `ChatConversation.loadMessage` |
| loadMsgWithStartId | `loadMsgWithStartId` | `ChatConversation.loadMessages` |
| loadMsgWithKeywords | `loadMsgWithKeywords` | `ChatConversation.loadMessagesWithKeyword` |
| loadMsgWithMsgType | `loadMsgWithMsgType` | `ChatConversation.loadMessagesWithMsgType` |
| loadMsgWithTime | `loadMsgWithTime` | `ChatConversation.loadMessagesFromTime` |
| messageCount | `messageCount` | `ChatConversation.messagesCount` |
| **removeMsgFromServerWithTimeStamp** | `removeMsgFromServerWithTimeStamp` | **无引用**（4.8.1 起由 `conversationDeleteServerMessageWithTime` 替代，旧常量未删） |

### 2.7 ChatMessage 方法（3）— channel: chat_message

| 常量名 | 字符串值 | 对应公开方法 |
|---|---|---|
| getReactionList | `getReactionList` | `ChatMessage.reactionList` |
| groupAckCount | `groupAckCount` | `ChatMessage.groupAckCount` |
| getChatThread | `chatThread` ⚠值与常量名不同 | `ChatMessage.chatThread` |

### 2.8 ChatRoomManager（36 方法 + 1 事件）— channel: chat_room_manager

| 常量名 | 字符串值 | 对应公开方法 |
|---|---|---|
| joinChatRoom | `joinChatRoom` | `ChatRoomManager.joinChatRoom` |
| leaveChatRoom | `leaveChatRoom` | `ChatRoomManager.leaveChatRoom` |
| fetchPublicChatRoomsFromServer | `fetchPublicChatRoomsFromServer` | `ChatRoomManager.fetchPublicChatRoomsFromServer` |
| fetchChatRoomInfoFromServer | `fetchChatRoomInfoFromServer` | `ChatRoomManager.fetchChatRoomInfoFromServer` |
| getChatRoom | `getChatRoom` | `ChatRoomManager.getChatRoomWithId` |
| **getAllChatRooms** | `getAllChatRooms` | **无引用**（无对应公开方法） |
| createChatRoom | `createChatRoom` | `ChatRoomManager.createChatRoom` |
| destroyChatRoom | `destroyChatRoom` | `ChatRoomManager.destroyChatRoom` |
| changeChatRoomSubject | `changeChatRoomSubject` | `ChatRoomManager.changeChatRoomName` |
| changeChatRoomDescription | `changeChatRoomDescription` | `ChatRoomManager.changeChatRoomDescription` |
| fetchChatRoomMembers | `fetchChatRoomMembers` | `ChatRoomManager.fetchChatRoomMembers` |
| muteChatRoomMembers | `muteChatRoomMembers` | `ChatRoomManager.muteChatRoomMembers` |
| unMuteChatRoomMembers | `unMuteChatRoomMembers` | `ChatRoomManager.unMuteChatRoomMembers` |
| changeChatRoomOwner | `changeChatRoomOwner` | `ChatRoomManager.changeOwner` |
| addChatRoomAdmin | `addChatRoomAdmin` | `ChatRoomManager.addChatRoomAdmin` |
| removeChatRoomAdmin | `removeChatRoomAdmin` | `ChatRoomManager.removeChatRoomAdmin` |
| fetchChatRoomMuteList | `fetchChatRoomMuteList` | `ChatRoomManager.fetchChatRoomMuteList` |
| removeChatRoomMembers | `removeChatRoomMembers` | `ChatRoomManager.removeChatRoomMembers` |
| blockChatRoomMembers | `blockChatRoomMembers` | `ChatRoomManager.blockChatRoomMembers` |
| unBlockChatRoomMembers | `unBlockChatRoomMembers` | `ChatRoomManager.unBlockChatRoomMembers` |
| fetchChatRoomBlockList | `fetchChatRoomBlockList` | `ChatRoomManager.fetchChatRoomBlockList` |
| updateChatRoomAnnouncement | `updateChatRoomAnnouncement` | `ChatRoomManager.updateChatRoomAnnouncement` |
| fetchChatRoomAnnouncement | `fetchChatRoomAnnouncement` | `ChatRoomManager.fetchChatRoomAnnouncement` |
| addMembersToChatRoomWhiteList | `addMembersToChatRoomWhiteList` | `ChatRoomManager.addMembersToChatRoomAllowList` |
| removeMembersFromChatRoomWhiteList | `removeMembersFromChatRoomWhiteList` | `ChatRoomManager.removeMembersFromChatRoomAllowList` |
| fetchChatRoomWhiteListFromServer | `fetchChatRoomWhiteListFromServer` | `ChatRoomManager.fetchChatRoomAllowListFromServer` |
| isMemberInChatRoomWhiteListFromServer | `isMemberInChatRoomWhiteListFromServer` | `ChatRoomManager.isMemberInChatRoomAllowList` |
| muteAllChatRoomMembers | `muteAllChatRoomMembers` | `ChatRoomManager.muteAllChatRoomMembers` |
| unMuteAllChatRoomMembers | `unMuteAllChatRoomMembers` | `ChatRoomManager.unMuteAllChatRoomMembers` |
| fetchChatRoomAttributes | `fetchChatRoomAttributes` | `ChatRoomManager.fetchChatRoomAttributes` |
| setChatRoomAttributes | `setChatRoomAttributes` | `ChatRoomManager.addAttributes` |
| removeChatRoomAttributes | `removeChatRoomAttributes` | `ChatRoomManager.removeAttributes` |
| chatRoomChange | `onChatRoomChanged` ⚠值与常量名不同 | 事件：按 `type` 分发到 `ChatRoomEvent`（见第 3 节）→ `ChatRoomEventHandler` |

### 2.9 ChatGroupManager（47 方法 + 1 事件）— channel: chat_group_manager

| 常量名 | 字符串值 | 对应公开方法 |
|---|---|---|
| getGroupWithId | `getGroupWithId` | `ChatGroupManager.getGroupWithId` |
| getJoinedGroups | `getJoinedGroups` | `ChatGroupManager.getJoinedGroups` |
| getJoinedGroupsFromServer | `getJoinedGroupsFromServer` | `ChatGroupManager.fetchJoinedGroupsFromServer` |
| getPublicGroupsFromServer | `getPublicGroupsFromServer` | `ChatGroupManager.fetchPublicGroupsFromServer` |
| createGroup | `createGroup` | `ChatGroupManager.createGroup` |
| getGroupSpecificationFromServer | `getGroupSpecificationFromServer` | `ChatGroupManager.fetchGroupInfoFromServer` |
| getGroupMemberListFromServer | `getGroupMemberListFromServer` | `ChatGroupManager.fetchMemberListFromServer` |
| getGroupBlockListFromServer | `getGroupBlockListFromServer` | `ChatGroupManager.fetchBlockListFromServer` |
| getGroupMuteListFromServer | `getGroupMuteListFromServer` | `ChatGroupManager.fetchMuteListFromServer` |
| getGroupWhiteListFromServer | `getGroupWhiteListFromServer` | `ChatGroupManager.fetchAllowListFromServer` |
| isMemberInWhiteListFromServer | `isMemberInWhiteListFromServer` | `ChatGroupManager.isMemberInAllowListFromServer` |
| getGroupFileListFromServer | `getGroupFileListFromServer` | `ChatGroupManager.fetchGroupFileListFromServer` |
| getGroupAnnouncementFromServer | `getGroupAnnouncementFromServer` | `ChatGroupManager.fetchAnnouncementFromServer` |
| addMembers | `addMembers` | `ChatGroupManager.addMembers` |
| inviterUser | `inviterUser` | `ChatGroupManager.inviterUser` |
| removeMembers | `removeMembers` | `ChatGroupManager.removeMembers` |
| blockMembers | `blockMembers` | `ChatGroupManager.blockMembers` |
| unblockMembers | `unblockMembers` | `ChatGroupManager.unblockMembers` |
| updateGroupSubject | `updateGroupSubject` | `ChatGroupManager.updateGroupName`；`changeGroupName`（Deprecated） |
| updateDescription | `updateDescription` | `ChatGroupManager.updateGroupDesc`；`changeGroupDescription`（Deprecated） |
| leaveGroup | `leaveGroup` | `ChatGroupManager.leaveGroup` |
| destroyGroup | `destroyGroup` | `ChatGroupManager.destroyGroup` |
| blockGroup | `blockGroup` | `ChatGroupManager.blockGroup` |
| unblockGroup | `unblockGroup` | `ChatGroupManager.unblockGroup` |
| updateGroupOwner | `updateGroupOwner` | `ChatGroupManager.changeOwner` |
| addAdmin | `addAdmin` | `ChatGroupManager.addAdmin` |
| removeAdmin | `removeAdmin` | `ChatGroupManager.removeAdmin` |
| muteMembers | `muteMembers` | `ChatGroupManager.muteMembers` |
| unMuteMembers | `unMuteMembers` | `ChatGroupManager.unMuteMembers` |
| muteAllMembers | `muteAllMembers` | `ChatGroupManager.muteAllMembers` |
| unMuteAllMembers | `unMuteAllMembers` | `ChatGroupManager.unMuteAllMembers` |
| addWhiteList | `addWhiteList` | `ChatGroupManager.addAllowList` |
| removeWhiteList | `removeWhiteList` | `ChatGroupManager.removeAllowList` |
| uploadGroupSharedFile | `uploadGroupSharedFile` | `ChatGroupManager.uploadGroupSharedFile` |
| downloadGroupSharedFile | `downloadGroupSharedFile` | `ChatGroupManager.downloadGroupSharedFile` |
| removeGroupSharedFile | `removeGroupSharedFile` | `ChatGroupManager.removeGroupSharedFile` |
| updateGroupAnnouncement | `updateGroupAnnouncement` | `ChatGroupManager.updateGroupAnnouncement` |
| updateGroupExt | `updateGroupExt` | `ChatGroupManager.updateGroupExtension` |
| joinPublicGroup | `joinPublicGroup` | `ChatGroupManager.joinPublicGroup` |
| requestToJoinPublicGroup | `requestToJoinPublicGroup` | `ChatGroupManager.requestToJoinPublicGroup` |
| acceptJoinApplication | `acceptJoinApplication` | `ChatGroupManager.acceptJoinApplication` |
| declineJoinApplication | `declineJoinApplication` | `ChatGroupManager.declineJoinApplication` |
| acceptInvitationFromGroup | `acceptInvitationFromGroup` | `ChatGroupManager.acceptInvitation` |
| declineInvitationFromGroup | `declineInvitationFromGroup` | `ChatGroupManager.declineInvitation` |
| setMemberAttributesFromGroup | `setMemberAttributesFromGroup` | `ChatGroupManager.setMemberAttributes` |
| removeMemberAttributesFromGroup | `removeMemberAttributesFromGroup` | `ChatGroupManager.removeMemberAttributes` |
| fetchMemberAttributesFromGroup | `fetchMemberAttributesFromGroup` | `ChatGroupManager.fetchMemberAttributes` |
| fetchMembersAttributesFromGroup | `fetchMembersAttributesFromGroup` | `ChatGroupManager.fetchMembersAttributes` |
| fetchJoinedGroupCount | `fetchJoinedGroupCount` | `ChatGroupManager.fetchJoinedGroupCount` |
| onGroupChanged | `onGroupChanged` | 事件：按 `type` 分发到 `ChatGroupChangeEvent`（见第 3 节）→ `ChatGroupEventHandler` |

### 2.10 ChatPushManager（18）— channel: chat_push_manager

| 常量名 | 字符串值 | 对应公开方法 |
|---|---|---|
| **getImPushConfig** | `getImPushConfig` | **无引用**（仅 `getImPushConfigFromServer` 被使用） |
| getImPushConfigFromServer | `getImPushConfigFromServer` | `ChatPushManager.fetchPushConfigsFromServer` |
| updateImPushStyle | `updateImPushStyle` | `ChatPushManager.updatePushDisplayStyle` |
| updatePushNickname | `updatePushNickname` | `ChatPushManager.updatePushNickname` |
| updateHMSPushToken | `updateHMSPushToken` | `ChatPushManager.updateHMSPushToken`（Deprecated） |
| updateFCMPushToken | `updateFCMPushToken` | `ChatPushManager.updateFCMPushToken`（Deprecated） |
| updateAPNsPushToken | `updateAPNsPushToken` | `ChatPushManager.updateAPNsDeviceToken`（Deprecated） |
| **reportPushAction** | `reportPushAction` | **无引用** |
| setConversationSilentMode | `setConversationSilentMode` | `ChatPushManager.setConversationSilentMode` |
| removeConversationSilentMode | `removeConversationSilentMode` | `ChatPushManager.removeConversationSilentMode` |
| fetchConversationSilentMode | `fetchConversationSilentMode` | `ChatPushManager.fetchConversationSilentMode` |
| setSilentModeForAll | `setSilentModeForAll` | `ChatPushManager.setSilentModeForAll` |
| fetchSilentModeForAll | `fetchSilentModeForAll` | `ChatPushManager.fetchSilentModeForAll` |
| fetchSilentModeForConversations | `fetchSilentModeForConversations` | `ChatPushManager.fetchSilentModeForConversations` |
| setPreferredNotificationLanguage | `setPreferredNotificationLanguage` | `ChatPushManager.setPreferredNotificationLanguage` |
| fetchPreferredNotificationLanguage | `fetchPreferredNotificationLanguage` | `ChatPushManager.fetchPreferredNotificationLanguage` |
| setPushTemplate | `setPushTemplate` | `ChatPushManager.setPushTemplate` |
| getPushTemplate | `getPushTemplate` | `ChatPushManager.getPushTemplate` |

### 2.11 ChatUserInfoManager（4 方法 + 1 事件）— channel: chat_userInfo_manager

| 常量名 | 字符串值 | 对应公开方法 |
|---|---|---|
| updateOwnUserInfo | `updateOwnUserInfo` | `ChatUserInfoManager.updateUserInfo` |
| **updateOwnUserInfoWithType** | `updateOwnUserInfoWithType` | **无引用** |
| fetchUserInfoById | `fetchUserInfoById` | `ChatUserInfoManager.fetchUserInfoById`（`fetchOwnInfo` 内部也走此 key） |
| **fetchUserInfoByIdWithType** | `fetchUserInfoByIdWithType` | **无引用** |
| onUserInfoChanged | `onUserInfoChanged` | 事件：按 `type` 分发到 `ChatUserInfoChangeEvent` → `ChatUserInfoEventHandler` |

### 2.12 ChatPresenceManager（5）— channel: chat_presence_manager

| 常量名 | 字符串值 | 对应公开方法 |
|---|---|---|
| presenceWithDescription | `publishPresenceWithDescription` ⚠值与常量名不同 | `ChatPresenceManager.publishPresence` |
| presenceSubscribe | `presenceSubscribe` | `ChatPresenceManager.subscribe` |
| presenceUnsubscribe | `presenceUnsubscribe` | `ChatPresenceManager.unsubscribe` |
| fetchSubscribedMembersWithPageNum | `fetchSubscribedMembersWithPageNum` | `ChatPresenceManager.fetchSubscribedMembers` |
| fetchPresenceStatus | `fetchPresenceStatus` | `ChatPresenceManager.fetchPresenceStatus` |

### 2.13 ChatThreadManager（12 方法 + 4 事件）— channel: chat_thread_manager

| 常量名 | 字符串值 | 对应公开方法 |
|---|---|---|
| fetchChatThreadDetail | `fetchChatThreadDetail` | `ChatThreadManager.fetchChatThread` |
| fetchJoinedChatThreads | `fetchJoinedChatThreads` | `ChatThreadManager.fetchJoinedChatThreads` |
| fetchChatThreadsWithParentId | `fetchChatThreadsWithParentId` | `ChatThreadManager.fetchChatThreadsWithParentId` |
| fetchJoinedChatThreadsWithParentId | `fetchJoinedChatThreadsWithParentId` | `ChatThreadManager.fetchJoinedChatThreadsWithParentId` |
| fetchChatThreadMember | `fetchChatThreadMember` | `ChatThreadManager.fetchChatThreadMembers` |
| fetchLastMessageWithChatThreads | `fetchLastMessageWithChatThreads` | `ChatThreadManager.fetchLatestMessageWithChatThreads` |
| removeMemberFromChatThread | `removeMemberFromChatThread` | `ChatThreadManager.removeMemberFromChatThread` |
| updateChatThreadSubject | `updateChatThreadSubject` | `ChatThreadManager.updateChatThreadName` |
| createChatThread | `createChatThread` | `ChatThreadManager.createChatThread` |
| joinChatThread | `joinChatThread` | `ChatThreadManager.joinChatThread` |
| leaveChatThread | `leaveChatThread` | `ChatThreadManager.leaveChatThread` |
| destroyChatThread | `destroyChatThread` | `ChatThreadManager.destroyChatThread` |
| onChatThreadCreate | `onChatThreadCreate` | `ChatThreadEventHandler.onChatThreadCreate` |
| onChatThreadUpdate | `onChatThreadUpdate` | `ChatThreadEventHandler.onChatThreadUpdate` |
| onChatThreadDestroy | `onChatThreadDestroy` | `ChatThreadEventHandler.onChatThreadDestroy` |
| onUserKickOutOfChatThread | `onUserKickOutOfChatThread` | `ChatThreadEventHandler.onUserKickOutOfChatThread` |

### 2.14 其余（按源文件版本注释分组）

| 常量名 | 字符串值 | 对应公开方法 |
|---|---|---|
| startCallback（HandleAction） | `startCallback` | `ChatClient.startCallback` |
| getPinInfo（450） | `getPinInfo` | `ChatMessage.pinInfo` |
| pinnedMessages（450） | `pinnedMessages` | `ChatConversation.loadPinnedMessages` |
| onMessagePinChanged（450） | `onMessagePinChanged` | 事件 → `ChatEventHandler.onMessagePinChanged` |
| addRemoteAndLocalConversationsMark（450） | `addRemoteAndLocalConversationsMark` | `ChatManager.addRemoteAndLocalConversationsMark` |
| deleteRemoteAndLocalConversationsMark（450） | `deleteRemoteAndLocalConversationsMark` | `ChatManager.deleteRemoteAndLocalConversationsMark` |
| fetchConversationsByOptions（450） | `fetchConversationsByOptions` | `ChatManager.fetchConversationsByOptions` |
| deleteAllMessageAndConversation（450） | `deleteAllMessageAndConversation` | `ChatManager.deleteAllMessageAndConversation` |
| pinMessage（450） | `pinMessage` | `ChatManager.pinMessage` |
| unpinMessage（450） | `unpinMessage` | `ChatManager.unpinMessage` |
| fetchPinnedMessages（450） | `fetchPinnedMessages` | `ChatManager.fetchPinnedMessages` |
| onMessagesRecalledInfo（460） | `onMessagesRecalledInfo` | 事件 → `ChatEventHandler.onMessagesRecalledInfo` |
| conversationRemindType（481） | `conversationRemindType` | `ChatConversation.remindType` |
| conversationSearchMsgsByOptions（481） | `conversationSearchMsgsByOptions` | `ChatConversation.searchMsgsByOptions` |
| conversationGetLocalMessageCount（481） | `conversationGetLocalMessageCount` | `ChatConversation.getLocalMessageCount`（`deleteLocalAndServerMessages`/`deleteLocalAndServerMessagesByTime` 也用此 key 读取返回值，见异常） |
| conversationDeleteServerMessageWithIds（481） | `conversationDeleteServerMessageWithIds` | `ChatConversation.deleteLocalAndServerMessages` |
| conversationDeleteServerMessageWithTime（481） | `conversationDeleteServerMessageWithTime` | `ChatConversation.deleteLocalAndServerMessagesByTime` |
| searchMsgsByOptions（481） | `searchMsgsByOptions` | `ChatManager.searchMsgsByOptions` |
| syncSilentModels（481） | `syncSilentModels` | `ChatPushManager.syncConversationsSilentMode` |
| clearAllGroupsFromDB（481） | `clearAllGroupsFromDB` | `ChatGroupManager.clearAllGroupsFromLocal` |
| updateUsingHttpsOnlySetting（481） | `updateUsingHttpsOnlySetting` | `ChatClient.updateUsingHttpsOnlySetting` |
| updateLoginExtensionInfo（481） | `updateLoginExtensionInfo` | `ChatClient.updateLoginExtensionInfoSetting` |
| updateDeleteMessagesWhenLeaveGroupSetting（481） | `updateDeleteMessagesWhenLeaveGroupSetting` | `ChatClient.updateDeleteMessagesWhenLeaveGroupSetting` |
| updateDeleteMessageWhenLeaveRoomSetting（481） | `updateDeleteMessageWhenLeaveRoomSetting` | `ChatClient.updateDeleteMessageWhenLeaveRoomSetting` |
| updateRoomOwnerCanLeaveSetting（481） | `updateRoomOwnerCanLeaveSetting` | `ChatClient.updateRoomOwnerCanLeaveSetting` |
| updateAutoAcceptGroupInvitationSetting（481） | `updateAutoAcceptGroupInvitationSetting` | `ChatClient.updateAutoAcceptGroupInvitationSetting` |
| updateAcceptInvitationAlways（481） | `acceptInvitationAlways` ⚠值与常量名不同 | `ChatClient.updateAutoAcceptFriendInvitationSetting` |
| updateAutoDownloadAttachmentThumbnailSetting（481） | `updateAutoDownloadAttachmentThumbnailSetting` | `ChatClient.updateAutoDownloadAttachmentThumbnailSetting` |
| updateRequireAckSetting（481） | `updateRequireAckSetting` | `ChatClient.updateRequireAckSetting` |
| updateDeliveryAckSetting（481） | `updateDeliveryAckSetting` | `ChatClient.updateDeliveryAckSetting` |
| updateSortMessageByServerTimeSetting（481） | `updateSortMessageByServerTimeSetting` | `ChatClient.updateSortMessageByServerTimeSetting` |
| updateMessagesReceiveCallbackIncludeSendSetting（481） | `updateMessagesReceiveCallbackIncludeSendSetting` | `ChatClient.updateMessagesReceiveCallbackIncludeSendSetting` |
| updateRegradeMessagesSetting（481） | `updateRegradeMessagesSetting` | `ChatClient.updateRegradeMessagesAsReadSetting` |
| bindDeviceToken（481） | `bindDeviceToken` | `ChatPushManager.bindDeviceToken` |
| bindPushKitToken（4.25.0） | `bindPushKitToken` | `ChatPushManager.bindPushKitToken` |
| unbindPushKitToken（4.25.0） | `unbindPushKitToken` | `ChatPushManager.unbindPushKitToken` |
| onOfflineMessageSyncStart（4.10） | `onOfflineMessageSyncStart` | 事件 → `ConnectionEventHandler.onOfflineMessageSyncStart`（channel: chat_client） |
| onOfflineMessageSyncFinish（4.10） | `onOfflineMessageSyncFinish` | 事件 → `ConnectionEventHandler.onOfflineMessageSyncFinish` |
| getMessageCount（4.10） | `getMessageCount` | `ChatManager.getAllMessageCount` |
| isMemberInGroupMuteList（4.10） | `isMemberInGroupMuteList` | `ChatGroupManager.isMemberInGroupMuteList` |
| changeAppId（shenwang） | `changeAppId` | `ChatClient.changeAppId` |
| isMemberInChatRoomMuteList（4.12.1） | `isMemberInChatRoomMuteList` | `ChatRoomManager.isMemberInChatRoomMuteList` |
| fetchGroupMembersInfo（4.14.0） | `fetchGroupMembersInfo` | `ChatGroupManager.fetchGroupMembersInfo` |
| updateGroupAvatar（4.14.0） | `updateGroupAvatar` | `ChatGroupManager.updateGroupAvatar` |
| loadConversationMessagesWithKeyword（4.15.2） | `loadConversationMessagesWithKeyword` | `ChatManager.loadConversationMessagesWithKeyword` |
| loadMessagesWithIds（4.15.2） | `loadMessagesWithIds` | `ChatManager.loadMessagesWithIds` |
| downloadBigImage（4.22.0） | `downloadBigImage` | `ChatManager.downloadBigImage` |
| voiceMessageToText（4.22.0） | `voiceMessageToText` | `ChatManager.voiceMessageToText` |
| voiceFileToText（4.22.0） | `voiceFileToText` | `ChatManager.voiceFileToText` |
| updateGroupNamecard（4.22.0） | `updateGroupNamecard` | `ChatGroupManager.updateGroupNamecard` |
| getGroupNamecard（4.22.0） | `getGroupNamecard` | `ChatGroupManager.getGroupNamecard` |
| subscribeUsersInfo（4.22.0） | `subscribeUsersInfo` | `ChatUserInfoManager.subscribeUsersInfo` |
| unsubscribeUsersInfo（4.22.0） | `unsubscribeUsersInfo` | `ChatUserInfoManager.unsubscribeUsersInfo` |
| fetchSubscribedUsers（4.22.0） | `fetchSubscribedUsers` | `ChatUserInfoManager.fetchSubscribedUsers` |
| getLocalUserInfoByIds（4.22.0） | `getLocalUserInfoByIds` | `ChatUserInfoManager.getLocalUserInfoByIds` |
| searchMessagesFromServer（4.24.0） | `searchMessagesFromServer` | `ChatManager.searchMessagesFromServer` |

## 3. 事件常量（`chat_event_keys.dart`，52 个）

这些常量是 channel 事件（如 `onContactChanged`/`onChatRoomChanged`/`onGroupChanged`/`onUserInfoChanged`）参数 Map 中 `type` 字段的取值，Dart 侧据此二次分发到具体回调。

### ChatContactChangeEvent（8）— 经 `onContactChanged` 分发

| 常量名 | 字符串值 |
|---|---|
| CONTACT_ADD | `onContactAdded` |
| CONTACT_DELETE | `onContactDeleted` |
| INVITED | `onContactInvited` |
| INVITATION_ACCEPTED | `onFriendRequestAccepted` |
| INVITATION_DECLINED | `onFriendRequestDeclined` |
| CONTACT_SYNC_START（4.22.0） | `onContactSyncStart` |
| CONTACT_SYNC_FINISH（4.22.0） | `onContactSyncFinish` |
| CONTACT_INFO_UPDATE（4.22.0） | `onContactInfoUpdate` |

### ChatRoomEvent（16）— 经 `onChatRoomChanged` 分发

| 常量名 | 字符串值 |
|---|---|
| ON_CHAT_ROOM_DESTROYED | `onRoomDestroyed` |
| ON_MEMBER_JOINED | `onRoomMemberJoined` |
| ON_MEMBER_EXITED | `onRoomMemberExited` |
| ON_REMOVED_FROM_CHAT_ROOM | `onRoomRemoved` |
| ON_MUTE_LIST_ADDED | `onRoomMuteListAdded` |
| ON_MUTE_LIST_REMOVED | `onRoomMuteListRemoved` |
| ON_ADMIN_ADDED | `onRoomAdminAdded` |
| ON_ADMIN_REMOVED | `onRoomAdminRemoved` |
| ON_OWNER_CHANGED | `onRoomOwnerChanged` |
| ON_ANNOUNCEMENT_CHANGED | `onRoomAnnouncementChanged` |
| ON_WHITE_LIST_REMOVED | `onRoomWhiteListRemoved` |
| ON_WHITE_LIST_ADDED | `onRoomWhiteListAdded` |
| ON_ALL_MEMBER_MUTE_STATE_CHANGED | `onRoomAllMemberMuteStateChanged` |
| ON_SPECIFICATION_CHANGED | `onRoomSpecificationChanged` |
| ON_ATTRIBUTES_UPDATED | `onRoomAttributesDidUpdated` |
| ON_ATTRIBUTES_REMOVED | `onRoomAttributesDidRemoved` |

### ChatGroupChangeEvent（26）— 经 `onGroupChanged` 分发

| 常量名 | 字符串值 |
|---|---|
| ON_INVITATION_RECEIVED | `onGroupInvitationReceived` |
| ON_INVITATION_ACCEPTED | `onGroupInvitationAccepted` |
| ON_INVITATION_DECLINED | `onGroupInvitationDeclined` |
| ON_AUTO_ACCEPT_INVITATION | `onGroupAutoAcceptInvitation` |
| ON_USER_REMOVED | `onGroupUserRemoved` |
| ON_REQUEST_TO_JOIN_RECEIVED | `onGroupRequestToJoinReceived` |
| ON_REQUEST_TO_JOIN_DECLINED | `onGroupRequestToJoinDeclined` |
| ON_REQUEST_TO_JOIN_ACCEPTED | `onGroupRequestToJoinAccepted` |
| ON_GROUP_DESTROYED | `onGroupDestroyed` |
| ON_MUTE_LIST_ADDED | `onGroupMuteListAdded` |
| ON_MUTE_LIST_REMOVED | `onGroupMuteListRemoved` |
| ON_ADMIN_ADDED | `onGroupAdminAdded` |
| ON_ADMIN_REMOVED | `onGroupAdminRemoved` |
| ON_OWNER_CHANGED | `onGroupOwnerChanged` |
| ON_MEMBER_JOINED | `onGroupMemberJoined` |
| ON_MEMBER_EXITED | `onGroupMemberExited` |
| ON_ANNOUNCEMENT_CHANGED | `onGroupAnnouncementChanged` |
| ON_SHARED_FILE_ADDED | `onGroupSharedFileAdded` |
| ON_SHARED_FILE__DELETED | `onGroupSharedFileDeleted` ⚠常量名有双下划线 |
| ON_WHITE_LIST_REMOVED | `onGroupWhiteListRemoved` |
| ON_WHITE_LIST_ADDED | `onGroupWhiteListAdded` |
| ON_ALL_MEMBER_MUTE_STATE_CHANGED | `onGroupAllMemberMuteStateChanged` |
| ON_SPECIFICATION_DID_UPDATE | `onGroupSpecificationDidUpdate` |
| ON_STATE_CHANGED | `onGroupStateChanged` |
| ON_ATTRIBUTES_CHANGED_OF_MEMBER | `onGroupAttributesChangedOfMember` |
| ON_USER_GROUP_NAMECARD_CHANGED（4.22.0） | `onUserGroupNamecardChanged` |

### ChatUserInfoChangeEvent（2，4.22.0）— 经 `onUserInfoChanged` 分发

| 常量名 | 字符串值 |
|---|---|
| ON_SELF_USER_INFO_UPDATE | `onSelfUserInfoUpdate` |
| ON_USER_INFO_UPDATE | `onUserInfoUpdate` |

## 4. 各 Manager 公开方法签名

以下签名从源码提取（省略 `async`，标注 `[Deprecated]`）。每个 Manager 均有统一的事件处理器管理方法：`addEventHandler(String identifier, XxxEventHandler handler)`、`removeEventHandler(String identifier)`、`getEventHandler(String identifier)`、`clearEventHandlers()`（ChatClient 例外，见下）。

### 4.1 ChatClient（`lib/src/managers/chat_client.dart`）

属性：`static ChatClient get getInstance`；`chatManager` / `contactManager` / `chatRoomManager` / `groupManager` / `pushManager` / `presenceManager` / `userInfoManager` / `chatThreadManager`（8 个 Manager getter）；`String? get currentUserId`；`ChatOptions? get options`；`void Function(Map map)? customEventHandler`。

事件处理器管理（两组，无统一 addEventHandler）：
- `void addConnectionEventHandler(String identifier, ConnectionEventHandler handler)` / `removeConnectionEventHandler(String identifier)` / `ConnectionEventHandler? getConnectionEventHandler(String identifier)` / `clearConnectionEventHandlers()`
- `void addMultiDeviceEventHandler(String identifier, ChatMultiDeviceEventHandler handler)` / `removeMultiDeviceEventHandler(String identifier)` / `ChatMultiDeviceEventHandler? getMultiDeviceEventHandler(String identifier)` / `clearMultiDeviceEventHandlers()`

方法：

```dart
Future<void> init(ChatOptions options)
Future<void> createAccount(String userId, String password)
Future<void> login(String userId, String pwdOrToken, [bool isPassword = true])          // [Deprecated]
Future<void> loginWithAgoraToken(String userId, String agoraToken)                     // [Deprecated]
Future<void> loginWithToken(String userId, String token)
Future<void> loginWithPassword(String userId, String password)
Future<void> renewAgoraToken(String agoraToken)
Future<void> logout([bool unbindDeviceToken = true])
Future<bool> changeAppKey({required String newAppKey})
Future<bool> changeAppId({required String newAppId})
Future<bool> isConnected()
Future<bool> isLoginBefore()
Future<String?> getCurrentUserId()
Future<String> getAccessToken()
Future<String> getCurrentDeviceId()
Future<void> startCallback()
Future<String> compressLogs()
Future<List<ChatDeviceInfo>> getLoggedInDevicesFromServer({required String userId, required String password})  // [Deprecated]
Future<List<ChatDeviceInfo>> fetchLoggedInDevices({required String userId, required String pwdOrToken, bool isPwd = true})
Future<void> kickDevice({required String userId, required String pwdOrToken, required String resource, bool isPwd = true})
Future<void> kickAllDevices({required String userId, required String pwdOrToken, bool isPwd = true})
Future<void> updateUsingHttpsOnlySetting(bool usingHttpsOnly)
Future<void> updateLoginExtensionInfoSetting(String extension)
Future<void> updateDeleteMessagesWhenLeaveGroupSetting(bool deleteMessagesWhenLeaveGroup)
Future<void> updateDeleteMessageWhenLeaveRoomSetting(bool deleteMessageWhenLeaveRoom)
Future<void> updateRoomOwnerCanLeaveSetting(bool roomOwnerCanLeave)
Future<void> updateAutoAcceptGroupInvitationSetting(bool autoAcceptGroupInvitation)
Future<void> updateAutoAcceptFriendInvitationSetting(bool acceptInvitationAlways)
Future<void> updateAutoDownloadAttachmentThumbnailSetting(bool autoDownloadThumbnail)
Future<void> updateRequireAckSetting(bool requireAck)
Future<void> updateDeliveryAckSetting(bool requireDeliveryAck)
Future<void> updateSortMessageByServerTimeSetting(bool sortMessageByServerTime)
Future<void> updateMessagesReceiveCallbackIncludeSendSetting(bool includeSend)
Future<void> updateRegradeMessagesAsReadSetting(bool isRead)
```

### 4.2 ChatContactManager（`lib/src/managers/chat_contact_manager.dart`）

```dart
Future<void> addContact(String userId, {String? reason})
Future<void> deleteContact(String userId, {bool keepConversation = false})
Future<List<String>> getAllContactsFromServer()                 // [Deprecated] → fetchAllContactIds
Future<List<String>> fetchAllContactIds()
Future<List<String>> getAllContactsFromDB()                     // [Deprecated] → getAllContactIds
Future<List<String>> getAllContactIds()
Future<void> addUserToBlockList(String userId)
Future<void> removeUserFromBlockList(String userId)
Future<List<String>> getBlockListFromServer()                   // [Deprecated] → fetchBlockIds
Future<List<String>> fetchBlockIds()
Future<List<String>> getBlockListFromDB()                       // [Deprecated] → getBlockIds
Future<List<String>> getBlockIds()
Future<void> acceptInvitation(String userId)
Future<void> declineInvitation(String userId)
Future<List<String>> getSelfIdsOnOtherPlatform()
Future<List<ChatContact>> getAllContacts()
Future<void> setContactRemark({required String userId, required String remark})
Future<ChatContact?> getContact({required String userId})
Future<List<ChatContact>> fetchAllContacts()
Future<ChatCursorResult<ChatContact>> fetchContacts({String? cursor, int pageSize = 20})
```

### 4.3 ChatManager（`lib/src/managers/chat_manager.dart`）

另有消息事件管理：`addMessageEvent(String identifier, ChatMessageEvent event)` / `removeMessageEvent(String identifier)` / `clearMessageEvent()`（文件尾部 `MessageCallBackManager` 单例：`addMessageEvent(String key, ...)` / `removeMessageEvent(String key)` / `clearAllMessageEvents()`）。

```dart
Future<ChatMessage> sendMessage(ChatMessage message)
Future<ChatMessage> resendMessage(ChatMessage message)
Future<void> sendMessageReadAck(ChatMessage message)
Future<void> sendGroupMessageReadAck(String msgId, String groupId, {String? content})
Future<void> sendConversationReadAck(String conversationId)
Future<void> recallMessage(String messageId, {String? ext})
Future<ChatMessage?> loadMessage(String messageId)
Future<List<ChatMessage>> loadMessagesWithIds(List<String> messageIds, String conversationId)
Future<ChatConversation?> getConversation(String conversationId, {ChatConversationType type = ChatConversationType.Chat, bool createIfNeed = true})
Future<ChatConversation?> getThreadConversation(String threadId)
Future<void> markAllConversationsAsRead()
Future<int> getUnreadMessageCount()
Future<void> updateMessage(ChatMessage message)
Future<void> importMessages(List<ChatMessage> messages)
Future<void> downloadAttachment(ChatMessage message)
Future<void> downloadThumbnail(ChatMessage message)
Future<void> downloadMessageAttachmentInCombine(ChatMessage message)
Future<void> downloadMessageThumbnailInCombine(ChatMessage message)
Future<List<ChatConversation>> loadAllConversations()
Future<List<ChatConversation>> getConversationsFromServer()                            // [Deprecated]
Future<List<ChatConversation>> fetchConversationListFromServer({int pageNum = 1, int pageSize = 20})  // [Deprecated]
Future<ChatCursorResult<ChatConversation>> fetchConversation({String? cursor, int pageSize = 20})     // [Deprecated]
Future<void> deleteRemoteMessagesWithIds({required String conversationId, required ChatConversationType type, required List<String> msgIds})
Future<void> deleteRemoteMessagesBefore({required String conversationId, required ChatConversationType type, required int timestamp})
Future<bool> deleteConversation(String conversationId, {bool deleteMessages = true})
Future<ChatCursorResult<ChatMessage>> fetchHistoryMessages({required String conversationId, ChatConversationType type = ChatConversationType.Chat, int pageSize = 20, ChatSearchDirection direction = ChatSearchDirection.Up, String startMsgId = ''})  // [Deprecated]
Future<ChatCursorResult<ChatMessage>> fetchHistoryMessagesByOption(String conversationId, ChatConversationType type, {FetchMessageOptions? options, String? cursor, int pageSize = 50})
Future<List<ChatMessage>> loadMessagesWithKeyword(String keywords, {String? sender, int timestamp = -1, int count = 20, MessageSearchScope searchScope = MessageSearchScope.All, ChatSearchDirection direction = ChatSearchDirection.Up})
Future<List<ChatMessage>> searchMsgFromDB(String keywords, {int timestamp = -1, int maxCount = 20, String from = '', ChatSearchDirection direction = ChatSearchDirection.Up})  // [Deprecated]
Future<ChatCursorResult<ChatGroupMessageAck>> fetchGroupAcks(String msgId, String groupId, {String? startAckId, int pageSize = 0})
Future<void> deleteRemoteConversation(String conversationId, {ChatConversationType conversationType = ChatConversationType.Chat, bool isDeleteMessage = true})
Future<void> deleteMessagesBefore(int timestamp)
Future<void> reportMessage({required String messageId, required String tag, required String reason})
Future<void> addReaction({required String messageId, required String reaction})
Future<void> removeReaction({required String messageId, required String reaction})
Future<Map<String, List<ChatMessageReaction>>> fetchReactionList({required List<String> messageIds, required ChatType chatType, String? groupId})
Future<ChatCursorResult<ChatMessageReaction>> fetchReactionDetail({required String messageId, required String reaction, String? cursor, int pageSize = 20})
Future<ChatMessage> translateMessage({required ChatMessage msg, required List<String> languages})
Future<List<ChatTranslateLanguage>> fetchSupportedLanguages()
Future<ChatCursorResult<ChatConversation>> fetchPinnedConversations({String? cursor, int pageSize = 20})  // [Deprecated]
Future<ChatCursorResult<ChatConversation>> fetchConversationsFromDB({String? cursor, int pageSize = 20})
Future<void> pinConversation({required String conversationId, required bool isPinned})
Future<ChatMessage> modifyMessage({required String messageId, ChatMessageBody? msgBody, Map<String, dynamic>? attributes})
Future<List<ChatMessage>> fetchCombineMessageDetail({required ChatMessage message})
Future<void> addRemoteAndLocalConversationsMark({required List<String> conversationIds, required ConversationMarkType mark})
Future<void> deleteRemoteAndLocalConversationsMark({required List<String> conversationIds, required ConversationMarkType mark})
Future<ChatCursorResult<ChatConversation>> fetchConversationsByOptions({required ConversationFetchOptions options})
Future<void> deleteAllMessageAndConversation({bool clearServerData = false})
Future<void> pinMessage({required String messageId})
Future<void> unpinMessage({required String messageId})
Future<List<ChatMessage>> fetchPinnedMessages({required String conversationId})
Future<List<ChatMessage>> searchMsgsByOptions(MessageSearchOptions options)
Future<int> getAllMessageCount()
Future<Map<String, List<String>>> loadConversationMessagesWithKeyword({String? keyword, int timestamp = -1, String? sender, ChatSearchDirection direction = ChatSearchDirection.Up, MessageSearchScope scope = MessageSearchScope.All})
Future<void> downloadBigImage(ChatMessage message)
Future<String> voiceMessageToText(ChatMessage message)
Future<String> voiceFileToText(String filePath, {ChatVoiceParam? voiceParam})
Future<ChatPageResult<ChatSearchServerMessageResult>> searchMessagesFromServer({required ChatMessageSearchOption option, int pageSize = 20, int pageNum = 1})
```

### 4.4 ChatGroupManager（`lib/src/managers/chat_group_manager.dart`）

```dart
Future<ChatGroup?> getGroupWithId(String groupId)
Future<List<ChatGroup>> getJoinedGroups()
Future<List<ChatGroup>> fetchJoinedGroupsFromServer({int pageSize = 20, int pageNum = 0, bool needMemberCount = false, bool needRole = false})
Future<ChatCursorResult<ChatGroupInfo>> fetchPublicGroupsFromServer({int pageSize = 200, String? cursor})
Future<ChatGroup> createGroup({String? groupName, String? avatarUrl, String? desc, List<String>? inviteMembers, String? inviteReason, required ChatGroupOptions options})
Future<ChatGroup> fetchGroupInfoFromServer(String groupId, {@Deprecated('') bool? fetchMembers})
Future<ChatCursorResult<String>> fetchMemberListFromServer(String groupId, {int pageSize = 200, String? cursor})
Future<List<String>> fetchBlockListFromServer(String groupId, {int pageSize = 200, int pageNum = 1})
Future<Map<String, int>> fetchMuteListFromServer(String groupId, {int pageSize = 200, int pageNum = 1})
Future<List<String>> fetchAllowListFromServer(String groupId)
Future<bool> isMemberInAllowListFromServer(String groupId)
Future<List<ChatGroupSharedFile>> fetchGroupFileListFromServer(String groupId, {int pageSize = 200, int pageNum = 1})
Future<String?> fetchAnnouncementFromServer(String groupId)
Future<void> addMembers(String groupId, List<String> members, {String? welcome})
Future<void> inviterUser(String groupId, List<String> members, {String? reason})
Future<void> removeMembers(String groupId, List<String> members)
Future<void> blockMembers(String groupId, List<String> members)
Future<void> unblockMembers(String groupId, List<String> members)
Future<void> changeGroupName(String groupId, String name)        // [Deprecated] → updateGroupName
Future<void> updateGroupName(String groupId, String name)
Future<void> changeGroupDescription(String groupId, String desc) // [Deprecated] → updateGroupDesc
Future<void> updateGroupDesc(String groupId, String desc)
Future<void> leaveGroup(String groupId)
Future<void> destroyGroup(String groupId)
Future<void> blockGroup(String groupId)
Future<void> unblockGroup(String groupId)
Future<void> changeOwner(String groupId, String newOwner)
Future<void> addAdmin(String groupId, String memberId)
Future<void> removeAdmin(String groupId, String adminId)
Future<void> muteMembers(String groupId, List<String> members, {int duration = -1})
Future<void> unMuteMembers(String groupId, List<String> members)
Future<void> muteAllMembers(String groupId)
Future<void> unMuteAllMembers(String groupId)
Future<void> addAllowList(String groupId, List<String> members)
Future<void> removeAllowList(String groupId, List<String> members)
Future<void> uploadGroupSharedFile(String groupId, String filePath)
Future<void> downloadGroupSharedFile({required String groupId, required String fileId, required String savePath})
Future<void> removeGroupSharedFile(String groupId, String fileId)
Future<void> updateGroupAnnouncement(String groupId, String announcement)
Future<void> updateGroupExtension(String groupId, String extension)
Future<void> joinPublicGroup(String groupId)
Future<void> requestToJoinPublicGroup(String groupId, {String? reason})
Future<void> acceptJoinApplication(String groupId, String username)
Future<void> declineJoinApplication(String groupId, String username, {String? reason})
Future<ChatGroup> acceptInvitation(String groupId, String inviter)
Future<void> declineInvitation({required String groupId, required String inviter, String? reason})
Future<void> setMemberAttributes({required String groupId, required Map<String, String> attributes, String? userId})
Future<void> removeMemberAttributes({required String groupId, required List<String> keys, String? userId})
Future<Map<String, String>> fetchMemberAttributes({required String groupId, String? userId})
Future<Map<String, Map<String, String>>> fetchMembersAttributes({required String groupId, required List<String> userIds, List<String>? keys})
Future<int> fetchJoinedGroupCount()
Future<bool> isMemberInGroupMuteList(String groupId)
Future<void> clearAllGroupsFromLocal()
Future<ChatCursorResult<GroupMemberInfo>> fetchGroupMembersInfo({required String groupId, String? cursor, int limit = 20})
Future<ChatGroup> updateGroupAvatar({required String groupId, required String avatarUrl})
Future<void> updateGroupNamecard({required String groupId, String? namecard})
Future<String?> getGroupNamecard({required String groupId, required String userId})
```

### 4.5 ChatRoomManager（`lib/src/managers/chat_room_manager.dart`）

```dart
Future<void> joinChatRoom(String roomId, {bool leaveOtherRooms = false, String? ext})
Future<void> leaveChatRoom(String roomId)
Future<ChatPageResult<ChatRoom>> fetchPublicChatRoomsFromServer({int pageNum = 1, int pageSize = 200})
Future<ChatRoom> fetchChatRoomInfoFromServer(String roomId, {@Deprecated('') bool? fetchMembers})
Future<ChatRoom?> getChatRoomWithId(String roomId)
Future<ChatRoom> createChatRoom(String name, {String? desc, String? welcomeMsg, int maxUserCount = 300, List<String>? members})
Future<void> destroyChatRoom(String roomId)
Future<void> changeChatRoomName(String roomId, String name)
Future<void> changeChatRoomDescription(String roomId, String description)
Future<ChatCursorResult<String>> fetchChatRoomMembers(String roomId, {String? cursor, int pageSize = 200})
Future<void> muteChatRoomMembers(String roomId, List<String> muteMembers, {int duration = -1})
Future<void> unMuteChatRoomMembers(String roomId, List<String> unMuteMembers)
Future<void> changeOwner(String roomId, String newOwner)
Future<void> addChatRoomAdmin(String roomId, String admin)
Future<void> removeChatRoomAdmin(String roomId, String admin)
Future<List<String>> fetchChatRoomMuteList(String roomId, {int pageNum = 1, int pageSize = 200})
Future<void> removeChatRoomMembers(String roomId, List<String> members)
Future<void> blockChatRoomMembers(String roomId, List<String> members)
Future<void> unBlockChatRoomMembers(String roomId, List<String> members)
Future<List<String>> fetchChatRoomBlockList(String roomId, {int pageNum = 1, int pageSize = 200})
Future<void> updateChatRoomAnnouncement(String roomId, String announcement)
Future<String?> fetchChatRoomAnnouncement(String roomId)
Future<List<String>> fetchChatRoomAllowListFromServer(String roomId)
Future<bool> isMemberInChatRoomAllowList(String roomId)
Future<void> addMembersToChatRoomAllowList(String roomId, List<String> members)
Future<void> removeMembersFromChatRoomAllowList(String roomId, List<String> members)
Future<void> muteAllChatRoomMembers(String roomId)
Future<void> unMuteAllChatRoomMembers(String roomId)
Future<Map<String, String>?> fetchChatRoomAttributes({required String roomId, List<String>? keys})
Future<Map<String, int>?> addAttributes(String roomId, {required Map<String, String> attributes, bool deleteWhenLeft = false, bool overwrite = false})
Future<Map<String, int>?> removeAttributes(String roomId, {required List<String> keys, bool force = false})
Future<bool> isMemberInChatRoomMuteList(String roomId)
```

### 4.6 ChatPushManager（`lib/src/managers/chat_push_manager.dart`）

注：本 Manager 无 `addEventHandler`（无事件）。

```dart
Future<ChatPushConfigs> fetchPushConfigsFromServer()
Future<void> updatePushNickname(String nickname)
Future<void> updatePushDisplayStyle(DisplayStyle displayStyle)
Future<void> updateHMSPushToken(String token)        // [Deprecated] → bindDeviceToken
Future<void> updateFCMPushToken(String token)        // [Deprecated] → bindDeviceToken
Future<void> updateAPNsDeviceToken(String token)     // [Deprecated] → bindDeviceToken
Future<void> bindDeviceToken({required String notifierName, required String deviceToken})
Future<void> bindPushKitToken({required String deviceToken})
Future<void> unbindPushKitToken()
Future<void> setConversationSilentMode({required String conversationId, required ChatConversationType type, required ChatSilentModeParam param})
Future<void> removeConversationSilentMode({required String conversationId, required ChatConversationType type})
Future<ChatSilentModeResult> fetchConversationSilentMode({required String conversationId, required ChatConversationType type})
Future<void> setSilentModeForAll({required ChatSilentModeParam param})
Future<ChatSilentModeResult> fetchSilentModeForAll()
Future<Map<String, ChatSilentModeResult>> fetchSilentModeForConversations(List<ChatConversation> conversations)
Future<void> setPreferredNotificationLanguage(String languageCode)
Future<String?> fetchPreferredNotificationLanguage()
Future<void> setPushTemplate(String pushTemplateName)
Future<String?> getPushTemplate()
Future<void> syncConversationsSilentMode()
```

### 4.7 ChatPresenceManager（`lib/src/managers/chat_presence_manager.dart`）

```dart
Future<void> publishPresence(String description)
Future<List<ChatPresence>> subscribe({required List<String> members, required int expiry})
Future<void> unsubscribe({required List<String> members})
Future<List<String>> fetchSubscribedMembers({int pageNum = 1, int pageSize = 20})
Future<List<ChatPresence>> fetchPresenceStatus({required List<String> members})
```

### 4.8 ChatThreadManager（`lib/src/managers/chat_thread_manager.dart`）

```dart
Future<ChatThread?> fetchChatThread({required String chatThreadId})
Future<ChatCursorResult<ChatThread>> fetchJoinedChatThreads({String? cursor, int limit = 20})
Future<ChatCursorResult<ChatThread>> fetchChatThreadsWithParentId({required String parentId, String? cursor, int limit = 20})
Future<ChatCursorResult<ChatThread>> fetchJoinedChatThreadsWithParentId({required String parentId, String? cursor, int limit = 20})
Future<ChatCursorResult<String>> fetchChatThreadMembers({required String chatThreadId, String? cursor, int limit = 20})
Future<Map<String, ChatMessage>> fetchLatestMessageWithChatThreads({required List<String> chatThreadIds})
Future<void> removeMemberFromChatThread({required String memberId, required String chatThreadId})
Future<void> updateChatThreadName({required String chatThreadId, required String newName})
Future<ChatThread> createChatThread({required String name, required String messageId, required String parentId})
Future<ChatThread> joinChatThread({required String chatThreadId})
Future<void> leaveChatThread({required String chatThreadId})
Future<void> destroyChatThread({required String chatThreadId})
```

### 4.9 ChatUserInfoManager（`lib/src/managers/chat_user_info_manager.dart`）

```dart
Future<ChatUserInfo> updateUserInfo({String? nickname, String? avatarUrl, String? mail, String? phone, int? gender, String? sign, String? birth, String? ext})
Future<ChatUserInfo?> fetchOwnInfo({int expireTime = 0})   // 内部调用 fetchUserInfoById([currentUser])
Future<Map<String, ChatUserInfo>> fetchUserInfoById(List<String> userIds, {int expireTime = 0})
void clearUserInfoCache()
Future<void> subscribeUsersInfo(List<String> userIds)
Future<void> unsubscribeUsersInfo(List<String> userIds)
Future<List<ChatUserInfo>> fetchSubscribedUsers()
Future<Map<String, ChatUserInfo>> getLocalUserInfoByIds(List<String> userIds)
```

### 4.10 ChatConversation 实例方法（`lib/src/models/chat_conversation.dart`，channel: chat_conversation）

```dart
Future<void> setExt(Map<String, String>? ext)
Future<ChatMessage?> latestMessage()
Future<ChatMessage?> lastReceivedMessage()
Future<int> unreadCount()
Future<void> markMessageAsRead(String messageId)
Future<void> markAllMessagesAsRead()
Future<void> insertMessage(ChatMessage message)
Future<void> appendMessage(ChatMessage message)
Future<void> updateMessage(ChatMessage message)
Future<void> deleteMessage(String messageId)
Future<void> deleteAllMessages()
Future<void> deleteMessagesWithTs(int startTs, int endTs)
Future<ChatMessage?> loadMessage(String messageId)
Future<List<ChatMessage>> loadMessagesWithMsgType({required MessageType type, int timestamp = -1, int count = 20, String? sender, ChatSearchDirection direction = ChatSearchDirection.Up})
Future<List<ChatMessage>> loadMessages({String startMsgId = '', int loadCount = 20, ChatSearchDirection direction = ChatSearchDirection.Up})
Future<List<ChatMessage>> loadMessagesWithKeyword(String keywords, {String? sender /*Deprecated*/, List<String>? senders, int timestamp = -1, int count = 20, MessageSearchScope searchScope = MessageSearchScope.All, ChatSearchDirection direction = ChatSearchDirection.Up})
Future<List<ChatMessage>> loadMessagesFromTime({required int startTime, required int endTime, int count = 20})
Future<int> messagesCount()
Future<void> deleteMessageByIds(List<String> messageIds)
Future<List<ChatMessage>> loadPinnedMessages()
Future<ChatPushRemindType> remindType()
Future<List<ChatMessage>> searchMsgsByOptions(MessageSearchOptions options)
Future<int> getLocalMessageCount({required int startMs, required int endMs})
Future<void> deleteLocalAndServerMessages({required List<String> msgIds})
Future<void> deleteLocalAndServerMessagesByTime({required int beforeMs})
```

### 4.11 ChatMessage 实例方法（`lib/src/models/chat_message.dart`，channel: chat_message）

```dart
Future<MessagePinInfo?> pinInfo()
Future<List<ChatMessageReaction>> reactionList()
Future<int> groupAckCount()
Future<ChatThread?> chatThread()
set chatroomMessagePriority(ChatRoomMessagePriority priority)   // 仅本地赋值，不走 channel
```

另有大量静态工厂方法（`ChatMessage.createSendMessage` / `createReceiveMessage`（通用），及 `createTxtSendMessage`、`createVoiceSendMessage`、`createImageSendMessage`、`createVideoSendMessage`、`createFileSendMessage`、`createLocationSendMessage`、`createCmdSendMessage`、`createCustomSendMessage`、`createCombineSendMessage`）——纯 Dart 构造，不走 channel，移植时需在 ArkTS 侧提供等价构造。

## 5. Model 清单（`lib/src/models/`，40 个文件 / 51 个类 / 24 个枚举）

| 文件 | 公开类 / 枚举 |
|---|---|
| chat_contact.dart | ChatContact |
| chat_conversation.dart | ChatConversation |
| chat_cursor_result.dart | ChatCursorResult |
| chat_device_info.dart | ChatDeviceInfo |
| chat_download_callback.dart | ChatDownloadCallback |
| chat_enums.dart | 枚举 ×22：ChatGroupStyle, ChatConversationType, ChatType, MessageDirection, MessageStatus, DownloadStatus, MessageType, ChatGroupPermissionType, ChatRoomPermissionType, ChatSearchDirection, ChatMultiDevicesEvent, ChatThreadOperation, DisplayStyle, ChatSilentModeParamType, ChatPushRemindType, ChatRoomMessagePriority, ReactionOperate, LeaveReason, MessagePinOperation, MessageSearchScope, ChatKeywordListMatchType, ConversationMarkType |
| chat_error.dart | ChatError |
| chat_group.dart | ChatGroup, ChatGroupInfo |
| chat_group_message_ack.dart | ChatGroupMessageAck |
| chat_group_options.dart | ChatGroupOptions |
| chat_group_shared_file.dart | ChatGroupSharedFile |
| chat_message.dart | ChatMessage；ChatMessageBody（abstract）及子类：ChatTextMessageBody, ChatLocationMessageBody, ChatImageMessageBody, ChatVoiceMessageBody, ChatVideoMessageBody, ChatFileMessageBody, ChatCmdMessageBody, ChatCustomMessageBody, CombineMessageBody |
| chat_message_reaction.dart | ChatMessageReaction, ChatMessageReactionEvent |
| chat_message_search_option.dart | ChatMessageSearchOption |
| chat_message_sender_info.dart | ChatMessageSenderInfo |
| chat_message_stream_chunk.dart | ChatStreamChunk；枚举 ChatStreamStatus |
| chat_options.dart | ChatOptions, ExtSettings |
| chat_page_result.dart | ChatPageResult |
| chat_presence.dart | ChatPresence, ChatPresenceStatusDetail |
| chat_push_configs.dart | ChatPushConfigs |
| chat_room.dart | ChatRoom |
| chat_search_server_message_result.dart | ChatSearchServerMessageResult |
| chat_silent_mode.dart | ChatSilentModeParam, ChatSilentModeTime, ChatSilentModeResult |
| chat_thread.dart | ChatThread, ChatThreadEvent |
| chat_translate_language.dart | ChatTranslateLanguage |
| chat_user_info.dart | ChatUserInfo |
| chat_voice_param.dart | ChatVoiceParam；枚举 ChatVoiceFormat |
| conversation_fetch_options.dart | ConversationFetchOptions |
| fetch_message_options.dart | FetchMessageOptions |
| group_member_info.dart | GroupMemberInfo |
| login_extension_info.dart | LoginExtensionInfo |
| message_pin_info.dart | MessagePinInfo |
| message_search_options.dart | MessageSearchOptions |
| reaction_operation.dart | ReactionOperation |
| recall_message_info.dart | RecallMessageInfo |

事件处理器类（`lib/src/handlers/manager_event_handler.dart`）：`ConnectionEventHandler`、`ChatMultiDeviceEventHandler`、`ChatEventHandler`、`ChatContactEventHandler`、`ChatGroupEventHandler`、`ChatRoomEventHandler`、`ChatPresenceEventHandler`、`ChatThreadEventHandler`、`ChatUserInfoEventHandler`、`ChatMessageEvent`。

## 6. 盘点发现的异常与注意点

1. **无引用的孤儿常量（11 个）**：`loginWithAgoraToken`、`uploadLog`、`onMessageChanged`、`onMessageReadAck`、`onMessageDeliveryAck`、`removeMsgFromServerWithTimeStamp`、`getAllChatRooms`、`getImPushConfig`、`reportPushAction`、`updateOwnUserInfoWithType`、`fetchUserInfoByIdWithType` 在 `im_flutter_sdk/lib` 与 `im_flutter_sdk_interface/lib` 中均无任何引用。其中：
   - `uploadLog`、`reportPushAction`、`getImPushConfig`、`getAllChatRooms`：常量存在但 Dart 侧从未发起过该调用（原生侧可能实现了对应分支，移植时需确认原生 wrapper 是否仍处理）。
   - `onMessageChanged`：无任何分发逻辑（消息变更实际走 `onMessageContentChanged`）。
   - `onMessageReadAck` / `onMessageDeliveryAck`：`MessageCallBackManager` 只处理 `onMessageProgressUpdate`/`onMessageError`/`onMessageSuccess`，这两个 key 未使用。
   - `removeMsgFromServerWithTimeStamp`：4.8.1 起被 `conversationDeleteServerMessageWithTime` 替代，旧常量残留。
2. **常量名 ≠ 字符串值（5 处）**：`onMessageReactionDidChange = 'messageReactionDidChange'`、`getChatThread = 'chatThread'`、`chatRoomChange = 'onChatRoomChanged'`、`presenceWithDescription = 'publishPresenceWithDescription'`、`updateAcceptInvitationAlways = 'acceptInvitationAlways'`。移植时以**字符串值**为准。
3. **一 key 多方法**：`searchChatMsgFromDB` 同时被 `ChatManager.loadMessagesWithKeyword` 与 `searchMsgFromDB`（Deprecated）使用；`login` 被 4 个登录方法共用；`fetchUserInfoById` 被 `fetchUserInfoById` 与 `fetchOwnInfo` 共用。
4. **跨 key 读返回值**：`ChatClient.changeAppId` 调用 `changeAppId` 却用 `ChatMethodKeys.changeAppKey` 读取结果（疑似复制粘贴问题）；`ChatConversation.deleteLocalAndServerMessages`（调用 `conversationDeleteServerMessageWithIds`）与 `deleteLocalAndServerMessagesByTime`（调用 `conversationDeleteServerMessageWithTime`）均用 `conversationGetLocalMessageCount` 读取返回值（这两个方法是 `Future<void>`，读取结果被丢弃，疑似残留代码）。移植时按调用 key 处理即可。
5. **channel 名大小写**：`com.chat.im/chat_userInfo_manager`（大写 I）与其他 channel 的命名风格不一致。
6. **事件常量命名笔误**：`ChatGroupChangeEvent.ON_SHARED_FILE__DELETED` 含双下划线；仅影响常量名，字符串值正常。
7. **ChatPushManager 无事件处理器**：9 个 Manager 中唯一没有 `addEventHandler` 的（无 push 相关回调事件）。
8. **`MessageCallBackManager` 位置**：定义在 `chat_manager.dart` 文件尾部（非独立文件），持有自己的 `com.chat.im/chat_message` channel，与 interface 层 `MessageChannel` 同名同实例语义。
9. **ChatClient 无统一 addEventHandler**：连接事件与多设备事件分别用 `addConnectionEventHandler` / `addMultiDeviceEventHandler` 两组 API。
