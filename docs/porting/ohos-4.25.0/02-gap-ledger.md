# 差距清单（Gap Ledger）：im_flutter_sdk 4.25.0 → 鸿蒙 chatsdk 1.15.0

- 盘点对象：git worktree `.worktree/ohos`（分支 `ohos`）
- 输入：`01-flutter-api-surface.md`（Flutter 4.25.0，271+48 key 口径）、`01-chatsdk-api-surface.md`（@easemob/chatsdk 1.15.0）
- 产出日期：2026-11-12
- 用途：鸿蒙 ArkTS 重写（P2）前确认差距边界；结尾「待用户确认清单」是批量确认的依据

## 统计汇总

### 方法 key（270 行，逐 key 一条）

| 分类 | 数量 | 占比 |
|---|---|---|
| 一致 | 214 | 79.3% |
| 签名差异 | 16 | 5.9% |
| 缺失 | 40 | 14.8% |

### 事件（45 个独立事件 key + 52 个 type 子事件 = 97 项）

| 分类 | 数量 |
|---|---|
| 一致 | 79 |
| 签名差异 | 9 |
| 缺失 | 9 |

### 按 channel 分布（方法 key）

| channel | key 数 | 一致 | 签名差异 | 缺失 |
|---|---|---|---|---|
| chat_client | 32 | 21 | 4 | 7 |
| chat_contact_manager | 16 | 16 | 0 | 0 |
| chat_manager | 57 | 48 | 5 | 4 |
| chat_conversation | 26 | 24 | 1 | 1 |
| chat_message | 4 | 3 | 0 | 1 |
| chat_room_manager | 33 | 27 | 1 | 5 |
| chat_group_manager | 55 | 52 | 2 | 1 |
| chat_push_manager | 22 | 11 | 2 | 9 |
| chat_userInfo_manager | 8 | 7 | 1 | 0 |
| chat_presence_manager | 5 | 5 | 0 | 0 |
| chat_thread_manager | 12 | 0 | 0 | 12 |
| file_progress_manager | 0 | — | — | — |
| **合计** | **270** | **214** | **16** | **40** |

### 按 channel 分布（事件项，含 type 子事件）

| channel | 事件项 | 一致 | 签名差异 | 缺失 |
|---|---|---|---|---|
| chat_client | 20 | 10 | 7 | 3 |
| chat_contact_manager | 8 | 8 | 0 | 0 |
| chat_manager | 15 | 15 | 0 | 0 |
| chat_message | 5 | 3 | 0 | 2 |
| chat_room_manager | 16 | 14 | 2 | 0 |
| chat_group_manager | 26 | 26 | 0 | 0 |
| chat_userInfo_manager | 2 | 2 | 0 | 0 |
| chat_presence_manager | 1 | 1 | 0 | 0 |
| chat_thread_manager | 4 | 0 | 0 | 4 |
| **合计** | **97** | **79** | **9** | **9** |

## 阅读说明

1. **分类定义**：
   - **一致**：chatsdk 有对应能力，参数/返回结构可对齐。枚举映射、同步/异步差异、参数从消息对象提取等平凡适配算一致，备注说明转换方式。
   - **签名差异**：能力存在但参数集、返回结构、枚举取值有明显差异，适配层需做非平凡转换或行为会不同。
   - **缺失**：chatsdk 1.15.0 无此能力。
2. **骨架**：以方法 key 逐条映射；一 key 多 Dart 方法的按 key 一条，备注列出各 Dart 方法。事件 key 按 `type` 子事件展开映射到 chatsdk Listener 回调。
3. **名≠值**：Flutter 侧 5 处常量名 ≠ 字符串值（`onMessageReactionDidChange='messageReactionDidChange'`、`getChatThread='chatThread'`、`chatRoomChange='onChatRoomChanged'`、`presenceWithDescription='publishPresenceWithDescription'`、`updateAcceptInvitationAlways='acceptInvitationAlways'`），本表「Flutter key」列一律取**字符串值**。
4. **chatsdk 侧名称**与 `01-chatsdk-api-surface.md` 逐字一致；语义不确定处标 ⚠️。T1.2 标注的疑似内部方法（`notifyPushResult`、`ChatMessage.setDelivered/setGroupAckCount/setBroadcast/setRecaller`、`ChatManager.checkAttachmentBeforeDownload`、`ChatOptions.setConfig`）不纳入映射。
5. **channel 名 `com.chat.im/chat_userInfo_manager` 大写 I 是有意的**，勿改。
6. **统计口径**：01-flutter 盘点文档头部统计为 319 常量（271 方法 + 48 事件）。按其各节表格逐行清点：总行数也是 319，但构成为 **270 方法 + 49 事件 key**（与头部的 271+48 差 1，属一个 key 的归类差异）；且 2.8 节头部（36 方法）与 2.9 节头部（47 方法）同各自表格实际行数（32、49 方法）不符。本 ledger 以表格逐行为准，统计数字均从本 ledger 表格计算（详见文末「意外发现」）。
7. 事件 key 中的 4 个容器 key（`onContactChanged`/`onChatRoomChanged`/`onGroupChanged`/`onUserInfoChanged`）本身不单独计分类，按其 `type` 子事件逐项分类计数。

## 1. chat_client（`com.chat.im/chat_client`）

### 1.1 方法（32）

| Flutter key | Manager | Dart 公开方法 | chatsdk 1.15.0 对应 | 分类 | 备注 |
|---|---|---|---|---|---|
| `init` | ChatClient | `ChatClient.init` | `ChatClient.init(context, chatOptions)` | 签名差异 | chatsdk 需额外传 UIAbility Context（插件层注入）；`ChatOptions` 字段需逐项映射，Flutter 侧推送证书类字段（HMS/FCM/APNs 配置）在鸿蒙无对应 |
| `createAccount` | ChatClient | `ChatClient.createAccount` | `ChatClient.createAccount` | 一致 | |
| `login` | ChatClient | `ChatClient.login`（Deprecated）、`loginWithToken`、`loginWithPassword`、`loginWithAgoraToken`（Deprecated） | `ChatClient.login` / `ChatClient.loginWithToken` | 一致 | 一 key 四方法；按 isPassword 分发到 chatsdk 两个方法。Agora token 登录鸿蒙不支持，见 `loginWithAgoraToken` |
| `loginWithAgoraToken` | ChatClient | 无引用（孤儿常量） | — | 缺失 | chatsdk 无 Agora token 登录；且 Flutter 侧本就是孤儿常量 |
| `renewToken` | ChatClient | `ChatClient.renewAgoraToken` | `ChatClient.renewToken` | 一致 | |
| `logout` | ChatClient | `ChatClient.logout` | `ChatClient.logout(unbindToken?)` | 一致 | |
| `changeAppKey` | ChatClient | `ChatClient.changeAppKey`；`changeAppId` 复用此 key 读返回值 | `ChatClient.changeAppkey` | 签名差异 | chatsdk 同步返回 `ChatError` 而非 `Future<bool>`，且仅未登录态可用 |
| `uploadLog` | ChatClient | 无引用（孤儿常量） | `ChatClient.uploadLog` | 一致 | chatsdk 有对应能力；Flutter Dart 侧从未发起调用 |
| `compressLogs` | ChatClient | `ChatClient.compressLogs` | — | 缺失 | chatsdk ChatLog 无压缩日志能力 |
| `kickDevice` | ChatClient | `ChatClient.kickDevice` | — | 缺失 | chatsdk 无多端设备管理 API |
| `kickAllDevices` | ChatClient | `ChatClient.kickAllDevices` | — | 缺失 | 同上 |
| `getLoggedInDevicesFromServer` | ChatClient | `ChatClient.fetchLoggedInDevices`；`getLoggedInDevicesFromServer`（Deprecated） | — | 缺失 | 同上 |
| `getToken` | ChatClient | `ChatClient.getAccessToken` | `ChatClient.getAccessToken` | 一致 | |
| `getCurrentUser` | ChatClient | `ChatClient.getCurrentUserId` | `ChatClient.getCurrentUser` | 一致 | |
| `getCurrentDeviceId` | ChatClient | `ChatClient.getCurrentDeviceId` | `ChatOptions.getDeviceUuid` | 一致 | Android 实现返回 DeviceUuidFactory 生成的设备 UUID（含 deviceName/resource 空字段）；chatsdk 对应物为 `ChatOptions.getDeviceUuid`，语义基本等同 ⚠️（deviceName/resource 无对应） |
| `isLoggedInBefore` | ChatClient | `ChatClient.isLoginBefore` | `ChatClient.isAutoLogin` | 签名差异 | ⚠️ 语义最接近但不完全等同：Flutter 表示"曾登录过"（自动登录判断依据），chatsdk `isAutoLogin` 为"是否自动登录状态"（Promise），需实测确认 |
| `isConnected` | ChatClient | `ChatClient.isConnected` | `ChatClient.isConnected` | 一致 | |
| `startCallback` | ChatClient | `ChatClient.startCallback` | — | 缺失 | Flutter 框架内部机制（Dart 侧就绪后再放行原生回调），不依赖 chatsdk；ArkTS 侧按需自行实现等价机制 |
| `changeAppId` | ChatClient | `ChatClient.changeAppId` | `ChatClient.changeAppId` | 签名差异 | 同 `changeAppKey`：返回 `ChatError`、仅未登录态；另 Flutter 侧存在跨 key 读返回值残留（用 `changeAppKey` 读结果），移植按调用 key 处理 |
| `updateUsingHttpsOnlySetting` | ChatClient | `ChatClient.updateUsingHttpsOnlySetting` | `ChatOptions.setUsingHttpsOnly` | 一致 | |
| `updateLoginExtensionInfo` | ChatClient | `ChatClient.updateLoginExtensionInfoSetting` | `ChatOptions.setLoginCustomExt` | 一致 | |
| `updateDeleteMessagesWhenLeaveGroupSetting` | ChatClient | `ChatClient.updateDeleteMessagesWhenLeaveGroupSetting` | `ChatOptions.setDeleteMessagesOnLeaveGroup` | 一致 | |
| `updateDeleteMessageWhenLeaveRoomSetting` | ChatClient | `ChatClient.updateDeleteMessageWhenLeaveRoomSetting` | `ChatOptions.setDeleteMessagesOnLeaveChatroom` | 一致 | |
| `updateRoomOwnerCanLeaveSetting` | ChatClient | `ChatClient.updateRoomOwnerCanLeaveSetting` | — | 缺失 | chatsdk ChatOptions 无"聊天室所有者可退出"开关 |
| `updateAutoAcceptGroupInvitationSetting` | ChatClient | `ChatClient.updateAutoAcceptGroupInvitationSetting` | `ChatOptions.setAutoAcceptGroupInvitations` | 一致 | |
| `acceptInvitationAlways` | ChatClient | `ChatClient.updateAutoAcceptFriendInvitationSetting` | `ChatOptions.setAcceptInvitationAlways` | 一致 | 常量名 `updateAcceptInvitationAlways` ≠ 值，以值为准 |
| `updateAutoDownloadAttachmentThumbnailSetting` | ChatClient | `ChatClient.updateAutoDownloadAttachmentThumbnailSetting` | `ChatOptions.setAutoDownloadThumbnail` | 一致 | |
| `updateRequireAckSetting` | ChatClient | `ChatClient.updateRequireAckSetting` | `ChatOptions.setRequireReadAck` | 一致 | |
| `updateDeliveryAckSetting` | ChatClient | `ChatClient.updateDeliveryAckSetting` | `ChatOptions.setRequireDeliveryAck` | 一致 | |
| `updateSortMessageByServerTimeSetting` | ChatClient | `ChatClient.updateSortMessageByServerTimeSetting` | `ChatOptions.setSortMessageByServerTime` | 一致 | |
| `updateMessagesReceiveCallbackIncludeSendSetting` | ChatClient | `ChatClient.updateMessagesReceiveCallbackIncludeSendSetting` | `ChatOptions.setIncludeSendMessageInMessageListener` | 一致 | |
| `updateRegradeMessagesSetting` | ChatClient | `ChatClient.updateRegradeMessagesAsReadSetting` | `ChatOptions.setRegardImportedMsgAsRead` | 一致 | Android 实现确认为 `setRegardImportedMsgAsRead` |

