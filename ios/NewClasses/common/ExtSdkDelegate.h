#import <Foundation/Foundation.h>

@protocol ExtSdkDelegate : <NSObject>

- (void)onReceive:(nonnull NSString*)methodType withParams:(nullable id<NSObject>)data;

- (void)setType:(nonnull NSString*)listenerType;

@end
