//
//  ExtSdkConversationWrapper.h
//
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import "ExtSdkWrapper.h"

NS_ASSUME_NONNULL_BEGIN

@interface ExtSdkConversationWrapper : ExtSdkWrapper

+ (nonnull instancetype)getInstance;

#pragma mark - Actions
- (void)getUnreadMsgCount:(nullable NSDictionary *)param
                   result:(nonnull id<ExtSdkCallbackObjc>)result;
- (void)getLatestMsg:(NSDictionary *)param
              result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)getLatestMsgFromOthers:(NSDictionary *)param
                        result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)markMsgAsRead:(NSDictionary *)param
               result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)syncConversationName:(NSDictionary *)param
                      result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)syncConversationExt:(NSDictionary *)param
                     result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)markAllMsgsAsRead:(NSDictionary *)param
                   result:(nonnull id<ExtSdkCallbackObjc>)result;
- (void)insertMsg:(NSDictionary *)param
           result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)appendMsg:(NSDictionary *)param
           result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)updateConversationMsg:(NSDictionary *)param
                       result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)removeMsg:(NSDictionary *)param
           result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)clearAllMsg:(NSDictionary *)param
             result:(nonnull id<ExtSdkCallbackObjc>)result;

#pragma mark - load messages
- (void)loadMsgWithId:(NSDictionary *)param
               result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)loadMsgWithMsgType:(NSDictionary *)param
                    result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)loadMsgWithStartId:(NSDictionary *)param
                    result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)loadMsgWithKeywords:(NSDictionary *)param
                     result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)loadMsgWithTime:(NSDictionary *)param
                 result:(nonnull id<ExtSdkCallbackObjc>)result;
@end

NS_ASSUME_NONNULL_END
