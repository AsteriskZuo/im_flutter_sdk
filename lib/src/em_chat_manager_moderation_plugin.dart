import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk/src/internal/chat_method_keys.dart';
import 'package:im_flutter_sdk/src/internal/em_channel_manager.dart';

extension EMModerationPlugin on EMChatManager {
  ///
  /// Report violation message
  ///
  /// Param [messageId] The ID of the violation message.
  ///
  /// Param [tag] The report type (For example: involving pornography and terrorism).
  ///
  /// Param [reason] The reason for reporting.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  Future<void> reportMessage(
      {required String messageId,
      required String tag,
      required String reason}) async {
    Map req = {"msgId": messageId, "tag": tag, "reason": reason};
    Map result = await EMMethodChannel.ChatManager.invokeMethod(
        ChatMethodKeys.reportMessage, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }
}
