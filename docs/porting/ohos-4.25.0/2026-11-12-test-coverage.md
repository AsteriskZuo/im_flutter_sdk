# OHOS 4.25.0 Dart 公开 API 测试覆盖表

> **快照时间**：2026-11-12 22:45 +08:00（Asia/Shanghai）  
> **终态更新**：2026-11-12 23:22 +08:00，六套件最终矩阵 **287 passed / 5 skipped / 0 failed**（292 条正式用例）。  
> **代码基线**：`d2772e3f`（`im_flutter_sdk/.worktree/ohos`）  
> **覆盖草稿**：[2026-11-12-test-coverage-draft.md](2026-11-12-test-coverage-draft.md)（704 行，396 张表行）  
> **失败台账**：[2026-11-12-test-failure-ledger.md](2026-11-12-test-failure-ledger.md)（分类口径以此为准）  
> **用例根目录**：`im_flutter_sdk/example/integration_test/`  
> **口径**：只统计 `modules/*.dart` 中的正式用例；`probe_*`、`probe_room_test.dart`、`probe_history*.dart`、`probe_timing_test.dart`、`probe_smoke_test.dart`、`no_login_presence_test.dart`、`single_account_local_test.dart` 不计入。

本文回答三个问题：每个 Dart 公开 API **有没有**对应用例、用例在**哪个文件**、在 2026-11-12 的跑测里**验证到什么程度**。

**注意**：表内通过的 `/` 失败状态行是 22:45 的中途快照。终态结果与归因见
[2026-11-12-test-verification.md](2026-11-12-test-verification.md) §4/§5：最终六套件
**287 passed + 5 skipped = 292 条正式用例，0 failed**；本表保留用于"每条 API 是否有
正式用例、落在哪个文件"的查询，不再代表最终通过状态。

## 摘要

- 草稿 396 行（248 API + 24 负向 + 124 事件）中，**281 行有正式用例**；缺口 **26 行**（认证 10、Client 13、消息 3），另有 **89 条事件回调没有逐条用例**。
- 正式用例共 **292 条**（草稿表内 281 + 既有 11）：终态 **287 passed / 5 skipped / 0 failed**（中途快照为 237 passed / 54 failed / 1 skipped）。
- 32 条用例以 `NOTE(deviation)` 记录与 SDK 文档/草稿预期的偏差后通过；5 条 UNVERIFIED skip 见验证记录 §4。
- 事件注册 35 条全部通过，但回调投递**没有逐条断言**；仅 onSuccess/onError 被发送类用例间接使用。

## 0. 图例与统计口径

| 状态 | 含义 |
|---|---|
| `passed` | 最近一次跑测通过 |
| `passed·dev` | 跑测通过，但用例内以 `NOTE(deviation)` 记录了与 SDK 文档/草稿预期的偏差 |
| `failed·已记录` | 最近一次跑测失败，已登记失败台账 §2，待修复或待确认 |
| `failed·待复跑` | 失败已定位且源码/wrapper 已修改，等待重新构建安装后复跑 |
| `failed·修复中` | 失败原因已知（多为夹具问题），当前正在修复 |
| `skipped·UNVERIFIED` | 用例主动 skip，能力未能验证（台账记为 UNVERIFIED） |
| `未覆盖` | 草稿有该行，但正式用例中不存在对应用例 |

统计口径：

- 草稿把 396 行拆成 **248 条 API 行 + 24 条负向行 + 124 条事件行**（35 条注册方法 + 89 条回调）。
- 248 条 API 行 = manager 219 + ChatConversation 24 + ChatMessage 4 + 公开字段 `customEventHandler` 1；D17 已移除的 50 个 key 不计入（见 §5）。
- 用例文件列是相对 `example/integration_test/` 的路径；入口列取自实际跑测日志的套件名。未覆盖行的入口列取自草稿的规划入口（标注为规划，不是实际执行）。
- 事件回调（`FL-EVENT-036`~`124`）没有逐条用例，覆盖方式单列在 §2.11~§2.17 与 §4。

## 1. 总览

### 1.1 行级覆盖

| 行类型 | 草稿行数 | 已映射用例 | 未覆盖 | 说明 |
|---|---:|---:|---:|---|
| API 行 | 248 | 224 | 24 | 缺口见 §3 |
| 负向行 | 24 | 22 | 2 | FL-AUTH-021/022 |
| 事件注册方法 | 35 | 35 | 0 | 全部 passed |
| 事件回调 | 89 | 0 | 89 | 无逐条用例，间接/未验证见 §4 |
| **合计** | **396** | **281** | **115** | 另有 11 条既有用例未进草稿（FL-CONV-001~006、FL-PRESENCE-001~005），合计 292 条 |

### 1.2 分域统计

| 域 | 草稿行 | 已映射 | passed | passed·dev | failed | skipped | 未覆盖 |
|---|---:|---:|---:|---:|---:|---:|---:|
| 3.1 认证 / Client | 41 | 18 | 18 | 0 | 0 | 0 | 23 |
| 3.2 联系人 | 23 | 23 | 20 | 3 | 0 | 0 | 0 |
| 3.3 消息 | 62 | 59 | 47 | 1 | 11 | 0 | 3 |
| 3.4 会话 | 27 | 27 | 25 | 0 | 1 | 1 | 0 |
| 3.5 群组 | 60 | 60 | 18 | 0 | 42 | 0 | 0 |
| 3.6 聊天室 | 31 | 31 | 31 | 0 | 0 | 0 | 0 |
| 3.7 Push | 13 | 13 | 12 | 1 | 0 | 0 | 0 |
| 3.8 UserInfo | 10 | 10 | 8 | 2 | 0 | 0 | 0 |
| 3.9 Presence | 5 | 5 | 5 | 0 | 0 | 0 | 0 |
| 3.10.1 事件注册方法 | 35 | 35 | 35 | 0 | 0 | 0 | 0 |
| 3.10.2 ConnectionEventHandler | 13 | 0 | 0 | 0 | 0 | 0 | 13 |
| 3.10.3 ChatMultiDeviceEventHandler | 4 | 0 | 0 | 0 | 0 | 0 | 4 |
| 3.10.4 ChatEventHandler + ChatMessageEvent | 17 | 0 | 0 | 0 | 0 | 0 | 17 |
| 3.10.5 ChatRoomEventHandler | 16 | 0 | 0 | 0 | 0 | 0 | 16 |
| 3.10.6 ChatContactEventHandler | 8 | 0 | 0 | 0 | 0 | 0 | 8 |
| 3.10.7 ChatGroupEventHandler | 28 | 0 | 0 | 0 | 0 | 0 | 28 |
| 3.10.8 ChatPresence / ChatUserInfoEventHandler | 3 | 0 | 0 | 0 | 0 | 0 | 3 |
| **合计** | **396** | **281** | **219** | **7** | **54** | **1** | **115** |

失败拆分：`failed·已记录` 9 条、`failed·待复跑` 3 条、`failed·修复中` 42 条。

### 1.3 用例与跑测结果

正式用例共 **292 条**，分布在 14 个 `modules/*.dart` 文件中；最近一轮可用日志的汇总为 **237 passed / 54 failed / 1 skipped**。

分域表只统计草稿行（281 条映射），其中 passed 219 + passed·dev 7 = 226；另有 11 条既有用例（FL-CONV-001~006、FL-PRESENCE-001~005）不在草稿表内，226 + 11 = 237，与 §1.2 合计一致。

草稿预计 407 条用例，与实际 292 条的差额 115 条恰好等于 §1.1 的 115 条未覆盖行（89 条回调未逐条建用例 + 26 条 API/负向缺口），不存在多余或重复编号。

## 2. 分域覆盖表

### 2.1 认证 / Client（草稿 §3.1；41 行，已映射 18，未覆盖 23）

认证与 Client 生命周期。gap 集中在认证 10 条与 Client 13 条（见 §3）。

