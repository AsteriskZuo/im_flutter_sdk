#import "ExtSdkToJson.h"

#import <HyphenateChat/EMClient.h>
#import <HyphenateChat/EMOptions+PrivateDeploy.h>

@implementation EMChatroom (Json)
- (NSDictionary *)toJsonObject {
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    ret[@"roomId"] = self.chatroomId;
    ret[@"name"] = self.subject;
    ret[@"desc"] = self.description;
    ret[@"owner"] = self.owner;
    ret[@"maxUsers"] = @(self.maxOccupantsCount);
    ret[@"memberCount"] = @(self.occupantsCount);
    ret[@"adminList"] = self.adminList;
    ret[@"memberList"] = self.memberList;
    ret[@"blockList"] = self.blacklist;
    ret[@"muteList"] = self.muteList;
    ret[@"isAllMemberMuted"] = @(self.isMuteAllMembers);
    ret[@"announcement"] = self.announcement;
    ret[@"permissionType"] = @([self premissionTypeToInt:self.permissionType]);

    return ret;
}

- (int)premissionTypeToInt:(EMChatroomPermissionType)type {
    int ret = -1;
    switch (type) {
    case EMChatroomPermissionTypeNone: {
        ret = -1;
    } break;
    case EMChatroomPermissionTypeMember: {
        ret = 0;
    } break;
    case EMChatroomPermissionTypeAdmin: {
        ret = 1;
    } break;
    case EMChatroomPermissionTypeOwner: {
        ret = 2;
    } break;
    default:
        break;
    }
    return ret;
}
@end

@implementation EMConversation (Json)
- (NSDictionary *)toJsonObject {
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    ret[@"con_id"] = self.conversationId;
    ret[@"type"] = @([self.class typeToInt:self.type]);
    ret[@"unreadCount"] = @(self.unreadMessagesCount);
    ret[@"ext"] = self.ext;
    ret[@"latestMessage"] = [self.latestMessage toJsonObject];
    ret[@"lastReceivedMessage"] = [self.lastReceivedMessage toJsonObject];
    return ret;
}

+ (int)typeToInt:(EMConversationType)aType {
    int ret = 0;
    switch (aType) {
    case EMConversationTypeChat:
        ret = 0;
        break;
    case EMConversationTypeGroupChat:
        ret = 1;
        break;
    case EMConversationTypeChatRoom:
        ret = 2;
        break;
    default:
        break;
    }
    return ret;
}

+ (EMConversationType)typeFromInt:(int)aType {
    EMConversationType ret = EMConversationTypeChat;
    switch (aType) {
    case 0:
        ret = EMConversationTypeChat;
        break;
    case 1:
        ret = EMConversationTypeGroupChat;
        break;
    case 2:
        ret = EMConversationTypeChatRoom;
        break;
    default:
        break;
    }
    return ret;
}

@end

@implementation EMCursorResult (Json)
- (NSDictionary *)toJsonObject {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    NSMutableArray *dataList = [NSMutableArray array];

    for (id obj in self.list) {
        if ([obj respondsToSelector:@selector(toJsonObject)]) {
            [dataList addObject:[obj toJsonObject]];
        } else if ([obj isKindOfClass:[NSString class]]) {
            [dataList addObject:obj];
        }
    }

    data[@"list"] = dataList;
    data[@"cursor"] = self.cursor;

    return data;
}
@end

@implementation EMDeviceConfig (Json)
- (NSDictionary *)toJsonObject {
    return @{
        @"resource" : self.resource,
        @"deviceUUID" : self.deviceUUID,
        @"deviceName" : self.deviceName,
    };
}
@end

@implementation EMError (Json)
- (NSDictionary *)toJsonObject {
    return @{
        @"code" : @(self.code),
        @"description" : self.errorDescription,
    };
}
@end

@implementation EMGroup (Json)

