import {
  ChatMessageBody,
  CmdMessageBody,
  CombineMessageBody,
  CombineMessageParams,
  ContentType,
  CustomMessageBody,
  FileMessageBody,
  ImageMessageBody,
  LocationMessageBody,
  TextMessageBody,
  VideoMessageBody,
  VoiceMessageBody,
} from '@easemob/chatsdk';
import { Any } from '@ohos/flutter_ohos';
import SafetyMapTool from '../SafetyMapTool';
import ChannelValue from './ChannelValue';
import EnumTool from './EnumTool';

/**
 * Converts chatsdk message bodies to/from the wire format the Dart side
 * expects (mirrors android MessageBodyHelper; field keys must stay identical,
 * the Dart ChatMessageBody subclasses deserialize by these keys).
 *
 * Known gaps against android (chatsdk limitations, not hard-coded on purpose):
 *   - CmdMessageBody has no deliverOnlineOnly on HarmonyOS.
 *   - ImageMessageBody has no thumbnailSecret on HarmonyOS.
 */
export default class MessageBodyHelper {
  /**
   * Builds a chatsdk body from the Dart body payload, dispatching on "type".
   * Returns undefined for an unknown type.
   */
  static fromJson(args: Any): ChatMessageBody | undefined {
    let typeValue = SafetyMapTool.getNumber(args, 'type');
    if (typeValue === undefined) {
      return undefined;
    }
    let type = EnumTool.messageBodyTypeFromInt(typeValue);
    switch (type) {
      case ContentType.TXT:
        return MessageBodyHelper.textBodyFromJson(args);
      case ContentType.IMAGE:
        return MessageBodyHelper.imageBodyFromJson(args);
      case ContentType.LOCATION:
        return MessageBodyHelper.localBodyFromJson(args);
      case ContentType.VIDEO:
        return MessageBodyHelper.videoBodyFromJson(args);
      case ContentType.VOICE:
        return MessageBodyHelper.voiceBodyFromJson(args);
      case ContentType.FILE:
        return MessageBodyHelper.fileBodyFromJson(args);
      case ContentType.CMD:
        return MessageBodyHelper.cmdBodyFromJson(args);
      case ContentType.CUSTOM:
        return MessageBodyHelper.customBodyFromJson(args);
      case ContentType.COMBINE:
        return MessageBodyHelper.combineBodyFromJson(args);
      default:
        return undefined;
    }
  }

  /**
   * Serializes any chatsdk body, dispatching on its content type.
   * Returns undefined for an unknown type.
   */
  static toJson(body: ChatMessageBody): Map<string, Object> | undefined {
    switch (body.type()) {
      case ContentType.TXT:
        return MessageBodyHelper.textBodyToJson(body as TextMessageBody);
      case ContentType.IMAGE:
        return MessageBodyHelper.imageBodyToJson(body as ImageMessageBody);
      case ContentType.LOCATION:
        return MessageBodyHelper.localBodyToJson(body as LocationMessageBody);
      case ContentType.VIDEO:
        return MessageBodyHelper.videoBodyToJson(body as VideoMessageBody);
      case ContentType.VOICE:
        return MessageBodyHelper.voiceBodyToJson(body as VoiceMessageBody);
      case ContentType.FILE:
        return MessageBodyHelper.fileBodyToJson(body as FileMessageBody);
      case ContentType.CMD:
        return MessageBodyHelper.cmdBodyToJson(body as CmdMessageBody);
      case ContentType.CUSTOM:
        return MessageBodyHelper.customBodyToJson(body as CustomMessageBody);
      case ContentType.COMBINE:
        return MessageBodyHelper.combineBodyToJson(body as CombineMessageBody);
      default:
        return undefined;
    }
  }

  /**
   * Shared message-modification fields (mirrors android getParentMap):
   * operatorId / operatorTime / operatorCount, only present when meaningful.
   */
  private static parentMap(body: ChatMessageBody): Map<string, Object> {
    let data = new Map<string, Object>();
    let operatorId = body.operatorId();
    if (operatorId.length > 0) {
      data.set('operatorId', operatorId);
    }
    if (body.operationTime() !== 0) {
      data.set('operatorTime', body.operationTime());
    }
    if (body.operationCount() !== 0) {
      data.set('operatorCount', body.operationCount());
    }
    return data;
  }

