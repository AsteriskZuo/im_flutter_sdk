# 环信鸿蒙原生 SDK（@easemob/chatsdk）公开 API 盘点

> 本文档是鸿蒙 ArkTS 重写（P2）的输入之一，盘点 ohpm 包 `@easemob/chatsdk` 1.15.x 的公开 API 表面。

## 0. 版本与来源

- **包名**：`@easemob/chatsdk`（Chat SDK for HarmonyOS）
- **确切版本**：**1.15.0**（CHANGELOG 标注为 "v1.15.0 Dev 2026-8-25（开发版）"）
- **1.15.x 最新小版本**：1.15.0。截至 2026-11-12，ohpm registry（https://ohpm.openharmony.cn/ohpm/@easemob/chatsdk）上 1.15.x 仅有 1.15.0 一个版本（registry 上另有更高的 5.0.0，不在本次范围）。
- **获取方式**：`ohpm install @easemob/chatsdk@^1.15.0` 于 /tmp 临时目录，registry 可达，无阻碍。
- **盘点来源**：HAR 包内自带的 ArkTS 类型声明文件（`Index.d.ets` + `src/main/ets/**/*.d.ets`，共 60+ 个声明文件）。包为字节码 HAR（`byteCodeHar: true`，`obfuscated: true`），但声明文件完整。
- **兼容信息**：`compatibleSdkVersion: 12`，`compatibleSdkType: HarmonyOS`，含 native 组件 `libhyphenate.so`。
- **口径说明**：
  - 方法签名一律以 `.d.ets` 声明为准；JSDoc 与声明不一致之处以"⚠️"标注。
  - 仅统计公开 API：`private` 成员不列出；少数未标 `private` 但 JSDoc 注明"仅内部使用"的方法会列出并标注。
  - 数据模型类只列类名（按需求不展开字段）。
  - 重载方法在表格中分行列出，统计时按"唯一方法名（签名数）"计。

## 1. 统计汇总

| 类别 | 数量 |
|---|---|
| 导出类（class） | 54 |
| 导出接口（interface，含 11 个 Listener） | 23 |
| 导出枚举（enum） | 29 |
| 类型别名（type） | 2 |
| 公开方法总数（核心类，唯一方法名） | **约 396**（含重载签名约 410） |
| 事件回调总数（11 个 Listener/Callback 接口） | 85 |

核心类方法数明细：

| 类 | 公开方法数（唯一名） | 备注 |
|---|---|---|
| ChatClient | 30 | 另含静态字段 `VERSION` |
| ChatManager | 52 | 含重载共 57 个签名；含 1 个疑似内部方法 |
| GroupManager | 56 | |
| ChatroomManager | 30 | |
| ContactManager | 18 | |
| PushManager | 16 | 含 1 个内部方法 `notifyPushResult`；`getSilentModeForConversation` 有 2 个重载 |
| PresenceManager | 7 | |
| UserInfoManager | 9 | `updateUserInfo` 有 2 个重载 |
| Conversation | 27 | |
| ChatMessage | 66 | 9 个静态创建方法 + 57 个实例方法（含 4 个内部 setter） |
| ChatOptions | 76 | 另含 2 个构造函数重载 |
| ChatLog | 8 | 全部静态 |
| ChatError | 1（`createError`，2 个重载） | 另含 2 个构造函数重载、2 个公开字段、**114 个静态错误码常量** |

## 2. ChatClient（客户端入口）

单例类，负责初始化、登录/登出、连接管理。通过 `ChatClient.getInstance()` 获取。

| 方法 | 参数 | 返回 | 说明 |
|---|---|---|---|
| `static getInstance()` | - | `ChatClient` | 获取单例 |
| `init` | `context: Context`, `chatOptions: ChatOptions \| ChatOptionsParam` | `void` | 初始化 SDK |
| `login` | `userId: string`, `password: string` | `Promise<void>` | 密码登录 |
| `loginWithToken` | `userId: string`, `token: string` | `Promise<void>` | token 登录 |
| `logout` | `unbindToken?: boolean` | `Promise<void>` | 登出，默认解绑推送 token |
| `createAccount` | `userId: string`, `password: string` | `Promise<void>` | 创建账号（不推荐，建议 REST） |
| `changeAppkey` | `appKey: string` | `ChatError` | 更新 App Key（仅未登录态） |
| `changeAppId` | `appId: string` | `ChatError` | 更新 AppId（仅未登录态） |
| `getOptions` | - | `ChatOptions \| undefined` | 获取 SDK 配置 |
| `getContext` | - | `Context \| undefined` | 获取 Context |
| `isAutoLogin` | - | `Promise<boolean>` | 是否自动登录状态 |
| `isSdkInited` | - | `boolean` | SDK 是否已初始化 |
| `getCurrentUser` | - | `string` | 当前登录用户 ID |
| `chatManager` | - | `ChatManager \| undefined` | 获取聊天管理类 |
| `contactManager` | - | `ContactManager \| undefined` | 获取联系人管理类 |
| `groupManager` | - | `GroupManager \| undefined` | 获取群组管理类 |
| `chatroomManager` | - | `ChatroomManager \| undefined` | 获取聊天室管理类 |
| `pushManager` | - | `PushManager \| undefined` | 获取推送管理类 |
| `userInfoManager` | - | `UserInfoManager \| undefined` | 获取用户信息管理类 |
| `presenceManager` | - | `PresenceManager \| undefined` | 获取在线状态管理类 |
| `addConnectionListener` | `listener: ConnectionListener` | `void` | 添加连接监听 |
| `removeConnectionListener` | `listener: ConnectionListener` | `void` | 移除连接监听 |
| `addMultiDevicesListener` | `listener: MultiDevicesListener` | `void` | 添加多设备监听 |
| `removeMultiDevicesListener` | `listener: MultiDevicesListener` | `void` | 移除多设备监听 |
| `uploadLog` | - | `Promise<void>` | 上传本地日志 |
| `getAccessToken` | - | `string` | 从内存获取身份认证 token |
| `isLoggedIn` | - | `boolean` | 是否已登录 |
| `isConnected` | - | `boolean` | 是否已连接服务器 |
| `renewToken` | `newToken: string` | `Promise<void>` | 更新 token |
| `notifySDKNetworkChanged` | - | `void` | 通知 SDK 网络变化 |

静态字段：`static readonly VERSION: string` — SDK 版本号。

## 3. ChatManager（聊天管理）

负责会话管理、消息收发、附件下载、搜索、Reaction、置顶消息等。文件中还导出枚举 `AttachmentDownloadType`（ORIGINAL=0 / BIG=1 / THUMBNAIL=2）。

### 3.1 消息发送与回执

| 方法 | 参数 | 返回 | 说明 |
|---|---|---|---|
| `sendMessage` | `message: ChatMessage` | `void` | 发送消息（附件自动上传），状态经 `ChatMessage.setMessageStatusCallback` 回调 |
| `ackMessageRead` | `to: string`, `messageId: string` | `void` | 发送单聊消息已读回执 |
| `ackConversationRead` | `conversationId: string` | `void` | 发送会话已读回执 |
| `ackGroupMessageRead` | `message: ChatMessage`, `ext: string` | `void` | 发送群消息已读回执 |
| `recallMessage` | `message: ChatMessage`, `ext?: string` | `Promise<void>` | 撤回消息 |
| `updateMessage` | `message: ChatMessage` | `boolean` | 更新本地消息 |
| `modifyMessage` | `messageId: string`, `modifiedBody?: TextMessageBody \| CustomMessageBody \| null`, `ext?: Map<string, MessageExtType> \| null` | `Promise<ChatMessage>` | 修改消息内容（本地+服务端） |

### 3.2 附件下载