- (NSDictionary *)toJsonObject {
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    ret[@"groupId"] = self.groupId;
    ret[@"name"] = self.groupName;
    ret[@"desc"] = self.description;
    ret[@"owner"] = self.owner;
    ret[@"announcement"] = self.announcement;
    ret[@"memberCount"] = @(self.occupantsCount);
    ret[@"memberList"] = self.memberList;
    ret[@"adminList"] = self.adminList;
    ret[@"blockList"] = self.blacklist;
    ret[@"muteList"] = self.muteList;
    ret[@"sharedFileList"] = self.sharedFileList;
    ret[@"noticeEnable"] = @(self.isPushNotificationEnabled);
    ret[@"messageBlocked"] = @(self.isBlocked);
    ret[@"isAllMemberMuted"] = @(self.isMuteAllMembers);
    ret[@"options"] = [self.setting toJsonObject];
    ret[@"permissionType"] =
        @([EMGroup premissionTypeToInt:self.permissionType]);

    return ret;
}

+ (int)premissionTypeToInt:(EMGroupPermissionType)type {
    int ret = -1;
    switch (type) {
    case EMGroupPermissionTypeNone: {
        ret = -1;
    } break;
    case EMGroupPermissionTypeMember: {
        ret = 0;
    } break;
    case EMGroupPermissionTypeAdmin: {
        ret = 1;
    } break;
    case EMGroupPermissionTypeOwner: {
        ret = 2;
    } break;
    default:
        break;
    }
    return ret;
}

+ (EMGroupPermissionType)premissionTypeFromInt:(int)type {
    EMGroupPermissionType ret = EMGroupPermissionTypeMember;
    switch (type) {
    case -1: {
        ret = EMGroupPermissionTypeNone;
    } break;
    case 0: {
        ret = EMGroupPermissionTypeMember;
    } break;
    case 1: {
        ret = EMGroupPermissionTypeAdmin;
    } break;
    case 2: {
        ret = EMGroupPermissionTypeOwner;
    } break;
    default:
        break;
    }
    return ret;
}

@end

@implementation EMGroupOptions (Json)
- (NSDictionary *)toJsonObject {
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    ret[@"maxCount"] = @(self.maxUsersCount);
    ret[@"ext"] = self.ext;
    ret[@"style"] = @([EMGroupOptions styleToInt:self.style]);
    ret[@"inviteNeedConfirm"] = @(self.IsInviteNeedConfirm);
    return ret;
}

+ (EMGroupOptions *)formJson:(NSDictionary *)dict {
    EMGroupOptions *options = [[EMGroupOptions alloc] init];
    options.maxUsersCount = [dict[@"maxCount"] intValue];
    options.ext = dict[@"ext"];
    options.IsInviteNeedConfirm = [dict[@"inviteNeedConfirm"] boolValue];
    options.style = [EMGroupOptions styleFromInt:[dict[@"style"] intValue]];
    return options;
}

+ (EMGroupStyle)styleFromInt:(int)style {
    EMGroupStyle ret = EMGroupStylePrivateOnlyOwnerInvite;
    switch (style) {
    case 0: {
        ret = EMGroupStylePrivateOnlyOwnerInvite;
    } break;
    case 1: {
        ret = EMGroupStylePrivateMemberCanInvite;
    } break;
    case 2: {
        ret = EMGroupStylePublicJoinNeedApproval;
    } break;
    case 3: {
        ret = EMGroupStylePublicOpenJoin;
    } break;
    default:
        break;
    }

    return ret;
}

+ (int)styleToInt:(EMGroupStyle)style {
    int ret = 0;
    switch (style) {
    case EMGroupStylePrivateOnlyOwnerInvite: {
        ret = 0;
    } break;
    case EMGroupStylePrivateMemberCanInvite: {
        ret = 1;
    } break;
    case EMGroupStylePublicJoinNeedApproval: {
        ret = 2;
    } break;
    case EMGroupStylePublicOpenJoin: {
        ret = 3;
    } break;
    default:
        break;
    }

    return ret;
}

@end

@implementation EMGroupSharedFile (Json)
- (NSDictionary *)toJsonObject {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"fileId"] = self.fileId;
    data[@"name"] = self.fileName;
    data[@"owner"] = self.fileOwner;
    data[@"createTime"] = @(self.createTime);
    data[@"fileSize"] = @(self.fileSize);
    return data;
}

@end

@implementation EMGroupMessageAck (Json)
- (NSDictionary *)toJsonObject {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"msg_id"] = self.messageId;
    data[@"from"] = self.from;
    data[@"content"] = self.content;
    data[@"count"] = @(self.readCount);
    data[@"timestamp"] = @(self.timestamp);
    return data;
}
@end

@implementation EMMessage (Json)

