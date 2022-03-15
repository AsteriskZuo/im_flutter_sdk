//
//  ExtSdkPushManagerWrapper.m
//  im_flutter_sdk
//
//  Created by 东海 on 2020/5/7.
//

#import "ExtSdkPushManagerWrapper.h"
#import "ExtSdkMethodTypeObjc.h"
#import "ExtSdkToJson.h"

@implementation ExtSdkPushManagerWrapper

+ (nonnull instancetype)getInstance {
    static ExtSdkPushManagerWrapper *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
      instance = [[ExtSdkPushManagerWrapper alloc] init];
    });
    return instance;
}


- (void)getImPushConfig:(NSDictionary *)param
         withMethodType:(NSString *)aChannelName
                 result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;
    EMPushOptions *options = EMClient.sharedClient.pushManager.pushOptions;
    [weakSelf onResult:result
        withMethodType:aChannelName
             withError:nil
            withParams:[options toJsonObject]];
}

- (void)getImPushConfigFromServer:(NSDictionary *)param
                   withMethodType:(NSString *)aChannelName
                           result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.pushManager
        getPushNotificationOptionsFromServerWithCompletion:^(
            EMPushOptions *aOptions, EMError *aError) {
          [weakSelf onResult:result
              withMethodType:aChannelName
                   withError:aError
                  withParams:[aOptions toJsonObject]];
        }];
}

- (void)updatePushNickname:(NSDictionary *)param
            withMethodType:(NSString *)aChannelName
                    result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;
    NSString *nickname = param[@"nickname"];
    [EMClient.sharedClient.pushManager
        updatePushDisplayName:nickname
                   completion:^(NSString *_Nonnull aDisplayName,
                                EMError *_Nonnull aError) {
                     [weakSelf onResult:result
                         withMethodType:aChannelName
                              withError:aError
                             withParams:aDisplayName];
                   }];
}

- (void)setImPushNoDisturb:(NSDictionary *)param
            withMethodType:(NSString *)aChannelName
                    result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;

    bool noDisturb = [param[@"noDisturb"] boolValue];
    int startTime = [param[@"startTime"] intValue];
    int endTime = [param[@"endTime"] intValue];

    dispatch_async(
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          EMError *aError = nil;
          if (noDisturb) {
              aError = [EMClient.sharedClient.pushManager
                  disableOfflinePushStart:startTime
                                      end:endTime];
          } else {
              aError = [EMClient.sharedClient.pushManager enableOfflinePush];
          }

          [weakSelf onResult:result
                withMethodType:aChannelName
                     withError:aError
                    withParams:@(!aError)];
        });
}

- (void)updateImPushStyle:(NSDictionary *)param
           withMethodType:(NSString *)aChannelName
                   result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;

    EMPushDisplayStyle pushStyle = [param[@"pushStyle"] intValue];

    dispatch_async(
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          EMError *aError = [EMClient.sharedClient.pushManager
              updatePushDisplayStyle:pushStyle];
          [weakSelf onResult:result
                withMethodType:aChannelName
                     withError:aError
                    withParams:@(!aError)];
        });
}

- (void)updateGroupPushService:(NSDictionary *)param
                withMethodType:(NSString *)aChannelName
                        result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;
    NSString *groupId = param[@"group_id"];
    bool enablePush = [param[@"enablePush"] boolValue];

    [EMClient.sharedClient.pushManager
        updatePushServiceForGroups:@[ groupId ]
                       disablePush:!enablePush
                        completion:^(EMError *_Nonnull aError) {
                          EMGroup *aGroup = [EMGroup groupWithId:groupId];
                          [weakSelf onResult:result
                              withMethodType:aChannelName
                                   withError:aError
                                  withParams:[aGroup toJsonObject]];
                        }];
}

- (void)getNoDisturbGroups:(NSDictionary *)param
            withMethodType:(NSString *)aChannelName
                    result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;
    dispatch_async(
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          EMError *aError = nil;
          [EMClient.sharedClient.pushManager
              getPushOptionsFromServerWithError:&aError];
          NSArray *list = [EMClient.sharedClient.pushManager noPushGroups];
          [weakSelf onResult:result
                withMethodType:aChannelName
                     withError:aError
                    withParams:list];
        });
}

- (void)bindDeviceToken:(NSDictionary *)param
         withMethodType:(NSString *)aChannelName
                 result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;
    NSString *deviceToken = param[@"token"];
    dispatch_async(
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          EMError *error = [EMClient.sharedClient bindDeviceToken:deviceToken];
          [weakSelf onResult:result
                withMethodType:aChannelName
                     withError:error
                    withParams:nil];
        });
}

@end