| 方法 | 参数 | 返回 | 说明 |
|---|---|---|---|
| `downloadThumbnail` | `message: ChatMessage`, `onProgress?: (progress: number) => void` | `Promise<void>` | 下载缩略图（图片/视频） |
| `downloadAttachment` | `message: ChatMessage`, `onProgress?: (progress: number) => void` | `Promise<void>` | 下载附件（原图/原始文件） |
| `downloadBigImage` | `message: ChatMessage`, `onProgress?: (progress: number) => void` | `Promise<void>` | 下载大图（仅图片消息） |
| `downloadAndParseCombineMessage` | `message: ChatMessage` | `Promise<Array<ChatMessage>>` | 下载并解析合并消息附件 |

### 3.3 翻译与语音转文字

| 方法 | 参数 | 返回 | 说明 |
|---|---|---|---|
| `fetchSupportLanguages` | - | `Promise<Array<TranslationLanguage>>` | 获取翻译服务支持的语言 |
| `translateMessage` | `message: ChatMessage`, `languages: string \| Array<string>` | `Promise<ChatMessage>` | 翻译文本消息（只更新本机） |
| `voiceMessageToText` | `message: ChatMessage` | `Promise<string>` | 语音消息转文字（AMR/MP3） |
| `voiceFileToText` | `filePath: string`, `audioParams?: ChatAudioParams \| null` | `Promise<string>` | 本地语音文件转文字（PCM/MP3/AMR） |

### 3.4 消息置顶

| 方法 | 参数 | 返回 | 说明 |
|---|---|---|---|
| `pinMessage` | `messageId: string` | `Promise<void>` | 置顶消息 |
| `unpinMessage` | `messageId: string` | `Promise<void>` | 取消置顶消息 |
| `fetchPinnedMessagesFromServer` | `conversationId: string` | `Promise<Array<ChatMessage>>` | 从服务端获取置顶消息 |

### 3.5 会话管理

| 方法 | 参数 | 返回 | 说明 |
|---|---|---|---|
| `deleteConversation` | `conversationId: string`, `isRemoveMessages: boolean` | `boolean` | 删除本地会话（可选删消息） |
| `getConversation` | `conversationId: string`, `type?: ConversationType`, `createIfNotExist?: boolean` | `Conversation \| undefined` | 获取会话 |
| `getConversations` | - | `Array<Conversation>` | 获取本地所有会话 |
| `getConversationsFromDB` | `cursor?: string`, `pageSize?: number` | `Promise<CursorResult<Conversation>>` | 分页从本地 DB 获取会话（需先关 `autoLoadAllConversations`） |
| `markAllConversationsAsRead` | - | `void` | 所有会话置为已读 |
| `fetchConversationsFromServer` | `limit: number`, `cursor: string` | `Promise<CursorResult<Conversation>>` | 分页从服务器获取会话 |
| `deleteConversationFromServer` | `conversationId: string`, `type: ConversationType`, `isDeleteServerMessages: boolean` | `Promise<void>` | 删除服务端会话及历史消息 |
| `deleteAllConversationsAndMessages` | `clearSeverData: boolean` | `Promise<void>` | 清空所有会话及其消息 |
| `pinConversation` | `conversationId: string`, `isPinned: boolean` | `Promise<void>` | 置顶/取消置顶会话 |
| `fetchPinnedConversationsFromServer` | `limit: number`, `cursor: string` | `Promise<CursorResult<Conversation>>` | 分页获取置顶会话 |
| `getAllConversationsBySort` | - | `Array<Conversation>` | 获取所有会话并排序（置顶在前） |
| `addConversationMark` | `conversationIds: Array<string> \| string`, `mark: MarkType` | `Promise<void>` | 标记会话 |
| `removeConversationMark` | `conversationIds: Array<string> \| string`, `mark: MarkType` | `Promise<void>` | 取消标记会话 |
| `fetchConversationsFromServerWithFilter` | `filter: ConversationFilter` | `Promise<CursorResult<Conversation>>` | 按过滤条件分页查询会话 |

### 3.6 消息存储与查询

| 方法 | 参数 | 返回 | 说明 |
|---|---|---|---|
| `importMessages` | `messages: Array<ChatMessage>` | `Promise<boolean>` | 导入消息到本地数据库 |
| `saveMessage` | `message: ChatMessage` | `void` | 保存消息到本地数据库 |
| `getMessage` | `messageId: string` | `ChatMessage \| undefined` | 按 ID 获取消息 |
| `getDBMsgsCount` | - | `Promise<number>` | 本地数据库消息总数 |
| `loadMessages` | `messageIds: Array<string>` | `Promise<Array<ChatMessage>>` | 批量按 ID 取本地消息（≤20 条） |
| `loadConversationMessagesWithKeyword` | `keyword: string`, `timestamp?: number`, `sender?: string`, `direction?: SearchDirection`, `scope?: MessageSearchScope` | `Promise<Map<string, Array<string>>>` | 关键词搜索本地消息，返回会话 ID→消息 ID 列表映射 |
| `removeMessagesFromServer`（重载1） | `conversationId: string`, `conversationType: ConversationType`, `messages: Array<string>` | `Promise<void>` | 按消息 ID 单向删除漫游消息 |
| `removeMessagesFromServer`（重载2） | `conversationId: string`, `conversationType: ConversationType`, `beforeTimeStamp: number` | `Promise<void>` | 按时间单向删除漫游消息 |

### 3.7 历史消息与搜索

| 方法 | 参数 | 返回 | 说明 |
|---|---|---|---|
| `fetchHistoryMessages`（重载1） | `param: FetchHistoryMessagesParam` | `Promise<CursorResult<ChatMessage>>` | 分页拉取服务端历史消息 |
| `fetchHistoryMessages`（重载2） | `conversationId: string`, `conversationType: ConversationType`, `pageSize?: number`, `cursor?: string`, `fetchOption?: FetchMessageOption` | `Promise<CursorResult<ChatMessage>>` | 分页拉取服务端历史消息 |
| `searchMessagesFromServer`（重载1） | `param: SearchMessagesFromServerParam` | `Promise<PageResult<SearchServerMessageResult>>` | 服务端搜索消息（需开通增值服务） |
| `searchMessagesFromServer`（重载2） | `option: MessageSearchOption`, `pageSize?: number`, `pageNum?: number` | `Promise<PageResult<SearchServerMessageResult>>` | 服务端搜索消息 |
| `searchMessagesFromDB`（重载1） | `keywords: string`, `timestamp?: number`, `maxCount?: number`, `from?: string`, `direction?: SearchDirection`, `searchScope?: MessageSearchScope` | `Promise<Array<ChatMessage>>` | 本地按关键字搜索 |
| `searchMessagesFromDB`（重载2） | `contentType: ContentType`, `timestamp?: number`, `maxCount?: number`, `from?: string`, `direction?: SearchDirection` | `Promise<Array<ChatMessage>>` | 本地按类型搜索 |
| `searchMessagesFromDB`（重载3） | `types: Array<ContentType>`, `timestamp?: number`, `maxCount?: number`, `from?: string`, `direction?: SearchDirection` | `Promise<Array<ChatMessage>>` | 本地按多类型搜索 |

### 3.8 Reaction 与群已读回执

| 方法 | 参数 | 返回 | 说明 |
|---|---|---|---|
| `addReaction` | `messageId: string`, `reaction: string` | `Promise<void>` | 添加 Reaction |
| `removeReaction` | `messageId: string`, `reaction: string` | `Promise<void>` | 删除 Reaction |
| `fetchReactions` | `messageId: Array<string> \| string`, `chatType: ChatType`, `groupId?: string` | `Promise<Map<string, Array<ChatMessageReaction>>>` | 获取 Reaction 列表 |
| `fetchReactionDetail` | `params: FetchReactionDetailParams` | `Promise<CursorResult<ChatMessageReaction>>` | 获取 Reaction 详情 |
| `fetchGroupReadAcks` | `messageId: string`, `pageSize: number`, `startAckId: string` | `Promise<CursorResult<GroupReadAck>>` | 分页获取群消息已读回执详情 |

### 3.9 监听器注册与其他

