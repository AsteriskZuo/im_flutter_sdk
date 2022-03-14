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
- (instancetype)initWithChannelName:(NSString *)aChannelName
                          registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if(self = [super initWithChannelName:aChannelName
                           registrar:registrar]) {
       [EMClient.sharedClient.contactManager addDelegate:self delegateQueue:nil];
    }
    return self;
}


#pragma mark - FlutterPlugin

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    if ([ExtSdkMethodKeyAddContact isEqualToString:call.method]) {
        [self addContact:call.arguments result:result];
    } else if ([ExtSdkMethodKeyDeleteContact isEqualToString:call.method]) {
        [self deleteContact:call.arguments result:result];
    } else if ([ExtSdkMethodKeyGetAllContactsFromServer isEqualToString:call.method]) {
        [self getAllContactsFromServer:call.arguments result:result];
    } else if ([ExtSdkMethodKeyGetAllContactsFromDB isEqualToString:call.method]) {
        [self getAllContactsFromDB:call.arguments result:result];
    } else if ([ExtSdkMethodKeyAddUserToBlockList isEqualToString:call.method]) {
        [self addUserToBlockList:call.arguments result:result];
    } else if ([ExtSdkMethodKeyRemoveUserFromBlockList isEqualToString:call.method]) {
        [self removeUserFromBlockList:call.arguments result:result];
    } else if ([ExtSdkMethodKeyGetBlockListFromServer isEqualToString:call.method]) {
        [self getBlockListFromServer:call.arguments result:result];
    } else if ([ExtSdkMethodKeyGetBlockListFromDB isEqualToString:call.method]){
        [self getBlockListFromDB:call.arguments result:result];
    } else if ([ExtSdkMethodKeyAcceptInvitation isEqualToString:call.method]) {
        [self acceptInvitation:call.arguments result:result];
    } else if ([ExtSdkMethodKeyDeclineInvitation isEqualToString:call.method]) {
        [self declineInvitation:call.arguments result:result];
    } else if ([ExtSdkMethodKeyGetSelfIdsOnOtherPlatform isEqualToString:call.method]) {
        [self getSelfIdsOnOtherPlatform:call.arguments result:result];
    } else {
        [super handleMethodCall:call result:result];
    }
}


#pragma mark - Actions
- (void)addContact:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *username = param[@"username"];
    NSString *reason = param[@"reason"];
    [EMClient.sharedClient.contactManager addContact:username
                                             message:reason
                                          completion:^(NSString *aUsername, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:ExtSdkMethodKeyAddContact
                            error:aError
                           object:aUsername];
    }];
}

- (void)deleteContact:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *username = param[@"username"];
    BOOL keepConversation = [param[@"keepConversation"] boolValue];
    [EMClient.sharedClient.contactManager deleteContact:username
                                   isDeleteConversation:keepConversation
                                             completion:^(NSString *aUsername, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:ExtSdkMethodKeyDeleteContact
                            error:aError
                           object:aUsername];
    }];
}

- (void)getAllContactsFromServer:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    [EMClient.sharedClient.contactManager getContactsFromServerWithCompletion:^(NSArray *aList, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:ExtSdkMethodKeyGetAllContactsFromServer
                            error:aError
                           object:aList];
    }];
}

- (void)getAllContactsFromDB:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSArray *aList = EMClient.sharedClient.contactManager.getContacts;
    [weakSelf wrapperCallBack:result
                  channelName:ExtSdkMethodKeyGetAllContactsFromDB
                        error:nil
                       object:aList];
}


- (void)addUserToBlockList:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *username = param[@"username"];
    [EMClient.sharedClient.contactManager addUserToBlackList:username
                                                  completion:^(NSString *aUsername, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:ExtSdkMethodKeyAddUserToBlockList
                            error:aError
                           object:aUsername];
    }];
}

- (void)removeUserFromBlockList:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *username = param[@"username"];
    [EMClient.sharedClient.contactManager removeUserFromBlackList:username
                                                       completion:^(NSString *aUsername, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:ExtSdkMethodKeyRemoveUserFromBlockList
                            error:aError
                           object:aUsername];
    }];
    
}

- (void)getBlockListFromServer:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    [EMClient.sharedClient.contactManager getBlackListFromServerWithCompletion:^(NSArray *aList, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:ExtSdkMethodKeyGetBlockListFromServer
                            error:aError
                           object:aList];
    }];
}

- (void)getBlockListFromDB:(NSDictionary *)param result:(FlutterResult)result {
    
    NSArray * list = [EMClient.sharedClient.contactManager getBlackList];
    [self wrapperCallBack:result channelName:ExtSdkMethodKeyGetBlockListFromDB error:nil object:list];
}

- (void)acceptInvitation:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *username = param[@"username"];
    [EMClient.sharedClient.contactManager approveFriendRequestFromUser:username
                                                            completion:^(NSString *aUsername, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:ExtSdkMethodKeyAcceptInvitation
                            error:aError
                           object:aUsername];
    }];
}

- (void)declineInvitation:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *username = param[@"username"];
    [EMClient.sharedClient.contactManager declineFriendRequestFromUser:username
                                                            completion:^(NSString *aUsername, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:ExtSdkMethodKeyDeclineInvitation
                            error:aError
                           object:aUsername];
    }];
}

- (void)getSelfIdsOnOtherPlatform:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    [EMClient.sharedClient.contactManager getSelfIdsOnOtherPlatformWithCompletion:^(NSArray *aList, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:ExtSdkMethodKeyGetSelfIdsOnOtherPlatform
                            error:aError
                           object:aList];
    }];
}


#pragma mark - ExtSdkContactManagerDelegate

- (void)friendshipDidAddByUser:(NSString *)aUsername {
    NSDictionary *map = @{
        @"type":@"onContactAdded",
        @"username":aUsername
    };
    [self.channel invokeMethod:ExtSdkMethodKeyOnContactChanged
                     arguments:map];
}

- (void)friendshipDidRemoveByUser:(NSString *)aUsername {
    NSDictionary *map = @{
        @"type":@"onContactDeleted",
        @"username":aUsername
    };
    [self.channel invokeMethod:ExtSdkMethodKeyOnContactChanged
                     arguments:map];
}

- (void)friendRequestDidReceiveFromUser:(NSString *)aUsername
                                message:(NSString *)aMessage {
    NSDictionary *map = @{
        @"type":@"onContactInvited",
        @"username":aUsername,
        @"reason":aMessage
    };
    [self.channel invokeMethod:ExtSdkMethodKeyOnContactChanged
                     arguments:map];
}

- (void)friendRequestDidApproveByUser:(NSString *)aUsername {
    NSDictionary *map = @{
        @"type":@"onFriendRequestAccepted",
        @"username":aUsername
    };
    [self.channel invokeMethod:ExtSdkMethodKeyOnContactChanged
                     arguments:map];
}

- (void)friendRequestDidDeclineByUser:(NSString *)aUsername {
    NSDictionary *map = @{
        @"type":@"onFriendRequestDeclined",
        @"username":aUsername
    };
    [self.channel invokeMethod:ExtSdkMethodKeyOnContactChanged
                     arguments:map];
}

@end
