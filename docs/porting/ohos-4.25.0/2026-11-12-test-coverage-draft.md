# ohos 4.25.0 integration_test 全量覆盖清单（草稿）

- 生成日期：2026-11-12
- 分支 / 基线：`ohos`，HEAD `d2772e3f`（Flutter SDK 4.25.0）
- 目标结构：`im_flutter_sdk/example/integration_test/` 重写为「5 个稳定入口 + `modules/` + `support/`」，参考 5.1.0 分支组织方式（仅参考结构）
- 执行环境：HarmonyOS 模拟器，账号 `zuoyu01` / `zuoyu02`，token 登录
- 来源（以源码为准）：`docs/porting/ohos-4.25.0/01-flutter-api-surface.md`、`01-chatsdk-api-surface.md`、`02-gap-ledger.md`（§16.1、§17）及 `im_flutter_sdk/lib/src/**` 实际声明
- 源码位置列省略公共前缀 `im_flutter_sdk/lib/src/`

## 1. 统计摘要

| 指标 | 数量 | 说明 |
|---|---|---|
| 计划覆盖公开 API 行 | **248** | manager 业务方法 219 + `ChatConversation` 24 + `ChatMessage` 4 + 公开字段 `customEventHandler` 1 |
| 其中事件注册方法 | 35 | 已移入「事件」域统计，不重复计入上面的 248 |
| 事件回调（`addEventHandler` 可注册） | **86** | Connection 13 / MultiDevice 4 / Chat 14 / Room 16 / Contact 8 / Group 28 / Presence 1 / UserInfo 2 |
| 事件回调（发送进度 `ChatMessageEvent`，非注册式） | 3 | `onSuccess` / `onError` / `onProgress` |
| 公开方法总数（含注册方法） | **282** | 247 个方法（248 行 − 1 个字段）+ 35 个注册方法；另有 1 个公开字段 `customEventHandler` |
| D17 已移除并排除 | **50** | 42 个方法 key（38 个实际 Dart 方法 + 4 个孤儿常量）+ 8 个事件 key（6 个回调 + 2 个孤儿常量） |
| 计划负向 / 边界补充用例 | 24 | 见各域表 `negative` 行 |
| 预计用例总数 | **407** | 表格 396 行（248 API + 24 负向 + 124 事件）+ 现有用例 13 条 − 重合 2 条（FL-APP-001、FL-AUTH-001） |

### 分域数量

| 域 | API 行 | 负向补充 | 本域小计 | 事件注册（计入事件域） | 事件回调（计入事件域） | 主要目标入口 |
|---|---:|---:|---:|---:|---:|---|
| 认证 / Client | 37 | 4 | 41 | 8 | — | logged_out + logged_in_base |
| 联系人 | 20 | 3 | 23 | 4 | — | logged_in_contact |
| 消息 | 58 | 4 | 62 | 7 | — | logged_in_base |
| 会话 | 24 | 3 | 27 | 0 | — | logged_in_base |
| 群组 | 56 | 4 | 60 | 4 | — | logged_in_group |
| 聊天室 | 28 | 3 | 31 | 4 | — | 特殊配置（房主账号 / REST 建房） |
| Push | 12 | 1 | 13 | 0 | — | 特殊配置（真机 + 推送证书） |
| UserInfo | 8 | 2 | 10 | 4 | — | logged_in_user_info |
| Presence | 5 | 0 | 5 | 4 | — | logged_in_base |
| 事件 | — | — | 124 | （35） | 89（含 3 个 `ChatMessageEvent`） | 按事件所属域 |
| 模型 | 0 | 0 | 0 | — | — | 仅类清单（§3.11） |
| **合计** | **248** | **24** | **396** | **35** | **89** | — |

> 说明：`ChatMessageEvent` 3 个进度回调计入「事件」域行数（EVENT-067~069），其触发场景写在「消息」域用例（FL-MSG-001 等）中。

## 2. 字段与编号约定

- **源码位置**：`file:line` 为类级声明起始行，多行签名取首行；行号随代码变动，diff 后需重新核对。
- **目标入口**：`logged_out` = `logged_out_test.dart`；`base` = `logged_in_base_test.dart`；`contact` = `logged_in_contact_test.dart`；`group` = `logged_in_group_test.dart`；`userinfo` = `logged_in_user_info_test.dart`；`特殊` = 需独立 dart-define / 独立进程配置（真机推送、短 TTL token、多端、聊天室房主、505 增值服务）。
- **断言类型**：
  - `server-positive`：调用成功且服务端状态/返回值符合预期，需要真实服务端；
  - `local`：仅校验本地返回值、本地 DB 或纯 Dart 对象，不依赖服务端写操作；
  - `event`：以事件回调收到且字段正确为断言主体；
  - `negative`：预期抛 `ChatError` 或返回错误，断言错误码。
- **依赖准备**：`—` 无；`peer` = zuoyu02 在线且可响应；`group` = 预置群（zuoyu01 为群主，zuoyu02 为成员）；`room` = 预置聊天室；`REST` = 需 REST/控制台夹具（建号、建群、建聊天室、改配置、发 token）；`多端` = 同账号第二端在线。
- **505 allowlist**：服务端返回 505 表示增值服务未开通，用例按 skip 处理而非 fail；标记在备注列。
- **弃用**：`@Deprecated` 方法保留 1 条冒烟用例，不铺开参数矩阵。
- **不列项**：`fromJson` / `toJson` 等纯序列化工具、`lib/src/internal/chat_method_keys.dart` 内部常量、`em_compat.dart` 的 `EM*` 别名均不写用例。
- **编号冲突规避**：现有 13 条用例占用 `FL-APP-001`、`FL-AUTH-001`、`FL-PRESENCE-001~005`、`FL-CONV-001~006`；本清单从 `FL-CONV-007`、`FL-PRESENCE-006`、`FL-AUTH-002` 起续编，不重号。

## 3. 分域清单

### 3.1 认证 / Client（`managers/chat_client.dart`）

| API（Dart 签名简写） | 源码位置 | 建议 case ID | 目标入口 | 断言类型 | 依赖准备 | 备注 |
|---|---|---|---|---|---|---|
| `getInstance()` | chat_client.dart:18 | FL-CLIENT-001 | logged_out | local | — | 单例恒等 |
| `chatManager` | chat_client.dart:196 | FL-CLIENT-002 | logged_out | local | — | 非空 |
| `contactManager` | chat_client.dart:197 | FL-CLIENT-003 | logged_out | local | — | 非空 |
| `chatRoomManager` | chat_client.dart:199 | FL-CLIENT-004 | logged_out | local | — | 非空 |
| `groupManager` | chat_client.dart:200 | FL-CLIENT-005 | logged_out | local | — | 非空 |
| `pushManager` | chat_client.dart:201 | FL-CLIENT-006 | logged_out | local | — | 非空 |
| `presenceManager` | chat_client.dart:202 | FL-CLIENT-007 | logged_out | local | — | 非空 |
| `userInfoManager` | chat_client.dart:204 | FL-CLIENT-008 | logged_out | local | — | 非空 |
| `currentUserId` | chat_client.dart:207 | FL-CLIENT-009 | logged_in_base | local | — | 登录前 `null`，登录后等于入参 |
| `options` | chat_client.dart:210 | FL-CLIENT-010 | logged_out | local | — | `appKey` 与 dart-define 一致 |
| `customEventHandler`（公开字段） | chat_client.dart:216 | FL-CLIENT-011 | logged_in_base | local | — | 依赖 `onSendDataToFlutter`，ArkTS 侧未实现 → 预期不触发（记录为已知缺口） |
| `startCallback()` | chat_client.dart:373 | FL-CLIENT-012 | logged_in_base | local | — | ArkTS 空实现，仅校验不抛错、不阻塞登录 |
| `isConnected` | chat_client.dart:396 | FL-CLIENT-013 | logged_in_base | local | — | 登录后 true，logout 后 false |
| `getCurrentUserId()` | chat_client.dart:419 | FL-CLIENT-014 | logged_in_base | local | — | 与 token 对应用户一致 |
| `getAccessToken()` | chat_client.dart:445 | FL-CLIENT-015 | logged_in_base | local | — | 与传入 token 一致 |
| `getCurrentDeviceId()` | chat_client.dart:467 | FL-CLIENT-016 | logged_in_base | local | — | 非空且同一会话内稳定；chatsdk 无 deviceId 概念，由 wrapper 生成（存疑 §5） |
| `init(options)` | chat_client.dart:491 | FL-APP-001 | 特殊 | local | — | 已存在用例；含 appKey、自动登录等开关 |
| `createAccount(userId, password)` | chat_client.dart:527 | FL-AUTH-002 | logged_out | server-positive | REST | 随机 uid，避免脏数据；重复注册见 FL-AUTH-020 |
| `login(userId, pwdOrToken, isPassword)` | chat_client.dart:573 | FL-AUTH-003 | logged_out | server-positive | — | `@Deprecated`（:539），仅冒烟 |
| `loginWithToken(userId, token)` | chat_client.dart:650 | FL-AUTH-004 | logged_out | server-positive | — | 主用登录方式；多入口重复登录幂等 |
| `loginWithPassword(userId, password)` | chat_client.dart:684 | FL-AUTH-001 | logged_out | server-positive | — | 已存在用例 |
| `renewAgoraToken(token)` | chat_client.dart:709 | FL-AUTH-005 | logged_in_base | server-positive | REST | 需有效 Agora token 夹具；chatsdk 无 Agora 续期语义（存疑 §5） |
| `logout([unbindDeviceToken])` | chat_client.dart:740 | FL-AUTH-006 | logged_in_base | server-positive | — | 之后 `isConnected == false`、`currentUserId == null` |
| `changeAppKey(newAppKey)` | chat_client.dart:777 | FL-AUTH-007 | logged_out | server-positive | REST | 需备用 appKey；登录态调用为负向（FL-AUTH-022） |
| `changeAppId(newAppId)` | chat_client.dart:812 | FL-AUTH-008 | logged_out | server-positive | REST | `appId` 与 `appKey` 语义待确认（存疑 §5） |
| `updateUsingHttpsOnlySetting(enable)` | chat_client.dart:825 | FL-CLIENT-020 | logged_out | local | — | 配置项是否落盘待确认（存疑 §5） |
| `updateLoginExtensionInfoSetting(enable)` | chat_client.dart:844 | FL-CLIENT-021 | logged_out | local | — | 同上 |
| `updateDeleteMessagesWhenLeaveGroupSetting(enable)` | chat_client.dart:856 | FL-CLIENT-022 | logged_out | local | — | 同上 |
| `updateDeleteMessageWhenLeaveRoomSetting(enable)` | chat_client.dart:870 | FL-CLIENT-023 | logged_out | local | — | 同上 |
| `updateAutoAcceptGroupInvitationSetting(enable)` | chat_client.dart:884 | FL-CLIENT-024 | logged_out | local | — | 同上 |
| `updateAutoAcceptFriendInvitationSetting(enable)` | chat_client.dart:898 | FL-CLIENT-025 | logged_out | local | — | 同上 |
| `updateAutoDownloadAttachmentThumbnailSetting(enable)` | chat_client.dart:912 | FL-CLIENT-026 | logged_out | local | — | 同上 |
| `updateRequireAckSetting(enable)` | chat_client.dart:926 | FL-CLIENT-027 | logged_out | local | — | 同上 |
| `updateDeliveryAckSetting(enable)` | chat_client.dart:938 | FL-CLIENT-028 | logged_out | local | — | 同上 |
| `updateSortMessageByServerTimeSetting(enable)` | chat_client.dart:950 | FL-CLIENT-029 | logged_out | local | — | 同上 |
| `updateMessagesReceiveCallbackIncludeSendSetting(enable)` | chat_client.dart:964 | FL-CLIENT-030 | logged_out | local | — | 同上 |
| `updateRegradeMessagesAsReadSetting(enable)` | chat_client.dart:978 | FL-CLIENT-031 | logged_out | local | — | 同上 |
| `login(userId, "wrong-password", true)` | chat_client.dart:573 | FL-AUTH-020 | logged_out | negative | — | 断言错误码（密码错误），不得产生登录态 |
| `createAccount(已有 userId, pwd)` | chat_client.dart:527 | FL-AUTH-021 | logged_out | negative | REST | 已存在用户注册 → 断言错误码 |
| `changeAppKey(登录态)` | chat_client.dart:777 | FL-AUTH-022 | logged_in_base | negative | — | 登录态切换 appKey 应失败或无效 |
| `getAccessToken()`（未登录） | chat_client.dart:445 | FL-CLIENT-040 | logged_out | negative | — | 空串 / null / 抛错三者之一，需固化契约 |