| 方法 | 参数 | 返回 | 说明 |
|---|---|---|---|
| `addMessageListener` | `listener: ChatMessageListener` | `void` | 注册消息监听 |
| `removeMessageListener` | `listener: ChatMessageListener` | `void` | 移除消息监听 |
| `addConversationListener` | `listener: ConversationListener` | `void` | 注册会话监听 |
| `removeConversationListener` | `listener: ConversationListener` | `void` | 移除会话监听 |
| `checkAttachmentBeforeDownload` | `message: ChatMessage` | `void` | ⚠️ 未标 private 但疑似内部使用（下载前附件检查） |

## 4. GroupManager（群组管理）

文件中还导出枚举 `GroupStyle`（4 种群类型）。

| 方法 | 参数 | 返回 | 说明 |
|---|---|---|---|
| `addListener` | `listener: GroupListener` | `void` | 注册群事件监听 |
| `removeListener` | `listener: GroupListener` | `void` | 移除群事件监听 |
| `createGroup` | `option?: GroupOptions` | `Promise<Group>` | 创建群组 |
| `destroyGroup` | `groupId: string` | `Promise<void>` | 解散群组（仅群主） |
| `addUsersToGroup` | `groupId: string`, `newMemberIds: Array<string> \| string`, `welcomeMessage?: string` | `Promise<Group>` | 添加群成员 ⚠️ JSDoc 写 `Promise<void>` |
| `removeUsersFromGroup` | `groupId: string`, `members: Array<string> \| string` | `Promise<Group>` | 移出群成员 ⚠️ JSDoc 写 `Promise<void>` |
| `leaveGroup` | `groupId: string` | `Promise<void>` | 退出群组 |
| `joinGroup` | `groupId: string`, `message?: string` | `Promise<Group>` | 加入公开群 |
| `changeGroupName` | `groupId: string`, `newGroupName: string` | `Promise<Group>` | 修改群名称 |
| `changeGroupAvatar` | `groupId: string`, `changedAvatar: string` | `Promise<Group>` | 修改群头像 |
| `changeGroupDescription` | `groupId: string`, `changedDescription: string` | `Promise<Group>` | 修改群描述 |
| `updateGroupAnnouncement` | `groupId: string`, `announcement: string` | `Promise<Group>` | 更新群公告 ⚠️ JSDoc 写 `Promise<void>` |
| `fetchGroupAnnouncement` | `groupId: string` | `Promise<string>` | 获取群公告 |
| `updateGroupExtension` | `groupId: string`, `extension: string` | `Promise<Group>` | 更新群扩展字段 |
| `acceptInvitation` | `groupId: string` | `Promise<Group>` | 接受入群邀请 |
| `declineInvitation` | `groupId: string`, `reason?: string` | `Promise<void>` | 拒绝入群邀请 ⚠️ JSDoc 写 `Promise<Group>` |
| `acceptApplication` | `groupId: string`, `userId: string` | `Promise<Group>` | 批准入群申请 |
| `declineApplication` | `groupId: string`, `userId: string`, `reason?: string` | `Promise<Group>` | 拒绝入群申请 |
| `inviteUsers` | `groupId: string`, `userIds: Array<string> \| string`, `reason?: string` | `Promise<Group>` | 邀请用户入群（私有群） |
| `applyJoinToGroup` | `groupId: string`, `reason?: string` | `Promise<Group>` | 申请加入公开群 |
| `blockGroupMessage` | `groupId: string` | `Promise<Group>` | 屏蔽群消息 |
| `unblockGroupMessage` | `groupId: string` | `Promise<Group>` | 取消屏蔽群消息 |
| `blockUsers` | `groupId: string`, `userIds: Array<string> \| string`, `reason?: string` | `Promise<Group>` | 加入群黑名单 |
| `unblockUsers` | `groupId: string`, `userIds: Array<string> \| string` | `Promise<Group>` | 移出群黑名单 |
| `changeOwner` | `groupId: string`, `newOwner: string` | `Promise<Group>` | 移交群主 |
| `addGroupAdmin` | `groupId: string`, `admin: string` | `Promise<Group>` | 添加管理员（仅群主） |
| `removeGroupAdmin` | `groupId: string`, `admin: string` | `Promise<Group>` | 移除管理员（仅群主） |
| `muteGroupMembers` | `groupId: string`, `muteMembers: Array<string> \| string`, `duration?: number` | `Promise<Group>` | 禁言成员（-1 永久） |
| `unmuteGroupMembers` | `groupId: string`, `muteMembers: Array<string> \| string` | `Promise<Group>` | 解除禁言 |
| `addToGroupWhitelist` | `groupId: string`, `members: Array<string> \| string` | `Promise<void>` | 添加群白名单 |
| `removeFromGroupWhitelist` | `groupId: string`, `members: Array<string> \| string` | `Promise<void>` | 移出群白名单 |
| `checkIfInGroupWhitelist` | `groupId: string` | `Promise<boolean>` | 检查自己是否在白名单 |
| `muteAllMembers` | `groupId: string` | `Promise<Group>` | 全员禁言 |
| `unmuteAllMembers` | `groupId: string` | `Promise<Group>` | 解除全员禁言 |
| `checkIfInGroupMutelist` | `groupId: string` | `Promise<boolean>` | 检查自己是否被禁言 |
| `fetchGroupSharedFileList` | `groupId: string`, `pageNum: number`, `pageSize: number` | `Promise<Array<SharedFile>>` | 获取群共享文件列表 |
| `deleteGroupSharedFile` | `groupId: string`, `fileId: string` | `Promise<void>` | 删除群共享文件 |
| `uploadGroupSharedFile` | `groupId: string`, `filePath: string`, `callback?: ChatCallback` | `Promise<SharedFile>` | 上传群共享文件（callback 报进度） |
| `downloadGroupSharedFile` | `groupId: string`, `fileId: string`, `savePath: string`, `callback?: ChatCallback` | `Promise<void>` | 下载群共享文件 |
| `fetchGroupMembers` | `groupId: string`, `pageSize: number`, `cursor?: string` | `Promise<CursorResult<string>>` | 分页获取群成员 ID |
| `fetchGroupMemberDetails` | `groupId: string`, `pageSize: number`, `cursor?: string` | `Promise<CursorResult<GroupMember>>` | 分页获取群成员详情 |
| `updateGroupNamecard` | `groupId: string`, `namecard: string` | `Promise<void>` | 更新自己的群名片 |
| `getGroupNamecard` | `groupId: string`, `userId: string` | `string` | 从本地缓存获取群名片（同步） |
| `fetchGroupMutelist` | `groupId: string`, `pageNum: number`, `pageSize: number` | `Promise<Map<string, number>>` | 获取禁言列表 |
| `fetchGroupWhitelist` | `groupId: string` | `Promise<Array<string>>` | 获取白名单 |
| `fetchGroupBlocklist` | `groupId: string`, `pageNum: number`, `pageSize: number` | `Promise<Array<string>>` | 分页获取黑名单 |
| `getGroup` | `groupId: string` | `Group \| undefined` | 从内存获取群对象 |
| `getAllGroups` | - | `Promise<Array<Group>>` | 获取当前用户所有群（内存/DB） |
| `clearAllLocalGroups` | - | `void` | 清除所有本地群组信息 |
| `fetchGroupFromServer` | `groupId: string` | `Promise<Group>` | 从服务器获取群详情（不含成员） |
| `fetchJoinedGroupsFromServer` | `pageNum: number`, `pageSize: number` | `Promise<Array<Group>>` | 分页获取已加入的群 |
| `fetchJoinedGroupsCount` | - | `Promise<number>` | 获取已加入群数量 |
| `fetchPublicGroupsFromServer` | `pageSize: number`, `cursor?: string` | `Promise<CursorResult<Group>>` | 分页获取公开群 |
| `setMemberAttributes` | `groupId: string`, `member: string`, `attributes: Map<string, string>` | `Promise<void>` | 设置群成员自定义属性 |
| `fetchMemberAttributes` | `groupId: string`, `member: string` | `Promise<Map<string, string>>` | 获取单个成员自定义属性 |
| `fetchMembersAttributes` | `groupId: string`, `members: Array<string> \| string`, `keys?: Array<string> \| string` | `Promise<Map<string, Map<string, string>>>` | 批量获取成员自定义属性 |