+ (EMMessage *)fromJsonObject:(NSDictionary *)aJson {
    EMMessageBody *body = [EMMessageBody fromJsonObject:aJson[@"body"]];
    if (!body) {
        return nil;
    }

    NSString *from = aJson[@"from"];
    if (from.length == 0) {
        from = EMClient.sharedClient.currentUsername;
    }

    NSString *to = aJson[@"to"];
    NSString *conversationId = aJson[@"conversationId"];

    EMMessage *msg = [[EMMessage alloc] initWithConversationID:conversationId
                                                          from:from
                                                            to:to
                                                          body:body
                                                           ext:nil];
    if (aJson[@"msgId"]) {
        msg.messageId = aJson[@"msgId"];
    }

    msg.direction = ({
        [aJson[@"direction"] isEqualToString:@"send"]
            ? EMMessageDirectionSend
            : EMMessageDirectionReceive;
    });

    msg.chatType = [msg chatTypeFromInt:[aJson[@"chatType"] intValue]];
    msg.status = [msg statusFromInt:[aJson[@"status"] intValue]];
    msg.localTime = [aJson[@"localTime"] longLongValue];
    msg.timestamp = [aJson[@"serverTime"] longLongValue];
    msg.isReadAcked = [aJson[@"hasReadAck"] boolValue];
    msg.isDeliverAcked = [aJson[@"hasDeliverAck"] boolValue];
    msg.isRead = [aJson[@"hasRead"] boolValue];
    msg.isNeedGroupAck = [aJson[@"needGroupAck"] boolValue];
    // read only
    // msg.groupAckCount = [aJson[@"groupAckCount"] intValue]
    msg.ext = aJson[@"attributes"];
    return msg;
}

- (NSDictionary *)toJsonObject {
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    ret[@"from"] = self.from;
    ret[@"msgId"] = self.messageId;
    ret[@"to"] = self.to;
    ret[@"conversationId"] = self.conversationId;
    ret[@"hasRead"] = @(self.isRead);
    ret[@"hasDeliverAck"] = @(self.isDeliverAcked);
    ret[@"hasReadAck"] = @(self.isReadAcked);
    ret[@"needGroupAck"] = @(self.isNeedGroupAck);
    ret[@"serverTime"] = @(self.timestamp);
    ret[@"groupAckCount"] = @(self.groupAckCount);
    ret[@"attributes"] = self.ext ?: @{};
    ret[@"localTime"] = @(self.localTime);
    ret[@"status"] = @([self statusToInt:self.status]);
    ret[@"chatType"] = @([self chatTypeToInt:self.chatType]);
    ret[@"direction"] =
        self.direction == EMMessageDirectionSend ? @"send" : @"rec";
    ret[@"body"] = [self.body toJsonObject];

    return ret;
}

- (EMMessageStatus)statusFromInt:(int)aStatus {
    EMMessageStatus status = EMMessageStatusPending;
    switch (aStatus) {
    case 0: {
        status = EMMessageStatusPending;
    } break;
    case 1: {
        status = EMMessageStatusDelivering;
    } break;
    case 2: {
        status = EMMessageStatusSucceed;
    } break;
    case 3: {
        status = EMMessageStatusFailed;
    } break;
    }

    return status;
}

- (int)statusToInt:(EMMessageStatus)aStatus {
    int status = 0;
    switch (aStatus) {
    case EMMessageStatusPending: {
        status = 0;
    } break;
    case EMMessageStatusDelivering: {
        status = 1;
    } break;
    case EMMessageStatusSucceed: {
        status = 2;
    } break;
    case EMMessageStatusFailed: {
        status = 3;
    } break;
    }

    return status;
}

- (EMChatType)chatTypeFromInt:(int)aType {
    EMChatType type = EMChatTypeChat;
    switch (aType) {
    case 0:
        type = EMChatTypeChat;
        break;
    case 1:
        type = EMChatTypeGroupChat;
        break;
    case 2:
        type = EMChatTypeChatRoom;
        break;
    }

    return type;
}

- (int)chatTypeToInt:(EMChatType)aType {
    int type;
    switch (aType) {
    case EMChatTypeChat:
        type = 0;
        break;
    case EMChatTypeGroupChat:
        type = 1;
        break;
    case EMChatTypeChatRoom:
        type = 2;
        break;
    }
    return type;
}