| Case | 被测 API | 用例文件:行 | 入口套件 | 草稿 | 状态 |
|---|---|---|---|---|---|
| FL-CLIENT-001 | `getInstance()` | modules/client_cases.negative.dart:21 | logged_out | L63 · 单例恒等 | passed |
| FL-CLIENT-002 | `chatManager` | modules/client_cases.negative.dart:25 | logged_out | L64 · 非空 | passed |
| FL-CLIENT-003 | `contactManager` | modules/client_cases.negative.dart:29 | logged_out | L65 · 非空 | passed |
| FL-CLIENT-004 | `chatRoomManager` | modules/client_cases.negative.dart:33 | logged_out | L66 · 非空 | passed |
| FL-CLIENT-005 | `groupManager` | modules/client_cases.negative.dart:38 | logged_out | L67 · 非空 | passed |
| FL-CLIENT-006 | `pushManager` | modules/client_cases.negative.dart:42 | logged_out | L68 · 非空 | passed |
| FL-CLIENT-007 | `presenceManager` | modules/client_cases.negative.dart:46 | logged_out | L69 · 非空 | passed |
| FL-CLIENT-008 | `userInfoManager` | modules/client_cases.negative.dart:51 | logged_out | L70 · 非空 | passed |
| FL-CLIENT-009 | `currentUserId` | modules/client_cases.dart:9 | logged_in_base | L71 · 登录前 `null`，登录后等于入参 | passed |
| FL-CLIENT-010 | `options` | modules/client_cases.negative.dart:56 | logged_out | L72 · `appKey` 与 dart-define 一致 | passed |
| FL-CLIENT-011 | `customEventHandler`（公开字段） | — | logged_in_base | L73 · 依赖 `onSendDataToFlutter`，ArkT… | 未覆盖 |
| FL-CLIENT-012 | `startCallback()` | modules/client_cases.dart:13 | logged_in_base | L74 · ArkTS 空实现，仅校验不抛错、不阻塞登录 | passed |
| FL-CLIENT-013 | `isConnected` | modules/client_cases.dart:19 | logged_in_base | L75 · 登录后 true，logout 后 false | passed |
| FL-CLIENT-014 | `getCurrentUserId()` | modules/client_cases.dart:23 | logged_in_base | L76 · 与 token 对应用户一致 | passed |
| FL-CLIENT-015 | `getAccessToken()` | modules/client_cases.dart:28 | logged_in_base | L77 · 与传入 token 一致 | passed |
| FL-CLIENT-016 | `getCurrentDeviceId()` | modules/client_cases.dart:32 | logged_in_base | L78 · 非空且同一会话内稳定；chatsdk 无 deviceId… | passed |
| FL-APP-001 | `init(options)` | modules/client_cases.negative.dart:11 | logged_out | L79 · 已存在用例；含 appKey、自动登录等开关 | passed |
| FL-AUTH-002 | `createAccount(userId, password)` | — | logged_out | L80 · 随机 uid，避免脏数据；重复注册见 FL-AUTH-020 | 未覆盖 |
| FL-AUTH-003 | `login(userId, pwdOrToken, isPassword)` | — | logged_out | L81 · `@Deprecated`（:539），仅冒烟 | 未覆盖 |
| FL-AUTH-004 | `loginWithToken(userId, token)` | — | logged_out | L82 · 主用登录方式；多入口重复登录幂等 | 未覆盖 |
| FL-AUTH-001 | `loginWithPassword(userId, password)` | — | logged_out | L83 · 已存在用例 | 未覆盖 |
| FL-AUTH-005 | `renewAgoraToken(token)` | — | logged_in_base | L84 · 需有效 Agora token 夹具；chatsdk 无 … | 未覆盖 |
| FL-AUTH-006 | `logout([unbindDeviceToken])` | — | logged_in_base | L85 · 之后 `isConnected == false`、`cu… | 未覆盖 |
| FL-AUTH-007 | `changeAppKey(newAppKey)` | — | logged_out | L86 · 需备用 appKey；登录态调用为负向（FL-AUTH-0… | 未覆盖 |
| FL-AUTH-008 | `changeAppId(newAppId)` | — | logged_out | L87 · `appId` 与 `appKey` 语义待确认（存疑 §… | 未覆盖 |
| FL-CLIENT-020 | `updateUsingHttpsOnlySetting(enable)` | — | logged_out | L88 · 配置项是否落盘待确认（存疑 §5） | 未覆盖 |
| FL-CLIENT-021 | `updateLoginExtensionInfoSetting(enable)` | — | logged_out | L89 · 同上 | 未覆盖 |
| FL-CLIENT-022 | `updateDeleteMessagesWhenLeaveGroupSetting(enable)` | — | logged_out | L90 · 同上 | 未覆盖 |
| FL-CLIENT-023 | `updateDeleteMessageWhenLeaveRoomSetting(enable)` | — | logged_out | L91 · 同上 | 未覆盖 |
| FL-CLIENT-024 | `updateAutoAcceptGroupInvitationSetting(enable)` | — | logged_out | L92 · 同上 | 未覆盖 |
| FL-CLIENT-025 | `updateAutoAcceptFriendInvitationSetting(enable)` | — | logged_out | L93 · 同上 | 未覆盖 |
| FL-CLIENT-026 | `updateAutoDownloadAttachmentThumbnailSetting(enable)` | — | logged_out | L94 · 同上 | 未覆盖 |
| FL-CLIENT-027 | `updateRequireAckSetting(enable)` | — | logged_out | L95 · 同上 | 未覆盖 |
| FL-CLIENT-028 | `updateDeliveryAckSetting(enable)` | — | logged_out | L96 · 同上 | 未覆盖 |
| FL-CLIENT-029 | `updateSortMessageByServerTimeSetting(enable)` | — | logged_out | L97 · 同上 | 未覆盖 |
| FL-CLIENT-030 | `updateMessagesReceiveCallbackIncludeSendSetting(enable)` | — | logged_out | L98 · 同上 | 未覆盖 |
| FL-CLIENT-031 | `updateRegradeMessagesAsReadSetting(enable)` | — | logged_out | L99 · 同上 | 未覆盖 |
| FL-AUTH-020 | `login(userId, "wrong-password", true)` | modules/client_cases.negative.dart:74 | logged_out | L100 · 断言错误码（密码错误），不得产生登录态 | passed |
| FL-AUTH-021 | `createAccount(已有 userId, pwd)` | — | logged_out | L101 · 已存在用户注册 → 断言错误码 | 未覆盖 |
| FL-AUTH-022 | `changeAppKey(登录态)` | — | logged_in_base | L102 · 登录态切换 appKey 应失败或无效 | 未覆盖 |
| FL-CLIENT-040 | `getAccessToken()`（未登录） | modules/client_cases.negative.dart:61 | logged_out | L103 · 空串 / null / 抛错三者之一，需固化契约 | passed |

### 2.2 联系人（草稿 §3.2；23 行，已映射 23，未覆盖 0）

联系人全套 23 条已映射；contact run2 全绿。

| Case | 被测 API | 用例文件:行 | 入口套件 | 草稿 | 状态 |
|---|---|---|---|---|---|
| FL-CONTACT-001 | `addContact(userId, {reason})` | modules/contact_cases.dart:36 | logged_in_contact | L111 · 添加后服务端好友列表含对端 | passed |
| FL-CONTACT-002 | `deleteContact(userId, {keepConversation})` | modules/contact_cases.dart:63 | logged_in_contact | L112 · 删除后 `getAllContactsFromDB` 不含… | passed |
| FL-CONTACT-003 | `getAllContactsFromServer()` | modules/contact_cases.dart:85 | logged_in_contact | L113 · 与 `fetchAllContacts` 共用能力，保留 … | passed |
| FL-CONTACT-004 | `fetchAllContactIds()` | modules/contact_cases.dart:99 | logged_in_contact | L114 · 4.x 新 API，主覆盖 | passed |
| FL-CONTACT-005 | `getAllContactsFromDB()` | modules/contact_cases.dart:112 | logged_in_contact | L115 · 本地 DB 读取 | passed |
| FL-CONTACT-006 | `getAllContactIds()` | modules/contact_cases.dart:125 | logged_in_contact | L116 · 本地 DB 读取 | passed |
| FL-CONTACT-007 | `addUserToBlockList(userId)` | modules/contact_cases.dart:138 | logged_in_contact | L117 · 拉黑后对端发消息不落会话（可断言本地无新会话） | passed |
| FL-CONTACT-008 | `removeUserFromBlockList(userId)` | modules/contact_cases.dart:152 | logged_in_contact | L118 · 解除后恢复 | passed |
| FL-CONTACT-009 | `getBlockListFromServer()` | modules/contact_cases.dart:166 | logged_in_contact | L119 · 黑名单含对端 | passed |
| FL-CONTACT-010 | `fetchBlockIds()` | modules/contact_cases.dart:179 | logged_in_contact | L120 · 新 API，主覆盖 | passed |
| FL-CONTACT-011 | `getBlockListFromDB()` | modules/contact_cases.dart:200 | logged_in_contact | L121 · 本地 DB | passed |
| FL-CONTACT-012 | `getBlockIds()` | modules/contact_cases.dart:219 | logged_in_contact | L122 · 本地 DB | passed |
| FL-CONTACT-013 | `acceptInvitation(userId)` | modules/contact_cases.dart:238 | logged_in_contact | L123 · 需对端先 `addContact` 造出 pending … | passed |
| FL-CONTACT-014 | `declineInvitation(userId)` | modules/contact_cases.dart:259 | logged_in_contact | L124 · 同上 | passed |
| FL-CONTACT-015 | `getSelfIdsOnOtherPlatform()` | modules/contact_cases.dart:278 | logged_in_contact | L125 · 同账号第二端在线后返回其 id；模拟器单端时返回空列表 | passed·dev |
| FL-CONTACT-016 | `getAllContacts()` | modules/contact_cases.dart:295 | logged_in_contact | L126 · 返回 `Map<String, ChatContact>` | passed |
| FL-CONTACT-017 | `setContactRemark(userId, remark)` | modules/contact_cases.dart:315 | logged_in_contact | L127 · 备注回读一致 | passed |
| FL-CONTACT-018 | `getContact(userId)` | modules/contact_cases.dart:347 | logged_in_contact | L128 · 未命中返回 null | passed |
| FL-CONTACT-019 | `fetchAllContacts({cursor, pageSize})` | modules/contact_cases.dart:366 | logged_in_contact | L129 · 游标分页：首页后有 cursor | passed |
| FL-CONTACT-020 | `fetchContacts({cursor, pageSize})` | modules/contact_cases.dart:385 | logged_in_contact | L130 · 分页游标串接，重复项去重 | passed |
| FL-CONTACT-021 | `addContact(自己)` | modules/contact_cases.negative.dart:25 | logged_in_contact | L131 · 断言错误码 | passed·dev |
| FL-CONTACT-022 | `addContact(不存在的 userId)` | modules/contact_cases.negative.dart:44 | logged_in_contact | L132 · 断言错误码 | passed |
| FL-CONTACT-023 | `acceptInvitation(无 pending 的 userId)` | modules/contact_cases.negative.dart:57 | logged_in_contact | L133 · 断言错误码 / 幂等成功二选一，需固化契约 | passed·dev |

### 2.3 消息（草稿 §3.3；62 行，已映射 59，未覆盖 3）

消息域 59 条已映射；MSG-004/028/057 三条 group 入口用例未迁移（§3）。

| Case | 被测 API | 用例文件:行 | 入口套件 | 草稿 | 状态 |
|---|---|---|---|---|---|
| FL-MSG-001 | `sendMessage(msg)` | modules/message_cases.dart:85 | logged_in_base | L141 · 对端 `onMessagesReceived` 收到且 b… | passed |
| FL-MSG-002 | `resendMessage(msg)` | modules/message_cases.dart:113 | logged_in_base | L142 · 复用 sendMessage；需构造一次失败消息或直接重发 | passed |
| FL-MSG-003 | `sendMessageReadAck(msgId)` | modules/message_cases.dart:510 | logged_in_base | L143 · 对端 `onMessagesRead` 触发（EVENT-… | passed·dev |
| FL-MSG-004 | `sendGroupMessageReadAck(msgId, groupId, {content})` | — | logged_in_group | L144 · 群已读；对端 `onGroupMessageRead` /… | 未覆盖 |
| FL-MSG-005 | `sendConversationReadAck(conversationId)` | modules/message_cases.dart:546 | logged_in_base | L145 · 对端 `onConversationRead`（EVENT… | passed |
| FL-MSG-006 | `recallMessage(msgId, {ext})` | modules/message_cases.dart:572 | logged_in_base | L146 · 2 分钟内消息；对端 `onMessagesRecalle… | passed |
| FL-MSG-007 | `loadMessage(msgId)` | modules/message_cases.dart:145 | logged_in_base | L147 · 先发一条再按 id 读 | passed |
| FL-MSG-008 | `loadMessagesWithIds(ids, conversationId)` | modules/message_cases.dart:594 | logged_in_base | L148 · 批量读，含不存在 id 的容错 | failed·待复跑 |
| FL-MSG-009 | `getConversation(id, {type, createIfNeed})` | modules/message_cases.dart:178 | logged_in_base | L149 · 不存在且 `createIfNeed=false` 返回 … | passed |
| FL-MSG-010 | `markAllConversationsAsRead()` | modules/message_cases.dart:188 | logged_in_base | L150 · 未读数全部归零 | passed |
| FL-MSG-011 | `getUnreadMessageCount()` | modules/message_cases.dart:626 | logged_in_base | L151 · 发消息后未读 +1，标记已读后归零 | passed |
| FL-MSG-012 | `updateMessage(msg)` | modules/message_cases.dart:654 | logged_in_base | L152 · 仅本地更新（如 ext），不触达服务端 | passed |
| FL-MSG-013 | `importMessages(msgs)` | modules/message_cases.dart:685 | logged_in_base | L153 · 导入后会话可查到 | failed·待复跑 |
| FL-MSG-014 | `downloadAttachment(msg)` | modules/message_cases.dart:875 | logged_in_base | L154 · 需图片/文件消息；断言本地路径存在 | passed |
| FL-MSG-015 | `downloadThumbnail(msg)` | modules/message_cases.dart:910 | logged_in_base | L155 · 同上，缩略图路径 | passed |
| FL-MSG-016 | `downloadMessageAttachmentInCombine(msg)` | modules/message_cases.dart:968 | logged_in_base | L156 · 需合并消息夹具（REST 或先发 2 条再合并） | passed |
| FL-MSG-017 | `downloadMessageThumbnailInCombine(msg)` | modules/message_cases.dart:991 | logged_in_base | L157 · 同上 | passed |
| FL-MSG-018 | `loadAllConversations()` | modules/message_cases.dart:712 | logged_in_base | L158 · 与 `fetchConversationsFromDB` … | passed |
| FL-MSG-019 | `getConversationsFromServer()` | modules/message_cases.dart:1059 | logged_in_base | L159 · 清本地后拉回会话 | passed |
| FL-MSG-020 | `fetchConversation({cursor, pageSize})` | modules/message_cases.dart:1075 | logged_in_base | L160 · 游标分页 | passed |
| FL-MSG-021 | `deleteRemoteMessagesWithIds(convId, ids)` | modules/message_cases.dart:1099 | logged_in_base | L161 · 服务端删除，重新拉取不含 | passed |
| FL-MSG-022 | `deleteRemoteMessagesBefore(convId, ts)` | modules/message_cases.dart:1116 | logged_in_base | L162 · 需可控时间戳 | passed |
| FL-MSG-023 | `deleteConversation(convId, {deleteMessages})` | modules/message_cases.dart:739 | logged_in_base | L163 · 本地删会话，消息按开关保留/删除 | passed |
| FL-MSG-024 | `fetchHistoryMessages(...)` | modules/message_cases.dart:1165 | logged_in_base | L164 · `@Deprecated`（:1178），冒出 1 条 | failed·已记录 |
| FL-MSG-025 | `fetchHistoryMessagesByOption(...)` | modules/message_cases.dart:1189 | logged_in_base | L165 · 新 API 主覆盖：方向 + 时间窗 | failed·已记录 |
| FL-MSG-026 | `loadMessagesWithKeyword(...)` | modules/message_cases.dart:1231 | logged_in_base | L166 · `@Deprecated`（:1373），1 条冒烟 | passed |
| FL-MSG-027 | `searchMsgFromDB(...)` | modules/message_cases.dart:1262 | logged_in_base | L167 · 本地 DB 搜索；`@Deprecated`（:1373） | passed |
| FL-MSG-028 | `fetchGroupAcks(msgId, groupId, {startTs, endTs})` | — | logged_in_group | L168 · 群已读回执列表 | 未覆盖 |
| FL-MSG-029 | `deleteRemoteConversation(convId)` | modules/message_cases.dart:1286 | logged_in_base | L169 · 服务端删会话 | passed |
| FL-MSG-030 | `addReaction(msgId, reaction)` | modules/message_cases.dart:1313 | logged_in_base | L170 · 505 allowlist；对端 `onMessageRe… | passed |
| FL-MSG-031 | `removeReaction(msgId, reaction)` | modules/message_cases.dart:1341 | logged_in_base | L171 · 505 allowlist | passed |
| FL-MSG-032 | `fetchReactionList(...)` | modules/message_cases.dart:1366 | logged_in_base | L172 · 505 allowlist | passed |
| FL-MSG-033 | `fetchReactionDetail(...)` | modules/message_cases.dart:1395 | logged_in_base | L173 · 505 allowlist | passed |
| FL-MSG-034 | `translateMessage(msgId, languages)` | modules/message_cases.dart:1422 | logged_in_base | L174 · 505 allowlist（翻译增值服务） | passed |
| FL-MSG-035 | `fetchSupportedLanguages()` | modules/message_cases.dart:1447 | logged_in_base | L175 · 505 allowlist | passed |
| FL-MSG-036 | `fetchPinnedConversations()` | modules/message_cases.dart:1467 | logged_in_base | L176 · 需先 `pinConversation`（FL-MSG-0… | passed |
| FL-MSG-037 | `fetchConversationsFromDB()` | modules/message_cases.dart:765 | logged_in_base | L177 · 与 `loadAllConversations` 对齐 | passed |
| FL-MSG-038 | `pinConversation(convId, isPinned)` | modules/message_cases.dart:1490 | logged_in_base | L178 · 置顶后 `fetchPinnedConversations… | passed |
| FL-MSG-039 | `modifyMessage(...)` | modules/message_cases.dart:1512 | logged_in_base | L179 · 需服务端支持，是否增值服务待确认（存疑 §5） | passed |
| FL-MSG-040 | `fetchCombineMessageDetail(msg)` | modules/message_cases.dart:949 | logged_in_base | L180 · 需合并消息夹具；解析出的消息列表非空 | passed |
| FL-MSG-041 | `addRemoteAndLocalConversationsMark(convIds, mark)` | modules/message_cases.dart:1637 | logged_in_base | L181 · 标记同步（服务端），4.25 新能力 | passed |
| FL-MSG-042 | `deleteRemoteAndLocalConversationsMark(convIds, mark)` | modules/message_cases.dart:1659 | logged_in_base | L182 · 取消标记 | passed |
| FL-MSG-043 | `fetchConversationsByOptions(options)` | modules/message_cases.dart:1683 | logged_in_base | L183 · 按标记/置顶过滤 | passed |
| FL-MSG-044 | `deleteAllMessageAndConversation({clearServerData})` | modules/message_cases.dart:1909 | logged_in_base | L184 · **破坏性**，放该入口最后执行；`clearServer… | passed |
| FL-MSG-045 | `pinMessage(msgId, isPinned)` | modules/message_cases.dart:1536 | logged_in_base | L185 · 505 待确认（存疑 §5） | passed |
| FL-MSG-046 | `unpinMessage(msgId)` | modules/message_cases.dart:1550 | logged_in_base | L186 · 同上 | passed |
| FL-MSG-047 | `fetchPinnedMessages(convId)` | modules/message_cases.dart:1564 | logged_in_base | L187 · 同上 | passed |
| FL-MSG-048 | `searchMsgsByOptions(options)` | modules/message_cases.dart:1721 | logged_in_base | L188 · 505 allowlist（关键词/搜索增值） | failed·已记录 |
| FL-MSG-049 | `getAllMessageCount()` | modules/message_cases.dart:788 | logged_in_base | L189 · 与本地库计数一致 | passed |
| FL-MSG-050 | `loadConversationMessagesWithKeyword(...)` | modules/message_cases.dart:1740 | logged_in_base | L190 · 505 allowlist | failed·已记录 |
| FL-MSG-051 | `downloadBigImage(msg)` | modules/message_cases.dart:1018 | logged_in_base | L191 · 需大图消息夹具 | passed |
| FL-MSG-052 | `voiceMessageToText(msgId)` | modules/message_cases.dart:1764 | logged_in_base | L192 · 505 allowlist（语音转文字） | failed·已记录 |
| FL-MSG-053 | `voiceFileToText(filePath)` | modules/message_cases.dart:1786 | logged_in_base | L193 · 505 allowlist；需本地语音文件 | failed·已记录 |
| FL-MSG-054 | `searchMessagesFromServer({option, pageSize, pageNum})` | modules/message_cases.dart:1799 | logged_in_base | L194 · 505 allowlist；分页与过滤条件 | failed·已记录 |
| FL-MSG-055 | `ChatMessage.pinInfo() → Future<MessagePinInfo?>` | modules/message_cases.dart:1581 | logged_in_base | L195 · 需先 `pinMessage`（FL-MSG-045）；`… | passed |
| FL-MSG-056 | `ChatMessage.reactionList() → Future<List<ChatMessageReaction>>` | modules/message_cases.dart:1604 | logged_in_base | L196 · 需先 `addReaction`（FL-MSG-030） | passed |
| FL-MSG-057 | `ChatMessage.groupAckCount() → Future<int>` | — | logged_in_group | L197 · 群消息已读人数 | 未覆盖 |
| FL-MSG-058 | `ChatMessage.dispose()` | modules/message_cases.dart:807 | logged_in_base | L198 · 释放原生资源；释放后访问字段不崩溃 | passed |
| FL-MSG-059 | `sendMessage(空文本)` | modules/message_cases.dart:1840 | logged_in_base | L199 · 断言 `ChatError` 或服务端拒绝 | failed·已记录 |
| FL-MSG-060 | `sendMessage(to: 不存在的 userId)` | modules/message_cases.dart:1853 | logged_in_base | L200 · 断言错误码 | failed·已记录 |
| FL-MSG-061 | `fetchHistoryMessages(不存在的 convId)` | modules/message_cases.dart:1866 | logged_in_base | L201 · 返回空列表或错误，需固化契约 | passed |
| FL-MSG-062 | `recallMessage(超过 2 分钟的消息)` | modules/message_cases.dart:1881 | logged_in_base | L202 · 断言错误码 | passed |