## 5. ChatroomManager（聊天室管理）

| 方法 | 参数 | 返回 | 说明 |
|---|---|---|---|
| `addListener` | `listener: ChatroomListener` | `void` | 添加聊天室监听 |
| `removeListener` | `listener: ChatroomListener` | `void` | 移除聊天室监听 |
| `joinChatroom` | `roomId: string`, `leaveOtherRooms?: boolean`, `ext?: string` | `Promise<Chatroom>` | 加入聊天室 ⚠️ JSDoc 写 `Promise<void>` |
| `leaveChatroom` | `roomId: string` | `Promise<void>` | 离开聊天室 |
| `fetchPublicChatroomsFromServer` | `pageNum: number`, `pageSize: number` | `Promise<Array<Chatroom>>` | 获取聊天室列表 |
| `changeChatroomName` | `roomId: string`, `newName: string` | `Promise<Chatroom>` | 修改聊天室名称 |
| `changeChatroomDescription` | `roomId: string`, `newDescription: string` | `Promise<Chatroom>` | 修改聊天室描述 |
| `fetchChatroomAnnouncement` | `roomId: string` | `Promise<string>` | 获取聊天室公告 |
| `changeChatroomAnnouncement` | `roomId: string`, `newAnnouncement: string` | `Promise<Chatroom>` | 修改聊天室公告 |
| `changeChatroomOwner` | `roomId: string`, `newOwner: string` | `Promise<Chatroom>` | 转移聊天室所有权 |
| `addChatroomAdmin` | `roomId: string`, `newAdmin: string` | `Promise<Chatroom>` | 添加管理员 |
| `removeChatroomAdmin` | `roomId: string`, `admin: string` | `Promise<Chatroom>` | 移除管理员 |
| `removeChatroomMembers` | `roomId: string`, `members: string[]` | `Promise<Chatroom>` | 移除聊天室成员 |
| `muteChatroomMembers` | `roomId: string`, `members: string[]`, `muteDuration: number` | `Promise<Chatroom>` | 禁言成员 |
| `unmuteChatroomMembers` | `roomId: string`, `members: string[]` | `Promise<Chatroom>` | 解除禁言 |
| `checkIfInMutelist` | `roomId: string` | `Promise<boolean>` | 检查自己是否被禁言 ⚠️ JSDoc 返回类型写错 |
| `blockChatroomMembers` | `roomId: string`, `members: string[]` | `Promise<Chatroom>` | 加入黑名单 |
| `unblockChatroomMembers` | `roomId: string`, `members: string[]` | `Promise<Chatroom>` | 移出黑名单 |
| `muteAllMembers` | `roomId: string` | `Promise<Chatroom>` | 全员禁言 |
| `unmuteAllMembers` | `roomId: string` | `Promise<Chatroom>` | 解除全员禁言 |
| `addToChatroomWhitelist` | `roomId: string`, `members: string[]` | `Promise<Chatroom>` | 加入白名单 |
| `removeFromChatroomWhitelist` | `roomId: string`, `members: string[]` | `Promise<Chatroom>` | 移出白名单 |
| `checkIfInWhitelist` | `roomId: string` | `Promise<boolean>` | 检查自己是否在白名单 ⚠️ JSDoc 返回类型写错 |
| `fetchChatroomMembers` | `roomId: string`, `cursor: string`, `pageSize: number` | `Promise<CursorResult<string>>` | 分页获取成员列表 |
| `fetchChatroomMutes` | `roomId: string`, `pageNum: number`, `pageSize: number` | `Promise<Map<string, number>>` | 分页获取禁言列表 |
| `fetchChatroomBlocklist` | `roomId: string`, `pageNum: number`, `pageSize: number` | `Promise<Array<string>>` | 分页获取黑名单 |
| `fetchChatroomWhitelist` | `roomId: string` | `Promise<Array<string>>` | 获取白名单 |
| `fetchChatroomAttributes` | `chatroomId: string`, `key?: string \| Array<string>` | `Promise<Map<string, string>>` | 获取聊天室自定义属性 |
| `setChatroomAttributes` | `params: SetChatroomAttributeParams` | `Promise<ChatroomAttributesResult>` | 设置自定义属性 |
| `removeChatroomAttributes` | `params: RemoveChatroomAttributeParams` | `Promise<ChatroomAttributesResult>` | 删除自定义属性 |

## 6. ContactManager（联系人管理）

| 方法 | 参数 | 返回 | 说明 |
|---|---|---|---|
| `addContactListener` | `listener: ContactListener` | `void` | 添加联系人监听 |
| `removeContactListener` | `listener: ContactListener` | `void` | 移除联系人监听 |
| `getContact` | `userId: string` | `Promise<Contact \| undefined>` | 获取本地单个联系人 |
| `allContacts` | - | `Promise<Array<string>>` | 获取缓存中所有联系人 ID |
| `getContactsFromLocal` | - | `Promise<Array<Contact>>` | 从本地获取所有联系人 |
| `fetchAllContactsIDFromServer` | - | `Promise<Array<string>>` | 从服务器获取所有联系人 ID |
| `fetchAllContactsFromServer` | - | `Promise<Array<Contact>>` | 从服务器获取所有联系人 |
| `fetchAllContactsFromServerByPage` | `pageSize: number`, `cursor?: string` | `Promise<CursorResult<Contact>>` | 从服务端分页获取联系人 |
| `addContact` | `userId: string`, `reason?: string` | `Promise<void>` | 添加联系人 |
| `deleteContact` | `userId: string`, `keepConversation?: boolean` | `Promise<void>` | 删除联系人 |
| `acceptInvitation` | `userId: string` | `Promise<void>` | 接受好友邀请 |
| `declineInvitation` | `userId: string` | `Promise<void>` | 拒绝好友邀请 |
| `blockList` | - | `Promise<Array<string>>` | 获取缓存中的黑名单 ⚠️ JSDoc 写同步返回 |
| `getBlockListFromServer` | - | `Promise<Array<string>>` | 从服务器获取黑名单 |
| `addUsersToBlocklist` | `list: Array<string> \| string` | `Promise<void>` | 加入黑名单 |
| `removeUserFromBlockList` | `userId: string` | `Promise<void>` | 移出黑名单 |
| `getSelfIdsOnOtherPlatform` | - | `Promise<Array<string>>` | 获取当前用户在其他设备的登录 ID |
| `setContactRemark` | `userId: string`, `remark: string` | `Promise<void>` | 设置好友备注 |

## 7. PushManager（推送管理）

文件中还导出枚举 `SilentModeParamType`、`PushDisplayStyle`（SimpleBanner/MessageSummary）、`PushRemindType`（ALL/MENTION_ONLY/NONE）。

