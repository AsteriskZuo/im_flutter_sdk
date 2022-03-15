#import "ExtSdkApiFlutter.h"
#include "ExtSdkApiObjcImpl.h"
#import "ExtSdkCallbackObjc.h"
#import "ExtSdkCallbackObjcImpl.h"
#import "ExtSdkChannelManager.h"
#import "ExtSdkDelegateObjc.h"
#import "ExtSdkDelegateObjcImpl.h"
#include "ExtSdkObjectObjcImpl.h"
#import "ExtSdkTest.h"
#import "ExtSdkThreadUtilObjc.h"
#import <UIKit/UIApplication.h>
#import <HyphenateChat/EMClient.h>

static NSString *const TAG = @"ExtSdkApiFlutter";

@interface ExtSdkApiFlutter () <UIApplicationDelegate>

@end

@implementation ExtSdkApiFlutter

+ (instancetype)getInstance {
    static ExtSdkApiFlutter *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
      instance = [[ExtSdkApiFlutter alloc] init];
    });
    return instance;
}

#pragma mark - ExtSdkApiObjc

- (void)addListener:(nonnull id<ExtSdkDelegateObjc>)listener {
    NSLog(@"%@: addListener:", TAG);
    EXT_SDK_NAMESPACE_USING
    ExtSdkApi::getInstance()->addListener(std::make_shared<ExtSdkObjectObjcImpl>(listener));
}

- (void)callSdkApi:(nonnull NSString *)methodType
        withParams:(nullable id<NSObject>)params
      withCallback:(nonnull id<ExtSdkCallbackObjc>)callback {
    NSLog(@"%@: callSdkApi: %@: %@", TAG, methodType, nil != params ? params : @"");
    EXT_SDK_NAMESPACE_USING
    std::string cpp_method_type = std::string([methodType UTF8String]);
    std::shared_ptr<ExtSdkObject> cpp_params = std::make_shared<ExtSdkObjectObjcImpl>(params);
    std::shared_ptr<ExtSdkObject> cpp_callback = std::make_shared<ExtSdkObjectObjcImpl>(callback);
    ExtSdkApi::getInstance()->callSdkApi(cpp_method_type, cpp_params, cpp_callback);
}

- (void)delListener:(nonnull id<ExtSdkDelegateObjc>)listener {
    NSLog(@"%@: delListener:", TAG);
    // TODO: no implement
}

- (void)init:(nonnull id<NSObject>)config {
    NSLog(@"%@: init:", TAG);
    EXT_SDK_NAMESPACE_USING
    std::shared_ptr<ExtSdkObjectObjcImpl> cpp_config = std::make_shared<ExtSdkObjectObjcImpl>(config);
    ExtSdkApi::getInstance()->init(cpp_config);
}

- (void)unInit:(nullable id<NSObject>)params {
    NSLog(@"%@: unInit:", TAG);
    EXT_SDK_NAMESPACE_USING
    ExtSdkApi::getInstance()->unInit();
}

#pragma mark - FlutterPlugin

+ (void)registerWithRegistrar:(nonnull NSObject<FlutterPluginRegistrar> *)registrar {
    NSLog(@"%@: registerWithRegistrar:", TAG);
    if ([ExtSdkTest testType] == 1) {

    } else if ([ExtSdkTest testType] == 2) {
        [[ExtSdkChannelManager getInstance] setRegistrar:registrar];
        [[ExtSdkChannelManager getInstance] add:SEND_CHANNEL];
        [[ExtSdkChannelManager getInstance] add:RECV_CHANNEL];
        [[ExtSdkApiFlutter getInstance] addListener:[[ExtSdkDelegateObjcImpl alloc] init]];
        FlutterMethodChannel *send_channel = [[ExtSdkChannelManager getInstance] get:SEND_CHANNEL];
        id<FlutterPlugin, UIApplicationDelegate> flutter = [ExtSdkApiFlutter getInstance];
        [registrar addMethodCallDelegate:flutter channel:send_channel];
        [registrar addApplicationDelegate:flutter];
    } else {
        @throw [NSException
            exceptionWithName:NSInvalidArgumentException
                       reason:[NSString stringWithFormat:@"test type is not exist: %d", [ExtSdkTest testType]]
                     userInfo:nil];
    }
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"%@: handleMethodCall:", TAG);
    //    __weak typeof(self) weakself = self; // TODO: 后续解决
    [ExtSdkThreadUtilObjc asyncExecute:^{
      id<NSObject> params = call.arguments;
      id<ExtSdkCallbackObjc> callback = [[ExtSdkCallbackObjcImpl alloc] init:result];
      [self callSdkApi:call.method withParams:params withCallback:callback];
    }];
}

#pragma mark - UIApplicationDelegate

- (void)applicationDidEnterBackground:(UIApplication *)application API_AVAILABLE(ios(4.0)) {
    NSLog(@"%@: applicationDidEnterBackground:", TAG);
    if ([ExtSdkTest testType] == 1) {

    } else if ([ExtSdkTest testType] == 2) {
        [[EMClient sharedClient] applicationDidEnterBackground:application];
    } else {
        @throw [NSException
            exceptionWithName:NSInvalidArgumentException
                       reason:[NSString stringWithFormat:@"test type is not exist: %d", [ExtSdkTest testType]]
                     userInfo:nil];
    }
}
- (void)applicationWillEnterForeground:(UIApplication *)application API_AVAILABLE(ios(4.0)) {
    NSLog(@"%@: applicationWillEnterForeground:", TAG);
    if ([ExtSdkTest testType] == 1) {

    } else if ([ExtSdkTest testType] == 2) {
        [[EMClient sharedClient] applicationWillEnterForeground:application];
    } else {
        @throw [NSException
            exceptionWithName:NSInvalidArgumentException
                       reason:[NSString stringWithFormat:@"test type is not exist: %d", [ExtSdkTest testType]]
                     userInfo:nil];
    }
}

- (void)application:(UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"%@: didRegisterForRemoteNotificationsWithDeviceToken:", TAG);
    if ([ExtSdkTest testType] == 1) {

    } else if ([ExtSdkTest testType] == 2) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          [[EMClient sharedClient] bindDeviceToken:deviceToken];
        });
    } else {
        @throw [NSException
            exceptionWithName:NSInvalidArgumentException
                       reason:[NSString stringWithFormat:@"test type is not exist: %d", [ExtSdkTest testType]]
                     userInfo:nil];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"%@: didFailToRegisterForRemoteNotificationsWithError: %@", error);
}

@end
