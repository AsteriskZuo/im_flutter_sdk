import { ChatAudioFormat, ChatAudioParams } from '@easemob/chatsdk';
import { Any } from '@ohos/flutter_ohos';
import SafetyMapTool from '../SafetyMapTool';

/**
 * Builds chatsdk ChatAudioParams from the Dart ChatVoiceParam.toJson()
 * payload. "format" travels as the format name string ("pcm" / "mp3" /
 * "amr"), identical to the chatsdk ChatAudioFormat values.
 */
export default class ChatAudioParamsHelper {
  static fromJson(args: Any): ChatAudioParams {
    let params = new ChatAudioParams();
    let format = SafetyMapTool.getString(args, 'format');
    if (format !== undefined) {
      params.setFormat(format as ChatAudioFormat);
    }
    let sampleRate = SafetyMapTool.getNumber(args, 'sampleRate');
    if (sampleRate !== undefined) {
      params.setSampleRate(sampleRate);
    }
    let bitsPerSample = SafetyMapTool.getNumber(args, 'bitsPerSample');
    if (bitsPerSample !== undefined) {
      params.setBitsPerSample(bitsPerSample);
    }
    let channels = SafetyMapTool.getNumber(args, 'channels');
    if (channels !== undefined) {
      params.setChannels(channels);
    }
    return params;
  }
}
