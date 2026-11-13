# 环信 IM Flutter SDK

环信即时通讯 IM 的 Flutter 插件仓库，Federated Plugin 架构，支持 Android、iOS、鸿蒙（鸿蒙为独立仓库插件）。

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

详见 [CONTRIBUTING.md](CONTRIBUTING.md)。
