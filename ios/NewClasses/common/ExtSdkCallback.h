#import <Foundation/Foundation.h>

@protocol ExtSdkCallback <NSObject> : NSObject

- (void)onSuccess:(nullable id<NSObject> data);

- (void)onFail:(nonnull int)code withExtension:(nullable id<NSObject>)ext;

@end
