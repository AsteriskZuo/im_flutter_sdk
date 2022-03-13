#import <Foundation/Foundation.h>
#import "ExtSdkApiObjc.h"

@interface ExtSdkDispatchObjc : NSObject <ExtSdkApiObjc>

+ (nonnull instancetype)getInstance;

- (void)addListener:(nonnull id<ExtSdkDelegateObjc>)listener;

- (void)callSdkApi:(nonnull NSString *)methodType withParams:(nullable id<NSObject>)params withCallback:(nonnull id<ExtSdkCallbackObjc>)callback;

- (void)delListener:(nonnull id<ExtSdkDelegateObjc>)listener;

- (void)init:(nonnull id<NSObject>)config;

- (void)unInit:(nullable id<NSObject>)params;

@end