### 2.4 会话（草稿 §3.4；27 行，已映射 27，未覆盖 0）

会话域 27 条全部映射，其中 CONV-001~006 为草稿编号前既有用例。

| Case | 被测 API | 用例文件:行 | 入口套件 | 草稿 | 状态 |
|---|---|---|---|---|---|
| FL-CONV-007 | `ext`（getter） | modules/conversation_cases.dart:414 | logged_in_base | L211 · 需先 `setExt` | passed |
| FL-CONV-008 | `setExt(ext)` | modules/conversation_cases.dart:434 | logged_in_base | L212 · 写回后 `ext` 可读；重启进程后仍在（落盘验证） | passed |
| FL-CONV-009 | `latestMessage` | modules/conversation_cases.dart:462 | logged_in_base | L213 · 与最后发送消息 id 一致 | passed |
| FL-CONV-010 | `lastReceivedMessage` | modules/conversation_cases.dart:485 | logged_in_base | L214 · 只统计接收方向 | passed |
| FL-CONV-011 | `unreadCount` | modules/conversation_cases.dart:516 | logged_in_base | L215 · 收 2 条后为 2 | passed |
| FL-CONV-012 | `markMessageAsRead(msgId)` | modules/conversation_cases.dart:539 | logged_in_base | L216 · 未读数递减 | passed |
| FL-CONV-013 | `markAllMessagesAsRead()` | modules/conversation_cases.dart:563 | logged_in_base | L217 · 未读归零 | passed |
| FL-CONV-014 | `insertMessage(msg)` | modules/conversation_cases.dart:592 | logged_in_base | L218 · 插入位置与时间序正确 | passed |
| FL-CONV-015 | `appendMessage(msg)` | modules/conversation_cases.dart:623 | logged_in_base | L219 · 追加到末尾 | passed |
| FL-CONV-016 | `updateMessage(msg)` | modules/conversation_cases.dart:645 | logged_in_base | L220 · 更新后重查生效 | passed |
| FL-CONV-017 | `deleteMessage(msgId)` | modules/conversation_cases.dart:671 | logged_in_base | L221 · 仅本地删除，服务端仍可拉回 | passed |
| FL-CONV-018 | `deleteAllMessages()` | modules/conversation_cases.dart:699 | logged_in_base | L222 · 本地清空 | passed |
| FL-CONV-019 | `loadMessage(msgId)` | modules/conversation_cases.dart:727 | logged_in_base | L223 · 存在/不存在两种 | passed |
| FL-CONV-020 | `loadMessagesWithMsgType(...)` | modules/conversation_cases.dart:747 | logged_in_base | L224 · 按类型过滤（文本/图片） | passed |
| FL-CONV-021 | `loadMessages(...)` | modules/conversation_cases.dart:780 | logged_in_base | L225 · 时间倒序 + 条数上限 | failed·待复跑 |
| FL-CONV-022 | `loadMessagesWithKeyword(...)` | modules/conversation_cases.dart:821 | logged_in_base | L226 · `sender` 参数已弃用（:710），用 `sende… | passed |
| FL-CONV-023 | `loadMessagesFromTime(...)` | modules/conversation_cases.dart:866 | logged_in_base | L227 · 起止时间窗 | passed |
| FL-CONV-024 | `messagesCount` | modules/conversation_cases.dart:896 | logged_in_base | L228 · 与 `getLocalMessageCount` 一致 | passed |
| FL-CONV-025 | `loadPinnedMessages()` | modules/conversation_cases.dart:936 | logged_in_base | L229 · 需先置顶消息（FL-MSG-045） | passed |
| FL-CONV-026 | `remindType` | modules/conversation_cases.dart:976 | logged_in_base | L230 · 静默模式设置后回读（关联 FL-PUSH-004） | passed |
| FL-CONV-027 | `searchMsgsByOptions(options)` | modules/conversation_cases.dart:1011 | logged_in_base | L231 · 本地搜索，多条件组合 | passed |
| FL-CONV-028 | `getLocalMessageCount()` | modules/conversation_cases.dart:1053 | logged_in_base | L232 · 与 `messagesCount` 对齐 | passed |
| FL-CONV-029 | `deleteLocalAndServerMessages(msgIds)` | modules/conversation_cases.dart:1083 | logged_in_base | L233 · 双端删除后重新拉取不含 | passed |
| FL-CONV-030 | `deleteLocalAndServerMessagesByTime(...)` | modules/conversation_cases.dart:1119 | logged_in_base | L234 · 时间窗删除 | passed |
| FL-CONV-031 | `loadMessagesFromTime(start > end)` | modules/conversation_cases.dart:1166 | logged_in_base | L235 · 空结果或错误，需固化契约 | skipped·UNVERIFIED |
| FL-CONV-032 | `deleteMessage(不存在的 msgId)` | modules/conversation_cases.dart:1182 | logged_in_base | L236 · 幂等成功或抛错，需固化契约 | passed |
| FL-CONV-033 | `insertMessage(已存在 msgId)` | modules/conversation_cases.dart:1197 | logged_in_base | L237 · 去重行为，不得产生重复行 | passed |

### 2.5 群组（草稿 §3.5；60 行，已映射 60，未覆盖 0）

群组 60 条全部映射；run2 中 42 条失败，主因是 REST 夹具路径错误（§6.3）。

| Case | 被测 API | 用例文件:行 | 入口套件 | 草稿 | 状态 |
|---|---|---|---|---|---|
| FL-GROUP-001 | `getGroupWithId(groupId)` | modules/group_cases.dart:36 | logged_in_group | L243 · 未加入时返回 null | failed·修复中 |
| FL-GROUP-002 | `getJoinedGroups()` | modules/group_cases.dart:55 | logged_in_group | L244 · 含预置群 | failed·修复中 |
| FL-GROUP-003 | `fetchJoinedGroupsFromServer({pageSize, pageNum, needMemberCount, needRole})` | modules/group_cases.dart:75 | logged_in_group | L245 · 分页 + 成员数/角色字段 | failed·修复中 |
| FL-GROUP-004 | `fetchPublicGroupsFromServer({pageSize, pageNum})` | modules/group_cases.dart:106 | logged_in_group | L246 · 需服务端存在公开群 | failed·修复中 |
| FL-GROUP-005 | `createGroup({groupName, inviteMembers, options, ...})` | modules/group_cases.dart:147 | logged_in_group | L247 · 创建后 `fetchJoinedGroupsFromSer… | failed·修复中 |
| FL-GROUP-006 | `fetchGroupInfoFromServer(groupId)` | modules/group_cases.dart:174 | logged_in_group | L248 · `fetchMembers` 参数已弃用（:500），不覆盖 | failed·修复中 |
| FL-GROUP-007 | `fetchMemberListFromServer(groupId)` | modules/group_cases.dart:197 | logged_in_group | L249 · 含 zuoyu01/zuoyu02 | failed·修复中 |
| FL-GROUP-008 | `fetchBlockListFromServer(groupId)` | modules/group_cases.dart:218 | logged_in_group | L250 · 先 `blockMembers`（FL-GROUP-017） | failed·修复中 |
| FL-GROUP-009 | `fetchMuteListFromServer(groupId)` | modules/group_cases.dart:240 | logged_in_group | L251 · 先 `muteMembers`（FL-GROUP-030） | failed·修复中 |
| FL-GROUP-010 | `fetchAllowListFromServer(groupId)` | modules/group_cases.dart:265 | logged_in_group | L252 · 先 `addAllowList`（FL-GROUP-034） | failed·修复中 |
| FL-GROUP-011 | `isMemberInAllowListFromServer(groupId, userId)` | modules/group_cases.dart:285 | logged_in_group | L253 · 白名单内外各一次 | failed·修复中 |
| FL-GROUP-012 | `fetchGroupFileListFromServer(groupId)` | modules/group_cases.dart:309 | logged_in_group | L254 · 先 `uploadGroupSharedFile`（FL-… | passed |
| FL-GROUP-013 | `fetchAnnouncementFromServer(groupId)` | modules/group_cases.dart:329 | logged_in_group | L255 · 先 `updateGroupAnnouncement` | passed |
| FL-GROUP-014 | `addMembers(groupId, members, {welcome})` | modules/group_cases.dart:343 | logged_in_group | L256 · 对端 `onMemberJoined` / `onMemb… | failed·修复中 |
| FL-GROUP-015 | `inviterUser(groupId, members, {reason})` | modules/group_cases.dart:364 | logged_in_group | L257 · 对端 `onInvitationReceived`（EVE… | failed·修复中 |
| FL-GROUP-016 | `removeMembers(groupId, members)` | modules/group_cases.dart:382 | logged_in_group | L258 · 对端 `onUserRemoved` | failed·修复中 |
| FL-GROUP-017 | `blockMembers(groupId, members)` | modules/group_cases.dart:401 | logged_in_group | L259 · 群黑名单 | failed·修复中 |
| FL-GROUP-018 | `unblockMembers(groupId, members)` | modules/group_cases.dart:425 | logged_in_group | L260 · 解除黑名单 | failed·修复中 |
| FL-GROUP-019 | `changeGroupName(groupId, name)` | modules/group_cases.dart:451 | logged_in_group | L261 · `@Deprecated`（:995），1 条冒烟；实际走… | passed |
| FL-GROUP-020 | `updateGroupName(groupId, name)` | modules/group_cases.dart:463 | logged_in_group | L262 · 主覆盖 | passed |
| FL-GROUP-021 | `changeGroupDescription(groupId, desc)` | modules/group_cases.dart:475 | logged_in_group | L263 · `@Deprecated`（:1047），1 条冒烟 | passed |
| FL-GROUP-022 | `updateGroupDesc(groupId, desc)` | modules/group_cases.dart:489 | logged_in_group | L264 · 主覆盖 | passed |
| FL-GROUP-023 | `leaveGroup(groupId)` | modules/group_cases.dart:504 | logged_in_group | L265 · 用临时群，避免毁掉共享夹具 | failed·修复中 |
| FL-GROUP-024 | `destroyGroup(groupId)` | modules/group_cases.dart:526 | logged_in_group | L266 · 仅群主；对端 `onGroupDestroyed`；用临时群 | failed·修复中 |
| FL-GROUP-025 | `blockGroup(groupId)` | modules/group_cases.dart:547 | logged_in_group | L267 · 屏蔽群消息，本地生效；解除见下条 | passed |
| FL-GROUP-026 | `unblockGroup(groupId)` | modules/group_cases.dart:560 | logged_in_group | L268 · 取消屏蔽 | passed |
| FL-GROUP-027 | `changeOwner(groupId, newOwner)` | modules/group_cases.dart:579 | logged_in_group | L269 · 仅群主；对端 `onOwnerChanged` | failed·修复中 |
| FL-GROUP-028 | `addAdmin(groupId, member)` | modules/group_cases.dart:595 | logged_in_group | L270 · 对端 `onAdminAddedFromGroup` | failed·修复中 |
| FL-GROUP-029 | `removeAdmin(groupId, member)` | modules/group_cases.dart:614 | logged_in_group | L271 · 对端 `onAdminRemoved` | failed·修复中 |
| FL-GROUP-030 | `muteMembers(groupId, members, {duration})` | modules/group_cases.dart:632 | logged_in_group | L272 · 对端 `onMuteListAdded` | failed·修复中 |
| FL-GROUP-031 | `unMuteMembers(groupId, members)` | modules/group_cases.dart:653 | logged_in_group | L273 · 对端 `onMuteListRemoved` | failed·修复中 |
| FL-GROUP-032 | `muteAllMembers(groupId)` | modules/group_cases.dart:674 | logged_in_group | L274 · 对端 `onAllGroupMemberMuteState… | passed |
| FL-GROUP-033 | `unMuteAllMembers(groupId)` | modules/group_cases.dart:688 | logged_in_group | L275 · 同上 | passed |
| FL-GROUP-034 | `addAllowList(groupId, members)` | modules/group_cases.dart:703 | logged_in_group | L276 · 对端 `onAllowListAdded` | failed·修复中 |
| FL-GROUP-035 | `removeAllowList(groupId, members)` | modules/group_cases.dart:721 | logged_in_group | L277 · 对端 `onAllowListRemoved` | failed·修复中 |
| FL-GROUP-036 | `uploadGroupSharedFile(groupId, filePath)` | modules/group_cases.dart:742 | logged_in_group | L278 · 需真实文件；对端 `onSharedFileAdded` | passed |
| FL-GROUP-037 | `downloadGroupSharedFile(groupId, fileId, savePath)` | modules/group_cases.dart:756 | logged_in_group | L279 · 需先上传（FL-GROUP-036） | passed |
| FL-GROUP-038 | `removeGroupSharedFile(groupId, fileId)` | modules/group_cases.dart:789 | logged_in_group | L280 · 对端 `onSharedFileDeleted` | passed |
| FL-GROUP-039 | `updateGroupAnnouncement(groupId, announcement)` | modules/group_cases.dart:806 | logged_in_group | L281 · 对端 `onAnnouncementChanged` | passed |
| FL-GROUP-040 | `updateGroupExtension(groupId, extension)` | modules/group_cases.dart:825 | logged_in_group | L282 · 回读一致 | passed |
| FL-GROUP-041 | `joinPublicGroup(groupId)` | modules/group_cases.dart:837 | logged_in_group | L283 · 需公开群 + 未加入的账号 | failed·修复中 |
| FL-GROUP-042 | `requestToJoinPublicGroup(groupId, {reason})` | modules/group_cases.dart:853 | logged_in_group | L284 · 对端 `onRequestToJoinReceived`（… | failed·修复中 |
| FL-GROUP-043 | `acceptJoinApplication(groupId, userId)` | modules/group_cases.dart:873 | logged_in_group | L285 · 需先有申请 | failed·修复中 |
| FL-GROUP-044 | `declineJoinApplication(groupId, userId)` | modules/group_cases.dart:889 | logged_in_group | L286 · 同上 | failed·修复中 |
| FL-GROUP-045 | `acceptInvitation(groupId, inviter)` | modules/group_cases.dart:909 | logged_in_group | L287 · 需 pending 邀请（FL-GROUP-015） | failed·修复中 |
| FL-GROUP-046 | `declineInvitation(groupId, inviter)` | modules/group_cases.dart:928 | logged_in_group | L288 · 同上 | failed·修复中 |
| FL-GROUP-047 | `setMemberAttributes(groupId, userId, attributes)` | modules/group_cases.dart:950 | logged_in_group | L289 · 群成员自定义属性 | failed·修复中 |
| FL-GROUP-048 | `fetchMemberAttributes(groupId, userId)` | modules/group_cases.dart:986 | logged_in_group | L290 · 回读一致 | failed·修复中 |
| FL-GROUP-049 | `fetchMembersAttributes(groupId, userIds)` | modules/group_cases.dart:1012 | logged_in_group | L291 · 批量 | failed·修复中 |
| FL-GROUP-050 | `fetchJoinedGroupCount()` | modules/group_cases.dart:1044 | logged_in_group | L292 · 与 `getJoinedGroups().length` … | failed·修复中 |
| FL-GROUP-051 | `isMemberInGroupMuteList(groupId, userId)` | modules/group_cases.dart:1058 | logged_in_group | L293 · 静音/非静音各一次 | failed·修复中 |
| FL-GROUP-052 | `clearAllGroupsFromLocal()` | modules/group_cases.dart:1077 | logged_in_group | L294 · 清本地群缓存，服务端仍可拉回 | failed·修复中 |
| FL-GROUP-053 | `fetchGroupMembersInfo(groupId, userIds)` | modules/group_cases.dart:1101 | logged_in_group | L295 · 指定成员信息 | failed·修复中 |
| FL-GROUP-054 | `updateGroupAvatar(groupId, filePath)` | modules/group_cases.dart:1128 | logged_in_group | L296 · 需图片文件；回读 avatar 变化 | passed |
| FL-GROUP-055 | `updateGroupNamecard(groupId, userId, namecard)` | modules/group_cases.dart:1144 | logged_in_group | L297 · 群昵称；对端 `onUserGroupNamecardCh… | failed·修复中 |
| FL-GROUP-056 | `getGroupNamecard(groupId, userId)` | modules/group_cases.dart:1174 | logged_in_group | L298 · 未设置返回空/默认 | failed·修复中 |
| FL-GROUP-057 | `createGroup({options: 非法组合})` | modules/group_cases.negative.dart:80 | logged_in_group | L299 · 断言参数错误码 | passed |
| FL-GROUP-058 | `addMembers(不存在的 userId)` | modules/group_cases.negative.dart:112 | logged_in_group | L300 · 断言错误码或部分成功 | failed·修复中 |
| FL-GROUP-059 | `leaveGroup(未加入的群)` | modules/group_cases.negative.dart:132 | logged_in_group | L301 · 断言错误码 | failed·修复中 |
| FL-GROUP-060 | `downloadGroupSharedFile(不存在的 fileId)` | modules/group_cases.negative.dart:144 | logged_in_group | L302 · 断言错误码 | passed |

### 2.6 聊天室（草稿 §3.6；31 行，已映射 31，未覆盖 0）

聊天室 31 条全部映射，special pilot5 全绿。

| Case | 被测 API | 用例文件:行 | 入口套件 | 草稿 | 状态 |
|---|---|---|---|---|---|
| FL-ROOM-001 | `joinChatRoom(roomId, {leaveOtherRooms, ext})` | modules/room_cases.dart:57 | logged_in_special | L312 · 对端 `onMemberJoined` | passed |
| FL-ROOM-002 | `leaveChatRoom(roomId)` | modules/room_cases.dart:70 | logged_in_special | L313 · 对端 `onMemberExited` | passed |
| FL-ROOM-003 | `fetchPublicChatRoomsFromServer({pageNum, pageSize})` | modules/room_cases.dart:87 | logged_in_special | L314 · 需公开聊天室 | passed |
| FL-ROOM-004 | `changeChatRoomName(roomId, name)` | modules/room_cases.dart:96 | logged_in_special | L315 · 仅房主；key 为 `changeChatRoomSubj… | passed |
| FL-ROOM-005 | `changeChatRoomDescription(roomId, desc)` | modules/room_cases.dart:104 | logged_in_special | L316 · 仅房主 | passed |
| FL-ROOM-006 | `fetchChatRoomMembers(roomId, {cursor, pageSize})` | modules/room_cases.dart:113 | logged_in_special | L317 · 分页 | passed |
| FL-ROOM-007 | `muteChatRoomMembers(roomId, members, {duration})` | modules/room_cases.dart:123 | logged_in_special | L318 · 对端 `onMuteListAdded` | passed |
| FL-ROOM-008 | `unMuteChatRoomMembers(roomId, members)` | modules/room_cases.dart:140 | logged_in_special | L319 · 对端 `onMuteListRemoved` | passed |
| FL-ROOM-009 | `changeOwner(roomId, newOwner)` | modules/room_cases.dart:395 | logged_in_special | L320 · 仅房主；对端 `onOwnerChanged` | passed |
| FL-ROOM-010 | `addChatRoomAdmin(roomId, admin)` | modules/room_cases.dart:153 | logged_in_special | L321 · 对端 `onAdminAddedFromChatRoom` | passed |
| FL-ROOM-011 | `removeChatRoomAdmin(roomId, admin)` | modules/room_cases.dart:162 | logged_in_special | L322 · 对端 `onAdminRemoved` | passed |
| FL-ROOM-012 | `fetchChatRoomMuteList(roomId)` | modules/room_cases.dart:169 | logged_in_special | L323 · 先禁言（FL-ROOM-007） | passed |
| FL-ROOM-013 | `removeChatRoomMembers(roomId, members)` | modules/room_cases.dart:176 | logged_in_special | L324 · 对端 `onRemovedFromChatRoom` | passed |
| FL-ROOM-014 | `blockChatRoomMembers(roomId, members)` | modules/room_cases.dart:185 | logged_in_special | L325 · 聊天室黑名单 | passed |
| FL-ROOM-015 | `unBlockChatRoomMembers(roomId, members)` | modules/room_cases.dart:200 | logged_in_special | L326 · 解除黑名单 | passed |
| FL-ROOM-016 | `fetchChatRoomBlockList(roomId)` | modules/room_cases.dart:213 | logged_in_special | L327 · 回读 | passed |
| FL-ROOM-017 | `updateChatRoomAnnouncement(roomId, announcement)` | modules/room_cases.dart:221 | logged_in_special | L328 · 对端 `onAnnouncementChanged` | passed |
| FL-ROOM-018 | `fetchChatRoomAnnouncement(roomId)` | modules/room_cases.dart:232 | logged_in_special | L329 · 回读一致 | passed |
| FL-ROOM-019 | `fetchChatRoomAllowListFromServer(roomId)` | modules/room_cases.dart:244 | logged_in_special | L330 · 走 whiteList 系列 key | passed |
| FL-ROOM-020 | `isMemberInChatRoomAllowList(roomId, userId)` | modules/room_cases.dart:252 | logged_in_special | L331 · 白名单内外各一次 | passed |
| FL-ROOM-021 | `addMembersToChatRoomAllowList(roomId, members)` | modules/room_cases.dart:261 | logged_in_special | L332 · 对端 `onAllowListAdded` | passed |
| FL-ROOM-022 | `removeMembersFromChatRoomAllowList(roomId, members)` | modules/room_cases.dart:276 | logged_in_special | L333 · 对端 `onAllowListRemoved` | passed |
| FL-ROOM-023 | `muteAllChatRoomMembers(roomId)` | modules/room_cases.dart:289 | logged_in_special | L334 · 对端 `onAllChatRoomMemberMuteSt… | passed |
| FL-ROOM-024 | `unMuteAllChatRoomMembers(roomId)` | modules/room_cases.dart:297 | logged_in_special | L335 · 同上 | passed |
| FL-ROOM-025 | `fetchChatRoomAttributes(roomId, {keys})` | modules/room_cases.dart:305 | logged_in_special | L336 · 全量 / 指定 key 两种 | passed |
| FL-ROOM-026 | `addAttributes(roomId, {attributes, deleteWhenLeft, overwrite})` | modules/room_cases.dart:314 | logged_in_special | L337 · 对端 `onAttributesUpdated`；覆盖/不… | passed |
| FL-ROOM-027 | `removeAttributes(roomId, {keys, force})` | modules/room_cases.dart:337 | logged_in_special | L338 · 对端 `onAttributesRemoved` | passed |
| FL-ROOM-028 | `isMemberInChatRoomMuteList(roomId, userId)` | modules/room_cases.dart:357 | logged_in_special | L339 · 禁言/非禁言各一次 | passed |
| FL-ROOM-029 | `joinChatRoom(不存在的 roomId)` | modules/room_cases.dart:366 | logged_in_special | L340 · 断言错误码 | passed |
| FL-ROOM-030 | `fetchChatRoomMembers(不存在的 roomId)` | modules/room_cases.dart:374 | logged_in_special | L341 · 断言错误码 | passed |
| FL-ROOM-031 | `addAttributes(空 map)` | modules/room_cases.dart:383 | logged_in_special | L342 · 断言参数错误码 | passed |

### 2.7 Push（草稿 §3.7；13 行，已映射 13，未覆盖 0）

Push 13 条全部映射；PUSH-003/010/011/013 在 special 入口执行。

| Case | 被测 API | 用例文件:行 | 入口套件 | 草稿 | 状态 |
|---|---|---|---|---|---|
| FL-PUSH-001 | `updatePushNickname(nickname)` | modules/push_cases.dart:11 | logged_in_base | L352 · 服务端离线推送昵称回读一致 | passed |
| FL-PUSH-002 | `updatePushDisplayStyle(style)` | modules/push_cases.dart:16 | logged_in_base | L353 · `Simple` / `Summary` 各一次 | passed |
| FL-PUSH-003 | `bindDeviceToken({notifierName, deviceToken})` | modules/push_cases.dart:93 | logged_in_special | L354 · 需真机 + HMS notifier 证书；模拟器只能断言… | passed |
| FL-PUSH-004 | `setConversationSilentMode(convId, param)` | modules/push_cases.dart:21 | logged_in_base | L355 · 设置后 `ChatConversation.remindT… | passed |
| FL-PUSH-005 | `removeConversationSilentMode(convId)` | modules/push_cases.dart:36 | logged_in_base | L356 · 移除后恢复默认 | passed |
| FL-PUSH-006 | `fetchConversationSilentMode(convId)` | modules/push_cases.dart:49 | logged_in_base | L357 · 回读一致 | passed |
| FL-PUSH-007 | `setSilentModeForAll(param)` | modules/push_cases.dart:59 | logged_in_base | L358 · 全局免打扰时段 | passed |
| FL-PUSH-008 | `fetchSilentModeForAll()` | modules/push_cases.dart:65 | logged_in_base | L359 · 回读一致 | passed |
| FL-PUSH-009 | `fetchSilentModeForConversations(convIds)` | modules/push_cases.dart:70 | logged_in_base | L360 · 批量返回 map | passed |
| FL-PUSH-010 | `setPushTemplate(templateName)` | modules/push_cases.dart:111 | logged_in_special | L361 · 需服务端预置模板；模板不存在为负向 | passed |
| FL-PUSH-011 | `getPushTemplate()` | modules/push_cases.dart:116 | logged_in_special | L362 · 与 `setPushTemplate` 对齐 | passed |
| FL-PUSH-012 | `syncConversationsSilentMode()` | modules/push_cases.dart:84 | logged_in_base | L363 · 多端设置后同步到本端 | passed |
| FL-PUSH-013 | `bindDeviceToken(非法 notifierName)` | modules/push_cases.dart:121 | logged_in_special | L364 · 断言错误码 | passed·dev |

