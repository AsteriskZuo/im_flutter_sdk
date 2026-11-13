# 贡献者指南

本文档面向 im_flutter_sdk 的开发与维护者，说明仓库结构、环境准备、验证方式与发布流程。SDK 使用者请阅读 [im_flutter_sdk/README.md](im_flutter_sdk/README.md)。

## 仓库结构

Federated Plugin 架构，各包的 pubspec 使用发布用的版本依赖，本地开发通过被 Git 忽略的 override 切换为 `path:` 依赖：

| 包 | 职责 |
|---|---|
| `im_flutter_sdk/` | 主包：公开 API、Model、Manager，含 `example/` 测试应用 |
| `im_flutter_sdk_interface/` | 平台接口层：MethodChannel 抽象 |
| `im_flutter_sdk_android/` | Android 平台实现 |
| `im_flutter_sdk_ios/` | iOS 平台实现 |

调用链：`Dart API → MethodChannel (interface) → Native Wrapper → HyphenateChat SDK`。改动 interface 会波及所有上层包。

## 环境准备

需要 Flutter（>= 3.3.0）、Xcode + CocoaPods（iOS）、Android Studio（Android）。

项目根目录提供了 Makefile，一键初始化：

```bash
make setup   # 依次执行 config + deps + pods
```

| target | 作用 |
|--------|------|
| `make config` | 创建本地环境文件：`im_flutter_sdk/example/config.local.json` + 占位 `example/lib/env.dart`（已存在则跳过），并保留旧的 `templates/config.example.json` → `scripts/config.json` 拷贝 |
| `make env-gettoken` | 读取 `example/config.local.json`，为每个账号换取 user token，生成被 gitignore 的 `example/lib/env.dart`（mode 600，默认 24h 过期） |
| `make local-deps` | 为主包、Android、iOS 和 example 生成被 Git 忽略的本地依赖 override，保留已有文件 |
| `make deps` | 先执行 `make local-deps`，再在 example 目录执行 `flutter pub get` |
| `make pods` | 在 `example/ios` 执行 `pod install`（仅 Podfile/podspec 变更时执行，mtime 检测） |
| `make clean` | 清理 build 产物和 Pods |
| `make help` | 查看所有命令 |

新增 API 不改初始化方式时，日常验证只需 `make config` → 编辑 `config.local.json` → `make env-gettoken`；已有 `example/lib/env.dart`（例如本地已生成）时 `make config` 不会覆盖它。

> **重要**：修改 `im_flutter_sdk_ios.podspec` 中的 native 依赖版本（如 HyphenateChat）后，必须执行 `make pods`。`flutter run` 不会追踪 podspec 变更，会跳过 pod install，导致 iOS 使用旧版本 native SDK 引发编译错误。

### 本地依赖与发布

运行 `make local-deps`（或 `bash tool/use_local_packages.sh`），会在主包、Android、iOS 和 example 的 pubspec 旁生成 `pubspec_overrides.yaml`。interface 没有其他子包依赖，无需 override。仓库 `.gitignore` 已在所有层级忽略这些文件，生成脚本纳入版本管理，已有 override 文件不会被覆盖。

override 只对当前解析的根包生效，不会从依赖包继承。因此，example 虽然已经通过 `path: ../` 依赖主包，仍需要自己的文件覆盖 interface、Android 和 iOS。`make deps`、CI 质量检查、双端构建和设备测试入口都会在依赖解析前生成本地文件。

发布配置与已发布的 `4.25.0` 保持一致：主包精确依赖 Android/iOS `4.25.0`，三个依赖 interface 的包使用 `^4.15.0+1`；该范围包含 interface `4.25.0`。本地 override 则统一使用当前工作树中的四个包。

发布验证应在没有 override 的检出目录执行，或先将四份 override 移出工作树，检查后再恢复。在各个可发布包内运行 `dart pub publish --dry-run`，期间不要调用本地开发初始化入口。有 override 时解析成功，不能证明正式版本依赖可解析。新版本按 interface → Android/iOS → 主包的顺序发布；已发布的版本不能重复上传。

## 测试数据准备

example 应用把测试环境集中在一个本地文件里（与 5.1.0 一致，均不入库）：

1. `make config` — 生成 `im_flutter_sdk/example/config.local.json`（含 restApi、appKey、clientId、clientSecret、accounts、groups、rooms、chatOptions 占位）和占位 `example/lib/env.dart`；
2. 编辑 `config.local.json` 填真实 appKey 与账号（4.25 没有 `dataSyncType`，`chatOptions` 使用 `debugMode` / `enableUserInfo` / `enableAutoSyncContacts` / `autoLoadConversations` / `enableChatroomConversation` 等开关）；
3. `make env-gettoken` — 用 clientId/clientSecret 换 app token，再为每个账号换 user token，生成 `example/lib/env.dart`（`chmod 600`，token 默认 24h 过期，过期后重新执行）。

