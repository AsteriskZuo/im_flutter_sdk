import '../tools/em_extension.dart';

import 'em_chat_enums.dart';
import 'em_message_body.dart';

///
/// The text message class.
///
class EMTextMessageBody extends EMMessageBody {
  ///
  /// Creates a text message.
  ///
  /// Param [content] The text content.
  ///
  EMTextMessageBody({required this.content}) : super(type: MessageType.TXT);

  /// @nodoc
  EMTextMessageBody.fromJson({required Map map})
      : super.fromJson(map: map, type: MessageType.TXT) {
    this.content = map.getStringValue("content", defaultValue: "")!;
  }

  @override

  ///@nodoc
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['content'] = this.content;
    return data;
  }

  /// The text content.
  late final String content;
}
