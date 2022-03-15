#import "ImFlutterSdkPlugin.h"

#import "EMChatManagerWrapper.h"
#import "EMClientWrapper.h"
#import "EMContactManagerWrapper.h"
#import "EMConversationWrapper.h"
#import "EMGroupManagerWrapper.h"
#import "EMChatroomManagerWrapper.h"
#import <HyphenateChat/HyphenateChat.h>
#import <UserNotifications/UserNotifications.h>

#import "ExtSdkTest.h"
#import "ExtSdkApiFlutter.h"
#import "ExtSdkDelegateObjcImpl.h"

@implementation ImFlutterSdkPlugin


+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if ([ExtSdkTest testType] == 1) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
//    EMClientWrapper *wrapper =  [[EMClientWrapper alloc] initWithChannelName:EMChannelName(@"em_client") registrar:registrar];
    [EMClientWrapper channelName:EMChannelName(@"em_client") registrar:registrar];
#pragma clang diagnostic pop
    } else if ([ExtSdkTest testType] == 2) {
        [[ExtSdkApiFlutter getInstance] addListener:[[ExtSdkDelegateObjcImpl alloc] init]];
        
    } else {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"test type is not exist: %d", [ExtSdkTest testType]]
                                     userInfo:nil];
    }

}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
}

@end


@implementation FlutterAppDelegate(EaseMob)
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if ([ExtSdkTest testType] == 1) {
        [[EMClient sharedClient] applicationDidEnterBackground:application];
    } else if ([ExtSdkTest testType] == 2) {
        [[EMClient sharedClient] applicationDidEnterBackground:application];
    } else {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"test type is not exist: %d", [ExtSdkTest testType]]
                                     userInfo:nil];
    }
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if ([ExtSdkTest testType] == 1) {
        [[EMClient sharedClient] applicationWillEnterForeground:application];
    } else if ([ExtSdkTest testType] == 2) {
        [[EMClient sharedClient] applicationWillEnterForeground:application];
    } else {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"test type is not exist: %d", [ExtSdkTest testType]]
                                     userInfo:nil];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    if ([ExtSdkTest testType] == 1) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[EMClient sharedClient] bindDeviceToken:deviceToken];
        });
    } else if ([ExtSdkTest testType] == 2) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[EMClient sharedClient] bindDeviceToken:deviceToken];
        });
    } else {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"test type is not exist: %d", [ExtSdkTest testType]]
                                     userInfo:nil];
    }

}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"注册推送失败 --- %@", error);
}

@end