> 事件注册方法（`addConnectionEventHandler` 等 8 个）见 §3.10，不在本表重复计数。

### 3.2 联系人（`managers/chat_contact_manager.dart`）

| API（Dart 签名简写） | 源码位置 | 建议 case ID | 目标入口 | 断言类型 | 依赖准备 | 备注 |
|---|---|---|---|---|---|---|
| `addContact(userId, {reason})` | chat_contact_manager.dart:157 | FL-CONTACT-001 | logged_in_contact | server-positive | peer | 添加后服务端好友列表含对端 |
| `deleteContact(userId, {keepConversation})` | chat_contact_manager.dart:198 | FL-CONTACT-002 | logged_in_contact | server-positive | peer | 删除后 `getAllContactsFromDB` 不含对端 |
| `getAllContactsFromServer()` | chat_contact_manager.dart:229 | FL-CONTACT-003 | logged_in_contact | server-positive | peer | 与 `fetchAllContacts` 共用能力，保留 1 条冒烟 |
| `fetchAllContactIds()` | chat_contact_manager.dart:262 | FL-CONTACT-004 | logged_in_contact | server-positive | peer | 4.x 新 API，主覆盖 |
| `getAllContactsFromDB()` | chat_contact_manager.dart:296 | FL-CONTACT-005 | logged_in_contact | local | — | 本地 DB 读取 |
| `getAllContactIds()` | chat_contact_manager.dart:330 | FL-CONTACT-006 | logged_in_contact | local | — | 本地 DB 读取 |
| `addUserToBlockList(userId)` | chat_contact_manager.dart:366 | FL-CONTACT-007 | logged_in_contact | server-positive | peer | 拉黑后对端发消息不落会话（可断言本地无新会话） |
| `removeUserFromBlockList(userId)` | chat_contact_manager.dart:398 | FL-CONTACT-008 | logged_in_contact | server-positive | peer | 解除后恢复 |
| `getBlockListFromServer()` | chat_contact_manager.dart:426 | FL-CONTACT-009 | logged_in_contact | server-positive | peer | 黑名单含对端 |
| `fetchBlockIds()` | chat_contact_manager.dart:459 | FL-CONTACT-010 | logged_in_contact | server-positive | peer | 新 API，主覆盖 |
| `getBlockListFromDB()` | chat_contact_manager.dart:493 | FL-CONTACT-011 | logged_in_contact | local | — | 本地 DB |
| `getBlockIds()` | chat_contact_manager.dart:526 | FL-CONTACT-012 | logged_in_contact | local | — | 本地 DB |
| `acceptInvitation(userId)` | chat_contact_manager.dart:559 | FL-CONTACT-013 | logged_in_contact | server-positive | peer | 需对端先 `addContact` 造出 pending 邀请 |
| `declineInvitation(userId)` | chat_contact_manager.dart:586 | FL-CONTACT-014 | logged_in_contact | server-positive | peer | 同上 |
| `getSelfIdsOnOtherPlatform()` | chat_contact_manager.dart:613 | FL-CONTACT-015 | 特殊 | server-positive | 多端 | 同账号第二端在线后返回其 id；模拟器单端时返回空列表 |
| `getAllContacts()` | chat_contact_manager.dart:644 | FL-CONTACT-016 | logged_in_contact | local | peer | 返回 `Map<String, ChatContact>` |
| `setContactRemark(userId, remark)` | chat_contact_manager.dart:671 | FL-CONTACT-017 | logged_in_contact | server-positive | peer | 备注回读一致 |
| `getContact(userId)` | chat_contact_manager.dart:705 | FL-CONTACT-018 | logged_in_contact | local | peer | 未命中返回 null |
| `fetchAllContacts({cursor, pageSize})` | chat_contact_manager.dart:737 | FL-CONTACT-019 | logged_in_contact | server-positive | peer | 游标分页：首页后有 cursor |
| `fetchContacts({cursor, pageSize})` | chat_contact_manager.dart:776 | FL-CONTACT-020 | logged_in_contact | server-positive | peer | 分页游标串接，重复项去重 |
| `addContact(自己)` | chat_contact_manager.dart:157 | FL-CONTACT-021 | logged_in_contact | negative | — | 断言错误码 |
| `addContact(不存在的 userId)` | chat_contact_manager.dart:157 | FL-CONTACT-022 | logged_in_contact | negative | — | 断言错误码 |
| `acceptInvitation(无 pending 的 userId)` | chat_contact_manager.dart:559 | FL-CONTACT-023 | logged_in_contact | negative | — | 断言错误码 / 幂等成功二选一，需固化契约 |

> 事件注册 4 个方法见 §3.10（EVENT-009~012）。

### 3.3 消息（`managers/chat_manager.dart` + `models/chat_message.dart`）

| API（Dart 签名简写） | 源码位置 | 建议 case ID | 目标入口 | 断言类型 | 依赖准备 | 备注 |
|---|---|---|---|---|---|---|
| `sendMessage(msg)` | chat_manager.dart:353 | FL-MSG-001 | logged_in_base | server-positive | peer | 对端 `onMessagesReceived` 收到且 body 一致；同时覆盖 `ChatMessageEvent.onSuccess`（EVENT-067） |
| `resendMessage(msg)` | chat_manager.dart:384 | FL-MSG-002 | logged_in_base | server-positive | peer | 复用 sendMessage；需构造一次失败消息或直接重发 |
| `sendMessageReadAck(msgId)` | chat_manager.dart:435 | FL-MSG-003 | logged_in_base | server-positive | peer | 对端 `onMessagesRead` 触发（EVENT-056） |
| `sendGroupMessageReadAck(msgId, groupId, {content})` | chat_manager.dart:480 | FL-MSG-004 | logged_in_group | server-positive | group | 群已读；对端 `onGroupMessageRead` / `onReadAckForGroupMessageUpdated` |
| `sendConversationReadAck(conversationId)` | chat_manager.dart:525 | FL-MSG-005 | logged_in_base | server-positive | peer | 对端 `onConversationRead`（EVENT-063） |
| `recallMessage(msgId, {ext})` | chat_manager.dart:551 | FL-MSG-006 | logged_in_base | server-positive | peer | 2 分钟内消息；对端 `onMessagesRecalled` |
| `loadMessage(msgId)` | chat_manager.dart:582 | FL-MSG-007 | logged_in_base | local | peer | 先发一条再按 id 读 |
| `loadMessagesWithIds(ids, conversationId)` | chat_manager.dart:622 | FL-MSG-008 | logged_in_base | local | peer | 批量读，含不存在 id 的容错 |
| `getConversation(id, {type, createIfNeed})` | chat_manager.dart:681 | FL-MSG-009 | logged_in_base | local | — | 不存在且 `createIfNeed=false` 返回 null |
| `markAllConversationsAsRead()` | chat_manager.dart:721 | FL-MSG-010 | logged_in_base | local | peer | 未读数全部归零 |
| `getUnreadMessageCount()` | chat_manager.dart:746 | FL-MSG-011 | logged_in_base | local | peer | 发消息后未读 +1，标记已读后归零 |
| `updateMessage(msg)` | chat_manager.dart:776 | FL-MSG-012 | logged_in_base | local | peer | 仅本地更新（如 ext），不触达服务端 |
| `importMessages(msgs)` | chat_manager.dart:809 | FL-MSG-013 | logged_in_base | local | — | 导入后会话可查到 |
| `downloadAttachment(msg)` | chat_manager.dart:843 | FL-MSG-014 | logged_in_base | server-positive | peer | 需图片/文件消息；断言本地路径存在 |
| `downloadThumbnail(msg)` | chat_manager.dart:869 | FL-MSG-015 | logged_in_base | server-positive | peer | 同上，缩略图路径 |
| `downloadMessageAttachmentInCombine(msg)` | chat_manager.dart:899 | FL-MSG-016 | logged_in_base | server-positive | peer | 需合并消息夹具（REST 或先发 2 条再合并） |
| `downloadMessageThumbnailInCombine(msg)` | chat_manager.dart:925 | FL-MSG-017 | logged_in_base | server-positive | peer | 同上 |
| `loadAllConversations()` | chat_manager.dart:955 | FL-MSG-018 | logged_in_base | local | — | 与 `fetchConversationsFromDB` 结果一致 |
| `getConversationsFromServer()` | chat_manager.dart:987 | FL-MSG-019 | logged_in_base | server-positive | peer | 清本地后拉回会话 |
| `fetchConversation({cursor, pageSize})` | chat_manager.dart:1033 | FL-MSG-020 | logged_in_base | server-positive | peer | 游标分页 |
| `deleteRemoteMessagesWithIds(convId, ids)` | chat_manager.dart:1075 | FL-MSG-021 | logged_in_base | server-positive | peer | 服务端删除，重新拉取不含 |
| `deleteRemoteMessagesBefore(convId, ts)` | chat_manager.dart:1113 | FL-MSG-022 | logged_in_base | server-positive | peer | 需可控时间戳 |
| `deleteConversation(convId, {deleteMessages})` | chat_manager.dart:1163 | FL-MSG-023 | logged_in_base | local | — | 本地删会话，消息按开关保留/删除 |
| `fetchHistoryMessages(...)` | chat_manager.dart:1215 | FL-MSG-024 | logged_in_base | server-positive | peer | `@Deprecated`（:1178），冒出 1 条 |
| `fetchHistoryMessagesByOption(...)` | chat_manager.dart:1270 | FL-MSG-025 | logged_in_base | server-positive | peer | 新 API 主覆盖：方向 + 时间窗 |
| `loadMessagesWithKeyword(...)` | chat_manager.dart:1343 | FL-MSG-026 | logged_in_base | local | peer | `@Deprecated`（:1373），1 条冒烟 |
| `searchMsgFromDB(...)` | chat_manager.dart:1411 | FL-MSG-027 | logged_in_base | local | peer | 本地 DB 搜索；`@Deprecated`（:1373） |
| `fetchGroupAcks(msgId, groupId, {startTs, endTs})` | chat_manager.dart:1474 | FL-MSG-028 | logged_in_group | server-positive | group | 群已读回执列表 |
| `deleteRemoteConversation(convId)` | chat_manager.dart:1532 | FL-MSG-029 | logged_in_base | server-positive | peer | 服务端删会话 |
| `addReaction(msgId, reaction)` | chat_manager.dart:1576 | FL-MSG-030 | logged_in_base | server-positive | peer | 505 allowlist；对端 `onMessageReactionDidChange` |
| `removeReaction(msgId, reaction)` | chat_manager.dart:1610 | FL-MSG-031 | logged_in_base | server-positive | peer | 505 allowlist |
| `fetchReactionList(...)` | chat_manager.dart:1652 | FL-MSG-032 | logged_in_base | server-positive | peer | 505 allowlist |
| `fetchReactionDetail(...)` | chat_manager.dart:1715 | FL-MSG-033 | logged_in_base | server-positive | peer | 505 allowlist |
| `translateMessage(msgId, languages)` | chat_manager.dart:1772 | FL-MSG-034 | logged_in_base | server-positive | peer | 505 allowlist（翻译增值服务） |
| `fetchSupportedLanguages()` | chat_manager.dart:1805 | FL-MSG-035 | logged_in_base | server-positive | — | 505 allowlist |
| `fetchPinnedConversations()` | chat_manager.dart:1849 | FL-MSG-036 | logged_in_base | server-positive | peer | 需先 `pinConversation`（FL-MSG-038） |
| `fetchConversationsFromDB()` | chat_manager.dart:1913 | FL-MSG-037 | logged_in_base | local | — | 与 `loadAllConversations` 对齐 |
| `pinConversation(convId, isPinned)` | chat_manager.dart:1962 | FL-MSG-038 | logged_in_base | server-positive | peer | 置顶后 `fetchPinnedConversations` 含该会话 |
| `modifyMessage(...)` | chat_manager.dart:2017 | FL-MSG-039 | logged_in_base | server-positive | peer | 需服务端支持，是否增值服务待确认（存疑 §5） |
| `fetchCombineMessageDetail(msg)` | chat_manager.dart:2059 | FL-MSG-040 | logged_in_base | local | peer | 需合并消息夹具；解析出的消息列表非空 |
| `addRemoteAndLocalConversationsMark(convIds, mark)` | chat_manager.dart:2112 | FL-MSG-041 | logged_in_base | server-positive | peer | 标记同步（服务端），4.25 新能力 |
| `deleteRemoteAndLocalConversationsMark(convIds, mark)` | chat_manager.dart:2151 | FL-MSG-042 | logged_in_base | server-positive | peer | 取消标记 |
| `fetchConversationsByOptions(options)` | chat_manager.dart:2187 | FL-MSG-043 | logged_in_base | server-positive | peer | 按标记/置顶过滤 |
| `deleteAllMessageAndConversation({clearServerData})` | chat_manager.dart:2220 | FL-MSG-044 | logged_in_base | server-positive | — | **破坏性**，放该入口最后执行；`clearServerData=true` 需独立账号 |
| `pinMessage(msgId, isPinned)` | chat_manager.dart:2247 | FL-MSG-045 | logged_in_base | server-positive | peer | 505 待确认（存疑 §5） |
| `unpinMessage(msgId)` | chat_manager.dart:2276 | FL-MSG-046 | logged_in_base | server-positive | peer | 同上 |
| `fetchPinnedMessages(convId)` | chat_manager.dart:2305 | FL-MSG-047 | logged_in_base | server-positive | peer | 同上 |
| `searchMsgsByOptions(options)` | chat_manager.dart:2348 | FL-MSG-048 | logged_in_base | server-positive | peer | 505 allowlist（关键词/搜索增值） |
| `getAllMessageCount()` | chat_manager.dart:2386 | FL-MSG-049 | logged_in_base | local | — | 与本地库计数一致 |
| `loadConversationMessagesWithKeyword(...)` | chat_manager.dart:2436 | FL-MSG-050 | logged_in_base | server-positive | peer | 505 allowlist |
| `downloadBigImage(msg)` | chat_manager.dart:2488 | FL-MSG-051 | logged_in_base | server-positive | peer | 需大图消息夹具 |
| `voiceMessageToText(msgId)` | chat_manager.dart:2518 | FL-MSG-052 | logged_in_base | server-positive | peer | 505 allowlist（语音转文字） |
| `voiceFileToText(filePath)` | chat_manager.dart:2553 | FL-MSG-053 | logged_in_base | server-positive | — | 505 allowlist；需本地语音文件 |
| `searchMessagesFromServer({option, pageSize, pageNum})` | chat_manager.dart:2602 | FL-MSG-054 | logged_in_base | server-positive | peer | 505 allowlist；分页与过滤条件 |
| `ChatMessage.pinInfo() → Future<MessagePinInfo?>` | chat_message.dart:320 | FL-MSG-055 | logged_in_base | local | peer | 需先 `pinMessage`（FL-MSG-045）；`msgId` 为空时返回 null |
| `ChatMessage.reactionList() → Future<List<ChatMessageReaction>>` | chat_message.dart:1064 | FL-MSG-056 | logged_in_base | local | peer | 需先 `addReaction`（FL-MSG-030） |
| `ChatMessage.groupAckCount() → Future<int>` | chat_message.dart:1100 | FL-MSG-057 | logged_in_group | local | group | 群消息已读人数 |
| `ChatMessage.dispose()` | chat_message.dart:425 | FL-MSG-058 | logged_in_base | local | — | 释放原生资源；释放后访问字段不崩溃 |
| `sendMessage(空文本)` | chat_manager.dart:353 | FL-MSG-059 | logged_in_base | negative | — | 断言 `ChatError` 或服务端拒绝 |
| `sendMessage(to: 不存在的 userId)` | chat_manager.dart:353 | FL-MSG-060 | logged_in_base | negative | — | 断言错误码 |
| `fetchHistoryMessages(不存在的 convId)` | chat_manager.dart:1215 | FL-MSG-061 | logged_in_base | negative | — | 返回空列表或错误，需固化契约 |
| `recallMessage(超过 2 分钟的消息)` | chat_manager.dart:551 | FL-MSG-062 | logged_in_base | negative | peer | 断言错误码 |