| 方法 | 参数 | 返回 | 说明 |
|---|---|---|---|
| `addListener` | `listener: PushListener` | `void` | 添加推送监听 |
| `removeListener` | `listener: PushListener` | `void` | 移除推送监听 |
| `notifyPushResult` | `error: ChatError` | `void` | ⚠️ 仅内部使用 |
| `uploadPushToken` | `token: string`, `certName: string` | `Promise<string>` | 绑定设备推送 token |
| `unbindPushToken` | `certName: string` | `Promise<void>` | 解绑设备推送 token |
| `updatePushNickname` | `nickname: string` | `Promise<void>` | 更新推送昵称 |
| `updatePushDisplayStyle` | `style: PushDisplayStyle` | `Promise<void>` | 更新推送展示样式 |
| `setSilentModeForConversation` | `conversationId: string`, `type: ConversationType`, `pushRemindType: PushRemindType` | `Promise<SilentModeResult>` | 设置会话免打扰 |
| `clearRemindTypeForConversation` | `conversationId: string`, `type: ConversationType` | `Promise<void>` | 清除会话提醒类型设置 |
| `getSilentModeForConversation`（重载1） | `conversationId: string`, `type: ConversationType` | `Promise<SilentModeResult>` | 获取会话免打扰设置 |
| `getSilentModeForConversation`（重载2） | `conversation: Conversation` | `Promise<SilentModeResult>` | 获取会话免打扰设置 |
| `getSilentModeForConversations` | `conversations: Array<Conversation>` | `Promise<Map<string, SilentModeResult>>` | 批量获取会话免打扰设置 |
| `syncConversationsSilentModeFromServer` | - | `Promise<void>` | 同步服务端会话免打扰状态 |
| `setSilentModeForAll` | `param: SilentModeParam` | `Promise<SilentModeResult>` | 设置当前用户全局免打扰 |
| `getSilentModeForAll` | - | `Promise<SilentModeResult>` | 获取当前用户全局免打扰 |
| `setPushTemplate` | `templateName: string` | `Promise<void>` | 设置离线推送模板 |
| `getPushTemplate` | - | `Promise<string>` | 获取离线推送模板 |

## 8. PresenceManager（在线状态管理）

继承 `ChatBase<EMPresenceManager>`。

| 方法 | 参数 | 返回 | 说明 |
|---|---|---|---|
| `publishPresence` | `customStatus: string` | `Promise<void>` | 发布自定义在线状态 |
| `subscribePresences` | `member: string \| Array<string>`, `expiry: number` | `Promise<Array<Presence>>` | 订阅用户在线状态（最长 30 天） |
| `unsubscribePresences` | `member: string \| Array<string>` | `Promise<void>` | 取消订阅 |
| `fetchSubscribedMembers` | `pageNumber: number`, `pageSize: number` | `Promise<Array<string>>` | 分页查询已订阅用户 |
| `fetchPresenceStatus` | `member: string \| Array<string>` | `Promise<Array<Presence>>` | 查询指定用户在线状态 |
| `addListener` | `listener: PresenceListener` | `void` | 添加监听 |
| `removeListener` | `listener: PresenceListener` | `void` | 移除监听 |

## 9. UserInfoManager（用户信息管理）

| 方法 | 参数 | 返回 | 说明 |
|---|---|---|---|
| `updateUserInfo`（重载1） | `userInfo: UserInfo` | `Promise<UserInfo>` | 修改当前用户信息 |
| `updateUserInfo`（重载2） | `userInfoType: UserInfoType`, `value: string \| Gender` | `Promise<UserInfo>` | 修改指定用户属性（value 为空删除该属性） |
| `fetchUserInfoById` | `userId: Array<string> \| string`, `attribute?: Array<UserInfoType> \| UserInfoType` | `Promise<Map<string, UserInfo>>` | 按 ID 和属性获取用户信息 |
| `getUserInfoById` | `userId: Array<string> \| string` | `Promise<Map<string, UserInfo>>` | 从本地缓存获取用户信息（无网络请求） |
| `subscribeUsersInfo` | `userIds: string[]` | `Promise<void>` | 订阅非好友用户信息变更 |
| `unsubscribeUsersInfo` | `userIds: string[]` | `Promise<void>` | 取消订阅 |
| `fetchSubscribedUsers` | - | `Promise<UserInfo[]>` | 获取已订阅的非好友用户信息 |
| `getUserInfoWithUserId` | `userId: string` | `UserInfo \| undefined` | 本地缓存获取单个用户信息（同步） |
| `addListener` | `listener: UserInfoListener` | `void` | 添加用户信息更新监听 |
| `removeListener` | `listener: UserInfoListener` | `void` | 移除监听 |

## 10. Conversation（会话）

继承 `ChatBase<EMConversation>`。同文件导出枚举 `ConversationType`、`SearchDirection`、`MarkType`（MARK_0~MARK_19）、`MessageSearchScope`，及类 `ConversationFilter`。

| 方法 | 参数 | 返回 | 说明 |
|---|---|---|---|
| `conversationId` | - | `string` | 会话 ID |
| `getType` | - | `ConversationType` | 会话类型 |
| `removeMessage` | `message: ChatMessage \| string` | `boolean` | 删除本地一条消息 |
| `insertMessage` | `message: ChatMessage` | `boolean` | 插入消息到本地 DB |
| `appendMessage` | `message: ChatMessage` | `boolean` | 在会话尾部插入消息 |
| `updateMessage` | `message: ChatMessage` | `boolean` | 更新本地消息 |
| `clearAllMessages` | - | `void` | 清除会话所有消息 |
| `markMessageAsRead` | `msgId: string` | `void` | 置消息为已读（内部异步） |
| `markAllMessagesAsRead` | - | `boolean` | 所有未读置已读 |
| `getUnreadMsgCount` | - | `number` | 未读消息数 |
| `getAllMsgCount` | - | `number` | 消息总数 |
| `getMsgCountInRange` | `startTimestamp: number`, `endTimestamp: number` | `number` | 时间段内消息数 |
| `getMessage` | `msgId: string` | `ChatMessage \| undefined` | 按 ID 取消息 |
| `getLatestMessage` | - | `ChatMessage \| undefined` | 最新一条消息 |
| `getLatestMessageFromOthers` | - | `ChatMessage \| undefined` | 收到的最新一条消息 |
| `loadMoreMessagesFromDB` | `startMsgId?: string`, `pageSize?: number`, `direction?: SearchDirection` | `Promise<Array<ChatMessage>>` | 分页加载本地消息 |
| `searchMessagesFromDB` | `timestamp: number`, `maxCount?: number`, `direction?: SearchDirection` | `Promise<Array<ChatMessage>>` | 按时间戳搜索本地消息 |
| `searchMessagesByType` | `type: ContentType \| Array<ContentType>`, `timestamp?: number`, `maxCount?: number`, `from?: string`, `direction?: SearchDirection` | `Promise<Array<ChatMessage>>` | 按类型搜索本地消息 |
| `searchMessagesByKeywords` | `keywords: string`, `timestamp?: number`, `maxCount?: number`, `from?: string \| string[]`, `direction?: SearchDirection`, `searchScope?: MessageSearchScope` | `Promise<Array<ChatMessage>>` | 按关键词搜索本地消息 |
| `searchMessagesBetweenTime` | `startTimestamp: number`, `endTimestamp: number`, `maxCount?: number` | `Promise<Array<ChatMessage>>` | 搜索时间段内消息 |
| `getExtField` | - | `string` | 获取会话扩展字段（仅本地） |
| `setExtField` | `ext: string` | `void` | 设置会话扩展字段 |
| `isPinned` | - | `boolean` | 是否置顶 |
| `getPinnedTime` | - | `number` | 置顶时间戳（毫秒，未置顶为 0） |
| `marks` | - | `Set<MarkType>` | 会话所有标记 |
| `pushRemindType` | - | `PushRemindType` | 本地推送提醒类型 |
| `getPinnedMessages` | - | `Promise<Array<ChatMessage>>` | 本地置顶消息列表 |

## 11. ChatMessage（消息）与消息体

### 11.1 ChatMessage

继承 `ChatBase<EMMessage>`。同文件导出：`MessageExtType`（type 别名）、`ChatCallbackHolder`、枚举 `ContentType`、`ChatType`、`MessageStatus`、`MessageDirection`、`ChatroomMessagePriority`。

**静态创建方法（9 个）**：