### 2.8 UserInfo（草稿 §3.8；10 行，已映射 10，未覆盖 0）

UserInfo 10 条全部映射；run3 全绿，含 2 条 deviation 记录。

| Case | 被测 API | 用例文件:行 | 入口套件 | 草稿 | 状态 |
|---|---|---|---|---|---|
| FL-USERINFO-001 | `updateUserInfo({nickname, avatarUrl, mail, phone, gender, sign, birth, ext})` | modules/user_info_cases.dart:32 | logged_in_user_info | L370 · 全字段一次、部分字段一次；对端 `onUserInfoUp… | passed |
| FL-USERINFO-002 | `fetchOwnInfo({expireTime})` | modules/user_info_cases.dart:104 | logged_in_user_info | L371 · `expireTime=0` 强制拉服务端；对端 `onS… | passed |
| FL-USERINFO-003 | `fetchUserInfoById(userIds, {expireTime})` | modules/user_info_cases.dart:138 | logged_in_user_info | L372 · 多 id + 不存在 id 混合 | passed·dev |
| FL-USERINFO-004 | `clearUserInfoCache()` | modules/user_info_cases.dart:165 | logged_in_user_info | L373 · 清缓存后 `getLocalUserInfoByIds` … | passed |
| FL-USERINFO-005 | `subscribeUsersInfo(userIds)` | modules/user_info_cases.dart:187 | logged_in_user_info | L374 · 订阅后对端更新触发 `onUserInfoUpdate` | passed |
| FL-USERINFO-006 | `unsubscribeUsersInfo(userIds)` | modules/user_info_cases.dart:202 | logged_in_user_info | L375 · 取消后不再触发 | passed |
| FL-USERINFO-007 | `fetchSubscribedUsers()` | modules/user_info_cases.dart:224 | logged_in_user_info | L376 · 含已订阅用户 | passed |
| FL-USERINFO-008 | `getLocalUserInfoByIds(userIds)` | modules/user_info_cases.dart:245 | logged_in_user_info | L377 · 未缓存时返回空 | passed |
| FL-USERINFO-009 | `fetchUserInfoById([])` | modules/user_info_cases.dart:267 | logged_in_user_info | L378 · 空列表应返回空 map | passed |
| FL-USERINFO-010 | `updateUserInfo(非法 phone/avatarUrl)` | modules/user_info_cases.dart:279 | logged_in_user_info | L379 · 断言错误码或服务端拒绝 | passed·dev |