@end

@implementation EMMessageBody (Json)

+ (EMMessageBody *)fromJsonObject:(NSDictionary *)bodyJson {
    EMMessageBody *ret = nil;
    NSString *type = bodyJson[@"type"];
    if ([type isEqualToString:@"txt"]) {
        ret = [EMTextMessageBody fromJsonObject:bodyJson];
    } else if ([type isEqualToString:@"img"]) {
        ret = [EMImageMessageBody fromJsonObject:bodyJson];
    } else if ([type isEqualToString:@"loc"]) {
        ret = [EMLocationMessageBody fromJsonObject:bodyJson];
    } else if ([type isEqualToString:@"video"]) {
        ret = [EMVideoMessageBody fromJsonObject:bodyJson];
    } else if ([type isEqualToString:@"voice"]) {
        ret = [EMVoiceMessageBody fromJsonObject:bodyJson];
    } else if ([type isEqualToString:@"file"]) {
        ret = [EMFileMessageBody fromJsonObject:bodyJson];
    } else if ([type isEqualToString:@"cmd"]) {
        ret = [EMCmdMessageBody fromJsonObject:bodyJson];
    } else if ([type isEqualToString:@"custom"]) {
        ret = [EMCustomMessageBody fromJsonObject:bodyJson];
    }
    return ret;
}

- (NSDictionary *)toJsonObject {
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    NSString *type = @"";
    switch (self.type) {
    case EMMessageBodyTypeText:
        type = @"txt";
        break;
    case EMMessageBodyTypeLocation:
        type = @"loc";
        break;
    case EMMessageBodyTypeCmd:
        type = @"cmd";
        break;
    case EMMessageBodyTypeCustom:
        type = @"custom";
        break;
    case EMMessageBodyTypeFile:
        type = @"file";
        break;
    case EMMessageBodyTypeImage:
        type = @"img";
        break;
    case EMMessageBodyTypeVideo:
        type = @"video";
        break;
    case EMMessageBodyTypeVoice:
        type = @"voice";
        break;
    default:
        break;
    }
    ret[@"type"] = type;

    return ret;
}

+ (EMMessageBodyType)typeFromString:(NSString *)aStrType {

    EMMessageBodyType ret = EMMessageBodyTypeText;

    if ([aStrType isEqualToString:@"txt"]) {
        ret = EMMessageBodyTypeText;
    } else if ([aStrType isEqualToString:@"loc"]) {
        ret = EMMessageBodyTypeLocation;
    } else if ([aStrType isEqualToString:@"cmd"]) {
        ret = EMMessageBodyTypeCmd;
    } else if ([aStrType isEqualToString:@"custom"]) {
        ret = EMMessageBodyTypeCustom;
    } else if ([aStrType isEqualToString:@"file"]) {
        ret = EMMessageBodyTypeFile;
    } else if ([aStrType isEqualToString:@"img"]) {
        ret = EMMessageBodyTypeImage;
    } else if ([aStrType isEqualToString:@"video"]) {
        ret = EMMessageBodyTypeVideo;
    } else if ([aStrType isEqualToString:@"voice"]) {
        ret = EMMessageBodyTypeVoice;
    }
    return ret;
}

@end

#pragma mark - txt

@interface EMTextMessageBody (Json)
+ (EMMessageBody *)fromJsonObject:(NSDictionary *)aJson;
- (NSDictionary *)toJsonObject;
@end

@implementation EMTextMessageBody (Json)

+ (EMMessageBody *)fromJsonObject:(NSDictionary *)aJson {
    return [[EMTextMessageBody alloc] initWithText:aJson[@"content"]];
}

- (NSDictionary *)toJsonObject {
    NSMutableDictionary *ret = [[super toJsonObject] mutableCopy];
    ret[@"content"] = self.text;
    return ret;
}

@end

#pragma mark - loc

@interface EMLocationMessageBody (Json)
+ (EMMessageBody *)fromJsonObject:(NSDictionary *)aJson;
- (NSDictionary *)toJsonObject;
@end

@implementation EMLocationMessageBody (Json)