> 消息事件注册 7 个方法（含 3 个 `*MessageEvent`）见 §3.10（EVENT-013~019）；`ChatMessageEvent` 3 个进度回调见 EVENT-067~069。
> 说明：`ChatMessage` 的同步 getter（`msgId`、`chatroomMessagePriority` 等）与 10 个 `create*` 静态工厂归入 §3.11 模型清单，不单列用例；其正确性由 FL-MSG-001 等发送用例间接覆盖。

### 3.4 会话（`models/chat_conversation.dart`）

| API（Dart 签名简写） | 源码位置 | 建议 case ID | 目标入口 | 断言类型 | 依赖准备 | 备注 |
|---|---|---|---|---|---|---|
| `ext`（getter） | chat_conversation.dart:187 | FL-CONV-007 | logged_in_base | local | peer | 需先 `setExt` |
| `setExt(ext)` | chat_conversation.dart:199 | FL-CONV-008 | logged_in_base | server-positive | peer | 写回后 `ext` 可读；重启进程后仍在（落盘验证） |
| `latestMessage` | chat_conversation.dart:231 | FL-CONV-009 | logged_in_base | local | peer | 与最后发送消息 id 一致 |
| `lastReceivedMessage` | chat_conversation.dart:258 | FL-CONV-010 | logged_in_base | local | peer | 只统计接收方向 |
| `unreadCount` | chat_conversation.dart:290 | FL-CONV-011 | logged_in_base | local | peer | 收 2 条后为 2 |
| `markMessageAsRead(msgId)` | chat_conversation.dart:321 | FL-CONV-012 | logged_in_base | local | peer | 未读数递减 |
| `markAllMessagesAsRead()` | chat_conversation.dart:340 | FL-CONV-013 | logged_in_base | local | peer | 未读归零 |
| `insertMessage(msg)` | chat_conversation.dart:367 | FL-CONV-014 | logged_in_base | local | — | 插入位置与时间序正确 |
| `appendMessage(msg)` | chat_conversation.dart:398 | FL-CONV-015 | logged_in_base | local | — | 追加到末尾 |
| `updateMessage(msg)` | chat_conversation.dart:429 | FL-CONV-016 | logged_in_base | local | peer | 更新后重查生效 |
| `deleteMessage(msgId)` | chat_conversation.dart:460 | FL-CONV-017 | logged_in_base | local | peer | 仅本地删除，服务端仍可拉回 |
| `deleteAllMessages()` | chat_conversation.dart:483 | FL-CONV-018 | logged_in_base | local | peer | 本地清空 |
| `loadMessage(msgId)` | chat_conversation.dart:516 | FL-CONV-019 | logged_in_base | local | peer | 存在/不存在两种 |
| `loadMessagesWithMsgType(...)` | chat_conversation.dart:575 | FL-CONV-020 | logged_in_base | local | peer | 按类型过滤（文本/图片） |
| `loadMessages(...)` | chat_conversation.dart:637 | FL-CONV-021 | logged_in_base | local | peer | 时间倒序 + 条数上限 |
| `loadMessagesWithKeyword(...)` | chat_conversation.dart:708 | FL-CONV-022 | logged_in_base | local | peer | `sender` 参数已弃用（:710），用 `senders` |
| `loadMessagesFromTime(...)` | chat_conversation.dart:773 | FL-CONV-023 | logged_in_base | local | peer | 起止时间窗 |
| `messagesCount` | chat_conversation.dart:805 | FL-CONV-024 | logged_in_base | local | peer | 与 `getLocalMessageCount` 一致 |
| `loadPinnedMessages()` | chat_conversation.dart:833 | FL-CONV-025 | logged_in_base | local | peer | 需先置顶消息（FL-MSG-045） |
| `remindType` | chat_conversation.dart:863 | FL-CONV-026 | logged_in_base | local | — | 静默模式设置后回读（关联 FL-PUSH-004） |
| `searchMsgsByOptions(options)` | chat_conversation.dart:895 | FL-CONV-027 | logged_in_base | local | peer | 本地搜索，多条件组合 |
| `getLocalMessageCount()` | chat_conversation.dart:948 | FL-CONV-028 | logged_in_base | local | peer | 与 `messagesCount` 对齐 |
| `deleteLocalAndServerMessages(msgIds)` | chat_conversation.dart:985 | FL-CONV-029 | logged_in_base | server-positive | peer | 双端删除后重新拉取不含 |
| `deleteLocalAndServerMessagesByTime(...)` | chat_conversation.dart:1019 | FL-CONV-030 | logged_in_base | server-positive | peer | 时间窗删除 |
| `loadMessagesFromTime(start > end)` | chat_conversation.dart:773 | FL-CONV-031 | logged_in_base | negative | — | 空结果或错误，需固化契约 |
| `deleteMessage(不存在的 msgId)` | chat_conversation.dart:460 | FL-CONV-032 | logged_in_base | negative | — | 幂等成功或抛错，需固化契约 |
| `insertMessage(已存在 msgId)` | chat_conversation.dart:367 | FL-CONV-033 | logged_in_base | negative | peer | 去重行为，不得产生重复行 |

### 3.5 群组（`managers/chat_group_manager.dart`）