### 1.2 事件（20）

| Flutter key | Dart 事件处理器 | chatsdk 1.15.0 对应 | 分类 | 备注 |
|---|---|---|---|---|
| `onMultiDeviceGroupEvent` | `ChatMultiDeviceEventHandler.onGroupEvent` | `MultiDevicesListener.onGroupEvent` | 一致 | |
| `onMultiDeviceContactEvent` | `ChatMultiDeviceEventHandler.onContactEvent` | `MultiDevicesListener.onContactEvent` | 一致 | |
| `onMultiDeviceThreadEvent` | `ChatMultiDeviceEventHandler.onChatThreadEvent` | — | 缺失 | chatsdk 无子区（见结构性差异 1） |
| `onMultiDeviceRemoveMessagesEvent` | `ChatMultiDeviceEventHandler.onRemoteMessagesRemoved` | `MultiDevicesListener.onMessageRemoved` | 一致 | |
| `onMultiDevicesConversationEvent` | `ChatMultiDeviceEventHandler.onConversationEvent` | `MultiDevicesListener.onConversationEvent` | 一致 | |
| `onConnected` | `ConnectionEventHandler.onConnected` | `ConnectionListener.onConnected` | 一致 | |
| `onDisconnected` | `ConnectionEventHandler.onDisconnected` | `ConnectionListener.onDisconnected(errorCode)` | 一致 | |
| `onUserDidLoginFromOtherDevice` | `ConnectionEventHandler.onUserDidLoginFromOtherDevice` | `ConnectionListener.onLogout(errorCode, info)` | 签名差异 | ⚠️ 需经 onLogout/onDisconnected 的 errorCode 二次分发；需核对 chatsdk 114 个错误码是否覆盖该原因 |
| `onUserDidRemoveFromServer` | `ConnectionEventHandler.onUserDidRemoveFromServer` | `ConnectionListener.onLogout(errorCode, info)` | 签名差异 | 同上 |
| `onUserDidForbidByServer` | `ConnectionEventHandler.onUserDidForbidByServer` | `ConnectionListener.onLogout(errorCode, info)` | 签名差异 | 同上 |
| `onUserDidChangePassword` | `ConnectionEventHandler.onUserDidChangePassword` | `ConnectionListener.onLogout(errorCode, info)` | 签名差异 | 同上 |
| `onUserDidLoginTooManyDevice` | `ConnectionEventHandler.onUserDidLoginTooManyDevice` | `ConnectionListener.onLogout(errorCode, info)` | 签名差异 | 同上 |
| `onUserKickedByOtherDevice` | `ConnectionEventHandler.onUserKickedByOtherDevice` | `ConnectionListener.onLogout(errorCode, info)` | 签名差异 | 同上 |
| `onUserAuthenticationFailed` | 分发到 `ConnectionEventHandler.onDisconnected` | `ConnectionListener.onLogout(errorCode, info)` | 签名差异 | 同上 |
| `onSendDataToFlutter` | `ChatClient.customEventHandler` | — | 缺失 | Flutter 自定义原生→Dart 透传管道，不依赖 chatsdk；如需保留可在 ArkTS 插件层自行实现 |
| `onTokenWillExpire` | `ConnectionEventHandler.onTokenWillExpire` | `ConnectionListener.onTokenWillExpire` | 一致 | |
| `onTokenDidExpire` | `ConnectionEventHandler.onTokenDidExpire` | `ConnectionListener.onTokenExpired` | 一致 | |
| `onAppActiveNumberReachLimit` | `ConnectionEventHandler.onAppActiveNumberReachLimit` | — | 缺失 | chatsdk ConnectionListener 无此回调 |
| `onOfflineMessageSyncStart` | `ConnectionEventHandler.onOfflineMessageSyncStart` | `ConnectionListener.onOfflineMessageSyncStart` | 一致 | |
| `onOfflineMessageSyncFinish` | `ConnectionEventHandler.onOfflineMessageSyncFinish` | `ConnectionListener.onOfflineMessageSyncFinish` | 一致 | |

## 2. chat_contact_manager（`com.chat.im/chat_contact_manager`）

### 2.1 方法（16）

| Flutter key | Manager | Dart 公开方法 | chatsdk 1.15.0 对应 | 分类 | 备注 |
|---|---|---|---|---|---|
| `addContact` | ChatContactManager | `addContact` | `ContactManager.addContact(userId, reason?)` | 一致 | |
| `deleteContact` | ChatContactManager | `deleteContact` | `ContactManager.deleteContact(userId, keepConversation?)` | 一致 | |
| `getAllContactsFromServer` | ChatContactManager | `fetchAllContactIds`；`getAllContactsFromServer`（Deprecated） | `ContactManager.fetchAllContactsIDFromServer` | 一致 | 一 key 两方法 |
| `getAllContactsFromDB` | ChatContactManager | `getAllContactIds`；`getAllContactsFromDB`（Deprecated） | `ContactManager.allContacts` | 一致 | 一 key 两方法 |
| `addUserToBlockList` | ChatContactManager | `addUserToBlockList` | `ContactManager.addUsersToBlocklist` | 一致 | chatsdk 参数为 `Array<string> \| string`，单用户直接传 string |
| `removeUserFromBlockList` | ChatContactManager | `removeUserFromBlockList` | `ContactManager.removeUserFromBlockList` | 一致 | |
| `getBlockListFromServer` | ChatContactManager | `fetchBlockIds`；`getBlockListFromServer`（Deprecated） | `ContactManager.getBlockListFromServer` | 一致 | 一 key 两方法 |
| `getBlockListFromDB` | ChatContactManager | `getBlockIds`；`getBlockListFromDB`（Deprecated） | `ContactManager.blockList` | 一致 | 一 key 两方法 |
| `acceptInvitation` | ChatContactManager | `acceptInvitation` | `ContactManager.acceptInvitation` | 一致 | |
| `declineInvitation` | ChatContactManager | `declineInvitation` | `ContactManager.declineInvitation` | 一致 | |
| `getSelfIdsOnOtherPlatform` | ChatContactManager | `getSelfIdsOnOtherPlatform` | `ContactManager.getSelfIdsOnOtherPlatform` | 一致 | |
| `getAllContacts` | ChatContactManager | `getAllContacts` | `ContactManager.getContactsFromLocal` | 一致 | |
| `setContactRemark` | ChatContactManager | `setContactRemark` | `ContactManager.setContactRemark` | 一致 | |
| `getContact` | ChatContactManager | `getContact` | `ContactManager.getContact` | 一致 | |
| `fetchAllContacts` | ChatContactManager | `fetchAllContacts` | `ContactManager.fetchAllContactsFromServer` | 一致 | |
| `fetchContacts` | ChatContactManager | `fetchContacts` | `ContactManager.fetchAllContactsFromServerByPage` | 一致 | |

### 2.2 事件（容器 key `onContactChanged`，8 个 type 子事件 → ContactListener）

| type 值 | Flutter 事件常量 | chatsdk 1.15.0 对应 | 分类 | 备注 |
|---|---|---|---|---|
| `onContactAdded` | `ChatContactChangeEvent.CONTACT_ADD` | `ContactListener.onContactAdded` | 一致 | |
| `onContactDeleted` | `CONTACT_DELETE` | `ContactListener.onContactDeleted` | 一致 | |
| `onContactInvited` | `INVITED` | `ContactListener.onContactInvited` | 一致 | |
| `onFriendRequestAccepted` | `INVITATION_ACCEPTED` | `ContactListener.onFriendRequestAccepted` | 一致 | |
| `onFriendRequestDeclined` | `INVITATION_DECLINED` | `ContactListener.onFriendRequestDeclined` | 一致 | |
| `onContactSyncStart` | `CONTACT_SYNC_START` | `ContactListener.onContactSyncStart` | 一致 | |
| `onContactSyncFinish` | `CONTACT_SYNC_FINISH` | `ContactListener.onContactSyncFinishWithError(errorCode, error)` | 一致 | chatsdk 回调多带 errorCode/error 参数，适配层可取用或丢弃 |
| `onContactInfoUpdate` | `CONTACT_INFO_UPDATE` | `ContactListener.onContactInfoUpdate` | 一致 | |

## 3. chat_manager（`com.chat.im/chat_manager`）

### 3.1 方法（57）

