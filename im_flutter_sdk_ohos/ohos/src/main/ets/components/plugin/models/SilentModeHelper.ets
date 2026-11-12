import {
  PushRemindType,
  SilentIntervalTypeParam,
  SilentModeParam,
  SilentModeResult,
  SilentModeTime,
  SilentModeTimeParam,
} from '@easemob/chatsdk';
import { Any } from '@ohos/flutter_ohos';
import SafetyMapTool from '../SafetyMapTool';
import ChannelValue from './ChannelValue';
import EnumTool from './EnumTool';

/**
 * Converts chatsdk silent-mode models to/from the wire format the Dart side
 * expects (mirrors android SilentModeParamHelper / SilentModeTimeHelper /
 * SilentModeResultHelper; keys match the Dart chat_silent_mode.dart models).
 */
export class SilentModeTimeHelper {
  /**
   * Builds a chatsdk SilentModeTimeParam ({hours, minutes}) from the Dart
   * payload ({hour, minute}).
   */
  static paramFromJson(args: Any): SilentModeTimeParam {
    let param: SilentModeTimeParam = {
      hours: SafetyMapTool.getNumber(args, 'hour') ?? 0,
      minutes: SafetyMapTool.getNumber(args, 'minute') ?? 0,
    };
    return param;
  }

  static toJson(modeTime: SilentModeTime): Map<string, Object> {
    let data = new Map<string, Object>();
    data.set('hour', modeTime.getHour());
    data.set('minute', modeTime.getMinute());
    return data;
  }
}

export class SilentModeResultHelper {
  static toJson(modeResult: SilentModeResult): Map<string, Object> {
    let data = new Map<string, Object>();
    data.set('expireTs', modeResult.getExpireTimestamp());
    // convId / conversationType / remindType are non-nullable on the Dart
    // side, so they are always written.
    data.set('convId', modeResult.getConversationId());
    data.set('conversationType', EnumTool.conversationTypeToInt(modeResult.getConversationType()));
    data.set('remindType', EnumTool.remindTypeToInt(modeResult.getRemindType()));
    let startTime = modeResult.getSilentModeStartTime();
    if (startTime !== undefined) {
      data.set('startTime', SilentModeTimeHelper.toJson(startTime));
    }
    let endTime = modeResult.getSilentModeEndTime();
    if (endTime !== undefined) {
      data.set('endTime', SilentModeTimeHelper.toJson(endTime));
    }
    return data;
  }
}

export class SilentModeParamHelper {
  /**
   * Builds a chatsdk SilentModeParam from the Dart payload.
   *
   * chatsdk types SilentModeParam as PushRemindType | SilentIntervalTypeParam,
   * so paramType REMIND_TYPE(0) and SILENT_MODE_INTERVAL(2) are supported.
   * SILENT_MODE_DURATION(1) has no chatsdk counterpart and returns undefined;
   * the calling wrapper must treat undefined as an unsupported-parameter
   * error instead of calling the SDK.
   */
  static fromJson(args: Any): SilentModeParam | undefined {
    let paramType = SafetyMapTool.getNumber(args, 'paramType');
    if (paramType === undefined) {
      return undefined;
    }
    switch (paramType) {
      case 0: {
        let remindType: PushRemindType =
          EnumTool.remindTypeFromInt(SafetyMapTool.getNumber(args, 'remindType') ?? 0);
        return remindType as SilentModeParam;
      }
      case 2: {
        let startTime: Object | null = ChannelValue.read(args, 'startTime');
        let endTime: Object | null = ChannelValue.read(args, 'endTime');
        if (startTime === null || endTime === null) {
          return undefined;
        }
        let param: SilentIntervalTypeParam = {
          startTime: SilentModeTimeHelper.paramFromJson(startTime),
          endTime: SilentModeTimeHelper.paramFromJson(endTime),
        };
        return param as SilentModeParam;
      }
      default:
        return undefined;
    }
  }
}
