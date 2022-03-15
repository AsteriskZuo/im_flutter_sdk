//
//  ExtSdkContactManagerWrapper.h
//
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import "ExtSdkWrapper.h"

NS_ASSUME_NONNULL_BEGIN

@interface ExtSdkContactManagerWrapper : ExtSdkWrapper

+ (nonnull instancetype)getInstance;

- (void)addContact:(NSDictionary *)param
            result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)deleteContact:(NSDictionary *)param
               result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)getAllContactsFromServer:(NSDictionary *)param
                          result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)getAllContactsFromDB:(NSDictionary *)param
                      result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)addUserToBlockList:(NSDictionary *)param
                    result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)removeUserFromBlockList:(NSDictionary *)param
                         result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)getBlockListFromServer:(NSDictionary *)param
                        result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)getBlockListFromDB:(NSDictionary *)param
                    result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)acceptInvitation:(NSDictionary *)param
                  result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)declineInvitation:(NSDictionary *)param
                   result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)getSelfIdsOnOtherPlatform:(NSDictionary *)param
                           result:(nonnull id<ExtSdkCallbackObjc>)result;

@end

NS_ASSUME_NONNULL_END