| Flutter key | Manager | Dart 公开方法 | chatsdk 1.15.0 对应 | 分类 | 备注 |
|---|---|---|---|---|---|
| `sendMessage` | ChatManager | `sendMessage` | `ChatManager.sendMessage` | 签名差异 | chatsdk 返回 `void`，发送结果经 `ChatMessage.setMessageStatusCallback` 回调；Flutter 返回 `Future<ChatMessage>` 且经 chat_message channel 事件回传，适配层需桥接两种模式 |
| `resendMessage` | ChatManager | `resendMessage` | — | 缺失 | chatsdk 无独立重发接口；可复用 `sendMessage` 重发同一消息对象实现 |
| `ackMessageRead` | ChatManager | `sendMessageReadAck` | `ChatManager.ackMessageRead(to, messageId)` | 一致 | to/messageId 从消息对象提取 |
| `ackGroupMessageRead` | ChatManager | `sendGroupMessageReadAck` | `ChatManager.ackGroupMessageRead(message, ext)` | 一致 | |
| `ackConversationRead` | ChatManager | `sendConversationReadAck` | `ChatManager.ackConversationRead` | 一致 | |
| `recallMessage` | ChatManager | `recallMessage` | `ChatManager.recallMessage(message, ext?)` | 一致 | Flutter 传 messageId，需先 `getMessage` 取消息对象 |
| `getConversation` | ChatManager | `getConversation` | `ChatManager.getConversation` | 一致 | Flutter 的 `ChatConversationType.Thread` 类型鸿蒙不支持 |
| `getThreadConversation` | ChatManager | `getThreadConversation` | — | 缺失 | chatsdk 无子区（见结构性差异 1） |
| `markAllChatMsgAsRead` | ChatManager | `markAllConversationsAsRead` | `ChatManager.markAllConversationsAsRead` | 一致 | |
| `getUnreadMessageCount` | ChatManager | `getUnreadMessageCount` | — | 签名差异 | chatsdk 无聚合未读数接口，需 `getConversations` + 各 `Conversation.getUnreadMsgCount` 求和 |
| `updateChatMessage` | ChatManager | `updateMessage` | `ChatManager.updateMessage` | 一致 | |
| `downloadAttachment` | ChatManager | `downloadAttachment` | `ChatManager.downloadAttachment(message, onProgress?)` | 一致 | 进度经 onProgress 回调桥接到 `ChatMessageEvent.onProgress` |
| `downloadThumbnail` | ChatManager | `downloadThumbnail` | `ChatManager.downloadThumbnail(message, onProgress?)` | 一致 | 同上 |
| `downloadMessageAttachmentInCombine` | ChatManager | `downloadMessageAttachmentInCombine` | — | 签名差异 | 无合并消息内附件的专用下载接口；需先 `downloadAndParseCombineMessage` 再对子消息调 `downloadAttachment` |
| `downloadMessageThumbnailInCombine` | ChatManager | `downloadMessageThumbnailInCombine` | — | 签名差异 | 同上，调 `downloadThumbnail` |
| `importMessages` | ChatManager | `importMessages` | `ChatManager.importMessages` | 一致 | |
| `loadAllConversations` | ChatManager | `loadAllConversations` | `ChatManager.getConversations` / `getAllConversationsBySort` | 一致 | |
| `getConversationsFromServer` | ChatManager | `getConversationsFromServer`（Deprecated） | `ChatManager.fetchConversationsFromServer(limit, cursor)` | 一致 | Deprecated 方法 |
| `deleteConversation` | ChatManager | `deleteConversation` | `ChatManager.deleteConversation(conversationId, isRemoveMessages)` | 一致 | |
| `fetchHistoryMessages` | ChatManager | `fetchHistoryMessages`（Deprecated） | `ChatManager.fetchHistoryMessages`（重载2） | 一致 | Deprecated 方法 |
| `fetchHistoryMessagesByOptions` | ChatManager | `fetchHistoryMessagesByOption` | `ChatManager.fetchHistoryMessages`（重载1，`FetchHistoryMessagesParam`） | 一致 | `FetchMessageOptions`→`FetchMessageOption` 字段映射 |
| `searchChatMsgFromDB` | ChatManager | `loadMessagesWithKeyword`、`searchMsgFromDB`（Deprecated） | `ChatManager.searchMessagesFromDB`（重载1） | 一致 | 一 key 两方法 |
| `getMessage` | ChatManager | `loadMessage` | `ChatManager.getMessage` | 一致 | |
| `asyncFetchGroupAcks` | ChatManager | `fetchGroupAcks` | `ChatManager.fetchGroupReadAcks(messageId, pageSize, startAckId)` | 一致 | chatsdk 无 groupId 参数 |
| `deleteRemoteConversation` | ChatManager | `deleteRemoteConversation` | `ChatManager.deleteConversationFromServer` | 一致 | |
| `deleteMessagesBeforeTimestamp` | ChatManager | `deleteMessagesBefore` | — | 缺失 | chatsdk 无"按时间戳删除全部本地消息"接口 |
| `translateMessage` | ChatManager | `translateMessage` | `ChatManager.translateMessage` | 一致 | |
| `fetchSupportLanguages` | ChatManager | `fetchSupportedLanguages` | `ChatManager.fetchSupportLanguages` | 一致 | `ChatTranslateLanguage`→`TranslationLanguage` |
| `addReaction` | ChatManager | `addReaction` | `ChatManager.addReaction` | 一致 | |
| `removeReaction` | ChatManager | `removeReaction` | `ChatManager.removeReaction` | 一致 | |
| `fetchReactionList` | ChatManager | `fetchReactionList` | `ChatManager.fetchReactions` | 一致 | |
| `fetchReactionDetail` | ChatManager | `fetchReactionDetail` | `ChatManager.fetchReactionDetail(FetchReactionDetailParams)` | 一致 | |
| `reportMessage` | ChatManager | `reportMessage` | — | 缺失 | chatsdk 无消息举报接口 |
| `fetchConversationsFromServerWithPage` | ChatManager | `fetchConversationListFromServer`（Deprecated） | `ChatManager.fetchConversationsFromServer(limit, cursor)` | 签名差异 | Flutter 按 pageNum 分页，chatsdk 按 cursor 分页；Deprecated 方法，可不移植 |
| `removeMessagesFromServerWithMsgIds` | ChatManager | `deleteRemoteMessagesWithIds` | `ChatManager.removeMessagesFromServer`（重载1） | 一致 | |
| `removeMessagesFromServerWithTs` | ChatManager | `deleteRemoteMessagesBefore` | `ChatManager.removeMessagesFromServer`（重载2） | 一致 | |
| `getConversationsFromServerWithCursor` | ChatManager | `fetchConversation`（Deprecated） | `ChatManager.fetchConversationsFromServer` | 一致 | Deprecated 方法 |
| `getPinnedConversationsFromServerWithCursor` | ChatManager | `fetchPinnedConversations`（Deprecated） | `ChatManager.fetchPinnedConversationsFromServer` | 一致 | Deprecated 方法 |
| `getConversationsFromDBWithCursor` | ChatManager | `fetchConversationsFromDB` | `ChatManager.getConversationsFromDB` | 一致 | 需先关闭 `ChatOptions.setAutoLoadAllConversations` |
| `pinConversation` | ChatManager | `pinConversation` | `ChatManager.pinConversation` | 一致 | |
| `modifyMessage` | ChatManager | `modifyMessage` | `ChatManager.modifyMessage` | 一致 | chatsdk modifiedBody 仅支持 Text/Custom 消息体 |
| `downloadAndParseCombineMessage` | ChatManager | `fetchCombineMessageDetail` | `ChatManager.downloadAndParseCombineMessage` | 一致 | |
| `addRemoteAndLocalConversationsMark` | ChatManager | `addRemoteAndLocalConversationsMark` | `ChatManager.addConversationMark` | 一致 | `ConversationMarkType`→`MarkType` |
| `deleteRemoteAndLocalConversationsMark` | ChatManager | `deleteRemoteAndLocalConversationsMark` | `ChatManager.removeConversationMark` | 一致 | 同上 |
| `fetchConversationsByOptions` | ChatManager | `fetchConversationsByOptions` | `ChatManager.fetchConversationsFromServerWithFilter(ConversationFilter)` | 一致 | `ConversationFetchOptions`→`ConversationFilter` 字段需逐项核对 ⚠️ |
| `deleteAllMessageAndConversation` | ChatManager | `deleteAllMessageAndConversation` | `ChatManager.deleteAllConversationsAndMessages` | 一致 | |
| `pinMessage` | ChatManager | `pinMessage` | `ChatManager.pinMessage` | 一致 | |
| `unpinMessage` | ChatManager | `unpinMessage` | `ChatManager.unpinMessage` | 一致 | |
| `fetchPinnedMessages` | ChatManager | `fetchPinnedMessages` | `ChatManager.fetchPinnedMessagesFromServer` | 一致 | 仅服务端拉取 |
| `searchMsgsByOptions` | ChatManager | `searchMsgsByOptions` | `ChatManager.searchMessagesFromDB`（重载3，按类型集合） | 一致 | Android 实现确认为按 types 集合搜索本地消息 |
| `getMessageCount` | ChatManager | `getAllMessageCount` | `ChatManager.getDBMsgsCount` | 一致 | |
| `loadConversationMessagesWithKeyword` | ChatManager | `loadConversationMessagesWithKeyword` | `ChatManager.loadConversationMessagesWithKeyword` | 一致 | |
| `loadMessagesWithIds` | ChatManager | `loadMessagesWithIds` | `ChatManager.loadMessages(messageIds)` | 一致 | chatsdk 仅需 msgIds（≤20 条），Flutter 的 conversationId 参数无需对应 |
| `downloadBigImage` | ChatManager | `downloadBigImage` | `ChatManager.downloadBigImage(message, onProgress?)` | 一致 | |
| `voiceMessageToText` | ChatManager | `voiceMessageToText` | `ChatManager.voiceMessageToText` | 一致 | |
| `voiceFileToText` | ChatManager | `voiceFileToText` | `ChatManager.voiceFileToText(filePath, audioParams?)` | 一致 | `ChatVoiceParam`→`ChatAudioParams` |
| `searchMessagesFromServer` | ChatManager | `searchMessagesFromServer` | `ChatManager.searchMessagesFromServer`（重载2） | 一致 | `ChatMessageSearchOption`→`MessageSearchOption` |

### 3.2 事件（15，channel: chat_manager）

| Flutter key | Dart 事件处理器 | chatsdk 1.15.0 对应 | 分类 | 备注 |
|---|---|---|---|---|
| `onMessagesReceived` | `ChatEventHandler.onMessagesReceived` | `ChatMessageListener.onMessageReceived` | 一致 | |
| `onStreamMessagesReceived` | `ChatEventHandler.onStreamMessagesReceived` | `ChatMessageListener.onStreamMessageReceived` | 一致 | |
| `onCmdMessagesReceived` | `ChatEventHandler.onCmdMessagesReceived` | `ChatMessageListener.onCmdMessageReceived` | 一致 | |
| `onMessagesRead` | `ChatEventHandler.onMessagesRead` | `ChatMessageListener.onMessageRead` | 一致 | |
| `onReadAckForGroupMessageUpdated` | `ChatEventHandler.onReadAckForGroupMessageUpdated` | `ChatMessageListener.onReadAckForGroupMessageUpdated` | 一致 | |
| `onGroupMessageRead` | `ChatEventHandler.onGroupMessageRead` | `ChatMessageListener.onGroupMessageRead` | 一致 | |
| `onMessagesDelivered` | `ChatEventHandler.onMessagesDelivered` | `ChatMessageListener.onMessageDelivered` | 一致 | |
| `onMessagesRecalled` | `ChatEventHandler.onMessagesRecalled` | `ChatMessageListener.onMessageRecalled(recallInfo)` | 一致 | chatsdk 单回调携带 `RecallMessageInfo`，同时支撑本 key 与 `onMessagesRecalledInfo` |
| `onMessageChanged` | 无引用（孤儿常量） | `ChatMessageListener.onMessageChanged` | 一致 | chatsdk 有对应回调；Flutter Dart 侧无分发逻辑 |
| `onConversationUpdate` | `ChatEventHandler.onConversationsUpdate` | `ConversationListener.onConversationUpdate` | 一致 | |
| `onConversationHasRead` | `ChatEventHandler.onConversationRead` | `ConversationListener.onConversationRead(from, to)` | 一致 | |
| `messageReactionDidChange` | `ChatEventHandler.onMessageReactionDidChange` | `ChatMessageListener.onReactionChanged` | 一致 | 常量名 `onMessageReactionDidChange` ≠ 值，以值为准 |
| `onMessageContentChanged` | `ChatEventHandler.onMessageContentChanged` | `ChatMessageListener.onMessageContentChanged` | 一致 | |
| `onMessagePinChanged` | `ChatEventHandler.onMessagePinChanged` | `ChatMessageListener.onMessagePinChanged` | 一致 | |
| `onMessagesRecalledInfo` | `ChatEventHandler.onMessagesRecalledInfo` | `ChatMessageListener.onMessageRecalled(recallInfo)` | 一致 | 与 `onMessagesRecalled` 共用 chatsdk 同一回调 |

## 4. chat_conversation（`com.chat.im/chat_conversation`）

chatsdk 无独立 ConversationManager（见结构性差异 2），以下方法 key 全部映射到 chatsdk `Conversation` 类（少数经 `ChatManager`）。

### 4.1 方法（26）

| Flutter key | Manager | Dart 公开方法 | chatsdk 1.15.0 对应 | 分类 | 备注 |
|---|---|---|---|---|---|
| `getUnreadMsgCount` | ChatConversation | `unreadCount` | `Conversation.getUnreadMsgCount` | 一致 | |
| `markAllMessagesAsRead` | ChatConversation | `markAllMessagesAsRead` | `Conversation.markAllMessagesAsRead` | 一致 | |
| `markMessageAsRead` | ChatConversation | `markMessageAsRead` | `Conversation.markMessageAsRead` | 一致 | |
| `syncConversationExt` | ChatConversation | `setExt` | `Conversation.setExtField` | 一致 | Flutter ext 为 `Map<String,String>?`，chatsdk 为 string，需 JSON 序列化/反序列化 |
| `removeMessage` | ChatConversation | `deleteMessage` | `Conversation.removeMessage` | 一致 | |
| `deleteMessageByIds` | ChatConversation | `deleteMessageByIds` | — | 签名差异 | chatsdk 无批量删除，需循环 `Conversation.removeMessage` 单条删除 |
| `getLatestMessage` | ChatConversation | `latestMessage` | `Conversation.getLatestMessage` | 一致 | |
| `getLatestMessageFromOthers` | ChatConversation | `lastReceivedMessage` | `Conversation.getLatestMessageFromOthers` | 一致 | |
| `clearAllMessages` | ChatConversation | `deleteAllMessages` | `Conversation.clearAllMessages` | 一致 | |
| `deleteMessagesWithTs` | ChatConversation | `deleteMessagesWithTs` | — | 缺失 | chatsdk 无按时间段删除本地消息接口 |
| `insertMessage` | ChatConversation | `insertMessage` | `Conversation.insertMessage` | 一致 | |
| `appendMessage` | ChatConversation | `appendMessage` | `Conversation.appendMessage` | 一致 | |
| `updateConversationMessage` | ChatConversation | `updateMessage` | `Conversation.updateMessage` | 一致 | |
| `loadMsgWithId` | ChatConversation | `loadMessage` | `Conversation.getMessage` | 一致 | |
| `loadMsgWithStartId` | ChatConversation | `loadMessages` | `Conversation.loadMoreMessagesFromDB` | 一致 | |
| `loadMsgWithKeywords` | ChatConversation | `loadMessagesWithKeyword` | `Conversation.searchMessagesByKeywords` | 一致 | chatsdk from 参数支持 `string \| string[]`，可覆盖 Flutter senders 参数 |
| `loadMsgWithMsgType` | ChatConversation | `loadMessagesWithMsgType` | `Conversation.searchMessagesByType` | 一致 | |
| `loadMsgWithTime` | ChatConversation | `loadMessagesFromTime` | `Conversation.searchMessagesBetweenTime` | 一致 | |
| `messageCount` | ChatConversation | `messagesCount` | `Conversation.getAllMsgCount` | 一致 | |
| `removeMsgFromServerWithTimeStamp` | ChatConversation | 无引用（孤儿常量，4.8.1 起被替代） | `ChatManager.removeMessagesFromServer`（重载2） | 一致 | 能力存在但 Flutter 侧已废弃不用 |
| `conversationRemindType` | ChatConversation | `remindType` | `Conversation.pushRemindType` | 一致 | |
| `conversationSearchMsgsByOptions` | ChatConversation | `searchMsgsByOptions` | `Conversation.searchMessagesByType` | 一致 | Android 实现确认为按 types 集合搜索 |
| `conversationGetLocalMessageCount` | ChatConversation | `getLocalMessageCount`；`deleteLocalAndServerMessages`/`deleteLocalAndServerMessagesByTime` 也用此 key 读返回值 | `Conversation.getMsgCountInRange` | 一致 | 一 key 三方法（后两者读取结果被丢弃，属 Flutter 侧残留） |
| `conversationDeleteServerMessageWithIds` | ChatConversation | `deleteLocalAndServerMessages` | `ChatManager.removeMessagesFromServer`（重载1） | 一致 | Android 实现确认为 `conversation.removeMessagesFromServer(msgIds)` |
| `conversationDeleteServerMessageWithTime` | ChatConversation | `deleteLocalAndServerMessagesByTime` | `ChatManager.removeMessagesFromServer`（重载2） | 一致 | Android 实现确认为 `conversation.removeMessagesFromServer(beforeMs)` |
| `pinnedMessages` | ChatConversation | `loadPinnedMessages` | `Conversation.getPinnedMessages` | 一致 | |