| API（Dart 签名简写） | 源码位置 | 建议 case ID | 目标入口 | 断言类型 | 依赖准备 | 备注 |
|---|---|---|---|---|---|---|
| `getGroupWithId(groupId)` | chat_group_manager.dart:289 | FL-GROUP-001 | logged_in_group | local | group | 未加入时返回 null |
| `getJoinedGroups()` | chat_group_manager.dart:320 | FL-GROUP-002 | logged_in_group | local | group | 含预置群 |
| `fetchJoinedGroupsFromServer({pageSize, pageNum, needMemberCount, needRole})` | chat_group_manager.dart:359 | FL-GROUP-003 | logged_in_group | server-positive | group | 分页 + 成员数/角色字段 |
| `fetchPublicGroupsFromServer({pageSize, pageNum})` | chat_group_manager.dart:405 | FL-GROUP-004 | logged_in_group | server-positive | REST | 需服务端存在公开群 |
| `createGroup({groupName, inviteMembers, options, ...})` | chat_group_manager.dart:454 | FL-GROUP-005 | logged_in_group | server-positive | peer + REST | 创建后 `fetchJoinedGroupsFromServer` 含新群；销毁见 FL-GROUP-024 |
| `fetchGroupInfoFromServer(groupId)` | chat_group_manager.dart:498 | FL-GROUP-006 | logged_in_group | server-positive | group | `fetchMembers` 参数已弃用（:500），不覆盖 |
| `fetchMemberListFromServer(groupId)` | chat_group_manager.dart:538 | FL-GROUP-007 | logged_in_group | server-positive | group | 含 zuoyu01/zuoyu02 |
| `fetchBlockListFromServer(groupId)` | chat_group_manager.dart:588 | FL-GROUP-008 | logged_in_group | server-positive | group | 先 `blockMembers`（FL-GROUP-017） |
| `fetchMuteListFromServer(groupId)` | chat_group_manager.dart:631 | FL-GROUP-009 | logged_in_group | server-positive | group | 先 `muteMembers`（FL-GROUP-030） |
| `fetchAllowListFromServer(groupId)` | chat_group_manager.dart:675 | FL-GROUP-010 | logged_in_group | server-positive | group | 先 `addAllowList`（FL-GROUP-034） |
| `isMemberInAllowListFromServer(groupId, userId)` | chat_group_manager.dart:712 | FL-GROUP-011 | logged_in_group | server-positive | group | 白名单内外各一次 |
| `fetchGroupFileListFromServer(groupId)` | chat_group_manager.dart:747 | FL-GROUP-012 | logged_in_group | server-positive | group | 先 `uploadGroupSharedFile`（FL-GROUP-036） |
| `fetchAnnouncementFromServer(groupId)` | chat_group_manager.dart:786 | FL-GROUP-013 | logged_in_group | server-positive | group | 先 `updateGroupAnnouncement` |
| `addMembers(groupId, members, {welcome})` | chat_group_manager.dart:821 | FL-GROUP-014 | logged_in_group | server-positive | peer + group | 对端 `onMemberJoined` / `onMembersJoined` |
| `inviterUser(groupId, members, {reason})` | chat_group_manager.dart:860 | FL-GROUP-015 | logged_in_group | server-positive | peer + group | 对端 `onInvitationReceived`（EVENT-104） |
| `removeMembers(groupId, members)` | chat_group_manager.dart:907 | FL-GROUP-016 | logged_in_group | server-positive | peer + group | 对端 `onUserRemoved` |
| `blockMembers(groupId, members)` | chat_group_manager.dart:944 | FL-GROUP-017 | logged_in_group | server-positive | peer + group | 群黑名单 |
| `unblockMembers(groupId, members)` | chat_group_manager.dart:981 | FL-GROUP-018 | logged_in_group | server-positive | peer + group | 解除黑名单 |
| `changeGroupName(groupId, name)` | chat_group_manager.dart:996 | FL-GROUP-019 | logged_in_group | server-positive | group | `@Deprecated`（:995），1 条冒烟；实际走 `updateGroupSubject` |
| `updateGroupName(groupId, name)` | chat_group_manager.dart:1033 | FL-GROUP-020 | logged_in_group | server-positive | group | 主覆盖 |
| `changeGroupDescription(groupId, desc)` | chat_group_manager.dart:1048 | FL-GROUP-021 | logged_in_group | server-positive | group | `@Deprecated`（:1047），1 条冒烟 |
| `updateGroupDesc(groupId, desc)` | chat_group_manager.dart:1085 | FL-GROUP-022 | logged_in_group | server-positive | group | 主覆盖 |
| `leaveGroup(groupId)` | chat_group_manager.dart:1118 | FL-GROUP-023 | logged_in_group | server-positive | group | 用临时群，避免毁掉共享夹具 |
| `destroyGroup(groupId)` | chat_group_manager.dart:1150 | FL-GROUP-024 | logged_in_group | server-positive | group | 仅群主；对端 `onGroupDestroyed`；用临时群 |
| `blockGroup(groupId)` | chat_group_manager.dart:1181 | FL-GROUP-025 | logged_in_group | local | group | 屏蔽群消息，本地生效；解除见下条 |
| `unblockGroup(groupId)` | chat_group_manager.dart:1211 | FL-GROUP-026 | logged_in_group | local | group | 取消屏蔽 |
| `changeOwner(groupId, newOwner)` | chat_group_manager.dart:1245 | FL-GROUP-027 | logged_in_group | server-positive | peer + group | 仅群主；对端 `onOwnerChanged` |
| `addAdmin(groupId, member)` | chat_group_manager.dart:1282 | FL-GROUP-028 | logged_in_group | server-positive | peer + group | 对端 `onAdminAddedFromGroup` |
| `removeAdmin(groupId, member)` | chat_group_manager.dart:1319 | FL-GROUP-029 | logged_in_group | server-positive | peer + group | 对端 `onAdminRemoved` |
| `muteMembers(groupId, members, {duration})` | chat_group_manager.dart:1358 | FL-GROUP-030 | logged_in_group | server-positive | peer + group | 对端 `onMuteListAdded` |
| `unMuteMembers(groupId, members)` | chat_group_manager.dart:1396 | FL-GROUP-031 | logged_in_group | server-positive | peer + group | 对端 `onMuteListRemoved` |
| `muteAllMembers(groupId)` | chat_group_manager.dart:1431 | FL-GROUP-032 | logged_in_group | server-positive | group | 对端 `onAllGroupMemberMuteStateChanged` |
| `unMuteAllMembers(groupId)` | chat_group_manager.dart:1463 | FL-GROUP-033 | logged_in_group | server-positive | group | 同上 |
| `addAllowList(groupId, members)` | chat_group_manager.dart:1497 | FL-GROUP-034 | logged_in_group | server-positive | peer + group | 对端 `onAllowListAdded` |
| `removeAllowList(groupId, members)` | chat_group_manager.dart:1534 | FL-GROUP-035 | logged_in_group | server-positive | peer + group | 对端 `onAllowListRemoved` |
| `uploadGroupSharedFile(groupId, filePath)` | chat_group_manager.dart:1569 | FL-GROUP-036 | logged_in_group | server-positive | group | 需真实文件；对端 `onSharedFileAdded` |
| `downloadGroupSharedFile(groupId, fileId, savePath)` | chat_group_manager.dart:1606 | FL-GROUP-037 | logged_in_group | server-positive | group | 需先上传（FL-GROUP-036） |
| `removeGroupSharedFile(groupId, fileId)` | chat_group_manager.dart:1642 | FL-GROUP-038 | logged_in_group | server-positive | group | 对端 `onSharedFileDeleted` |
| `updateGroupAnnouncement(groupId, announcement)` | chat_group_manager.dart:1679 | FL-GROUP-039 | logged_in_group | server-positive | group | 对端 `onAnnouncementChanged` |
| `updateGroupExtension(groupId, extension)` | chat_group_manager.dart:1716 | FL-GROUP-040 | logged_in_group | server-positive | group | 回读一致 |
| `joinPublicGroup(groupId)` | chat_group_manager.dart:1749 | FL-GROUP-041 | logged_in_group | server-positive | REST | 需公开群 + 未加入的账号 |
| `requestToJoinPublicGroup(groupId, {reason})` | chat_group_manager.dart:1784 | FL-GROUP-042 | logged_in_group | server-positive | REST | 对端 `onRequestToJoinReceived`（EVENT-100） |
| `acceptJoinApplication(groupId, userId)` | chat_group_manager.dart:1822 | FL-GROUP-043 | logged_in_group | server-positive | peer + group | 需先有申请 |
| `declineJoinApplication(groupId, userId)` | chat_group_manager.dart:1861 | FL-GROUP-044 | logged_in_group | server-positive | peer + group | 同上 |
| `acceptInvitation(groupId, inviter)` | chat_group_manager.dart:1899 | FL-GROUP-045 | logged_in_group | server-positive | peer + REST | 需 pending 邀请（FL-GROUP-015） |
| `declineInvitation(groupId, inviter)` | chat_group_manager.dart:1938 | FL-GROUP-046 | logged_in_group | server-positive | peer + REST | 同上 |
| `setMemberAttributes(groupId, userId, attributes)` | chat_group_manager.dart:1977 | FL-GROUP-047 | logged_in_group | server-positive | peer + group | 群成员自定义属性 |
| `fetchMemberAttributes(groupId, userId)` | chat_group_manager.dart:2017 | FL-GROUP-048 | logged_in_group | server-positive | group | 回读一致 |
| `fetchMembersAttributes(groupId, userIds)` | chat_group_manager.dart:2061 | FL-GROUP-049 | logged_in_group | server-positive | group | 批量 |
| `fetchJoinedGroupCount()` | chat_group_manager.dart:2105 | FL-GROUP-050 | logged_in_group | server-positive | group | 与 `getJoinedGroups().length` 对齐 |
| `isMemberInGroupMuteList(groupId, userId)` | chat_group_manager.dart:2136 | FL-GROUP-051 | logged_in_group | server-positive | group | 静音/非静音各一次 |
| `clearAllGroupsFromLocal()` | chat_group_manager.dart:2163 | FL-GROUP-052 | logged_in_group | local | group | 清本地群缓存，服务端仍可拉回 |
| `fetchGroupMembersInfo(groupId, userIds)` | chat_group_manager.dart:2196 | FL-GROUP-053 | logged_in_group | server-positive | group | 指定成员信息 |
| `updateGroupAvatar(groupId, filePath)` | chat_group_manager.dart:2248 | FL-GROUP-054 | logged_in_group | server-positive | group + REST | 需图片文件；回读 avatar 变化 |
| `updateGroupNamecard(groupId, userId, namecard)` | chat_group_manager.dart:2291 | FL-GROUP-055 | logged_in_group | server-positive | group | 群昵称；对端 `onUserGroupNamecardChanged` |
| `getGroupNamecard(groupId, userId)` | chat_group_manager.dart:2329 | FL-GROUP-056 | logged_in_group | local | group | 未设置返回空/默认 |
| `createGroup({options: 非法组合})` | chat_group_manager.dart:454 | FL-GROUP-057 | logged_in_group | negative | — | 断言参数错误码 |
| `addMembers(不存在的 userId)` | chat_group_manager.dart:821 | FL-GROUP-058 | logged_in_group | negative | group | 断言错误码或部分成功 |
| `leaveGroup(未加入的群)` | chat_group_manager.dart:1118 | FL-GROUP-059 | logged_in_group | negative | REST | 断言错误码 |
| `downloadGroupSharedFile(不存在的 fileId)` | chat_group_manager.dart:1606 | FL-GROUP-060 | logged_in_group | negative | group | 断言错误码 |

> 事件注册 4 个方法见 §3.10（EVENT-020~023）。

### 3.6 聊天室（`managers/chat_room_manager.dart`）

> 入口说明：`createChatRoom` / `destroyChatRoom` / `fetchChatRoomInfoFromServer` / `getChatRoom` 已被 D17 移除，聊天室必须由 REST/控制台预建，因此本域整体归「特殊」入口（独立 dart-define 传入 `E2E_ROOM_ID` 与房主账号）。

| API（Dart 签名简写） | 源码位置 | 建议 case ID | 目标入口 | 断言类型 | 依赖准备 | 备注 |
|---|---|---|---|---|---|---|
| `joinChatRoom(roomId, {leaveOtherRooms, ext})` | chat_room_manager.dart:259 | FL-ROOM-001 | 特殊 | server-positive | room + REST | 对端 `onMemberJoined` |
| `leaveChatRoom(roomId)` | chat_room_manager.dart:295 | FL-ROOM-002 | 特殊 | server-positive | room | 对端 `onMemberExited` |
| `fetchPublicChatRoomsFromServer({pageNum, pageSize})` | chat_room_manager.dart:329 | FL-ROOM-003 | 特殊 | server-positive | REST | 需公开聊天室 |
| `changeChatRoomName(roomId, name)` | chat_room_manager.dart:372 | FL-ROOM-004 | 特殊 | server-positive | room + REST | 仅房主；key 为 `changeChatRoomSubject` |
| `changeChatRoomDescription(roomId, desc)` | chat_room_manager.dart:410 | FL-ROOM-005 | 特殊 | server-positive | room + REST | 仅房主 |
| `fetchChatRoomMembers(roomId, {cursor, pageSize})` | chat_room_manager.dart:454 | FL-ROOM-006 | 特殊 | server-positive | room | 分页 |
| `muteChatRoomMembers(roomId, members, {duration})` | chat_room_manager.dart:501 | FL-ROOM-007 | 特殊 | server-positive | room + REST | 对端 `onMuteListAdded` |
| `unMuteChatRoomMembers(roomId, members)` | chat_room_manager.dart:544 | FL-ROOM-008 | 特殊 | server-positive | room + REST | 对端 `onMuteListRemoved` |
| `changeOwner(roomId, newOwner)` | chat_room_manager.dart:582 | FL-ROOM-009 | 特殊 | server-positive | room + REST | 仅房主；对端 `onOwnerChanged` |
| `addChatRoomAdmin(roomId, admin)` | chat_room_manager.dart:620 | FL-ROOM-010 | 特殊 | server-positive | room + REST | 对端 `onAdminAddedFromChatRoom` |
| `removeChatRoomAdmin(roomId, admin)` | chat_room_manager.dart:654 | FL-ROOM-011 | 特殊 | server-positive | room + REST | 对端 `onAdminRemoved` |
| `fetchChatRoomMuteList(roomId)` | chat_room_manager.dart:700 | FL-ROOM-012 | 特殊 | server-positive | room | 先禁言（FL-ROOM-007） |
| `removeChatRoomMembers(roomId, members)` | chat_room_manager.dart:740 | FL-ROOM-013 | 特殊 | server-positive | room + REST | 对端 `onRemovedFromChatRoom` |
| `blockChatRoomMembers(roomId, members)` | chat_room_manager.dart:787 | FL-ROOM-014 | 特殊 | server-positive | room + REST | 聊天室黑名单 |
| `unBlockChatRoomMembers(roomId, members)` | chat_room_manager.dart:825 | FL-ROOM-015 | 特殊 | server-positive | room + REST | 解除黑名单 |
| `fetchChatRoomBlockList(roomId)` | chat_room_manager.dart:871 | FL-ROOM-016 | 特殊 | server-positive | room | 回读 |
| `updateChatRoomAnnouncement(roomId, announcement)` | chat_room_manager.dart:912 | FL-ROOM-017 | 特殊 | server-positive | room + REST | 对端 `onAnnouncementChanged` |
| `fetchChatRoomAnnouncement(roomId)` | chat_room_manager.dart:946 | FL-ROOM-018 | 特殊 | server-positive | room | 回读一致 |
| `fetchChatRoomAllowListFromServer(roomId)` | chat_room_manager.dart:984 | FL-ROOM-019 | 特殊 | server-positive | room + REST | 走 whiteList 系列 key |
| `isMemberInChatRoomAllowList(roomId, userId)` | chat_room_manager.dart:1026 | FL-ROOM-020 | 特殊 | server-positive | room + REST | 白名单内外各一次 |
| `addMembersToChatRoomAllowList(roomId, members)` | chat_room_manager.dart:1064 | FL-ROOM-021 | 特殊 | server-positive | room + REST | 对端 `onAllowListAdded` |
| `removeMembersFromChatRoomAllowList(roomId, members)` | chat_room_manager.dart:1108 | FL-ROOM-022 | 特殊 | server-positive | room + REST | 对端 `onAllowListRemoved` |
| `muteAllChatRoomMembers(roomId)` | chat_room_manager.dart:1152 | FL-ROOM-023 | 特殊 | server-positive | room + REST | 对端 `onAllChatRoomMemberMuteStateChanged` |
| `unMuteAllChatRoomMembers(roomId)` | chat_room_manager.dart:1186 | FL-ROOM-024 | 特殊 | server-positive | room + REST | 同上 |
| `fetchChatRoomAttributes(roomId, {keys})` | chat_room_manager.dart:1224 | FL-ROOM-025 | 特殊 | server-positive | room | 全量 / 指定 key 两种 |
| `addAttributes(roomId, {attributes, deleteWhenLeft, overwrite})` | chat_room_manager.dart:1287 | FL-ROOM-026 | 特殊 | server-positive | room | 对端 `onAttributesUpdated`；覆盖/不覆盖各一次 |
| `removeAttributes(roomId, {keys, force})` | chat_room_manager.dart:1343 | FL-ROOM-027 | 特殊 | server-positive | room | 对端 `onAttributesRemoved` |
| `isMemberInChatRoomMuteList(roomId, userId)` | chat_room_manager.dart:1387 | FL-ROOM-028 | 特殊 | server-positive | room | 禁言/非禁言各一次 |
| `joinChatRoom(不存在的 roomId)` | chat_room_manager.dart:259 | FL-ROOM-029 | 特殊 | negative | — | 断言错误码 |
| `fetchChatRoomMembers(不存在的 roomId)` | chat_room_manager.dart:454 | FL-ROOM-030 | 特殊 | negative | — | 断言错误码 |
| `addAttributes(空 map)` | chat_room_manager.dart:1287 | FL-ROOM-031 | 特殊 | negative | room | 断言参数错误码 |

