import { ChatError } from '@easemob/chatsdk';

/**
 * Serializes chatsdk ChatError to the wire format the Dart side expects:
 * { "code": number, "description": string } (see android HyphenateExceptionHelper
 * and Dart ChatError.fromJson).
 */
export default class ChatErrorHelper {
  static toJson(err: ChatError): Map<string, Object> {
    let ret = new Map<string, Object>();
    ret.set('code', err.errorCode);
    ret.set('description', err.description);
    return ret;
  }

  static infoToJson(code: number, desc: string): Map<string, Object> {
    let ret = new Map<string, Object>();
    ret.set('code', code);
    ret.set('description', desc);
    return ret;
  }
}
