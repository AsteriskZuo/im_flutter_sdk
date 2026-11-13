# 环信 IM Flutter SDK

环信即时通讯 IM 的 Flutter 插件仓库，Federated Plugin 架构，支持 Android、iOS、HarmonyOS。当前鸿蒙线版本为 `1.15.0`，由 5 个包组成：`im_flutter_sdk`（主包）、`im_flutter_sdk_interface`（接口包）、`im_flutter_sdk_android` / `im_flutter_sdk_ios` / `im_flutter_sdk_ohos`（平台实现包）；使用方只需依赖主包，接口包与平台实现包会被自动引入。

## 文档导航

| 读者 | 文档 | 内容 |
|---|---|---|
| SDK 使用者 | [im_flutter_sdk/README.md](im_flutter_sdk/README.md) | 集成方式、平台配置、快速上手 |
| 开发 / 维护者 | [CONTRIBUTING.md](CONTRIBUTING.md) | 环境准备、验证方式、分支与发布流程 |
| AI Agent | [AGENTS.md](AGENTS.md) | 项目结构、硬性约定、编码规范 |

## 开发环境初始化

```bash
make setup        # config + deps + pods
make config       # 生成 example/config.local.json + 占位 example/lib/env.dart
# 编辑 example/config.local.json 填入 appKey / 凭证 / 测试账号
make env-gettoken # 换取 user token 并生成 example/lib/env.dart（gitignore，mode 600）
```

鸿蒙设备构建/测试使用 fvm 锁定的 `custom_ohos`（`fvm use custom_ohos --force`，项目级 `.fvmrc` 本机生效），
Android/iOS 与质量门禁仍使用官方 Flutter 3.47.0；详见 [CONTRIBUTING.md](CONTRIBUTING.md) 的「Flutter SDK 版本（fvm）」。
