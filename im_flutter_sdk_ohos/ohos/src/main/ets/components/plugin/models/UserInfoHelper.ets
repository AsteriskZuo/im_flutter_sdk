import { Gender, UserInfo } from '@easemob/chatsdk';
import { Any } from '@ohos/flutter_ohos';
import SafetyMapTool from '../SafetyMapTool';

/**
 * Converts chatsdk UserInfo to/from the wire format the Dart side expects
 * (mirrors android UserInfoHelper; keys match the Dart ChatUserInfo).
 *
 * Note: the Dart ChatUserInfo.userId is non-nullable, so toJson always
 * carries "userId" (empty string when chatsdk leaves it undefined). Gender
 * values (unknown=0, male=1, female=2) are identical on Dart, android and
 * chatsdk.
 */
export default class UserInfoHelper {
  static fromJson(args: Any): UserInfo {
    let userInfo = new UserInfo();
    userInfo.nickname = SafetyMapTool.getString(args, 'nickName');
    userInfo.avatarUrl = SafetyMapTool.getString(args, 'avatarUrl');
    userInfo.email = SafetyMapTool.getString(args, 'mail');
    userInfo.phone = SafetyMapTool.getString(args, 'phone');
    let gender = SafetyMapTool.getNumber(args, 'gender');
    if (gender !== undefined) {
      userInfo.gender = gender as Gender;
    }
    userInfo.signature = SafetyMapTool.getString(args, 'sign');
    userInfo.birth = SafetyMapTool.getString(args, 'birth');
    userInfo.ext = SafetyMapTool.getString(args, 'ext');
    return userInfo;
  }

  static toJson(userInfo: UserInfo): Map<string, Object> {
    let data = new Map<string, Object>();
    data.set('userId', userInfo.userId ?? '');
    if (userInfo.nickname !== undefined) {
      data.set('nickName', userInfo.nickname);
    }
    if (userInfo.avatarUrl !== undefined) {
      data.set('avatarUrl', userInfo.avatarUrl);
    }
    if (userInfo.email !== undefined) {
      data.set('mail', userInfo.email);
    }
    if (userInfo.phone !== undefined) {
      data.set('phone', userInfo.phone);
    }
    if (userInfo.gender !== undefined) {
      data.set('gender', userInfo.gender as number);
    }
    if (userInfo.signature !== undefined) {
      data.set('sign', userInfo.signature);
    }
    if (userInfo.birth !== undefined) {
      data.set('birth', userInfo.birth);
    }
    if (userInfo.ext !== undefined) {
      data.set('ext', userInfo.ext);
    }
    return data;
  }
}
