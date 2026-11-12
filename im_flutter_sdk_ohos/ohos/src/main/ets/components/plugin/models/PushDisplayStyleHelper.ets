import { PushDisplayStyle } from '@easemob/chatsdk';

/**
 * Push display style conversions for the chat_push_manager channel wire
 * format (mirrors android PushManagerWrapper.updateImPushStyle:
 * pushStyle 0 -> SimpleBanner, otherwise MessageSummary).
 *
 * Lives in its own helper instead of EnumTool because PushManagerWrapper is
 * the only consumer and the porting task scope is limited to the push
 * channel files.
 */
export default class PushDisplayStyleHelper {
  static displayStyleFromInt(iStyle: number): PushDisplayStyle {
    return iStyle === 0 ? PushDisplayStyle.SimpleBanner : PushDisplayStyle.MessageSummary;
  }
}