  static textBodyFromJson(args: Any): TextMessageBody {
    let content = SafetyMapTool.getString(args, 'content') ?? '';
    let body = new TextMessageBody(content);
    let targetLanguages = SafetyMapTool.getStringArray(args, 'targetLanguages');
    if (targetLanguages !== undefined) {
      body.setTargetLanguages(targetLanguages);
    }
    return body;
  }

  static textBodyToJson(body: TextMessageBody): Map<string, Object> {
    let data = MessageBodyHelper.parentMap(body);
    data.set('content', body.getContent());
    data.set('type', EnumTool.messageBodyTypeToInt(ContentType.TXT));
    let targetLanguages = body.getTargetLanguages();
    if (targetLanguages.length > 0) {
      data.set('targetLanguages', targetLanguages);
    }
    let translations = body.getTranslations();
    if (translations.length > 0) {
      let map = new Map<string, string>();
      for (let info of translations) {
        map.set(info.languageCode, info.translationText);
      }
      data.set('translations', map);
    }
    return data;
  }

  static localBodyFromJson(args: Any): LocationMessageBody {
    let latitude = SafetyMapTool.getNumber(args, 'latitude') ?? 0;
    let longitude = SafetyMapTool.getNumber(args, 'longitude') ?? 0;
    let address = SafetyMapTool.getString(args, 'address');
    let buildingName = SafetyMapTool.getString(args, 'buildingName');
    return new LocationMessageBody(latitude, longitude, address, buildingName);
  }

  static localBodyToJson(body: LocationMessageBody): Map<string, Object> {
    let data = MessageBodyHelper.parentMap(body);
    data.set('latitude', body.getLatitude());
    data.set('longitude', body.getLongitude());
    data.set('buildingName', body.getBuildingName());
    data.set('address', body.getAddress());
    data.set('type', EnumTool.messageBodyTypeToInt(ContentType.LOCATION));
    return data;
  }

  static cmdBodyFromJson(args: Any): CmdMessageBody {
    let action = SafetyMapTool.getString(args, 'action') ?? '';
    // chatsdk CmdMessageBody has no deliverOnlineOnly; the Dart-side flag is
    // dropped here (see class doc).
    return new CmdMessageBody(action);
  }

  static cmdBodyToJson(body: CmdMessageBody): Map<string, Object> {
    let data = MessageBodyHelper.parentMap(body);
    data.set('action', body.action());
    data.set('type', EnumTool.messageBodyTypeToInt(ContentType.CMD));
    return data;
  }

  static customBodyFromJson(args: Any): CustomMessageBody {
    let event = SafetyMapTool.getString(args, 'event') ?? '';
    let body = new CustomMessageBody(event);
    let params = MessageBodyHelper.stringMap(args, 'params');
    if (params !== undefined) {
      body.setParams(params);
    }
    return body;
  }

  static customBodyToJson(body: CustomMessageBody): Map<string, Object> {
    let data = MessageBodyHelper.parentMap(body);
    data.set('event', body.event());
    data.set('params', body.getParams());
    data.set('type', EnumTool.messageBodyTypeToInt(ContentType.CUSTOM));
    return data;
  }

  static fileBodyFromJson(args: Any): FileMessageBody {
    let localPath = SafetyMapTool.getString(args, 'localPath') ?? '';
    let body = new FileMessageBody(localPath);
    MessageBodyHelper.applyFileFields(body, args);
    return body;
  }

  static fileBodyToJson(body: FileMessageBody): Map<string, Object> {
    let data = MessageBodyHelper.parentMap(body);
    data.set('localPath', body.getLocalPath());
    data.set('fileSize', body.getFileLength());
    data.set('displayName', body.getFileName());
    data.set('remotePath', body.getRemoteUrl());
    data.set('secret', body.getSecretKey());
    data.set('fileStatus', EnumTool.downloadStatusToInt(body.getDownloadStatus()));
    data.set('type', EnumTool.messageBodyTypeToInt(ContentType.FILE));
    return data;
  }

  static imageBodyFromJson(args: Any): ImageMessageBody {
    let localPath = SafetyMapTool.getString(args, 'localPath') ?? '';
    let body = new ImageMessageBody(localPath);
    MessageBodyHelper.applyString(args, 'thumbnailLocalPath', (v) => body.setThumbnailLocalPath(v));
    MessageBodyHelper.applyString(args, 'thumbnailRemotePath', (v) => body.setThumbnailRemoteUrl(v));
    MessageBodyHelper.applyNumber(args, 'thumbnailStatus',
      (v) => body.setThumbnailDownloadStatus(EnumTool.downloadStatusFromInt(v)));
    let width = SafetyMapTool.getNumber(args, 'width');
    let height = SafetyMapTool.getNumber(args, 'height');
    if (width !== undefined && height !== undefined) {
      body.setSize(width, height);
    }
    MessageBodyHelper.applyBoolean(args, 'sendOriginalImage', (v) => body.setSendOriginalImage(v));
    MessageBodyHelper.applyBoolean(args, 'isGif', (v) => body.setGif(v));
    MessageBodyHelper.applyFileFields(body, args);
    return body;
  }