> 事件注册 4 个方法见 §3.10（EVENT-024~027）。

### 3.7 Push（`managers/chat_push_manager.dart`）

> 本域无事件注册方法。`updateHMSPushToken` / `updateFCMPushToken` / `updateAPNsPushToken` / `getImPushConfigFromServer` / `setPreferredNotificationLanguage` / `fetchPreferredNotificationLanguage` / `bindPushKitToken` / `unbindPushKitToken` 已被 D17 移除，不在清单内。

| API（Dart 签名简写） | 源码位置 | 建议 case ID | 目标入口 | 断言类型 | 依赖准备 | 备注 |
|---|---|---|---|---|---|---|
| `updatePushNickname(nickname)` | chat_push_manager.dart:44 | FL-PUSH-001 | logged_in_base | server-positive | — | 服务端离线推送昵称回读一致 |
| `updatePushDisplayStyle(style)` | chat_push_manager.dart:71 | FL-PUSH-002 | logged_in_base | server-positive | — | `Simple` / `Summary` 各一次 |
| `bindDeviceToken({notifierName, deviceToken})` | chat_push_manager.dart:112 | FL-PUSH-003 | 特殊 | server-positive | — | 需真机 + HMS notifier 证书；模拟器只能断言错误码（存疑 §5） |
| `setConversationSilentMode(convId, param)` | chat_push_manager.dart:149 | FL-PUSH-004 | logged_in_base | server-positive | peer | 设置后 `ChatConversation.remindType` 同步（FL-CONV-026） |
| `removeConversationSilentMode(convId)` | chat_push_manager.dart:192 | FL-PUSH-005 | logged_in_base | server-positive | peer | 移除后恢复默认 |
| `fetchConversationSilentMode(convId)` | chat_push_manager.dart:232 | FL-PUSH-006 | logged_in_base | server-positive | peer | 回读一致 |
| `setSilentModeForAll(param)` | chat_push_manager.dart:266 | FL-PUSH-007 | logged_in_base | server-positive | — | 全局免打扰时段 |
| `fetchSilentModeForAll()` | chat_push_manager.dart:299 | FL-PUSH-008 | logged_in_base | server-positive | — | 回读一致 |
| `fetchSilentModeForConversations(convIds)` | chat_push_manager.dart:332 | FL-PUSH-009 | logged_in_base | server-positive | peer | 批量返回 map |
| `setPushTemplate(templateName)` | chat_push_manager.dart:377 | FL-PUSH-010 | 特殊 | server-positive | REST | 需服务端预置模板；模板不存在为负向 |
| `getPushTemplate()` | chat_push_manager.dart:405 | FL-PUSH-011 | logged_in_base | server-positive | — | 与 `setPushTemplate` 对齐 |
| `syncConversationsSilentMode()` | chat_push_manager.dart:433 | FL-PUSH-012 | logged_in_base | server-positive | peer | 多端设置后同步到本端 |
| `bindDeviceToken(非法 notifierName)` | chat_push_manager.dart:112 | FL-PUSH-013 | 特殊 | negative | — | 断言错误码 |

### 3.8 UserInfo（`managers/chat_user_info_manager.dart`）

| API（Dart 签名简写） | 源码位置 | 建议 case ID | 目标入口 | 断言类型 | 依赖准备 | 备注 |
|---|---|---|---|---|---|---|
| `updateUserInfo({nickname, avatarUrl, mail, phone, gender, sign, birth, ext})` | chat_user_info_manager.dart:173 | FL-USERINFO-001 | logged_in_user_info | server-positive | — | 全字段一次、部分字段一次；对端 `onUserInfoUpdate` |
| `fetchOwnInfo({expireTime})` | chat_user_info_manager.dart:226 | FL-USERINFO-002 | logged_in_user_info | server-positive | — | `expireTime=0` 强制拉服务端；对端 `onSelfUserInfoUpdate` 不触发（自身更新才触发） |
| `fetchUserInfoById(userIds, {expireTime})` | chat_user_info_manager.dart:270 | FL-USERINFO-003 | logged_in_user_info | server-positive | peer | 多 id + 不存在 id 混合 |
| `clearUserInfoCache()` | chat_user_info_manager.dart:317 | FL-USERINFO-004 | logged_in_user_info | local | — | 清缓存后 `getLocalUserInfoByIds` 为空 |
| `subscribeUsersInfo(userIds)` | chat_user_info_manager.dart:342 | FL-USERINFO-005 | logged_in_user_info | server-positive | peer | 订阅后对端更新触发 `onUserInfoUpdate` |
| `unsubscribeUsersInfo(userIds)` | chat_user_info_manager.dart:368 | FL-USERINFO-006 | logged_in_user_info | server-positive | peer | 取消后不再触发 |
| `fetchSubscribedUsers()` | chat_user_info_manager.dart:394 | FL-USERINFO-007 | logged_in_user_info | server-positive | peer | 含已订阅用户 |
| `getLocalUserInfoByIds(userIds)` | chat_user_info_manager.dart:428 | FL-USERINFO-008 | logged_in_user_info | local | peer | 未缓存时返回空 |
| `fetchUserInfoById([])` | chat_user_info_manager.dart:270 | FL-USERINFO-009 | logged_in_user_info | negative | — | 空列表应返回空 map |
| `updateUserInfo(非法 phone/avatarUrl)` | chat_user_info_manager.dart:173 | FL-USERINFO-010 | logged_in_user_info | negative | — | 断言错误码或服务端拒绝 |

> 事件注册 4 个方法见 §3.10（EVENT-032~035）。

### 3.9 Presence（`managers/chat_presence_manager.dart`）

> 现有 `FL-PRESENCE-001~005`（未登录调用被拒，断言 code 201）保留不动。本表从 `FL-PRESENCE-006` 续编。

| API（Dart 签名简写） | 源码位置 | 建议 case ID | 目标入口 | 断言类型 | 依赖准备 | 备注 |
|---|---|---|---|---|---|---|
| `publishPresence(description)` | chat_presence_manager.dart:126 | FL-PRESENCE-006 | logged_in_base | server-positive | peer | 对端 `onPresenceStatusChanged` 收到 description |
| `subscribe(members, {expiry})` | chat_presence_manager.dart:163 | FL-PRESENCE-007 | logged_in_base | server-positive | peer | `expiry` 单位待确认（存疑 §5） |
| `unsubscribe(members)` | chat_presence_manager.dart:198 | FL-PRESENCE-008 | logged_in_base | server-positive | peer | 取消后 `fetchSubscribedMembers` 不含对端 |
| `fetchSubscribedMembers({pageNum, pageSize})` | chat_presence_manager.dart:235 | FL-PRESENCE-009 | logged_in_base | server-positive | peer | 分页 |
| `fetchPresenceStatus(members)` | chat_presence_manager.dart:278 | FL-PRESENCE-010 | logged_in_base | server-positive | peer | 对端已 publish 时返回其状态 |

> 事件注册 4 个方法见 §3.10（EVENT-028~031）；回调 `onPresenceStatusChanged` 见 EVENT-122。

### 3.10 事件（`handlers/manager_event_handler.dart`）

#### 3.10.1 注册 / 注销方式（35 个方法）

| API（Dart 签名简写） | 源码位置 | 建议 case ID | 目标入口 | 断言类型 | 依赖准备 | 备注 |
|---|---|---|---|---|---|---|
| `ChatClient.addConnectionEventHandler(id, handler)` | chat_client.dart:243 | FL-EVENT-001 | logged_out | local | — | 注册后 `getConnectionEventHandler` 命中；id 重复注册覆盖 |
| `ChatClient.removeConnectionEventHandler(id)` | chat_client.dart:261 | FL-EVENT-002 | logged_out | local | — | 注销后不再回调 |
| `ChatClient.getConnectionEventHandler(id)` | chat_client.dart:280 | FL-EVENT-003 | logged_out | local | — | 未注册返回 null |
| `ChatClient.clearConnectionEventHandlers()` | chat_client.dart:291 | FL-EVENT-004 | logged_out | local | — | 清空全部 |
| `ChatClient.addMultiDeviceEventHandler(id, handler)` | chat_client.dart:310 | FL-EVENT-005 | logged_in_base | local | — | 同上 |
| `ChatClient.removeMultiDeviceEventHandler(id)` | chat_client.dart:328 | FL-EVENT-006 | logged_in_base | local | — | 同上 |
| `ChatClient.getMultiDeviceEventHandler(id)` | chat_client.dart:347 | FL-EVENT-007 | logged_in_base | local | — | 同上 |
| `ChatClient.clearMultiDeviceEventHandlers()` | chat_client.dart:358 | FL-EVENT-008 | logged_in_base | local | — | 同上 |
| `ChatContactManager.addEventHandler(id, handler)` | chat_contact_manager.dart:85 | FL-EVENT-009 | logged_in_contact | local | — | 同上 |
| `ChatContactManager.removeEventHandler(id)` | chat_contact_manager.dart:103 | FL-EVENT-010 | logged_in_contact | local | — | 同上 |
| `ChatContactManager.getEventHandler(id)` | chat_contact_manager.dart:122 | FL-EVENT-011 | logged_in_contact | local | — | 同上 |
| `ChatContactManager.clearEventHandlers()` | chat_contact_manager.dart:133 | FL-EVENT-012 | logged_in_contact | local | — | 同上 |
| `ChatManager.addEventHandler(id, handler)` | chat_manager.dart:229 | FL-EVENT-013 | logged_in_base | local | — | 同上 |
| `ChatManager.removeEventHandler(id)` | chat_manager.dart:247 | FL-EVENT-014 | logged_in_base | local | — | 同上 |
| `ChatManager.getEventHandler(id)` | chat_manager.dart:266 | FL-EVENT-015 | logged_in_base | local | — | 同上 |
| `ChatManager.clearEventHandlers()` | chat_manager.dart:277 | FL-EVENT-016 | logged_in_base | local | — | 同上 |
| `ChatManager.addMessageEvent(id, ChatMessageEvent)` | chat_manager.dart:296 | FL-EVENT-017 | logged_in_base | local | — | 发送进度回调注册 |
| `ChatManager.removeMessageEvent(id)` | chat_manager.dart:311 | FL-EVENT-018 | logged_in_base | local | — | 注销后无进度回调 |
| `ChatManager.clearMessageEvent()` | chat_manager.dart:322 | FL-EVENT-019 | logged_in_base | local | — | 清空全部 |
| `ChatGroupManager.addEventHandler(id, handler)` | chat_group_manager.dart:218 | FL-EVENT-020 | logged_in_group | local | — | 同上 |
| `ChatGroupManager.removeEventHandler(id)` | chat_group_manager.dart:236 | FL-EVENT-021 | logged_in_group | local | — | 同上 |
| `ChatGroupManager.getEventHandler(id)` | chat_group_manager.dart:255 | FL-EVENT-022 | logged_in_group | local | — | 同上 |
| `ChatGroupManager.clearEventHandlers()` | chat_group_manager.dart:266 | FL-EVENT-023 | logged_in_group | local | — | 同上 |
| `ChatRoomManager.addEventHandler(id, handler)` | chat_room_manager.dart:179 | FL-EVENT-024 | 特殊 | local | — | 同上 |
| `ChatRoomManager.removeEventHandler(id)` | chat_room_manager.dart:197 | FL-EVENT-025 | 特殊 | local | — | 同上 |
| `ChatRoomManager.getEventHandler(id)` | chat_room_manager.dart:216 | FL-EVENT-026 | 特殊 | local | — | 同上 |
| `ChatRoomManager.clearEventHandlers()` | chat_room_manager.dart:227 | FL-EVENT-027 | 特殊 | local | — | 同上 |
| `ChatPresenceManager.addEventHandler(id, handler)` | chat_presence_manager.dart:58 | FL-EVENT-028 | logged_in_base | local | — | 同上 |
| `ChatPresenceManager.removeEventHandler(id)` | chat_presence_manager.dart:76 | FL-EVENT-029 | logged_in_base | local | — | 同上 |
| `ChatPresenceManager.getEventHandler(id)` | chat_presence_manager.dart:95 | FL-EVENT-030 | logged_in_base | local | — | 同上 |
| `ChatPresenceManager.clearEventHandlers()` | chat_presence_manager.dart:106 | FL-EVENT-031 | logged_in_base | local | — | 同上 |
| `ChatUserInfoManager.addEventHandler(id, handler)` | chat_user_info_manager.dart:68 | FL-EVENT-032 | logged_in_user_info | local | — | 同上 |
| `ChatUserInfoManager.removeEventHandler(id)` | chat_user_info_manager.dart:86 | FL-EVENT-033 | logged_in_user_info | local | — | 同上 |
| `ChatUserInfoManager.getEventHandler(id)` | chat_user_info_manager.dart:105 | FL-EVENT-034 | logged_in_user_info | local | — | 同上 |
| `ChatUserInfoManager.clearEventHandlers()` | chat_user_info_manager.dart:116 | FL-EVENT-035 | logged_in_user_info | local | — | 同上 |

