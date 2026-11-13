## 1.15.0

### 中文

鸿蒙线首个正式版本，版本号跟随 HarmonyOS 原生 SDK（`@easemob/chatsdk` 1.15.0）。

**新增**

- 新增 HarmonyOS 平台实现包 `im_flutter_sdk_ohos`，基于 HarmonyOS 原生 `@easemob/chatsdk` 1.15.0；
- Dart API 与 Flutter 4.25.0 线对齐，覆盖 `ChatClient` 与 8 个 Manager：会话、消息、群组、聊天室、联系人、用户属性、推送、在线状态；
- 新增本地数据准备工具：`make config` / `make env-gettoken` 生成不随仓库提交的 `example/lib/env.dart`；
- 新增鸿蒙本地测试入口 `tool/ci/ohos_local.sh` 与 `tool/ci/smoke_local.harmony.sh`、`tool/ci/nightly_local.harmony.sh`（smoke 零凭证；nightly 只需长期凭证，token 由脚本现场换取）。

**修复**

- 修复 `ChatClient.init` 后事件监听器未及时注册，导致纯接收方收不到事件的问题；
- 修复 `loadMessagesWithIds`、`searchMsgFromDB` 参数键与 native 不一致的问题；
- 修复 `getGroupWithId` 对不存在的群返回空壳对象的问题（现返回 `null`）；
- 修复群组/聊天室成员列表缺少群主/房主的问题；
- 修复会话消息分页顺序、按时间删除会话消息参数的问题。

**说明**

- Android/iOS 实现包随版本号统一为 1.15.0，但本次不单独发版；其原生依赖与 4.25.x 保持一致。

**已知限制**

- 暂不支持 Thread 相关 API（按鸿蒙能力缺口清单移除）；
- 鸿蒙端隐藏悬浮附件面板（`file_picker` 无可用实现）；
- 聊天室消息回执、翻译、语音转文字、服务端消息搜索等依赖服务端增值服务开通；
- 多设备部分用例需双端联调。

### English

First official release of the HarmonyOS line. The version number follows the HarmonyOS native SDK (`@easemob/chatsdk` 1.15.0).

**Added**

- Added the HarmonyOS implementation package `im_flutter_sdk_ohos`, built on HarmonyOS native `@easemob/chatsdk` 1.15.0;
- Dart API aligned with the Flutter 4.25.0 line, covering `ChatClient` and 8 managers: conversation, message, group, chat room, contact, user info, push, and presence;
- Added local data preparation targets: `make config` / `make env-gettoken` generate `example/lib/env.dart`, which is not committed;
- Added HarmonyOS local test entries `tool/ci/ohos_local.sh`, `tool/ci/smoke_local.harmony.sh`, and `tool/ci/nightly_local.harmony.sh` (smoke needs no credentials; nightly needs only long-lived credentials, with tokens fetched by the script at run time).

**Fixed**

- Fixed event listeners not being registered in time after `ChatClient.init`, which caused receive-only clients to miss events;
- Fixed parameter keys of `loadMessagesWithIds` and `searchMsgFromDB` not matching the native side;
- Fixed `getGroupWithId` returning a shell object for a non-existent group (it now returns `null`);
- Fixed group/chat room member lists missing the group owner/room owner;
- Fixed conversation message pagination order and the parameter for deleting conversation messages by time.

**Notes**

- The Android/iOS implementation packages are versioned 1.15.0 for consistency but are not released separately this time; their native dependencies stay in line with 4.25.x.

**Known limitations**

- Thread-related APIs are not supported yet (removed per the HarmonyOS capability gap list);
- The floating attachment panel is hidden on HarmonyOS (`file_picker` has no available implementation);
- Chat room message receipts, translation, voice-to-text, and server-side message search depend on server-side value-added services being enabled;
- Some multi-device cases require joint debugging on two devices.

## 1.5.4

- 修复鸿蒙分页参数顺序（`pageNum` / `pageSize`）；
- 更新构建配置与示例调试依赖。

## 1.5.3

- 首个支持鸿蒙平台的联合插件版本，Dart API 对齐 Android/iOS 4.12；
- 暂不支持聊天室、Thread、多设备管理。
