import 'dart:collection';

import 'package:flutter/services.dart';

import 'em_test.dart';

class EMChannel {
  static const _channelPrefix = EMTest.TEST_TYPE == 1 ? 'com.chat.im' : 'com.chat.im.ext';
  static HashMap<String, MethodChannel> _list =
      new HashMap<String, MethodChannel>();

MethodChannel getChannel(String name) {
    if (EMTest.TEST_TYPE == 1) {
      return _list['$_channelPrefix/$name']!;
    } else if (EMTest.TEST_TYPE == 2) {
      return _list['$_channelPrefix.$name']!;
    }
    throw "not find MethodChannel";
  }

  static EMChannel? _instance;

  static EMChannel get getInstance => _instance = _instance ?? EMChannel._();

  EMChannel._() {
    if (EMTest.TEST_TYPE == 1) {
      _list['$_channelPrefix/em_client'] =
          MethodChannel('$_channelPrefix/em_client', JSONMethodCodec());
      _list['$_channelPrefix/chat_manager'] =
          MethodChannel('$_channelPrefix/chat_manager', JSONMethodCodec());
      _list['$_channelPrefix/chat_room_manager'] = MethodChannel(
          '$_channelPrefix/chat_room_manager', JSONMethodCodec());
      _list['$_channelPrefix/chat_contact_manager'] = MethodChannel(
          '$_channelPrefix/chat_contact_manager', JSONMethodCodec());
      _list['$_channelPrefix/chat_group_manager'] =
          MethodChannel('$_channelPrefix/chat_group_manager', JSONMethodCodec());
      _list['$_channelPrefix/chat_push_manager'] =
          MethodChannel('$_channelPrefix/chat_push_manager', JSONMethodCodec());
      _list['$_channelPrefix/chat_userInfo_manager'] = MethodChannel(
          '$_channelPrefix/chat_userInfo_manager', JSONMethodCodec());
    } else if (EMTest.TEST_TYPE == 2) {
      _list['$_channelPrefix.dart_to_native'] =
          MethodChannel('$_channelPrefix.dart_to_native', JSONMethodCodec());
      _list['$_channelPrefix.native_to_dart'] =
          MethodChannel('$_channelPrefix.native_to_dart', JSONMethodCodec());
    }
  }
}
