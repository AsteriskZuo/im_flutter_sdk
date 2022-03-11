
#import <Foundation/Foundation.h>

@class ExtSdkDelegate;
@class ExtSdkCallback;

@protocol ExtSdkApi : NSObject

- (void)init:(nonnull id<NSObject>)config;

- (void)unInit:(nullable id<NSObject>)params;

- (void)addListener:(nonnull id<ExtSdkDelegate>)listener;

- (void)delListener:(nonnull id<ExtSdkDelegate>)listener;

- (void)callSdkApi:(nonnull NSString*)methodType withParams:(nullable id<NSObject>)params withCallback:(nonnull id<ExtSdkCallback>)callback;

@end