  static imageBodyToJson(body: ImageMessageBody): Map<string, Object> {
    let data = MessageBodyHelper.parentMap(body);
    data.set('localPath', body.getLocalPath());
    data.set('displayName', body.getFileName());
    data.set('remotePath', body.getRemoteUrl());
    data.set('secret', body.getSecretKey());
    data.set('fileStatus', EnumTool.downloadStatusToInt(body.getDownloadStatus()));
    data.set('thumbnailLocalPath', body.getThumbnailLocalPath());
    data.set('thumbnailRemotePath', body.getThumbnailRemoteUrl());
    data.set('thumbnailStatus', EnumTool.downloadStatusToInt(body.getThumbnailDownloadStatus()));
    data.set('height', body.getHeight());
    data.set('width', body.getWidth());
    data.set('sendOriginalImage', body.isOriginalImage());
    data.set('bigImageLocalPath', body.getBigImageLocalPath());
    data.set('bigImageRemotePath', body.getBigImageRemoteUrl());
    data.set('bigImageDownloadStatus', EnumTool.downloadStatusToInt(body.getBigImageDownloadStatus()));
    data.set('fileSize', body.getFileLength());
    data.set('isGif', body.isGif());
    data.set('type', EnumTool.messageBodyTypeToInt(ContentType.IMAGE));
    return data;
  }

  static videoBodyFromJson(args: Any): VideoMessageBody {
    let localPath = SafetyMapTool.getString(args, 'localPath') ?? '';
    let duration = SafetyMapTool.getNumber(args, 'duration') ?? 0;
    let thumbnailLocalPath = SafetyMapTool.getString(args, 'thumbnailLocalPath');
    let body = new VideoMessageBody(localPath, duration, thumbnailLocalPath);
    MessageBodyHelper.applyString(args, 'thumbnailRemotePath', (v) => body.setThumbnailRemoteUrl(v));
    MessageBodyHelper.applyString(args, 'thumbnailSecret', (v) => body.setThumbnailSecret(v));
    MessageBodyHelper.applyNumber(args, 'thumbnailStatus',
      (v) => body.setThumbnailDownloadStatus(EnumTool.downloadStatusFromInt(v)));
    let width = SafetyMapTool.getNumber(args, 'width');
    let height = SafetyMapTool.getNumber(args, 'height');
    if (width !== undefined && height !== undefined) {
      body.setThumbnailSize(width, height);
    }
    MessageBodyHelper.applyFileFields(body, args);
    return body;
  }

  static videoBodyToJson(body: VideoMessageBody): Map<string, Object> {
    let data = MessageBodyHelper.parentMap(body);
    data.set('localPath', body.getLocalPath());
    data.set('thumbnailLocalPath', body.getThumbnailLocalPath());
    data.set('duration', body.getDuration());
    data.set('thumbnailRemotePath', body.getThumbnailRemoteUrl());
    data.set('thumbnailSecret', body.getThumbnailSecret());
    data.set('thumbnailStatus', EnumTool.downloadStatusToInt(body.getThumbnailDownloadStatus()));
    data.set('displayName', body.getFileName());
    data.set('height', body.getThumbnailHeight());
    data.set('width', body.getThumbnailWidth());
    data.set('remotePath', body.getRemoteUrl());
    data.set('fileStatus', EnumTool.downloadStatusToInt(body.getDownloadStatus()));
    data.set('secret', body.getSecretKey());
    data.set('fileSize', body.getFileLength());
    data.set('type', EnumTool.messageBodyTypeToInt(ContentType.VIDEO));
    return data;
  }

  static voiceBodyFromJson(args: Any): VoiceMessageBody {
    let localPath = SafetyMapTool.getString(args, 'localPath') ?? '';
    let duration = SafetyMapTool.getNumber(args, 'duration') ?? 0;
    let body = new VoiceMessageBody(localPath, duration);
    MessageBodyHelper.applyFileFields(body, args);
    return body;
  }

