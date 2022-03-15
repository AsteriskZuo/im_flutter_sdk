//
//  ExtSdkClientWrapper.h
//
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import "ExtSdkWrapper.h"

NS_ASSUME_NONNULL_BEGIN

@interface ExtSdkClientWrapper : ExtSdkWrapper

+ (nonnull instancetype)getInstance;

- (void)initSDKWithDict:(NSDictionary *)param
                 result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)createAccount:(NSDictionary *)param
               result:(nonnull id<ExtSdkCallbackObjc>)result;
- (void)login:(NSDictionary *)param
       result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)logout:(NSDictionary *)param
        result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)changeAppKey:(NSDictionary *)param
              result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)getCurrentUser:(NSDictionary *)param
                result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)uploadLog:(NSDictionary *)param
           result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)compressLogs:(NSDictionary *)param
              result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)kickDevice:(NSDictionary *)param
            result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)kickAllDevices:(NSDictionary *)param
                result:(nonnull id<ExtSdkCallbackObjc>)result;
- (void)isLoggedInBefore:(NSDictionary *)param
                  result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)onMultiDeviceEvent:(NSDictionary *)param
                    result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)getLoggedInDevicesFromServer:(NSDictionary *)param
                              result:(nonnull id<ExtSdkCallbackObjc>)result;

@end

NS_ASSUME_NONNULL_END
