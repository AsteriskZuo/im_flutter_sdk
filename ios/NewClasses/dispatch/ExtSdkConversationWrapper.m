//
//  ExtSdkConversationWrapper.m
//
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import "ExtSdkConversationWrapper.h"
#import "ExtSdkMethodTypeObjc.h"

#import "ExtSdkToJson.h"

@interface ExtSdkConversationWrapper ()

@end

@implementation ExtSdkConversationWrapper

+ (nonnull instancetype)getInstance {
    static ExtSdkConversationWrapper *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
      instance = [[ExtSdkConversationWrapper alloc] init];
    });
    return instance;
}


#pragma mark - Private
- (void)getConversationWithParam:(NSDictionary *)param
                      completion:
                          (void (^)(EMConversation *conversation))aCompletion {
    __weak NSString *conversationId = param[@"con_id"];
    EMConversationType type =
        [EMConversation typeFromInt:[param[@"type"] intValue]];
    EMConversation *conversation =
        [EMClient.sharedClient.chatManager getConversation:conversationId
                                                      type:type
                                          createIfNotExist:YES];
    if (aCompletion) {
        aCompletion(conversation);
    }
}

#pragma mark - Actions
- (void)getUnreadMsgCount:(nullable NSDictionary *)param
                   result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;
    [self
        getConversationWithParam:param
                      completion:^(EMConversation *conversation) {
                        [weakSelf onResult:result
                            withMethodType:ExtSdkMethodKeyGetUnreadMsgCount
                                 withError:nil
                                withParams:@(conversation.unreadMessagesCount)];
                      }];
}

- (void)getLatestMsg:(NSDictionary *)param
                  result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation) {
                          EMMessage *msg = conversation.latestMessage;
                          [weakSelf onResult:result
                              withMethodType:ExtSdkMethodKeyGetLatestMsg
                                   withError:nil
                                  withParams:[msg toJsonObject]];
                        }];
}

- (void)getLatestMsgFromOthers:(NSDictionary *)param
                            result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;
    [self
        getConversationWithParam:param
                      completion:^(EMConversation *conversation) {
                        EMMessage *msg = conversation.lastReceivedMessage;
                        [weakSelf onResult:result
                            withMethodType:ExtSdkMethodKeyGetLatestMsgFromOthers
                                 withError:nil
                                withParams:[msg toJsonObject]];
                      }];
}

- (void)markMsgAsRead:(NSDictionary *)param
                   result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation) {
                          NSString *msgId = param[@"msg_id"];
                          EMError *error = nil;
                          [conversation markMessageAsReadWithId:msgId
                                                          error:&error];

                          [weakSelf onResult:result
                              withMethodType:ExtSdkMethodKeyMarkMsgAsRead
                                   withError:nil
                                  withParams:@(YES)];
                        }];
}

- (void)syncConversationName:(NSDictionary *)param
                      result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation) {
                          NSString *name = param[@"con_name"];
                          NSMutableDictionary *ext =
                              [conversation.ext mutableCopy];
                          if (!ext) {
                              ext = [NSMutableDictionary dictionary];
                          }
                          ext[@"con_name"] = name;
                          conversation.ext = ext;
                          [weakSelf onResult:result
                              withMethodType:ExtSdkMethodKeySyncConversationName
                                   withError:nil
                                  withParams:@(YES)];
                        }];
}

- (void)syncConversationExt:(NSDictionary *)param
                     result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation) {
                          NSDictionary *ext = param[@"ext"];
                          conversation.ext = ext;
                          [weakSelf onResult:result
                              withMethodType:ExtSdkMethodKeySyncConversationExt
                                   withError:nil
                                  withParams:@(YES)];
                        }];
}

- (void)markAllMsgsAsRead:(NSDictionary *)param
                       result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation) {
                          EMError *error = nil;
                          [conversation markAllMessagesAsRead:&error];
                          [weakSelf onResult:result
                              withMethodType:ExtSdkMethodKeyMarkAllMsgsAsRead
                                   withError:error
                                  withParams:@(!error)];
                        }];
}

- (void)insertMsg:(NSDictionary *)param
               result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation) {
                          NSDictionary *msgDict = param[@"msg"];
                          EMMessage *msg = [EMMessage fromJsonObject:msgDict];

                          EMError *error = nil;
                          [conversation insertMessage:msg error:&error];
                          [weakSelf onResult:result
                              withMethodType:ExtSdkMethodKeyInsertMsg
                                   withError:error
                                  withParams:@(!error)];
                        }];
}

- (void)appendMsg:(NSDictionary *)param
               result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation) {
                          NSDictionary *msgDict = param[@"msg"];
                          EMMessage *msg = [EMMessage fromJsonObject:msgDict];

                          EMError *error = nil;
                          [conversation appendMessage:msg error:&error];
                          [weakSelf onResult:result
                              withMethodType:ExtSdkMethodKeyAppendMsg
                                   withError:error
                                  withParams:@(!error)];
                        }];
}

- (void)updateConversationMsg:(NSDictionary *)param
                           result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;
    [self
        getConversationWithParam:param
                      completion:^(EMConversation *conversation) {
                        NSDictionary *msgDict = param[@"msg"];
                        EMMessage *msg = [EMMessage fromJsonObject:msgDict];

                        EMError *error = nil;
                        [conversation updateMessageChange:msg error:&error];
                        [weakSelf onResult:result
                            withMethodType:ExtSdkMethodKeyUpdateConversationMsg
                                 withError:error
                                withParams:@(!error)];
                      }];
}

