//
//  ExtSdkCallbackObjcImpl.m
//  im_flutter_sdk
//
//  Created by asterisk on 2022/3/14.
//

#import "ExtSdkCallbackObjcImpl.h"
#import "ExtSdkThreadUtilObjc.h"
#import "ExtSdkChannelManager.h"

@interface ExtSdkCallbackObjcImpl () {
    FlutterResult _result;
}

@end

@implementation ExtSdkCallbackObjcImpl

- (nonnull instancetype)init:(nonnull FlutterResult)result {
    _result = result;
    return self;
}

- (void)onFail:(int)code withExtension:(nullable id<NSObject>)ext {
    __weak typeof(self) weakself = self;
    [ExtSdkThreadUtilObjc mainThreadExecute:^{
        FlutterResult _result = [weakself getResult];
        if (nil != _result) {
            _result(ext);
        }
    }];
}

- (void)onSuccess:(nullable id<NSObject>)data {
    [ExtSdkThreadUtilObjc mainThreadExecute:^{
        self->_result(data);
    }];
}

- (FlutterResult)getResult {
    return self->_result;
}

@end
