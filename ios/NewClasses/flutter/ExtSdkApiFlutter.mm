#import <Flutter/Flutter.h>
#import "ExtSdkApiFlutter.h"
#import "ExtSdkDelegateObjc.h"
#import "ExtSdkCallbackObjc.h"
#import "ExtSdkCallbackObjcImpl.h"
#import "ExtSdkChannelManager.h"
#import "ExtSdkThreadUtilObjc.h"
#include "ExtSdkApiObjcImpl.h"
#include "ExtSdkObjectObjcImpl.h"


@interface ExtSdkApiFlutter () <FlutterPlugin>

@end

@implementation ExtSdkApiFlutter

+ (nonnull instancetype)getInstance {
    static ExtSdkApiFlutter *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
      instance = [[ExtSdkApiFlutter alloc] init];
    });
    return instance;
}

- (void)addListener:(nonnull id<ExtSdkDelegateObjc>)listener {
    EXT_SDK_NAMESPACE_USING
    ExtSdkApi::getInstance()->addListener(std::make_shared<ExtSdkObjectObjcImpl>(listener));
}

- (void)callSdkApi:(nonnull NSString *)methodType withParams:(nullable id<NSObject>)params withCallback:(nonnull id<ExtSdkCallbackObjc>)callback {
    EXT_SDK_NAMESPACE_USING
    std::string cpp_method_type = std::string([methodType UTF8String]);
    std::shared_ptr<ExtSdkObject> cpp_params = std::make_shared<ExtSdkObjectObjcImpl>(params);
    std::shared_ptr<ExtSdkObject> cpp_callback = std::make_shared<ExtSdkObjectObjcImpl>(callback);
    ExtSdkApi::getInstance()->callSdkApi(cpp_method_type, cpp_params, cpp_callback);
}

- (void)delListener:(nonnull id<ExtSdkDelegateObjc>)listener {
    // TODO: no implement
}

- (void)init:(nonnull id<NSObject>)config {
    EXT_SDK_NAMESPACE_USING
    std::shared_ptr<ExtSdkObjectObjcImpl> cpp_config = std::make_shared<ExtSdkObjectObjcImpl>(config);
    ExtSdkApi::getInstance()->init(cpp_config);
}

- (void)unInit:(nullable id<NSObject>)params {
    EXT_SDK_NAMESPACE_USING
    ExtSdkApi::getInstance()->unInit();
}

+ (void)registerWithRegistrar:(nonnull NSObject<FlutterPluginRegistrar> *)registrar {
    [[ExtSdkChannelManager getInstance] setRegistrar:registrar];
    [[ExtSdkChannelManager getInstance] add:SEND_CHANNEL];
    [[ExtSdkChannelManager getInstance] add:RECV_CHANNEL];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
//    __weak typeof(self) weakself = self; // TODO: 后续解决
    [ExtSdkThreadUtilObjc asyncExecute:^{
        id<NSObject> params = call.arguments;
        id<ExtSdkCallbackObjc> callback = [[ExtSdkCallbackObjcImpl alloc] init:result];
        [self callSdkApi:call.method withParams:params withCallback:callback];
    }];
}

@end