#### 3.10.2 `ConnectionEventHandler`（13 个回调，`manager_event_handler.dart:41`）

| API（回调签名简写） | 源码位置 | 建议 case ID | 目标入口 | 断言类型 | 依赖准备 | 备注 |
|---|---|---|---|---|---|---|
| `onConnected()` | manager_event_handler.dart:49 | FL-EVENT-036 | logged_in_base | event | — | 登录成功即触发；不得早于 init 完成 |
| `onDisconnected()` | manager_event_handler.dart:60 | FL-EVENT-037 | logged_in_base | event | — | 断网 / 服务端断链；重连后 `onConnected` 再触发 |
| `onUserDidLoginFromOtherDevice()` | manager_event_handler.dart:69 | FL-EVENT-038 | 特殊 | event | 多端 | 同账号第二端登录触发 |
| `onUserDidRemoveFromServer()` | manager_event_handler.dart:78 | FL-EVENT-039 | 特殊 | event | REST | 需控制台删号 |
| `onUserDidForbidByServer()` | manager_event_handler.dart:87 | FL-EVENT-040 | 特殊 | event | REST | 需控制台封禁 |
| `onUserDidChangePassword()` | manager_event_handler.dart:96 | FL-EVENT-041 | 特殊 | event | REST | 需控制台改密 |
| `onUserDidLoginTooManyDevice()` | manager_event_handler.dart:105 | FL-EVENT-042 | 特殊 | event | 多端 | 超出设备数上限 |
| `onUserKickedByOtherDevice()` | manager_event_handler.dart:114 | FL-EVENT-043 | 特殊 | event | 多端 | 第二端踢人 |
| `onUserAuthenticationFailed()` | manager_event_handler.dart:123 | FL-EVENT-044 | 特殊 | event | REST | 失效 token / 服务端撤销 |
| `onTokenWillExpire()` | manager_event_handler.dart:132 | FL-EVENT-045 | 特殊 | event | REST | 需短 TTL token（服务端配置） |
| `onTokenDidExpire()` | manager_event_handler.dart:141 | FL-EVENT-046 | 特殊 | event | REST | 需短 TTL token |
| `onOfflineMessageSyncStart()` | manager_event_handler.dart:150 | FL-EVENT-047 | logged_in_base | event | peer | 登录时先离线再上线 |
| `onOfflineMessageSyncFinish()` | manager_event_handler.dart:159 | FL-EVENT-048 | logged_in_base | event | peer | 与 START 成对，顺序不可颠倒 |

#### 3.10.3 `ChatMultiDeviceEventHandler`（4 个回调，`manager_event_handler.dart:268`）

| API（回调签名简写） | 源码位置 | 建议 case ID | 目标入口 | 断言类型 | 依赖准备 | 备注 |
|---|---|---|---|---|---|---|
| `onContactEvent(type, data)` | manager_event_handler.dart:276 | FL-EVENT-049 | 特殊 | event | 多端 | 第二端加好友，本端收到 `ChatMultiDevicesEvent` |
| `onGroupEvent(type, data)` | manager_event_handler.dart:289 | FL-EVENT-050 | 特殊 | event | 多端 + group | 第二端入群/退群 |
| `onRemoteMessagesRemoved(convId)` | manager_event_handler.dart:302 | FL-EVENT-051 | 特殊 | event | 多端 | 第二端删除消息 |
| `onConversationEvent(type, convId)` | manager_event_handler.dart:314 | FL-EVENT-052 | 特殊 | event | 多端 | 第二端删会话/置顶 |

#### 3.10.4 `ChatEventHandler` + `ChatMessageEvent`（14 + 3 个回调）

| API（回调签名简写） | 源码位置 | 建议 case ID | 目标入口 | 断言类型 | 依赖准备 | 备注 |
|---|---|---|---|---|---|---|
| `onMessagesReceived(List<ChatMessage>)` | manager_event_handler.dart:397 | FL-EVENT-053 | logged_in_base | event | peer | 与 FL-MSG-001 成对 |
| `onStreamMessagesReceived(List<ChatMessage>)` | manager_event_handler.dart:409 | FL-EVENT-054 | logged_in_base | event | peer | 流式消息需服务端支持，待确认 |
| `onCmdMessagesReceived(List<ChatMessage>)` | manager_event_handler.dart:421 | FL-EVENT-055 | logged_in_base | event | peer | 发 CMD 消息 |
| `onMessagesRead(List<ChatMessage>)` | manager_event_handler.dart:430 | FL-EVENT-056 | logged_in_base | event | peer | 对端 `sendMessageReadAck` |
| `onGroupMessageRead(List<ChatGroupMessageAck>)` | manager_event_handler.dart:439 | FL-EVENT-057 | logged_in_group | event | group | 对端 `sendGroupMessageReadAck` |
| `onReadAckForGroupMessageUpdated()` | manager_event_handler.dart:449 | FL-EVENT-058 | logged_in_group | event | group | 群已读回执变更 |
| `onMessagesDelivered(List<ChatMessage>)` | manager_event_handler.dart:458 | FL-EVENT-059 | logged_in_base | event | peer | 需 `updateDeliveryAckSetting(true)`（FL-CLIENT-028） |
| `onMessagesRecalled(List<ChatMessage>)` | manager_event_handler.dart:469 | FL-EVENT-060 | logged_in_base | event | peer | 对端 `recallMessage` |
| `onMessagesRecalledInfo(List<ChatMessage>)` | manager_event_handler.dart:478 | FL-EVENT-061 | logged_in_base | event | peer | 含操作者/时间 |
| `onConversationsUpdate()` | manager_event_handler.dart:487 | FL-EVENT-062 | logged_in_base | event | peer | 会话列表变更即触发 |
| `onConversationRead(from, to)` | manager_event_handler.dart:509 | FL-EVENT-063 | logged_in_base | event | peer | 对端 `sendConversationReadAck` |
| `onMessageReactionDidChange(List<ChatMessageReactionEvent>)` | manager_event_handler.dart:518 | FL-EVENT-064 | logged_in_base | event | peer | 505 allowlist |
| `onMessageContentChanged(msg, operatorId, time)` | manager_event_handler.dart:528 | FL-EVENT-065 | logged_in_base | event | peer | 需服务端 `modifyMessage`，能力待确认 |
| `onMessagePinChanged(convId, msgId, op, time)` | manager_event_handler.dart:543 | FL-EVENT-066 | logged_in_base | event | peer | 需 `pinMessage` / `unpinMessage`，505 待确认 |
| `ChatMessageEvent.onSuccess(msg)` | manager_event_handler.dart:1768 | FL-EVENT-067 | logged_in_base | event | — | 发送成功（FL-MSG-001 复用） |
| `ChatMessageEvent.onError(msg, error)` | manager_event_handler.dart:1785 | FL-EVENT-068 | logged_in_base | event | — | 发送失败（非法接收方触发，配合 FL-MSG-060） |
| `ChatMessageEvent.onProgress(msg, progress)` | manager_event_handler.dart:1802 | FL-EVENT-069 | logged_in_base | event | peer | 附件上传进度，需图片/文件消息 |

#### 3.10.5 `ChatRoomEventHandler`（16 个回调，`manager_event_handler.dart:657`）

> 全部依赖预置聊天室与房主账号（特殊入口），需 `ChatRoomManager.addEventHandler` 注册。

| API（回调签名简写） | 源码位置 | 建议 case ID | 目标入口 | 断言类型 | 依赖准备 | 备注 |
|---|---|---|---|---|---|---|
| `onAdminAddedFromChatRoom(roomId, admin)` | manager_event_handler.dart:665 | FL-EVENT-070 | 特殊 | event | room + REST | 房主 `addChatRoomAdmin` |
| `onAdminRemoved(roomId, admin)` | manager_event_handler.dart:677 | FL-EVENT-071 | 特殊 | event | room + REST | 房主 `removeChatRoomAdmin` |
| `onAllChatRoomMemberMuteStateChanged(roomId, muted)` | manager_event_handler.dart:689 | FL-EVENT-072 | 特殊 | event | room + REST | `muteAllChatRoomMembers` |
| `onAllowListAdded(roomId, members)` | manager_event_handler.dart:701 | FL-EVENT-073 | 特殊 | event | room + REST | `addMembersToChatRoomAllowList` |
| `onAllowListRemoved(roomId, members)` | manager_event_handler.dart:713 | FL-EVENT-074 | 特殊 | event | room + REST | `removeMembersFromChatRoomAllowList` |
| `onAnnouncementChanged(roomId, announcement)` | manager_event_handler.dart:725 | FL-EVENT-075 | 特殊 | event | room + REST | `updateChatRoomAnnouncement` |
| `onChatRoomDestroyed(roomId, reason)` | manager_event_handler.dart:737 | FL-EVENT-076 | 特殊 | event | room + REST | 需 REST 销毁聊天室（SDK 已移除 destroyChatRoom） |
| `onMemberExited(roomId, member, ext)` | manager_event_handler.dart:749 | FL-EVENT-077 | 特殊 | event | room | 对端 `leaveChatRoom` |
| `onMemberJoined(roomId, member, ext)` | manager_event_handler.dart:762 | FL-EVENT-078 | 特殊 | event | room | 对端 `joinChatRoom` |
| `onMuteListAdded(roomId, members, expireTs)` | manager_event_handler.dart:775 | FL-EVENT-079 | 特殊 | event | room + REST | `muteChatRoomMembers` |
| `onMuteListRemoved(roomId, members)` | manager_event_handler.dart:787 | FL-EVENT-080 | 特殊 | event | room + REST | `unMuteChatRoomMembers` |
| `onOwnerChanged(roomId, newOwner, oldOwner)` | manager_event_handler.dart:800 | FL-EVENT-081 | 特殊 | event | room + REST | `changeOwner` |
| `onRemovedFromChatRoom(reason, roomId, member)` | manager_event_handler.dart:809 | FL-EVENT-082 | 特殊 | event | room + REST | 被踢出 |
| `onSpecificationChanged(room)` | manager_event_handler.dart:823 | FL-EVENT-083 | 特殊 | event | room + REST | 名称/描述变更 |
| `onAttributesUpdated(roomId, attributes)` | manager_event_handler.dart:832 | FL-EVENT-084 | 特殊 | event | room | `addAttributes` |
| `onAttributesRemoved(roomId, keys)` | manager_event_handler.dart:845 | FL-EVENT-085 | 特殊 | event | room | `removeAttributes` |