### 2.9 Presence（草稿 §3.9；5 行，已映射 5，未覆盖 0）

草稿新增 5 条（PRESENCE-006~010）；PRESENCE-001~005 为未登录负向既有用例，在 logged_out 执行。

| Case | 被测 API | 用例文件:行 | 入口套件 | 草稿 | 状态 |
|---|---|---|---|---|---|
| FL-PRESENCE-006 | `publishPresence(description)` | modules/presence_cases.dart:9 | logged_in_base | L389 · 对端 `onPresenceStatusChanged` … | passed |
| FL-PRESENCE-007 | `subscribe(members, {expiry})` | modules/presence_cases.dart:15 | logged_in_base | L390 · `expiry` 单位待确认（存疑 §5） | passed |
| FL-PRESENCE-008 | `unsubscribe(members)` | modules/presence_cases.dart:30 | logged_in_base | L391 · 取消后 `fetchSubscribedMembers` … | passed |
| FL-PRESENCE-009 | `fetchSubscribedMembers({pageNum, pageSize})` | modules/presence_cases.dart:37 | logged_in_base | L392 · 分页 | passed |
| FL-PRESENCE-010 | `fetchPresenceStatus(members)` | modules/presence_cases.dart:45 | logged_in_base | L393 · 对端已 publish 时返回其状态 | passed |

### 2.10 事件注册方法（草稿 §3.10.1；35 行，已映射 35，未覆盖 0）

35 个注册/注销方法均有独立用例，全部 passed。