| 方法 | 参数 | 返回 |
|---|---|---|
| `createTextSendMessage` | `to: string`, `message: string` | `ChatMessage \| undefined` |
| `createVoiceSendMessage` | `to: string`, `filePath: string`, `duration: number` | `ChatMessage \| undefined` |
| `createImageSendMessage` | `to: string`, `filePath: string`, `isGif?: boolean` | `ChatMessage \| undefined` |
| `createVideoSendMessage` | `to: string`, `filePath: string`, `duration: number`, `imageThumbPath?: string` | `ChatMessage \| undefined` ⚠️ JSDoc 参数顺序与声明不一致，以声明为准 |
| `createFileSendMessage` | `to: string`, `filePath: string` | `ChatMessage \| undefined` |
| `createLocationSendMessage` | `to: string`, `latitude: number`, `longitude: number`, `locationAddress: string`, `buildingName?: string` | `ChatMessage` |
| `createCombinedSendMessage` | `to: string`, `params: CombineMessageParams` | `ChatMessage` |
| `createSendMessage` | `to: string`, `body: ChatMessageBody`, `chatType: ChatType` | `ChatMessage` |
| `createReceiveMessage` | `from: string`, `body: ChatMessageBody`, `chatType: ChatType`, `msgId: string` | `ChatMessage` |

**实例方法（57 个）**：

| 方法 | 参数 | 返回 | 说明 |
|---|---|---|---|
| `getMsgId` / `setMsgId` | `msgId: string` | `string` / `void` | 消息 ID |
| `getFrom` / `setFrom` | `from: string` | `string` / `void` | 发送方 |
| `getTo` / `setTo` | `to: string` | `string` / `void` | 接收方 |
| `getConversationId` | - | `string` | 会话 ID |
| `getStatus` / `setStatus` | `status: MessageStatus` | `MessageStatus` / `void` | 发送/接收状态 |
| `getType` | - | `ContentType` | 消息类型 |
| `getChatType` / `setChatType` | `chatType: ChatType` | `ChatType` / `void` | 聊天类型 |
| `getDirection` / `setDirection` | `direction: MessageDirection` | `MessageDirection` / `void` | 消息方向 |
| `isUnread` / `setUnread` | `isUnread: boolean` | `boolean` / `void` | 未读标记 |
| `isListened` / `setIsListened` | `isListened: boolean` | `boolean` / `void` | 语音已听标记 |
| `isReceiverRead` / `setReceiverRead` | `isReadAcked: boolean` | `boolean` / `void` | 对方已读标记 |
| `isDelivered` | - | `boolean` | 是否已送达 |
| `setDelivered` | `isDelivered: boolean` | `void` | ⚠️ 仅内部使用 |
| `isNeedGroupAck` / `setIsNeedGroupAck` | `isNeedGroupAck: boolean` | `boolean` / `void` | 群已读回执标记 |
| `groupAckCount` | - | `number` | 群消息已读人数 |
| `setGroupAckCount` | `groupAckCount: number` | `void` | ⚠️ 仅内部使用 |
| `getServerTimestamp` / `setServerTimestamp` | `timestamp: number` | `number` / `void` | 服务器时间戳 |
| `getLocalTimestamp` / `setLocalTimestamp` | `localTime: number` | `number` / `void` | 本地时间戳 |
| `getBody` / `setBody` | `body: ChatMessageBody` | `ChatMessageBody \| undefined` / `void` | 消息体 |
| `clearAttributes` | - | `void` | 清除本地所有扩展属性 |
| `setExt` | `ext: Map<string, MessageExtType>` | `void` | 设置扩展属性 |
| `setJsonAttribute` | `key: string`, `value: object` | `void` | 设置 JSON 扩展属性 |
| `ext` | - | `Map<string, MessageExtType>` | 获取全部扩展属性 |
| `setMessageStatusCallback` | `callback: ChatCallback` | `void` | 设置消息状态回调 |
| `addMessageStatusCallback` | `callback: ChatCallback` | `void` | 添加消息状态回调（支持多个） |
| `removeMessageStatusCallback` | `callback: ChatCallback` | `void` | 移除消息状态回调 |
| `getProgress` | - | `number` | 附件上传/下载进度 |
| `isBroadcast` | - | `boolean` | 是否聊天室全局广播消息 |
| `setBroadcast` | `isBroadcast: boolean` | `void` | ⚠️ 仅内部使用 |
| `isOnlineState` | - | `boolean` | 是否在线消息 |
| `setPriority` | `priority: ChatroomMessagePriority` | `void` | 设置聊天室消息优先级 |
| `isDeliverOnlineOnly` | - | `boolean` | 是否只投递在线用户 |
| `deliverOnlineOnly` | `onlineOnly: boolean` | `void` | 设置只投递在线用户 |
| `setWebhookEnv` | `webhookEnv?: string` | `void` | 设置消息回调路由环境标识（1.15 新增） |
| `getWebhookEnv` | - | `string \| undefined` | 获取回调路由环境标识 |
| `receiverList` | - | `Array<string>` | 定向消息接收方 |
| `setReceiverList` | `receiverList: Array<string>` | `void` | 设置定向消息接收方 |
| `getReactions` | - | `Array<ChatMessageReaction>` | 本地 Reaction 列表 |
| `getRecaller` | - | `string` | 消息撤回者 ID |
| `setRecaller` | `recaller: string` | `void` | ⚠️ 仅内部使用 |
| `getSenderInfo` | - | `ChatSenderInfo \| undefined` | 消息发送者信息（需开 `enableUserInfo`） |
| `getPinnedInfo` | - | `ChatMessagePinInfo \| undefined` | 消息置顶详情 |
| `getStreamChunk` | - | `ChatStreamChunk \| null` | 流式消息分片信息 |
| `toString` | `isFull?: boolean` | `string` | |

### 11.2 消息体类（数据模型，只列类名）

`ChatMessageBody`（基类）、`TextMessageBody`（含 `TranslationInfo` 接口）、`ImageMessageBody`、`VideoMessageBody`、`VoiceMessageBody`、`FileMessageBody`（含 `DownloadStatus` 枚举）、`LocationMessageBody`、`CmdMessageBody`、`CustomMessageBody`、`CombineMessageBody`（继承 FileMessageBody）。

### 11.3 消息相关数据模型（只列类名）

`ChatMessageReaction`、`ChatMessageReactionChange`、`ChatMessageReactionOperation`（含 `ReactionOperation` 枚举）、`ChatMessagePinInfo`（含 `PinOperation` 枚举）、`ChatStreamChunk`（含 `ChatStreamStatus` 枚举）、`ChatSenderInfo`、`RecallMessageInfo`、`GroupReadAck`、`ChatCallbackHolder`。

## 12. ChatOptions（SDK 配置）

构造：`new ChatOptions(param: string)` 或 `new ChatOptions(param: AppParam)`。同文件导出接口 `AppParam`、枚举 `AreaCode`、`SDKPlatform`。

