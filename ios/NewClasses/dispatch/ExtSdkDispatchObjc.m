#import "ExtSdkDispatchObjc.h"
#import "ExtSdkDelegateObjc.h"


@interface ExtSdkDispatchObjc () {
    id<ExtSdkDelegateObjc> _listener;
}

@end

@implementation ExtSdkDispatchObjc

+ (nonnull instancetype)getInstance {
    static ExtSdkDispatchObjc *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
      instance = [[ExtSdkDispatchObjc alloc] init];
    });
    return instance;
}

- (void)addListener:(nonnull id<ExtSdkDelegateObjc>)listener {
    _listener = listener;
}

- (void)callSdkApi:(nonnull NSString *)methodType withParams:(nullable id<NSObject>)params withCallback:(nonnull id<ExtSdkCallbackObjc>)callback {
    
}

- (void)delListener:(nonnull id<ExtSdkDelegateObjc>)listener {
    
}

- (void)init:(nonnull id<NSObject>)config {
    
}

- (void)unInit:(nullable id<NSObject>)params {
    
}

@end
