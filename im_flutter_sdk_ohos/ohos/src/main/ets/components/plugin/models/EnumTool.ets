import {
  ChatStreamStatus,
  ChatType,
  ChatroomMessagePriority,
  ContentType,
  ConversationType,
  DownloadStatus,
  GroupPermissionType,
  MessageDirection,
  MessageStatus,
  PinOperation,
  PushRemindType,
  ReactionOperation,
  SearchDirection,
  SilentModeParamType,
} from '@easemob/chatsdk';

/**
 * Enum/int conversions for the channel wire format (mirrors android EnumTools).
 *
 * The Dart side deserializes enums by index, so the ints produced here must
 * match the Dart enum indexes exactly. chatsdk enums already use the same
 * numeric values as the android SDK for every enum listed here, so most
 * conversions are identity casts; they stay explicit to keep the android
 * mapping points visible and to guard against future SDK value changes.
 *
 * Non-identity mappings (same as android):
 *   - permission types: none=-1, member=0, admin=1, owner=2
 *     (Dart adds +1 on its side: None=0, Member=1, Admin=2, Owner=3)
 */
export default class EnumTool {
  static messageStatusFromInt(iStatus: number): MessageStatus {
    switch (iStatus) {
      case 0:
        return MessageStatus.CREATE;
      case 1:
        return MessageStatus.PROGRESSING;
      case 2:
        return MessageStatus.SUCCESS;
      case 3:
        return MessageStatus.FAIL;
      default:
        return MessageStatus.FAIL;
    }
  }

  static messageStatusToInt(status: MessageStatus): number {
    return status as number;
  }

  static messageDirectFromInt(iType: number): MessageDirection {
    return iType as MessageDirection;
  }

  static messageDirectToInt(direct: MessageDirection): number {
    return direct as number;
  }

  static chatTypeFromInt(iType: number): ChatType {
    return iType as ChatType;
  }

  static chatTypeToInt(type: ChatType): number {
    return type as number;
  }

  static messageBodyTypeFromInt(iType: number): ContentType {
    return iType as ContentType;
  }

  static messageBodyTypeToInt(type: ContentType): number {
    return type as number;
  }

  static downloadStatusFromInt(iStatus: number): DownloadStatus {
    return iStatus as DownloadStatus;
  }

  static downloadStatusToInt(status: DownloadStatus): number {
    return status as number;
  }

  static conversationTypeFromInt(iType: number): ConversationType {
    return iType as ConversationType;
  }

  static conversationTypeToInt(type: ConversationType): number {
    return type as number;
  }

  static chatRoomMessagePriorityFromInt(iType: number): ChatroomMessagePriority {
    return iType as ChatroomMessagePriority;
  }

  static groupPermissionTypeToInt(type: GroupPermissionType): number {
    // chatsdk GroupPermissionType: NONE=-1, MEMBER=0, ADMIN=1, OWNER=2,
    // identical to the android wire values.
    return type as number;
  }

  static searchDirectionFromInt(iDirection: number): SearchDirection {
    return iDirection as SearchDirection;
  }

  static searchDirectionToInt(direction: SearchDirection): number {
    return direction as number;
  }

  static silentModeParamTypeFromInt(iType: number): SilentModeParamType {
    return iType as SilentModeParamType;
  }

  static remindTypeFromInt(iType: number): PushRemindType {
    return iType as PushRemindType;
  }

  static remindTypeToInt(type: PushRemindType): number {
    return type as number;
  }

  static reactionOperationToInt(operation: ReactionOperation): number {
    return operation as number;
  }

  static pinOperationToInt(operation: PinOperation): number {
    return operation as number;
  }

  static streamStatusToInt(status: ChatStreamStatus): number {
    // chatsdk ChatStreamStatus: START=0, START_AND_COMPLETE=1, PROGRESS=2,
    // COMPLETE=3, ERROR=4, identical to android streamStatusToInt.
    return status as number;
  }
}