| 方法 | 参数 | 返回 | 说明 |
|---|---|---|---|
| `setConfig` | `config: ChatConfigPrivate` | `void` | ⚠️ 参数类型 `ChatConfigPrivate` 位于 internal 目录，疑为内部使用 |
| `setAppKey` / `getAppKey` | `appKey: string` | `void` / `string` | App Key |
| `setAppId` / `getAppId` | `appId: string` | `void` / `string` | AppId |
| `setAutoLogin` / `isAutoLogin` | `autoLogin: boolean` | `void` / `boolean` | 自动登录 |
| `setSortMessageByServerTime` / `isSortMessageByServerTime` | `sortByServerTime: boolean` | `void` / `boolean` | 按服务器时间排序消息 |
| `getDownloadPath` | - | `string` | 下载路径 |
| `setAcceptInvitationAlways` / `isAcceptInvitationAlways` | `isAutoAccept: boolean` | `void` / `boolean` | 自动接受好友邀请 |
| `setAutoAcceptGroupInvitations` / `isAutoAcceptGroupInvitations` | `isAutoAcceptGroups: boolean` | `void` / `boolean` | 自动接受群邀请 |
| `setRequireReadAck` / `isRequireReadAck` | `isRequireReadAck: boolean` | `void` / `boolean` | 已读回执开关 |
| `setRequireDeliveryAck` / `isRequireDeliveryAck` | `isRequireDeliveryAck: boolean` | `void` / `boolean` | 送达回执开关 |
| `setDeleteMessagesOnLeaveGroup` / `isDeleteMessagesOnLeaveGroup` | `boolean` | `void` / `boolean` | 退群删消息 |
| `setDeleteMessagesOnLeaveChatroom` / `isDeleteMessagesOnLeaveChatroom` | `boolean` | `void` / `boolean` | 退聊天室删消息 |
| `setLogLevel` / `getLogLevel` | `level: ChatLogLevel` | `void` / `ChatLogLevel` | 日志级别 |
| `getDeviceUuid` | - | `string` | 设备 UUID |
| `setUsingHttpsOnly` / `isUsingHttpsOnly` | `httpsOnly: boolean` | `void` / `boolean` | 仅 HTTPS |
| `setAutoTransferMessageAttachments` / `isAutoTransferMessageAttachments` | `boolean` | `void` / `boolean` | 自动上传附件 |
| `setAutoDownloadThumbnail` / `isAutoDownloadThumbnail` | `autoDownload: boolean` | `void` / `boolean` | 自动下载缩略图 |
| `setAppIDForPush` / `getAppIDForPush` | `appId: string` | `void` / `string` | 推送 AppId |
| `setLoginCustomExt` / `getLoginCustomExt` | `ext: string` | `void` / `string` | 登录自定义扩展 |
| `setAreaCode` / `getAreaCode` | `code: AreaCode` | `void` / `AreaCode` | 区域码 |
| `setIncludeSendMessageInMessageListener` / `isIncludeSendMessageInMessageListener` | `include: boolean` | `void` / `boolean` | 消息监听是否包含发送的消息 |
| `setUseReplacedMessageContents` / `isUseReplacedMessageContents` | `boolean` | `void` / `boolean` | 使用替换后的消息内容 |
| `setCustomOSPlatform` / `getCustomOSPlatform` | `platform: number` | `void` / `number` | 自定义 OS 平台 |
| `setCustomDeviceName` / `getCustomDeviceName` | `customDeviceName: string` | `void` / `string` | 自定义设备名 |
| `setUIKitVersion` / `getUIKitVersion` | `version: string` | `void` / `string` | UIKit 版本 |
| `setSDKPlatform` / `getSDKPlatform` | `platform: SDKPlatform` | `void` / `SDKPlatform` | SDK 平台 |
| `setEnableTLSConnection` / `isEnableTLSConnection` | `boolean` | `void` / `boolean` | TLS 连接 |
| `setEnableUserInfo` / `isEnableUserInfo` | `boolean` | `void` / `boolean` | 用户信息能力开关 |
| `setDnsURL` / `getDnsURL` | `url: string` | `void` / `string` | DNS 地址 |
| `setIMServer` / `getImServer` | `imServer: string` | `void` / `string` | IM 服务器 |
| `setImPort` / `getImPort` | `imPort: number` | `void` / `number` | IM 端口 |
| `setRestServer` / `getRestServer` | `restServer: string` | `void` / `string` | REST 服务器 |
| `setWebSocketServer` / `getWebSocketServer` | `webSocketServer: string` | `void` / `string` | WebSocket 服务器 |
| `setWebSocketPort` / `getWebSocketPort` | `webSocketPort: number` | `void` / `number` | WebSocket 端口 |
| `setEnableAutoSyncContacts` / `isEnableAutoSyncContacts` | `boolean` | `void` / `boolean` | 登录自动同步联系人 |
| `setEnableDnsConfig` / `getEnableDnsConfig` | `boolean` | `void` / `boolean` | 启用 DNS 配置 |
| `setRegardImportedMsgAsRead` | `regardImportedMsgAsRead: boolean` | `void` | 导入消息视为已读（⚠️ 声明中未见对应 getter） |
| `setNtpServers` / `getNtpServers` | `servers: string[]` | `void` / `string[]` | 自定义 NTP 服务器（1.15 新增） |
| `setAutoLoadAllConversations` / `isAutoLoadAllConversations` | `boolean` | `void` / `boolean` | 登录后自动加载全部会话（1.15 新增，默认 true） |
| `setEnableChatroomConversation` / `isEnableChatroomConversation` | `boolean` | `void` / `boolean` | 会话列表是否含聊天室会话（1.15 新增，默认 false） |

注：1.15.0 删除了 `setSyncDataWebSocketServer` / `getSyncDataWebSocketServer` / `setSyncDataWebSocketPort` / `getSyncDataWebSocketPort`（见 CHANGELOG"变更"节）。

## 13. ChatLog 与 ChatError

**ChatLog**（util/ChatLog.d.ets，全部静态）：`i(info)`、`d(info)`、`e(info)`、`w(info)`、`setLogLevel(level)`、`getLogLevel()`、`addLogCallback(callback: (info: string) => void)`、`removeLogCallback(callback)`；静态字段 `static log: EMLog`；枚举 `ChatLogLevel`（DEBUG/WARNING/ERROR）。

**ChatError**：字段 `errorCode: number`、`description: string`；构造函数 `constructor(error: EMError)` / `constructor(errorCode: number, description: string)`；静态 `createError(error: EMError | BusinessError)` / `createError(errorCode, description)`；**114 个静态只读错误码常量**（`EM_NO_ERROR`、`GENERAL_ERROR`、`NETWORK_ERROR`、`CONNECTION_TIMEOUT`、`PARTIAL_SUCCESS`、`FILE_NOT_FOUND`、`USER_ILLEGAL_ARGUMENT` 等，含 1.15 新增的 350–354 连接类错误码）。

## 14. 事件监听接口

注册入口：`ChatClient.addConnectionListener` / `addMultiDevicesListener`，`ChatManager.addMessageListener` / `addConversationListener`，`GroupManager.addListener`，`ChatroomManager.addListener`，`ContactManager.addContactListener`，`PushManager.addListener`，`PresenceManager.addListener`，`UserInfoManager.addListener`；消息级回调经 `ChatMessage.setMessageStatusCallback`（`ChatCallback`）。

### 14.1 ConnectionListener（连接，7 个回调）

| 回调 | 签名 |
|---|---|
| `onConnected`（必选） | `() => void` |
| `onDisconnected`（必选） | `(errorCode: number) => void` |
| `onLogout` | `(errorCode: number, info: LoginExtInfo) => void` |
| `onTokenExpired` | `() => void` |
| `onTokenWillExpire` | `() => void` |
| `onOfflineMessageSyncStart` | `() => void` |
| `onOfflineMessageSyncFinish` | `() => void` |

相关类：`LoginExtInfo`（字段 `deviceInfo`、`deviceExt`；静态 `create(deviceInfo, deviceExt)`）。

### 14.2 ChatMessageListener（消息，12 个回调）

| 回调 | 签名 |
|---|---|
| `onMessageReceived`（必选） | `(messages: Array<ChatMessage>) => void` |
| `onCmdMessageReceived` | `(messages: Array<ChatMessage>) => void` |
| `onMessageRead` | `(messages: Array<ChatMessage>) => void` |
| `onMessageDelivered` | `(messages: Array<ChatMessage>) => void` |
| `onMessageRecalled` | `(recallInfo: Array<RecallMessageInfo>) => void` |
| `onMessageChanged` | `(message: ChatMessage, change: object) => void` |
| `onGroupMessageRead` | `(groupReadAcks: Array<GroupReadAck>) => void` |
| `onReadAckForGroupMessageUpdated` | `() => void` |
| `onMessageContentChanged` | `(modifiedMessage: ChatMessage, operatorId: string, operationTime: number) => void` |
| `onReactionChanged` | `(messageReactionChange: Array<ChatMessageReactionChange>) => void` |
| `onMessagePinChanged` | `(messageId: string, conversationId: string, pinOperation: PinOperation, pinInfo: ChatMessagePinInfo) => void` |
| `onStreamMessageReceived` | `(messages: Array<ChatMessage>) => void` |

### 14.3 GroupListener（群组，28 个回调，全部可选）