## 5. chat_message（`com.chat.im/chat_message`）

### 5.1 方法（4）

| Flutter key | Manager | Dart 公开方法 | chatsdk 1.15.0 对应 | 分类 | 备注 |
|---|---|---|---|---|---|
| `getReactionList` | ChatMessage | `reactionList` | `ChatMessage.getReactions` | 一致 | |
| `groupAckCount` | ChatMessage | `groupAckCount` | `ChatMessage.groupAckCount` | 一致 | |
| `chatThread` | ChatMessage | `chatThread` | — | 缺失 | chatsdk 无子区（见结构性差异 1）；常量名 `getChatThread` ≠ 值，以值为准 |
| `getPinInfo` | ChatMessage | `pinInfo` | `ChatMessage.getPinnedInfo` | 一致 | |

### 5.2 事件（5，经 `MessageCallBackManager`，channel: chat_message）

| Flutter key | Dart 事件 | chatsdk 1.15.0 对应 | 分类 | 备注 |
|---|---|---|---|---|
| `onMessageProgressUpdate` | `ChatMessageEvent.onProgress` | `ChatCallback.onProgress`（经 `ChatMessage.setMessageStatusCallback`/`addMessageStatusCallback`） | 一致 | 下载类方法的 onProgress 参数亦桥接到此 |
| `onMessageError` | `ChatMessageEvent.onError` | `ChatCallback.onError(code, error)` | 一致 | |
| `onMessageSuccess` | `ChatMessageEvent.onSuccess` | `ChatCallback.onSuccess` | 一致 | |
| `onMessageReadAck` | 无引用（孤儿常量） | — | 缺失 | chatsdk 无消息级独立已读 ack 回调；已读由 `ChatMessageListener.onMessageRead` 承担 |
| `onMessageDeliveryAck` | 无引用（孤儿常量） | — | 缺失 | 同上，送达由 `ChatMessageListener.onMessageDelivered` 承担 |

## 6. chat_room_manager（`com.chat.im/chat_room_manager`）

### 6.1 方法（33）

| Flutter key | Manager | Dart 公开方法 | chatsdk 1.15.0 对应 | 分类 | 备注 |
|---|---|---|---|---|---|
| `joinChatRoom` | ChatRoomManager | `joinChatRoom` | `ChatroomManager.joinChatroom(roomId, leaveOtherRooms?, ext?)` | 一致 | chatsdk 返回 `Promise<Chatroom>` |
| `leaveChatRoom` | ChatRoomManager | `leaveChatRoom` | `ChatroomManager.leaveChatroom` | 一致 | |
| `fetchPublicChatRoomsFromServer` | ChatRoomManager | `fetchPublicChatRoomsFromServer` | `ChatroomManager.fetchPublicChatroomsFromServer(pageNum, pageSize)` | 签名差异 | Flutter 返回 `ChatPageResult<ChatRoom>`（含分页信息），chatsdk 返回 `Array<Chatroom>` 无总数/分页元数据 |
| `fetchChatRoomInfoFromServer` | ChatRoomManager | `fetchChatRoomInfoFromServer` | — | 缺失 | chatsdk 无单个聊天室服务端详情拉取接口 |
| `getChatRoom` | ChatRoomManager | `getChatRoomWithId` | — | 缺失 | chatsdk 无聊天室本地缓存查询接口 |
| `getAllChatRooms` | ChatRoomManager | 无引用（孤儿常量） | — | 缺失 | chatsdk 无本地聊天室列表缓存；且为孤儿常量 |
| `createChatRoom` | ChatRoomManager | `createChatRoom` | — | 缺失 | chatsdk 无创建聊天室接口 |
| `destroyChatRoom` | ChatRoomManager | `destroyChatRoom` | — | 缺失 | chatsdk 无解散聊天室接口 |
| `changeChatRoomSubject` | ChatRoomManager | `changeChatRoomName` | `ChatroomManager.changeChatroomName` | 一致 | |
| `changeChatRoomDescription` | ChatRoomManager | `changeChatRoomDescription` | `ChatroomManager.changeChatroomDescription` | 一致 | |
| `fetchChatRoomMembers` | ChatRoomManager | `fetchChatRoomMembers` | `ChatroomManager.fetchChatroomMembers` | 一致 | |
| `muteChatRoomMembers` | ChatRoomManager | `muteChatRoomMembers` | `ChatroomManager.muteChatroomMembers` | 一致 | |
| `unMuteChatRoomMembers` | ChatRoomManager | `unMuteChatRoomMembers` | `ChatroomManager.unmuteChatroomMembers` | 一致 | |
| `changeChatRoomOwner` | ChatRoomManager | `changeOwner` | `ChatroomManager.changeChatroomOwner` | 一致 | |
| `addChatRoomAdmin` | ChatRoomManager | `addChatRoomAdmin` | `ChatroomManager.addChatroomAdmin` | 一致 | |
| `removeChatRoomAdmin` | ChatRoomManager | `removeChatRoomAdmin` | `ChatroomManager.removeChatroomAdmin` | 一致 | |
| `fetchChatRoomMuteList` | ChatRoomManager | `fetchChatRoomMuteList` | `ChatroomManager.fetchChatroomMutes` | 一致 | chatsdk 返回 `Map<string, number>`（含禁言到期时间），取 keys 即得 Flutter 的 `List<String>` |
| `removeChatRoomMembers` | ChatRoomManager | `removeChatRoomMembers` | `ChatroomManager.removeChatroomMembers` | 一致 | |
| `blockChatRoomMembers` | ChatRoomManager | `blockChatRoomMembers` | `ChatroomManager.blockChatroomMembers` | 一致 | |
| `unBlockChatRoomMembers` | ChatRoomManager | `unBlockChatRoomMembers` | `ChatroomManager.unblockChatroomMembers` | 一致 | |
| `fetchChatRoomBlockList` | ChatRoomManager | `fetchChatRoomBlockList` | `ChatroomManager.fetchChatroomBlocklist` | 一致 | |
| `updateChatRoomAnnouncement` | ChatRoomManager | `updateChatRoomAnnouncement` | `ChatroomManager.changeChatroomAnnouncement` | 一致 | |
| `fetchChatRoomAnnouncement` | ChatRoomManager | `fetchChatRoomAnnouncement` | `ChatroomManager.fetchChatroomAnnouncement` | 一致 | |
| `addMembersToChatRoomWhiteList` | ChatRoomManager | `addMembersToChatRoomAllowList` | `ChatroomManager.addToChatroomWhitelist` | 一致 | |
| `removeMembersFromChatRoomWhiteList` | ChatRoomManager | `removeMembersFromChatRoomAllowList` | `ChatroomManager.removeFromChatroomWhitelist` | 一致 | |
| `fetchChatRoomWhiteListFromServer` | ChatRoomManager | `fetchChatRoomAllowListFromServer` | `ChatroomManager.fetchChatroomWhitelist` | 一致 | |
| `isMemberInChatRoomWhiteListFromServer` | ChatRoomManager | `isMemberInChatRoomAllowList` | `ChatroomManager.checkIfInWhitelist` | 一致 | |
| `muteAllChatRoomMembers` | ChatRoomManager | `muteAllChatRoomMembers` | `ChatroomManager.muteAllMembers` | 一致 | |
| `unMuteAllChatRoomMembers` | ChatRoomManager | `unMuteAllChatRoomMembers` | `ChatroomManager.unmuteAllMembers` | 一致 | |
| `fetchChatRoomAttributes` | ChatRoomManager | `fetchChatRoomAttributes` | `ChatroomManager.fetchChatroomAttributes` | 一致 | |
| `setChatRoomAttributes` | ChatRoomManager | `addAttributes` | `ChatroomManager.setChatroomAttributes(SetChatroomAttributeParams)` | 一致 | 失败 key 列表：`Map<String,int>`→`ChatroomAttributesResult` |
| `removeChatRoomAttributes` | ChatRoomManager | `removeAttributes` | `ChatroomManager.removeChatroomAttributes(RemoveChatroomAttributeParams)` | 一致 | 同上 |
| `isMemberInChatRoomMuteList` | ChatRoomManager | `isMemberInChatRoomMuteList` | `ChatroomManager.checkIfInMutelist` | 一致 | |

### 6.2 事件（容器 key `onChatRoomChanged`，16 个 type 子事件 → ChatroomListener）

常量名 `chatRoomChange` ≠ 值 `onChatRoomChanged`，以值为准。

| type 值 | Flutter 事件常量 | chatsdk 1.15.0 对应 | 分类 | 备注 |
|---|---|---|---|---|
| `onRoomDestroyed` | `ChatRoomEvent.ON_CHAT_ROOM_DESTROYED` | `ChatroomListener.onRemovedFromChatroom(reason)` | 签名差异 | chatsdk 无独立销毁回调，需按 `LEAVE_REASON.ROOM_DESTROYED` 从 onRemovedFromChatroom 分发 |
| `onRoomMemberJoined` | `ON_MEMBER_JOINED` | `ChatroomListener.onMemberJoined` | 一致 | |
| `onRoomMemberExited` | `ON_MEMBER_EXITED` | `ChatroomListener.onMemberExited` | 一致 | |
| `onRoomRemoved` | `ON_REMOVED_FROM_CHAT_ROOM` | `ChatroomListener.onRemovedFromChatroom(reason)` | 签名差异 | 需按 `LEAVE_REASON.BE_KICK` 分发；`BE_KICKED_FOR_OFFLINE` 在 Flutter 侧无对应事件 |
| `onRoomMuteListAdded` | `ON_MUTE_LIST_ADDED` | `ChatroomListener.onMutelistAdded` / `onMuteMapAdded` | 一致 | |
| `onRoomMuteListRemoved` | `ON_MUTE_LIST_REMOVED` | `ChatroomListener.onMutelistRemoved` | 一致 | |
| `onRoomAdminAdded` | `ON_ADMIN_ADDED` | `ChatroomListener.onAdminAdded` | 一致 | |
| `onRoomAdminRemoved` | `ON_ADMIN_REMOVED` | `ChatroomListener.onAdminRemoved` | 一致 | |
| `onRoomOwnerChanged` | `ON_OWNER_CHANGED` | `ChatroomListener.onOwnerChanged` | 一致 | |
| `onRoomAnnouncementChanged` | `ON_ANNOUNCEMENT_CHANGED` | `ChatroomListener.onAnnouncementChanged` | 一致 | |
| `onRoomWhiteListRemoved` | `ON_WHITE_LIST_REMOVED` | `ChatroomListener.onWhitelistRemoved` | 一致 | |
| `onRoomWhiteListAdded` | `ON_WHITE_LIST_ADDED` | `ChatroomListener.onWhitelistAdded` | 一致 | |
| `onRoomAllMemberMuteStateChanged` | `ON_ALL_MEMBER_MUTE_STATE_CHANGED` | `ChatroomListener.onAllMemberMuteStateChanged` | 一致 | |
| `onRoomSpecificationChanged` | `ON_SPECIFICATION_CHANGED` | `ChatroomListener.onSpecificationChanged` | 一致 | |
| `onRoomAttributesDidUpdated` | `ON_ATTRIBUTES_UPDATED` | `ChatroomListener.onAttributesUpdate` | 一致 | |
| `onRoomAttributesDidRemoved` | `ON_ATTRIBUTES_REMOVED` | `ChatroomListener.onAttributesRemoved` | 一致 | |

