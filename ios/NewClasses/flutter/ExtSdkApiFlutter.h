#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "ExtSdkApiObjc.h"

@interface ExtSdkApiFlutter : NSObject <ExtSdkApiObjc, FlutterPlugin>

+ (instancetype)getInstance;

- (void)addListener:(nonnull id<ExtSdkDelegateObjc>)listener;

- (void)callSdkApi:(nonnull NSString *)methodType withParams:(nullable id<NSObject>)params withCallback:(nonnull id<ExtSdkCallbackObjc>)callback;

- (void)delListener:(nonnull id<ExtSdkDelegateObjc>)listener;

- (void)init:(nonnull id<NSObject>)config;

- (void)unInit:(nullable id<NSObject>)params;

+ (void)registerWithRegistrar:(nonnull NSObject<FlutterPluginRegistrar> *)registrar;

@end