#### 3.10.6 `ChatContactEventHandler`（8 个回调，`manager_event_handler.dart:971`）

| API（回调签名简写） | 源码位置 | 建议 case ID | 目标入口 | 断言类型 | 依赖准备 | 备注 |
|---|---|---|---|---|---|---|
| `onContactAdded(userId)` | manager_event_handler.dart:979 | FL-EVENT-086 | logged_in_contact | event | peer | 双方已是好友后对端再添加 / 服务端同步 |
| `onContactDeleted(userId)` | manager_event_handler.dart:990 | FL-EVENT-087 | logged_in_contact | event | peer | 对端删好友 |
| `onContactInvited(userId, reason)` | manager_event_handler.dart:1001 | FL-EVENT-088 | logged_in_contact | event | peer | 对端 `addContact` |
| `onFriendRequestAccepted(userId)` | manager_event_handler.dart:1013 | FL-EVENT-089 | logged_in_contact | event | peer | 对端 `acceptInvitation` |
| `onFriendRequestDeclined(userId)` | manager_event_handler.dart:1024 | FL-EVENT-090 | logged_in_contact | event | peer | 对端 `declineInvitation` |
| `onContactSyncStart()` | manager_event_handler.dart:1035 | FL-EVENT-091 | logged_in_contact | event | — | 登录后好友同步开始 |
| `onContactSyncFinish()` | manager_event_handler.dart:1048 | FL-EVENT-092 | logged_in_contact | event | — | 与 START 成对 |
| `onContactInfoUpdate(contacts)` | manager_event_handler.dart:1061 | FL-EVENT-093 | logged_in_contact | event | peer | 需 REST 改好友信息（SDK 无对应方法） |

#### 3.10.7 `ChatGroupEventHandler`（28 个回调，`manager_event_handler.dart:1143`）

| API（回调签名简写） | 源码位置 | 建议 case ID | 目标入口 | 断言类型 | 依赖准备 | 备注 |
|---|---|---|---|---|---|---|
| `onAdminAddedFromGroup(groupId, admin)` | manager_event_handler.dart:1151 | FL-EVENT-094 | logged_in_group | event | group + REST | `addAdmin`（FL-GROUP-028） |
| `onAdminRemoved(groupId, admin)` | manager_event_handler.dart:1163 | FL-EVENT-095 | logged_in_group | event | group + REST | `removeAdmin` |
| `onAllGroupMemberMuteStateChanged(groupId, muted)` | manager_event_handler.dart:1175 | FL-EVENT-096 | logged_in_group | event | group | `muteAllMembers` |
| `onAllowListAdded(groupId, members)` | manager_event_handler.dart:1187 | FL-EVENT-097 | logged_in_group | event | group | `addAllowList` |
| `onAllowListRemoved(groupId, members)` | manager_event_handler.dart:1199 | FL-EVENT-098 | logged_in_group | event | group | `removeAllowList` |
| `onAnnouncementChanged(groupId, announcement)` | manager_event_handler.dart:1211 | FL-EVENT-099 | logged_in_group | event | group | `updateGroupAnnouncement` |
| `onAutoAcceptInvitation(groupId, inviter, inviteMessage)` | manager_event_handler.dart:1226 | FL-EVENT-100 | logged_in_group | event | group | 需 `updateAutoAcceptGroupInvitationSetting(true)`（FL-CLIENT-024） |
| `onGroupDestroyed(groupId)` | manager_event_handler.dart:1239 | FL-EVENT-101 | logged_in_group | event | group | 临时群 `destroyGroup` |
| `onInvitationAccepted(groupId, invitee, reason)` | manager_event_handler.dart:1251 | FL-EVENT-102 | logged_in_group | event | peer + group | 受邀方 `acceptInvitation` |
| `onInvitationDeclined(groupId, invitee, reason)` | manager_event_handler.dart:1265 | FL-EVENT-103 | logged_in_group | event | peer + group | 受邀方 `declineInvitation` |
| `onInvitationReceived(groupId, inviter, reason)` | manager_event_handler.dart:1278 | FL-EVENT-104 | logged_in_group | event | peer + group | 对端 `inviterUser`（FL-GROUP-015） |
| `onMemberExited(groupId, member)` | manager_event_handler.dart:1292 | FL-EVENT-105 | logged_in_group | event | group | 对端 `leaveGroup` |
| `onMemberJoined(groupId, member)` | manager_event_handler.dart:1304 | FL-EVENT-106 | logged_in_group | event | peer + group | 对端入群 |
| `onMuteListAdded(groupId, mutes, expireTs)` | manager_event_handler.dart:1321 | FL-EVENT-107 | logged_in_group | event | group | `muteMembers` |
| `onMuteListRemoved(groupId, mutes)` | manager_event_handler.dart:1334 | FL-EVENT-108 | logged_in_group | event | group | `unMuteMembers` |
| `onOwnerChanged(groupId, newOwner, oldOwner)` | manager_event_handler.dart:1346 | FL-EVENT-109 | logged_in_group | event | peer + group | `changeOwner` |
| `onRequestToJoinAccepted(groupId, accepter)` | manager_event_handler.dart:1359 | FL-EVENT-110 | logged_in_group | event | peer + group | 申请被批准 |
| `onRequestToJoinDeclined(groupId, decliner, reason)` | manager_event_handler.dart:1372 | FL-EVENT-111 | logged_in_group | event | peer + group | 申请被拒绝 |
| `onRequestToJoinReceived(groupId, applicant, reason)` | manager_event_handler.dart:1387 | FL-EVENT-112 | logged_in_group | event | peer + REST | 对端 `requestToJoinPublicGroup`（FL-GROUP-042） |
| `onSharedFileAdded(groupId, sharedFile)` | manager_event_handler.dart:1401 | FL-EVENT-113 | logged_in_group | event | group | `uploadGroupSharedFile` |
| `onSpecificationDidUpdate(group)` | manager_event_handler.dart:1413 | FL-EVENT-114 | logged_in_group | event | group | 群名称/描述变更 |
| `onDisableChanged(groupId, disabled)` | manager_event_handler.dart:1424 | FL-EVENT-115 | logged_in_group | event | REST | 需服务端禁用群 |
| `onSharedFileDeleted(groupId, fileId)` | manager_event_handler.dart:1436 | FL-EVENT-116 | logged_in_group | event | group | `removeGroupSharedFile` |
| `onUserRemoved(groupId, groupName)` | manager_event_handler.dart:1448 | FL-EVENT-117 | logged_in_group | event | peer + group | 被群主移出 |
| `onAttributesChangedOfGroupMember(groupId, userId, attributes, operatorId)` | manager_event_handler.dart:1477 | FL-EVENT-118 | logged_in_group | event | peer + group | `setMemberAttributes` |
| `onMembersJoined(groupId, members)` | manager_event_handler.dart:1492 | FL-EVENT-119 | logged_in_group | event | peer + group | 批量入群（一次加 ≥2 人） |
| `onMembersExited(groupId, members)` | manager_event_handler.dart:1504 | FL-EVENT-120 | logged_in_group | event | peer + group | 批量退群 |
| `onUserGroupNamecardChanged(groupId, userId, namecard)` | manager_event_handler.dart:1528 | FL-EVENT-121 | logged_in_group | event | peer + group | `updateGroupNamecard` |

#### 3.10.8 `ChatPresenceEventHandler` / `ChatUserInfoEventHandler`（1 + 2 个回调）

| API（回调签名简写） | 源码位置 | 建议 case ID | 目标入口 | 断言类型 | 依赖准备 | 备注 |
|---|---|---|---|---|---|---|
| `onPresenceStatusChanged(List<ChatPresence>)` | manager_event_handler.dart:1725 | FL-EVENT-122 | logged_in_base | event | peer | 对端 `publishPresence` 后本端已 `subscribe` |
| `onSelfUserInfoUpdate(ChatUserInfo)` | manager_event_handler.dart:1848 | FL-EVENT-123 | logged_in_user_info | event | — | 本端 `updateUserInfo` 触发 |
| `onUserInfoUpdate(List<ChatUserInfo>)` | manager_event_handler.dart:1861 | FL-EVENT-124 | logged_in_user_info | event | peer | 需已订阅对端（FL-USERINFO-005） |

### 3.11 模型类清单（只列类名）

> 模型层无独立用例：所有模型均由上面各域 API 的返回值/入参覆盖。下面分类清单仅用于确认 D17 后 `lib/src/models/` 的公开类型范围（源码实测 48 类 + 23 枚举 = 71，与 `01-flutter-api-surface.md` 头部「51 类 / 24 枚举」的差异见 §5 存疑 12）。

**基础 / 通用（7）**：`ChatError`、`ChatOptions`、`ChatPageResult`、`ChatCursorResult`、`ChatDeviceInfo`、`ChatDownloadCallback`、`ExtSettings`

**消息（23）**：`ChatMessage`、`ChatMessageBody`（abstract）、`ChatTextMessageBody`、`ChatImageMessageBody`、`ChatVoiceMessageBody`、`ChatVideoMessageBody`、`ChatFileMessageBody`、`ChatLocationMessageBody`、`ChatCmdMessageBody`、`ChatCustomMessageBody`、`CombineMessageBody`、`ChatMessageReaction`、`ChatMessageReactionEvent`、`ChatMessageSenderInfo`、`ChatMessageSearchOption`、`ChatSearchServerMessageResult`、`MessagePinInfo`、`MessageSearchOptions`、`ReactionOperation`、`RecallMessageInfo`、`ChatTranslateLanguage`、`ChatStreamChunk`、`ChatVoiceParam`

**会话 / 群组 / 聊天室（10）**：`ChatConversation`、`ConversationFetchOptions`、`FetchMessageOptions`、`ChatGroup`、`ChatGroupInfo`、`ChatGroupOptions`、`ChatGroupSharedFile`、`GroupMemberInfo`、`ChatGroupMessageAck`、`ChatRoom`

**联系人 / 用户 / Presence（4）**：`ChatContact`、`ChatUserInfo`、`ChatPresence`、`ChatPresenceStatusDetail`

**推送 / 静默 / 登录扩展（4）**：`ChatSilentModeParam`、`ChatSilentModeTime`、`ChatSilentModeResult`、`LoginExtensionInfo`

**枚举（23）**：`ChatType`、`ChatConversationType`、`ChatGroupStyle`、`ChatGroupPermissionType`、`ChatRoomPermissionType`、`ChatRoomMessagePriority`、`MessageType`、`MessageDirection`、`MessageStatus`、`DownloadStatus`、`ChatSearchDirection`、`ChatMultiDevicesEvent`、`DisplayStyle`、`ChatSilentModeParamType`、`ChatPushRemindType`、`ReactionOperate`、`LeaveReason`、`MessagePinOperation`、`MessageSearchScope`、`ChatKeywordListMatchType`、`ConversationMarkType`、`ChatStreamStatus`、`ChatVoiceFormat`

**`ChatMessage` 内嵌公开构造/成员（不入用例表）**：`msgId` getter（chat_message.dart:50）、`chatroomMessagePriority` setter（:352）、静态工厂 `createSendMessage`（:414）、`createTxtSendMessage`（:460）、`createVoiceSendMessage`（:517）、`createImageSendMessage`（:594）、`createVideoSendMessage`（:670）、`createFileSendMessage`（:731）、`createLocationSendMessage`（:788）、`createCmdSendMessage`（:836）、`createCustomSendMessage`（:880）、`createCombineSendMessage`（:933）。这些为纯 Dart 构造，由 FL-MSG-001 / FL-MSG-014 / FL-MSG-040 间接覆盖。

## 4. D17 已移除，不写用例

> 依据 `02-gap-ledger.md` §16.1 / §17。以下 50 个 key 已从 ohos 分支 Dart 代码移除，**不得出现在任何用例中**。`ChatMethodKeys` 现存常量数 269 = 319 − 42 − 8，可作为对账依据。

### 4.1 方法 key（42）

