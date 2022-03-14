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
#import <HyphenateChat/EMGroupOptions.h>
#import <HyphenateChat/EMGroupSharedFile.h>
#import <HyphenateChat/EMGroupMessageAck.h>
#import <HyphenateChat/EMMessage.h>
#import <HyphenateChat/EMMessageBody.h>
#import <HyphenateChat/EMOptions.h>
#import <HyphenateChat/EMPageResult.h>
#import <HyphenateChat/EMPushOptions.h>
#import <HyphenateChat/EMUserInfo.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ExtSdkToJson <NSObject>
- (NSDictionary *)toJson;
@end

@interface EMChatroom (Json) <ExtSdkToJson>
- (NSDictionary *)toJson;
@end

@interface EMConversation (Json) <ExtSdkToJson>
- (NSDictionary *)toJson;
+ (int)typeToInt:(EMConversationType)aType;
+ (EMConversationType)typeFromInt:(int)aType;
@end

@interface EMCursorResult (Json) <ExtSdkToJson>
- (NSDictionary *)toJson;
@end

@interface EMDeviceConfig (Json) <ExtSdkToJson>
- (NSDictionary *)toJson;
@end

@interface EMError (Json) <ExtSdkToJson>
- (NSDictionary *)toJson;
@end

@interface EMGroup (Json) <ExtSdkToJson>
- (NSDictionary *)toJson;
+ (EMGroupPermissionType)premissionTypeFromInt:(int)type;
+ (int)premissionTypeToInt:(EMGroupPermissionType)type;
@end

@interface EMGroupOptions (Json) <ExtSdkToJson>
+ (EMGroupOptions *)formJson:(NSDictionary *)dict;
- (NSDictionary *)toJson;
+ (EMGroupStyle)styleFromInt:(int)style;
+ (int)styleToInt:(EMGroupStyle)style;
@end

@interface EMGroupSharedFile (Json) <ExtSdkToJson>
- (NSDictionary *)toJson;
@end

@interface EMGroupMessageAck (Json) <ExtSdkToJson>
- (NSDictionary *)toJson;
@end

@interface EMMessage (Json) <ExtSdkToJson>
+ (EMMessage *)fromJson:(NSDictionary *)aJson;
- (NSDictionary *)toJson;
@end

@interface EMMessageBody (Json) <ExtSdkToJson>
+ (EMMessageBody *)fromJson:(NSDictionary *)aJson;
- (NSDictionary *)toJson;
+ (EMMessageBodyType)typeFromString:(NSString *)aStrType;
@end

@interface EMOptions (Json) <ExtSdkToJson>
- (NSDictionary *)toJson;
+ (EMOptions *)fromJson:(NSDictionary *)aJson;
@end

@interface EMPageResult (Json) <ExtSdkToJson>
- (NSDictionary *)toJson;
@end

@interface EMPushOptions (Json) <ExtSdkToJson>
- (NSDictionary *)toJson;
@end

@interface EMUserInfo (Json) <ExtSdkToJson>
- (NSDictionary *)toJson;
+ (EMUserInfo *)fromJson:(NSDictionary *)aJson;
@end

NS_ASSUME_NONNULL_END
