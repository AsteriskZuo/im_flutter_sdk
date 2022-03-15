//
//  ExtSdkToJson.h
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/9/27.
//

#import <Foundation/Foundation.h>

#import <HyphenateChat/EMChatroom.h>
#import <HyphenateChat/EMConversation.h>
#import <HyphenateChat/EMCursorResult.h>
#import <HyphenateChat/EMDeviceConfig.h>
#import <HyphenateChat/EMError.h>
#import <HyphenateChat/EMGroup.h>
#import <HyphenateChat/EMGroupMessageAck.h>
#import <HyphenateChat/EMGroupOptions.h>
#import <HyphenateChat/EMGroupSharedFile.h>
#import <HyphenateChat/EMMessage.h>
#import <HyphenateChat/EMMessageBody.h>
#import <HyphenateChat/EMOptions.h>
#import <HyphenateChat/EMPageResult.h>
#import <HyphenateChat/EMPushOptions.h>
#import <HyphenateChat/EMUserInfo.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ExtSdkToJson <NSObject>
- (NSDictionary *)toJsonObject;
@end

@interface EMChatroom (Json) <ExtSdkToJson>
- (NSDictionary *)toJsonObject;
@end

@interface EMConversation (Json) <ExtSdkToJson>
- (NSDictionary *)toJsonObject;
+ (int)typeToInt:(EMConversationType)aType;
+ (EMConversationType)typeFromInt:(int)aType;
@end

@interface EMCursorResult (Json) <ExtSdkToJson>
- (NSDictionary *)toJsonObject;
@end

@interface EMDeviceConfig (Json) <ExtSdkToJson>
- (NSDictionary *)toJsonObject;
@end

@interface EMError (Json) <ExtSdkToJson>
- (NSDictionary *)toJsonObject;
@end

@interface EMGroup (Json) <ExtSdkToJson>
- (NSDictionary *)toJsonObject;
+ (EMGroupPermissionType)premissionTypeFromInt:(int)type;
+ (int)premissionTypeToInt:(EMGroupPermissionType)type;
@end

@interface EMGroupOptions (Json) <ExtSdkToJson>
+ (EMGroupOptions *)formJson:(NSDictionary *)dict;
- (NSDictionary *)toJsonObject;
+ (EMGroupStyle)styleFromInt:(int)style;
+ (int)styleToInt:(EMGroupStyle)style;
@end

@interface EMGroupSharedFile (Json) <ExtSdkToJson>
- (NSDictionary *)toJsonObject;
@end

@interface EMGroupMessageAck (Json) <ExtSdkToJson>
- (NSDictionary *)toJsonObject;
@end

@interface EMMessage (Json) <ExtSdkToJson>
+ (EMMessage *)fromJsonObject:(NSDictionary *)aJson;
- (NSDictionary *)toJsonObject;
@end

@interface EMMessageBody (Json) <ExtSdkToJson>
+ (EMMessageBody *)fromJsonObject:(NSDictionary *)aJson;
- (NSDictionary *)toJsonObject;
+ (EMMessageBodyType)typeFromString:(NSString *)aStrType;
@end

@interface EMOptions (Json) <ExtSdkToJson>
- (NSDictionary *)toJsonObject;
+ (EMOptions *)fromJsonObject:(NSDictionary *)aJson;
@end

@interface EMPageResult (Json) <ExtSdkToJson>
- (NSDictionary *)toJsonObject;
@end

@interface EMPushOptions (Json) <ExtSdkToJson>
- (NSDictionary *)toJsonObject;
@end

@interface EMUserInfo (Json) <ExtSdkToJson>
- (NSDictionary *)toJsonObject;
+ (EMUserInfo *)fromJsonObject:(NSDictionary *)aJson;
@end

NS_ASSUME_NONNULL_END
