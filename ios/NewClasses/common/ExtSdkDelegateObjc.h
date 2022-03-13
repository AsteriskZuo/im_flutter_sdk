#import <Foundation/Foundation.h>

@protocol ExtSdkDelegateObjc <NSObject>

- (void)onReceive:(nonnull NSString*)methodType withParams:(nullable id<NSObject>)data;

- (void)setType:(nonnull NSString*)listenerType;

- (NSString*)getType;

@end
