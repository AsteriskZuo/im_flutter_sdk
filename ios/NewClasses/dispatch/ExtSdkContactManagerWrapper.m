//
//  ExtSdkContactManagerWrapper.m
//
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import "ExtSdkContactManagerWrapper.h"
#import "ExtSdkMethodTypeObjc.h"

@interface ExtSdkContactManagerWrapper () <EMContactManagerDelegate>

@end

@implementation ExtSdkContactManagerWrapper

+ (nonnull instancetype)getInstance {
    static ExtSdkContactManagerWrapper *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
      instance = [[ExtSdkContactManagerWrapper alloc] init];
    });
    return instance;
}


#pragma mark - Actions
- (void)addContact:(NSDictionary *)param
            result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;
    NSString *username = param[@"username"];
    NSString *reason = param[@"reason"];
    [EMClient.sharedClient.contactManager
        addContact:username
           message:reason
        completion:^(NSString *aUsername, EMError *aError) {
          [weakSelf onResult:result
              withMethodType:ExtSdkMethodKeyAddContact
                   withError:aError
                  withParams:aUsername];
        }];
}

- (void)deleteContact:(NSDictionary *)param
               result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;
    NSString *username = param[@"username"];
    BOOL keepConversation = [param[@"keepConversation"] boolValue];
    [EMClient.sharedClient.contactManager
               deleteContact:username
        isDeleteConversation:keepConversation
                  completion:^(NSString *aUsername, EMError *aError) {
                    [weakSelf onResult:result
                        withMethodType:ExtSdkMethodKeyDeleteContact
                             withError:aError
                            withParams:aUsername];
                  }];
}

- (void)getAllContactsFromServer:(NSDictionary *)param
                          result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.contactManager
        getContactsFromServerWithCompletion:^(NSArray *aList, EMError *aError) {
          [weakSelf onResult:result
              withMethodType:ExtSdkMethodKeyGetAllContactsFromServer
                   withError:aError
                  withParams:aList];
        }];
}

- (void)getAllContactsFromDB:(NSDictionary *)param
                      result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;
    NSArray *aList = EMClient.sharedClient.contactManager.getContacts;
    [weakSelf onResult:result
        withMethodType:ExtSdkMethodKeyGetAllContactsFromDB
             withError:nil
            withParams:aList];
}

- (void)addUserToBlockList:(NSDictionary *)param
                    result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;
    NSString *username = param[@"username"];
    [EMClient.sharedClient.contactManager
        addUserToBlackList:username
                completion:^(NSString *aUsername, EMError *aError) {
                  [weakSelf onResult:result
                      withMethodType:ExtSdkMethodKeyAddUserToBlockList
                           withError:aError
                          withParams:aUsername];
                }];
}

- (void)removeUserFromBlockList:(NSDictionary *)param
                         result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;
    NSString *username = param[@"username"];
    [EMClient.sharedClient.contactManager
        removeUserFromBlackList:username
                     completion:^(NSString *aUsername, EMError *aError) {
                       [weakSelf onResult:result
                           withMethodType:ExtSdkMethodKeyRemoveUserFromBlockList
                                withError:aError
                               withParams:aUsername];
                     }];
}

- (void)getBlockListFromServer:(NSDictionary *)param
                        result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.contactManager
        getBlackListFromServerWithCompletion:^(NSArray *aList,
                                               EMError *aError) {
          [weakSelf onResult:result
              withMethodType:ExtSdkMethodKeyGetBlockListFromServer
                   withError:aError
                  withParams:aList];
        }];
}

- (void)getBlockListFromDB:(NSDictionary *)param
                    result:(nonnull id<ExtSdkCallbackObjc>)result {

    NSArray *list = [EMClient.sharedClient.contactManager getBlackList];
    [self onResult:result
        withMethodType:ExtSdkMethodKeyGetBlockListFromDB
             withError:nil
            withParams:list];
}

- (void)acceptInvitation:(NSDictionary *)param
                  result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;
    NSString *username = param[@"username"];
    [EMClient.sharedClient.contactManager
        approveFriendRequestFromUser:username
                          completion:^(NSString *aUsername, EMError *aError) {
                            [weakSelf onResult:result
                                withMethodType:ExtSdkMethodKeyAcceptInvitation
                                     withError:aError
                                    withParams:aUsername];
                          }];
}

- (void)declineInvitation:(NSDictionary *)param
                   result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;
    NSString *username = param[@"username"];
    [EMClient.sharedClient.contactManager
        declineFriendRequestFromUser:username
                          completion:^(NSString *aUsername, EMError *aError) {
                            [weakSelf onResult:result
                                withMethodType:ExtSdkMethodKeyDeclineInvitation
                                     withError:aError
                                    withParams:aUsername];
                          }];
}

- (void)getSelfIdsOnOtherPlatform:(NSDictionary *)param
                           result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.contactManager
        getSelfIdsOnOtherPlatformWithCompletion:^(NSArray *aList,
                                                  EMError *aError) {
          [weakSelf onResult:result
              withMethodType:ExtSdkMethodKeyGetSelfIdsOnOtherPlatform
                   withError:aError
                  withParams:aList];
        }];
}

#pragma mark - ExtSdkContactManagerDelegate

- (void)friendshipDidAddByUser:(NSString *)aUsername {
    NSDictionary *map = @{@"type" : @"onContactAdded", @"username" : aUsername};
    [self onReceive:ExtSdkMethodKeyOnContactChanged withParams:map];
}

- (void)friendshipDidRemoveByUser:(NSString *)aUsername {
    NSDictionary *map =
        @{@"type" : @"onContactDeleted", @"username" : aUsername};
    [self onReceive:ExtSdkMethodKeyOnContactChanged withParams:map];
}

- (void)friendRequestDidReceiveFromUser:(NSString *)aUsername
                                message:(NSString *)aMessage {
    NSDictionary *map = @{
        @"type" : @"onContactInvited",
        @"username" : aUsername,
        @"reason" : aMessage
    };
    [self onReceive:ExtSdkMethodKeyOnContactChanged withParams:map];
}

- (void)friendRequestDidApproveByUser:(NSString *)aUsername {
    NSDictionary *map =
        @{@"type" : @"onFriendRequestAccepted", @"username" : aUsername};
    [self onReceive:ExtSdkMethodKeyOnContactChanged withParams:map];
}

- (void)friendRequestDidDeclineByUser:(NSString *)aUsername {
    NSDictionary *map =
        @{@"type" : @"onFriendRequestDeclined", @"username" : aUsername};
    [self onReceive:ExtSdkMethodKeyOnContactChanged withParams:map];
}

@end