+ (EMMessageBody *)fromJsonObject:(NSDictionary *)aJson {
    double latitude = [aJson[@"latitude"] doubleValue];
    double longitude = [aJson[@"longitude"] doubleValue];
    NSString *address = aJson[@"address"];
    EMLocationMessageBody *ret =
        [[EMLocationMessageBody alloc] initWithLatitude:latitude
                                              longitude:longitude
                                                address:address];
    return ret;
}

- (NSDictionary *)toJsonObject {
    NSMutableDictionary *ret = [[super toJsonObject] mutableCopy];
    ret[@"address"] = self.address;
    ret[@"latitude"] = @(self.latitude);
    ret[@"longitude"] = @(self.longitude);
    return ret;
}

@end

#pragma mark - cmd

@interface EMCmdMessageBody (Json)
+ (EMCmdMessageBody *)fromJsonObject:(NSDictionary *)aJson;
- (NSDictionary *)toJsonObject;
@end

@implementation EMCmdMessageBody (Json)

+ (EMCmdMessageBody *)fromJsonObject:(NSDictionary *)aJson {
    EMCmdMessageBody *ret =
        [[EMCmdMessageBody alloc] initWithAction:aJson[@"action"]];
    ret.isDeliverOnlineOnly = [aJson[@"deliverOnlineOnly"] boolValue];
    return ret;
}

- (NSDictionary *)toJsonObject {
    NSMutableDictionary *ret = [[super toJsonObject] mutableCopy];
    ret[@"action"] = self.action;
    ret[@"deliverOnlineOnly"] = @(self.isDeliverOnlineOnly);
    return ret;
}

@end

#pragma mark - custom

@interface EMCustomMessageBody (Json)
+ (EMCustomMessageBody *)fromJsonObject:(NSDictionary *)aJson;
- (NSDictionary *)toJsonObject;
@end

@implementation EMCustomMessageBody (Json)

+ (EMCustomMessageBody *)fromJsonObject:(NSDictionary *)aJson {
    NSDictionary *dic = aJson[@"params"];
    if ([dic isKindOfClass:[NSNull class]]) {
        dic = nil;
    }

    EMCustomMessageBody *ret =
        [[EMCustomMessageBody alloc] initWithEvent:aJson[@"event"] ext:dic];
    return ret;
}

- (NSDictionary *)toJsonObject {
    NSMutableDictionary *ret = [[super toJsonObject] mutableCopy];
    ret[@"event"] = self.event;
    ret[@"params"] = self.ext;
    return ret;
}

@end

#pragma mark - file

@interface EMFileMessageBody (Json)
+ (EMMessageBody *)fromJsonObject:(NSDictionary *)aJson;
- (NSDictionary *)toJsonObject;
@end

@implementation EMFileMessageBody (Json)

+ (EMMessageBody *)fromJsonObject:(NSDictionary *)aJson {
    NSString *path = aJson[@"localPath"];
    NSString *displayName = aJson[@"displayName"];
    EMFileMessageBody *ret =
        [[EMFileMessageBody alloc] initWithLocalPath:path
                                         displayName:displayName];
    ret.secretKey = aJson[@"secret"];
    ret.remotePath = aJson[@"remotePath"];
    ret.fileLength = [aJson[@"fileSize"] longLongValue];
    ret.downloadStatus =
        [ret downloadStatusFromInt:[aJson[@"fileStatus"] intValue]];
    return ret;
}

- (NSDictionary *)toJsonObject {
    NSMutableDictionary *ret = [[super toJsonObject] mutableCopy];
    ret[@"localPath"] = self.localPath;
    ret[@"displayName"] = self.displayName;
    ret[@"secret"] = self.secretKey;
    ret[@"remotePath"] = self.remotePath;
    ret[@"fileSize"] = @(self.fileLength);
    ret[@"fileStatus"] = @([self downloadStatusToInt:self.downloadStatus]);
    return ret;
}

- (EMDownloadStatus)downloadStatusFromInt:(int)aStatus {
    EMDownloadStatus ret = EMDownloadStatusPending;
    switch (aStatus) {
    case 0:
        ret = EMDownloadStatusDownloading;
        break;
    case 1:
        ret = EMDownloadStatusSucceed;
        break;
    case 2:
        ret = EMDownloadStatusFailed;
        break;
    case 3:
        ret = EMDownloadStatusPending;
        break;
    default:
        break;
    }

    return ret;
}