## 7. chat_group_manager（`com.chat.im/chat_group_manager`）

### 7.1 方法（55）

| Flutter key | Manager | Dart 公开方法 | chatsdk 1.15.0 对应 | 分类 | 备注 |
|---|---|---|---|---|---|
| `getGroupWithId` | ChatGroupManager | `getGroupWithId` | `GroupManager.getGroup` | 一致 | |
| `getJoinedGroups` | ChatGroupManager | `getJoinedGroups` | `GroupManager.getAllGroups` | 一致 | |
| `getJoinedGroupsFromServer` | ChatGroupManager | `fetchJoinedGroupsFromServer` | `GroupManager.fetchJoinedGroupsFromServer(pageNum, pageSize)` | 签名差异 | Flutter 的 `needMemberCount`/`needRole` 参数在 chatsdk 无对应 |
| `getPublicGroupsFromServer` | ChatGroupManager | `fetchPublicGroupsFromServer` | `GroupManager.fetchPublicGroupsFromServer(pageSize, cursor?)` | 签名差异 | Flutter 返回轻量 `ChatCursorResult<ChatGroupInfo>`，chatsdk 返回 `CursorResult<Group>`（完整群对象），结构需裁剪 |
| `createGroup` | ChatGroupManager | `createGroup` | `GroupManager.createGroup(GroupOptions)` | 一致 | `ChatGroupOptions`→`GroupOptions` 字段映射 |
| `getGroupSpecificationFromServer` | ChatGroupManager | `fetchGroupInfoFromServer` | `GroupManager.fetchGroupFromServer` | 一致 | 不含成员；Flutter 的 `fetchMembers` 参数已 Deprecated |
| `getGroupMemberListFromServer` | ChatGroupManager | `fetchMemberListFromServer` | `GroupManager.fetchGroupMembers` | 一致 | |
| `getGroupBlockListFromServer` | ChatGroupManager | `fetchBlockListFromServer` | `GroupManager.fetchGroupBlocklist` | 一致 | |
| `getGroupMuteListFromServer` | ChatGroupManager | `fetchMuteListFromServer` | `GroupManager.fetchGroupMutelist` | 一致 | |
| `getGroupWhiteListFromServer` | ChatGroupManager | `fetchAllowListFromServer` | `GroupManager.fetchGroupWhitelist` | 一致 | |
| `isMemberInWhiteListFromServer` | ChatGroupManager | `isMemberInAllowListFromServer` | `GroupManager.checkIfInGroupWhitelist` | 一致 | |
| `getGroupFileListFromServer` | ChatGroupManager | `fetchGroupFileListFromServer` | `GroupManager.fetchGroupSharedFileList` | 一致 | |
| `getGroupAnnouncementFromServer` | ChatGroupManager | `fetchAnnouncementFromServer` | `GroupManager.fetchGroupAnnouncement` | 一致 | |
| `addMembers` | ChatGroupManager | `addMembers` | `GroupManager.addUsersToGroup` | 一致 | |
| `inviterUser` | ChatGroupManager | `inviterUser` | `GroupManager.inviteUsers` | 一致 | |
| `removeMembers` | ChatGroupManager | `removeMembers` | `GroupManager.removeUsersFromGroup` | 一致 | |
| `blockMembers` | ChatGroupManager | `blockMembers` | `GroupManager.blockUsers` | 一致 | |
| `unblockMembers` | ChatGroupManager | `unblockMembers` | `GroupManager.unblockUsers` | 一致 | |
| `updateGroupSubject` | ChatGroupManager | `updateGroupName`；`changeGroupName`（Deprecated） | `GroupManager.changeGroupName` | 一致 | 一 key 两方法 |
| `updateDescription` | ChatGroupManager | `updateGroupDesc`；`changeGroupDescription`（Deprecated） | `GroupManager.changeGroupDescription` | 一致 | 一 key 两方法 |
| `leaveGroup` | ChatGroupManager | `leaveGroup` | `GroupManager.leaveGroup` | 一致 | |
| `destroyGroup` | ChatGroupManager | `destroyGroup` | `GroupManager.destroyGroup` | 一致 | |
| `blockGroup` | ChatGroupManager | `blockGroup` | `GroupManager.blockGroupMessage` | 一致 | |
| `unblockGroup` | ChatGroupManager | `unblockGroup` | `GroupManager.unblockGroupMessage` | 一致 | |
| `updateGroupOwner` | ChatGroupManager | `changeOwner` | `GroupManager.changeOwner` | 一致 | |
| `addAdmin` | ChatGroupManager | `addAdmin` | `GroupManager.addGroupAdmin` | 一致 | |
| `removeAdmin` | ChatGroupManager | `removeAdmin` | `GroupManager.removeGroupAdmin` | 一致 | |
| `muteMembers` | ChatGroupManager | `muteMembers` | `GroupManager.muteGroupMembers` | 一致 | |
| `unMuteMembers` | ChatGroupManager | `unMuteMembers` | `GroupManager.unmuteGroupMembers` | 一致 | |
| `muteAllMembers` | ChatGroupManager | `muteAllMembers` | `GroupManager.muteAllMembers` | 一致 | |
| `unMuteAllMembers` | ChatGroupManager | `unMuteAllMembers` | `GroupManager.unmuteAllMembers` | 一致 | |
| `addWhiteList` | ChatGroupManager | `addAllowList` | `GroupManager.addToGroupWhitelist` | 一致 | |
| `removeWhiteList` | ChatGroupManager | `removeAllowList` | `GroupManager.removeFromGroupWhitelist` | 一致 | |
| `uploadGroupSharedFile` | ChatGroupManager | `uploadGroupSharedFile` | `GroupManager.uploadGroupSharedFile` | 一致 | 进度经 callback 桥接 |
| `downloadGroupSharedFile` | ChatGroupManager | `downloadGroupSharedFile` | `GroupManager.downloadGroupSharedFile` | 一致 | 同上 |
| `removeGroupSharedFile` | ChatGroupManager | `removeGroupSharedFile` | `GroupManager.deleteGroupSharedFile` | 一致 | |
| `updateGroupAnnouncement` | ChatGroupManager | `updateGroupAnnouncement` | `GroupManager.updateGroupAnnouncement` | 一致 | |
| `updateGroupExt` | ChatGroupManager | `updateGroupExtension` | `GroupManager.updateGroupExtension` | 一致 | |
| `joinPublicGroup` | ChatGroupManager | `joinPublicGroup` | `GroupManager.joinGroup` | 一致 | |
| `requestToJoinPublicGroup` | ChatGroupManager | `requestToJoinPublicGroup` | `GroupManager.applyJoinToGroup` | 一致 | |
| `acceptJoinApplication` | ChatGroupManager | `acceptJoinApplication` | `GroupManager.acceptApplication` | 一致 | |
| `declineJoinApplication` | ChatGroupManager | `declineJoinApplication` | `GroupManager.declineApplication` | 一致 | |
| `acceptInvitationFromGroup` | ChatGroupManager | `acceptInvitation` | `GroupManager.acceptInvitation(groupId)` | 一致 | chatsdk 无 inviter 参数 |
| `declineInvitationFromGroup` | ChatGroupManager | `declineInvitation` | `GroupManager.declineInvitation(groupId, reason?)` | 一致 | 同上 |
| `setMemberAttributesFromGroup` | ChatGroupManager | `setMemberAttributes` | `GroupManager.setMemberAttributes` | 一致 | |
| `removeMemberAttributesFromGroup` | ChatGroupManager | `removeMemberAttributes` | — | 缺失 | chatsdk GroupManager 无删除成员自定义属性接口 |
| `fetchMemberAttributesFromGroup` | ChatGroupManager | `fetchMemberAttributes` | `GroupManager.fetchMemberAttributes` | 一致 | |
| `fetchMembersAttributesFromGroup` | ChatGroupManager | `fetchMembersAttributes` | `GroupManager.fetchMembersAttributes` | 一致 | |
| `fetchJoinedGroupCount` | ChatGroupManager | `fetchJoinedGroupCount` | `GroupManager.fetchJoinedGroupsCount` | 一致 | |
| `isMemberInGroupMuteList` | ChatGroupManager | `isMemberInGroupMuteList` | `GroupManager.checkIfInGroupMutelist` | 一致 | |
| `clearAllGroupsFromDB` | ChatGroupManager | `clearAllGroupsFromLocal` | `GroupManager.clearAllLocalGroups` | 一致 | |
| `fetchGroupMembersInfo` | ChatGroupManager | `fetchGroupMembersInfo` | `GroupManager.fetchGroupMemberDetails` | 一致 | `GroupMemberInfo`→`GroupMember` |
| `updateGroupAvatar` | ChatGroupManager | `updateGroupAvatar` | `GroupManager.changeGroupAvatar` | 一致 | |
| `updateGroupNamecard` | ChatGroupManager | `updateGroupNamecard` | `GroupManager.updateGroupNamecard` | 一致 | |
| `getGroupNamecard` | ChatGroupManager | `getGroupNamecard` | `GroupManager.getGroupNamecard` | 一致 | chatsdk 为同步本地缓存读取 |

### 7.2 事件（容器 key `onGroupChanged`，26 个 type 子事件 → GroupListener）

