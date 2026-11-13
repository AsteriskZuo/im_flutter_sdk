import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

void main() {
  group('CombineMessageBody JSON contract', () {
    test('round trip preserves messageList and compatibleText', () {
      final body = CombineMessageBody(
        title: 'chat history',
        summary: 'a summary',
        compatibleText: 'upgrade to view',
        messageList: <String>['m1', 'm2'],
      );

      final decoded = CombineMessageBody.fromJson(map: body.toJson());

      expect(decoded.title, 'chat history');
      expect(decoded.summary, 'a summary');
      expect(decoded.toJson()['messageList'], <String>['m1', 'm2']);
      expect(decoded.toJson()['compatibleText'], 'upgrade to view');
    });

    test('fromJson keeps optional fields absent when they are not sent', () {
      final decoded = CombineMessageBody.fromJson(map: <String, dynamic>{});

      expect(decoded.toJson().containsKey('messageList'), isFalse);
      expect(decoded.toJson().containsKey('compatibleText'), isFalse);
    });

    test('message round trip keeps the combined body payload', () {
      final message = ChatMessage.createCombineSendMessage(
        targetId: 'receiver',
        title: 'chat history',
        summary: 'a summary',
        compatibleText: 'upgrade to view',
        msgIds: <String>['m1', 'm2'],
      );

      final decoded = ChatMessage.fromJson(message.toJson());

      expect(decoded.body, isA<CombineMessageBody>());
      final body = decoded.body as CombineMessageBody;
      expect(body.toJson()['messageList'], <String>['m1', 'm2']);
      expect(body.toJson()['compatibleText'], 'upgrade to view');
    });
  });

  group('ChatImageMessageBody JSON contract', () {
    test('round trip preserves the big image fields', () {
      final body = ChatImageMessageBody(
        localPath: '/tmp/photo.png',
        displayName: 'photo.png',
      )
        ..bigImageLocalPath = '/tmp/photo_big.png'
        ..bigImageRemotePath = 'https://example.com/photo_big.png'
        ..bigImageDownloadStatus = DownloadStatus.SUCCESS;

      final decoded = ChatImageMessageBody.fromJson(map: body.toJson());

      expect(decoded.bigImageLocalPath, '/tmp/photo_big.png');
      expect(decoded.bigImageRemotePath, 'https://example.com/photo_big.png');
      expect(decoded.bigImageDownloadStatus, DownloadStatus.SUCCESS);
    });

    test('toJson omits the big image status when it is unknown', () {
      final body = ChatImageMessageBody(localPath: '/tmp/photo.png');

      expect(body.toJson().containsKey('bigImageDownloadStatus'), isFalse);
    });
  });

  group('ChatMessage dispose', () {
    test('dispose leaves the plain data message usable', () {
      final message = ChatMessage.createTxtSendMessage(
        targetId: 'receiver',
        content: 'hello',
      );

      expect(message.dispose, returnsNormally);

      expect(message.to, 'receiver');
      expect((message.body as ChatTextMessageBody).content, 'hello');
    });
  });
}
