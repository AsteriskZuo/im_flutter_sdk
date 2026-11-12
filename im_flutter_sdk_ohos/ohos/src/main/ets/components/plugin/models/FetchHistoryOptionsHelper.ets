import { ContentType, FetchMessageOption } from '@easemob/chatsdk';
import { Any } from '@ohos/flutter_ohos';
import SafetyMapTool from '../SafetyMapTool';
import ChannelValue from './ChannelValue';
import EnumTool from './EnumTool';

/**
 * Builds chatsdk FetchMessageOption from the Dart FetchMessageOptions.toJson()
 * payload (mirrors android FetchHistoryOptionsHelper.fromJson; reads
 * "direction", "needSave", "startTs", "endTs", "from", "senders",
 * "msgTypes").
 */
export default class FetchHistoryOptionsHelper {
  static fromJson(args: Any): FetchMessageOption {
    let options = new FetchMessageOption();
    options.setDirection(EnumTool.searchDirectionFromInt(SafetyMapTool.getNumber(args, 'direction') ?? 0));
    options.setIsSave(SafetyMapTool.getBoolean(args, 'needSave') ?? false);
    options.setStartTime(SafetyMapTool.getNumber(args, 'startTs') ?? -1);
    options.setEndTime(SafetyMapTool.getNumber(args, 'endTs') ?? -1);

    let senders = SafetyMapTool.getStringArray(args, 'senders');
    if (senders !== undefined && senders.length > 0) {
      options.setFrom(senders);
    } else {
      let from = SafetyMapTool.getString(args, 'from');
      if (from !== undefined) {
        options.setFrom(from);
      }
    }

    let typeValues = ChannelValue.numberArray(args, 'msgTypes');
    if (typeValues !== undefined && typeValues.length > 0) {
      let types = new Array<ContentType>();
      for (let value of typeValues) {
        types.push(EnumTool.messageBodyTypeFromInt(value));
      }
      options.setMsgTypes(types);
    }

    return options;
  }
}