- (int)downloadStatusToInt:(EMDownloadStatus)aStatus {
    int ret = 0;
    switch (aStatus) {
    case EMDownloadStatusDownloading:
        ret = 0;
        break;
    case EMDownloadStatusSucceed:
        ret = 1;
        break;
    case EMDownloadStatusFailed:
        ret = 2;
        break;
    case EMDownloadStatusPending:
        ret = 3;
        break;
    default:
        break;
    }
    return ret;
}

@end

#pragma mark - img

@interface EMImageMessageBody (Json)
+ (EMMessageBody *)fromJsonObject:(NSDictionary *)aJson;
- (NSDictionary *)toJsonObject;
@end

@implementation EMImageMessageBody (Json)

+ (EMMessageBody *)fromJsonObject:(NSDictionary *)aJson {
    NSString *path = aJson[@"localPath"];
    NSString *displayName = aJson[@"displayName"];
    NSData *imageData = [NSData dataWithContentsOfFile:path];
    EMImageMessageBody *ret =
        [[EMImageMessageBody alloc] initWithData:imageData
                                     displayName:displayName];
    ret.secretKey = aJson[@"secret"];
    ret.remotePath = aJson[@"remotePath"];
    ret.fileLength = [aJson[@"fileSize"] longLongValue];
    ret.downloadStatus =
        [ret downloadStatusFromInt:[aJson[@"fileStatus"] intValue]];
    ret.thumbnailLocalPath = aJson[@"thumbnailLocalPath"];
    ret.thumbnailRemotePath = aJson[@"thumbnailRemotePath"];
    ret.thumbnailSecretKey = aJson[@"thumbnailSecret"];
    ret.size =
        CGSizeMake([aJson[@"width"] floatValue], [aJson[@"height"] floatValue]);
    ret.thumbnailDownloadStatus =
        [ret downloadStatusFromInt:[aJson[@"thumbnailStatus"] intValue]];
    ret.compressionRatio = [aJson[@"sendOriginalImage"] boolValue] ? 1.0 : 0.6;
    return ret;
}

- (NSDictionary *)toJsonObject {
    NSMutableDictionary *ret = [[super toJsonObject] mutableCopy];
    ret[@"thumbnailLocalPath"] = self.thumbnailLocalPath;
    ret[@"thumbnailRemotePath"] = self.thumbnailRemotePath;
    ret[@"thumbnailSecret"] = self.thumbnailSecretKey;
    ret[@"thumbnailStatus"] =
        @([self downloadStatusToInt:self.thumbnailDownloadStatus]);
    ret[@"fileStatus"] = @([self downloadStatusToInt:self.downloadStatus]);
    ret[@"width"] = @(self.size.width);
    ret[@"height"] = @(self.size.height);
    ret[@"fileSize"] = @(self.fileLength);
    ret[@"remotePath"] = self.remotePath;
    ret[@"secret"] = self.secretKey;
    ret[@"displayName"] = self.displayName;
    ret[@"localPath"] = self.localPath;
    ret[@"sendOriginalImage"] =
        self.compressionRatio == 1.0 ? @(true) : @(false);
    return ret;
}
@end

#pragma mark - video

@interface EMVideoMessageBody (Json)
+ (EMVideoMessageBody *)fromJsonObject:(NSDictionary *)aJson;
- (NSDictionary *)toJsonObject;
@end

@implementation EMVideoMessageBody (Json)
+ (EMVideoMessageBody *)fromJsonObject:(NSDictionary *)aJson {
    NSString *path = aJson[@"localPath"];
    NSString *displayName = aJson[@"displayName"];
    EMVideoMessageBody *ret =
        [[EMVideoMessageBody alloc] initWithLocalPath:path
                                          displayName:displayName];
    ret.duration = [aJson[@"duration"] intValue];
    ret.secretKey = aJson[@"secret"];
    ret.remotePath = aJson[@"remotePath"];
    ret.fileLength = [aJson[@"fileSize"] longLongValue];
    ret.thumbnailLocalPath = aJson[@"thumbnailLocalPath"];
    ret.thumbnailRemotePath = aJson[@"thumbnailRemotePath"];
    ret.thumbnailSecretKey = aJson[@"thumbnailSecret"];
    ret.thumbnailDownloadStatus =
        [ret downloadStatusFromInt:[aJson[@"thumbnailStatus"] intValue]];
    ret.thumbnailSize =
        CGSizeMake([aJson[@"width"] floatValue], [aJson[@"height"] floatValue]);
    return ret;
}

