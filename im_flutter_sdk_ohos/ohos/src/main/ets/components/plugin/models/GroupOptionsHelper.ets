import { GroupOptions, GroupStyle } from '@easemob/chatsdk';
import { Any } from '@ohos/flutter_ohos';
import SafetyMapTool from '../SafetyMapTool';

/**
 * Builds chatsdk GroupOptions from the Dart ChatGroupOptions.toJson() payload
 * (mirrors android GroupOptionsHelper.fromJson; reads "maxCount",
 * "inviteNeedConfirm", "ext", "style").
 *
 * GroupStyle values 0..3 are identical on Dart, android and chatsdk.
 */
export default class GroupOptionsHelper {
  static fromJson(args: Any): GroupOptions {
    let options = new GroupOptions();
    options.maxUsers = SafetyMapTool.getNumber(args, 'maxCount') ?? 200;
    options.inviteNeedConfirm = SafetyMapTool.getBoolean(args, 'inviteNeedConfirm') ?? false;
    options.extField = SafetyMapTool.getString(args, 'ext');
    options.style = (SafetyMapTool.getNumber(args, 'style') ?? 0) as GroupStyle;
    return options;
  }
}