`onInvitationReceived(groupId, groupName, inviter, reason)`、`onRequestToJoinReceived(groupId, groupName, applicant, reason)`、`onRequestToJoinAccepted(groupId, groupName, accepter)`、`onRequestToJoinDeclined(groupId, groupName, decliner, applicant, reason)`、`onInvitationAccepted(groupId, invitee, reason)`、`onInvitationDeclined(groupId, invitee, reason)`、`onUserRemoved(groupId, groupName)`、`onGroupDestroyed(groupId, groupName)`、`onAutoAcceptInvitationFromGroup(groupId, inviter, inviteMessage)`、`onMutelistAdded(groupId, mutes, muteExpire)`、`onMutelistRemoved(groupId, mutes)`、`onWhitelistAdded(groupId, whitelist)`、`onWhitelistRemoved(groupId, whitelist)`、`onAllMemberMuteStateChanged(groupId, isMuted)`、`onAdminAdded(groupId, administrator)`、`onAdminRemoved(groupId, administrator)`、`onOwnerChanged(groupId, newOwner, oldOwner)`、`onMemberJoined(groupId, member)`、`onMembersJoined(groupId, members)`、`onMemberExited(groupId, member)`、`onMembersExited(groupId, members)`、`onAnnouncementChanged(groupId, announcement)`、`onSharedFileAdded(groupId, sharedFile)`、`onSharedFileDeleted(groupId, fileId)`、`onSpecificationChanged(group)`、`onStateChanged(group, isDisabled)`、`onGroupMemberAttributeChanged(groupId, member, attributes, from)`、`onUserGroupNamecardUpdated(groupId, userId, namecard)`。

### 14.4 ChatroomListener（聊天室，16 个回调，全部可选）

`onMemberJoined(roomId, userId, ext?)`、`onMemberExited(roomId, roomName, userId)`、`onRemovedFromChatroom(reason: LEAVE_REASON, roomId, roomName)`、`onMutelistAdded(roomId, mutes, expireTime)`、`onMuteMapAdded(roomId, mutes: Map<string, number>)`、`onMutelistRemoved(roomId, mutes)`、`onWhitelistAdded(roomId, whitelist)`、`onWhitelistRemoved(roomId, whitelist)`、`onAllMemberMuteStateChanged(roomId, isMuted)`、`onAdminAdded(roomId, adminId)`、`onAdminRemoved(roomId, adminId)`、`onOwnerChanged(roomId, newOwner, oldOwner)`、`onAnnouncementChanged(roomId, announcement)`、`onSpecificationChanged(room)`、`onAttributesUpdate(roomId, attributeMap, from)`、`onAttributesRemoved(roomId, keys, from)`。枚举 `LEAVE_REASON`（BE_KICK/ROOM_DESTROYED/BE_KICKED_FOR_OFFLINE）。

### 14.5 ContactListener（联系人，8 个回调，全部可选）

`onContactAdded(userId)`、`onContactDeleted(userId)`、`onContactInvited(userId, reason)`、`onFriendRequestAccepted(userId)`、`onFriendRequestDeclined(userId)`、`onContactSyncStart()`、`onContactSyncFinishWithError(errorCode, error)`、`onContactInfoUpdate(contact)`。

### 14.6 MultiDevicesListener（多设备，4 个回调）

| 回调 | 签名 |
|---|---|
| `onContactEvent`（必选） | `(event: MultiDevicesEvent, target: string, ext: string) => void` |
| `onGroupEvent`（必选） | `(event: MultiDevicesEvent, target: string, userIds: Array<string>) => void` |
| `onMessageRemoved`（必选） | `(conversationId: string, deviceId: string) => void` |
| `onConversationEvent` | `(event: MultiDevicesEvent, conversationId: string, type: ConversationType) => void` |

枚举 `MultiDevicesEvent`：CONTACT_*（2–6）、GROUP_*（10–33）、CONVERSATION_*（60–64），共 36 个值。

### 14.7 ConversationListener（会话，2 个回调）

`onConversationUpdate()`（可选）、`onConversationRead(from, to)`（必选）。

### 14.8 PushListener（推送，2 个回调，均必选）

`onBindTokenSuccess(token: string)`、`onError(error: ChatError)`。

### 14.9 PresenceListener（在线状态，1 个回调，必选）

`onPresenceUpdated(presences: Array<Presence>)`。

### 14.10 UserInfoListener（用户信息，2 个回调，均可选）

`onSelfUserInfoUpdate(userInfo)`、`onUserInfoUpdate(userInfoList)`。

### 14.11 ChatCallback（通用回调，3 个，均可选）

`onSuccess()`、`onError(code: number, error: string)`、`onProgress(progress: number)`。用于消息状态回调、群共享文件上传/下载进度等。

## 15. 数据模型类清单（只列类名）

- 基础：`ChatBase<T>`（多数模型/管理类的基类）、`CursorResult<T>`、`PageResult<T>`
- 配置/参数：`ChatOptions`、`AppParam`（interface）、`ChatOptionsParam`（interface）、`ChatAudioParams`（含 `ChatAudioFormat` 枚举）、`GroupOptions`、`FetchMessageOption`、`MessageSearchOption`（含 `KeywordListMatchType` 枚举）、`ConversationFilter`、`CombineMessageParams`、`FetchReactionDetailParams`、`SetChatroomAttributeParams`（interface）、`RemoveChatroomAttributeParams`（interface）、`SilentModeTimeParam` / `SilentIntervalTypeParam` / `SilentDurationTypeParam`（interface）、`SilentModeParam`（type 别名 = `PushRemindType | SilentIntervalTypeParam`）、`FetchHistoryMessagesParam`（interface）、`SearchMessagesFromServerParam`（interface）、`SearchOptions`（interface）
- 会话/群组/聊天室：`Conversation`、`Group`（含 `GroupPermissionType`、`GroupLeaveReason` 枚举）、`GroupMember`、`SharedFile`、`Chatroom`、`ChatroomAttributesResult`
- 联系人/用户：`Contact`、`UserInfo`（含 `Gender`、`UserInfoType` 枚举）、`Presence`
- 消息：见 11.2 / 11.3
- 推送/免打扰：`SilentModeTime`、`SilentModeResult`
- 其他：`TranslationLanguage`（interface）、`SearchServerMessageResult`、`LoginExtInfo`

## 16. 备注与不确定项

1. **返回类型以 `.d.ets` 声明为准**。多处 JSDoc 与声明签名不一致（已在表中用 ⚠️ 标出），如 `joinChatroom` 声明返回 `Promise<Chatroom>` 而 JSDoc 写 `Promise<void>`；`GroupManager` 多个写操作方法声明返回 `Promise<Group>` 而 JSDoc 写 `Promise<void>`。
2. **疑似内部方法**：`PushManager.notifyPushResult`（JSDoc 注明内部使用）、`ChatMessage.setDelivered` / `setGroupAckCount` / `setBroadcast` / `setRecaller`（JSDoc 注明内部使用）、`ChatManager.checkAttachmentBeforeDownload`、`ChatOptions.setConfig`（参数类型在 internal 目录）。重写时建议不纳入公开 API。
3. **无 ChatThreadManager（子区）**：1.15.0 的 `Index.d.ets` 未导出任何 Thread 相关模块，鸿蒙 SDK 当前不支持消息子区功能。
4. **无独立 ConversationManager**：会话能力合并于 `ChatManager` + `Conversation` 类。
5. **`util/`、`internal/`、`param/` 目录**：`Index.d.ets` 只导出了 `util/ChatLog` 和 `param/MethodParams`；`internal/*` 与 `util/` 其余文件（ChatUtils、JsonUtils、ChatFileHelper 等）未从包入口导出，属内部实现，未计入公开 API。
6. **native 层声明**：`src/main/cpp/types/libhyphenate/*.d.ts` 是 C++ native 层（EM* 前缀类）的绑定声明，ArkTS 重写若以该 native 库为底座需另作盘点，不在本文范围。
7. 统计数字由人工逐一清点声明文件得出，方法数可能有 ±1 的误差；类/接口/枚举数以 `grep "export declare"` 结果为准。
