import 'dart:convert';

import 'package:im_flutter_sdk/im_flutter_sdk.dart';

/// ChatOptions keys accepted by the example environment and auto mode.
/// 4.25 has no `dataSyncType`; keys not listed here are ignored by the example.
const List<String> chatOptionKeys = <String>[
  'appKey',
  'autoLogin',
  'debugMode',
  'acceptInvitationAlways',
  'autoAcceptGroupInvitation',
  'requireAck',
  'requireDeliveryAck',
  'deleteMessagesAsExitGroup',
  'deleteMessagesAsExitChatRoom',
  'isChatRoomOwnerLeaveAllowed',
  'sortMessageByServerTime',
  'usingHttpsOnly',
  'serverTransfer',
  'isAutoDownloadThumbnail',
  'enableDNSConfig',
  'dnsUrl',
  'restServer',
  'imPort',
  'imServer',
  'webSocketServer',
  'webSocketPort',
  'chatAreaCode',
  'enableEmptyConversation',
  'deviceName',
  'osType',
  'useReplacedMessageContents',
  'enableTLS',
  'messagesReceiveCallbackIncludeSend',
  'regardImportMessagesAsRead',
  'workPathCopiable',
  'enableUserInfo',
  'enableAutoSyncContacts',
  'loginExtension',
  'autoLoadConversations',
  'enableChatroomConversation',
];

Map<String, dynamic> chatOptionsJsonFromEnvironment(
  Map<String, dynamic> environment,
) {
  return <String, dynamic>{
    for (final key in chatOptionKeys)
      if (environment.containsKey(key)) key: environment[key],
  };
}

/// Shared by init page and auto mode: JSON -> ChatOptions.
/// appKey is required; other keys fall back to SDK defaults; unknown keys are ignored.
ChatOptions emOptionsFromJson(Map<String, dynamic> j) {
  final appKey = j['appKey'] as String?;
  if (appKey == null || appKey.isEmpty) {
    throw ArgumentError('appKey 不能为空');
  }
  bool? b(String k) => j[k] as bool?;
  String? s(String k) => j[k] as String?;
  int? i(String k) => j[k] as int?;
  return ChatOptions.withAppKey(
    appKey,
    autoLogin: b('autoLogin') ?? true,
    debugMode: b('debugMode') ?? false,
    acceptInvitationAlways: b('acceptInvitationAlways') ?? false,
    autoAcceptGroupInvitation: b('autoAcceptGroupInvitation') ?? false,
    requireAck: b('requireAck') ?? true,
    requireDeliveryAck: b('requireDeliveryAck') ?? false,
    deleteMessagesAsExitGroup: b('deleteMessagesAsExitGroup') ?? true,
    deleteMessagesAsExitChatRoom: b('deleteMessagesAsExitChatRoom') ?? true,
    isChatRoomOwnerLeaveAllowed: b('isChatRoomOwnerLeaveAllowed') ?? true,
    sortMessageByServerTime: b('sortMessageByServerTime') ?? true,
    usingHttpsOnly: b('usingHttpsOnly') ?? true,
    serverTransfer: b('serverTransfer') ?? true,
    isAutoDownloadThumbnail: b('isAutoDownloadThumbnail') ?? true,
    enableDNSConfig: b('enableDNSConfig') ?? true,
    dnsUrl: s('dnsUrl'),
    restServer: s('restServer'),
    imPort: i('imPort'),
    imServer: s('imServer'),
    webSocketServer: s('webSocketServer'),
    webSocketPort: i('webSocketPort'),
    chatAreaCode: i('chatAreaCode'),
    enableEmptyConversation: b('enableEmptyConversation') ?? false,
    deviceName: s('deviceName'),
    osType: i('osType'),
    useReplacedMessageContents: b('useReplacedMessageContents') ?? false,
    enableTLS: b('enableTLS') ?? false,
    messagesReceiveCallbackIncludeSend:
        b('messagesReceiveCallbackIncludeSend') ?? false,
    regardImportMessagesAsRead: b('regardImportMessagesAsRead') ?? false,
    workPathCopiable: b('workPathCopiable') ?? false,
    enableUserInfo: b('enableUserInfo') ?? false,
    enableAutoSyncContacts: b('enableAutoSyncContacts') ?? false,
    loginExtension: s('loginExtension'),
    // 4.25.0
    autoLoadConversations: b('autoLoadConversations') ?? true,
    enableChatroomConversation: b('enableChatroomConversation') ?? false,
  );
}

/// Init page pre-fill template: contains only required fields.
const String emOptionsTemplate = '''{
  "appKey": "",
  "autoLogin": false,
  "debugMode": true
}''';

/// Init page pre-fill template built from the generated env.dart environment.
/// Falls back to the plain template when env.dart is still the empty
/// placeholder written by `make config` / tool/ci/ensure_example_env.sh.
String emOptionsTemplateFromEnvironment(Map<String, dynamic> environment) {
  final options = chatOptionsJsonFromEnvironment(environment);
  if ((options['appKey'] as String?)?.isNotEmpty != true) {
    return emOptionsTemplate;
  }
  return const JsonEncoder.withIndent('  ').convert(options);
}
