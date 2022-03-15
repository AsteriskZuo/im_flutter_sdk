//
//  ExtSdkCallbackObjcImpl.h
//  im_flutter_sdk
//
//  Created by asterisk on 2022/3/14.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "ExtSdkCallbackObjc.h"


NS_ASSUME_NONNULL_BEGIN

@interface ExtSdkCallbackObjcImpl : NSObject <ExtSdkCallbackObjc>

- (nonnull instancetype)init:(nonnull FlutterResult)result;

- (void)onFail:(int)code withExtension:(nullable id<NSObject>)ext;

- (void)onSuccess:(nullable id<NSObject>)data;

@end

NS_ASSUME_NONNULL_END