| type 值 | Flutter 事件常量 | chatsdk 1.15.0 对应 | 分类 | 备注 |
|---|---|---|---|---|
| `onGroupInvitationReceived` | `ChatGroupChangeEvent.ON_INVITATION_RECEIVED` | `GroupListener.onInvitationReceived` | 一致 | |
| `onGroupInvitationAccepted` | `ON_INVITATION_ACCEPTED` | `GroupListener.onInvitationAccepted` | 一致 | |
| `onGroupInvitationDeclined` | `ON_INVITATION_DECLINED` | `GroupListener.onInvitationDeclined` | 一致 | |
| `onGroupAutoAcceptInvitation` | `ON_AUTO_ACCEPT_INVITATION` | `GroupListener.onAutoAcceptInvitationFromGroup` | 一致 | |
| `onGroupUserRemoved` | `ON_USER_REMOVED` | `GroupListener.onUserRemoved` | 一致 | |
| `onGroupRequestToJoinReceived` | `ON_REQUEST_TO_JOIN_RECEIVED` | `GroupListener.onRequestToJoinReceived` | 一致 | |
| `onGroupRequestToJoinDeclined` | `ON_REQUEST_TO_JOIN_DECLINED` | `GroupListener.onRequestToJoinDeclined` | 一致 | |
| `onGroupRequestToJoinAccepted` | `ON_REQUEST_TO_JOIN_ACCEPTED` | `GroupListener.onRequestToJoinAccepted` | 一致 | |
| `onGroupDestroyed` | `ON_GROUP_DESTROYED` | `GroupListener.onGroupDestroyed` | 一致 | |
| `onGroupMuteListAdded` | `ON_MUTE_LIST_ADDED` | `GroupListener.onMutelistAdded` | 一致 | |
| `onGroupMuteListRemoved` | `ON_MUTE_LIST_REMOVED` | `GroupListener.onMutelistRemoved` | 一致 | |
| `onGroupAdminAdded` | `ON_ADMIN_ADDED` | `GroupListener.onAdminAdded` | 一致 | |
| `onGroupAdminRemoved` | `ON_ADMIN_REMOVED` | `GroupListener.onAdminRemoved` | 一致 | |
| `onGroupOwnerChanged` | `ON_OWNER_CHANGED` | `GroupListener.onOwnerChanged` | 一致 | |
| `onGroupMemberJoined` | `ON_MEMBER_JOINED` | `GroupListener.onMemberJoined` / `onMembersJoined` | 一致 | chatsdk 区分单人/多人两个回调，统一桥接到同一事件 |
| `onGroupMemberExited` | `ON_MEMBER_EXITED` | `GroupListener.onMemberExited` / `onMembersExited` | 一致 | 同上 |
| `onGroupAnnouncementChanged` | `ON_ANNOUNCEMENT_CHANGED` | `GroupListener.onAnnouncementChanged` | 一致 | |
| `onGroupSharedFileAdded` | `ON_SHARED_FILE_ADDED` | `GroupListener.onSharedFileAdded` | 一致 | |
| `onGroupSharedFileDeleted` | `ON_SHARED_FILE__DELETED` | `GroupListener.onSharedFileDeleted` | 一致 | Flutter 常量名双下划线为笔误，以值为准 |
| `onGroupWhiteListRemoved` | `ON_WHITE_LIST_REMOVED` | `GroupListener.onWhitelistRemoved` | 一致 | |
| `onGroupWhiteListAdded` | `ON_WHITE_LIST_ADDED` | `GroupListener.onWhitelistAdded` | 一致 | |
| `onGroupAllMemberMuteStateChanged` | `ON_ALL_MEMBER_MUTE_STATE_CHANGED` | `GroupListener.onAllMemberMuteStateChanged` | 一致 | |
| `onGroupSpecificationDidUpdate` | `ON_SPECIFICATION_DID_UPDATE` | `GroupListener.onSpecificationChanged` | 一致 | |
| `onGroupStateChanged` | `ON_STATE_CHANGED` | `GroupListener.onStateChanged` | 一致 | |
| `onGroupAttributesChangedOfMember` | `ON_ATTRIBUTES_CHANGED_OF_MEMBER` | `GroupListener.onGroupMemberAttributeChanged` | 一致 | |
| `onUserGroupNamecardChanged` | `ON_USER_GROUP_NAMECARD_CHANGED` | `GroupListener.onUserGroupNamecardUpdated` | 一致 | |

## 8. chat_push_manager（`com.chat.im/chat_push_manager`）

### 8.1 方法（22）

| Flutter key | Manager | Dart 公开方法 | chatsdk 1.15.0 对应 | 分类 | 备注 |
|---|---|---|---|---|---|
| `getImPushConfig` | ChatPushManager | 无引用（孤儿常量） | — | 缺失 | chatsdk 无推送配置本地读取接口 |
| `getImPushConfigFromServer` | ChatPushManager | `fetchPushConfigsFromServer` | — | 缺失 | chatsdk 无推送配置（`ChatPushConfigs`）拉取接口 |
| `updateImPushStyle` | ChatPushManager | `updatePushDisplayStyle` | `PushManager.updatePushDisplayStyle` | 一致 | `DisplayStyle`→`PushDisplayStyle` |
| `updatePushNickname` | ChatPushManager | `updatePushNickname` | `PushManager.updatePushNickname` | 一致 | |
| `updateHMSPushToken` | ChatPushManager | `updateHMSPushToken`（Deprecated） | `PushManager.uploadPushToken(token, certName)` | 签名差异 | chatsdk 必须传 certName，Flutter 该方法只有 token；方法本身已 Deprecated |
| `updateFCMPushToken` | ChatPushManager | `updateFCMPushToken`（Deprecated） | — | 缺失 | FCM 在鸿蒙平台不适用 |
| `updateAPNsPushToken` | ChatPushManager | `updateAPNsDeviceToken`（Deprecated） | — | 缺失 | APNs 在鸿蒙平台不适用 |
| `reportPushAction` | ChatPushManager | 无引用（孤儿常量） | — | 缺失 | chatsdk 无推送行为上报接口（`notifyPushResult` 为内部方法，不纳入） |
| `setConversationSilentMode` | ChatPushManager | `setConversationSilentMode` | `PushManager.setSilentModeForConversation(conversationId, type, pushRemindType)` | 签名差异 | Flutter 的 `ChatSilentModeParam` 支持时段/时长设置，chatsdk 会话级仅支持 `PushRemindType`；时段免打扰仅全局级（`SilentModeParam`）可用 |
| `removeConversationSilentMode` | ChatPushManager | `removeConversationSilentMode` | `PushManager.clearRemindTypeForConversation` | 一致 | |
| `fetchConversationSilentMode` | ChatPushManager | `fetchConversationSilentMode` | `PushManager.getSilentModeForConversation` | 一致 | |
| `setSilentModeForAll` | ChatPushManager | `setSilentModeForAll` | `PushManager.setSilentModeForAll` | 一致 | |
| `fetchSilentModeForAll` | ChatPushManager | `fetchSilentModeForAll` | `PushManager.getSilentModeForAll` | 一致 | |
| `fetchSilentModeForConversations` | ChatPushManager | `fetchSilentModeForConversations` | `PushManager.getSilentModeForConversations` | 一致 | |
| `setPreferredNotificationLanguage` | ChatPushManager | `setPreferredNotificationLanguage` | — | 缺失 | chatsdk 无推送语言设置接口 |
| `fetchPreferredNotificationLanguage` | ChatPushManager | `fetchPreferredNotificationLanguage` | — | 缺失 | 同上 |
| `setPushTemplate` | ChatPushManager | `setPushTemplate` | `PushManager.setPushTemplate` | 一致 | |
| `getPushTemplate` | ChatPushManager | `getPushTemplate` | `PushManager.getPushTemplate` | 一致 | |
| `syncSilentModels` | ChatPushManager | `syncConversationsSilentMode` | `PushManager.syncConversationsSilentModeFromServer` | 一致 | |
| `bindDeviceToken` | ChatPushManager | `bindDeviceToken` | `PushManager.uploadPushToken(token, certName)` | 一致 | deviceToken→token、notifierName→certName |
| `bindPushKitToken` | ChatPushManager | `bindPushKitToken` | — | 缺失 | PushKit 为 iOS 专用能力（Android 侧路由亦直接报 unsupported），鸿蒙推送 token 走 `uploadPushToken` |
| `unbindPushKitToken` | ChatPushManager | `unbindPushKitToken` | — | 缺失 | 同上（chatsdk `unbindPushToken(certName)` 对应的是设备推送 token 解绑，语义不同） |

## 9. chat_userInfo_manager（`com.chat.im/chat_userInfo_manager`）

channel 名中 `userInfo` 大写 I 有意保留，勿改。

### 9.1 方法（8）

| Flutter key | Manager | Dart 公开方法 | chatsdk 1.15.0 对应 | 分类 | 备注 |
|---|---|---|---|---|---|
| `updateOwnUserInfo` | ChatUserInfoManager | `updateUserInfo` | `UserInfoManager.updateUserInfo`（重载1，`UserInfo` 对象） | 一致 | |
| `updateOwnUserInfoWithType` | ChatUserInfoManager | 无引用（孤儿常量） | `UserInfoManager.updateUserInfo`（重载2，按属性类型） | 一致 | 孤儿常量，能力存在 |
| `fetchUserInfoById` | ChatUserInfoManager | `fetchUserInfoById`；`fetchOwnInfo` 内部也走此 key | `UserInfoManager.fetchUserInfoById(userId, attribute?)` | 签名差异 | 一 key 两方法；Flutter 的 `expireTime` 参数无对应，chatsdk 第二参数是 `attribute`（属性过滤），参数集不同 |
| `fetchUserInfoByIdWithType` | ChatUserInfoManager | 无引用（孤儿常量） | `UserInfoManager.fetchUserInfoById(userId, attribute)` | 一致 | 孤儿常量；chatsdk 的 attribute 参数正好对应"按类型获取" |
| `subscribeUsersInfo` | ChatUserInfoManager | `subscribeUsersInfo` | `UserInfoManager.subscribeUsersInfo` | 一致 | |
| `unsubscribeUsersInfo` | ChatUserInfoManager | `unsubscribeUsersInfo` | `UserInfoManager.unsubscribeUsersInfo` | 一致 | |
| `fetchSubscribedUsers` | ChatUserInfoManager | `fetchSubscribedUsers` | `UserInfoManager.fetchSubscribedUsers` | 一致 | |
| `getLocalUserInfoByIds` | ChatUserInfoManager | `getLocalUserInfoByIds` | `UserInfoManager.getUserInfoById` | 一致 | |

### 9.2 事件（容器 key `onUserInfoChanged`，2 个 type 子事件 → UserInfoListener）

| type 值 | Flutter 事件常量 | chatsdk 1.15.0 对应 | 分类 | 备注 |
|---|---|---|---|---|
| `onSelfUserInfoUpdate` | `ChatUserInfoChangeEvent.ON_SELF_USER_INFO_UPDATE` | `UserInfoListener.onSelfUserInfoUpdate` | 一致 | |
| `onUserInfoUpdate` | `ON_USER_INFO_UPDATE` | `UserInfoListener.onUserInfoUpdate` | 一致 | |

## 10. chat_presence_manager（`com.chat.im/chat_presence_manager`）

### 10.1 方法（5）

| Flutter key | Manager | Dart 公开方法 | chatsdk 1.15.0 对应 | 分类 | 备注 |
|---|---|---|---|---|---|
| `publishPresenceWithDescription` | ChatPresenceManager | `publishPresence` | `PresenceManager.publishPresence` | 一致 | 常量名 `presenceWithDescription` ≠ 值，以值为准 |
| `presenceSubscribe` | ChatPresenceManager | `subscribe` | `PresenceManager.subscribePresences` | 一致 | |
| `presenceUnsubscribe` | ChatPresenceManager | `unsubscribe` | `PresenceManager.unsubscribePresences` | 一致 | |
| `fetchSubscribedMembersWithPageNum` | ChatPresenceManager | `fetchSubscribedMembers` | `PresenceManager.fetchSubscribedMembers` | 一致 | |
| `fetchPresenceStatus` | ChatPresenceManager | `fetchPresenceStatus` | `PresenceManager.fetchPresenceStatus` | 一致 | |

### 10.2 事件（1）

| Flutter key | Dart 事件处理器 | chatsdk 1.15.0 对应 | 分类 | 备注 |
|---|---|---|---|---|
| `onPresenceStatusChanged` | `ChatPresenceEventHandler.onPresenceStatusChanged` | `PresenceListener.onPresenceUpdated` | 一致 | |

## 11. chat_thread_manager（`com.chat.im/chat_thread_manager`）

**chatsdk 1.15.0 无 ChatThreadManager（子区）**：`Index.d.ets` 未导出任何 Thread 相关模块。以下 12 个方法 key 与 4 个事件 key 全部**缺失**。关联缺失还有：`getThreadConversation`（chat_manager）、`chatThread`（chat_message）、`onMultiDeviceThreadEvent`（chat_client），见结构性差异 1。

### 11.1 方法（12，全部缺失）

| Flutter key | Dart 公开方法 | 分类 |
|---|---|---|
| `fetchChatThreadDetail` | `ChatThreadManager.fetchChatThread` | 缺失 |
| `fetchJoinedChatThreads` | `ChatThreadManager.fetchJoinedChatThreads` | 缺失 |
| `fetchChatThreadsWithParentId` | `ChatThreadManager.fetchChatThreadsWithParentId` | 缺失 |
| `fetchJoinedChatThreadsWithParentId` | `ChatThreadManager.fetchJoinedChatThreadsWithParentId` | 缺失 |
| `fetchChatThreadMember` | `ChatThreadManager.fetchChatThreadMembers` | 缺失 |
| `fetchLastMessageWithChatThreads` | `ChatThreadManager.fetchLatestMessageWithChatThreads` | 缺失 |
| `removeMemberFromChatThread` | `ChatThreadManager.removeMemberFromChatThread` | 缺失 |
| `updateChatThreadSubject` | `ChatThreadManager.updateChatThreadName` | 缺失 |
| `createChatThread` | `ChatThreadManager.createChatThread` | 缺失 |
| `joinChatThread` | `ChatThreadManager.joinChatThread` | 缺失 |
| `leaveChatThread` | `ChatThreadManager.leaveChatThread` | 缺失 |
| `destroyChatThread` | `ChatThreadManager.destroyChatThread` | 缺失 |

