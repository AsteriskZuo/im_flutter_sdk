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

- (instancetype)initWithChannelName:(NSString *)aChannelName
                          registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if(self = [super initWithChannelName:aChannelName
                               registrar:registrar]) {
    }
    return self;
}

#pragma mark - FlutterPlugin

- (void)handleMethodCall:(FlutterMethodCall*)call
                  result:(FlutterResult)result {
    if ([ExtSdkMethodKeyGetImPushConfig isEqualToString:call.method]) {
        [self getImPushConfig:call.arguments
                   channelName:ExtSdkMethodKeyGetImPushConfig
                        result:result];
    } else if ([ExtSdkMethodKeyGetImPushConfigFromServer isEqualToString:call.method]) {
        [self getImPushConfigFromServer:call.arguments
                             channelName:ExtSdkMethodKeyGetImPushConfigFromServer
                                  result:result];
    } else if ([ExtSdkMethodKeyUpdatePushNickname isEqualToString:call.method]) {
        [self updatePushNickname:call.arguments
                     channelName:ExtSdkMethodKeyUpdatePushNickname
                          result:result];
    } else if ([ExtSdkMethodKeyImPushNoDisturb isEqualToString:call.method]) {
        [self setImPushNoDisturb:call.arguments
                     channelName:ExtSdkMethodKeyImPushNoDisturb
                          result:result];
    } else if ([ExtSdkMethodKeyUpdateImPushStyle isEqualToString:call.method]) {
        [self updateImPushStyle:call.arguments
                    channelName:ExtSdkMethodKeyUpdateImPushStyle
                         result:result];
    } else if ([ExtSdkMethodKeyUpdateGroupPushService isEqualToString:call.method]) {
        [self updateGroupPushService:call.arguments
                         channelName:ExtSdkMethodKeyUpdateGroupPushService
                              result:result];
    } else if ([ExtSdkMethodKeyGetNoDisturbGroups isEqualToString:call.method]) {
        [self getNoDisturbGroups:call.arguments
                     channelName:ExtSdkMethodKeyGetNoDisturbGroups
                          result:result];
    } else if ([ExtSdkMethodKeyBindDeviceToken isEqualToString:call.method]) {
        [self  bindDeviceToken:call.arguments
                   channelName:(NSString *)ExtSdkMethodKeyBindDeviceToken
                        result:result];
    }
    else{
        [super handleMethodCall:call result:result];
    }
}

- (void)getImPushConfig:(NSDictionary *)param
             channelName:(NSString *)aChannelName
                  result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    EMPushOptions *options = EMClient.sharedClient.pushManager.pushOptions;
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:[options toJson]];
}

- (void)getImPushConfigFromServer:(NSDictionary *)param
                       channelName:(NSString *)aChannelName
                            result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.pushManager getPushNotificationOptionsFromServerWithCompletion:^(EMPushOptions *aOptions, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aOptions toJson]];
        
    }];
}

- (void)updatePushNickname:(NSDictionary *)param
               channelName:(NSString *)aChannelName
                    result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *nickname = param[@"nickname"];
    [EMClient.sharedClient.pushManager updatePushDisplayName:nickname
                                                  completion:^(NSString * _Nonnull aDisplayName, EMError * _Nonnull aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:aDisplayName];
    }];
    
}

- (void)setImPushNoDisturb:(NSDictionary *)param
               channelName:(NSString *)aChannelName
                    result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    
    bool noDisturb = [param[@"noDisturb"] boolValue];
    int startTime = [param[@"startTime"] intValue];
    int endTime = [param[@"endTime"] intValue];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *aError = nil;
        if (noDisturb) {
            aError = [EMClient.sharedClient.pushManager disableOfflinePushStart:startTime end:endTime];
        }else {
            aError = [EMClient.sharedClient.pushManager enableOfflinePush];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:aError
                               object:@(!aError)];
        });
    });
    
    
}

- (void)updateImPushStyle:(NSDictionary *)param
              channelName:(NSString *)aChannelName
                   result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    
    EMPushDisplayStyle pushStyle = [param[@"pushStyle"] intValue];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *aError = [EMClient.sharedClient.pushManager updatePushDisplayStyle:pushStyle];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:aError
                               object:@(!aError)];
        });
    });
}

- (void)updateGroupPushService:(NSDictionary *)param
                   channelName:(NSString *)aChannelName
                        result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *groupId = param[@"group_id"];
    bool enablePush = [param[@"enablePush"] boolValue];
    
    [EMClient.sharedClient.pushManager updatePushServiceForGroups:@[groupId]
                                                      disablePush:!enablePush
                                                       completion:^(EMError * _Nonnull aError)
    {
        EMGroup *aGroup = [EMGroup groupWithId:groupId];
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aGroup toJson]];
    }];
}

- (void)getNoDisturbGroups:(NSDictionary *)param
               channelName:(NSString *)aChannelName
                    result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *aError = nil;
        [EMClient.sharedClient.pushManager getPushOptionsFromServerWithError:&aError];
        NSArray *list = [EMClient.sharedClient.pushManager noPushGroups];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:aError
                               object:list];
        });
    });
}

- (void)bindDeviceToken:(NSDictionary *)param
            channelName:(NSString *)aChannelName
                 result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *deviceToken = param[@"token"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = [EMClient.sharedClient bindDeviceToken:deviceToken];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:error
                               object:nil];
        });
    });
}


@end