- (NSDictionary *)toJsonObject {
    NSMutableDictionary *ret = [[super toJsonObject] mutableCopy];
    ret[@"duration"] = @(self.duration);
    ret[@"thumbnailLocalPath"] = self.thumbnailLocalPath;
    ret[@"secret"] = self.secretKey;
    ret[@"remotePath"] = self.remotePath;
    ret[@"thumbnailRemotePath"] = self.thumbnailRemotePath;
    ret[@"thumbnailSecretKey"] = self.thumbnailSecretKey;
    ret[@"thumbnailStatus"] =
        @([self downloadStatusToInt:self.thumbnailDownloadStatus]);
    ret[@"width"] = @(self.thumbnailSize.width);
    ret[@"height"] = @(self.thumbnailSize.height);
    ret[@"fileSize"] = @(self.fileLength);
    ret[@"displayName"] = self.displayName;
    ret[@"duration"] = @(self.duration);
    return ret;
}
@end

#pragma mark - voice

@interface EMVoiceMessageBody (Json)
+ (EMVoiceMessageBody *)fromJsonObject:(NSDictionary *)aJson;
- (NSDictionary *)toJsonObject;
@end

@implementation EMVoiceMessageBody (Json)
+ (EMVoiceMessageBody *)fromJsonObject:(NSDictionary *)aJson {
    NSString *path = aJson[@"localPath"];
    NSString *displayName = aJson[@"displayName"];
    EMVoiceMessageBody *ret =
        [[EMVoiceMessageBody alloc] initWithLocalPath:path
                                          displayName:displayName];
    ret.secretKey = aJson[@"secret"];
    ret.remotePath = aJson[@"remotePath"];
    ret.duration = [aJson[@"duration"] intValue];
    ret.downloadStatus =
        [ret downloadStatusFromInt:[aJson[@"fileStatus"] intValue]];
    return ret;
}

- (NSDictionary *)toJsonObject {
    NSMutableDictionary *ret = [[super toJsonObject] mutableCopy];
    ret[@"duration"] = @(self.duration);
    ret[@"displayName"] = self.displayName;
    ret[@"localPath"] = self.localPath;
    ret[@"fileSize"] = @(self.fileLength);
    ret[@"secret"] = self.secretKey;
    ret[@"remotePath"] = self.remotePath;
    ret[@"fileStatus"] = @([self downloadStatusToInt:self.downloadStatus]);
    ;
    return ret;
}

@end

