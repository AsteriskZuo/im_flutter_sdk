#import "ExtSdkDispatch.h"
#import "ExtSdkDelegateObjc.h"


@interface ExtSdkDispatch () {
    id<ExtSdkDelegateObjc> _listener;
}

@end

@implementation ExtSdkDispatch

+ (nonnull instancetype)getInstance {
    static ExtSdkDispatch *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
      instance = [[ExtSdkDispatch alloc] init];
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
