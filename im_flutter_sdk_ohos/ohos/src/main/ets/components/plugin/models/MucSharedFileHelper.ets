import { SharedFile } from '@easemob/chatsdk';

/**
 * Serializes chatsdk SharedFile (mirrors android MucSharedFileHelper; keys
 * match the Dart ChatGroupSharedFile.fromJson).
 */
export default class MucSharedFileHelper {
  static toJson(file: SharedFile): Map<string, Object> {
    let data = new Map<string, Object>();
    data.set('fileId', file.fileId());
    data.set('name', file.fileName());
    data.set('owner', file.fileOwner());
    data.set('createTime', file.fileUpdateTime());
    data.set('fileSize', file.fileSize());
    return data;
  }

  static listToJson(files: Array<SharedFile>): Array<Map<string, Object>> {
    let list = new Array<Map<string, Object>>();
    for (let file of files) {
      list.push(MucSharedFileHelper.toJson(file));
    }
    return list;
  }
}