@implementation EMOptions (Json)
- (NSDictionary *)toJsonObject {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"appKey"] = self.appkey;
    data[@"autoLogin"] = @(self.isAutoLogin);
    data[@"debugModel"] = @(self.enableConsoleLog);
    data[@"requireAck"] = @(self.enableRequireReadAck);
    data[@"requireDeliveryAck"] = @(self.enableDeliveryAck);
    data[@"sortMessageByServerTime"] = @(self.sortMessageByServerTime);
    data[@"acceptInvitationAlways"] = @(self.isAutoAcceptFriendInvitation);
    data[@"autoAcceptGroupInvitation"] = @(self.isAutoAcceptGroupInvitation);
    data[@"deleteMessagesAsExitGroup"] = @(self.isDeleteMessagesWhenExitGroup);
    data[@"deleteMessagesAsExitChatRoom"] =
        @(self.isDeleteMessagesWhenExitChatRoom);
    data[@"isAutoDownload"] = @(self.isAutoDownloadThumbnail);
    data[@"isChatRoomOwnerLeaveAllowed"] = @(self.isChatroomOwnerLeaveAllowed);
    data[@"serverTransfer"] = @(self.isAutoTransferMessageAttachments);
    data[@"usingHttpsOnly"] = @(self.usingHttpsOnly);
    data[@"pushConfig"] =
        @{@"pushConfig" : @{@"apnsCertName" : self.apnsCertName}};
    data[@"enableDNSConfig"] = @(self.enableDnsConfig);
    data[@"imPort"] = @(self.chatPort);
    data[@"imServer"] = self.chatServer;
    data[@"restServer"] = self.restServer;
    data[@"dnsUrl"] = self.dnsURL;

    return data;
}
+ (EMOptions *)fromJsonObject:(NSDictionary *)aJson {
    EMOptions *options = [EMOptions optionsWithAppkey:aJson[@"appKey"]];
    options.isAutoLogin = [aJson[@"autoLogin"] boolValue];
    options.enableConsoleLog = [aJson[@"debugModel"] boolValue];
    options.enableRequireReadAck = [aJson[@"requireAck"] boolValue];
    options.enableDeliveryAck = [aJson[@"requireDeliveryAck"] boolValue];
    options.sortMessageByServerTime =
        [aJson[@"sortMessageByServerTime"] boolValue];
    options.isAutoAcceptFriendInvitation =
        [aJson[@"acceptInvitationAlways"] boolValue];
    options.isAutoAcceptGroupInvitation =
        [aJson[@"autoAcceptGroupInvitation"] boolValue];
    options.isDeleteMessagesWhenExitGroup =
        [aJson[@"deleteMessagesAsExitGroup"] boolValue];
    options.isDeleteMessagesWhenExitChatRoom =
        [aJson[@"deleteMessagesAsExitChatRoom"] boolValue];
    options.isAutoDownloadThumbnail = [aJson[@"isAutoDownload"] boolValue];
    options.isChatroomOwnerLeaveAllowed =
        [aJson[@"isChatRoomOwnerLeaveAllowed"] boolValue];
    options.isAutoTransferMessageAttachments =
        [aJson[@"serverTransfer"] boolValue];
    options.usingHttpsOnly = [aJson[@"usingHttpsOnly"] boolValue];
    options.apnsCertName = aJson[@"pushConfig"][@"apnsCertName"];
    options.enableDnsConfig = [aJson[@"enableDNSConfig"] boolValue];
    options.chatPort = [aJson[@"imPort"] intValue];
    options.chatServer = aJson[@"imServer"];
    options.restServer = aJson[@"restServer"];
    options.dnsURL = aJson[@"dnsURL"];

    return options;
}
@end

@implementation EMPageResult (Json)
- (NSDictionary *)toJsonObject {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    NSMutableArray *dataList = [NSMutableArray array];
    for (id<ExtSdkToJson> obj in self.list) {
        [dataList addObject:[obj toJsonObject]];
    }

    data[@"list"] = dataList;
    data[@"count"] = @(self.count);

    return data;
}
@end

@implementation EMPushOptions (Json)
- (NSDictionary *)toJsonObject {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"noDisturb"] = @(self.isNoDisturbEnable);
    data[@"pushStyle"] = @(self.displayStyle != EMPushDisplayStyleSimpleBanner);
    data[@"noDisturbStartHour"] = @(self.noDisturbingStartH);
    data[@"noDisturbEndHour"] = @(self.noDisturbingEndH);
    return data;
}

@end

@implementation EMUserInfo (Json)

- (NSDictionary *)toJsonObject {
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    ret[@"userId"] = self.userId;
    ret[@"nickName"] = self.nickName;
    ret[@"avatarUrl"] = self.avatarUrl;
    ret[@"mail"] = self.mail;
    ret[@"phone"] = self.phone;
    ret[@"gender"] = @(self.gender);
    ret[@"sign"] = self.sign;
    ret[@"birth"] = self.birth;
    ret[@"ext"] = self.ext;

    return ret;
}

+ (EMUserInfo *)fromJsonObject:(NSDictionary *)aJson {
    EMUserInfo *userInfo = EMUserInfo.new;
    userInfo.userId = aJson[@"userId"] ?: @"";
    userInfo.nickName = aJson[@"nickName"] ?: @"";
    userInfo.avatarUrl = aJson[@"avatarUrl"] ?: @"";
    userInfo.mail = aJson[@"mail"] ?: @"";
    userInfo.phone = aJson[@"phone"] ?: @"";
    userInfo.gender = [aJson[@"gender"] integerValue] ?: 0;
    userInfo.sign = aJson[@"sign"] ?: @"";
    userInfo.birth = aJson[@"birth"] ?: @"";
    if ([aJson[@"ext"] isKindOfClass:[NSNull class]]) {
        userInfo.ext = @"";
    } else {
        userInfo.ext = aJson[@"ext"] ?: @"";
    }
    return [userInfo copy];
}

@end
