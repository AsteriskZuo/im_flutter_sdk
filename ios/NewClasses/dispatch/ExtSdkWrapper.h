//
//  ExtSdkWrapper.h
//
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import "ExtSdkCallbackObjc.h"
#import <HyphenateChat/HyphenateChat.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExtSdkWrapper : NSObject

- (void)onResult:(nonnull id<ExtSdkCallbackObjc>)result
    withMethodType:(nonnull NSString *)methodType
         withError:(nullable EMError *)error
        withParams:(nullable NSObject *)params;

- (void)onReceive:(NSString *)methodType withParams:(nullable NSObject *)params;

@end

NS_ASSUME_NONNULL_END
