//
//  ExtSdkUserInfoManagerWrapper.h
//  im_flutter_sdk
//
//  Created by liujinliang on 2021/4/26.
//

#import "ExtSdkWrapper.h"

NS_ASSUME_NONNULL_BEGIN

@interface ExtSdkUserInfoManagerWrapper : ExtSdkWrapper

+ (nonnull instancetype)getInstance;

- (void)updateOwnUserInfo:(NSDictionary *)param
                   result:(nonnull id<ExtSdkCallbackObjc>)result;
- (void)updateOwnUserInfoWithType:(NSDictionary *)param
                           result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)fetchUserInfoById:(NSDictionary *)param
                   result:(nonnull id<ExtSdkCallbackObjc>)result;
- (void)fetchUserInfoByIdWithType:(NSDictionary *)param
                           result:(nonnull id<ExtSdkCallbackObjc>)result;
@end

NS_ASSUME_NONNULL_END
