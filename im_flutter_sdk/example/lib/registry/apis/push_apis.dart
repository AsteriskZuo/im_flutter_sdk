import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../api_entry.dart';

/// PushManager related entries.
final pushApis = <ApiEntry>[
  ApiEntry(
    name: 'ChatPushManager.bindDeviceToken',
    group: 'PushManager',
    description: '绑定设备推送 token。iOS 上 notifierName 为 APNs 证书名，非空时优先级高于 '
        'ChatOptions.apnsCertName；Android 上 notifierName 为厂商推送凭据（FCM Sender ID、'
        '华为/荣耀 App ID、小米/魅族 App ID、OPPO App Key、vivo appId#appKey），不能为空，'
        '否则原生返回参数非法错误。',
    paramsTemplate: '''{
  "notifierName": "",
  "deviceToken": ""
}''',
    invoke: (p) async {
      return ChatClient.getInstance.pushManager.bindDeviceToken(
        notifierName: p['notifierName'] as String,
        deviceToken: p['deviceToken'] as String,
      );
    },
  ),
];