- (void)removeMsg:(NSDictionary *)param
               result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation) {
                          NSString *msgId = param[@"msg_id"];
                          EMError *error = nil;
                          [conversation deleteMessageWithId:msgId error:&error];

                          [weakSelf onResult:result
                              withMethodType:ExtSdkMethodKeyRemoveMsg
                                   withError:error
                                  withParams:@(!error)];
                        }];
}

- (void)clearAllMsg:(NSDictionary *)param
                  result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation) {
                          EMError *error = nil;
                          [conversation deleteAllMessages:&error];
                          [weakSelf onResult:result
                              withMethodType:ExtSdkMethodKeyClearAllMsg
                                   withError:error
                                  withParams:@(!error)];
                        }];
}

#pragma mark - load messages
- (void)loadMsgWithId:(NSDictionary *)param
               result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;
    NSString *msgId = param[@"msg_id"];
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation) {
                          EMError *error = nil;
                          EMMessage *msg =
                              [conversation loadMessageWithId:msgId
                                                        error:&error];

                          [weakSelf onResult:result
                              withMethodType:ExtSdkMethodKeyLoadMsgWithId
                                   withError:error
                                  withParams:[msg toJsonObject]];
                        }];
}

- (void)loadMsgWithMsgType:(NSDictionary *)param
                    result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;

    EMMessageBodyType type = [EMMessageBody typeFromString:param[@"type"]];
    long long timeStamp = [param[@"timeStamp"] longLongValue];
    int count = [param[@"count"] intValue];
    NSString *sender = param[@"sender"];
    EMMessageSearchDirection direction =
        [self searchDirectionFromString:param[@"direction"]];

    [self
        getConversationWithParam:param
                      completion:^(EMConversation *conversation) {
                        [conversation
                            loadMessagesWithType:type
                                       timestamp:timeStamp
                                           count:count
                                        fromUser:sender
                                 searchDirection:direction
                                      completion:^(NSArray *aMessages,
                                                   EMError *aError) {
                                        NSMutableArray *msgJsonAry =
                                            [NSMutableArray array];
                                        for (EMMessage *msg in aMessages) {
                                            [msgJsonAry addObject:[msg toJsonObject]];
                                        }
                                        [weakSelf onResult:result
                                            withMethodType:
                                                ExtSdkMethodKeyLoadMsgWithMsgType
                                                 withError:aError
                                                withParams:msgJsonAry];
                                      }];
                      }];
}

- (void)loadMsgWithStartId:(NSDictionary *)param
                    result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;
    NSString *startId = param[@"startId"];
    int count = [param[@"count"] intValue];
    EMMessageSearchDirection direction =
        [self searchDirectionFromString:param[@"direction"]];

    [self
        getConversationWithParam:param
                      completion:^(EMConversation *conversation) {
                        [conversation
                            loadMessagesStartFromId:startId
                                              count:count
                                    searchDirection:direction
                                         completion:^(NSArray *aMessages,
                                                      EMError *aError) {
                                           NSMutableArray *jsonMsgs =
                                               [NSMutableArray array];
                                           for (EMMessage *msg in aMessages) {
                                               [jsonMsgs
                                                   addObject:[msg toJsonObject]];
                                           }

                                           [weakSelf onResult:result
                                               withMethodType:
                                                   ExtSdkMethodKeyLoadMsgWithStartId
                                                    withError:aError
                                                   withParams:jsonMsgs];
                                         }];
                      }];
}

- (void)loadMsgWithKeywords:(NSDictionary *)param
                     result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;
    NSString *keywords = param[@"keywords"];
    long long timestamp = [param[@"timestamp"] longLongValue];
    int count = [param[@"count"] intValue];
    NSString *sender = param[@"sender"];
    EMMessageSearchDirection direction =
        [self searchDirectionFromString:param[@"direction"]];
    [self
        getConversationWithParam:param
                      completion:^(EMConversation *conversation) {
                        [conversation
                            loadMessagesWithKeyword:keywords
                                          timestamp:timestamp
                                              count:count
                                           fromUser:sender
                                    searchDirection:direction
                                         completion:^(NSArray *aMessages,
                                                      EMError *aError) {
                                           NSMutableArray *msgJsonAry =
                                               [NSMutableArray array];
                                           for (EMMessage *msg in aMessages) {
                                               [msgJsonAry
                                                   addObject:[msg toJsonObject]];
                                           }
                                           [weakSelf onResult:result
                                               withMethodType:
                                                   ExtSdkMethodKeyLoadMsgWithKeywords
                                                    withError:aError
                                                   withParams:msgJsonAry];
                                         }];
                      }];
}

- (void)loadMsgWithTime:(NSDictionary *)param
                 result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;
    long long startTime = [param[@"startTime"] longLongValue];
    long long entTime = [param[@"endTime"] longLongValue];
    int count = [param[@"count"] intValue];
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation) {
                          [conversation
                              loadMessagesFrom:startTime
                                            to:entTime
                                         count:count
                                    completion:^(NSArray *aMessages,
                                                 EMError *aError) {
                                      NSMutableArray *msgJsonAry =
                                          [NSMutableArray array];
                                      for (EMMessage *msg in aMessages) {
                                          [msgJsonAry addObject:[msg toJsonObject]];
                                      }
                                      [weakSelf onResult:result
                                          withMethodType:
                                              ExtSdkMethodKeyLoadMsgWithTime
                                               withError:aError
                                              withParams:msgJsonAry];
                                    }];
                        }];
}

- (EMMessageSearchDirection)searchDirectionFromString:(NSString *)aDirection {
    return [aDirection isEqualToString:@"up"] ? EMMessageSearchDirectionUp
                                              : EMMessageSearchDirectionDown;
}

@end