| Case | 被测 API | 用例文件:行 | 入口套件 | 草稿 | 状态 |
|---|---|---|---|---|---|
| FL-EVENT-001 | `ChatClient.addConnectionEventHandler(id, handler)` | modules/event_registration_cases.dart:14 | logged_out | L403 · 注册后 `getConnectionEventHandle… | passed |
| FL-EVENT-002 | `ChatClient.removeConnectionEventHandler(id)` | modules/event_registration_cases.dart:23 | logged_out | L404 · 注销后不再回调 | passed |
| FL-EVENT-003 | `ChatClient.getConnectionEventHandler(id)` | modules/event_registration_cases.dart:34 | logged_out | L405 · 未注册返回 null | passed |
| FL-EVENT-004 | `ChatClient.clearConnectionEventHandlers()` | modules/event_registration_cases.dart:42 | logged_out | L406 · 清空全部 | passed |
| FL-EVENT-005 | `ChatClient.addMultiDeviceEventHandler(id, handler)` | modules/event_registration_cases.dart:61 | logged_in_base | L407 · 同上 | passed |
| FL-EVENT-006 | `ChatClient.removeMultiDeviceEventHandler(id)` | modules/event_registration_cases.dart:70 | logged_in_base | L408 · 同上 | passed |
| FL-EVENT-007 | `ChatClient.getMultiDeviceEventHandler(id)` | modules/event_registration_cases.dart:81 | logged_in_base | L409 · 同上 | passed |
| FL-EVENT-008 | `ChatClient.clearMultiDeviceEventHandlers()` | modules/event_registration_cases.dart:89 | logged_in_base | L410 · 同上 | passed |
| FL-EVENT-009 | `ChatContactManager.addEventHandler(id, handler)` | modules/event_registration_cases.dart:101 | logged_in_base | L411 · 同上 | passed |
| FL-EVENT-010 | `ChatContactManager.removeEventHandler(id)` | modules/event_registration_cases.dart:110 | logged_in_base | L412 · 同上 | passed |
| FL-EVENT-011 | `ChatContactManager.getEventHandler(id)` | modules/event_registration_cases.dart:121 | logged_in_base | L413 · 同上 | passed |
| FL-EVENT-012 | `ChatContactManager.clearEventHandlers()` | modules/event_registration_cases.dart:129 | logged_in_base | L414 · 同上 | passed |
| FL-EVENT-013 | `ChatManager.addEventHandler(id, handler)` | modules/event_registration_cases.dart:141 | logged_in_base | L415 · 同上 | passed |
| FL-EVENT-014 | `ChatManager.removeEventHandler(id)` | modules/event_registration_cases.dart:150 | logged_in_base | L416 · 同上 | passed |
| FL-EVENT-015 | `ChatManager.getEventHandler(id)` | modules/event_registration_cases.dart:160 | logged_in_base | L417 · 同上 | passed |
| FL-EVENT-016 | `ChatManager.clearEventHandlers()` | modules/event_registration_cases.dart:167 | logged_in_base | L418 · 同上 | passed |
| FL-EVENT-017 | `ChatManager.addMessageEvent(id, ChatMessageEvent)` | modules/event_registration_cases.dart:177 | logged_in_base | L419 · 发送进度回调注册 | passed |
| FL-EVENT-018 | `ChatManager.removeMessageEvent(id)` | modules/event_registration_cases.dart:184 | logged_in_base | L420 · 注销后无进度回调 | passed |
| FL-EVENT-019 | `ChatManager.clearMessageEvent()` | modules/event_registration_cases.dart:191 | logged_in_base | L421 · 清空全部 | passed |
| FL-EVENT-020 | `ChatGroupManager.addEventHandler(id, handler)` | modules/event_registration_cases.dart:201 | logged_in_base | L422 · 同上 | passed |
| FL-EVENT-021 | `ChatGroupManager.removeEventHandler(id)` | modules/event_registration_cases.dart:210 | logged_in_base | L423 · 同上 | passed |
| FL-EVENT-022 | `ChatGroupManager.getEventHandler(id)` | modules/event_registration_cases.dart:220 | logged_in_base | L424 · 同上 | passed |
| FL-EVENT-023 | `ChatGroupManager.clearEventHandlers()` | modules/event_registration_cases.dart:227 | logged_in_base | L425 · 同上 | passed |
| FL-EVENT-024 | `ChatRoomManager.addEventHandler(id, handler)` | modules/event_registration_cases.dart:239 | logged_in_base | L426 · 同上 | passed |
| FL-EVENT-025 | `ChatRoomManager.removeEventHandler(id)` | modules/event_registration_cases.dart:248 | logged_in_base | L427 · 同上 | passed |
| FL-EVENT-026 | `ChatRoomManager.getEventHandler(id)` | modules/event_registration_cases.dart:258 | logged_in_base | L428 · 同上 | passed |
| FL-EVENT-027 | `ChatRoomManager.clearEventHandlers()` | modules/event_registration_cases.dart:266 | logged_in_base | L429 · 同上 | passed |
| FL-EVENT-028 | `ChatPresenceManager.addEventHandler(id, handler)` | modules/event_registration_cases.dart:278 | logged_in_base | L430 · 同上 | passed |
| FL-EVENT-029 | `ChatPresenceManager.removeEventHandler(id)` | modules/event_registration_cases.dart:287 | logged_in_base | L431 · 同上 | passed |
| FL-EVENT-030 | `ChatPresenceManager.getEventHandler(id)` | modules/event_registration_cases.dart:297 | logged_in_base | L432 · 同上 | passed |
| FL-EVENT-031 | `ChatPresenceManager.clearEventHandlers()` | modules/event_registration_cases.dart:305 | logged_in_base | L433 · 同上 | passed |
| FL-EVENT-032 | `ChatUserInfoManager.addEventHandler(id, handler)` | modules/event_registration_cases.dart:317 | logged_in_base | L434 · 同上 | passed |
| FL-EVENT-033 | `ChatUserInfoManager.removeEventHandler(id)` | modules/event_registration_cases.dart:326 | logged_in_base | L435 · 同上 | passed |
| FL-EVENT-034 | `ChatUserInfoManager.getEventHandler(id)` | modules/event_registration_cases.dart:336 | logged_in_base | L436 · 同上 | passed |
| FL-EVENT-035 | `ChatUserInfoManager.clearEventHandlers()` | modules/event_registration_cases.dart:344 | logged_in_base | L437 · 同上 | passed |

### 2.11 ConnectionEventHandler（草稿 §3.10.2；13 行，已映射 0，未覆盖 13）

| Case | 回调 | 草稿 | 覆盖方式 |
|---|---|---|---|
| FL-EVENT-036 | `onConnected()` | L443 | 未逐条覆盖 |
| FL-EVENT-037 | `onDisconnected()` | L444 | 未逐条覆盖 |
| FL-EVENT-038 | `onUserDidLoginFromOtherDevice()` | L445 | 未逐条覆盖 |
| FL-EVENT-039 | `onUserDidRemoveFromServer()` | L446 | 未逐条覆盖 |
| FL-EVENT-040 | `onUserDidForbidByServer()` | L447 | 未逐条覆盖 |
| FL-EVENT-041 | `onUserDidChangePassword()` | L448 | 未逐条覆盖 |
| FL-EVENT-042 | `onUserDidLoginTooManyDevice()` | L449 | 未逐条覆盖 |
| FL-EVENT-043 | `onUserKickedByOtherDevice()` | L450 | 未逐条覆盖 |
| FL-EVENT-044 | `onUserAuthenticationFailed()` | L451 | 未逐条覆盖 |
| FL-EVENT-045 | `onTokenWillExpire()` | L452 | 未逐条覆盖 |
| FL-EVENT-046 | `onTokenDidExpire()` | L453 | 未逐条覆盖 |
| FL-EVENT-047 | `onOfflineMessageSyncStart()` | L454 | 未逐条覆盖 |
| FL-EVENT-048 | `onOfflineMessageSyncFinish()` | L455 | 未逐条覆盖 |

### 2.12 ChatMultiDeviceEventHandler（草稿 §3.10.3；4 行，已映射 0，未覆盖 4）

| Case | 回调 | 草稿 | 覆盖方式 |
|---|---|---|---|
| FL-EVENT-049 | `onContactEvent(type, data)` | L461 | 未逐条覆盖 |
| FL-EVENT-050 | `onGroupEvent(type, data)` | L462 | 未逐条覆盖 |
| FL-EVENT-051 | `onRemoteMessagesRemoved(convId)` | L463 | 未逐条覆盖 |
| FL-EVENT-052 | `onConversationEvent(type, convId)` | L464 | 未逐条覆盖 |

### 2.13 ChatEventHandler + ChatMessageEvent（草稿 §3.10.4；17 行，已映射 0，未覆盖 17）

| Case | 回调 | 草稿 | 覆盖方式 |
|---|---|---|---|
| FL-EVENT-053 | `onMessagesReceived(List<ChatMessage>)` | L470 | 未逐条覆盖 |
| FL-EVENT-054 | `onStreamMessagesReceived(List<ChatMessage>)` | L471 | 未逐条覆盖 |
| FL-EVENT-055 | `onCmdMessagesReceived(List<ChatMessage>)` | L472 | 未逐条覆盖 |
| FL-EVENT-056 | `onMessagesRead(List<ChatMessage>)` | L473 | 未逐条覆盖（UNVERIFIED） |
| FL-EVENT-057 | `onGroupMessageRead(List<ChatGroupMessageAck>)` | L474 | 未逐条覆盖 |
| FL-EVENT-058 | `onReadAckForGroupMessageUpdated()` | L475 | 未逐条覆盖 |
| FL-EVENT-059 | `onMessagesDelivered(List<ChatMessage>)` | L476 | 未逐条覆盖 |
| FL-EVENT-060 | `onMessagesRecalled(List<ChatMessage>)` | L477 | 未逐条覆盖 |
| FL-EVENT-061 | `onMessagesRecalledInfo(List<ChatMessage>)` | L478 | 未逐条覆盖 |
| FL-EVENT-062 | `onConversationsUpdate()` | L479 | 未逐条覆盖 |
| FL-EVENT-063 | `onConversationRead(from, to)` | L480 | 未逐条覆盖（UNVERIFIED） |
| FL-EVENT-064 | `onMessageReactionDidChange(List<ChatMessageReactionEvent>)` | L481 | 未逐条覆盖 |
| FL-EVENT-065 | `onMessageContentChanged(msg, operatorId, time)` | L482 | 未逐条覆盖 |
| FL-EVENT-066 | `onMessagePinChanged(convId, msgId, op, time)` | L483 | 未逐条覆盖 |
| FL-EVENT-067 | `ChatMessageEvent.onSuccess(msg)` | L484 | 间接断言 |
| FL-EVENT-068 | `ChatMessageEvent.onError(msg, error)` | L485 | 间接断言 |
| FL-EVENT-069 | `ChatMessageEvent.onProgress(msg, progress)` | L486 | 未断言 |

### 2.14 ChatRoomEventHandler（草稿 §3.10.5；16 行，已映射 0，未覆盖 16）

| Case | 回调 | 草稿 | 覆盖方式 |
|---|---|---|---|
| FL-EVENT-070 | `onAdminAddedFromChatRoom(roomId, admin)` | L494 | 未逐条覆盖 |
| FL-EVENT-071 | `onAdminRemoved(roomId, admin)` | L495 | 未逐条覆盖 |
| FL-EVENT-072 | `onAllChatRoomMemberMuteStateChanged(roomId, muted)` | L496 | 未逐条覆盖 |
| FL-EVENT-073 | `onAllowListAdded(roomId, members)` | L497 | 未逐条覆盖 |
| FL-EVENT-074 | `onAllowListRemoved(roomId, members)` | L498 | 未逐条覆盖 |
| FL-EVENT-075 | `onAnnouncementChanged(roomId, announcement)` | L499 | 未逐条覆盖 |
| FL-EVENT-076 | `onChatRoomDestroyed(roomId, reason)` | L500 | 未逐条覆盖 |
| FL-EVENT-077 | `onMemberExited(roomId, member, ext)` | L501 | 未逐条覆盖 |
| FL-EVENT-078 | `onMemberJoined(roomId, member, ext)` | L502 | 未逐条覆盖 |
| FL-EVENT-079 | `onMuteListAdded(roomId, members, expireTs)` | L503 | 未逐条覆盖 |
| FL-EVENT-080 | `onMuteListRemoved(roomId, members)` | L504 | 未逐条覆盖 |
| FL-EVENT-081 | `onOwnerChanged(roomId, newOwner, oldOwner)` | L505 | 未逐条覆盖 |
| FL-EVENT-082 | `onRemovedFromChatRoom(reason, roomId, member)` | L506 | 未逐条覆盖 |
| FL-EVENT-083 | `onSpecificationChanged(room)` | L507 | 未逐条覆盖 |
| FL-EVENT-084 | `onAttributesUpdated(roomId, attributes)` | L508 | 未逐条覆盖 |
| FL-EVENT-085 | `onAttributesRemoved(roomId, keys)` | L509 | 未逐条覆盖 |

### 2.15 ChatContactEventHandler（草稿 §3.10.6；8 行，已映射 0，未覆盖 8）

| Case | 回调 | 草稿 | 覆盖方式 |
|---|---|---|---|
| FL-EVENT-086 | `onContactAdded(userId)` | L515 | 未逐条覆盖 |
| FL-EVENT-087 | `onContactDeleted(userId)` | L516 | 未逐条覆盖 |
| FL-EVENT-088 | `onContactInvited(userId, reason)` | L517 | 未逐条覆盖 |
| FL-EVENT-089 | `onFriendRequestAccepted(userId)` | L518 | 未逐条覆盖 |
| FL-EVENT-090 | `onFriendRequestDeclined(userId)` | L519 | 未逐条覆盖 |
| FL-EVENT-091 | `onContactSyncStart()` | L520 | 未逐条覆盖 |
| FL-EVENT-092 | `onContactSyncFinish()` | L521 | 未逐条覆盖 |
| FL-EVENT-093 | `onContactInfoUpdate(contacts)` | L522 | 未逐条覆盖 |

### 2.16 ChatGroupEventHandler（草稿 §3.10.7；28 行，已映射 0，未覆盖 28）

| Case | 回调 | 草稿 | 覆盖方式 |
|---|---|---|---|
| FL-EVENT-094 | `onAdminAddedFromGroup(groupId, admin)` | L528 | 未逐条覆盖 |
| FL-EVENT-095 | `onAdminRemoved(groupId, admin)` | L529 | 未逐条覆盖 |
| FL-EVENT-096 | `onAllGroupMemberMuteStateChanged(groupId, muted)` | L530 | 未逐条覆盖 |
| FL-EVENT-097 | `onAllowListAdded(groupId, members)` | L531 | 未逐条覆盖 |
| FL-EVENT-098 | `onAllowListRemoved(groupId, members)` | L532 | 未逐条覆盖 |
| FL-EVENT-099 | `onAnnouncementChanged(groupId, announcement)` | L533 | 未逐条覆盖 |
| FL-EVENT-100 | `onAutoAcceptInvitation(groupId, inviter, inviteMessage)` | L534 | 未逐条覆盖 |
| FL-EVENT-101 | `onGroupDestroyed(groupId)` | L535 | 未逐条覆盖 |
| FL-EVENT-102 | `onInvitationAccepted(groupId, invitee, reason)` | L536 | 未逐条覆盖 |
| FL-EVENT-103 | `onInvitationDeclined(groupId, invitee, reason)` | L537 | 未逐条覆盖 |
| FL-EVENT-104 | `onInvitationReceived(groupId, inviter, reason)` | L538 | 未逐条覆盖 |
| FL-EVENT-105 | `onMemberExited(groupId, member)` | L539 | 未逐条覆盖 |
| FL-EVENT-106 | `onMemberJoined(groupId, member)` | L540 | 未逐条覆盖 |
| FL-EVENT-107 | `onMuteListAdded(groupId, mutes, expireTs)` | L541 | 未逐条覆盖 |
| FL-EVENT-108 | `onMuteListRemoved(groupId, mutes)` | L542 | 未逐条覆盖 |
| FL-EVENT-109 | `onOwnerChanged(groupId, newOwner, oldOwner)` | L543 | 未逐条覆盖 |
| FL-EVENT-110 | `onRequestToJoinAccepted(groupId, accepter)` | L544 | 未逐条覆盖 |
| FL-EVENT-111 | `onRequestToJoinDeclined(groupId, decliner, reason)` | L545 | 未逐条覆盖 |
| FL-EVENT-112 | `onRequestToJoinReceived(groupId, applicant, reason)` | L546 | 未逐条覆盖 |
| FL-EVENT-113 | `onSharedFileAdded(groupId, sharedFile)` | L547 | 未逐条覆盖 |
| FL-EVENT-114 | `onSpecificationDidUpdate(group)` | L548 | 未逐条覆盖 |
| FL-EVENT-115 | `onDisableChanged(groupId, disabled)` | L549 | 未逐条覆盖 |
| FL-EVENT-116 | `onSharedFileDeleted(groupId, fileId)` | L550 | 未逐条覆盖 |
| FL-EVENT-117 | `onUserRemoved(groupId, groupName)` | L551 | 未逐条覆盖 |
| FL-EVENT-118 | `onAttributesChangedOfGroupMember(groupId, userId, attributes, operatorId)` | L552 | 未逐条覆盖 |
| FL-EVENT-119 | `onMembersJoined(groupId, members)` | L553 | 未逐条覆盖 |
| FL-EVENT-120 | `onMembersExited(groupId, members)` | L554 | 未逐条覆盖 |
| FL-EVENT-121 | `onUserGroupNamecardChanged(groupId, userId, namecard)` | L555 | 未逐条覆盖 |

### 2.17 ChatPresence / ChatUserInfoEventHandler（草稿 §3.10.8；3 行，已映射 0，未覆盖 3）

| Case | 回调 | 草稿 | 覆盖方式 |
|---|---|---|---|
| FL-EVENT-122 | `onPresenceStatusChanged(List<ChatPresence>)` | L561 | 未逐条覆盖 |
| FL-EVENT-123 | `onSelfUserInfoUpdate(ChatUserInfo)` | L562 | 未逐条覆盖 |
| FL-EVENT-124 | `onUserInfoUpdate(List<ChatUserInfo>)` | L563 | 未逐条覆盖 |

## 3. 未覆盖缺口（26 行）

以下行在草稿中有编号，但 `modules/*.dart` 中没有对应用例。它们不计入任何 passed/failed 统计。

| Case | 被测 API | 草稿 | 原因 | 建议 |
|---|---|---|---|---|
| FL-CLIENT-011 | `customEventHandler`（公开字段） | L73 | 无用例；`customEventHandler` ArkTS 未实现（草稿 §5 存疑 5） | 保持缺口并在文档标注，或补“注册不触发”的弱断言 |
| FL-AUTH-002 | `createAccount(userId, password)` | L80 | 无用例；createAccount 走 REST 注册 | 补 logged_out 用例（一次性账号） |
| FL-AUTH-003 | `login(userId, pwdOrToken, isPassword)` | L81 | 无用例；login 为 @Deprecated | 补冒烟用例或从清单降级 |
| FL-AUTH-004 | `loginWithToken(userId, token)` | L82 | 无用例；loginWithToken 仅作 `support/login.dart:51` 夹具与 FL-AUTH-020 负向 | 补主登录路径用例 |
| FL-AUTH-001 | `loginWithPassword(userId, password)` | L83 | 仅存在于临时入口 `single_account_local_test.dart:46`，正式套件未收录 | 移入 `client_cases.negative.dart` 或新 auth 模块并纳入 logged_out |
| FL-AUTH-005 | `renewAgoraToken(token)` | L84 | 无用例；chatsdk 无语义（草稿 §5 存疑） | 确认语义后再决定是否建用例 |
| FL-AUTH-006 | `logout([unbindDeviceToken])` | L85 | 无用例；登出仅由夹具 `ensureLoggedOutForCi` 使用 | 补用例（登出后 isConnected/currentUserId） |
| FL-AUTH-007 | `changeAppKey(newAppKey)` | L86 | 无用例 | 补 logged_out 用例（REST 换 appKey 风险高，需单独 appKey） |
| FL-AUTH-008 | `changeAppId(newAppId)` | L87 | 无用例；语义待确认 | 先确认语义 |
| FL-CLIENT-020 | `updateUsingHttpsOnlySetting(enable)` | L88 | 零调用：`modules/` 与 `support/` 中均未出现 | 补 logged_out 本地开关用例（不抛错 + 同会话可读回） |
| FL-CLIENT-021 | `updateLoginExtensionInfoSetting(enable)` | L89 | 零调用：`modules/` 与 `support/` 中均未出现 | 补 logged_out 本地开关用例（不抛错 + 同会话可读回） |
| FL-CLIENT-022 | `updateDeleteMessagesWhenLeaveGroupSetting(enable)` | L90 | 零调用：`modules/` 与 `support/` 中均未出现 | 补 logged_out 本地开关用例（不抛错 + 同会话可读回） |
| FL-CLIENT-023 | `updateDeleteMessageWhenLeaveRoomSetting(enable)` | L91 | 零调用：`modules/` 与 `support/` 中均未出现 | 补 logged_out 本地开关用例（不抛错 + 同会话可读回） |
| FL-CLIENT-024 | `updateAutoAcceptGroupInvitationSetting(enable)` | L92 | 零调用：`modules/` 与 `support/` 中均未出现 | 补 logged_out 本地开关用例（不抛错 + 同会话可读回） |
| FL-CLIENT-025 | `updateAutoAcceptFriendInvitationSetting(enable)` | L93 | 零调用：`modules/` 与 `support/` 中均未出现 | 补 logged_out 本地开关用例（不抛错 + 同会话可读回） |
| FL-CLIENT-026 | `updateAutoDownloadAttachmentThumbnailSetting(enable)` | L94 | 零调用：`modules/` 与 `support/` 中均未出现 | 补 logged_out 本地开关用例（不抛错 + 同会话可读回） |
| FL-CLIENT-027 | `updateRequireAckSetting(enable)` | L95 | 零调用：`modules/` 与 `support/` 中均未出现 | 补 logged_out 本地开关用例（不抛错 + 同会话可读回） |
| FL-CLIENT-028 | `updateDeliveryAckSetting(enable)` | L96 | 零调用：`modules/` 与 `support/` 中均未出现 | 补 logged_out 本地开关用例（不抛错 + 同会话可读回） |
| FL-CLIENT-029 | `updateSortMessageByServerTimeSetting(enable)` | L97 | 零调用：`modules/` 与 `support/` 中均未出现 | 补 logged_out 本地开关用例（不抛错 + 同会话可读回） |
| FL-CLIENT-030 | `updateMessagesReceiveCallbackIncludeSendSetting(enable)` | L98 | 零调用：`modules/` 与 `support/` 中均未出现 | 补 logged_out 本地开关用例（不抛错 + 同会话可读回） |
| FL-CLIENT-031 | `updateRegradeMessagesAsReadSetting(enable)` | L99 | 零调用：`modules/` 与 `support/` 中均未出现 | 补 logged_out 本地开关用例（不抛错 + 同会话可读回） |
| FL-AUTH-021 | `createAccount(已有 userId, pwd)` | L101 | 无用例；重复注册需 REST 前置 | 补负向用例 |
| FL-AUTH-022 | `changeAppKey(登录态)` | L102 | 无用例 | 补负向用例 |
| FL-MSG-004 | `sendGroupMessageReadAck(msgId, groupId, {content})` | L144 | `message_cases.dart:1896-1901` 注释标记 SKIPPED(group entry)，group 入口未迁移 | 迁入 `group_cases.dart`（需群消息 + 已读回执夹具） |
| FL-MSG-028 | `fetchGroupAcks(msgId, groupId, {startTs, endTs})` | L168 | `message_cases.dart:1896-1901` 注释标记 SKIPPED(group entry) | 迁入 `group_cases.dart` |
| FL-MSG-057 | `ChatMessage.groupAckCount() → Future<int>` | L197 | `message_cases.dart:1896-1901` 注释标记 SKIPPED(group entry) | 迁入 `group_cases.dart` |

## 4. 事件回调覆盖统计（89 行）

### 4.1 注册方法（35）

`FL-EVENT-001`~`004` 在 logged_out 入口、`005`~`035` 在 logged_in_base 入口，全部是本地注册表增删查清断言（不等待原生事件投递），35 条全部 passed。文件：`modules/event_registration_cases.dart`（`registerLoggedOutEventCases` L13、`registerManagerEventCases` L59）。

### 4.2 回调（89）

| 处理器 | 回调数 | Case 区间 | 覆盖方式 |
|---|---:|---|---|
| ConnectionEventHandler | 13 | FL-EVENT-036~048 | 仅注册/注销验证，投递未断言 |
| ChatMultiDeviceEventHandler | 4 | FL-EVENT-049~052 | 仅注册/注销验证；多端场景需第二设备 |
| ChatEventHandler + ChatMessageEvent | 17 | FL-EVENT-053~069 | onSuccess/onError 间接断言；onMessagesRead/onConversationRead 标 UNVERIFIED；onProgress 未断言 |
| ChatRoomEventHandler | 16 | FL-EVENT-070~085 | 仅注册/注销验证（special 入口） |
| ChatContactEventHandler | 8 | FL-EVENT-086~093 | 仅注册/注销验证；对端事件需第二账号在线 |
| ChatGroupEventHandler | 28 | FL-EVENT-094~121 | 仅注册/注销验证；多端/群事件未逐条断言 |
| ChatPresenceEventHandler / ChatUserInfoEventHandler | 3 | FL-EVENT-122~124 | 仅注册/注销验证 |
| **合计** | **89** | 036~124 | 0 条逐条用例 |

统计结论：

- **有逐条用例的回调：0 条。** 回调行不能算“有对应用例”，只能算“注册入口已被覆盖”。
- **间接断言：2 条**（`FL-EVENT-067` onSuccess、`FL-EVENT-068` onError）。`message_cases.dart:59-70` 与 `conversation_cases.dart:148-161` 的 `awaitFinalSend` 用这两个回调关联发送结果，发送/重发/下载类用例依赖它完成。
- **明确 UNVERIFIED：2 条**。`FL-EVENT-056` onMessagesRead 见 `message_cases.dart:516`；`FL-EVENT-063` onConversationRead 见 `message_cases.dart:552`——单设备入口没有对端在线，回调无法观测。
- **未断言：1 条**（`FL-EVENT-069` onProgress，测试中无 `onProgress` 回调）。
- **其余 84 条**：注册/注销路径通过，但原生事件投递没有任何断言；需要第二设备、多端登录、真机推送或 505 增值服务才能逐条验证（草稿 §2 的“特殊入口”场景）。
- 各域 API 用例只做了 server-positive / local 断言，不依赖这些回调，因此 89 条回调不构成“API 未测”的阻塞项，但也不能作为“事件链路已验证”的依据。

## 5. D17 已移除 key 索引（50 项）

引用草稿 §4：以下 50 个 key 已从 ohos 分支 Dart 代码移除，**不得出现在任何用例中**。`ChatMethodKeys` 现存常量 269 = 319 − 42 − 8，可作对账依据。

> 下表备注中的“见 §5 存疑 N”指草稿 §5，不是本文 §5。

### 5.1 方法 key（42）

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

### 5.2 事件 key（8）

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

> 连带移除的公开类型（同样不写用例）：`ChatThreadManager` 及其 `ChatClient.chatThreadManager`、`ChatThread` 模型、`ChatThreadEventHandler`、`ChatMessage.chatThread`。

## 6. 当前跑测汇总

### 6.1 套件汇总

| 入口套件 | 日志 | 用例数 | passed | failed | skipped | 状态 |
|---|---|---:|---:|---:|---:|---|
| logged_out（`logged_out_test.dart`） | `ohos-logged-out-pilot2.log` | 21 | 21 | 0 | 0 | 全绿 |
| logged_in_base（`logged_in_base_test.dart`） | `ohos-base-pilot4.log` | 143 | 130 | 12 | 1 | 12 条失败，其中 3 条已修待复跑 |
| logged_in_contact（`logged_in_contact_test.dart`） | `ohos-logged_in_contact_test-run2.log` | 23 | 23 | 0 | 0 | 全绿（3 条 deviation） |
| logged_in_user_info（`logged_in_user_info_test.dart`） | `ohos-user-info-run3.log` | 10 | 10 | 0 | 0 | 全绿（2 条 deviation） |
| logged_in_group（`logged_in_group_test.dart`） | `ohos-logged_in_group_test-run2.log` | 60 | 18 | 42 | 0 | 42 条失败，修复中 |
| logged_in_special（`logged_in_special_test.dart`） | `ohos-special-pilot5.log` | 35 | 35 | 0 | 0 | 全绿 |
| **合计** | — | **292** | **237** | **54** | **1** | — |

### 6.2 base 套件失败 / 跳过明细（12 failed + 1 skipped）

| Case | 现象（以台账 §2 为准） | 台账分类 | 当前状态 |
|---|---|---|---|
| FL-CONV-021 | `loadMessages(Up)` 返回升序，与 Dart 文档 newest-first 不符；源码已改为 unordered 断言 | SDK 行为偏差-待确认 | 待复跑 |
| FL-MSG-008 | code 110 `messageIds cannot be empty`；wrapper 读 `msgIds` 键名不一致 | SDK 问题（wrapper 键名） | 待复跑 |
| FL-MSG-013 | 同上（importMessages 路径） | SDK 问题（wrapper 键名） | 待复跑 |
| FL-MSG-024 | 历史消息回调/超时 | 待确认 | 已记录 |
| FL-MSG-025 | 历史消息空结果 | 待确认 | 已记录 |
| FL-MSG-048 | 服务端搜索只返回旧消息 | 待确认 | 已记录 |
| FL-MSG-050 | code 1 `Native async operation completed without an error result` | 待确认 | 已记录 |
| FL-MSG-052 | code 505 语音转写未开通 | 环境限制（应转 skip） | 已记录 |
| FL-MSG-053 | 同 052（voiceFileToText） | 环境限制（应转 skip） | 已记录 |
| FL-MSG-054 | code 100 搜索服务未注册 | 环境限制 | 已记录 |
| FL-MSG-059 | 空文本消息被服务端接受（期望 500） | 待确认（契约） | 已记录 |
| FL-MSG-060 | 不存在的 userId 被服务端接受（期望错误） | 待确认（契约） | 已记录 |
| FL-CONV-030 | by-time purge 只发 beforeTs，wrapper 要求 convId；用例 skip | UNVERIFIED | skipped |

### 6.3 group 套件 42 条失败

36 条同一根因：`support/rest.dart:131 addGroupMembers` 请求 `POST /easemob-demo/zuoyu/groups/{id}/users`，服务端返回 `HTTP 404: url is invalid`（REST 群成员接口应为 `/chatgroups/{id}/users`），夹具建群失败后整批用例级联失败。这是夹具问题，不是 SDK 缺陷。

- 夹具 404 级联（36）：`FL-GROUP-002`~`004`、`006`~`010`、`016`~`018`、`023`、`024`、`027`~`031`、`034`、`035`、`041`~`053`、`055`、`056`、`059`
- 语义类失败（6）：

| Case | 现象 |
|---|---|
| FL-GROUP-001 | `getGroupWithId` 对不存在的群返回空 `ChatGroup`，用例期望 `null` |
| FL-GROUP-005 | 成员列表期望含 peer，实际缺 peer（建群未带成员） |
| FL-GROUP-011 | `isMemberInAllowListFromServer` 期望 false，实际 true |
| FL-GROUP-014/015 | 成员列表缺 peer（同 005） |
| FL-GROUP-058 | 负向 addMembers 期望抛错，实际返回 `['zuoyu01']` |

group 套件通过 18 条：`FL-GROUP-012/013/019`~`022`、`025`、`026`、`032`、`033`、`036`~`040`、`054`、`057`、`060`。

### 6.4 deviation 记录（7 条）

这些用例最终 passed，但用例内用 `NOTE(deviation)` 记录了与文档预期不符的行为，不能被当作“能力已验证”：

| Case | 偏差现象 | 记录位置 |
|---|---|---|
| FL-CONTACT-015 | `getSelfIdsOnOtherPlatform` 对无多端账号返回 `code=101 User ID is invalid` | `ohos-logged_in_contact_test-run2.log:48`、`contact_cases.dart:287` |
| FL-CONTACT-021 | `addContact(自己)` 返回 101（草稿期望 205） | 同上日志 L64、`contact_cases.negative.dart:35` |
| FL-CONTACT-023 | 无 pending 邀请时 `acceptInvitation` 直接 resolve、不抛错（期望 205） | 同上日志 L67、`contact_cases.negative.dart:71` |
| FL-PUSH-013 | 空 notifier 被 `bindDeviceToken` 接受、未抛错 | `ohos-special-pilot5.log:50`、`push_cases.dart:137` |
| FL-USERINFO-003 | 未知 id 返回占位 `ChatUserInfo`，而非跳过该 key | `ohos-user-info-run3.log:20`、`user_info_cases.dart:154` |
| FL-USERINFO-010 | 超长资料字段被接受（未返回 901） | `user_info_cases.dart:302-306` |
| FL-MSG-003 | 对端发送的消息被 rekey 到 peer 会话（`conversationId` 变 peerId） | `message_cases.dart:490` |

另有 `FL-CONV-021` 同时属于 deviation 与 failure：SDK 返回顺序与 Dart 文档不符，源码已改 unordered 断言，见 §6.2。

## 7. 与草稿 / 台账的不一致

1. **`FL-AUTH-001` 名不副实**：草稿 §2 把它列为“现有用例”，但正式 `modules/` 中不存在；唯一实现是临时入口 `single_account_local_test.dart:46`（`FL-AUTH-001 logs in and exposes native client state`），该文件按口径不计入覆盖。**结论：认证 API 本身没有断言用例，登录只作为各套件夹具（`support/login.dart`）存在。**
2. **`FL-MSG-004/028/057` 落在 group 入口但没迁移**：`message_cases.dart:1896-1901` 只有三行 `// SKIPPED(group entry)` 注释，`group_cases.dart` 中没有对应 case，故计为未覆盖而不是 passed。
3. **`FL-AUTH-020` 口径不符**：草稿写“错误密码”，实际用例是 `FL-AUTH-020 rejects an invalid token login`（`client_cases.negative.dart:74`，`loginWithToken` + 伪造 token）。负向目标一致，描述需回写草稿。
4. **Client 的 13 条零调用**：`FL-CLIENT-011`（`customEventHandler`）与 `FL-CLIENT-020~031`（12 个 `update*Setting`）在 `modules/` 与 `support/` 中 grep 不到任何调用，草稿却按“logged_out local”登记了实现路径，需要补用例或显式标注“不测”。
5. **入口列与实际执行不一致 19 条**：`FL-APP-001`（草稿特殊 → 实际 logged_out）、`FL-CONTACT-015`（草稿特殊 → 实际 contact）、`FL-PUSH-011`（草稿 base → 实际 special），以及 16 条 `FL-EVENT-005~035` 注册用例（草稿按 handler 业务归属填 contact/group/特殊/userinfo，实际统一在 base 执行）。事件行属口径差异（草稿入口列指业务归属），前 3 条建议回写。
6. **用例总数 407 → 292**：差额 115 全部是“未落地的行”（89 回调 + 26 缺口），不是漏统计；草稿 §2 的 13 条既有用例里，`FL-CONV-001~006`、`FL-PRESENCE-001~005`、`FL-APP-001` 共 12 条确实存在，`FL-AUTH-001` 不存在（见第 1 条），因此草稿口径的“现有用例”实际是 12 条而非 13 条。
7. **失败台账已过期**：台账 §1/§5 仍写“未跑 group、user_info”，实际已有 group run2 与 user_info run3；台账也缺 contact run2（13 条转全绿）、special pilot5、`FL-USERINFO-003/010` deviation 的条目。§2 的 27 条里，contact 与 special push 的多条已被后续日志推翻或转为 deviation。
8. **日志文件名**：任务约定 `ohos-logged_in_user_info_test-run3.log`，`artifacts/` 下实际是 `ohos-user-info-run3.log`。
9. **group 域 404 未入台账**：台账记录了 contact 域 `addContacts` 405，但未记录 group 域 `addGroupMembers` 404（同一类夹具路径错误，影响 36 条用例）。修复后需回写台账。
10. **special 套件构成**：35 条 = ROOM 31 + PUSH 003/010/011/013；草稿把 `FL-PUSH-011` 归 base，`push_cases.dart` 头注释也未列出 011（实际由 `registerPushSpecialCases` 执行）。

## 8. 复跑后需更新的状态

- `failed·待复跑` 3 条（CONV-021、MSG-008、MSG-013）：重新 `flutter build hap` + 安装后跑 base，确认转 passed。
- `failed·已记录` 9 条：MSG-052/053 按计划改 `markTestSkipped`（505 → skip 不计 fail）；MSG-024/025/048/050/054/059/060 待契约确认或环境开通后重跑。
- `skipped·UNVERIFIED` 1 条（CONV-030）：需补 `convId` 参数或放宽 wrapper。
- group 42 条：修正 `support/rest.dart` 的群成员 REST 路径后整域重跑；其中 6 条语义类失败（001/005/011/014/015/058）需单独归因。
- 缺口 26 条：优先补 `FL-AUTH-001~008`（认证主路径）与 `FL-MSG-004/028/057`（group 入口迁移）。
- 89 条回调：短期维持“注册覆盖 + 间接断言”口径；需要多端/真机/增值服务的回调在文档里保留“未逐条覆盖”标记。

---

*生成方式：基于草稿表行 + `modules/*.dart` 的 `ciTestWidgets('FL-…')` 定义 + `artifacts/*.log` 的逐例结果交叉比对；事件回调与缺口行单独标注。*