### 11.2 事件（4，全部缺失）

| Flutter key | Dart 事件处理器 | 分类 |
|---|---|---|
| `onChatThreadCreate` | `ChatThreadEventHandler.onChatThreadCreate` | 缺失 |
| `onChatThreadUpdate` | `ChatThreadEventHandler.onChatThreadUpdate` | 缺失 |
| `onChatThreadDestroy` | `ChatThreadEventHandler.onChatThreadDestroy` | 缺失 |
| `onUserKickOutOfChatThread` | `ChatThreadEventHandler.onUserKickOutOfChatThread` | 缺失 |

## 12. file_progress_manager（`com.chat.im/file_progress_manager`）

Flutter 4.25.0 侧该 channel **无任何方法/事件 key**（`ChatMethodKeys` 中无常量使用它），仅为原生侧下载进度回传预留的通道；附件/缩略图下载进度实际经 chat_message channel 的 `onMessageProgressUpdate` 分发。chatsdk 侧进度由 `onProgress` 回调参数与 `ChatCallback.onProgress` 承担，无独立通道概念。**无差距条目**，移植时无需为该 channel 建独立通路。

## 13. 孤儿常量专节（11 个）

以下常量在 `im_flutter_sdk/lib` 与 `im_flutter_sdk_interface/lib` 中均无引用。Android/iOS 原生 wrapper 可能仍有对应实现分支，**需用户确认是否在鸿蒙侧移植**。

| 常量 | 字符串值 | 所属 channel | chatsdk 对应 | 分类 | 建议 |
|---|---|---|---|---|---|
| `loginWithAgoraToken` | `loginWithAgoraToken` | chat_client | — | 缺失 | chatsdk 无 Agora token 登录，建议不移植 |
| `uploadLog` | `uploadLog` | chat_client | `ChatClient.uploadLog` | 一致 | chatsdk 有能力，建议补移植（Dart 侧从未调用过） |
| `onMessageChanged` | `onMessageChanged` | chat_manager | `ChatMessageListener.onMessageChanged` | 一致 | chatsdk 有回调；Flutter 侧消息变更实际走 `onMessageContentChanged`，可不接 |
| `onMessageReadAck` | `onMessageReadAck` | chat_message | — | 缺失 | chatsdk 无消息级独立已读 ack 回调 |
| `onMessageDeliveryAck` | `onMessageDeliveryAck` | chat_message | — | 缺失 | 同上 |
| `removeMsgFromServerWithTimeStamp` | `removeMsgFromServerWithTimeStamp` | chat_conversation | `ChatManager.removeMessagesFromServer`（重载2） | 一致 | 4.8.1 起被 `conversationDeleteServerMessageWithTime` 替代，建议不移植 |
| `getAllChatRooms` | `getAllChatRooms` | chat_room_manager | — | 缺失 | chatsdk 无本地聊天室缓存 |
| `getImPushConfig` | `getImPushConfig` | chat_push_manager | — | 缺失 | chatsdk 无推送配置读取 |
| `reportPushAction` | `reportPushAction` | chat_push_manager | — | 缺失 | chatsdk 无推送行为上报 |
| `updateOwnUserInfoWithType` | `updateOwnUserInfoWithType` | chat_userInfo_manager | `UserInfoManager.updateUserInfo`（重载2） | 一致 | 能力存在，可补移植 |
| `fetchUserInfoByIdWithType` | `fetchUserInfoByIdWithType` | chat_userInfo_manager | `UserInfoManager.fetchUserInfoById(attribute)` | 一致 | 能力存在，可补移植 |

## 14. 已确认的结构性差异

1. **无 ChatThreadManager（子区）**：chatsdk 1.15.0 未导出任何 Thread 模块。影响面：chat_thread_manager channel 全部 12 方法 + 4 事件，外加 `getThreadConversation`（chat_manager）、`chatThread`（chat_message）、`onMultiDeviceThreadEvent`（chat_client）——共 **19 个 key 缺失**。Flutter 侧 `ChatConversationType.Thread`、`ChatThread` 模型、`ChatThreadEventHandler` 在鸿蒙均无落点。
2. **无独立 ConversationManager**：chat_conversation channel 的 26 个方法 key 映射到 chatsdk `Conversation` 类（24 个）与 `ChatManager.removeMessagesFromServer`（2 个）。除 `deleteMessagesWithTs`（缺失）与 `deleteMessageByIds`（签名差异）外全部可对齐。
3. **事件分发机制差异**：Flutter 的 4 个容器事件 key（`onContactChanged`/`onChatRoomChanged`/`onGroupChanged`/`onUserInfoChanged`）+ `type` 字段二次分发，在 chatsdk 中对应 4 个 Listener 的独立回调（一回调对一 type），适配层做"多回调 → 单 channel 事件 + type"的聚合。

## 15. 映射中发现的意外问题

1. **01 盘点文档内部统计不一致**：`01-flutter-api-surface.md` 头部统计 319 常量（271 方法 + 48 事件）。经逐行清点：表格总行数确为 319，但构成是 270 方法 + 49 事件 key（与头部 271+48 差 1，一个 key 的归类差异）；另外 2.8 节头部写"36 方法"而表格实际 32 个方法行，2.9 节头部写"47 方法"而表格实际 49 个方法行。本 ledger 以表格逐行为准。
2. **`bindPushKitToken`/`unbindPushKitToken` 是 iOS 专用能力**：Android wrapper（`PushManagerWrapper.java`）中这两个路由直接返回 unsupported，注释明确 "PushKit is an iOS-only capability"。鸿蒙 chatsdk 亦无 PushKit 概念，建议鸿蒙侧同样报 unsupported 或按华为 Push Kit 场景改走 `uploadPushToken`，需用户决策。
3. **`getCurrentDeviceId` 的 Android 实现不经过 IM SDK**：wrapper 自行用 `DeviceUuidFactory` 生成设备 UUID（deviceName/resource 恒为空字符串）。chatsdk `ChatOptions.getDeviceUuid` 语义最接近，但 deviceName/resource 字段无来源。
4. **聊天室能力缺口比预期大**：chatsdk `ChatroomManager` 无创建/解散聊天室、无单个聊天室详情拉取（服务端或本地缓存均无），加入后只能依赖 `joinChatroom` 的返回值持有房间信息。
5. **`PushListener` 在 Flutter 侧无对应**：chatsdk 推送 token 绑定结果经 `PushListener.onBindTokenSuccess`/`onError` 回调（且两个回调均必选），而 Flutter 侧 push 完全走方法调用返回值，无 push 事件。适配层需把该 Listener 内部消化（转成 Promise 成败）。
6. **`resendMessage` 与 `reportMessage` 在 chatsdk 无任何形式的对应**（Android/iOS 原生 SDK 有），属于 chatsdk 能力缺口而非命名差异。

## 16. 用户确认清单（2026-11-12 已全部确认，结论见 §16.1 与 §17）

以下聚拢全部**签名差异**与**缺失**条目（已按家族合并相关项），每条一句话说明影响。编号按 channel 分组。2026-11-12 用户逐项确认完毕，最终处置结论见 §16.1（签名差异）与 §17（缺失 → Dart 移除清单）。

### A. 签名差异（16 项）

1. 【chat_client】`init`：chatsdk 需注入 UIAbility Context，且 Flutter `ChatOptions` 的推送证书类字段无鸿蒙对应——需确认 ChatOptions 字段映射口径。
2. 【chat_client】`changeAppKey`/`changeAppId`：chatsdk 同步返回 `ChatError` 且仅未登录态可用，与 Flutter `Future<bool>` 语义不同——需确认返回转换与调用时序约束。
3. 【chat_client】`isLoggedInBefore`：仅有语义近似的 `isAutoLogin`（Promise），"曾登录过"与"自动登录状态"不完全等同 ⚠️——需实测确认能否替代。
4. 【chat_client 事件】7 个登出原因回调（`onUserDidLoginFromOtherDevice`/`onUserDidRemoveFromServer`/`onUserDidForbidByServer`/`onUserDidChangePassword`/`onUserDidLoginTooManyDevice`/`onUserKickedByOtherDevice`/`onUserAuthenticationFailed`）：需经 `ConnectionListener.onLogout`/`onDisconnected` 的 errorCode 二次分发，chatsdk 错误码是否覆盖全部 7 种原因未证实 ⚠️——需核对错误码清单。
5. 【chat_manager】`sendMessage`：chatsdk 为 `void` + `setMessageStatusCallback` 模式，与 Flutter `Future<ChatMessage>` + channel 事件模式不同——需确认桥接方案。
6. 【chat_manager】`getUnreadMessageCount`：chatsdk 无聚合未读数接口，需遍历会话求和——需确认是否接受该近似实现。
7. 【chat_manager】`downloadMessageAttachmentInCombine`/`downloadMessageThumbnailInCombine`：无合并消息内附件专用下载接口，需先解析合并消息再对子消息下载——需确认该两步方案是否满足行为预期。
8. 【chat_manager】`fetchConversationsFromServerWithPage`（Deprecated）：pageNum 分页 vs chatsdk cursor 分页——建议不移植，需确认。
9. 【chat_conversation】`deleteMessageByIds`：chatsdk 无批量删除，需循环单条删除——需确认是否接受。
10. 【chat_room_manager】`fetchPublicChatRoomsFromServer`：chatsdk 返回 `Array<Chatroom>` 无分页总数，`ChatPageResult` 结构无法完整填充——需确认降级方式。
11. 【chat_room_manager 事件】`onRoomDestroyed`/`onRoomRemoved`：需从 `onRemovedFromChatroom(reason)` 按 `LEAVE_REASON` 分发，且 `BE_KICKED_FOR_OFFLINE` 在 Flutter 无对应事件——需确认分发规则。
12. 【chat_group_manager】`getJoinedGroupsFromServer`：`needMemberCount`/`needRole` 参数无对应——需确认是否放弃这两个参数。
13. 【chat_group_manager】`getPublicGroupsFromServer`：chatsdk 返回完整 `Group` 而非轻量 `ChatGroupInfo`——需确认裁剪方案（数据量更大）。
14. 【chat_push_manager】`updateHMSPushToken`（Deprecated）：chatsdk `uploadPushToken` 必须传 certName，Flutter 未提供——需确认 certName 来源或放弃移植。
15. 【chat_push_manager】`setConversationSilentMode`：chatsdk 会话级免打扰仅支持 `PushRemindType`，`ChatSilentModeParam` 的时段/时长设置只全局可用——需确认降级行为。
16. 【chat_userInfo_manager】`fetchUserInfoById`：Flutter 的 `expireTime` 参数无对应（chatsdk 第二参数是 attribute 属性过滤）——需确认缓存过期策略如何实现。

### B. 缺失（24 项）