  static voiceBodyToJson(body: VoiceMessageBody): Map<string, Object> {
    let data = MessageBodyHelper.parentMap(body);
    data.set('localPath', body.getLocalPath());
    data.set('duration', body.getDuration());
    data.set('displayName', body.getFileName());
    data.set('remotePath', body.getRemoteUrl());
    data.set('fileStatus', EnumTool.downloadStatusToInt(body.getDownloadStatus()));
    data.set('secret', body.getSecretKey());
    data.set('fileSize', body.getFileLength());
    data.set('text', body.getText());
    data.set('type', EnumTool.messageBodyTypeToInt(ContentType.VOICE));
    return data;
  }

  static combineBodyFromJson(args: Any): CombineMessageBody {
    let params = new CombineMessageParams();
    params.messageIds = SafetyMapTool.getStringArray(args, 'messageList') ?? [];
    params.title = SafetyMapTool.getString(args, 'title');
    params.summary = SafetyMapTool.getString(args, 'summary');
    params.compatibleText = SafetyMapTool.getString(args, 'compatibleText');
    let body = new CombineMessageBody(params);
    MessageBodyHelper.applyString(args, 'localPath', (v) => body.setLocalPath(v));
    MessageBodyHelper.applyString(args, 'remotePath', (v) => body.setRemoteUrl(v));
    MessageBodyHelper.applyString(args, 'secret', (v) => body.setSecretKey(v));
    MessageBodyHelper.applyNumber(args, 'fileStatus',
      (v) => body.setDownloadStatus(EnumTool.downloadStatusFromInt(v)));
    return body;
  }

  static combineBodyToJson(body: CombineMessageBody): Map<string, Object> {
    let data = MessageBodyHelper.parentMap(body);
    data.set('title', body.getTitle());
    data.set('summary', body.getSummary());
    data.set('compatibleText', body.getCompatibleText());
    data.set('localPath', body.getLocalPath());
    data.set('remotePath', body.getRemoteUrl());
    data.set('secret', body.getSecretKey());
    data.set('fileStatus', EnumTool.downloadStatusToInt(body.getDownloadStatus()));
    data.set('type', EnumTool.messageBodyTypeToInt(ContentType.COMBINE));
    return data;
  }

  /**
   * File-attachment fields shared by file/image/video/voice bodies
   * (mirrors the android fromJson setters).
   */
  private static applyFileFields(body: FileMessageBody, args: Any): void {
    MessageBodyHelper.applyString(args, 'displayName', (v) => body.setFileName(v));
    MessageBodyHelper.applyString(args, 'remotePath', (v) => body.setRemoteUrl(v));
    MessageBodyHelper.applyString(args, 'secret', (v) => body.setSecretKey(v));
    MessageBodyHelper.applyNumber(args, 'fileSize', (v) => body.setFileLength(v));
    MessageBodyHelper.applyNumber(args, 'fileStatus',
      (v) => body.setDownloadStatus(EnumTool.downloadStatusFromInt(v)));
  }

  private static applyString(args: Any, key: string, apply: (value: string) => void): void {
    let value = SafetyMapTool.getString(args, key);
    if (value !== undefined) {
      apply(value);
    }
  }

  private static applyNumber(args: Any, key: string, apply: (value: number) => void): void {
    let value = SafetyMapTool.getNumber(args, key);
    if (value !== undefined) {
      apply(value);
    }
  }

  private static applyBoolean(args: Any, key: string, apply: (value: boolean) => void): void {
    let value = SafetyMapTool.getBoolean(args, key);
    if (value !== undefined) {
      apply(value);
    }
  }

  /**
   * Reads a string-valued map parameter; tolerates both Map and plain-object
   * shapes produced by the channel codec.
   */
  private static stringMap(args: Any, key: string): Map<string, string> | undefined {
    let value = ChannelValue.read(args, key);
    let ret = new Map<string, string>();
    if (value instanceof Map) {
      let map = value as Map<string, Object>;
      map.forEach((v: Object, k: string) => {
        if (typeof v === 'string') {
          ret.set(k, v as string);
        }
      });
      return ret;
    }
    if (ChannelValue.isPlainObject(value)) {
      let record = value as Record<string, Object>;
      for (let k of Object.keys(record)) {
        let v = record[k];
        if (typeof v === 'string') {
          ret.set(k, v as string);
        }
      }
      return ret;
    }
    return undefined;
  }
}