`example/lib/env.dart` 是 `const Map<String, Object?> environment`，包含 appKey、每个账号的 id+token、群组/聊天室引用；人工模式页面会用它预填初始化参数和登录账号（第一个 account 的 id+token），脚本模式以其为 base config，`API_CONFIG` 可逐键覆盖。

旧机制 `im_flutter_sdk/example/scripts/config.json`（AutoMode 脚本用，同样 gitignore）仍兼容：`make config` 在缺少时继续从 `templates/config.example.json` 创建。

全新检出与 CI 不需要真实凭证：`tool/ci/ensure_example_env.sh` 在 `lib/env.dart` 缺失时复制空占位模板，`tool/use_local_packages.sh` 与 `tool/ci/ohos_local.sh` 都会调用它。

## 运行与验证

example 是一个可视化 API 测试应用，支持两种模式：

- **人工模式**：初始化 → 登录 → 搜索 API → 填 JSON 参数调用，结果和监听器回调在悬浮日志中查看。
- **脚本模式**（适合 AI / 自动化）：通过 `--dart-define=API_SCRIPT=...` 传入 JSON 脚本顺序执行一批 API，日志以 `[APITEST]` 前缀单行 JSON 输出到 stdout 和日志文件。

详细用法见 [im_flutter_sdk/example/README.md](im_flutter_sdk/example/README.md)；覆盖 4.22 新增 API 的完整脚本示例见 `example/scripts/script_422_apis.json`。

## 编码规范

命名约定、双语注释规范、新增 API 的标准链路（Dart → 常量 → Android → iOS）与提交前自检清单，统一维护在 [AGENTS.md](AGENTS.md) 中，人类开发者同样适用，不再重复列举。

## 命名与兼容约定

- 4.22.0 起公开 API 统一为 `Chat` 前缀命名（与海外版 agora_chat_sdk 对齐）；
- 旧 `EM*` 名字通过 `im_flutter_sdk/lib/em_compat.dart` 中的 `@Deprecated` typedef 保留兼容，新代码不要再使用旧名；`em_compat.dart` 由脚本统一生成，不要手工添加条目；
- 少量无法 typedef 的名字（`ChatLog`、`ChatTools`、`ChatGroupPermissionTypeExtension` 等）没有旧名兼容，引用时注意。

## 生成 API 文档

主包公开 API 使用中英双语注释（`~english` / `~chinese` / `~end` 标记块，格式见 AGENTS.md「文档注释规范」）。修改注释或新增 API 后，应重新生成 API 文档检查渲染效果：

```bash
cd im_flutter_sdk
scripts/gen-apidoc.sh        # 中文版 → output/apidoc-cn/
scripts/gen-apidoc.sh en     # 英文版 → output/apidoc-en/
```

- 脚本在临时副本中剥离另一语言块与标记行后运行 `dart doc`，不修改源码；`im_flutter_sdk/output/` 已 gitignore，生成物不进仓库；
- 侧边导航由 JS 动态加载，必须通过 HTTP 访问，直接双击 `index.html`（file:// 协议）侧边栏会是空白。本地预览：

  ```bash
  cd im_flutter_sdk/output/apidoc-cn && python3 -m http.server 8765
  # 浏览器打开 http://localhost:8765/
  ```

- 部署时将 `output/apidoc-cn/im_flutter_sdk/` 目录内容作为站点根（类页面需挂在根路径下）；
- `dart doc` 会对注释中 `[xxx]` 形式的文本报 unresolved doc reference 警告，属既有写法问题，不影响生成。

## 版本号与 CHANGELOG

- 四个子包的版本号保持一致，禁止只改其中一个。
- CHANGELOG 使用中文，格式为 `## 版本号` 标题 + `- 新增…` / `- 修复…` / `- 优化…` 条目；条目中的公开 API 名字一律使用新命名（`Chat*`），不要出现 `EM*` 旧名。
- 新增 API 时：主包 CHANGELOG 记录新 API 条目；interface / android / ios 的 CHANGELOG 按各自实际改动记录。

## 分支与发布流程

- **4.x 起每个发布版本对应一个同名分支**（如 `4.22.0`），不使用 tag；3.x 遗留 tag 仅属历史。
- 默认分支为 `flutter2_stable`；`alpha`、`dev` 等为特性或历史分支，不在其上做版本开发。
- 版本开发流程：
  1. 确认当前工作区干净后，从 `flutter2_stable` 新建与目标版本同名的分支；
  2. 在该分支上完成开发与验证（双端编译运行 + example 脚本验证）；
  3. 验证测试通过后，合并回 `flutter2_stable`。
- 版本升级（对齐 native SDK 新版本的公开 API）有专门的工作流与验收报告模板，见团队工作区的 `platform-sdk-porting-v2` skill 及历次升级报告。