17. 【chat_client】`loginWithAgoraToken`（孤儿常量）：Agora token 登录鸿蒙不支持——确认不移植。
18. 【chat_client】`compressLogs`：chatsdk 无日志压缩能力——确认不移植或降级为仅 `uploadLog`。
19. 【chat_client】`kickDevice`/`kickAllDevices`/`getLoggedInDevicesFromServer`：chatsdk 无多端设备管理 API——确认整体缺失。
20. 【chat_client】`startCallback`：Flutter 框架内部机制，chatsdk 无对应——确认 ArkTS 侧是否需要等价机制。
21. 【chat_client】`updateRoomOwnerCanLeaveSetting`：chatsdk 无此开关——确认不移植。
22. 【chat_client 事件】`onMultiDeviceThreadEvent`：无子区导致多设备子区事件缺失——并入第 27 项一并确认。
23. 【chat_client 事件】`onSendDataToFlutter`：自定义透传管道，chatsdk 无对应——确认是否保留及实现方式。
24. 【chat_client 事件】`onAppActiveNumberReachLimit`：chatsdk 无激活数超限回调——确认缺失。
25. 【chat_manager】`resendMessage`：无独立重发接口——确认以 `sendMessage` 复用实现是否可接受。
26. 【chat_manager】`deleteMessagesBeforeTimestamp`：无按时间戳删本地消息接口——确认缺失。
27. 【chat_thread_manager + 关联】整个子区能力：12 方法 + 4 事件 + `getThreadConversation` + `chatThread` + `onMultiDeviceThreadEvent`（共 19 key）全部缺失——确认鸿蒙版放弃子区功能，或等待 chatsdk 后续版本。
28. 【chat_manager】`reportMessage`：无消息举报接口——确认缺失。
29. 【chat_conversation】`deleteMessagesWithTs`：无按时间段删除本地消息接口——确认缺失。
30. 【chat_message】`chatThread`：见第 27 项。
31. 【chat_message 事件】`onMessageReadAck`/`onMessageDeliveryAck`（孤儿常量）：无消息级独立 ack 回调——确认不移植（能力由 `onMessageRead`/`onMessageDelivered` 覆盖）。
32. 【chat_room_manager】`createChatRoom`/`destroyChatRoom`：无创建/解散聊天室接口——确认缺失。
33. 【chat_room_manager】`fetchChatRoomInfoFromServer`/`getChatRoom`/`getAllChatRooms`（含 1 个孤儿常量）：无单个聊天室详情与本地缓存——确认缺失及降级方案（依赖 join 返回值）。
34. 【chat_group_manager】`removeMemberAttributesFromGroup`：无删除群成员自定义属性接口——确认缺失。
35. 【chat_push_manager】`getImPushConfig`（孤儿）/`getImPushConfigFromServer`：无推送配置读取/拉取——确认缺失。
36. 【chat_push_manager】`updateFCMPushToken`/`updateAPNsPushToken`（均 Deprecated）：FCM/APNs 鸿蒙不适用——确认不移植。
37. 【chat_push_manager】`reportPushAction`（孤儿常量）：无推送行为上报——确认不移植。
38. 【chat_push_manager】`setPreferredNotificationLanguage`/`fetchPreferredNotificationLanguage`：无推送语言设置——确认缺失。
39. 【chat_push_manager】`bindPushKitToken`/`unbindPushKitToken`：iOS 专用 PushKit 能力，鸿蒙无对应——确认鸿蒙侧报 unsupported 或改走 `uploadPushToken`。
40. 【孤儿常量】`uploadLog`/`updateOwnUserInfoWithType`/`fetchUserInfoByIdWithType`/`onMessageChanged`/`removeMsgFromServerWithTimeStamp`：chatsdk 有能力但 Flutter Dart 侧从未使用——确认是否补移植。

### C. 统计

- 待确认条目：**40 项**（签名差异 16 + 缺失/孤儿决策 24），覆盖 16 个签名差异方法 key、9 个签名差异事件项、40 个缺失方法 key、9 个缺失事件项与 11 个孤儿常量的全部处置决策。

## 16.1 确认结论（2026-11-12 用户逐项确认）

**总原则（用户定，2026-11-12）**：chatsdk 没有的能力**不在 Dart 代码中体现**——核心迁移思路是将 ios/android 的 Dart 直接迁移使用，因此缺失 API 的处理是**从 ohos 分支 Dart 代码中移除**（方法、MethodKey 常量、事件回调、关联 Model 一并清理），而非在 ArkTS 侧标记不支持；每一次移除在本清单 §17 留痕。签名差异项一律在**鸿蒙（ArkTS）层适配吸收，保证 Dart 公开 API 不修改**。

### A. 签名差异（16 项）结论

| # | 项 | 结论 |
|---|---|---|
| 1 | `init` | 接受。Context 插件层注入对 Dart 透明；`ChatOptions` 推送证书类字段鸿蒙忽略（留痕） |
| 2 | `changeAppKey`/`changeAppId` | 接受，鸿蒙层保异步语义：MethodChannel 本身异步，Dart `Future<bool>` 不变；ArkTS 执行同步调用后经 channel 回调结果（必要时 taskpool  offload 防阻塞 UI 线程），成功返 `true`、失败抛 `ChatError`；仅未登录态可调的约束保留 |
| 3 | `isLoggedInBefore` | **移除**（用户裁定：`isAutoLogin` 语义不同，不可替代；chatsdk 无其他等价接口）→ §17 |
| 4 | 7 个登出原因事件 | 接受。**鸿蒙层处理，保证 Dart 不修改**：按 `onLogout`/`onDisconnected` 的 errorCode 二次分发为 7 个事件；P2 实现时逐一对照 chatsdk 114 个错误码核对覆盖性，缺码导致某事件无法触发的单独汇报用户 |
| 5 | `sendMessage` | 接受，**对齐 android 两步语义**（用户明确）：第一步 channel 调用立即返回消息对象（android 侧 `ChatManagerWrapper.sendMessage` 即此行为），第二步发送结果经 `setMessageStatusCallback` 以 channel 事件异步送达；Dart 不修改 |
| 6 | `getUnreadMessageCount` | 接受。遍历会话求和 |
| 7 | `downloadMessageAttachmentInCombine`/`ThumbnailInCombine` | 接受。先 `downloadAndParseCombineMessage` 再对子消息下载；子消息 ID 对应关系实现时验证 |
| 8 | `fetchConversationsFromServerWithPage`（Deprecated） | **移除**（用户确认"建议合理"）→ §17 |
| 9 | `deleteMessageByIds` | **移除**（用户改判：不做循环单删适配）→ §17 |
| 10 | `fetchPublicChatRoomsFromServer` | 接受。**鸿蒙层兜底，保证 Dart 不修改**：`ChatPageResult` 结构保留，总数字段 chatsdk 无来源，按约定降级值填充 |
| 11 | `onRoomDestroyed`/`onRoomRemoved` | 接受。按 `LEAVE_REASON` 分发；`BE_KICKED_FOR_OFFLINE` 无对应事件不触发 |
| 12 | `getJoinedGroupsFromServer` | 接受。`needMemberCount`/`needRole` 参数鸿蒙忽略（留痕） |
| 13 | `getPublicGroupsFromServer` | 接受。完整 `Group` 裁剪为 `ChatGroupInfo` |
| 14 | `updateHMSPushToken`（Deprecated） | **移除**（用户确认"建议合理"）→ §17 |
| 15 | `setConversationSilentMode` | 接受。会话级仅映射 `PushRemindType`，时段/时长参数鸿蒙忽略（留痕） |
| 16 | `fetchUserInfoById` | 接受。放弃 `expireTime`，按 chatsdk 默认缓存策略 |

### B. 缺失（24 项）结论

- **转为 Dart 移除 → §17**：#17（孤儿常量清理）、#18、#19、#21、#22（事件）、#24（事件）、#26、#27（子区整体 19 key）、#28、#29、#30（并入 #27）、#31（孤儿常量清理）、#32、#33（含 1 孤儿常量）、#34、#35（含 1 孤儿常量）、#36、#37（孤儿常量清理）、#38、#39。
- **保留但特殊处理**（非 chatsdk 能力缺口，Dart 不动）：
  - #20 `startCallback`：Flutter 框架内部机制，ArkTS 侧空实现保协议。
  - #23 `onSendDataToFlutter`：自定义透传管道，保留 channel 不实现。
  - #25 `resendMessage`：保留，复用 `sendMessage` 重发同一消息对象实现（对齐 android wrapper 既有做法）。
- **记 backlog（本期不补）**：#40 五个孤儿常量 `uploadLog`/`updateOwnUserInfoWithType`/`fetchUserInfoByIdWithType`/`onMessageChanged`/`removeMsgFromServerWithTimeStamp`——chatsdk 有能力但 Flutter Dart 侧从未引用，常量保留不删，后续按需补移植。（补记 2026-11-12 T2.0：`uploadLog` 虽为孤儿常量但属现存 Dart key，ArkTS 已实现。）

> 勘误（2026-11-12 T2.0 发现）：#21 判定 chatsdk 无"聊天室所有者可退出"开关，实际 1.15.0 `ChatOptions.d.ets` 有 `allowChatroomOwnerLeave(boolean)`（`01-chatsdk-api-surface.md` §12 漏列）；仅 init 初始值可设、无运行时更新接口，**维持 `updateRoomOwnerCanLeaveSetting` 移除结论不变**，T2.0 已在 init 的 ChatOptions 映射中保留该字段（对齐 android）。

## 17. Dart 移除清单（ohos 分支，2026-11-12 确认）

本清单是 **T2.0a「Dart API 移除」的执行依据**，也是**每次例行同步（merge 主线）后必须重放的 checklist**（spec §5）。移除范围：Dart 公开方法/字段、MethodKey 常量、事件回调与事件常量、仅服务于被移除能力的 Model 与导出、example 中的调用入口、引用被移除 API 的测试。

### 方法 key（42 个）

| channel | key |
|---|---|
| chat_client（6+1 孤儿） | `isLoggedInBefore`、`compressLogs`、`kickDevice`、`kickAllDevices`、`getLoggedInDevicesFromServer`、`updateRoomOwnerCanLeaveSetting`；孤儿常量 `loginWithAgoraToken` |
| chat_manager（4） | `fetchConversationsFromServerWithPage`、`deleteMessagesBeforeTimestamp`、`reportMessage`、`getThreadConversation` |
| chat_conversation（2） | `deleteMessageByIds`、`deleteMessagesWithTs` |
| chat_message（1） | `chatThread`（常量值 `getChatThread`） |
| chat_room_manager（4+1 孤儿） | `createChatRoom`、`destroyChatRoom`、`fetchChatRoomInfoFromServer`、`getChatRoom`；孤儿常量 `getAllChatRooms` |
| chat_group_manager（1） | `removeMemberAttributesFromGroup` |
| chat_push_manager（8+2 孤儿） | `updateHMSPushToken`、`updateFCMPushToken`、`updateAPNsPushToken`、`getImPushConfigFromServer`、`setPreferredNotificationLanguage`、`fetchPreferredNotificationLanguage`、`bindPushKitToken`、`unbindPushKitToken`；孤儿常量 `getImPushConfig`、`reportPushAction` |

| channel | key（子区整体 12） |
|---|---|
| chat_thread_manager | `fetchChatThreadDetail`、`fetchJoinedChatThreads`、`fetchChatThreadsWithParentId`、`fetchJoinedChatThreadsWithParentId`、`fetchChatThreadMember`、`fetchLastMessageWithChatThreads`、`removeMemberFromChatThread`、`updateChatThreadSubject`、`createChatThread`、`joinChatThread`、`leaveChatThread`、`destroyChatThread` |

### 事件 key（8 个）

| channel | key |
|---|---|
| chat_client（2） | `onMultiDeviceThreadEvent`、`onAppActiveNumberReachLimit` |
| chat_message（2，孤儿常量） | `onMessageReadAck`、`onMessageDeliveryAck` |
| chat_thread_manager（4） | `onChatThreadCreate`、`onChatThreadUpdate`、`onChatThreadDestroy`、`onUserKickOutOfChatThread` |

### 连带移除

- `ChatThreadManager` Dart 类及其在 `ChatClient` 的 getter、主库导出；`ChatThread` 等仅服务子区的 Model；`ChatThreadEventHandler`；`ChatMessage.chatThread` getter。
- example 中子区页面/入口及所有调用被移除 API 的页面入口；引用被移除 API 的 Dart 测试同步清理。
- ohos 分支 ArkTS 侧**不实现**上述 key；`MethodKeys.ets` 以移除后的 Dart 常量集为准对齐（T2.0）。

### 不移除的缺口相关项（复述）

- `resendMessage`（复用 `sendMessage`）、`startCallback`（ArkTS 空实现）、`onSendDataToFlutter`（保留 channel 不实现）。
- backlog 孤儿常量 5 个（`uploadLog` 等）保留不删，见 §16.1-B。
