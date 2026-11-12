import { UserInfoType } from '@easemob/chatsdk';

/**
 * Converts the wire-format user info type int to the chatsdk UserInfoType
 * string enum (mirrors android UserInfoManagerWrapper.getUserInfoTypeFromInt).
 *
 * Introduced by the chat_userInfo_manager port: the conversion is not an
 * identity cast (int -> string enum), so it does not belong in EnumTool,
 * which only holds numeric identity mappings shared with android EnumTools.
 *
 * Returns undefined for values android would reject with an
 * IllegalStateException; the caller reports a channel error instead of
 * throwing, because an uncaught throw has no handler on the ArkTS side.
 */
export default class UserInfoTypeHelper {
  static userInfoTypeFromInt(value: number): UserInfoType | undefined {
    switch (value) {
      case 0:
        return UserInfoType.NICKNAME;
      case 1:
        return UserInfoType.AVATAR_URL;
      case 2:
        return UserInfoType.EMAIL;
      case 3:
        return UserInfoType.PHONE;
      case 4:
        return UserInfoType.GENDER;
      case 5:
        return UserInfoType.SIGN;
      case 6:
        return UserInfoType.BIRTH;
      case 100:
        return UserInfoType.EXT;
      default:
        return undefined;
    }
  }
}