| # | key | 原所属 | 备注 |
|---:|---|---|---|
| 1 | `isLoggedInBefore` | ChatClient | 由 `currentUserId` 替代 |
| 2 | `compressLogs` | ChatClient | chatsdk 无 |
| 3 | `kickDevice` | ChatClient | chatsdk 无 |
| 4 | `kickAllDevices` | ChatClient | chatsdk 无 |
| 5 | `getLoggedInDevicesFromServer` | ChatClient | chatsdk 无 |
| 6 | `updateRoomOwnerCanLeaveSetting` | ChatClient | chatsdk 无 |
| 7 | `loginWithAgoraToken` | ChatClient | **孤儿常量**：key 已删，方法仍在 `chat_client.dart:620`（见 §5 存疑 1） |
| 8 | `fetchConversationsFromServerWithPage` | ChatManager | 由 `fetchConversation` 替代 |
| 9 | `deleteMessagesBeforeTimestamp` | ChatManager | 由 `deleteRemoteMessagesBefore` 替代 |
| 10 | `reportMessage` | ChatManager | chatsdk 无 |
| 11 | `getThreadConversation` | ChatManager | 线程能力整体移除 |
| 12 | `deleteMessageByIds` | ChatConversation | 由 `deleteLocalAndServerMessages` 替代 |
| 13 | `deleteMessagesWithTs` | ChatConversation | 由 `deleteLocalAndServerMessagesByTime` 替代 |
| 14 | `chatThread` | ChatMessage | `getChatThread`，随 ChatThread 模型移除 |
| 15 | `createChatRoom` | ChatRoomManager | 改由 REST 预建 |
| 16 | `destroyChatRoom` | ChatRoomManager | 改由 REST |
| 17 | `fetchChatRoomInfoFromServer` | ChatRoomManager | 改由 REST |
| 18 | `getChatRoom` | ChatRoomManager | chatsdk 无 |
| 19 | `getAllChatRooms` | ChatRoomManager | **孤儿常量** |
| 20 | `removeMemberAttributesFromGroup` | ChatGroupManager | chatsdk 无（仅保留单个移除语义的 `setMemberAttributes`） |
| 21 | `updateHMSPushToken` | ChatPushManager | 由 `bindDeviceToken` 统一 |
| 22 | `updateFCMPushToken` | ChatPushManager | 同上 |
| 23 | `updateAPNsPushToken` | ChatPushManager | 同上 |
| 24 | `getImPushConfigFromServer` | ChatPushManager | chatsdk 无 |
| 25 | `setPreferredNotificationLanguage` | ChatPushManager | chatsdk 无 |
| 26 | `fetchPreferredNotificationLanguage` | ChatPushManager | chatsdk 无 |
| 27 | `bindPushKitToken` | ChatPushManager | iOS PushKit 专用 |
| 28 | `unbindPushKitToken` | ChatPushManager | 同上 |
| 29 | `getImPushConfig` | ChatPushManager | **孤儿常量** |
| 30 | `reportPushAction` | ChatPushManager | **孤儿常量** |
| 31 | `fetchChatThreadDetail` | ChatThreadManager | 线程能力整体移除 |
| 32 | `fetchJoinedChatThreads` | ChatThreadManager | 同上 |
| 33 | `fetchChatThreadsWithParentId` | ChatThreadManager | 同上 |
| 34 | `fetchJoinedChatThreadsWithParentId` | ChatThreadManager | 同上 |
| 35 | `fetchChatThreadMember` | ChatThreadManager | 同上 |
| 36 | `fetchLastMessageWithChatThreads` | ChatThreadManager | 同上 |
| 37 | `removeMemberFromChatThread` | ChatThreadManager | 同上 |
| 38 | `updateChatThreadSubject` | ChatThreadManager | 同上 |
| 39 | `createChatThread` | ChatThreadManager | 同上 |
| 40 | `joinChatThread` | ChatThreadManager | 同上 |
| 41 | `leaveChatThread` | ChatThreadManager | 同上 |
| 42 | `destroyChatThread` | ChatThreadManager | 同上 |

### 4.2 事件 key（8）

| # | key | 原所属 | 备注 |
|---:|---|---|---|
| 43 | `onMultiDeviceThreadEvent` | ChatClient / MultiDevice | 线程能力整体移除 |
| 44 | `onAppActiveNumberReachLimit` | ChatClient | chatsdk 无 |
| 45 | `onMessageReadAck` | ChatMessage | **孤儿常量**（回调从未存在） |
| 46 | `onMessageDeliveryAck` | ChatMessage | **孤儿常量** |
| 47 | `onChatThreadCreate` | ChatThreadManager | 线程能力整体移除 |
| 48 | `onChatThreadUpdate` | ChatThreadManager | 同上 |
| 49 | `onChatThreadDestroy` | ChatThreadManager | 同上 |
| 50 | `onUserKickOutOfChatThread` | ChatThreadManager | 同上 |

> 连带移除的公开类型：`ChatThreadManager` 类及其 `ChatClient.chatThreadManager` getter、`ChatThread` 模型、`ChatThreadEventHandler`、`ChatMessage.chatThread`。均不写用例。

## 5. 无法归类 / 存疑 API

| # | 项 | 现状 | 建议 |
|---:|---|---|---|
| 1 | `ChatClient.loginWithAgoraToken`（chat_client.dart:620，`@Deprecated` :594） | key 已被 D17 删除，但方法仍在，方法体 `return login(userId, agoraToken, false)` | 不写用例；建议主线确认是否删除方法（当前属「已移除 key + 存活别名」的不一致状态） |
| 2 | `MessageCallBackManager`（chat_manager.dart:2629，含 `getInstance` / `addMessageEvent` / `removeMessageEvent` / `clearAllMessageEvents`） | 公开类，但未在 `im_flutter_sdk.dart` 导出，且与 `ChatManager.addMessageEvent` 能力重叠 | 暂不写用例；若确认对外可见，补 4 行（与 EVENT-017~019 合并） |
| 3 | `renewAgoraToken`（chat_client.dart:709） | chatsdk 无 Agora token 续期概念，ArkTS 侧实现方式未定 | 需 505/能力确认后再定；暂按「特殊配置 + REST 夹具」占位 |
| 4 | `getCurrentDeviceId`（chat_client.dart:467） | chatsdk 无稳定 deviceId，值由 wrapper 生成 | 只断言非空 + 同会话稳定，不断言跨进程一致 |
| 5 | `customEventHandler`（chat_client.dart:216） | 依赖 `onSendDataToFlutter`，ArkTS 侧保留 channel 但未实现 | 标为已知缺口；用例断言「不触发」而非「触发」 |
| 6 | `startCallback`（chat_client.dart:373） | ArkTS 空实现 | 仅断言不抛错 |
| 7 | 12 个 `update*Setting`（chat_client.dart:825~978） | 本地配置项，ArkTS 是否落盘/生效未确认 | 只断言调用成功；若要断言生效，需先补 native 读回能力 |
| 8 | `changeAppId`（chat_client.dart:812） | chatsdk 只有 appKey，appId 语义/与 appKey 的关系未确认 | 与 `changeAppKey` 合并验证，或确认后移除 |
| 9 | `fetchConversation` / `fetchConversationsByOptions` 的分页与过滤字段 | 4.25 新 API，服务端行为未在文档中固化 | 用宽松断言（非空 + 结构正确），不锁具体条数 |
| 10 | `modifyMessage` / `pinMessage` / `unpinMessage` / `fetchPinnedMessages` / `onMessageContentChanged` / `onMessagePinChanged` | 是否属增值服务（505）、服务端是否开通未知 | 先按 505 allowlist 跑，命中 505 则标 skip 并回填台账 |
| 11 | `searchMessagesFromServer` / `loadConversationMessagesWithKeyword` / `searchMsgsByOptions` / `translateMessage` / `voiceMessageToText` / `voiceFileToText` / reactions | 已知增值服务，历史环境曾命中 505 | 统一 505 allowlist；跳过时记录 code=505 与请求参数 |
| 12 | 模型数量口径 | 源码实测 48 类 + 23 枚举；`01-flutter-api-surface.md` 头部写 40 文件 / 51 类 / 24 枚举 | 以源码为准；差异含已移除 `ChatThread` 及 handler/enum 统计口径，建议回修文档 |
| 13 | Contact 新旧 API 共用 key（`getAllContactsFromServer`/`fetchAllContactIds`、`getBlockListFromServer`/`fetchBlockIds` 等） | 旧方法 `@Deprecated`，新旧共用同一 native key | 新 API 全覆盖，旧 API 各 1 条冒烟（已在 FL-CONTACT-003/009 标注） |
| 14 | `fetchGroupInfoFromServer({fetchMembers})` | 参数 `@Deprecated`（:500） | 不覆盖该参数；如需成员列表用 `fetchMemberListFromServer` |
| 15 | `ChatConversation.setExt` / `ext` | 走 channel 写会话扩展，服务端是否持久化未确认 | 用例加「杀进程重启后回读」步骤，按结果回填 |
| 16 | `ChatPresenceManager.subscribe({expiry})` | `expiry` 单位（秒/天）与上限未确认 | 用默认值跑通，边界值单列待确认 |
| 17 | `bindDeviceToken` | 模拟器无 HMS 推送通道 | 仅真机 + 已配置 notifier 时可正测；模拟器只跑负向（FL-PUSH-013） |

## 6. 附录

### 6.1 入口 → 模块文件映射建议

| 入口文件 | 承载域 | 建议 modules |
|---|---|---|
| `logged_out_test.dart` | 认证前置、Client 配置、未登录负向、Presence 拒绝 | `client_cases.dart`、`client.negative.dart`、`presence.negative.dart` |
| `logged_in_base_test.dart` | 消息、会话、Client 设置、事件（Connection/Chat/MultiDevice）、Presence | `message_cases.dart`、`message.negative.dart`、`conversation_cases.dart`、`client_cases.dart`、`presence_cases.dart` |
| `logged_in_contact_test.dart` | 联系人、好友事件 | `contact_cases.dart`、`contact.negative.dart` |
| `logged_in_group_test.dart` | 群组、群事件、群消息已读 | `group_cases.dart`、`group.negative.dart` |
| `logged_in_user_info_test.dart` | 用户资料、订阅、UserInfo 事件 | `user_info_cases.dart`、`user_info.negative.dart` |
| `chat_room_test.dart`（新增特殊入口） | 聊天室全量 + 房间事件 | `room_cases.dart`、`room.negative.dart` |
| `config_variants_test.dart`（新增特殊入口） | Push、短 TTL token、多端事件、505 增值服务 | `push_cases.dart`、`multi_device_cases.dart`、`premium.505.dart` |

### 6.2 夹具需求

- **peer**：zuoyu02 常驻在线，能自动接受好友/群邀请、回应已读回执（脚本化或人工配合）。
- **group**：预置群 1 个（zuoyu01 群主、zuoyu02 成员）；破坏性用例（`leaveGroup` / `destroyGroup` / `changeOwner`）每次新建临时群，避免污染。
- **room**：REST 预建聊天室 + 房主账号 token（`createChatRoom` 已移除，无法用 SDK 建房）。
- **REST fixture**：建号、删号、封禁、改密、改好友资料、建群/公开群、建聊天室、发短 TTL token、配置推送模板。
- **多端**：同账号第二端（模拟器 + 真机，或两台模拟器）用于 MultiDevice 与 `onUserDidLoginFromOtherDevice` 系列。

### 6.3 执行顺序建议

1. `logged_out`（无副作用，最快）
2. `logged_in_base`：Client 设置 → 消息发送/接收 → 会话 → Presence → 事件（破坏性 `deleteAllMessageAndConversation` 放最后）
3. `logged_in_contact` → `logged_in_user_info` → `logged_in_group`
4. 特殊入口：聊天室 → Push/多端 → 505 增值服务（允许 skip）

### 6.4 505 allowlist 汇总

`addReaction`、`removeReaction`、`fetchReactionList`、`fetchReactionDetail`、`onMessageReactionDidChange`、`translateMessage`、`fetchSupportedLanguages`、`voiceMessageToText`、`voiceFileToText`、`searchMessagesFromServer`、`loadConversationMessagesWithKeyword`、`searchMsgsByOptions`、`pinMessage`（待确认）、`unpinMessage`（待确认）、`fetchPinnedMessages`（待确认）、`onMessagePinChanged`（待确认）、`onMessageContentChanged`（待确认）。

> 命中 505 时用例记 `skip` 并在报告回填「服务端未开通」，不计入 fail。
